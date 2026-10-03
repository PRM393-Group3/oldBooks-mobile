import 'order.dart';

enum OrderStep {
  saleOrdered,
  saleShipped,
  delivered,
  saleCompleted,
  auctionWon,
  auctionInDelivery,
  auctionReceived,
  auctionCompleted,
}

class TimelineStep {
  const TimelineStep({
    required this.step,
    required this.done,
    required this.isCurrent,
    required this.isNext,
    this.time,
  });

  final OrderStep step;

  /// Mốc đã đạt (tô đặc).
  final bool done;

  /// Mốc hiện tại của đơn (chữ đậm).
  final bool isCurrent;

  /// Mốc kế tiếp (hiện "Tiếp theo").
  final bool isNext;
  final DateTime? time;
}

class OrderTimeline {
  const OrderTimeline({required this.steps, required this.cancelled});

  final List<TimelineStep> steps;

  /// Đơn đã hủy: mốc đầu hiện "Đã hủy" thay cho nhãn thường.
  final bool cancelled;
}

const _saleSteps = [
  OrderStep.saleOrdered,
  OrderStep.saleShipped,
  OrderStep.delivered,
  OrderStep.saleCompleted,
];
const _auctionSteps = [
  OrderStep.auctionWon,
  OrderStep.auctionInDelivery,
  OrderStep.auctionReceived,
  OrderStep.auctionCompleted,
];

/// Dòng thời gian bốn mốc của đơn. Các trạng thái ngoài chuỗi chính được ánh xạ
/// về mốc gần nhất (ví dụ khiếu nại ở mốc "Đã giao").
OrderTimeline orderTimeline(Order o) {
  final seq = o.isAuction ? _auctionSteps : _saleSteps;
  final main = o.isAuction
      ? const [
          OrderStatus.readyToShip,
          OrderStatus.inDelivery,
          OrderStatus.delivered,
          OrderStatus.completed,
        ]
      : const [
          OrderStatus.paidAwaitingShipment,
          OrderStatus.shipped,
          OrderStatus.delivered,
          OrderStatus.completed,
        ];
  final cancelled = o.status == OrderStatus.cancelledByBuyer;
  final idx = switch (o.status) {
    OrderStatus.pickedUp => 2,
    OrderStatus.inStorage => 1,
    OrderStatus.disputed => 2,
    OrderStatus.refunded || OrderStatus.partiallyRefunded => 3,
    OrderStatus.cancelledByBuyer => 0,
    _ => main.indexOf(o.status).clamp(0, 3),
  };
  final times = [o.placedAt, o.shippedAt, o.deliveredAt, o.completedAt];

  return OrderTimeline(
    cancelled: cancelled,
    steps: [
      for (var i = 0; i < seq.length; i++)
        TimelineStep(
          step: seq[i],
          done: i <= idx && !(cancelled && i > 0),
          isCurrent: i == idx,
          isNext: i == idx + 1 && !cancelled,
          time: times[i],
        ),
    ],
  );
}
