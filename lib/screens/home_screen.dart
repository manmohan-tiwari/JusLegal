import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_config.dart';
import '../core/constants/categories.dart';
import '../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';
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
                  toolbarHeight: 76,
                  titleSpacing: 16,
                  scrolledUnderElevation: 0,
                  title: const Align(
                    alignment: Alignment.centerLeft,
                    child: _HeaderLogo(height: 36),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      onPressed: () => context.go('/home/settings'),
                      tooltip: 'Settings',
                    ),
                  ],
                ),
          body: SafeArea(
            top: false,
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: isDesktop ? 1100 : double.infinity),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      isDesktop ? 32 : 16,
                      isDesktop ? 28 : 16,
                      isDesktop ? 32 : 16,
                      isDesktop ? 36 : 112,
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
          floatingActionButton: _buildFloatingAIButton(),
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

// ─────────────────────────────────────────────
// AI Feature Tool model
// ─────────────────────────────────────────────

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

// ─────────────────────────────────────────────
// Full feature list
// ─────────────────────────────────────────────

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
    description: 'Upload a doc — AI finds red flags & key clauses',
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

// ─────────────────────────────────────────────
// Home Content
// ─────────────────────────────────────────────

class _HomeContent extends StatelessWidget {
  final List<LegalCategory> categories;
  final bool isDesktop;

  static const double _categorySectionTopSpacingDesktop = 48;
  static const double _categorySectionTopSpacingMobile = 40;

  const _HomeContent({
    required this.categories,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HeroSection(isDesktop: isDesktop),
        SizedBox(
          height: isDesktop
              ? _categorySectionTopSpacingDesktop
              : _categorySectionTopSpacingMobile,
        ),

        // ── Legal Categories ──────────────────────────────
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
              final columns = isDesktop ? 4 : 2;
              final childAspectRatio = isDesktop ? 1.1 : 0.85;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categories.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: childAspectRatio,
                ),
                itemBuilder: (context, index) {
                  return _CategoryCard(
                    category: categories[index],
                    onTap: () => context.go(
                      '/home/analyzer?category=${Uri.encodeComponent(categories[index].name)}',
                    ),
                  );
                },
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

        // ── AI Chat & Analysis Tools ──────────────────────
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
        _AiToolsGrid(tools: _aiChatTools, isDesktop: isDesktop),

        // ── Documents & Contracts Tools ───────────────────
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
        _AiToolsGrid(tools: _documentTools, isDesktop: isDesktop),

        // ── Why Choose JusLegal ───────────────────────────
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

// ─────────────────────────────────────────────
// AI Tools Grid
// ─────────────────────────────────────────────

class _AiToolsGrid extends StatelessWidget {
  final List<_AiFeatureTool> tools;
  final bool isDesktop;

  const _AiToolsGrid({required this.tools, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final columns = isDesktop ? 4 : 2;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tools.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: isDesktop ? 1.15 : 0.9,
      ),
      itemBuilder: (context, index) {
        return _AiToolCard(
          tool: tools[index],
          onTap: () => context.push(tools[index].route),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// AI Tool Card
// ─────────────────────────────────────────────

class _AiToolCard extends StatelessWidget {
  final _AiFeatureTool tool;
  final VoidCallback onTap;

  const _AiToolCard({required this.tool, required this.onTap});

  // Documents category gets a gold accent, chat gets blue
  Color get _accentColor =>
      tool.category == 'documents' ? AppColors.legalGold : AppColors.trustBlue;

  Color get _iconBg => tool.category == 'documents'
      ? AppColors.legalGold.withValues(alpha: 0.10)
      : AppColors.trustBlue.withValues(alpha: 0.08);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 2,
      shadowColor: AppColors.primaryNavy.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: _accentColor.withValues(alpha: 0.08),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon circle
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  tool.icon,
                  color: _accentColor,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                tool.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF1F2937),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ).copyWith(
                  color: AppColors.primaryNavy,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),

              // Description
              Text(
                tool.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ).copyWith(
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
              ),

              const Spacer(),

              // Bottom arrow chip
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _iconBg,
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Existing widgets below — unchanged
// ─────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  final bool isDesktop;

  const _HeroSection({required this.isDesktop});

  static const Color _heroAccentTextColor = Color(0xFFFFC247);
  static const Color _heroCtaColor = Color(0xFF111827);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 28 : 16,
        vertical: isDesktop ? 30 : 24,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryNavy, AppColors.trustBlue],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryNavy.withValues(alpha: 0.16),
            blurRadius: 26,
            offset: const Offset(0, 14),
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
    final headlineStyle = TextStyle(
      color: Colors.white,
      fontSize: isDesktop ? 34 : 28,
      fontWeight: FontWeight.w800,
      height: 1.2,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Know Your Rights.', style: headlineStyle),
        Text(
          'Take Action.',
          style: headlineStyle.copyWith(
            color: _HeroSection._heroAccentTextColor,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Get instant AI-powered legal guidance for your consumer issues.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: isDesktop ? 220 : double.infinity,
          child: ElevatedButton(
            onPressed: () => context.go('/home/analyzer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _HeroSection._heroCtaColor,
              foregroundColor: Colors.white,
              elevation: 2,
              shadowColor: Colors.black.withValues(alpha: 0.18),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
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

  static const double _titleBlockMinHeight = 40;

  const _CategoryCard({
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 2,
      shadowColor: AppColors.primaryNavy.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: AppColors.trustBlue.withValues(alpha: 0.1),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.trustBlue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  category.icon,
                  color: AppColors.primaryNavy,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints:
                    const BoxConstraints(minHeight: _titleBlockMinHeight),
                child: Center(
                  child: Text(
                    category.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF1F2937),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ).copyWith(
                      color: AppColors.primaryNavy,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                category.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ).copyWith(
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
              ),
            ],
          ),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF1F2937),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ).copyWith(
                    color: AppColors.primaryNavy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ).copyWith(
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.legalGold.withValues(alpha: 0.12),
            border: Border.all(color: AppColors.legalGold),
            borderRadius: BorderRadius.circular(12),
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
                          text:
                              'AI-generated guidance only. Not legal advice. '),
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
          width: 3,
          height: 14,
          color: AppColors.trustBlue,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF0052CC),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ).copyWith(
            color: AppColors.primaryNavy,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
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
  Size get preferredSize => const Size.fromHeight(88);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: preferredSize.height,
      titleSpacing: 28,
      scrolledUnderElevation: 0,
      title: const Align(
        alignment: Alignment.centerLeft,
        child: _HeaderLogo(height: 38),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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
  final double height;

  const _HeaderLogo({required this.height});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppConfig.appLogoAsset,
      height: height,
      fit: BoxFit.contain,
      alignment: Alignment.centerLeft,
      errorBuilder: (context, error, stackTrace) => const Text(
        'JusLegal',
        style: TextStyle(
          color: AppColors.primaryNavy,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
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
              color: const Color(0xFFFFFFFF).withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                  color: const Color(0xFFE5E7EB).withValues(alpha: 0.8)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryNavy.withValues(alpha: 0.14),
                  blurRadius: 32,
                  offset: const Offset(0, -4),
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
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.trustBlue.withValues(alpha: 0.08)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            selected ? item.selectedIcon : item.icon,
                            color: selected
                                ? const Color(0xFF0052CC)
                                : const Color(0xFF6B7280),
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
                                  ? const Color(0xFF0052CC)
                                  : const Color(0xFF6B7280),
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
