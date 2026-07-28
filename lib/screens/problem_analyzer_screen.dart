import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/config/theme_config.dart';
import '../core/constants/categories.dart';
import '../models/problem_model.dart';
import '../widgets/empty_state_widget.dart';
import '../providers/ai_provider.dart';
import '../providers/problem_provider.dart';
import '../widgets/category_card.dart';
import '../widgets/shimmer_loader.dart';

class ProblemAnalyzerScreen extends ConsumerStatefulWidget {
  final String? initialCategory;

  const ProblemAnalyzerScreen({super.key, this.initialCategory});

  @override
  ConsumerState<ProblemAnalyzerScreen> createState() =>
      _ProblemAnalyzerScreenState();
}

class _ProblemAnalyzerScreenState extends ConsumerState<ProblemAnalyzerScreen> {
  final _formKey = GlobalKey<FormState>();

  late final ScrollController _scrollController;
  late final FocusNode _categoryFocusNode;
  late final FocusNode _dateFocusNode;
  late final FocusNode _amountFocusNode;
  late final FocusNode _partyFocusNode;
  late final FocusNode _refFocusNode;
  late final FocusNode _summaryFocusNode;

  int _currentStep = 0;
  late final int _minStep;
  final List<PlatformFile> _pickedFiles = [];

  late final TextEditingController _summaryController;
  late final TextEditingController _dateController;
  late final TextEditingController _amountController;
  late final TextEditingController _partyController;
  late final TextEditingController _refController;

  final List<LegalCategory> _categories = AppCategories.categories;

  late String _category;
  bool _isAnalyzing = false;
  final Map<String, String> _dynamicFieldValues = {};
  final Map<String, TextEditingController> _dynamicFieldControllers = {};

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _categoryFocusNode = FocusNode();
    _dateFocusNode = FocusNode();
    _amountFocusNode = FocusNode();
    _partyFocusNode = FocusNode();
    _refFocusNode = FocusNode();
    _summaryFocusNode = FocusNode();

    _summaryController = TextEditingController();
    _dateController = TextEditingController();
    _amountController = TextEditingController();
    _partyController = TextEditingController();
    _refController = TextEditingController();

    final hasCategoryParam = widget.initialCategory != null &&
        widget.initialCategory!.trim().isNotEmpty;
    _minStep = hasCategoryParam ? 1 : 0;
    _currentStep = _minStep;

    _category =
        hasCategoryParam ? _safeInitialCategory(widget.initialCategory) : '';

    // Set initial category once state is ready.
    if (hasCategoryParam) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(problemProvider.notifier).setCategory(_category);
      });
    }
  }

  String _safeInitialCategory(String? initialCategory) {
    final defaultCategory = _categories.first.name;
    if (initialCategory == null || initialCategory.trim().isEmpty) {
      return defaultCategory;
    }

    const aliases = {
      'Travel & Flights': 'Flights & Travel Issues',
      'Flights & Travel': 'Flights & Travel Issues',
      'Restaurants & Food': 'Restaurants & Food Billing',
      'E-commerce': 'E-commerce & Shopping',
      'Shopping': 'E-commerce & Shopping',
      'Housing': 'Housing & Real Estate',
      'Housing & Rent': 'Housing & Real Estate',
    };

    final normalized = aliases[initialCategory] ?? initialCategory;
    final isValid = _categories.any((c) => c.name == normalized);
    return isValid ? normalized : defaultCategory;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _categoryFocusNode.dispose();
    _dateFocusNode.dispose();
    _amountFocusNode.dispose();
    _partyFocusNode.dispose();
    _refFocusNode.dispose();
    _summaryFocusNode.dispose();

    _summaryController.dispose();
    _dateController.dispose();
    _amountController.dispose();
    _partyController.dispose();
    _refController.dispose();

    for (final controller in _dynamicFieldControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _scrollToFirstError() {
    FocusNode? targetNode;
    if (_currentStep == 1) {
      targetNode = _categoryFocusNode;
    } else if (_currentStep == 2) {
      if (_dateController.text.trim().isEmpty) {
        targetNode = _dateFocusNode;
      } else if (_amountController.text.trim().isEmpty) {
        targetNode = _amountFocusNode;
      } else if (_partyController.text.trim().isEmpty) {
        targetNode = _partyFocusNode;
      } else if (_refController.text.trim().isEmpty) {
        targetNode = _refFocusNode;
      }
    } else if (_currentStep == 3) {
      final summary = _summaryController.text.trim();
      if (summary.isEmpty || summary.length < 10) {
        targetNode = _summaryFocusNode;
      }
    }

    if (targetNode != null && targetNode.context != null) {
      targetNode.requestFocus();
      _scrollController.position.ensureVisible(
        targetNode.context!.findRenderObject()!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onContinue() {
    if (_currentStep == 0) return;
    if (_formKey.currentState?.validate() ?? false) {
      if (_currentStep < 3) {
        setState(() => _currentStep++);
      } else {
        _analyze();
      }
    } else {
      _scrollToFirstError();
    }
  }

  Future<void> _analyze() async {
    if (_isAnalyzing) return;

    final summaryText = _summaryController.text.trim();

    setState(() => _isAnalyzing = true);

    try {
      ref.read(problemProvider.notifier).setCategory(_category);

      String dynamicFieldsText = '';
      if (AppCategories.categoryFields.containsKey(_category)) {
        for (final field in AppCategories.categoryFields[_category]!) {
          final value = _dynamicFieldValues[field.fieldKey] ?? 'Not provided';
          dynamicFieldsText += '${field.label}: $value\n';
        }
      }

      final fullDescription = '''
$dynamicFieldsText
Date: ${_dateController.text}
Amount: ${_amountController.text}
Involved Party: ${_partyController.text}
Reference Number: ${_refController.text}
Summary: $summaryText
'''
          .trim();

      ref.read(problemProvider.notifier).setDescription(fullDescription);

      final problem = ProblemModel(
        category: _category,
        dateOfIncident: _dateController.text.trim(),
        disputedAmount: _amountController.text.trim(),
        involvedParty: _partyController.text.trim(),
        referenceNumber: _refController.text.trim(),
        summary: summaryText,
        attachedFiles: _pickedFiles,
        dynamicFieldValues: _dynamicFieldValues,
      );

      final legalResult =
          await ref.read(analysisProvider.notifier).analyze(problem);

      if (mounted) {
        context.go('/home/result', extra: legalResult);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Analysis failed: $e'),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  Widget _buildStepIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: _currentStep / 3,
          backgroundColor: const Color(0xFFFFFFFF),
          color: const Color(0xFF0052CC),
          minHeight: 2,
        ),
      ],
    );
  }

  Widget _buildStepContent(ThemeData theme) {
    String stepLabel = '';
    Widget content = const SizedBox.shrink();

    if (_currentStep == 0) {
      stepLabel = 'Step 0 - Choose Category';
      content = _categories.isEmpty
          ? const EmptyStateWidget(
              icon: Icons.search_off_outlined,
              title: 'No categories available',
              subtitle: 'Please try again later.',
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 900
                    ? 4
                    : (constraints.maxWidth > 600 ? 3 : 2);
                final textScale = MediaQuery.textScalerOf(context).scale(1);
                final cardHeight = (constraints.maxWidth > 900
                        ? 190.0
                        : (constraints.maxWidth > 600 ? 204.0 : 212.0)) *
                    textScale.clamp(1.0, 1.35);

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _categories.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent: cardHeight,
                  ),
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    return CategoryCard(
                      icon: category.icon,
                      title: category.name,
                      subtitle: category.description,
                      iconColor: const Color(0xFF0052CC),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          _category = category.name;
                          _currentStep = 1;
                        });
                        ref
                            .read(problemProvider.notifier)
                            .setCategory(category.name);
                      },
                    );
                  },
                );
              },
            );
    } else if (_currentStep == 1) {
      stepLabel = 'Step 1 of 3 - Issue Details';
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _category.isEmpty ? null : _category,
            focusNode: _categoryFocusNode,
            validator: (value) => (value == null || value.isEmpty)
                ? 'Please select a category'
                : null,
            items: _categories
                .map(
                  (category) => DropdownMenuItem(
                    value: category.name,
                    child: Text(category.name),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _category = value;
                _dynamicFieldValues.clear();
                for (final controller in _dynamicFieldControllers.values) {
                  controller.dispose();
                }
                _dynamicFieldControllers.clear();
              });
              ref.read(problemProvider.notifier).setCategory(value);
            },
            hint: const Text('Select a category'),
            decoration: const InputDecoration(labelText: 'Category'),
          ),
          if (_category.isNotEmpty &&
              AppCategories.categoryFields.containsKey(_category)) ...[
            const SizedBox(height: 16),
            ...AppCategories.categoryFields[_category]!.map((field) {
              if (!_dynamicFieldControllers.containsKey(field.fieldKey)) {
                _dynamicFieldControllers[field.fieldKey] =
                    TextEditingController();
              }
              final controller = _dynamicFieldControllers[field.fieldKey]!;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextFormField(
                  controller: controller,
                  keyboardType: field.inputType,
                  validator: field.required
                      ? (value) => (value == null || value.trim().isEmpty)
                          ? 'Please enter ${field.label}'
                          : null
                      : null,
                  decoration: InputDecoration(
                    labelText:
                        field.required ? '${field.label} *' : field.label,
                    hintText: field.hint,
                  ),
                  onChanged: (value) {
                    _dynamicFieldValues[field.fieldKey] = value;
                  },
                ),
              );
            }),
          ],
        ],
      );
    } else if (_currentStep == 2) {
      stepLabel = 'Step 2 of 3 - Additional Information';
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _dateController,
                  focusNode: _dateFocusNode,
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Please enter the date'
                      : null,
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    hintText: 'DD/MM/YYYY',
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _amountController,
                  focusNode: _amountFocusNode,
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Please enter the amount'
                      : null,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    hintText: 'e.g. Rs.5000',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _partyController,
            focusNode: _partyFocusNode,
            validator: (value) => (value == null || value.trim().isEmpty)
                ? 'Please enter the involved party'
                : null,
            decoration: const InputDecoration(
              labelText: 'Involved Party',
              hintText: 'e.g. Vendor name, Bank name',
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _refController,
            focusNode: _refFocusNode,
            validator: (value) => (value == null || value.trim().isEmpty)
                ? 'Please enter the reference number'
                : null,
            decoration: const InputDecoration(
              labelText: 'Reference Number',
              hintText: 'e.g. Order ID, Transaction ID',
            ),
          ),
        ],
      );
    } else if (_currentStep == 3) {
      stepLabel = 'Step 3 of 3 - Summary & Evidence';
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _summaryController,
            focusNode: _summaryFocusNode,
            validator: (value) {
              final v = value?.trim() ?? '';
              if (v.isEmpty) return 'Please enter the summary';
              if (v.length < 10) return 'Please enter at least 10 characters';
              return null;
            },
            maxLines: 6,
            maxLength: 600,
            textInputAction: TextInputAction.newline,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Summary',
              hintText: 'Describe what happened in detail...',
            ),
          ),
          const SizedBox(height: 24),
          Text('Evidence',
              style: const TextStyle(
                color: Color(0xFF1F2937),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFE5E7EB),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                const Icon(Icons.cloud_upload_outlined,
                    color: Color(0xFF0052CC), size: 32),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () async {
                    final result = await FilePicker.platform.pickFiles(
                      allowMultiple: true,
                      type: FileType.custom,
                      allowedExtensions: const [
                        'jpg',
                        'jpeg',
                        'png',
                        'pdf',
                        'doc',
                        'docx'
                      ],
                    );
                    if (result != null) {
                      setState(() {
                        _pickedFiles.addAll(result.files);
                      });
                    }
                  },
                  child: const Text('Attach files'),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_outlined,
                        color: const Color(0xFF6B7280).withValues(alpha: 0.7),
                        size: 24),
                    const SizedBox(width: 16),
                    Icon(Icons.picture_as_pdf_outlined,
                        color: const Color(0xFF6B7280).withValues(alpha: 0.7),
                        size: 24),
                    const SizedBox(width: 16),
                    Icon(Icons.description_outlined,
                        color: const Color(0xFF6B7280).withValues(alpha: 0.7),
                        size: 24),
                  ],
                ),
              ],
            ),
          ),
          if (_pickedFiles.isNotEmpty) ...[
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _pickedFiles.length,
              itemBuilder: (context, index) {
                final file = _pickedFiles[index];
                return Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            file.name,
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ).copyWith(color: const Color(0xFF1F2937)),
                          ),
                          Text(
                            '${(file.size / 1024).toStringAsFixed(1)} KB',
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ).copyWith(color: const Color(0xFF6B7280)),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _pickedFiles.removeAt(index);
                        });
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            stepLabel,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Card(
          color: const Color(0xFFF5F7FF),
          elevation: 0,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: content,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    final bool isLastStep = _currentStep == 3;
    const bool canContinue = true;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (_isAnalyzing) return;

        await showDialog<void>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('Discard Analysis?'),
              content: const Text('Your entered data will be lost.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Keep Editing'),
                ),
                ElevatedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(dialogContext).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Discard'),
                ),
              ],
            );
          },
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('New Analysis'),
          leading: IconButton(
            onPressed: () {
              if (_currentStep > _minStep) {
                setState(() => _currentStep--);
                return;
              }
              context.pop();
            },
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(2),
            child: _buildStepIndicator(),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: EdgeInsets.only(bottom: bottomInset > 0 ? 16 : 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        _buildStepContent(Theme.of(context)),
                        if (_isAnalyzing) ...[
                          const SizedBox(height: 24),
                          const ShimmerLoader(),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              if (_currentStep != 0)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    border: Border(top: BorderSide(color: AppTheme.border)),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isAnalyzing || !canContinue
                          ? null
                          : () {
                              HapticFeedback.lightImpact();
                              _onContinue();
                            },
                      child: Text(
                        _isAnalyzing
                            ? 'Analyzing...'
                            : (isLastStep ? 'Analyze My Problem' : 'Continue'),
                      ),
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
