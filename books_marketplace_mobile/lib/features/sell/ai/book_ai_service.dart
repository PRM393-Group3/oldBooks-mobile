import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_edge_ai/flutter_edge_ai.dart';
import 'package:flutter_edge_ai_litertlm/flutter_edge_ai_litertlm.dart';

import 'book_analysis.dart';

/// Model nhìn-ngôn ngữ nhỏ (~360MB, Apache-2.0, không cần token) chạy trên máy.
const _modelRepo = 'litert-community/SmolVLM2-500M';
const _modelFile = 'SmolVLM2-500M.litertlm';
const _modelUrl = 'https://huggingface.co/$_modelRepo/resolve/main/$_modelFile';

/// Model nhỏ có thể lặp từ; giới hạn thời gian để UI không chờ vô hạn.
const _analyzeTimeout = Duration(seconds: 120);

enum BookAiFailure { unsupported, download, model, unreadable }

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

  /// Phân tích một ảnh. Giải phóng model ngay sau đó để trả RAM (máy 4GB).
  Future<BookAnalysis> analyze(Uint8List image) async {
    if (!await isModelReady()) {
      await downloadModel((_) {});
    }

    InferenceModel? model;
    InferenceChat? chat;
    final String raw;
    try {
      model = await FlutterEdgeAi.getActiveModel(
        maxTokens: 2048,
        supportImage: true,
        maxNumImages: 1,
      );
      chat = await model.createChat(supportImage: true);
      await chat.addQueryChunk(
        Message.withImages(
          text: bookAnalysisPrompt,
          imageBytes: [image],
          isUser: true,
        ),
      );
      final buffer = StringBuffer();
      await for (final r in chat.generateChatResponseAsync().timeout(
        _analyzeTimeout,
      )) {
        if (r is TextResponse) buffer.write(r.token);
      }
      raw = buffer.toString();
    } catch (_) {
      throw const BookAiException(BookAiFailure.model);
    } finally {
      await chat?.close();
      await model?.close();
    }

    final result = parseBookAnalysis(raw);
    if (result == null) throw const BookAiException(BookAiFailure.unreadable);
    return result;
  }
}
