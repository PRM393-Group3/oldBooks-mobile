import 'dart:math';

import '../domain/kyc_models.dart';

/// Ngưỡng kiểm tra khuôn mặt và thử thách liveness. Gom một chỗ để chỉnh và
/// test; toàn bộ là logic thuần, không đụng camera hay ML Kit.
abstract final class LivenessThresholds {
  /// Mặt nhìn thẳng: lệch ngang/dọc tối đa (độ).
  static const frontalMaxYaw = 12.0;
  static const frontalMaxPitch = 15.0;

  /// Chiều rộng khung mặt so với chiều rộng ảnh.
  static const minFaceWidth = 0.30;
  static const maxFaceWidth = 0.80;

  /// Tâm mặt lệch khỏi tâm ảnh tối đa (tỉ lệ cạnh ảnh).
  static const maxCenterOffset = 0.18;

  /// Độ sáng trung bình kênh Y (0..255) chấp nhận được.
  static const minLuma = 50.0;
  static const maxLuma = 220.0;

  /// Số khung liên tiếp đạt yêu cầu mới chụp, tránh chụp khung nhòe.
  static const stableFrames = 3;

  /// Quay đầu: góc Y đủ lớn về một phía (độ).
  static const turnYaw = 20.0;

  /// Nhắm mắt khi xác suất mở mắt dưới ngưỡng này, mở khi trên ngưỡng kia.
  static const eyeClosed = 0.3;
  static const eyeOpen = 0.6;

  /// Dấu của `headEulerAngleY` khi quay sang TRÁI của người dùng. ML Kit tính
  /// góc Y dương khi mặt quay về phía bên phải của ảnh xử lý (ảnh không lật
  /// gương); người nhìn camera quay sang trái của mình thì mặt hướng về bên
  /// phải ảnh. Đổi dấu tại đây nếu máy thật cho kết quả ngược.
  static const turnLeftSign = 1.0;
}

/// Khung mặt theo tỉ lệ 0..1 của ảnh đã xoay thẳng đứng.
class NormBox {
  const NormBox(this.left, this.top, this.right, this.bottom);

  final double left;
  final double top;
  final double right;
  final double bottom;

  double get width => right - left;
  double get height => bottom - top;
  double get centerX => (left + right) / 2;
  double get centerY => (top + bottom) / 2;
}

/// Kết quả nhận diện một khung hình, đã quy về dạng không phụ thuộc ML Kit.
class FaceObservation {
  const FaceObservation({
    required this.faceCount,
    this.box,
    this.yaw,
    this.pitch,
    this.leftEyeOpen,
    this.rightEyeOpen,
    this.luma,
  });

  final int faceCount;

  /// Mặt duy nhất trong khung (null nếu không có hoặc nhiều hơn một mặt).
  final NormBox? box;
  final double? yaw;
  final double? pitch;
  final double? leftEyeOpen;
  final double? rightEyeOpen;

  /// Độ sáng trung bình 0..255, `null` nếu không đo được.
  final double? luma;
}

/// Lý do khung hình chưa đạt, để hiện gợi ý cho người dùng.
enum FaceHint {
  noFace,
  multipleFaces,
  tooFar,
  tooClose,
  notCentered,
  tooDark,
  tooBright,
  lookStraight,
  ok,
}

/// Kiểm tra mặt có đủ tốt để chụp selfie: đúng một mặt, kích thước và vị trí
/// hợp lý, đủ sáng, nhìn thẳng.
FaceHint evaluateFrame(FaceObservation o) {
  if (o.faceCount == 0) return FaceHint.noFace;
  if (o.faceCount > 1) return FaceHint.multipleFaces;
  final box = o.box;
  if (box == null) return FaceHint.noFace;
  if (box.width < LivenessThresholds.minFaceWidth) return FaceHint.tooFar;
  if (box.width > LivenessThresholds.maxFaceWidth) return FaceHint.tooClose;
  if ((box.centerX - 0.5).abs() > LivenessThresholds.maxCenterOffset ||
      (box.centerY - 0.5).abs() > LivenessThresholds.maxCenterOffset) {
    return FaceHint.notCentered;
  }
  final luma = o.luma;
  if (luma != null && luma < LivenessThresholds.minLuma) {
    return FaceHint.tooDark;
  }
  if (luma != null && luma > LivenessThresholds.maxLuma) {
    return FaceHint.tooBright;
  }
  return FaceHint.ok;
}

bool isFrontal(FaceObservation o) =>
    (o.yaw ?? 0).abs() <= LivenessThresholds.frontalMaxYaw &&
    (o.pitch ?? 0).abs() <= LivenessThresholds.frontalMaxPitch;

/// Chọn [count] thử thách ngẫu nhiên không trùng nhau.
List<LivenessChallenge> pickChallenges(Random random, {int count = 2}) {
  final all = List.of(LivenessChallenge.values)..shuffle(random);
  return all.take(count).toList();
}

/// Độ sáng trung bình của mặt phẳng Y (NV21), lấy mẫu mỗi [step] điểm ảnh.
double meanLuma(List<int> yPlane, {int step = 16}) {
  if (yPlane.isEmpty) return 0;
  var sum = 0;
  var n = 0;
  for (var i = 0; i < yPlane.length; i += step) {
    sum += yPlane[i];
    n++;
  }
  return sum / n;
}

/// Sự kiện [LivenessSession.update] phát ra.
enum LivenessEvent {
  /// Chưa có gì mới.
  none,

  /// Khung đạt yêu cầu liên tiếp: chụp ảnh selfie ngay.
  captureSelfie,

  /// Vừa hoàn thành thử thách hiện tại: chụp khung liveness ngay.
  challengePassed,

  /// Hoàn thành tất cả thử thách.
  completed,
}

class LivenessUpdate {
  const LivenessUpdate(this.event, this.hint);

  final LivenessEvent event;
  final FaceHint hint;
}

/// Máy trạng thái liveness chủ động: (1) chờ mặt thẳng, đủ tốt vài khung rồi
/// chụp selfie, (2) lần lượt từng thử thách. Nhận [FaceObservation] của từng
/// khung, không biết gì về camera.
class LivenessSession {
  LivenessSession(this.challenges) : assert(challenges.isNotEmpty);

  final List<LivenessChallenge> challenges;

  int _stable = 0;
  bool _selfieTaken = false;
  int _index = 0;

  // Nhắm mắt: mở -> nhắm -> mở.
  bool _sawOpen = false;
  bool _sawClosed = false;

  bool get selfieTaken => _selfieTaken;

  /// Số thử thách đã xong.
  int get passedCount => _index;

  bool get isDone => _selfieTaken && _index >= challenges.length;

  /// Thử thách đang chờ (null khi chưa chụp selfie hoặc đã xong).
  LivenessChallenge? get current =>
      _selfieTaken && _index < challenges.length ? challenges[_index] : null;

  LivenessUpdate update(FaceObservation o) {
    if (isDone) return const LivenessUpdate(LivenessEvent.none, FaceHint.ok);
    final hint = evaluateFrame(o);

    if (!_selfieTaken) {
      if (hint == FaceHint.ok && !isFrontal(o)) {
        _stable = 0;
        return const LivenessUpdate(LivenessEvent.none, FaceHint.lookStraight);
      }
      if (hint != FaceHint.ok) {
        _stable = 0;
        return LivenessUpdate(LivenessEvent.none, hint);
      }
      if (++_stable >= LivenessThresholds.stableFrames) {
        _selfieTaken = true;
        _resetBlink();
        return const LivenessUpdate(LivenessEvent.captureSelfie, FaceHint.ok);
      }
      return const LivenessUpdate(LivenessEvent.none, FaceHint.ok);
    }

    // Thử thách: vẫn cần đúng một mặt trong khung, nhưng không đòi nhìn thẳng.
    if (o.faceCount != 1 || o.box == null) {
      return LivenessUpdate(LivenessEvent.none, hint);
    }
    if (_challengeMet(challenges[_index], o)) {
      _index++;
      _resetBlink();
      return LivenessUpdate(
        isDone ? LivenessEvent.completed : LivenessEvent.challengePassed,
        FaceHint.ok,
      );
    }
    return const LivenessUpdate(LivenessEvent.none, FaceHint.ok);
  }

  void _resetBlink() {
    _sawOpen = false;
    _sawClosed = false;
  }

  bool _challengeMet(LivenessChallenge c, FaceObservation o) {
    switch (c) {
      case LivenessChallenge.turnLeft:
        return (o.yaw ?? 0) * LivenessThresholds.turnLeftSign >=
            LivenessThresholds.turnYaw;
      case LivenessChallenge.turnRight:
        return (o.yaw ?? 0) * LivenessThresholds.turnLeftSign <=
            -LivenessThresholds.turnYaw;
      case LivenessChallenge.blink:
        final l = o.leftEyeOpen;
        final r = o.rightEyeOpen;
        if (l == null || r == null) return false;
        final open = min(l, r) >= LivenessThresholds.eyeOpen;
        final closed = max(l, r) <= LivenessThresholds.eyeClosed;
        if (!_sawClosed) {
          if (open) _sawOpen = true;
          if (_sawOpen && closed) _sawClosed = true;
          return false;
        }
        return open;
    }
  }
}
