import 'dart:convert';
import 'form_field_model.dart';

class FormDefinitionModel {
  String name;
  String code;
  String price;
  String description;
  String notes;
  bool isActive;
  bool isPublic;
  int retentionYears;
  int retentionMonths;
  List<FormFieldModel> fields;

  FormDefinitionModel({
    this.name = '',
    this.code = '',
    this.price = '',
    this.description = '',
    this.notes = '',
    this.isActive = false,
    this.isPublic = false,
    this.retentionYears = 0,
    this.retentionMonths = 1,
    List<FormFieldModel>? fields,
  }) : fields = fields ?? [];

  Map<String, dynamic> toJson() {
    return {
      'form_name': name,
      'form_code': code,
      'form_price': price,
      'description': description,
      'notes': notes,
      'is_active': isActive,
      'is_public': isPublic,
      'retention': {
        'years': retentionYears,
        'months': retentionMonths,
      },
      'fields': fields.map((f) => f.toJson()).toList(),
    };
  }

  String toPrettyJson() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(toJson());
  }
}
