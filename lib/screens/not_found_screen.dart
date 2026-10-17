import 'package:flutter/material.dart';
import 'package:juslegal/core/core.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmOffWhite,
      appBar: AppBar(
        title: const Text(
          'Page Not Found',
          style: TextStyle(
            color: AppColors.deepNavy,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: AppColors.warmOffWhite,
        elevation: 0,
        leading: BackButton(
          color: AppColors.deepNavy,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.divider, height: 1),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.palePeach,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE8C8B5)),
                ),
                child: const Center(
                  child: Icon(
                    Icons.search_off_rounded,
                    color: Color(0xFFC62828),
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '404',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: AppColors.deepNavy,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'The page or document you requested does not exist.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.slateBlue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).maybePop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mustardGold,
                  foregroundColor: AppColors.deepNavy,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Go Back',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: AppColors.deepNavy,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}