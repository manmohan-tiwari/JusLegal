import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/rate_us_provider.dart';
import '../core/config/theme_config.dart';

class RateUsSheet extends ConsumerStatefulWidget {
  const RateUsSheet({super.key});

  @override
  ConsumerState<RateUsSheet> createState() => _RateUsSheetState();
}

class _RateUsSheetState extends ConsumerState<RateUsSheet> {
  int _selectedRating = 0;
  final TextEditingController _feedbackController = TextEditingController();
  bool _isSubmitting = false;


  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _handleRatingSubmit() async {
    if (_selectedRating >= 4) {
      // 4-5 stars: open play store listing
      final Uri playStoreUri = Uri.parse(
        'https://play.google.com/store/apps/details?id=com.juslegal.app',
      );
      
      // Save rating state as never ask again before opening link
      await ref.read(rateUsProvider.notifier).neverAsk();
      
      if (mounted) {
        Navigator.of(context).pop();
      }

      try {
        if (await canLaunchUrl(playStoreUri)) {
          await launchUrl(playStoreUri, mode: LaunchMode.externalApplication);
        }
      } catch (e) {
        debugPrint('Could not launch Play Store: $e');
      }
    } else {
      // 1-3 stars: send feedback via email
      final feedbackText = _feedbackController.text.trim();
      if (feedbackText.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter your feedback to help us improve.'),
            backgroundColor: AppTheme.error,
          ),
        );
        return;
      }

      setState(() => _isSubmitting = true);

      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: 'support@juslegal.app',
        queryParameters: {
          'subject': 'JusLegal App Feedback ($_selectedRating Stars)',
          'body': 'Rating: $_selectedRating/5 stars\n\nFeedback:\n$feedbackText',
        },
      );

      // Save rating state as never ask again
      await ref.read(rateUsProvider.notifier).neverAsk();

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Thank you for your feedback! Opening email client...'),
            backgroundColor: AppTheme.success,
          ),
        );
      }

      try {
        if (await canLaunchUrl(emailUri)) {
          await launchUrl(emailUri);
        }
      } catch (e) {
        debugPrint('Could not launch email app: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle/indicator is handled by showModalBottomSheet(showDragHandle: true)
          // but we add a nice header
          Center(
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.rate_review_outlined,
                color: AppTheme.primaryBlue,
                size: 26,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Enjoying JusLegal?',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.darkText,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap a star to rate us. Your feedback helps us make legal assistance accessible to everyone.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.mediumText,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 24),
          
          // Star rating Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starValue = index + 1;
              final isSelected = starValue <= _selectedRating;
              return IconButton(
                onPressed: () {
                  setState(() {
                    _selectedRating = starValue;
                  });
                },
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: Icon(
                    isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                    key: ValueKey<bool>(isSelected),
                    color: isSelected ? Colors.amber[700] : Colors.grey[400],
                    size: 48,
                  ),
                ),
                tooltip: '$starValue Star${starValue > 1 ? 's' : ''}',
              );
            }),
          ),
          
          const SizedBox(height: 16),

          // Dynamic Feedback section for 1-3 stars
          if (_selectedRating > 0 && _selectedRating <= 3) ...[
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "We'd love to know how we can improve:",
                    style: const TextStyle(
                      color: AppTheme.darkText,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _feedbackController,
                    maxLines: 3,
                    style: const TextStyle(
                      color: AppTheme.darkText,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Tell us about your experience...',
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppTheme.primaryBlue, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],

          // Submit Rating / Submit Feedback action
          if (_selectedRating > 0) ...[
            ElevatedButton(
              onPressed: _isSubmitting ? null : _handleRatingSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: AppTheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                _selectedRating >= 4 ? 'Rate on Play Store' : 'Submit Feedback',
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Maybe later & Never ask again buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () async {
                  await ref.read(rateUsProvider.notifier).maybeLater();
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.mediumText,
                ),
                child: const Text('Maybe later'),
              ),
              TextButton(
                onPressed: () async {
                  await ref.read(rateUsProvider.notifier).neverAsk();
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.error,
                ),
                child: const Text('Never ask again'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

