import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class UserTestimonial extends StatelessWidget {
  final String userName;
  final String location;
  final String caseType;
  final String outcome;
  final String amount;
  final String? avatarUrl;
  final String date;

  const UserTestimonial({
    super.key,
    required this.userName,
    required this.location,
    required this.caseType,
    required this.outcome,
    required this.amount,
    this.avatarUrl,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Testimonial from $userName',
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.border,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User info row
              Row(
                children: [
                  Semantics(
                    label: 'User avatar',
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(24),
                        image: avatarUrl != null
                            ? DecorationImage(
                                image: NetworkImage(avatarUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: avatarUrl == null
                          ? const Icon(
                              Icons.person,
                              color: AppTheme.primaryBlue,
                              size: 24,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            color: AppTheme.darkText,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ).copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.darkText,
                          ),
                        ),
                        Text(
                          location,
                          style: const TextStyle(
                            color: AppTheme.mediumText,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ).copyWith(
                            color: AppTheme.mediumText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.successEmerald.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'SUCCESS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.successEmerald,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Case details
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      caseType,
                      style: const TextStyle(
                        color: AppTheme.darkText,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ).copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Outcome: $outcome',
                      style: const TextStyle(
                        color: AppTheme.mediumText,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ).copyWith(
                        color: AppTheme.mediumText,
                      ),
                    ),
                    if (amount.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'Amount Recovered:',
                            style: const TextStyle(
                              color: AppTheme.mediumText,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ).copyWith(
                              color: AppTheme.mediumText,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            amount,
                            style: const TextStyle(
                              color: AppTheme.darkText,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ).copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.successEmerald,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 8),
              
              // Date
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: AppTheme.mediumText,
                  ),
                  SizedBox(width: 6),
                  Text(
                    date,
                    style: TextStyle(
                      color: AppTheme.mediumText,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
