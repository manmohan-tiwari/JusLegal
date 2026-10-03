import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'package:juslegal/core/core.dart';
import '../providers/ai_provider.dart';
import '../providers/problem_provider.dart';
import '../services/file_upload_service.dart';
import '../widgets/section_label.dart';

class ProblemAnalyzerScreen extends ConsumerStatefulWidget {
  final String? initialCategory;

  const ProblemAnalyzerScreen({super.key, this.initialCategory});

  @override
  ConsumerState<ProblemAnalyzerScreen> createState() =>
      _ProblemAnalyzerScreenState();
}

class _ProblemAnalyzerScreenState extends ConsumerState<ProblemAnalyzerScreen> {
  final _scrollController = ScrollController();
  final _summaryController = TextEditingController();
  final _amountController = TextEditingController();
  final _opponentController = TextEditingController();
  final _focusNode = FocusNode();

  late String _selectedCategory;
  bool _isAnalyzing = false;
  bool _showExtraDetails = false;
  final List<PlatformFile> _attachedFiles = [];

  // Voice Speech-to-Text
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  final List<LegalCategory> _categories = AppCategories.categories;

  static const List<Map<String, String>> _quickScenarios = [
    {
      'label': 'Deposit Withheld',
      'category': 'Housing & Real Estate',
      'text':
          'My landlord is refusing to return my security deposit of ₹45,000 even after vacating the flat 30 days ago with all dues cleared.',
    },
    {
      'label': 'Unpaid Salary',
      'category': 'Employment',
      'text':
          'My employer has withheld my last 2 months salary (₹80,000) and full-and-final settlement after I completed my notice period.',
    },
    {
      'label': 'Cheque Bounced',
      'category': 'Banking & UPI Fraud',
      'text':
          'A business partner gave me a cheque of ₹1,50,000 against goods delivered, which got bounced due to insufficient funds in their account.',
    },
    {
      'label': 'UPI / Bank Fraud',
      'category': 'Banking & UPI Fraud',
      'text':
          'An unauthorized transaction of ₹25,000 was debited from my bank account via UPI fraud. Bank customer care has not resolved it.',
    },
    {
      'label': 'Fake / Defective Item',
      'category': 'E-commerce & Shopping',
      'text':
          'I received a damaged and counterfeit electronic product worth ₹18,000 from an online seller. The platform rejected my return request.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = _safeInitialCategory(widget.initialCategory);
  }

  String _safeInitialCategory(String? initial) {
    if (initial == null || initial.trim().isEmpty) {
      return _categories.isNotEmpty ? _categories.first.name : 'General';
    }
    final match = _categories.firstWhere(
      (c) => c.name.toLowerCase() == initial.toLowerCase(),
      orElse: () => _categories.first,
    );
    return match.name;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _summaryController.dispose();
    _amountController.dispose();
    _opponentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _toggleVoiceInput() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      return;
    }

    final available = await _speech.initialize(
      onError: (e) => setState(() => _isListening = false),
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
    );

    if (available) {
      setState(() => _isListening = true);
      HapticFeedback.lightImpact();
      _speech.listen(
        onResult: (result) {
          setState(() {
            _summaryController.text = result.recognizedWords;
          });
        },
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speech recognition is not available.')),
      );
    }
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: const [
          'jpg',
          'jpeg',
          'png',
          'pdf',
          'doc',
          'docx',
          'txt'
        ],
      );
      if (result == null || result.files.isEmpty) return;

      final validation = FileUploadService.validateFileBatch(result.files);
      if (validation != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(validation),
            backgroundColor: Colors.red.shade700,
          ),
        );
        return;
      }

      setState(() {
        _attachedFiles.addAll(result.files);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not attach files.')),
      );
    }
  }

  Future<void> _analyze() async {
    final description = _summaryController.text.trim();
    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe your issue first.')),
      );
      _focusNode.requestFocus();
      return;
    }

    if (description.length < 15) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Please provide a little more detail (at least 15 characters).')),
      );
      return;
    }

    final conn = await Connectivity().checkConnectivity();
    if (conn == ConnectivityResult.none) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No internet connection. Please check your network.')),
      );
      return;
    }

    _focusNode.unfocus();
    setState(() => _isAnalyzing = true);

    try {
      final amount = _amountController.text.trim().isNotEmpty
          ? _amountController.text.trim()
          : 'Not specified';
      final opponent = _opponentController.text.trim().isNotEmpty
          ? _opponentController.text.trim()
          : 'Opposite Party';

      ref.read(problemProvider.notifier).setCategory(_selectedCategory);
      ref.read(problemProvider.notifier).setDescription(description);

      final aiService = ref.read(aiServiceProvider);
      final rawAnalysis = await aiService.analyzeProblem(
        category: _selectedCategory,
        dateOfIncident: 'Recent',
        disputedAmount: amount,
        involvedParty: opponent,
        referenceNumber: 'REF-${DateTime.now().millisecondsSinceEpoch}',
        summary: description,
        attachedFiles: _attachedFiles,
      );

      final normalizer = AnalysisPayloadNormalizer();
      final normalized = normalizer.normalize(rawAnalysis);
      final legalResult = normalizer.toLegalResultModel(normalized);

      ref.read(lastResultProvider.notifier).set(legalResult);

      if (!mounted) return;
      context.push('/home/result', extra: legalResult);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Analysis failed: ${e.toString()}'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Solve Legal Issue'),
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Category Selector (Horizontal Pills)
              SectionLabel('1. SELECT TOPIC'),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categories.map((cat) {
                    final isSelected = cat.name == _selectedCategory;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () => setState(() => _selectedCategory = cat.name),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.deepForest
                                : AppColors.surface,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.deepForest
                                  : AppColors.border,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            cat.name,
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.onSurface,
                              fontSize: 12.5,
                              fontWeight:
                                  isSelected ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 20),

              // 2. Quick Scenario Chips (1-tap to populate)
              SectionLabel('2. COMMON SCENARIOS (1-TAP TO FILL)'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _quickScenarios.map((qs) {
                  return ActionChip(
                    label: Text(qs['label']!),
                    avatar: const Icon(Icons.bolt, size: 16, color: AppColors.brightEmerald),
                    backgroundColor: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _selectedCategory = qs['category']!;
                        _summaryController.text = qs['text']!;
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // 3. Problem Description & Voice Input
              SectionLabel('3. DESCRIBE YOUR ISSUE'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _summaryController,
                      focusNode: _focusNode,
                      maxLines: 5,
                      maxLength: 2000,
                      textInputAction: TextInputAction.newline,
                      decoration: const InputDecoration(
                        hintText:
                            'Explain what happened in plain Hindi or English...\n\nE.g. My landlord is not returning my ₹45,000 security deposit after 30 days of vacating with all electricity dues paid.',
                        hintStyle: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          height: 1.5,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.border),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: _toggleVoiceInput,
                            icon: Icon(
                              _isListening ? Icons.mic : Icons.mic_none_rounded,
                              color: _isListening ? Colors.red : AppColors.deepForest,
                            ),
                            tooltip: 'Voice Input',
                          ),
                          Text(
                            _isListening ? 'Listening...' : 'Tap mic to speak',
                            style: TextStyle(
                              fontSize: 12,
                              color: _isListening ? Colors.red : AppColors.textSecondary,
                              fontWeight: _isListening ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          if (_summaryController.text.isNotEmpty)
                            TextButton(
                              onPressed: () => setState(() => _summaryController.clear()),
                              child: const Text('Clear'),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // 4. Optional Details Accordion
              InkWell(
                onTap: () => setState(() => _showExtraDetails = !_showExtraDetails),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  child: Row(
                    children: [
                      Icon(
                        _showExtraDetails ? Icons.expand_less : Icons.add_circle_outline,
                        size: 18,
                        color: AppColors.deepForest,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _showExtraDetails
                            ? 'Hide Additional Details'
                            : 'Add Amount / Opponent / Evidence (Optional)',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.deepForest,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (_showExtraDetails) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Disputed Amount (₹)',
                          hintText: 'E.g. 45000',
                          prefixText: '₹ ',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _opponentController,
                        decoration: const InputDecoration(
                          labelText: 'Opposite Party / Company Name',
                          hintText: 'E.g. Landlord Name / Bank / Company',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _pickFiles,
                        icon: const Icon(Icons.attach_file_rounded),
                        label: Text(_attachedFiles.isEmpty
                            ? 'Attach Photos / PDF Evidence'
                            : '${_attachedFiles.length} file(s) attached'),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // 5. Big 1-Tap Solution Action Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isAnalyzing ? null : _analyze,
                  icon: _isAnalyzing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.onPrimary,
                          ),
                        )
                      : const Icon(Icons.gavel_rounded),
                  label: Text(
                    _isAnalyzing
                        ? 'Analyzing Legal Rights & Sections...'
                        : 'Get Legal Solution & Action Plan',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Trust badge
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shield_outlined, color: AppColors.deepForest, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'AI analyzes Indian Acts (Consumer Protection, NI Act, BNS/IPC, RERA, Labor Laws) to provide exact legal sections and step-by-step remedies.',
                        style: TextStyle(fontSize: 11.5, height: 1.4, color: AppColors.deepForest),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
