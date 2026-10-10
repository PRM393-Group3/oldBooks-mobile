import 'dart:convert';

import 'package:books_marketplace_mobile/core/config/config_repository.dart';
import 'package:books_marketplace_mobile/core/config/public_config.dart';
import 'package:books_marketplace_mobile/core/network/api_client.dart';
import 'package:books_marketplace_mobile/features/sell/domain/sell_rules.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fakes.dart';

void main() {
  late List<RequestOptions> seen;
  late int status;
  late ConfigRepository repo;
  late SharedPreferences prefs;

  Future<void> setup({Map<String, Object> stored = const {}}) async {
    SharedPreferences.setMockInitialValues(stored);
    prefs = await SharedPreferences.getInstance();
    seen = [];
    status = 200;
    final adapter = FakeAdapter((o) {
      seen.add(o);
      if (status == 304) return ResponseBody.fromString('', 304);
      return jsonResponse(
        200,
        okBody({
          'fee.sale.rate': 0.07,
          'listing.photos.min': 5,
          'x.unknown': 'bỏ',
        }),
        headers: {
          'etag': ['"v2"'],
        },
      );
    });
    repo = ConfigRepository(
      ApiClient(
        Dio(BaseOptions(baseUrl: 'http://x'))..httpClientAdapter = adapter,
      ),
      prefs,
    );
  }

  test('lần đầu: tải, lưu body và ETag; khóa không phải số bị bỏ', () async {
    await setup();
    final c = (await repo.fetch())!;
    expect(c['fee.sale.rate'], 0.07);
    expect(c.intOf('listing.photos.min'), 5);
    expect(c['x.unknown'], isNull);
    expect(seen.single.headers.containsKey('If-None-Match'), isFalse);
    expect(prefs.getString('public_config_etag'), '"v2"');
    expect(repo.cached()!['listing.photos.min'], 5);
  });

  test('lần sau gửi If-None-Match; 304 thì giữ bản đã lưu', () async {
    await setup(
      stored: {
        'public_config_body': jsonEncode({'listing.photos.min': 4}),
        'public_config_etag': '"v1"',
      },
    );
    status = 304;
    expect(await repo.fetch(), isNull);
    expect(seen.single.headers['If-None-Match'], '"v1"');
    expect(repo.cached()!.intOf('listing.photos.min'), 4);
  });

  test('cache hỏng thì coi như chưa có và không gửi ETag', () async {
    await setup(
      stored: {'public_config_body': '{hỏng', 'public_config_etag': '"v1"'},
    );
    expect(repo.cached(), isNull);
    await repo.fetch();
    expect(seen.single.headers.containsKey('If-None-Match'), isFalse);
  });

  group('SellRules.fromConfig', () {
    test('mặc định khớp bộ khóa mẫu của backend', () {
      final r = SellRules.fromConfig(
        const PublicConfig({
          'fee.sale.rate': 0.05,
          'fee.auction.commissionRate': 0.1,
          'auction.buyNow.minMultiplier': 1.5,
        }),
      );
      expect(r.sellerFee(100000), 5000);
      expect(r.auctionCommission(250000), 25000);
      expect(r.minBuyNow(200000), 300000);
    });

    test('đổi phí/ảnh theo cấu hình, khóa thiếu dùng mặc định', () {
      final r = SellRules.fromConfig(
        const PublicConfig({'fee.sale.rate': 0.07, 'listing.photos.min': 6}),
      );
      expect(r.sellerFee(100000), 7000);
      expect(r.minPhotos, 6);
      expect(r.commissionBps, SellRules.defaults.commissionBps);
      expect(
        validateSell(const SellForm(photos: 5), rules: r),
        contains(SellError.photos),
      );
    });

    test('phí tham gia bị kẹp giữa min và max, cọc theo tỉ lệ', () {
      const r = SellRules();
      expect(r.participationFee(100000), 10000, reason: '2% = 2.000 < min');
      expect(r.participationFee(2000000), 40000);
      expect(r.participationFee(100000000), 100000, reason: 'kẹp max');
      expect(r.deposit(200000), 20000);
    });

    test('bước nhảy: tối thiểu là max(1%, minAmount)', () {
      const r = SellRules();
      expect(r.stepRange(100000), (lo: 5000, hi: 10000));
      expect(r.stepRange(1000000), (lo: 10000, hi: 100000));
    });
  });
}
