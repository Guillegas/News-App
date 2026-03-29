import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_themes.dart';
import '../../../injection_container.dart';
import '../domain/use_cases/summarize_article_usecase.dart';
import '../domain/use_cases/suggest_headline_usecase.dart';
import '../domain/use_cases/analyze_sentiment_usecase.dart';

/// A bottom sheet that offers AI-powered features for an article.
class AiBottomSheet extends StatefulWidget {
  final String title;
  final String content;

  const AiBottomSheet({
    Key? key,
    required this.title,
    required this.content,
  }) : super(key: key);

  /// Convenience method to show the bottom sheet.
  static void show(BuildContext context,
      {required String title, required String content}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AiBottomSheet(title: title, content: content),
    );
  }

  @override
  State<AiBottomSheet> createState() => _AiBottomSheetState();
}

class _AiBottomSheetState extends State<AiBottomSheet> {
  final SummarizeArticleUseCase _summarize = sl<SummarizeArticleUseCase>();
  final SuggestHeadlineUseCase _suggestHeadline = sl<SuggestHeadlineUseCase>();
  final AnalyzeSentimentUseCase _analyzeSentiment = sl<AnalyzeSentimentUseCase>();

  bool _loading = false;
  String? _result;
  String? _error;
  String _currentAction = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title
              Row(
                children: [
                  Icon(Icons.auto_awesome, color: kSymmetryPurple, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'AI Assistant',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Powered by OpenAI',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
              const SizedBox(height: 20),

              // Action buttons
              if (!_loading && _result == null) ...[
                _buildActionButton(
                  icon: Icons.summarize,
                  label: 'Summarize Article',
                  subtitle: 'Get a 2-3 sentence summary',
                  isDark: isDark,
                  onTap: _onSummarize,
                ),
                const SizedBox(height: 10),
                _buildActionButton(
                  icon: Icons.title,
                  label: 'Suggest Better Headline',
                  subtitle: 'AI-powered headline improvement',
                  isDark: isDark,
                  onTap: _onSuggestHeadline,
                ),
                const SizedBox(height: 10),
                _buildActionButton(
                  icon: Icons.sentiment_satisfied_alt,
                  label: 'Analyze Sentiment',
                  subtitle: 'Positive, negative or neutral?',
                  isDark: isDark,
                  onTap: _onAnalyzeSentiment,
                ),
              ],

              // Loading
              if (_loading) ...[
                const SizedBox(height: 40),
                Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: kSymmetryPurple),
                      const SizedBox(height: 16),
                      Text(
                        _currentAction,
                        style: TextStyle(
                          color: isDark ? Colors.white60 : Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],

              // Result
              if (_result != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? kSymmetryPurple.withOpacity(0.15)
                        : kSymmetryPurple.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: kSymmetryPurple.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.auto_awesome,
                              color: kSymmetryPurple, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            _currentAction,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: kSymmetryPurple,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _result!,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton.icon(
                    onPressed: () => setState(() {
                      _result = null;
                      _error = null;
                    }),
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: const Text('Try another action'),
                    style: TextButton.styleFrom(
                      foregroundColor: kSymmetryPurple,
                    ),
                  ),
                ),
              ],

              // Error
              if (_error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: const TextStyle(
                              color: Colors.red, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () => setState(() {
                      _error = null;
                      _result = null;
                    }),
                    child: Text('Try again',
                        style: TextStyle(color: kSymmetryPurple)),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isDark ? const Color(0xFF252525) : const Color(0xFFF5F5F5),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: kSymmetryPurple.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: kSymmetryPurple, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white38 : Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  color: isDark ? Colors.white24 : Colors.black26),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onSummarize() async {
    await _runAiAction(
      action: 'Summary',
      future: _summarize(SummarizeArticleParams(
        title: widget.title,
        content: widget.content,
      )),
    );
  }

  Future<void> _onSuggestHeadline() async {
    await _runAiAction(
      action: 'Headline Suggestion',
      future: _suggestHeadline(SuggestHeadlineParams(
        title: widget.title,
        content: widget.content,
      )),
    );
  }

  Future<void> _onAnalyzeSentiment() async {
    await _runAiAction(
      action: 'Sentiment Analysis',
      future: _analyzeSentiment(AnalyzeSentimentParams(
        title: widget.title,
        content: widget.content,
      )),
    );
  }

  Future<void> _runAiAction({
    required String action,
    required Future<String> future,
  }) async {
    setState(() {
      _loading = true;
      _currentAction = action;
      _error = null;
      _result = null;
    });

    try {
      final result = await future;
      if (mounted) {
        setState(() {
          _loading = false;
          _result = result;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    }
  }
}
