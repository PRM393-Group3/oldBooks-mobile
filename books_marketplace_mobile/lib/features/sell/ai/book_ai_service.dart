import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_edge_ai/flutter_edge_ai.dart';
import 'package:flutter_edge_ai_litertlm/flutter_edge_ai_litertlm.dart';

import 'book_analysis.dart';

/// Gemma 4 E2B (~2,6GB, Apache-2.0, không cần token) chạy trên máy, nhận ảnh.
const _modelRepo = 'litert-community/gemma-4-E2B-it-litert-lm';
const _modelFile = 'gemma-4-E2B-it.litertlm';
const _modelUrl = 'https://huggingface.co/$_modelRepo/resolve/main/$_modelFile';

/// Model nhỏ có thể lặp từ; giới hạn thời gian để UI không chờ vô hạn.
const _analyzeTimeout = Duration(seconds: 180);

enum BookAiFailure { unsupported, download, model, empty, unreadable }

class BookAiException implements Exception {
  const BookAiException(this.failure);

  final BookAiFailure failure;
}

/// Tải và chạy model AI trên máy để gợi ý tình trạng sách từ ảnh.
/// Chỉ Android (LiteRT-LM cần Android 11+ và arm64, đã đặt trong gradle).
class BookAiService {
  bool _initialized = false;

  bool get isSupported => Platform.isAndroid;

  Future<void> _init() async {
    if (_initialized) return;
    await FlutterEdgeAi.initialize(inferenceEngines: const [LiteRtLmEngine()]);
    _initialized = true;
  }

  /// Model đã nằm trên máy (không cần tải lại).
  Future<bool> isModelReady() async {
    if (!isSupported) return false;
    await _init();
    return await FlutterEdgeAi.isModelInstalled(_modelFile) &&
        FlutterEdgeAi.hasActiveModel();
  }

  /// Tải model về máy và đặt làm model đang dùng. [onProgress] nhận 0–100.
  Future<void> downloadModel(void Function(int percent) onProgress) async {
    if (!isSupported) throw const BookAiException(BookAiFailure.unsupported);
    await _init();
    try {
      await FlutterEdgeAi.installModel(
        modelType: ModelType.general,
        fileType: ModelFileType.litertlm,
      ).fromNetwork(_modelUrl).withProgress(onProgress).install();
    } catch (_) {
      throw const BookAiException(BookAiFailure.download);
    }
  }

  /// Phân tích một ảnh, phát ra toàn bộ câu trả lời đã sinh được sau mỗi token
  /// để giao diện hiện dần. Giải phóng model khi xong hoặc khi bị hủy nghe để
  /// trả RAM. Lỗi phát ra dưới dạng [BookAiException].
  ///
  /// [prompt] mặc định là lời nhắc đánh giá sách; eKYC dùng lời nhắc đọc CCCD
  /// với [sensitive] bật để không ghi nội dung model trả (có họ tên, số CCCD)
  /// vào log.
  Stream<String> analyzeStream(
    Uint8List image, {
    String prompt = bookAnalysisPrompt,
    bool sensitive = false,
  }) async* {
    if (!await isModelReady()) {
      await downloadModel((_) {});
    }

    InferenceModel? model;
    InferenceChat? chat;
    try {
      model = await FlutterEdgeAi.getActiveModel(
        maxTokens: 2048,
        supportImage: true,
        maxNumImages: 1,
      );
      chat = await model.createChat(supportImage: true);
      await chat.addQueryChunk(
        Message.withImages(
          text: prompt,
          imageBytes: [image],
          isUser: true,
        ),
      );
      final buffer = StringBuffer();
      await for (final r in chat.generateChatResponseAsync().timeout(
        _analyzeTimeout,
      )) {
        if (r is! TextResponse) continue;
        buffer.write(r.token);
        yield buffer.toString();
      }
      if (!sensitive) debugPrint('[BookAI] raw="$buffer"');
    } catch (e, st) {
      debugPrint('[BookAI] model error: ${sensitive ? e.runtimeType : e}\n$st');
      throw const BookAiException(BookAiFailure.model);
    } finally {
      await chat?.close();
      await model?.close();
    }
  }

  /// Đọc câu trả lời đầy đủ của [analyzeStream]. Rỗng nghĩa là model không sinh
  /// gì (thường do ảnh không tới được model); khác với có chữ nhưng không đọc
  /// ra tình trạng.
  BookAnalysis parseResult(String raw) {
    if (raw.trim().isEmpty) throw const BookAiException(BookAiFailure.empty);
    final result = parseBookAnalysis(raw);
    if (result == null) throw const BookAiException(BookAiFailure.unreadable);
    return result;
  }
}
