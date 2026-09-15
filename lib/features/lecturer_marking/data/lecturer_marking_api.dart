/// Suggests a mark for one exam-script question using a local heuristic —
/// not a live AI model, and no backend is required. This is advisory only:
/// [suggestMarking] never writes a score anywhere itself; the caller shows
/// the suggestion for the lecturer to accept, edit, or ignore. When a real
/// backend/AI service is ready, this is the file to swap the local
/// heuristic for a network call (the `/api/ai/marking/suggest` request
/// shape below is already documented for that).
class LecturerMarkingApi {
  LecturerMarkingApi();

  /// [candidateAnswer] is whatever text the lecturer has transcribed or
  /// summarised from the (often handwritten/scanned) script — there is no
  /// digitised answer text elsewhere in this app yet, so the lecturer
  /// supplies it here rather than the client guessing at OCR.
  ///
  /// The local heuristic scores keyword overlap between [candidateAnswer]
  /// and [markingGuide], blended with a light answer-length signal, so
  /// typing a more complete/relevant answer visibly moves the suggested
  /// score — good enough to demo the "AI helps mark" flow end-to-end
  /// without a backend, though it is not a real grading model.
  Future<AiMarkingSuggestionResult> suggestMarking({
    required String question,
    required String markingGuide,
    required String candidateAnswer,
    required int maxMark,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final guideKeywords = _keywords(markingGuide);
    final answerKeywords = _keywords(candidateAnswer);
    final matched = guideKeywords.where(answerKeywords.contains).length;
    final coverage = guideKeywords.isEmpty
        ? 0.5
        : (matched / guideKeywords.length).clamp(0.0, 1.0);
    final wordCount = candidateAnswer
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .length;
    final lengthFactor = (wordCount / 40).clamp(0.0, 1.0);
    final blended = coverage * 0.7 + lengthFactor * 0.3;
    final suggestedMark = (blended * maxMark).round().clamp(0, maxMark);

    final rationale = guideKeywords.isEmpty
        ? 'No marking guide keywords to compare against — review this one manually.'
        : matched == 0
        ? 'The answer doesn\'t clearly cover the marking guide\'s key points; '
              'consider a low score pending manual review.'
        : 'Covers $matched of ${guideKeywords.length} key term(s) from the '
              'marking guide based on wording overlap.';

    return AiMarkingSuggestionResult.available(
      AiMarkingSuggestion(suggestedMark: suggestedMark, rationale: rationale),
    );
  }

  Set<String> _keywords(String text) => text
      .toLowerCase()
      .split(RegExp(r'[^a-z0-9]+'))
      .where((word) => word.length > 3)
      .toSet();

  void close() {}
}

class AiMarkingSuggestion {
  const AiMarkingSuggestion({
    required this.suggestedMark,
    required this.rationale,
  });

  final int suggestedMark;
  final String rationale;

  factory AiMarkingSuggestion.fromJson(Map<String, dynamic> json) {
    return AiMarkingSuggestion(
      suggestedMark:
          int.tryParse(
            (json['suggested_mark'] ?? json['mark'])?.toString() ?? '',
          ) ??
          0,
      rationale: (json['rationale'] ?? json['feedback'] ?? json['note'] ?? '')
          .toString(),
    );
  }
}

/// Outcome of an AI marking-suggestion request — modelled explicitly (like
/// [AiMarkingSuggestion] for question drafting) so the UI can distinguish
/// "the AI suggested this" from "the AI service isn't reachable", rather
/// than silently defaulting a score. The local heuristic always succeeds,
/// but this shape survives an eventual swap to a real backend call.
class AiMarkingSuggestionResult {
  const AiMarkingSuggestionResult._({
    required this.available,
    this.suggestion,
    this.message,
  });

  final bool available;
  final AiMarkingSuggestion? suggestion;
  final String? message;

  factory AiMarkingSuggestionResult.available(AiMarkingSuggestion suggestion) =>
      AiMarkingSuggestionResult._(available: true, suggestion: suggestion);

  factory AiMarkingSuggestionResult.unavailable([String? message]) =>
      AiMarkingSuggestionResult._(
        available: false,
        message: message ?? 'AI marking suggestions are unavailable right now.',
      );
}
