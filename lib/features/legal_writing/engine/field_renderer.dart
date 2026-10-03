import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:juslegal/core/core.dart';
import '../models/form_field_definition.dart';

class FieldRenderer extends StatefulWidget {
  final FormFieldDefinition field;
  final dynamic value;
  final String? error;
  final ValueChanged<dynamic> onChanged;

  const FieldRenderer({
    super.key,
    required this.field,
    required this.value,
    this.error,
    required this.onChanged,
  });

  @override
  State<FieldRenderer> createState() => _FieldRendererState();
}

class _FieldRendererState extends State<FieldRenderer> {
  late TextEditingController _textController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _textController =
        TextEditingController(text: widget.value?.toString() ?? '');
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(FieldRenderer oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newText = widget.value?.toString() ?? '';
    if (_textController.text != newText) {
      _textController.text = newText;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 13),
      filled: true,
      fillColor: AppColors.surface,
      errorText: widget.error,
      errorStyle: const TextStyle(fontSize: 11),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.legalGold, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade300),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      contentPadding: const EdgeInsets.all(12),
    );
  }

  bool get _isTextarea {
    final fieldLower = widget.field.id.toLowerCase();
    return widget.field.type == FormFieldType.textarea ||
        fieldLower.contains('detail') ||
        fieldLower.contains('description') ||
        fieldLower.contains('scope') ||
        fieldLower.contains('term') ||
        fieldLower.contains('clause') ||
        fieldLower.contains('evidence') ||
        fieldLower.contains('content') ||
        fieldLower.contains('facts');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.field.label + (widget.field.required ? ' *' : ''),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryNavy,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        _buildFieldInput(),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _buildFieldInput() {
    switch (widget.field.type) {
      case FormFieldType.text:
        return TextField(
          controller: _textController,
          focusNode: _focusNode,
          onChanged: (v) => widget.onChanged(v),
          readOnly: widget.field.isReadOnly,
          decoration:
              _decoration(widget.field.hint ?? 'Enter ${widget.field.label}'),
          maxLines: 1,
        );
      case FormFieldType.textarea:
        return TextField(
          controller: _textController,
          focusNode: _focusNode,
          onChanged: (v) => widget.onChanged(v),
          readOnly: widget.field.isReadOnly,
          maxLines: _isTextarea ? 3 : 1,
          decoration:
              _decoration(widget.field.hint ?? 'Enter ${widget.field.label}'),
        );
      case FormFieldType.number:
        return TextField(
          controller: _textController,
          focusNode: _focusNode,
          keyboardType: TextInputType.number,
          onChanged: (v) => widget.onChanged(v),
          readOnly: widget.field.isReadOnly,
          decoration: _decoration(widget.field.hint ?? 'Enter number'),
        );
      case FormFieldType.currency:
        return TextField(
          controller: _textController,
          focusNode: _focusNode,
          keyboardType: TextInputType.number,
          onChanged: (v) => widget.onChanged(v),
          readOnly: widget.field.isReadOnly,
          decoration: _decoration(widget.field.hint ?? 'Enter amount').copyWith(
            prefixText: '₹ ',
            prefixStyle: TextStyle(color: AppColors.textSecondary),
          ),
        );
      case FormFieldType.date:
        return _DateField(
          controller: _textController,
          decoration: _decoration(widget.field.hint ?? 'Select date'),
          onDateSelected: (date) {
            final formatted = DateFormat('dd MMM yyyy').format(date);
            _textController.text = formatted;
            widget.onChanged(formatted);
          },
          readOnly: widget.field.isReadOnly,
        );
      case FormFieldType.dropdown:
        final options = widget.field.options ?? [];
        final val = widget.value?.toString();
        final selectedValue =
            options.any((opt) => opt.value == val) ? val : null;
        return DropdownButtonFormField<String>(
          initialValue: selectedValue,
          onChanged: (v) => widget.onChanged(v),
          items: options.map((opt) {
            return DropdownMenuItem<String>(
              value: opt.value,
              child: Text(opt.label),
            );
          }).toList(),
          decoration: _decoration(widget.field.hint ?? 'Select option'),
        );
      case FormFieldType.radio:
        final options = widget.field.options ?? [];
        final groupValue = widget.value?.toString();
        return Column(
          children: options.map((opt) {
            // ignore: deprecated_member_use
            return RadioListTile<String>(
              title: Text(opt.label),
              value: opt.value,
              // ignore: deprecated_member_use
              groupValue: groupValue,
              // ignore: deprecated_member_use
              onChanged: (v) => widget.onChanged(v),
              dense: true,
              contentPadding: EdgeInsets.zero,
            );
          }).toList(),
        );
      case FormFieldType.multiSelect:
        final options = widget.field.options ?? [];
        final current = (widget.value as List?)?.cast<String>() ?? <String>[];
        return Column(
          children: options.map((opt) {
            final checked = current.contains(opt.value);
            return CheckboxListTile(
              title: Text(opt.label),
              value: checked,
              onChanged: (v) {
                final updated = List<String>.from(current);
                if (v == true) {
                  updated.add(opt.value);
                } else {
                  updated.remove(opt.value);
                }
                widget.onChanged(updated);
              },
              activeColor: AppColors.trustBlue,
              dense: true,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            );
          }).toList(),
        );
      case FormFieldType.toggle:
        final current = widget.value == true;
        return SwitchListTile(
          title: Text(widget.field.label),
          value: current,
          onChanged: (v) => widget.onChanged(v),
          activeThumbColor: AppColors.trustBlue,
          dense: true,
          contentPadding: EdgeInsets.zero,
        );
    }
  }
}

class _DateField extends StatelessWidget {
  final TextEditingController controller;
  final InputDecoration decoration;
  final ValueChanged<DateTime> onDateSelected;
  final bool readOnly;

  const _DateField({
    required this.controller,
    required this.decoration,
    required this.onDateSelected,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: readOnly
          ? null
          : () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime(2100),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: AppColors.trustBlue,
                        onPrimary: Colors.white,
                        surface: Colors.white,
                        onSurface: AppColors.primaryNavy,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                onDateSelected(picked);
              }
            },
      decoration: decoration.copyWith(
        suffixIcon:
            Icon(Icons.calendar_month_outlined, color: AppColors.textSecondary),
      ),
    );
  }
}
