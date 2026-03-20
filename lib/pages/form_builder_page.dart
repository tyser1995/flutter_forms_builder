import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../models/form_field_model.dart';
import '../models/form_definition_model.dart';
import '../widgets/edit_field_dialog.dart';
import '../widgets/json_output_panel.dart';

const _uuid = Uuid();

class FormBuilderPage extends StatefulWidget {
  const FormBuilderPage({super.key});

  @override
  State<FormBuilderPage> createState() => _FormBuilderPageState();
}

class _FormBuilderPageState extends State<FormBuilderPage> {
  // Metadata controllers
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _connectedIdController = TextEditingController();

  bool _isActive = false;
  int _activeValue = 0;

  // Form fields
  final List<FormFieldModel> _fields = [];
  // Stable keys for ReorderableListView
  int _nextKey = 0;
  final List<int> _fieldKeys = [];

  // Available palette items
  static const List<FieldType> _palette = [
    FieldType.label,
    FieldType.text,
    FieldType.multiline,
    FieldType.number,
    FieldType.radioButton,
    FieldType.checkbox,
    FieldType.dropdown,
    FieldType.imageUpload,
    FieldType.imageUploadCapture,
    FieldType.wetSignature,
    FieldType.goodsAndServices,
    FieldType.datepicker,
  ];

  @override
  void initState() {
    super.initState();
    _connectedIdController.text = _uuid.v4();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _connectedIdController.dispose();
    super.dispose();
  }

  FormDefinitionModel _buildDefinition() {
    return FormDefinitionModel(
      name: _nameController.text,
      description: _descController.text,
      connectedId: _connectedIdController.text,
      isActive: _isActive,
      fields: _fields,
    );
  }

  String get _jsonOutput => _buildDefinition().toPrettyJson();

  void _addField(FieldType type) {
    setState(() {
      final field = FormFieldModel(
        id: 'field_${_uuid.v4().substring(0, 8)}',
        type: type,
        label: _defaultLabel(type),
        order: _fields.length,
      );
      _fields.add(field);
      _fieldKeys.add(_nextKey++);
    });
  }

  String _defaultLabel(FieldType type) {
    switch (type) {
      case FieldType.label:
        return 'Section Label';
      case FieldType.text:
        return 'Text Field';
      case FieldType.multiline:
        return 'Multi-line Field';
      case FieldType.number:
        return 'Number Field';
      case FieldType.radioButton:
        return 'Radio Button';
      case FieldType.checkbox:
        return 'Checkbox';
      case FieldType.dropdown:
        return 'Dropdown';
      case FieldType.imageUpload:
        return 'Image Upload';
      case FieldType.imageUploadCapture:
        return 'Image Upload / Capture';
      case FieldType.wetSignature:
        return 'Wet Signature';
      case FieldType.goodsAndServices:
        return 'Goods and Services';
      case FieldType.datepicker:
        return 'Date Picker';
    }
  }

  void _deleteField(int index) {
    setState(() {
      _fields.removeAt(index);
      _fieldKeys.removeAt(index);
      for (int i = 0; i < _fields.length; i++) {
        _fields[i] = _fields[i].copyWith(order: i);
      }
    });
  }

  void _moveUp(int index) {
    if (index > 0) {
      setState(() {
        final f = _fields.removeAt(index);
        _fields.insert(index - 1, f);
        final k = _fieldKeys.removeAt(index);
        _fieldKeys.insert(index - 1, k);
        for (int i = 0; i < _fields.length; i++) {
          _fields[i] = _fields[i].copyWith(order: i);
        }
      });
    }
  }

  void _moveDown(int index) {
    if (index < _fields.length - 1) {
      setState(() {
        final f = _fields.removeAt(index);
        _fields.insert(index + 1, f);
        final k = _fieldKeys.removeAt(index);
        _fieldKeys.insert(index + 1, k);
        for (int i = 0; i < _fields.length; i++) {
          _fields[i] = _fields[i].copyWith(order: i);
        }
      });
    }
  }

  void _reorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final f = _fields.removeAt(oldIndex);
      _fields.insert(newIndex, f);
      final k = _fieldKeys.removeAt(oldIndex);
      _fieldKeys.insert(newIndex, k);
      for (int i = 0; i < _fields.length; i++) {
        _fields[i] = _fields[i].copyWith(order: i);
      }
    });
  }

  Future<void> _editField(int index) async {
    final result = await showDialog<FormFieldModel>(
      context: context,
      builder: (_) => EditFieldDialog(field: _fields[index]),
    );
    if (result != null) {
      setState(() => _fields[index] = result.copyWith(order: index));
    }
  }

  void _resetForm() {
    setState(() {
      _nameController.clear();
      _descController.clear();
      _connectedIdController.text = _uuid.v4();
      _isActive = false;
      _activeValue = 0;
      _fields.clear();
      _fieldKeys.clear();
    });
  }

  // ────────────────────────── BUILD ──────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        title: const Text(
          'Flutter Forms Builder',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton.icon(
            onPressed: _resetForm,
            icon: const Icon(Icons.refresh, color: Colors.white70),
            label: const Text('Reset', style: TextStyle(color: Colors.white70)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPageHeader(),
              const SizedBox(height: 16),
              _buildMetaRow(),
              const Divider(height: 48),
              _buildFormBuilderSection(),
            ],
          ),
        ),
      ),
    );
  }

  // ────────────────────── Header ──────────────────────────────

  Widget _buildPageHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add Form',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E3A8A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Build a form by dragging field types into the canvas. Configure each field and export the definition as JSON.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }

  // ────────────────────── Metadata Row ─────────────────────────

  Widget _buildMetaRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 1, child: _buildLeftMeta()),
        const SizedBox(width: 40),
        Expanded(flex: 1, child: _buildRightMeta()),
      ],
    );
  }

  Widget _buildLeftMeta() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _metaField('Name', _nameController),
        _buildConnectedIdField(),
        _textAreaField('Description', _descController),
      ],
    );
  }

  Widget _buildConnectedIdField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Connected ID',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _connectedIdController,
                  readOnly: true,
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Auto-generated UUID',
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Tooltip(
                message: 'Copy ID',
                child: IconButton(
                  icon: const Icon(Icons.copy, size: 18),
                  color: const Color(0xFF1E3A8A),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _connectedIdController.text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Connected ID copied to clipboard'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ),
              Tooltip(
                message: 'Regenerate ID',
                child: IconButton(
                  icon: const Icon(Icons.refresh, size: 18),
                  color: const Color(0xFF1E3A8A),
                  onPressed: () {
                    setState(() => _connectedIdController.text = _uuid.v4());
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Use this ID in your other application to link to this form.',
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _metaField(String label, TextEditingController controller, {String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              isDense: true,
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _textAreaField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            maxLines: 5,
            minLines: 5,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightMeta() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildActiveRadio(),
      ],
    );
  }

  Widget _buildActiveRadio() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Set this form active?',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
            ),
            const SizedBox(width: 6),
            Icon(Icons.info_outline, size: 16, color: Colors.grey[500]),
          ],
        ),
        RadioMenuButton<int>(
          value: 0,
          groupValue: _activeValue,
          onChanged: (v) => setState(() {
            _isActive = false;
            _activeValue = 0;
          }),
          child: Text('No', style: Theme.of(context).textTheme.bodySmall),
        ),
        RadioMenuButton<int>(
          value: 1,
          groupValue: _activeValue,
          onChanged: (v) => setState(() {
            _isActive = true;
            _activeValue = 1;
          }),
          child: Text('Yes', style: Theme.of(context).textTheme.bodySmall),
        ),
      ],
    );
  }

  // ────────────────────── Form Builder Section ─────────────────

  Widget _buildFormBuilderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Form Builder',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Drag field types from the palette onto the canvas, or tap them to add. Reorder by dragging the handle.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPalette(),
            const SizedBox(width: 24),
            Expanded(child: _buildCanvas()),
            const SizedBox(width: 24),
            SizedBox(width: 320, height: 600, child: JsonOutputPanel(json: _jsonOutput)),
          ],
        ),
        const SizedBox(height: 32),
        _buildFormActions(),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildFormActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        OutlinedButton(
          onPressed: _resetForm,
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF374151),
            side: const BorderSide(color: Color(0xFFD1D5DB)),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 16),
        OutlinedButton.icon(
          onPressed: _showPreviewDialog,
          icon: const Icon(Icons.visibility_outlined, size: 18),
          label: const Text('Preview'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF1E3A8A),
            side: const BorderSide(color: Color(0xFF1E3A8A)),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: _submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E3A8A),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Submit Form'),
        ),
      ],
    );
  }

  void _showPreviewDialog() {
    final formName = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()
        : 'Untitled Form';
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560, maxHeight: 700),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: const BoxDecoration(
                  color: Color(0xFF1E3A8A),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.visibility_outlined, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        formName,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(ctx).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: _fields.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(
                          child: Text(
                            'No fields added yet.',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _fields.map(_buildFieldPreview).toList(),
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Close'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a form name.')),
      );
      return;
    }
    if (_fields.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one field.')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Form submitted successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  // ────────────────────── Palette ──────────────────────────────

  Widget _buildPalette() {
    return SizedBox(
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fields',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          ..._palette.map(_buildPaletteItem),
        ],
      ),
    );
  }

  Widget _buildPaletteItem(FieldType type) {
    final label = type.displayName.replaceAll('\n', ' / ');
    final tile = Container(
      width: 160,
      height: 36,
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 2, offset: const Offset(0, 1)),
        ],
      ),
      child: Center(
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
          textAlign: TextAlign.center,
          maxLines: 2,
        ),
      ),
    );

    return Draggable<FieldType>(
      data: type,
      feedback: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 160,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFF1E3A8A).withValues(alpha: 0.5)),
          ),
          child: Center(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF1E3A8A)),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.4, child: tile),
      child: GestureDetector(
        onTap: () => _addField(type),
        child: MouseRegion(
          cursor: SystemMouseCursors.grab,
          child: tile,
        ),
      ),
    );
  }

  // ────────────────────── Canvas ────────────────────────────────

  Widget _buildCanvas() {
    return DragTarget<FieldType>(
      onAcceptWithDetails: (details) => _addField(details.data),
      builder: (context, candidateData, _) {
        final isHovering = candidateData.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          constraints: const BoxConstraints(minHeight: 500),
          decoration: BoxDecoration(
            color: isHovering ? const Color(0xFF1E3A8A).withValues(alpha: 0.05) : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isHovering ? const Color(0xFF1E3A8A).withValues(alpha: 0.4) : Colors.grey[300]!,
              width: isHovering ? 2 : 1,
            ),
          ),
          child: _fields.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.drag_indicator, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text(
                          isHovering ? 'Drop here' : 'Drag items here or tap to add',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ReorderableListView.builder(
                    buildDefaultDragHandles: false,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    onReorder: _reorder,
                    itemCount: _fields.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        key: ValueKey(_fieldKeys[index]),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: _buildFieldRow(index),
                      );
                    },
                  ),
                ),
        );
      },
    );
  }

  Widget _buildFieldRow(int index) {
    final field = _fields[index];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 3, offset: const Offset(0, 1)),
        ],
      ),
      child: Row(
        children: [
          // Drag handle
          ReorderableDragStartListener(
            index: index,
            child: MouseRegion(
              cursor: SystemMouseCursors.grab,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                child: Icon(Icons.drag_handle, color: Colors.grey[400], size: 20),
              ),
            ),
          ),
          // Field preview
          Expanded(child: _buildFieldPreview(field)),
          // Controls
          _buildFieldControls(index),
        ],
      ),
    );
  }

  Widget _buildFieldPreview(FormFieldModel field) {
    switch (field.type) {
      case FieldType.label:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(field.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        );

      case FieldType.text:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _previewLabel(field),
              const SizedBox(height: 4),
              _previewTextField('Enter ${field.label}'),
            ],
          ),
        );

      case FieldType.multiline:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _previewLabel(field),
              const SizedBox(height: 4),
              Container(
                height: 60,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Text(
                    'Enter multi-line text...',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        );

      case FieldType.number:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _previewLabel(field),
              const SizedBox(height: 4),
              _previewTextField('0'),
            ],
          ),
        );

      case FieldType.radioButton:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _previewLabel(field),
              ...field.options.take(3).map(
                (opt) => Row(
                  children: [
                    const SizedBox(width: 4),
                    Icon(Icons.radio_button_unchecked, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 6),
                    Text(opt, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                  ],
                ),
              ),
            ],
          ),
        );

      case FieldType.checkbox:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(Icons.check_box_outline_blank, size: 16, color: Colors.grey[500]),
              const SizedBox(width: 6),
              Text(field.label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        );

      case FieldType.dropdown:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _previewLabel(field),
              const SizedBox(height: 4),
              Container(
                height: 32,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.white,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        field.options.isNotEmpty ? field.options.first : 'Select...',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                    Icon(Icons.arrow_drop_down, color: Colors.grey[500]),
                  ],
                ),
              ),
            ],
          ),
        );

      case FieldType.imageUpload:
      case FieldType.imageUploadCapture:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _previewLabel(field),
              const SizedBox(height: 4),
              Row(
                children: [
                  _miniButton('Upload'),
                  const SizedBox(width: 8),
                  Text('No file selected', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                ],
              ),
            ],
          ),
        );

      case FieldType.wetSignature:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _previewLabel(field),
              const SizedBox(height: 4),
              Container(
                height: 48,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    'Sign here',
                    style: TextStyle(fontSize: 11, color: Colors.grey[400], fontStyle: FontStyle.italic),
                  ),
                ),
              ),
            ],
          ),
        );

      case FieldType.goodsAndServices:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _previewLabel(field),
              ...field.options.take(2).map(
                (item) => Row(
                  children: [
                    Icon(Icons.check_box_outline_blank, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 6),
                    Text(item, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                    const SizedBox(width: 6),
                    Text('x0', style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                  ],
                ),
              ),
            ],
          ),
        );

      case FieldType.datepicker:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _previewLabel(field),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(child: _previewTextField('YYYY-MM-DD')),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(Icons.calendar_month_outlined, size: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        );
    }
  }

  Widget _previewLabel(FormFieldModel field) {
    return Row(
      children: [
        Text(field.label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        if (field.required)
          const Text(' *', style: TextStyle(color: Colors.red, fontSize: 12)),
      ],
    );
  }

  Widget _previewTextField(String hint) {
    return Container(
      height: 28,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.centerLeft,
      child: Text(hint, style: TextStyle(fontSize: 11, color: Colors.grey[400])),
    );
  }

  Widget _miniButton(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A8A),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
    );
  }

  Widget _buildFieldControls(int index) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _controlBtn(Icons.edit_square, 'Edit', () => _editField(index)),
          const SizedBox(width: 4),
          _controlBtn(Icons.arrow_upward, 'Move up', () => _moveUp(index)),
          const SizedBox(width: 4),
          _controlBtn(Icons.arrow_downward, 'Move down', () => _moveDown(index)),
          const SizedBox(width: 4),
          _controlBtn(Icons.delete_forever_outlined, 'Delete', () => _deleteField(index), isDelete: true),
        ],
      ),
    );
  }

  Widget _controlBtn(IconData icon, String tooltip, VoidCallback onTap, {bool isDelete = false}) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isDelete ? Colors.red : null,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: isDelete ? Colors.red : Colors.grey[300]!),
          ),
          child: Icon(
            icon,
            size: 15,
            color: isDelete ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}
