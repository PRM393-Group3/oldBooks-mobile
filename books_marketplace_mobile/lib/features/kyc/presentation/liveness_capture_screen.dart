import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/widgets/app_button.dart';
import '../domain/kyc_models.dart';
import '../face/face_image.dart';
import '../face/liveness_logic.dart';

/// Chạy bước chụp selfie liveness. Trả `null` nếu người dùng thoát. Mặc định
/// mở camera trên Android; test ghi đè bằng kết quả giả.
typedef LivenessRunner = Future<LivenessResult?> Function(BuildContext context);

final livenessRunnerProvider = Provider<LivenessRunner>(
  (ref) =>
      (context) => Navigator.of(context).push<LivenessResult>(
        MaterialPageRoute(builder: (_) => const LivenessCaptureScreen()),
      ),
);

/// Thời gian tối đa cho cả phiên chụp.
const _sessionTimeout = Duration(seconds: 40);

/// Khoảng cách tối thiểu giữa hai khung hình được nhận diện.
const _frameGap = Duration(milliseconds: 120);

const _jpegSide = 1280;
const _jpegQuality = 88;

/// Màn hình chụp selfie có thử thách liveness chủ động. Dùng camera trước, ML
/// Kit nhận diện mặt trên từng khung hình; mọi quyết định nằm ở
/// [LivenessSession] (logic thuần, có test). Chỉ Android.
class LivenessCaptureScreen extends StatefulWidget {
  const LivenessCaptureScreen({super.key});

  @override
  State<LivenessCaptureScreen> createState() => _LivenessCaptureScreenState();
}

enum _Stage { starting, running, capturing, failed, denied, unsupported }

class _LivenessCaptureScreenState extends State<LivenessCaptureScreen>
    with WidgetsBindingObserver {
  CameraController? _camera;
  CameraDescription? _description;
  late final FaceDetector _detector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,
      performanceMode: FaceDetectorMode.fast,
      minFaceSize: 0.2,
    ),
  );
  late LivenessSession _session;
  Timer? _timeout;

  _Stage _stage = _Stage.starting;
  FaceHint _hint = FaceHint.noFace;
  bool _busy = false;
  DateTime _lastFrame = DateTime.fromMillisecondsSinceEpoch(0);

  Uint8List? _selfie;
  final List<Uint8List> _frames = [];

  static const _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _start();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timeout?.cancel();
    _stopCamera();
    _detector.close();
    super.dispose();
  }

  Future<void> _stopCamera() async {
    final c = _camera;
    _camera = null;
    if (c == null) return;
    try {
      if (c.value.isStreamingImages) await c.stopImageStream();
    } catch (_) {}
    await c.dispose();
  }

  Future<void> _start() async {
    if (!Platform.isAndroid) {
      setState(() => _stage = _Stage.unsupported);
      return;
    }
    setState(() {
      _stage = _Stage.starting;
      _hint = FaceHint.noFace;
      _selfie = null;
      _frames.clear();
    });
    _session = LivenessSession(pickChallenges(Random.secure()));
    try {
      final cameras = await availableCameras();
      final front = cameras
          .where((c) => c.lensDirection == CameraLensDirection.front)
          .firstOrNull;
      if (front == null) {
        if (mounted) setState(() => _stage = _Stage.failed);
        return;
      }
      _description = front;
      final controller = CameraController(
        front,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.nv21,
      );
      await controller.initialize();
      await controller.lockCaptureOrientation(DeviceOrientation.portraitUp);
      if (!mounted) {
        await controller.dispose();
        return;
      }
      _camera = controller;
      await controller.startImageStream(_onFrame);
      _timeout?.cancel();
      _timeout = Timer(_sessionTimeout, () {
        if (mounted && _stage == _Stage.running) _fail();
      });
      setState(() => _stage = _Stage.running);
    } on CameraException catch (e) {
      debugPrint('[KYC] camera: ${e.code}');
      if (mounted) {
        setState(
          () => _stage = e.code.contains('Denied')
              ? _Stage.denied
              : _Stage.failed,
        );
      }
    } catch (e) {
      debugPrint('[KYC] camera: ${e.runtimeType}');
      if (mounted) setState(() => _stage = _Stage.failed);
    }
  }

  void _fail() {
    _timeout?.cancel();
    _stopCamera();
    setState(() => _stage = _Stage.failed);
  }

  Future<void> _onFrame(CameraImage image) async {
    final now = DateTime.now();
    if (_busy ||
        _stage != _Stage.running ||
        now.difference(_lastFrame) < _frameGap) {
      return;
    }
    _busy = true;
    _lastFrame = now;
    try {
      final input = _toInputImage(image);
      if (input == null) return;
      final faces = await _detector.processImage(input);
      if (!mounted || _stage != _Stage.running) return;

      final rotated =
          input.metadata?.rotation == InputImageRotation.rotation90deg ||
          input.metadata?.rotation == InputImageRotation.rotation270deg;
      final w = (rotated ? image.height : image.width).toDouble();
      final h = (rotated ? image.width : image.height).toDouble();
      final face = faces.length == 1 ? faces.first : null;
      final box = face?.boundingBox;
      final obs = FaceObservation(
        faceCount: faces.length,
        box: box == null
            ? null
            : NormBox(box.left / w, box.top / h, box.right / w, box.bottom / h),
        yaw: face?.headEulerAngleY,
        pitch: face?.headEulerAngleX,
        leftEyeOpen: face?.leftEyeOpenProbability,
        rightEyeOpen: face?.rightEyeOpenProbability,
        luma: image.planes.isEmpty
            ? null
            : meanLuma(
                image.planes.first.bytes.sublist(
                  0,
                  min(
                    image.planes.first.bytes.length,
                    image.width * image.height,
                  ),
                ),
              ),
      );
      final update = _session.update(obs);
      if (update.hint != _hint && mounted) setState(() => _hint = update.hint);

      switch (update.event) {
        case LivenessEvent.none:
          break;
        case LivenessEvent.captureSelfie:
          await _capture(selfie: true);
        case LivenessEvent.challengePassed:
        case LivenessEvent.completed:
          await _capture(selfie: false);
          if (update.event == LivenessEvent.completed) _finish();
      }
    } catch (e) {
      debugPrint('[KYC] khung hình lỗi: ${e.runtimeType}');
    } finally {
      _busy = false;
    }
  }

  Future<void> _capture({required bool selfie}) async {
    final camera = _camera;
    if (camera == null) return;
    setState(() => _stage = _Stage.capturing);
    try {
      final file = await camera.takePicture();
      final raw = await file.readAsBytes();
      try {
        await File(file.path).delete();
      } catch (_) {}
      final jpeg = await compute(normalizeJpeg, (
        bytes: raw,
        maxSide: _jpegSide,
        quality: _jpegQuality,
      ));
      if (jpeg == null) throw StateError('decode');
      if (selfie) {
        _selfie = jpeg;
      } else {
        _frames.add(jpeg);
      }
      if (mounted) setState(() => _stage = _Stage.running);
    } catch (e) {
      debugPrint('[KYC] chụp lỗi: ${e.runtimeType}');
      if (mounted) _fail();
    }
  }

  void _finish() {
    _timeout?.cancel();
    final selfie = _selfie;
    if (selfie == null || !mounted) return;
    Navigator.of(context).pop(
      LivenessResult(
        selfie: selfie,
        frames: List.of(_frames),
        challenges: List.of(_session.challenges),
      ),
    );
  }

  /// Dựng [InputImage] từ khung NV21 theo công thức xoay của ví dụ ML Kit.
  InputImage? _toInputImage(CameraImage image) {
    final camera = _camera;
    final desc = _description;
    if (camera == null || desc == null) return null;
    final sensor = desc.sensorOrientation;
    final deviceRot = _orientations[camera.value.deviceOrientation] ?? 0;
    final compensation = desc.lensDirection == CameraLensDirection.front
        ? (sensor + deviceRot) % 360
        : (sensor - deviceRot + 360) % 360;
    final rotation = InputImageRotationValue.fromRawValue(compensation);
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (rotation == null ||
        format == null ||
        format != InputImageFormat.nv21 ||
        image.planes.length != 1) {
      return null;
    }
    final plane = image.planes.first;
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final camera = _camera;
    final live =
        camera != null &&
        camera.value.isInitialized &&
        (_stage == _Stage.running || _stage == _Stage.capturing);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(l.kycLivenessTitle),
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: live
                      ? ClipOval(
                          child: SizedBox(
                            width: 300,
                            height: 400,
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: camera.value.previewSize!.height,
                                height: camera.value.previewSize!.width,
                                child: CameraPreview(camera),
                              ),
                            ),
                          ),
                        )
                      : _Status(stage: _stage, onRetry: _start),
                ),
              ),
              if (live) ...[
                _Instruction(session: _session, hint: _hint),
                const SizedBox(height: AppSpacing.sm),
                _Dots(session: _session),
              ],
              if (_stage == _Stage.failed || _stage == _Stage.denied)
                const SizedBox(height: AppSpacing.sm),
              Text(
                l.kycLivenessPrivacy,
                textAlign: TextAlign.center,
                style: context.text.labelSmall?.copyWith(
                  color: colors.inverseMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Status extends StatelessWidget {
  const _Status({required this.stage, required this.onRetry});

  final _Stage stage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final style = context.text.bodyMedium?.copyWith(color: Colors.white);
    return switch (stage) {
      _Stage.starting => const CircularProgressIndicator(),
      _Stage.denied => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l.kycCameraDenied, textAlign: TextAlign.center, style: style),
        ],
      ),
      _Stage.unsupported => Text(
        l.kycLivenessUnsupported,
        textAlign: TextAlign.center,
        style: style,
      ),
      _Stage.failed => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l.kycLivenessFailed, textAlign: TextAlign.center, style: style),
          const SizedBox(height: AppSpacing.md),
          AppButton(label: l.aiRetry, onPressed: onRetry, expanded: false),
        ],
      ),
      _ => const SizedBox.shrink(),
    };
  }
}

class _Instruction extends StatelessWidget {
  const _Instruction({required this.session, required this.hint});

  final LivenessSession session;
  final FaceHint hint;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final current = session.current;
    final text = current != null && hint == FaceHint.ok
        ? switch (current) {
            LivenessChallenge.blink => l.kycChallengeBlink,
            LivenessChallenge.turnLeft => l.kycChallengeTurnLeft,
            LivenessChallenge.turnRight => l.kycChallengeTurnRight,
          }
        : switch (hint) {
            FaceHint.noFace => l.kycHintNoFace,
            FaceHint.multipleFaces => l.kycHintMultipleFaces,
            FaceHint.tooFar => l.kycHintTooFar,
            FaceHint.tooClose => l.kycHintTooClose,
            FaceHint.notCentered => l.kycHintNotCentered,
            FaceHint.tooDark => l.kycHintTooDark,
            FaceHint.tooBright => l.kycHintTooBright,
            FaceHint.lookStraight => l.kycHintLookStraight,
            FaceHint.ok => l.kycHintHold,
          };
    return Semantics(
      liveRegion: true,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: context.text.titleMedium?.copyWith(color: Colors.white),
      ),
    );
  }
}

/// Chấm tiến trình: một chấm cho selfie và mỗi thử thách.
class _Dots extends StatelessWidget {
  const _Dots({required this.session});

  final LivenessSession session;

  @override
  Widget build(BuildContext context) {
    final total = session.challenges.length + 1;
    final done = (session.selfieTaken ? 1 : 0) + session.passedCount;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < total; i++)
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i < done ? context.colors.success : Colors.white24,
            ),
          ),
      ],
    );
  }
}
