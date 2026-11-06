import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/api_error_l10n.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/network/api_error.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/util/idempotency.dart';
import '../../../core/util/image_picking.dart';
import '../../../core/util/photo_picker.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_state_views.dart';
import '../../../core/widgets/photo_source_sheet.dart';
import '../application/ai_providers.dart';
import '../data/ai_repository.dart';
import '../domain/ai_models.dart';
import 'ai_chat_list_screen.dart';
import 'ai_markdown.dart';
import 'ai_question_card.dart';

/// Khung chat với Trợ lý đăng bài. [conversationId] null: cuộc trò chuyện mới,
/// chỉ tạo trên server khi gửi tin đầu tiên.
class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key, this.conversationId});

  final String? conversationId;

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _send = IdempotentAction();
  final List<AiMessage> _messages = [];
  final List<PickedImage> _pending = [];
  String? _id;
  bool _loading = false;
  Object? _loadError;
  bool _sending = false;

  /// Thẻ câu hỏi đang mở (từ lượt trả lời cuối hoặc khi mở lại hội thoại).
  AiPendingQuestion? _question;

  /// Người dùng chọn "Để mình tự gõ": ẩn thẻ cho tới khi có thẻ mới.
  bool _questionDismissed = false;

  @override
  void initState() {
    super.initState();
    _id = widget.conversationId;
    if (_id != null) _load();
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final detail = await ref.read(aiRepositoryProvider).conversation(_id!);
      if (!mounted) return;
      setState(() {
        _messages
          ..clear()
          ..addAll(detail.messages);
        _question = detail.pendingQuestion;
        _questionDismissed = false;
      });
      _toBottom();
    } catch (e) {
      if (mounted) setState(() => _loadError = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _toBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _attach() async {
    final l = context.l10n;
    final room = aiMaxImages - _pending.length;
    if (room <= 0) {
      AppSnackbar.show(context, l.aiChatPhotoLimit(aiMaxImages));
      return;
    }
    final source = await showPhotoSourceSheet(context, multiple: room > 1);
    if (source == null || !mounted) return;
    try {
      final batch = await ref.read(photoPickerProvider)(source, room);
      if (!mounted) return;
      setState(() => _pending.addAll(batch.images.take(room)));
    } on ImagePickException {
      if (mounted) {
        AppSnackbar.show(context, l.errorNetwork, type: AppSnackbarType.error);
      }
    }
  }

  Future<void> _submit() => _deliver(text: _input.text.trim());

  void _answerQuestion(List<AiAnswer> answers, String summary) =>
      _deliver(text: '', answers: answers, shownText: summary);

  /// Gửi một lượt. [shownText] là chữ hiện ở bong bóng người dùng khi trả lời
  /// bằng thẻ (mặc định là [text]).
  Future<void> _deliver({
    required String text,
    List<AiAnswer> answers = const [],
    String? shownText,
  }) async {
    final withImages = answers.isEmpty;
    if (_sending || (text.isEmpty && answers.isEmpty && (_pending.isEmpty))) {
      return;
    }
    final images = withImages
        ? List<PickedImage>.of(_pending)
        : <PickedImage>[];
    setState(() => _sending = true);
    try {
      final repo = ref.read(aiRepositoryProvider);
      _id ??= await repo.createConversation();
      final blobs = await repo.uploadImages([
        for (var i = 0; i < images.length; i++)
          AiImage(
            bytes: images[i].bytes,
            fileName: 'chat-${i + 1}.${images[i].extension}',
            contentType: images[i].contentType,
          ),
      ]);
      final reply = await repo.sendMessage(
        _id!,
        text: text,
        blobNames: blobs,
        answers: answers,
        idempotencyKey: _send.key,
      );
      _send.settle();
      if (!mounted) return;
      setState(() {
        _messages
          ..add(
            AiMessage(
              id: 'u${_messages.length}',
              isUser: true,
              text: shownText ?? text,
              imageCount: images.length,
            ),
          )
          ..add(
            AiMessage(
              id: reply.messageId ?? 'a${_messages.length}',
              isUser: false,
              text: reply.reply,
              toolCalls: reply.toolCalls,
              listingIds: reply.listingIds,
            ),
          );
        _question = reply.pendingQuestion;
        _questionDismissed = false;
        if (answers.isEmpty) _input.clear();
        if (withImages) _pending.clear();
      });
      _toBottom();
    } catch (e) {
      _send.settle(e);
      if (mounted) {
        final l = context.l10n;
        AppSnackbar.show(
          context,
          e is ApiError ? e.localized(l) : l.aiChatSendFailed,
          type: AppSnackbarType.error,
        );
        if (e is ApiError) {
          if (e.code == ApiErrorCode.aiSubscriptionRequired ||
              e.code == ApiErrorCode.aiUnavailable) {
            ref.read(aiStatusProvider.notifier).refresh();
          } else if (e.code == ApiErrorCode.aiNoPendingQuestion) {
            // Thẻ không còn hiệu lực: tải lại hội thoại và bỏ thẻ.
            setState(() => _question = null);
            if (_id != null) _refreshAfterStale();
          }
        }
        // Lỗi dữ liệu (400): giữ nguyên thẻ để người dùng sửa đáp án.
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _refreshAfterStale() async {
    try {
      final detail = await ref.read(aiRepositoryProvider).conversation(_id!);
      if (!mounted) return;
      setState(() {
        _messages
          ..clear()
          ..addAll(detail.messages);
        _question = detail.pendingQuestion;
        _questionDismissed = false;
      });
      _toBottom();
    } catch (_) {
      // Giữ nguyên danh sách hiện có.
    }
  }

  Widget _buildList(AppLocalizations l) {
    final showCard = _question != null && !_questionDismissed;
    final lastIsAssistant = _messages.isEmpty || !_messages.last.isUser;
    final card = showCard && lastIsAssistant;
    final head = _messages.isEmpty ? 1 : 0;
    final count = head + _messages.length + (card ? 1 : 0) + (_sending ? 1 : 0);
    return ListView.builder(
      controller: _scroll,
      padding: AppSpacing.screenPadding,
      itemCount: count,
      itemBuilder: (context, i) {
        if (i < head) {
          return _Bubble(isUser: false, child: Text(l.aiChatIntro));
        }
        i -= head;
        if (i < _messages.length) {
          return _MessageView(
            key: ValueKey(_messages[i].id),
            message: _messages[i],
          );
        }
        i -= _messages.length;
        if (card && i == 0) {
          return Align(
            alignment: Alignment.centerLeft,
            child: AiQuestionCard(
              key: ObjectKey(_question),
              pending: _question!,
              enabled: !_sending,
              onSubmit: _answerQuestion,
              onDismiss: () => setState(() => _questionDismissed = true),
            ),
          );
        }
        return _Bubble(
          isUser: false,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(l.aiChatThinking),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final route = ref.watch(aiRouteProvider);
    final status = ref.watch(aiStatusProvider);
    final gated =
        route != AiRoute.claude && !(status.isLoading && !status.hasValue);

    return Scaffold(
      appBar: AppBar(title: Text(l.aiChatTitle)),
      body: SafeArea(
        child: gated
            ? AiUpsell(unavailable: status.value?.claudeAvailable == false)
            : _loading
            ? const AppLoadingView()
            : _loadError != null
            ? AppErrorView(error: _loadError!, onRetry: _load)
            : Column(
                children: [
                  Expanded(child: _buildList(l)),
                  _Composer(
                    controller: _input,
                    pending: _pending,
                    sending: _sending,
                    onAttach: _attach,
                    onRemove: (i) => setState(() => _pending.removeAt(i)),
                    onSend: _submit,
                  ),
                ],
              ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.pending,
    required this.sending,
    required this.onAttach,
    required this.onRemove,
    required this.onSend,
  });

  final TextEditingController controller;
  final List<PickedImage> pending;
  final bool sending;
  final VoidCallback onAttach;
  final void Function(int) onRemove;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        boxShadow: context.colors.barShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (pending.isNotEmpty)
              SizedBox(
                height: 64,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: pending.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 6),
                  itemBuilder: (_, i) => Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          Uint8List.fromList(pending[i].bytes),
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: InkWell(
                          onTap: sending ? null : () => onRemove(i),
                          child: const Icon(Icons.cancel, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  tooltip: l.aiChatAttach,
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  onPressed: sending ? null : onAttach,
                ),
                Expanded(
                  child: TextField(
                    controller: controller,
                    minLines: 1,
                    maxLines: 5,
                    enabled: !sending,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(hintText: l.aiChatInputHint),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: context.colors.primary,
                  onPressed: sending ? null : onSend,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.isUser, required this.child});

  final bool isUser;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.xs),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.82,
        ),
        decoration: BoxDecoration(
          color: isUser ? colors.primaryContainer : colors.surface,
          borderRadius: AppRadius.mdAll,
          border: isUser ? null : Border.all(color: colors.border),
        ),
        child: child,
      ),
    );
  }
}

class _MessageView extends StatelessWidget {
  const _MessageView({super.key, required this.message});

  final AiMessage message;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Column(
      crossAxisAlignment: message.isUser
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        _Bubble(
          isUser: message.isUser,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (message.imageCount > 0)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.image_outlined, size: 16),
                    const SizedBox(width: 4),
                    Text(l.aiChatAttachedCount(message.imageCount)),
                  ],
                ),
              if (message.text.isNotEmpty)
                message.isUser
                    ? SelectableText(message.text)
                    : AiMarkdown(message.text),
            ],
          ),
        ),
        if (message.toolCalls.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final t in message.toolCalls)
                  Chip(
                    avatar: Icon(
                      t.ok ? Icons.check_circle_outline : Icons.error_outline,
                      size: 16,
                      color: t.ok
                          ? context.colors.success
                          : context.colors.error,
                    ),
                    label: Text(t.summary ?? t.name),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ),
        for (final id in message.listingIds)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: AppCard(
              onTap: () => context.push('/home/book/$id'),
              child: Row(
                children: [
                  Icon(Icons.task_alt, color: context.colors.success),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      l.aiChatSubmittedTitle,
                      style: context.text.titleSmall,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/me/listings'),
                    child: Text(l.aiChatMyListings),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
