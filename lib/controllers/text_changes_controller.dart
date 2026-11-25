import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TextChangesController extends GetxController {
  final TextEditingController textController = TextEditingController();

  final RxInt wordCount = 0.obs;
  final RxInt letterCount = 0.obs;
  final RxInt whitespaceCount = 0.obs;
  final RxList<_WordFrequency> topWords = <_WordFrequency>[].obs;

  final RxBool isAnalyzing = false.obs;
  final RxBool hasError = false.obs;

  bool _isRunning = false;
  String? _pendingText;

  @override
  void onInit() {
    super.onInit();
    textController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    _requestAnalyze(textController.text);
  }

  void _requestAnalyze(String text) {
    if (_isRunning) {
      _pendingText = text;
      return;
    }
    _runAnalysis(text);
  }

  Future<void> _runAnalysis(String text) async {
    _isRunning = true;
    hasError.value = false;

    if (text.isEmpty) {
      _resetStats();
      isAnalyzing.value = false;
      _isRunning = false;
      _consumePendingIfAny();
      return;
    }

    isAnalyzing.value = true;

    try {
      final result = await Isolate.run(() => _analyzeTextInIsolate(text));
      if (isClosed) return;

      wordCount.value = result.wordCount;
      letterCount.value = result.letterCount;
      whitespaceCount.value = result.whitespaceCount;
      topWords.assignAll(result.topWords);
      hasError.value = false;
    } catch (_) {
      if (isClosed) return;
      hasError.value = true;
    } finally {
      _isRunning = false;
      if (!isClosed) {
        isAnalyzing.value = false;
        _consumePendingIfAny();
      }
    }
  }

  void _consumePendingIfAny() {
    final nextText = _pendingText;
    if (nextText == null) return;
    _pendingText = null;
    _runAnalysis(nextText);
  }

  void _resetStats() {
    wordCount.value = 0;
    letterCount.value = 0;
    whitespaceCount.value = 0;
    topWords.clear();
  }

  @override
  void onClose() {
    _pendingText = null;
    textController.removeListener(_onTextChanged);
    textController.dispose();
    super.onClose();
  }
}

class _WordFrequency {
  final String word;
  final int count;

  const _WordFrequency({required this.word, required this.count});
}

class _AnalysisResult {
  final int wordCount;
  final int letterCount;
  final int whitespaceCount;
  final List<_WordFrequency> topWords;

  const _AnalysisResult({
    required this.wordCount,
    required this.letterCount,
    required this.whitespaceCount,
    required this.topWords,
  });
}

_AnalysisResult _analyzeTextInIsolate(String text) {
  int whitespaceCount = 0;
  int letterCount = 0;

  final RegExp letterPattern = RegExp(r'[A-Za-z\u0600-\u06FF]');
  final Map<String, int> frequencyMap = {};
  final StringBuffer currentWord = StringBuffer();

  void flushWord() {
    if (currentWord.isEmpty) return;
    final word = currentWord.toString().toLowerCase();
    frequencyMap[word] = (frequencyMap[word] ?? 0) + 1;
    currentWord.clear();
  }

  for (int i = 0; i < text.length; i++) {
    final char = text[i];
    final codeUnit = text.codeUnitAt(i);

    final isWhitespace =
        codeUnit == 32 ||
        codeUnit == 9 ||
        codeUnit == 10 ||
        codeUnit == 13 ||
        char.trim().isEmpty;

    if (isWhitespace) {
      whitespaceCount++;
      flushWord();
    } else if (letterPattern.hasMatch(char)) {
      letterCount++;
      currentWord.write(char);
    } else {
      flushWord();
    }
  }
  flushWord();

  int totalWords = 0;
  for (final count in frequencyMap.values) {
    totalWords += count;
  }

  final sortedEntries = frequencyMap.entries.toList()
    ..sort((a, b) {
      final countCompare = b.value.compareTo(a.value);
      if (countCompare != 0) return countCompare;
      return a.key.compareTo(b.key);
    });

  final topFive = sortedEntries
      .take(5)
      .map((e) => _WordFrequency(word: e.key, count: e.value))
      .toList();

  return _AnalysisResult(
    wordCount: totalWords,
    letterCount: letterCount,
    whitespaceCount: whitespaceCount,
    topWords: topFive,
  );
}