import 'dart:convert';

enum FieldType {
  label,
  text,
  multiline,
  number,
  radioButton,
  checkbox,
  dropdown,
  imageUpload,
  imageUploadCapture,
  wetSignature,
  goodsAndServices,
  datepicker,
}

extension FieldTypeLabel on FieldType {
  String get displayName {
    switch (this) {
      case FieldType.label:
        return 'Label';
      case FieldType.text:
        return 'Text';
      case FieldType.multiline:
        return 'Multi-line';
      case FieldType.number:
        return 'Number';
      case FieldType.radioButton:
        return 'Radio Button';
      case FieldType.checkbox:
        return 'Checkbox';
      case FieldType.dropdown:
        return 'Dropdown';
      case FieldType.imageUpload:
        return 'Image Upload';
      case FieldType.imageUploadCapture:
        return 'Image Upload /\nCapture';
      case FieldType.wetSignature:
        return 'Wet Signature';
      case FieldType.goodsAndServices:
        return 'Goods and\nServices';
      case FieldType.datepicker:
        return 'Datepicker';
    }
  }

  String get jsonKey {
    switch (this) {
      case FieldType.label:
        return 'label';
      case FieldType.text:
        return 'text';
      case FieldType.multiline:
        return 'multiline';
      case FieldType.number:
        return 'number';
      case FieldType.radioButton:
        return 'radio_button';
      case FieldType.checkbox:
        return 'checkbox';
      case FieldType.dropdown:
        return 'dropdown';
      case FieldType.imageUpload:
        return 'image_upload';
      case FieldType.imageUploadCapture:
        return 'image_upload_capture';
      case FieldType.wetSignature:
        return 'wet_signature';
      case FieldType.goodsAndServices:
        return 'goods_and_services';
      case FieldType.datepicker:
        return 'datepicker';
    }
  }

  static FieldType fromDisplayName(String name) {
    return FieldType.values.firstWhere(
      (t) => t.displayName == name,
      orElse: () => FieldType.text,
    );
  }

  bool get hasOptions =>
      this == FieldType.radioButton ||
      this == FieldType.checkbox ||
      this == FieldType.dropdown ||
      this == FieldType.goodsAndServices;
}

class FormFieldModel {
  final String id;
  FieldType type;
  String label;
  bool required;
  List<String> options;
  int order;

  FormFieldModel({
    required this.id,
    required this.type,
    required this.label,
    this.required = false,
    List<String>? options,
    required this.order,
  }) : options = options ?? _defaultOptions(type);

  static List<String> _defaultOptions(FieldType type) {
    if (type.hasOptions) {
      return ['Option 1', 'Option 2', 'Option 3'];
    }
    return [];
  }

  FormFieldModel copyWith({
    String? label,
    bool? required,
    List<String>? options,
    int? order,
  }) {
    return FormFieldModel(
      id: id,
      type: type,
      label: label ?? this.label,
      required: required ?? this.required,
      options: options ?? List.from(this.options),
      order: order ?? this.order,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'id': id,
      'order': order,
      'type': type.jsonKey,
      'label': label,
      'required': required,
    };
    if (type.hasOptions && options.isNotEmpty) {
      map['options'] = options;
    }
    return map;
  }

  @override
  String toString() => jsonEncode(toJson());
}
