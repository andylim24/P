import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Compact text field for forms
class CompactTextField extends StatelessWidget {
  final String hint;
  final String? label;
  final double? width;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final String initialValue;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final VoidCallback? onTap;
  final int maxLines;

  const CompactTextField({
    Key? key,
    required this.hint,
    this.label,
    this.width,
    this.validator,
    this.keyboardType,
    this.initialValue = '',
    this.onChanged,
    this.readOnly = false,
    this.onTap,
    this.maxLines = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TextFormField(
        initialValue: initialValue,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          labelText: label ?? hint,
          hintText: hint,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
        validator: validator,
        onChanged: onChanged,
      ),
    );
  }
}

/// Compact dropdown for forms
class CompactDropdown<T> extends StatelessWidget {
  final String label;
  final List<T> items;
  final T? value;
  final ValueChanged<T?> onChanged;
  final double? width;

  const CompactDropdown({
    Key? key,
    required this.label,
    required this.items,
    required this.value,
    required this.onChanged,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Type-safe check to prevent dropdown assertion error
    final T? safeValue = (value != null && items.contains(value)) ? value : null;

    return SizedBox(
      width: width,
      child: DropdownButtonFormField<T>(
        value: safeValue,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
        items: items.map((e) {
          return DropdownMenuItem<T>(
            value: e,
            child: Text(e.toString(), style: const TextStyle(fontSize: 13)),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}

/// Section title widget
class FormSectionTitle extends StatelessWidget {
  final String text;

  const FormSectionTitle(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        text,
        style: GoogleFonts.bebasNeue(
          fontSize: 18,
          color: Colors.blue.shade700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Language proficiency row
class LanguageRow extends StatelessWidget {
  final String language;
  final Map<String, bool> proficiency;
  final ValueChanged<Map<String, bool>> onChanged;

  const LanguageRow({
    Key? key,
    required this.language,
    required this.proficiency,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(language, style: const TextStyle(fontSize: 13)),
          ),
          _buildCheckbox('read', 'Read'),
          _buildCheckbox('write', 'Write'),
          _buildCheckbox('speak', 'Speak'),
          _buildCheckbox('understand', 'Understand'),
        ],
      ),
    );
  }

  Widget _buildCheckbox(String key, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: proficiency[key] ?? false,
            onChanged: (v) {
              final newMap = Map<String, bool>.from(proficiency);
              newMap[key] = v ?? false;
              onChanged(newMap);
            },
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: 2),
        Text(label, style: const TextStyle(fontSize: 11)),
        const SizedBox(width: 8),
      ],
    );
  }
}

/// Employment status radio option
class EmploymentRadio extends StatelessWidget {
  final String title;
  final String value;
  final String? groupValue;
  final ValueChanged<String?> onChanged;

  const EmploymentRadio({
    Key? key,
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Radio<String>(
                value: value,
                groupValue: groupValue,
                onChanged: onChanged,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 4),
            Text(title, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

/// Skill checkbox
class SkillCheckbox extends StatelessWidget {
  final String skill;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SkillCheckbox({
    Key? key,
    required this.skill,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: Checkbox(
                  value: value,
                  onChanged: (v) => onChanged(v ?? false),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  skill,
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Form header with logo
class JobseekerFormHeader extends StatelessWidget {
  final String subtitle;

  const JobseekerFormHeader({Key? key, this.subtitle = ''}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/images/logo.png', width: 70, height: 70),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PESO MAKATI',
              style: GoogleFonts.bebasNeue(fontSize: 24, color: Colors.blue.shade700),
            ),
            Text(
              subtitle.isNotEmpty ? subtitle : 'JOBSEEKER REGISTRATION FORM',
              style: GoogleFonts.bebasNeue(fontSize: 12, color: Colors.blue.shade700),
            ),
          ],
        ),
      ],
    );
  }
}

/// Labeled checkbox row
class LabeledCheckbox extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Widget? trailing;

  const LabeledCheckbox({
    Key? key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: value,
            onChanged: (v) => onChanged(v ?? false),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 13)),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          trailing!,
        ],
      ],
    );
  }
}