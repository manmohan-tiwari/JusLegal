import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/constants/app_config.dart';
import '../core/constants/app_colors.dart';
import '../widgets/empty_state_widget.dart';

class AuthoritiesScreen extends StatefulWidget {
  const AuthoritiesScreen({super.key});

  @override
  State<AuthoritiesScreen> createState() => _AuthoritiesScreenState();
}

class _AuthoritiesScreenState extends State<AuthoritiesScreen> {
  final List<Map<String, String>> _authorities = [
    {
      'name': 'National Consumer Helpline',
      'contact': '1800-11-4000',
      'purpose': 'All consumer complaints',
      'action': 'Call Now',
    },
    {
      'name': 'Cyber Crime Portal',
      'contact': 'cybercrime.gov.in',
      'purpose': 'Online fraud, UPI fraud',
      'action': 'File Online',
    },
    {
      'name': 'RBI Complaint Portal',
      'contact': 'cms.rbi.org.in',
      'purpose': 'Banking & payment issues',
      'action': 'File Online',
    },
    {
      'name': 'DGCA',
      'contact': 'dgca.gov.in',
      'purpose': 'Flight complaints',
      'action': 'File Online',
    },
    {
      'name': 'TRAI Consumer Portal',
      'contact': 'trai.gov.in',
      'purpose': 'Telecom & internet issues',
      'action': 'File Online',
    },
    {
      'name': 'FSSAI',
      'contact': 'fssai.gov.in',
      'purpose': 'Food quality complaints',
      'action': 'File Online',
    },
    {
      'name': 'Medical Council of India',
      'contact': 'mciindia.org',
      'purpose': 'Hospital & doctor complaints',
      'action': 'File Online',
    },
    {
      'name': 'Traffic Police (Local)',
      'contact': '',
      'purpose': 'Challan disputes',
      'action': 'Find Nearest',
    },
    {
      'name': 'District Consumer Commission',
      'contact': '',
      'purpose': 'Formal consumer court filing',
      'action': 'Find Nearest',
    },
    {
      'name': 'Education Regulatory Authority',
      'contact': '',
      'purpose': 'School/college complaints',
      'action': 'File Online',
    },
    {
      'name': 'State Consumer Commission',
      'contact': '1800-11-4000',
      'purpose': 'State-level consumer issues',
      'action': 'Call Now',
    },
    {
      'name': 'RTO Office',
      'contact': '',
      'purpose': 'Vehicle & license issues',
      'action': 'Find Nearest',
    },
    {
      'name': 'Police Helpline',
      'contact': '100',
      'purpose': 'Emergency complaints',
      'action': 'Call Now',
    },
  ];

  String searchQuery = '';

  List<Map<String, String>> get _filteredAuthorities {
    final q = searchQuery.trim().toLowerCase();
    if (q.isEmpty) return _authorities;

    return _authorities.where((a) {
      final name = (a['name'] ?? '').toLowerCase();
      final category = (a['category'] ?? '').toLowerCase();
      return name.contains(q) || category.contains(q);
    }).toList();
  }

  bool _isLikelyPhone(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return false;
    return RegExp(r'^[0-9+\-\s]{3,}$').hasMatch(s);
  }

  bool _isLikelyEmail(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return false;
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(s);
  }

  bool _isLikelyWebsite(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return false;
    return s.contains('.') && !s.contains(' ');
  }

  Future<void> _launchCall(String phone) async {
    final Uri tel = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(tel)) await launchUrl(tel);
  }

  Future<void> _launchEmail(String email) async {
    final Uri mail = Uri(scheme: 'mailto', path: email.trim());
    if (await canLaunchUrl(mail)) await launchUrl(mail);
  }

  Future<void> _launchUrl(String urlLike) async {
    final trimmed = urlLike.trim();
    if (trimmed.isEmpty) return;

    final Uri url = trimmed.startsWith('http://') || trimmed.startsWith('https://')
        ? Uri.parse(trimmed)
        : Uri.parse('https://$trimmed');

    if (await canLaunchUrl(url)) await launchUrl(url);
  }

  Future<void> _openNearest(String name) async {
    final Uri maps = Uri.parse('${AppConfig.googleMapsUrl}/${Uri.encodeComponent(name)}');
    if (await canLaunchUrl(maps)) await launchUrl(maps);
  }

  Future<void> _copyText(String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surface,
        content: Text(
          'Copied to clipboard',
          style: TextStyle(color: AppColors.primaryNavy),
        ),
      ),
    );
  }

  IconData? _purposeIcon(String action) {
    switch (action) {
      case 'Call Now':
        return Icons.call;
      case 'File Online':
        return Icons.open_in_browser;
      case 'Find Nearest':
        return Icons.location_on;
      default:
        return null;
    }
  }

  void _showAuthorityDetails(Map<String, String> a) {
    final name = a['name'] ?? '';
    final purpose = a['purpose'] ?? '';
    final contact = (a['contact'] ?? '').trim();
    final action = a['action'] ?? '';

    final isPhone = _isLikelyPhone(contact);
    final isEmail = _isLikelyEmail(contact);
    final isWebsite = _isLikelyWebsite(contact);

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(ctx).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    purpose,
                    style: Theme.of(ctx).textTheme.bodySmall,
                  ),
                  if (contact.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      contact,
                      style: Theme.of(ctx).textTheme.bodyMedium,
                    ),
                  ],
                  const SizedBox(height: 16),

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                       if (isPhone || action == 'Call Now')
                         _ContactActionIcon(
                           icon: Icons.call,
                           label: 'Phone',
                           color: AppColors.textSecondary,
                          onPressed: () async {
                            Navigator.of(ctx).pop();
                            await _launchCall(contact);
                          },
                        ),
                       if (isEmail)
                         _ContactActionIcon(
                           icon: Icons.email,
                           label: 'Email',
                           color: AppColors.textSecondary,
                          onPressed: () async {
                            Navigator.of(ctx).pop();
                            await _launchEmail(contact);
                          },
                        ),
                       if (isWebsite)
                         _ContactActionIcon(
                           icon: Icons.open_in_browser,
                           label: 'Website',
                           color: AppColors.textSecondary,
                          onPressed: () async {
                            Navigator.of(ctx).pop();
                            await _launchUrl(contact);
                          },
                        ),
                       if (action == 'Find Nearest')
                         _ContactActionIcon(
                           icon: Icons.location_on,
                           label: 'Find Nearest',
                           color: AppColors.textSecondary,
                          onPressed: () async {
                            Navigator.of(ctx).pop();
                            await _openNearest(name);
                          },
                        ),
                       if (contact.isNotEmpty)
                         _ContactActionIcon(
                           icon: Icons.copy,
                           label: 'Copy',
                           color: AppColors.textSecondary,
                          onPressed: () async {
                            Navigator.of(ctx).pop();
                            await _copyText(contact);
                          },
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  if (isWebsite)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.of(ctx).pop();
                          await _launchUrl(contact);
                        },
                        child: const Text('Visit Website'),
                      ),
                    ),

                  if (contact.isNotEmpty)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () {
                          _copyText(contact);
                          Navigator.of(ctx).pop();
                        },
                        child: const Text('Share'),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _authorityRow(Map<String, String> a) {
    final name = a['name'] ?? '';
    final purpose = a['purpose'] ?? '';
    final action = a['action'] ?? '';
    final actionIcon = _purposeIcon(action);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      shadowColor: Colors.transparent,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        splashColor: AppColors.trustBlue.withValues(alpha: 0.08),
        onTap: () => _showAuthorityDetails(a),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Color(0xFF1F2937),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      purpose,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (actionIcon != null) ...[
                Icon(
                  actionIcon,
                  size: 16,
                  color: AppColors.trustBlue,
                ),
                const SizedBox(width: 6),
              ],
              Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.primaryNavy,
        elevation: 0,
        title: const Text('Legal Authorities'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                onChanged: (query) => setState(() => searchQuery = query),
                decoration: InputDecoration(
                  hintText: 'Search authorities...',
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.textSecondary,
                  ),
                ).applyDefaults(Theme.of(context).inputDecorationTheme),
              ),
            ),
            Expanded(
              child: _filteredAuthorities.isEmpty
                  ? EmptyStateWidget(
                      icon: Icons.gavel_outlined,
                      title: 'No authorities found',
                      subtitle: searchQuery.isEmpty
                          ? 'No authority results are available right now.'
                          : 'Try a different search or clear your query.',
                      actionLabel: searchQuery.isEmpty ? null : 'Clear search',
                      onActionPressed: searchQuery.isEmpty
                          ? null
                          : () => setState(() => searchQuery = ''),
                    )
                  : ListView.builder(
                      itemCount: _filteredAuthorities.length,
                      itemBuilder: (context, index) {
                        return _authorityRow(_filteredAuthorities[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactActionIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ContactActionIcon({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      splashColor: AppColors.trustBlue.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: AppColors.primaryNavy,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
