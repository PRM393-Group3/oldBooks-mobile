import '../../../core/util/json_read.dart';

/// Hai đường xử lý AI: Claude chạy ở backend (cần gói) hoặc model trên máy.
enum AiRoute { claude, local }

/// `GET /me/ai` và `POST /me/ai/subscription`.
class AiStatus {
  const AiStatus({
    this.claudeAvailable = false,
    this.subscribed = false,
    this.expiresAt,
    this.priceVnd = 0,
    this.durationDays = 0,
    this.dailyQuota = 0,
    this.usedToday = 0,
    this.provider,
  });

  factory AiStatus.fromJson(dynamic json) {
    final j = json as Map<dynamic, dynamic>;
    return AiStatus(
      claudeAvailable: readBool(j, 'claudeAvailable') ?? false,
      subscribed: readBool(j, 'subscribed') ?? false,
      expiresAt: readDate(j, 'expiresAt'),
      priceVnd: readInt(j, 'priceVnd') ?? 0,
      durationDays: readInt(j, 'durationDays') ?? 0,
      dailyQuota: readInt(j, 'dailyQuota') ?? 0,
      usedToday: readInt(j, 'usedToday') ?? 0,
      provider: readString(j, 'provider'),
    );
  }

  final bool claudeAvailable;
  final bool subscribed;
  final DateTime? expiresAt;
  final int priceVnd;
  final int durationDays;

  /// 0 là không giới hạn.
  final int dailyQuota;
  final int usedToday;
  final String? provider;

  /// Số ngày còn lại (làm tròn lên), 0 nếu hết hạn hoặc chưa đăng ký.
  int daysRemaining(DateTime now) {
    final end = expiresAt;
    if (!subscribed || end == null) return 0;
    final d = end.difference(now);
    if (d.isNegative) return 0;
    return (d.inSeconds / 86400).ceil();
  }
}

/// Quy tắc dùng chung: dùng Claude khi admin đã bật và người dùng có gói, còn
/// lại dùng model trên máy. Chưa tải được trạng thái ([status] null) thì dùng
/// model trên máy để không chặn người bán.
AiRoute chooseAiRoute(AiStatus? status) =>
    status != null && status.claudeAvailable && status.subscribed
    ? AiRoute.claude
    : AiRoute.local;

/// `POST /me/ai/extract`. Trường không đọc được là `null`.
class AiExtractResult {
  const AiExtractResult({
    this.title,
    this.author,
    this.publisher,
    this.publishYear,
    this.isbn,
    this.categoryHint,
    this.conditionHint,
    this.descriptionDraft,
    this.confidence,
  });

  factory AiExtractResult.fromJson(dynamic json) {
    final j = json as Map<dynamic, dynamic>;
    return AiExtractResult(
      title: readString(j, 'title'),
      author: readString(j, 'author'),
      publisher: readString(j, 'publisher'),
      publishYear: readInt(j, 'publishYear'),
      isbn: readString(j, 'isbn'),
      categoryHint: readString(j, 'categoryHint'),
      conditionHint: readString(j, 'conditionHint'),
      descriptionDraft: readString(j, 'descriptionDraft'),
      confidence: readDouble(j, 'confidence'),
    );
  }

  final String? title;
  final String? author;
  final String? publisher;
  final int? publishYear;
  final String? isbn;
  final String? categoryHint;

  /// `NEW` | `GOOD` | `FAIR` | `WORN` (cùng mã với tình trạng tin đăng).
  final String? conditionHint;
  final String? descriptionDraft;
  final double? confidence;
}

class AiConversation {
  const AiConversation({
    required this.id,
    this.title,
    this.lastMessage,
    this.createdAt,
    this.updatedAt,
  });

  /// Doc backend chưa nêu hình dạng phần tử danh sách: chỉ `id` là bắt buộc,
  /// các trường còn lại đọc phòng thủ.
  factory AiConversation.fromJson(dynamic json) {
    final j = json as Map<dynamic, dynamic>;
    return AiConversation(
      id: j['id'].toString(),
      title: readString(j, 'title'),
      lastMessage:
          readString(j, 'lastMessage') ?? readString(j, 'lastMessagePreview'),
      createdAt: readDate(j, 'createdAt'),
      updatedAt: readDate(j, 'updatedAt') ?? readDate(j, 'lastMessageAt'),
    );
  }

  final String id;
  final String? title;
  final String? lastMessage;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}

class AiToolCall {
  const AiToolCall({required this.name, required this.ok, this.summary});

  factory AiToolCall.fromJson(dynamic json) {
    final j = json as Map<dynamic, dynamic>;
    return AiToolCall(
      name: readString(j, 'name') ?? '',
      ok: readBool(j, 'ok') ?? true,
      summary: readString(j, 'summary'),
    );
  }

  final String name;
  final bool ok;
  final String? summary;
}

/// Một tin nhắn trong hội thoại. Vai trò `USER` hoặc `ASSISTANT`.
class AiMessage {
  const AiMessage({
    required this.id,
    required this.isUser,
    required this.text,
    this.toolCalls = const [],
    this.listingIds = const [],
    this.imageCount = 0,
    this.createdAt,
  });

  /// `GET /me/ai/conversations/{id}` chưa có hình dạng chính thức; chấp nhận
  /// `role`/`text` hoặc `content`.
  factory AiMessage.fromJson(dynamic json) {
    final j = json as Map<dynamic, dynamic>;
    final role = (readString(j, 'role') ?? '').toUpperCase();
    return AiMessage(
      id: (j['id'] ?? j['messageId'] ?? '').toString(),
      isUser: role == 'USER',
      text: readString(j, 'text') ?? readString(j, 'content') ?? '',
      toolCalls: [
        for (final t in readList(j, 'toolCalls'))
          if (t is Map) AiToolCall.fromJson(t),
      ],
      listingIds: [
        for (final id in readList(j, 'listingIds'))
          if (id is String) id,
      ],
      imageCount: readList(j, 'blobNames').length,
      createdAt: readDate(j, 'createdAt'),
    );
  }

  final String id;
  final bool isUser;
  final String text;
  final List<AiToolCall> toolCalls;
  final List<String> listingIds;
  final int imageCount;
  final DateTime? createdAt;
}

enum AiQuestionKind {
  singleChoice,
  multiChoice,
  text,
  number;

  static AiQuestionKind parse(String? v) => switch (v?.toUpperCase()) {
    'MULTI_CHOICE' => multiChoice,
    'TEXT' => text,
    'NUMBER' => number,
    _ => singleChoice,
  };
}

class AiQuestionOption {
  const AiQuestionOption({required this.value, required this.label});

  factory AiQuestionOption.fromJson(dynamic json) {
    final j = json as Map<dynamic, dynamic>;
    final value = readString(j, 'value') ?? '';
    return AiQuestionOption(
      value: value,
      label: readString(j, 'label') ?? value,
    );
  }

  final String value;
  final String label;
}

/// Một câu hỏi của agent (`ask_user`).
class AiQuestion {
  const AiQuestion({
    required this.id,
    required this.kind,
    required this.prompt,
    this.options = const [],
    this.allowOther = false,
    this.placeholder,
    this.unit,
  });

  factory AiQuestion.fromJson(dynamic json) {
    final j = json as Map<dynamic, dynamic>;
    return AiQuestion(
      id: j['id'].toString(),
      kind: AiQuestionKind.parse(readString(j, 'kind')),
      prompt: readString(j, 'prompt') ?? '',
      options: [
        for (final o in readList(j, 'options'))
          if (o is Map) AiQuestionOption.fromJson(o),
      ],
      allowOther: readBool(j, 'allowOther') ?? false,
      placeholder: readString(j, 'placeholder'),
      unit: readString(j, 'unit'),
    );
  }

  final String id;
  final AiQuestionKind kind;
  final String prompt;
  final List<AiQuestionOption> options;
  final bool allowOther;
  final String? placeholder;
  final String? unit;
}

/// Thẻ câu hỏi đang chờ người dùng trả lời.
class AiPendingQuestion {
  const AiPendingQuestion({required this.questions});

  /// null khi không có thẻ mở (hoặc không có câu hỏi hợp lệ).
  static AiPendingQuestion? tryParse(dynamic json) {
    if (json is! Map) return null;
    final qs = [
      for (final q in readList(json, 'questions'))
        if (q is Map && q['id'] != null) AiQuestion.fromJson(q),
    ];
    return qs.isEmpty ? null : AiPendingQuestion(questions: qs);
  }

  final List<AiQuestion> questions;
}

/// Một đáp án gửi kèm tin nhắn: [value] cho một giá trị, [values] cho nhiều.
class AiAnswer {
  const AiAnswer({required this.questionId, this.value, this.values});

  final String questionId;
  final String? value;
  final List<String>? values;

  Map<String, dynamic> toJson() => {
    'questionId': questionId,
    'value': ?value,
    'values': ?values,
  };
}

/// `GET /me/ai/conversations/{id}`.
class AiConversationDetail {
  const AiConversationDetail({required this.messages, this.pendingQuestion});

  factory AiConversationDetail.fromJson(dynamic data) => AiConversationDetail(
    messages: parseAiMessages(data),
    pendingQuestion: data is Map
        ? AiPendingQuestion.tryParse(data['pendingQuestion'])
        : null,
  );

  final List<AiMessage> messages;
  final AiPendingQuestion? pendingQuestion;
}

List<AiMessage> parseAiMessages(dynamic data) {
  final raw = data is List
      ? data
      : (data is Map ? (data['messages'] as List? ?? const []) : const []);
  return [
    for (final m in raw)
      if (m is Map) AiMessage.fromJson(m),
  ];
}

/// `POST /me/ai/conversations/{id}/messages`.
class AiAgentReply {
  const AiAgentReply({
    required this.reply,
    this.toolCalls = const [],
    this.listingIds = const [],
    this.submitted = false,
    this.messageId,
    this.pendingQuestion,
  });

  factory AiAgentReply.fromJson(dynamic json) {
    final j = json as Map<dynamic, dynamic>;
    return AiAgentReply(
      reply: readString(j, 'reply') ?? '',
      toolCalls: [
        for (final t in readList(j, 'toolCalls'))
          if (t is Map) AiToolCall.fromJson(t),
      ],
      listingIds: [
        for (final id in readList(j, 'listingIds'))
          if (id is String) id,
      ],
      submitted: readBool(j, 'submitted') ?? false,
      messageId: readString(j, 'messageId'),
      pendingQuestion: AiPendingQuestion.tryParse(j['pendingQuestion']),
    );
  }

  final String reply;
  final List<AiToolCall> toolCalls;
  final List<String> listingIds;
  final bool submitted;
  final String? messageId;
  final AiPendingQuestion? pendingQuestion;
}
