import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

/// Lý do thiết bị không chạy được AI trên máy.
enum DeviceIssue { notAndroid, androidTooOld, noArm64, lowRam, lowFreeRam }

/// Thông số cần để đánh giá. Tách khỏi plugin để kiểm thử được.
class DeviceSpecs {
  const DeviceSpecs({
    required this.isAndroid,
    required this.sdkInt,
    required this.abis,
    required this.totalRamMb,
    required this.freeRamMb,
    required this.isLowRamDevice,
  });

  final bool isAndroid;
  final int sdkInt;
  final List<String> abis;
  final int totalRamMb;
  final int freeRamMb;
  final bool isLowRamDevice;
}

/// LiteRT-LM chỉ có Android 11+ (API 30) và arm64.
const minAiSdk = 30;

/// Gemma 4 E2B cần máy từ 6GB; máy "6GB" báo khoảng 5,5–5,9GB tổng nên đặt ngưỡng 5,5GB.
const minAiTotalRamMb = 5500;

/// RAM trống tối thiểu để nạp model; thấp hơn thì nên đóng bớt ứng dụng.
const minAiFreeRamMb = 1500;

class DeviceCheck {
  const DeviceCheck(this.issues, this.specs);

  final List<DeviceIssue> issues;
  final DeviceSpecs specs;

  bool get compatible => issues.isEmpty;
}

/// Đánh giá thông số: trả danh sách vấn đề (rỗng là tương thích).
DeviceCheck evaluateDevice(DeviceSpecs s) {
  if (!s.isAndroid) return DeviceCheck(const [DeviceIssue.notAndroid], s);
  return DeviceCheck([
    if (s.sdkInt < minAiSdk) DeviceIssue.androidTooOld,
    if (!s.abis.contains('arm64-v8a')) DeviceIssue.noArm64,
    if (s.totalRamMb < minAiTotalRamMb || s.isLowRamDevice) DeviceIssue.lowRam,
    if (s.totalRamMb >= minAiTotalRamMb && s.freeRamMb < minAiFreeRamMb)
      DeviceIssue.lowFreeRam,
  ], s);
}

/// Đọc thông số máy thật rồi đánh giá. Không đọc được thì coi như không
/// tương thích (an toàn hơn là để model chạy rồi đơ máy).
Future<DeviceCheck> checkDeviceCompat() async {
  if (!Platform.isAndroid) {
    return evaluateDevice(
      const DeviceSpecs(
        isAndroid: false,
        sdkInt: 0,
        abis: [],
        totalRamMb: 0,
        freeRamMb: 0,
        isLowRamDevice: false,
      ),
    );
  }
  try {
    final info = await DeviceInfoPlugin().androidInfo;
    return evaluateDevice(
      DeviceSpecs(
        isAndroid: true,
        sdkInt: info.version.sdkInt,
        abis: info.supportedAbis,
        totalRamMb: info.physicalRamSize,
        freeRamMb: info.availableRamSize,
        isLowRamDevice: info.isLowRamDevice,
      ),
    );
  } catch (_) {
    return evaluateDevice(
      const DeviceSpecs(
        isAndroid: true,
        sdkInt: 0,
        abis: [],
        totalRamMb: 0,
        freeRamMb: 0,
        isLowRamDevice: true,
      ),
    );
  }
}
