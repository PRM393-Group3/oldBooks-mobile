import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:signalr_netcore/signalr_client.dart';

import '../../../core/config/env.dart';
import '../domain/auction_event.dart';

/// Kênh realtime của phiên đấu giá. Một kết nối dùng chung cho cả app; mỗi màn
/// hình [acquire] phiên mình xem và gọi hàm trả về khi rời màn hình.
abstract class AuctionHub {
  /// Mọi sự kiện của các phiên đang theo dõi (lọc theo `auctionId` ở nơi nhận).
  Stream<AuctionLiveEvent> get events;

  /// Kết nối lại sau khi mất: nơi nhận nên tải lại phiên từ REST.
  Stream<void> get reconnected;

  /// Trạng thái kết nối, để hiện "mất kết nối realtime".
  ValueListenable<bool> get connected;

  /// Theo dõi [auctionId]. Trả về hàm hủy theo dõi (gọi nhiều lần vô hại).
  void Function() acquire(String auctionId);

  void dispose();
}

/// Hub thật trên `signalr_netcore`: `{host}/hubs/auctions`, không token, tự
/// kết nối lại. Đếm số màn hình theo dõi mỗi phiên để chỉ `Subscribe` một lần
/// và `Unsubscribe` khi không còn ai xem; không còn phiên nào thì đóng kết nối.
class SignalRAuctionHub implements AuctionHub {
  SignalRAuctionHub({String? url})
    : _url = url ?? '${Env.apiBaseUrl}/hubs/auctions';

  final String _url;
  final _events = StreamController<AuctionLiveEvent>.broadcast();
  final _reconnected = StreamController<void>.broadcast();
  final _connected = ValueNotifier<bool>(false);
  final Map<String, int> _refs = {};

  HubConnection? _connection;
  Future<void>? _starting;
  Timer? _stopTimer;
  Timer? _retryTimer;
  bool _disposed = false;

  /// Lần khởi động đầu tiên đã thành công chưa (để biết lần sau là kết nối lại).
  bool _everConnected = false;

  @override
  Stream<AuctionLiveEvent> get events => _events.stream;

  @override
  Stream<void> get reconnected => _reconnected.stream;

  @override
  ValueListenable<bool> get connected => _connected;

  HubConnection _build() {
    final c = HubConnectionBuilder()
        .withUrl(_url)
        .withAutomaticReconnect(retryDelays: [0, 2000, 5000, 10000, 20000])
        .build();
    for (final name in AuctionEventName.all) {
      c.on(name, (args) {
        final payload = args == null || args.isEmpty ? null : args.first;
        if (payload is Map && !_events.isClosed) {
          _events.add(AuctionLiveEvent.fromJson(name, payload));
        }
      });
    }
    c.onreconnecting(({error}) => _connected.value = false);
    c.onreconnected(({connectionId}) async {
      _connected.value = true;
      await _subscribeAll();
      if (!_reconnected.isClosed) _reconnected.add(null);
    });
    c.onclose(({error}) {
      _connected.value = false;
      _scheduleRetry();
    });
    return c;
  }

  Future<void> _ensureStarted() {
    final c = _connection ??= _build();
    if (c.state == HubConnectionState.Connected) return Future.value();
    return _starting ??= () async {
      try {
        await c.start();
        _connected.value = true;
        await _subscribeAll();
        if (_everConnected && !_reconnected.isClosed) _reconnected.add(null);
        _everConnected = true;
      } catch (e) {
        debugPrint('AuctionHub: start failed: $e');
        _connected.value = false;
        _scheduleRetry();
      } finally {
        _starting = null;
      }
    }();
  }

  /// Khởi động thất bại hoặc kết nối đóng hẳn: thử lại sau ít giây nếu vẫn còn
  /// màn hình đang theo dõi.
  void _scheduleRetry() {
    if (_disposed || _refs.isEmpty || _retryTimer != null) return;
    _retryTimer = Timer(const Duration(seconds: 5), () {
      _retryTimer = null;
      if (_refs.isNotEmpty) _ensureStarted();
    });
  }

  Future<void> _subscribeAll() async {
    for (final id in _refs.keys.toList()) {
      await _invoke('Subscribe', id);
    }
  }

  Future<void> _invoke(String method, String id) async {
    final c = _connection;
    if (c == null || c.state != HubConnectionState.Connected) return;
    try {
      await c.invoke(method, args: [id]);
    } catch (e) {
      debugPrint('AuctionHub: $method($id) failed: $e');
    }
  }

  @override
  void Function() acquire(String auctionId) {
    _stopTimer?.cancel();
    _stopTimer = null;
    final count = (_refs[auctionId] ?? 0) + 1;
    _refs[auctionId] = count;
    if (count == 1) {
      final c = _connection;
      if (c != null && c.state == HubConnectionState.Connected) {
        _invoke('Subscribe', auctionId);
      } else {
        _ensureStarted();
      }
    }
    var released = false;
    return () {
      if (released) return;
      released = true;
      _release(auctionId);
    };
  }

  void _release(String auctionId) {
    final count = (_refs[auctionId] ?? 1) - 1;
    if (count > 0) {
      _refs[auctionId] = count;
      return;
    }
    _refs.remove(auctionId);
    _invoke('Unsubscribe', auctionId);
    if (_refs.isEmpty) {
      // Đợi chút trước khi đóng để chuyển qua lại giữa các phiên không phải
      // bắt tay lại từ đầu.
      _stopTimer = Timer(const Duration(seconds: 5), () {
        _stopTimer = null;
        if (_refs.isEmpty) _connection?.stop();
      });
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _stopTimer?.cancel();
    _retryTimer?.cancel();
    _connection?.stop();
    _events.close();
    _reconnected.close();
    _connected.dispose();
  }
}

/// Hub không kết nối, cho chế độ xem trước và test không cần realtime.
class OfflineAuctionHub implements AuctionHub {
  final _events = StreamController<AuctionLiveEvent>.broadcast();
  final _reconnected = StreamController<void>.broadcast();
  final _connected = ValueNotifier<bool>(true);

  /// Số lần theo dõi đang mở theo phiên (test kiểm tra việc hủy theo dõi).
  final Map<String, int> refs = {};

  @override
  Stream<AuctionLiveEvent> get events => _events.stream;

  @override
  Stream<void> get reconnected => _reconnected.stream;

  @override
  ValueListenable<bool> get connected => _connected;

  /// Giả lập server phát một sự kiện.
  void emit(AuctionLiveEvent e) => _events.add(e);

  /// Giả lập kết nối lại.
  void simulateReconnect() => _reconnected.add(null);

  @override
  void Function() acquire(String auctionId) {
    refs[auctionId] = (refs[auctionId] ?? 0) + 1;
    var released = false;
    return () {
      if (released) return;
      released = true;
      final n = (refs[auctionId] ?? 1) - 1;
      if (n <= 0) {
        refs.remove(auctionId);
      } else {
        refs[auctionId] = n;
      }
    };
  }

  @override
  void dispose() {
    _events.close();
    _reconnected.close();
    _connected.dispose();
  }
}
