import 'dart:convert';
import 'dart:typed_data';

import 'package:books_marketplace_mobile/core/network/api_client.dart';
import 'package:books_marketplace_mobile/core/network/api_error.dart';
import 'package:books_marketplace_mobile/core/network/blob_uploader.dart';
import 'package:books_marketplace_mobile/core/l10n/api_error_l10n.dart';
import 'package:books_marketplace_mobile/core/l10n/app_localizations_vi.dart';
import 'package:books_marketplace_mobile/features/auctions/domain/auction.dart';
import 'package:books_marketplace_mobile/features/kyc/data/kyc_repository.dart';
import 'package:books_marketplace_mobile/features/kyc/domain/kyc_models.dart';
import 'package:books_marketplace_mobile/features/listings/domain/listing.dart';
import 'package:books_marketplace_mobile/features/notifications/domain/app_notification.dart';
import 'package:books_marketplace_mobile/features/profile/domain/profile.dart';
import 'package:books_marketplace_mobile/core/navigation/notification_router.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fakes.dart';

const _submission = {
  'id': 's1',
  'status': 'PENDING_REVIEW',
  'submittedAt': '2026-10-27T03:00:00Z',
  'reviewedAt': null,
  'rejectReason': null,
  'fullName': 'NGUYEN VAN AN',
  'idNumberMasked': '********8901',
  'dateOfBirth': '1999-03-05',
};

void main() {
  late FakeAdapter adapter;
  late List<RequestOptions> seen;
  late KycRepository repo;

  void setup(ResponseBody Function(RequestOptions) handler) {
    seen = [];
    adapter = FakeAdapter((o) {
      seen.add(o);
      return handler(o);
    });
    final dio = Dio(BaseOptions(baseUrl: 'http://x'))
      ..httpClientAdapter = adapter;
    final api = ApiClient(dio);
    repo = KycRepository(api, BlobUploader(api, dio));
  }

  group('JSON mapping', () {
    test('GET /me/kyc đầy đủ', () async {
      setup(
        (_) => jsonResponse(
          200,
          okBody({
            'status': 'REJECTED',
            'isVerified': false,
            'verifiedAt': null,
            'canSubmit': false,
            'retryAfter': '2026-10-28T00:00:00Z',
            'latest': {
              ..._submission,
              'status': 'REJECTED',
              'reviewedAt': '2026-10-27T05:00:00Z',
              'rejectReason': 'Ảnh mờ',
            },
          }),
        ),
      );
      final s = await repo.getState();
      expect(seen.single.path, '/me/kyc');
      expect(s.status, KycStatus.rejected);
      expect(s.isVerified, isFalse);
      expect(s.canSubmit, isFalse);
      expect(s.retryAfter, DateTime.utc(2026, 10, 28));
      expect(s.latest!.rejectReason, 'Ảnh mờ');
      expect(s.latest!.idNumberMasked, '********8901');
      expect(s.latest!.dateOfBirth, '1999-03-05');
      expect(s.latest!.reviewedAt, DateTime.utc(2026, 10, 27, 5));
    });

    test('trạng thái NONE và mã lạ', () {
      final none = KycState.fromJson({
        'status': 'NONE',
        'isVerified': false,
        'canSubmit': true,
        'latest': null,
      });
      expect(none.status, KycStatus.none);
      expect(none.latest, isNull);
      expect(none.canSubmit, isTrue);
      expect(KycStatus.fromApi('SOMETHING_NEW'), KycStatus.none);
      for (final s in KycStatus.values) {
        expect(KycStatus.fromApi(s.api), s);
      }
    });

    test(
      'isVerified mặc định false khi thiếu trong /me, người bán và phiên',
      () {
        final profile = {
          'id': 'u1',
          'fullName': 'A',
          'role': 'USER',
          'createdAt': '2026-09-19T08:30:18Z',
        };
        expect(Profile.fromJson(profile).isVerified, isFalse);
        expect(
          Profile.fromJson({...profile, 'isVerified': true}).isVerified,
          isTrue,
        );
        expect(
          SellerInfo.fromJson({'id': 's', 'fullName': 'B'}).isVerified,
          isFalse,
        );
        expect(
          SellerInfo.fromJson({'id': 's', 'fullName': 'B', 'isVerified': true})
              .isVerified,
          isTrue,
        );
        final auction = {
          'id': 'a1',
          'title': 'T',
          'author': 'A',
          'status': 'LIVE',
          'startPrice': 1000,
          'bidStep': 100,
        };
        expect(Auction.fromJson(auction).sellerVerified, isFalse);
        expect(
          Auction.fromJson({
            ...auction,
            'seller': {'id': 's', 'fullName': 'B', 'isVerified': true},
          }).sellerVerified,
          isTrue,
        );
      },
    );

    test('body gửi đúng hợp đồng', () {
      const req = KycSubmitRequest(
        fullName: ' NGUYEN VAN AN ',
        idNumber: '012345678901',
        dateOfBirth: '1999-03-05',
        frontBlobName: 'f',
        backBlobName: 'b',
        selfieBlobName: 's',
        livenessBlobNames: ['l0', 'l1'],
        clientInfo: KycClientInfo(
          faceMatchScore: 0.62,
          ocrSource: OcrSource.ai,
          modelVersion: 'gemma-4-e2b-it+mobilefacenet-sirius-v1',
          livenessChallenges: [
            LivenessChallenge.blink,
            LivenessChallenge.turnLeft,
          ],
        ),
      );
      expect(req.toJson(), {
        'fullName': 'NGUYEN VAN AN',
        'idNumber': '012345678901',
        'dateOfBirth': '1999-03-05',
        'frontBlobName': 'f',
        'backBlobName': 'b',
        'selfieBlobName': 's',
        'livenessBlobNames': ['l0', 'l1'],
        'consentAccepted': true,
        'clientInfo': {
          'faceMatchScore': 0.62,
          'ocrSource': 'AI',
          'modelVersion': 'gemma-4-e2b-it+mobilefacenet-sirius-v1',
          'livenessChallenges': ['BLINK', 'TURN_LEFT'],
        },
      });
      const manual = KycClientInfo(
        ocrSource: OcrSource.manual,
        livenessChallenges: [],
      );
      expect(manual.toJson()['faceMatchScore'], isNull);
      expect(manual.toJson().containsKey('faceMatchScore'), isTrue);
    });
  });

  group('upload và gửi hồ sơ', () {
    test('tải ảnh lên kho riêng tư rồi POST kèm Idempotency-Key', () async {
      var n = 0;
      setup((o) {
        if (o.path == '/storage/upload-url') {
          final i = n++;
          return jsonResponse(
            200,
            okBody({
              'blobName': 'u1/blob$i.jpg',
              'uploadUrl': 'http://blob/upload$i',
              'requiredHeaders': {'x-ms-blob-type': 'BlockBlob'},
            }),
          );
        }
        if (o.uri.toString().startsWith('http://blob/')) {
          return jsonResponse(201, {});
        }
        return jsonResponse(201, okBody(_submission));
      });

      final images = [
        KycImage(Uint8List.fromList([1, 2]), fileName: 'a.jpg'),
        KycImage(Uint8List.fromList([3]), fileName: 'b.jpg'),
      ];
      final progress = <int>[];
      final names = await repo.uploadImages(
        images,
        onProgress: (done, _) => progress.add(done),
      );
      expect(names, ['u1/blob0.jpg', 'u1/blob1.jpg']);
      expect(progress, [0, 1, 2]);

      final tickets = seen.where((o) => o.path == '/storage/upload-url');
      for (final t in tickets) {
        expect(jsonDecode(jsonEncode(t.data)), {
          'fileName': anyOf('a.jpg', 'b.jpg'),
          'contentType': 'image/jpeg',
          'visibility': 'PRIVATE',
        });
      }

      // Thử lại không tải lại ảnh đã có blobName.
      final before = seen.length;
      await repo.uploadImages(images);
      expect(seen.length, before);

      final result = await repo.submit(
        const KycSubmitRequest(
          fullName: 'A B',
          idNumber: '012345678901',
          dateOfBirth: '1999-03-05',
          frontBlobName: 'f',
          backBlobName: 'b',
          selfieBlobName: 's',
          livenessBlobNames: [],
          clientInfo: KycClientInfo(
            ocrSource: OcrSource.manual,
            livenessChallenges: [],
          ),
        ),
        idempotencyKey: 'key-1',
      );
      final post = seen.last;
      expect(post.method, 'POST');
      expect(post.path, '/me/kyc/submissions');
      expect(post.headers['Idempotency-Key'], 'key-1');
      expect(result.id, 's1');
      expect(result.status, KycStatus.pendingReview);
    });

    test('lỗi KYC được ánh xạ sang câu tiếng Việt, không lộ message', () async {
      final l = AppLocalizationsVi();
      const cases = {
        'KYC_ALREADY_VERIFIED': 409,
        'KYC_PENDING_EXISTS': 409,
        'KYC_ID_DUPLICATE': 409,
        'KYC_UNDERAGE': 422,
        'KYC_LIMIT_REACHED': 422,
        'KYC_CONSENT_REQUIRED': 400,
        'KYC_IMAGE_INVALID': 400,
      };
      final seenTexts = <String>{};
      for (final e in cases.entries) {
        setup((_) => jsonResponse(e.value, errorBody(e.key)));
        try {
          await repo.getState();
          fail('phải ném');
        } on ApiError catch (err) {
          expect(err.code, e.key);
          final text = err.localized(l);
          expect(text, isNot('english message'));
          expect(text, isNot(l.errorUnknown));
          seenTexts.add(text);
        }
      }
      expect(seenTexts.length, cases.length, reason: 'mỗi mã một câu riêng');
    });
  });

  group('thông báo KYC', () {
    AppNotification n(String type) => AppNotification.fromJson({
      'id': 'n1',
      'type': type,
      'title': 't',
      'body': 'b',
      'isRead': false,
    });

    test('KYC_APPROVED / KYC_REJECTED mở màn trạng thái', () {
      expect(n('KYC_APPROVED').type, NotificationType.kycApproved);
      expect(n('KYC_REJECTED').type, NotificationType.kycRejected);
      expect(
        notificationTarget(n('KYC_APPROVED')),
        const NotificationTarget(['/me/kyc']),
      );
      expect(
        notificationTarget(n('KYC_REJECTED')),
        const NotificationTarget(['/me/kyc']),
      );
    });
  });
}
