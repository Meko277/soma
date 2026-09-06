// ================================================================
// COPTIC TRANSLATOR PROVIDER (Riverpod state layer)
//
// UI  ->  translatorProvider  ->  CopticTranslatorService
//
// Network traffic happens ONLY inside translate() calls, i.e. only
// when the user actually uses the translator. Everything else in the
// app stays fully offline.
// ================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'translator_models.dart';
import 'translator_service.dart';

/// Lifecycle of one translation request.
enum TranslatorStatus {
  /// Nothing translated yet.
  idle,

  /// A request is in flight.
  loading,

  /// A result is available (may still be "not in dictionary").
  done,

  /// The request failed (network/API problem).
  error,
}

/// Immutable UI state for the translator screen.
class TranslatorState {
  const TranslatorState({
    this.status = TranslatorStatus.idle,
    this.result,
    this.requestedText = '',
    this.from = '',
    this.to = '',
    this.errorMessage,
  });

  const TranslatorState.idle() : this();

  const TranslatorState.loading({
    required this.requestedText,
    required this.from,
    required this.to,
  })  : status = TranslatorStatus.loading,
        result = null,
        errorMessage = null;

  const TranslatorState.done({
    required this.result,
    required this.requestedText,
    required this.from,
    required this.to,
  })  : status = TranslatorStatus.done,
        errorMessage = null;

  const TranslatorState.error({
    required String this.errorMessage,
    required this.requestedText,
    required this.from,
    required this.to,
  })  : status = TranslatorStatus.error,
        result = null;

  final TranslatorStatus status;
  final TranslationResult? result;
  final String requestedText;
  final String from;
  final String to;
  final String? errorMessage;

  bool get isLoading => status == TranslatorStatus.loading;
}

/// The single translator service used by the whole app.
///
/// Offline-first: the built-in lexicon always answers; an online
/// gateway upgrades the result only when one was configured for this
/// build via --dart-define.
final Provider<CopticTranslatorService> copticTranslatorServiceProvider =
    Provider<CopticTranslatorService>((ref) {
  return createCopticTranslatorService();
});

/// Whether an online gateway was configured for this build.
final Provider<bool> translatorRemoteConfiguredProvider = Provider<bool>((ref) {
  final service = ref.watch(copticTranslatorServiceProvider);
  return service is CompositeCopticTranslatorService &&
      service.isRemoteConfigured;
});

/// Drives the translator screen.
class TranslatorNotifier extends StateNotifier<TranslatorState> {
  TranslatorNotifier(this._service) : super(const TranslatorState.idle());

  final CopticTranslatorService _service;

  /// Guards against out-of-order completion (e.g. the user retypes
  /// while a request is still in flight).
  int _requestSeq = 0;

  Future<void> translate(
    String text,
    String from,
    String to,
  ) async {
    final input = text.trim();

    if (input.isEmpty) {
      _requestSeq++;
      state = const TranslatorState.idle();
      return;
    }

    if (!(
      (from == TCode.coptic || from == TCode.arabic) &&
          (to == TCode.coptic || to == TCode.arabic) &&
          from != to
    )) {
      state = TranslatorState.error(
        errorMessage: 'Unsupported translation direction.',
        requestedText: input,
        from: from,
        to: to,
      );
      return;
    }

    final seq = ++_requestSeq;
    state = TranslatorState.loading(
      requestedText: input,
      from: from,
      to: to,
    );

    try {
      final result = await _service.translate(
        TranslationRequest(text: input, from: from, to: to),
      );

      if (!mounted || seq != _requestSeq) {
        return; // A newer request superseded this one.
      }

      state = TranslatorState.done(
        result: result,
        requestedText: input,
        from: from,
        to: to,
      );
    } on TranslatorUnavailableException catch (error) {
      if (!mounted || seq != _requestSeq) {
        return;
      }
      state = TranslatorState.error(
        errorMessage: error.message,
        requestedText: input,
        from: from,
        to: to,
      );
    } catch (_) {
      // Absolute last resort - the UI must never crash on translation.
      if (!mounted || seq != _requestSeq) {
        return;
      }
      state = TranslatorState.error(
        errorMessage: 'Unexpected translator error.',
        requestedText: input,
        from: from,
        to: to,
      );
    }
  }

  /// Clears the current state (e.g. input was emptied).
  void clear() {
    _requestSeq++;
    state = const TranslatorState.idle();
  }
}

final StateNotifierProvider<TranslatorNotifier, TranslatorState>
    translatorProvider = StateNotifierProvider<TranslatorNotifier,
        TranslatorState>((ref) {
  return TranslatorNotifier(ref.watch(copticTranslatorServiceProvider));
});