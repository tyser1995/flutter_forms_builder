import 'package:flutter/material.dart';
import '../models/form_field_model.dart';

class EditFieldDialog extends StatefulWidget {
  final FormFieldModel field;

  const EditFieldDialog({super.key, required this.field});

  @override
  State<EditFieldDialog> createState() => _EditFieldDialogState();
}

class _EditFieldDialogState extends State<EditFieldDialog> {
  late TextEditingController _labelController;
  late bool _required;
  late List<String> _options;
  final List<TextEditingController> _optionControllers = [];

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.field.label);
    _required = widget.field.required;
    _options = List.from(widget.field.options);
    for (final opt in _options) {
      _optionControllers.add(TextEditingController(text: opt));
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    for (final c in _optionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addOption() {
    setState(() {
      _options.add('Option ${_options.length + 1}');
      _optionControllers.add(
        TextEditingController(text: 'Option ${_options.length}'),
      );
    });
  }

  void _removeOption(int index) {
    setState(() {
      _options.removeAt(index);
      _optionControllers[index].dispose();
      _optionControllers.removeAt(index);
    });
  }

  FormFieldModel _buildResult() {
    final updatedOptions = _optionControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();
    return widget.field.copyWith(
      label: _labelController.text.trim().isEmpty ? widget.field.label : _labelController.text.trim(),
      required: _required,
      options: updatedOptions,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(24, 18, 16, 18),
              color: const Color(0xFF1E3A8A),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Edit Field',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Type: ${widget.field.type.jsonKey.replaceAll('_', ' ')}',
                          style: const TextStyle(color: Colors.white60, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.close, color: Colors.white70, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            // Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _labelController,
                      decoration: const InputDecoration(
                        labelText: 'Field Label',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (widget.field.type != FieldType.label)
                      CheckboxListTile(
                        title: const Text(
                          'Required field',
                          style: TextStyle(color: Colors.black87),
                        ),
                        value: _required,
                        onChanged: (v) => setState(() => _required = v ?? false),
                        contentPadding: EdgeInsets.zero,
                      ),
                    if (widget.field.type.hasOptions) ...[
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Options',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          TextButton.icon(
                            onPressed: _addOption,
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Add option'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ..._optionControllers.asMap().entries.map((entry) {
                        final i = entry.key;
                        final controller = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: controller,
                                  decoration: InputDecoration(
                                    labelText: 'Option ${i + 1}',
                                    border: const OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                onPressed: _options.length > 1 ? () => _removeOption(i) : null,
                                tooltip: 'Remove option',
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF374151),
                            side: const BorderSide(color: Color(0xFFD1D5DB)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(_buildResult()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A8A),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Save'),
                        ),
                      ],
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
