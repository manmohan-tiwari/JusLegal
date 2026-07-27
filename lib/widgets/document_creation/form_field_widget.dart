import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/config/theme_config.dart';
import '../../models/form_field_model.dart';

class FormFieldWidget extends StatelessWidget {
  final FormFieldModel field;
  final String value;
  final String? error;
  final ValueChanged<String> onChanged;

  const FormFieldWidget({
    super.key,
    required this.field,
    required this.value,
    required this.onChanged,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: field.label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.primaryNavy,
                  fontWeight: FontWeight.w600,
                ),
            children: field.required
                ? [
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(color: Colors.red),
                    )
                  ]
                : [],
          ),
        ),
        const SizedBox(height: 6),
        if (field.type == FormFieldType.dropdown)
          _buildDropdown(context)
        else if (field.type == FormFieldType.checkbox)
          _buildCheckbox(context)
        else
          _buildTextField(context),
        if (error != null) ...[
          const SizedBox(height: 4),
          Text(
            error!,
            style: const TextStyle(color: Colors.red, fontSize: 11),
          ),
        ],
      ],
    );
  }

  Widget _buildTextField(BuildContext context) {
    return TextField(
      maxLines: field.maxLines,
      keyboardType: _keyboardType,
      inputFormatters: _inputFormatters,
      onChanged: onChanged,
      controller: TextEditingController.fromValue(
        TextEditingValue(
          text: value,
          selection: TextSelection.collapsed(offset: value.length),
        ),
      ),
      decoration: InputDecoration(
        hintText: field.hint,
        hintStyle:
            TextStyle(color: AppColors.textSecondary, fontSize: 13),
        prefixText: field.prefix,
        prefixStyle: TextStyle(
            color: AppColors.primaryNavy, fontWeight: FontWeight.w600),
        filled: true,
        fillColor: AppColors.surface,
        errorText: error,
        errorStyle: const TextStyle(fontSize: 11),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: error != null ? Colors.red : AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: AppColors.trustBlue, width: 1.5),
        ),
        contentPadding: const EdgeInsets.all(12),
      ),
    );
  }

  Widget _buildDropdown(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value.isEmpty ? null : value,
      hint: Text(field.hint.isEmpty ? 'Select ${field.label}' : field.hint,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      items: field.options
          .map((o) => DropdownMenuItem(value: o, child: Text(o)))
          .toList(),
      onChanged: (v) => onChanged(v ?? ''),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surface,
        errorText: error,
        errorStyle: const TextStyle(fontSize: 11),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: error != null ? Colors.red : AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: AppColors.trustBlue, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }

  Widget _buildCheckbox(BuildContext context) {
    return CheckboxListTile(
      value: value == 'true',
      onChanged: (v) => onChanged((v ?? false).toString()),
      title: Text(field.hint,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.primaryNavy,
              )),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      activeColor: AppColors.trustBlue,
    );
  }

  TextInputType get _keyboardType {
    switch (field.type) {
      case FormFieldType.phone:
        return TextInputType.phone;
      case FormFieldType.email:
        return TextInputType.emailAddress;
      case FormFieldType.number:
        return TextInputType.number;
      case FormFieldType.textarea:
        return TextInputType.multiline;
      case FormFieldType.date:
        return TextInputType.datetime;
      default:
        return TextInputType.text;
    }
  }

  List<TextInputFormatter> get _inputFormatters {
    if (field.type == FormFieldType.phone ||
        field.type == FormFieldType.number) {
      return [FilteringTextInputFormatter.digitsOnly];
    }
    return [];
  }
}

