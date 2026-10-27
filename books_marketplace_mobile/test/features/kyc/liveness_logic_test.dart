import 'dart:math';

import 'package:books_marketplace_mobile/features/kyc/domain/kyc_models.dart';
import 'package:books_marketplace_mobile/features/kyc/face/liveness_logic.dart';
import 'package:flutter_test/flutter_test.dart';

const _centered = NormBox(0.3, 0.25, 0.7, 0.75);

FaceObservation _face({
  double yaw = 0,
  double pitch = 0,
  double? left = 0.9,
  double? right = 0.9,
  NormBox? box = _centered,
  double? luma = 120,
  int count = 1,
}) => FaceObservation(
  faceCount: count,
  box: box,
  yaw: yaw,
  pitch: pitch,
  leftEyeOpen: left,
  rightEyeOpen: right,
  luma: luma,
);

/// Đưa [n] khung đạt yêu cầu để chụp selfie.
LivenessUpdate _toSelfie(LivenessSession s) {
  late LivenessUpdate u;
  for (var i = 0; i < LivenessThresholds.stableFrames; i++) {
    u = s.update(_face());
  }
  return u;
}

void main() {
  group('evaluateFrame', () {
    test('đạt khi đúng một mặt, to vừa, giữa khung, đủ sáng', () {
      expect(evaluateFrame(_face()), FaceHint.ok);
    });
    test('không mặt, nhiều mặt', () {
      expect(
        evaluateFrame(const FaceObservation(faceCount: 0)),
        FaceHint.noFace,
      );
      expect(evaluateFrame(_face(count: 2)), FaceHint.multipleFaces);
    });
    test('quá xa, quá gần, lệch tâm', () {
      expect(
        evaluateFrame(_face(box: const NormBox(0.4, 0.4, 0.55, 0.6))),
        FaceHint.tooFar,
      );
      expect(
        evaluateFrame(_face(box: const NormBox(0.05, 0.1, 0.95, 0.9))),
        FaceHint.tooClose,
      );
      expect(
        evaluateFrame(_face(box: const NormBox(0.0, 0.25, 0.4, 0.75))),
        FaceHint.notCentered,
      );
    });
    test('tối, chói; không đo được sáng thì bỏ qua', () {
      expect(evaluateFrame(_face(luma: 20)), FaceHint.tooDark);
      expect(evaluateFrame(_face(luma: 250)), FaceHint.tooBright);
      expect(evaluateFrame(_face(luma: null)), FaceHint.ok);
    });
  });

  group('LivenessSession', () {
    test('chụp selfie chỉ sau đủ số khung ổn định liên tiếp', () {
      final s = LivenessSession([LivenessChallenge.blink]);
      for (var i = 0; i < LivenessThresholds.stableFrames - 1; i++) {
        expect(s.update(_face()).event, LivenessEvent.none);
      }
      expect(s.update(_face()).event, LivenessEvent.captureSelfie);
      expect(s.selfieTaken, isTrue);
      expect(s.current, LivenessChallenge.blink);
    });

    test('khung xấu đặt lại bộ đếm ổn định', () {
      final s = LivenessSession([LivenessChallenge.blink]);
      s.update(_face());
      s.update(_face());
      s.update(_face(count: 2));
      expect(s.update(_face()).event, LivenessEvent.none);
      expect(s.selfieTaken, isFalse);
    });

    test('mặt chưa nhìn thẳng thì chưa chụp selfie', () {
      final s = LivenessSession([LivenessChallenge.blink]);
      for (var i = 0; i < 10; i++) {
        final u = s.update(_face(yaw: 30));
        expect(u.event, LivenessEvent.none);
        expect(u.hint, FaceHint.lookStraight);
      }
    });

    test('quay trái: cần góc đủ lớn đúng chiều', () {
      final s = LivenessSession([LivenessChallenge.turnLeft]);
      _toSelfie(s);
      const sign = LivenessThresholds.turnLeftSign;
      expect(s.update(_face(yaw: 10 * sign)).event, LivenessEvent.none);
      expect(s.update(_face(yaw: -30 * sign)).event, LivenessEvent.none);
      expect(s.update(_face(yaw: 25 * sign)).event, LivenessEvent.completed);
      expect(s.isDone, isTrue);
    });

    test('quay phải ngược chiều với quay trái', () {
      final s = LivenessSession([LivenessChallenge.turnRight]);
      _toSelfie(s);
      const sign = LivenessThresholds.turnLeftSign;
      expect(s.update(_face(yaw: 30 * sign)).event, LivenessEvent.none);
      expect(s.update(_face(yaw: -25 * sign)).event, LivenessEvent.completed);
    });

    test('chớp mắt: phải mở -> nhắm -> mở; mắt luôn mở không qua', () {
      final s = LivenessSession([LivenessChallenge.blink]);
      _toSelfie(s);
      for (var i = 0; i < 5; i++) {
        expect(s.update(_face()).event, LivenessEvent.none);
      }
      expect(s.update(_face(left: 0.1, right: 0.1)).event, LivenessEvent.none);
      // Vẫn nhắm: chưa tính.
      expect(s.update(_face(left: 0.1, right: 0.1)).event, LivenessEvent.none);
      expect(s.update(_face()).event, LivenessEvent.completed);
    });

    test('chớp mắt: nhắm ngay từ đầu (chưa thấy mở) không tính', () {
      final s = LivenessSession([LivenessChallenge.blink]);
      _toSelfie(s);
      s.update(_face(left: 0.1, right: 0.1));
      expect(s.update(_face()).event, LivenessEvent.none);
    });

    test('không có xác suất mắt thì không bao giờ qua', () {
      final s = LivenessSession([LivenessChallenge.blink]);
      _toSelfie(s);
      for (var i = 0; i < 20; i++) {
        expect(
          s.update(_face(left: null, right: null)).event,
          LivenessEvent.none,
        );
      }
    });

    test('hai thử thách: challengePassed rồi completed, theo thứ tự', () {
      final s = LivenessSession([
        LivenessChallenge.turnRight,
        LivenessChallenge.turnLeft,
      ]);
      _toSelfie(s);
      const sign = LivenessThresholds.turnLeftSign;
      expect(s.current, LivenessChallenge.turnRight);
      expect(
        s.update(_face(yaw: -30 * sign)).event,
        LivenessEvent.challengePassed,
      );
      expect(s.passedCount, 1);
      expect(s.current, LivenessChallenge.turnLeft);
      expect(s.update(_face(yaw: 30 * sign)).event, LivenessEvent.completed);
      expect(s.current, isNull);
    });

    test('nhiều mặt trong lúc thử thách thì không qua', () {
      final s = LivenessSession([LivenessChallenge.turnLeft]);
      _toSelfie(s);
      const sign = LivenessThresholds.turnLeftSign;
      expect(
        s.update(_face(yaw: 30 * sign, count: 2)).event,
        LivenessEvent.none,
      );
    });
  });

  test('pickChallenges: không trùng, đủ số lượng, có đủ phân bố', () {
    final seen = <LivenessChallenge>{};
    for (var seed = 0; seed < 60; seed++) {
      final c = pickChallenges(Random(seed));
      expect(c.length, 2);
      expect(c.toSet().length, 2);
      seen.addAll(c);
    }
    expect(seen, LivenessChallenge.values.toSet());
  });

  test('meanLuma', () {
    expect(meanLuma(List.filled(1000, 100)), 100);
    expect(meanLuma([0, 255, 0, 255], step: 1), 127.5);
    expect(meanLuma(const []), 0);
  });
}
