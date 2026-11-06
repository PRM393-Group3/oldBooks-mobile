import 'package:books_marketplace_mobile/core/network/api_client.dart';
import 'package:books_marketplace_mobile/core/network/api_error.dart';
import 'package:books_marketplace_mobile/core/network/blob_uploader.dart';
import 'package:books_marketplace_mobile/features/ai_assistant/data/ai_repository.dart';
import 'package:books_marketplace_mobile/features/ai_assistant/domain/ai_models.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fakes.dart';

const _status = {
  'claudeAvailable': true,
  'subscribed': true,
  'expiresAt': '2026-12-06T10:00:00Z',
  'priceVnd': 49000,
  'durationDays': 30,
  'dailyQuota': 0,
  'usedToday': 12,
  'provider': 'CLAUDE',
};

void main() {
  group('chooseAiRoute', () {
    AiStatus s({required bool available, required bool subscribed}) =>
        AiStatus(claudeAvailable: available, subscribed: subscribed);

    test('Claude chỉ khi admin bật và đã đăng ký', () {
      expect(
        chooseAiRoute(s(available: true, subscribed: true)),
        AiRoute.claude,
      );
      expect(
        chooseAiRoute(s(available: true, subscribed: false)),
        AiRoute.local,
      );
      expect(
        chooseAiRoute(s(available: false, subscribed: true)),
        AiRoute.local,
      );
      expect(
        chooseAiRoute(s(available: false, subscribed: false)),
        AiRoute.local,
      );
    });

    test('chưa có trạng thái thì dùng model trên máy', () {
      expect(chooseAiRoute(null), AiRoute.local);
    });
  });

  group('model parsing', () {
    test('AiStatus', () {
      final st = AiStatus.fromJson(_status);
      expect(st.claudeAvailable, isTrue);
      expect(st.priceVnd, 49000);
      expect(st.durationDays, 30);
      expect(st.usedToday, 12);
      expect(st.expiresAt, DateTime.utc(2026, 12, 6, 10));
      expect(st.daysRemaining(DateTime.utc(2026, 12, 1, 10)), 5);
      expect(st.daysRemaining(DateTime.utc(2027, 1, 1)), 0);
    });

    test('AiExtractResult: null giữ nguyên', () {
      final r = AiExtractResult.fromJson({
        'title': 'Dế Mèn',
        'publishYear': 2019,
        'author': null,
        'conditionHint': 'GOOD',
        'confidence': 0.82,
      });
      expect(r.title, 'Dế Mèn');
      expect(r.author, isNull);
      expect(r.publishYear, 2019);
      expect(r.conditionHint, 'GOOD');
      expect(r.confidence, 0.82);
    });

    test('AiAgentReply', () {
      final r = AiAgentReply.fromJson({
        'reply': 'Xong',
        'toolCalls': [
          {'name': 'create_listing', 'ok': true, 'summary': 'Tạo tin'},
        ],
        'listingIds': ['a', 'b'],
        'submitted': true,
        'messageId': 'm1',
      });
      expect(r.toolCalls.single.name, 'create_listing');
      expect(r.listingIds, ['a', 'b']);
      expect(r.submitted, isTrue);
    });

    test('tin nhắn: role chữ thường, bọc trong messages', () {
      final m = parseAiMessages({
        'id': 'c1',
        'messages': [
          {'id': '1', 'role': 'user', 'text': 'hi'},
          {'id': '2', 'role': 'assistant', 'text': 'chào'},
        ],
      });
      expect(m.map((e) => e.isUser), [true, false]);
      expect(m.last.text, 'chào');
    });
  });

  group('AiRepository', () {
    late List<RequestOptions> seen;
    late AiRepository repo;

    void setup(ResponseBody Function(RequestOptions) h) {
      seen = [];
      final dio = Dio(BaseOptions(baseUrl: 'http://x'))
        ..httpClientAdapter = FakeAdapter((o) {
          seen.add(o);
          return h(o);
        });
      final api = ApiClient(dio);
      repo = AiRepository(api, BlobUploader(api, dio));
    }

    test('subscribe gửi Idempotency-Key', () async {
      setup((_) => jsonResponse(200, okBody(_status)));
      final st = await repo.subscribe(idempotencyKey: 'k1');
      expect(seen.single.path, '/me/ai/subscription');
      expect(seen.single.headers['Idempotency-Key'], 'k1');
      expect(st.subscribed, isTrue);
    });

    test('INSUFFICIENT_BALANCE mang required/available', () async {
      setup(
        (_) => jsonResponse(
          422,
          errorBody(
            'INSUFFICIENT_BALANCE',
            details: [
              {'field': 'required', 'message': '49000'},
              {'field': 'available', 'message': '1000'},
            ],
          ),
        ),
      );
      try {
        await repo.subscribe(idempotencyKey: 'k');
        fail('phải ném');
      } on ApiError catch (e) {
        expect(e.code, ApiErrorCode.insufficientBalance);
        expect(e.detailAmount('required'), 49000);
        expect(e.detailAmount('available'), 1000);
      }
    });

    test('sendMessage gửi Idempotency-Key và blobNames', () async {
      setup(
        (_) => jsonResponse(200, okBody({'reply': 'ok', 'listingIds': []})),
      );
      final r = await repo.sendMessage(
        'c1',
        text: 'đăng giúp',
        blobNames: ['u/1.jpg'],
        idempotencyKey: 'k2',
      );
      expect(seen.single.path, '/me/ai/conversations/c1/messages');
      expect(seen.single.headers['Idempotency-Key'], 'k2');
      expect((seen.single.data as Map)['blobNames'], ['u/1.jpg']);
      expect(r.reply, 'ok');
    });

    test('AI_UPSTREAM_ERROR là ApiError 502', () async {
      setup((_) => jsonResponse(502, errorBody('AI_UPSTREAM_ERROR')));
      expect(
        repo.extract(['a']),
        throwsA(
          isA<ApiError>().having((e) => e.code, 'code', 'AI_UPSTREAM_ERROR'),
        ),
      );
    });
  });
}
