import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_animations.dart';
import '../core/constants/categories.dart';
import '../core/config/theme_config.dart';
import '../services/auth_handler.dart';
import '../providers/rate_us_provider.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/floating_ai_button.dart';
import '../widgets/rate_us_sheet.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const SystemUiOverlayStyle _lightSurfaceOverlayStyle =
      SystemUiOverlayStyle(
    statusBarColor: AppColors.surface,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  );
  static const SystemUiOverlayStyle _gradientOverlayStyle =
      SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  );

  int _tabIndex = 0;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(rateUsProvider.notifier).initAndIncrement();
      if (ref.read(rateUsProvider).shouldShowPrompt) {
        _showRateUsSheet();
      }
    });
  }

  void _showRateUsSheet() {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const RateUsSheet(),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  static const List<_BottomNavItem> _navItems = [
    _BottomNavItem('Home', Icons.home_outlined, Icons.home_rounded),
    _BottomNavItem(
        'My Cases', Icons.folder_open_outlined, Icons.folder_rounded),
    _BottomNavItem('Authorities', Icons.gavel_outlined, Icons.gavel_rounded),
    _BottomNavItem('Settings', Icons.settings_outlined, Icons.settings_rounded),
  ];

  void _onTab(int index) {
    if (index == _tabIndex) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
    setState(() => _tabIndex = index);
    switch (index) {
      case 1:
        context.go('/home/cases');
        break;
      case 2:
        context.go('/home/authorities');
        break;
      case 3:
        context.go('/home/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 600;
        final viewPadding = MediaQuery.paddingOf(context);
        final scrollPhysics =
            defaultTargetPlatform == TargetPlatform.android && !kIsWeb
                ? const BouncingScrollPhysics()
                : const ClampingScrollPhysics();
        final homeCategories =
            AppCategories.categories.take(4).toList(growable: false);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: isDesktop
              ? _DesktopHeader(
                  selectedIndex: _tabIndex,
                  items: _navItems,
                  onSelected: _onTab,
                )
              : AppBar(
                  toolbarHeight: 64,
                  titleSpacing: 16,
                  elevation: 8,
                  shadowColor: AppColors.shadowStrong,
                  backgroundColor: Colors.transparent,
                  foregroundColor: AppColors.white,
                  surfaceTintColor: Colors.transparent,
                  flexibleSpace: Container(
                    decoration:
                        const BoxDecoration(gradient: AppColors.appBarGradient),
                  ),
                  centerTitle: false,
                  systemOverlayStyle: _gradientOverlayStyle,
                  title: const Align(
                    alignment: Alignment.centerLeft,
                    child: _HeaderLogo(iconHeight: 40),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      onPressed: () => context.go('/home/settings'),
                      tooltip: 'Settings',
                      constraints:
                          const BoxConstraints(minWidth: 48, minHeight: 48),
                    ),
                  ],
                ),
          body: SafeArea(
            top: false,
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: scrollPhysics,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isDesktop ? 1200 : double.infinity,
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      isDesktop ? 32 : 16,
                      isDesktop ? 28 : 16,
                      isDesktop ? 32 : 16,
                      isDesktop ? 36 : 132 + viewPadding.bottom,
                    ),
                    child: _HomeContent(
                      categories: homeCategories,
                      isDesktop: isDesktop,
                    ),
                  ),
                ),
              ),
            ),
          ),
          bottomNavigationBar: isDesktop
              ? null
              : _FloatingBottomNav(
                  selectedIndex: _tabIndex,
                  items: _navItems,
                  onSelected: _onTab,
                ),
          floatingActionButton: Padding(
            padding: EdgeInsets.only(
              right: isDesktop ? 8 : 4,
              bottom: isDesktop ? 12 : 84 + viewPadding.bottom,
            ),
            child: _buildFloatingAIButton(),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        );
      },
    );
  }

  Widget _buildFloatingAIButton() {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final name = user?.displayName?.split(' ').first ?? 'there';
    return FloatingAIButton(userName: name);
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// AI Feature Tool model
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _AiFeatureTool {
  final String title;
  final String description;
  final IconData icon;
  final String route;
  final String category; // 'chat' | 'documents'

  const _AiFeatureTool({
    required this.title,
    required this.description,
    required this.icon,
    required this.route,
    required this.category,
  });
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Full feature list
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

const List<_AiFeatureTool> _aiChatTools = [
  _AiFeatureTool(
    title: 'AI Lawyer Chat',
    description: 'Ask legal questions in natural conversation',
    icon: Icons.chat_bubble_outline_rounded,
    route: '/home/ai-lawyer-chat',
    category: 'chat',
  ),
  _AiFeatureTool(
    title: 'Legal Advice Q&A',
    description: 'Pre-built questions with AI-generated answers',
    icon: Icons.balance_outlined,
    route: '/home/legal-advice',
    category: 'chat',
  ),
  _AiFeatureTool(
    title: 'Case Analysis',
    description: 'Strengths, weaknesses & next steps for your case',
    icon: Icons.track_changes_rounded,
    route: '/home/case-analysis',
    category: 'chat',
  ),
  _AiFeatureTool(
    title: 'Legal Terms',
    description: 'Plain-language dictionary of legal terminology',
    icon: Icons.menu_book_outlined,
    route: '/home/legal-terms',
    category: 'chat',
  ),
];

const List<_AiFeatureTool> _documentTools = [
  _AiFeatureTool(
    title: 'Legal Writing',
    description: 'Generate complaint letters, notices & agreements',
    icon: Icons.edit_note_rounded,
    route: '/home/legal-writing',
    category: 'documents',
  ),
  _AiFeatureTool(
    title: 'Document Creation',
    description: 'Fill AI-assisted templates as PDF or text',
    icon: Icons.note_add_outlined,
    route: '/home/document-creation',
    category: 'documents',
  ),
  _AiFeatureTool(
    title: 'Document Review',
    description: 'Upload a doc â€” AI finds red flags & key clauses',
    icon: Icons.fact_check_outlined,
    route: '/home/document-review',
    category: 'documents',
  ),
  _AiFeatureTool(
    title: 'Contract Negotiation',
    description: 'AI flags unfair clauses & suggests amendments',
    icon: Icons.handshake_outlined,
    route: '/home/contract-negotiation',
    category: 'documents',
  ),
];

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Home Content
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _HomeContent extends StatelessWidget {
  final List<LegalCategory> categories;
  final bool isDesktop;

  static const double _categorySectionTopSpacingDesktop = 48;
  static const double _categorySectionTopSpacingMobile = 48;

  const _HomeContent({
    required this.categories,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppAnimations.fadeSlideIn(
          _HeroSection(isDesktop: isDesktop),
          duration: const Duration(milliseconds: 520),
        ),
        SizedBox(
          height: isDesktop
              ? _categorySectionTopSpacingDesktop
              : _categorySectionTopSpacingMobile,
        ),

        // â”€â”€ Legal Categories â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        const _SectionLabel('EXPLORE LEGAL CATEGORIES'),
        const SizedBox(height: 16),
        if (categories.isEmpty)
          const EmptyStateWidget(
            icon: Icons.category_outlined,
            title: 'No categories available',
            subtitle: 'Please check back later for legal topics.',
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final columns =
                  isDesktop ? 4 : (constraints.maxWidth < 360 ? 1 : 2);
              final spacing = isDesktop ? 14.0 : 12.0;
              final itemWidth =
                  (constraints.maxWidth - (spacing * (columns - 1))) / columns;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: List.generate(categories.length, (index) {
                  return SizedBox(
                    width: itemWidth,
                    child: AppAnimations.staggeredListItem(
                      _CategoryCard(
                        category: categories[index],
                        onTap: () => context.go(
                          '/home/analyzer?category=${Uri.encodeComponent(categories[index].name)}',
                        ),
                      ),
                      index,
                    ),
                  );
                }),
              );
            },
          ),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: () => context.go('/home/analyzer'),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Show All Categories'),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded, size: 18),
              ],
            ),
          ),
        ),

        // â”€â”€ AI Chat & Analysis Tools â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        SizedBox(height: isDesktop ? 32 : 28),
        const _SectionLabel('AI CHAT, LEGAL QUERIES AND ANALYSIS'),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 11),
          child: Text(
            'Instant AI-powered legal guidance at your fingertips',
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ).copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 14),
        AppAnimations.fadeSlideIn(
          _AiToolsGrid(tools: _aiChatTools, isDesktop: isDesktop),
          delay: const Duration(milliseconds: 120),
        ),

        // â”€â”€ Documents & Contracts Tools â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        SizedBox(height: isDesktop ? 32 : 28),
        const _SectionLabel('DOCUMENTS AND CONTRACTS'),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 11),
          child: Text(
            'Generate, review and negotiate legal documents with AI',
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ).copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 14),
        AppAnimations.fadeSlideIn(
          _AiToolsGrid(tools: _documentTools, isDesktop: isDesktop),
          delay: const Duration(milliseconds: 180),
        ),

        // â”€â”€ Why Choose JusLegal â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        SizedBox(height: isDesktop ? 28 : 24),
        const _SectionLabel('WHY CHOOSE JUSLEGAL'),
        const SizedBox(height: 16),
        const _BenefitItem(
          icon: Icons.verified_outlined,
          title: 'AI-Powered Analysis',
          description: 'Get instant legal analysis based on your situation',
        ),
        const SizedBox(height: 14),
        const _BenefitItem(
          icon: Icons.diamond_outlined,
          title: '10+ Legal Categories',
          description: 'Covers all major consumer issues',
          isGold: true,
        ),
        const SizedBox(height: 14),
        const _BenefitItem(
          icon: Icons.account_balance_rounded,
          title: 'Expert Authorities',
          description: 'Direct access to official regulatory bodies',
        ),
        const SizedBox(height: 14),
        const _BenefitItem(
          icon: Icons.description_outlined,
          title: 'Document Generation',
          description: 'Professional complaint letters and notices',
          isGold: true,
        ),
        const SizedBox(height: 24),
        _DisclaimerBanner(onTap: () => context.push('/privacy-policy')),
      ],
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// AI Tools Grid
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _AiToolsGrid extends StatelessWidget {
  final List<_AiFeatureTool> tools;
  final bool isDesktop;

  const _AiToolsGrid({required this.tools, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = isDesktop ? 4 : (constraints.maxWidth < 360 ? 1 : 2);
        const spacing = 12.0;
        final itemWidth =
            (constraints.maxWidth - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: List.generate(tools.length, (index) {
            return SizedBox(
              width: itemWidth,
              child: AppAnimations.staggeredListItem(
                _AiToolCard(
                  tool: tools[index],
                  onTap: () => context.push(tools[index].route),
                ),
                index,
              ),
            );
          }),
        );
      },
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// AI Tool Card
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _AiToolCard extends StatelessWidget {
  final _AiFeatureTool tool;
  final VoidCallback onTap;

  const _AiToolCard({required this.tool, required this.onTap});

  Color get _accentColor =>
      tool.category == 'documents' ? AppColors.legalGold : AppColors.trustBlue;

  Color get _iconBg => tool.category == 'documents'
      ? AppColors.grey100
      : AppColors.trustBlue.withValues(alpha: 0.12);

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(18);
    return AppAnimations.pressScale(
      onTap: onTap,
      borderRadius: radius,
      splashColor: _accentColor.withValues(alpha: 0.08),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: radius,
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowBlack,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon circle
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                tool.icon,
                color: _accentColor,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              tool.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.primaryNavy,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 6),

            // Description
            Text(
              tool.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
            ),

            // Bottom arrow chip
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Open',
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ).copyWith(
                        color: _accentColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 12,
                      color: _accentColor,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Existing widgets below â€” unchanged
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _HeroSection extends StatelessWidget {
  final bool isDesktop;

  const _HeroSection({required this.isDesktop});

  static const Color _heroAccentTextColor = AppColors.legalGold;

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = isDesktop ? 28.0 : 18.0;
    final verticalPadding = isDesktop ? 30.0 : 22.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryNavy.withValues(alpha: 0.28),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  flex: 6,
                  child: _HeroContent(isDesktop: true),
                ),
                const Spacer(),
                Expanded(
                  flex: 4,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 220),
                    ),
                  ),
                ),
              ],
            )
          : const _HeroContent(isDesktop: false),
    );
  }
}

class _HeroContent extends StatelessWidget {
  final bool isDesktop;

  const _HeroContent({required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final compactMobile = !isDesktop && screenWidth <= 360;
    final headlineStyle = TextStyle(
      color: Colors.white,
      fontSize: isDesktop ? 34 : (compactMobile ? 25 : 28),
      fontWeight: FontWeight.w800,
      height: compactMobile ? 1.15 : 1.2,
    );
    final bodyStyle = TextStyle(
      color: Colors.white,
      fontSize: compactMobile ? 13 : 14,
      fontWeight: FontWeight.w400,
      height: 1.5,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Know Your Rights.', style: headlineStyle),
        Text(
          'Take Action.',
          style: headlineStyle.copyWith(
            color: _HeroSection._heroAccentTextColor,
          ),
        ),
        SizedBox(height: compactMobile ? 10 : 12),
        Text(
          'Get instant AI-powered legal guidance for your consumer issues.',
          style: bodyStyle,
        ),
        SizedBox(height: compactMobile ? 18 : 20),
        SizedBox(
          width: isDesktop ? 220 : double.infinity,
          child: ElevatedButton(
            onPressed: () => context.go('/home/analyzer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryNavy,
              foregroundColor: AppColors.white,
              elevation: 8,
              shadowColor: AppColors.shadow,
              minimumSize: const Size.fromHeight(48),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: const Text('Get Started'),
          ),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final LegalCategory category;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(18);
    return AppAnimations.pressScale(
      onTap: onTap,
      borderRadius: radius,
      splashColor: AppColors.trustBlue.withValues(alpha: 0.1),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppColors.cardBlueGradient,
          borderRadius: radius,
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowBlack,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.backgroundBlue,
                shape: BoxShape.circle,
              ),
              child: Icon(
                category.icon,
                color: AppColors.primaryNavy,
                size: 30,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                category.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.primaryNavy,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              category.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BenefitItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isGold;

  const _BenefitItem({
    required this.icon,
    required this.title,
    required this.description,
    this.isGold = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isGold ? AppColors.legalGold : AppColors.primaryNavy;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowBlack,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.primaryNavy,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DisclaimerBanner extends StatelessWidget {
  final VoidCallback onTap;

  const _DisclaimerBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppAnimations.pressScale(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowBlack,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.warning_rounded,
              color: AppColors.legalGold,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ).copyWith(
                    color: AppColors.primaryNavy,
                    height: 1.4,
                  ),
                  children: const [
                    TextSpan(
                        text: 'AI-generated guidance only. Not legal advice. '),
                    TextSpan(
                      text: 'Learn More ->',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.trustBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;

  const _SectionLabel(this.title);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            gradient: AppColors.goldGradient,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF0052CC),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ).copyWith(
              color: AppColors.primaryNavy,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}

class _DesktopHeader extends StatelessWidget implements PreferredSizeWidget {
  final int selectedIndex;
  final List<_BottomNavItem> items;
  final ValueChanged<int> onSelected;

  const _DesktopHeader({
    required this.selectedIndex,
    required this.items,
    required this.onSelected,
  });

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      systemOverlayStyle: _HomeScreenState._lightSurfaceOverlayStyle,
      toolbarHeight: preferredSize.height,
      titleSpacing: 20,
      scrolledUnderElevation: 0,
      title: const Align(
        alignment: Alignment.centerLeft,
        child: _HeaderLogo(iconHeight: 42),
      ),
      actions: [
        ...List.generate(items.length, (index) {
          final selected = selectedIndex == index;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: TextButton.icon(
              onPressed: () => onSelected(index),
              icon: Icon(
                selected ? items[index].selectedIcon : items[index].icon,
                size: 19,
              ),
              label: Text(items[index].label),
              style: TextButton.styleFrom(
                foregroundColor:
                    selected ? AppColors.primaryNavy : AppColors.textSecondary,
                backgroundColor:
                    selected ? const Color(0xFFDCEBFF) : Colors.transparent,
                minimumSize: const Size(48, 48),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          );
        }),
        const SizedBox(width: 20),
      ],
    );
  }
}

class _HeaderLogo extends StatelessWidget {
  final double iconHeight;

  const _HeaderLogo({required this.iconHeight});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox.square(
            dimension: iconHeight,
            child: Icon(
              Icons.balance_rounded,
              size: iconHeight,
              color: AppColors.primaryNavy,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'JusLegal',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.legalGold,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
          ),
        ],
      ),
    );
  }
}

class _FloatingBottomNav extends StatelessWidget {
  final int selectedIndex;
  final List<_BottomNavItem> items;
  final ValueChanged<int> onSelected;

  const _FloatingBottomNav({
    required this.selectedIndex,
    required this.items,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFFFFF), Color(0xFFF1F7FF)],
              ),
              borderRadius: BorderRadius.circular(24),
              border:
                  Border.all(color: AppColors.white.withValues(alpha: 0.88)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryNavy.withValues(alpha: 0.20),
                  blurRadius: 34,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: AppColors.shadowGold.withValues(alpha: 0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: List.generate(items.length, (index) {
                final item = items[index];
                final selected = index == selectedIndex;

                return Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => onSelected(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      constraints: const BoxConstraints(minHeight: 48),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primaryNavy
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: AppColors.shadow,
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            selected ? item.selectedIcon : item.icon,
                            color: selected
                                ? AppColors.white
                                : AppColors.textSecondary,
                            size: 24,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                            ).copyWith(
                              color: selected
                                  ? AppColors.white
                                  : AppColors.textSecondary,
                              fontWeight:
                                  selected ? FontWeight.w700 : FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem {
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const _BottomNavItem(this.label, this.icon, this.selectedIcon);
}

