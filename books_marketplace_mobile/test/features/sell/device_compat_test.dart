import 'package:books_marketplace_mobile/features/sell/ai/device_compat.dart';
import 'package:flutter_test/flutter_test.dart';

DeviceSpecs specs({
  bool isAndroid = true,
  int sdk = 34,
  List<String> abis = const ['arm64-v8a', 'armeabi-v7a'],
  int total = 5800,
  int free = 2500,
  bool lowRam = false,
}) => DeviceSpecs(
  isAndroid: isAndroid,
  sdkInt: sdk,
  abis: abis,
  totalRamMb: total,
  freeRamMb: free,
  isLowRamDevice: lowRam,
);

void main() {
  test('máy 6GB Android 14 arm64 tương thích', () {
    expect(evaluateDevice(specs()).compatible, isTrue);
  });

  test('Android 10 bị loại', () {
    expect(evaluateDevice(specs(sdk: 29)).issues, [DeviceIssue.androidTooOld]);
  });

  test('máy không có arm64 bị loại', () {
    expect(evaluateDevice(specs(abis: const ['x86_64'])).issues, [
      DeviceIssue.noArm64,
    ]);
  });

  test('RAM 4GB hoặc cờ low-ram bị loại', () {
    expect(evaluateDevice(specs(total: 4000)).issues, [DeviceIssue.lowRam]);
    expect(evaluateDevice(specs(lowRam: true)).issues, [DeviceIssue.lowRam]);
  });

  test('RAM trống thấp chỉ báo lowFreeRam khi tổng RAM đủ', () {
    expect(evaluateDevice(specs(free: 800)).issues, [DeviceIssue.lowFreeRam]);
    expect(evaluateDevice(specs(total: 4000, free: 300)).issues, [
      DeviceIssue.lowRam,
    ]);
  });

  test('không phải Android', () {
    expect(evaluateDevice(specs(isAndroid: false)).issues, [
      DeviceIssue.notAndroid,
    ]);
  });

  test('nhiều lý do cùng lúc', () {
    expect(evaluateDevice(specs(sdk: 28, total: 2000)).issues, [
      DeviceIssue.androidTooOld,
      DeviceIssue.lowRam,
    ]);
  });
}
