import 'dart:convert';
import 'form_field_model.dart';

class FormDefinitionModel {
  String name;
  String description;
  String connectedId;
  bool isActive;
  List<FormFieldModel> fields;

  FormDefinitionModel({
    this.name = '',
    this.description = '',
    this.connectedId = '',
    this.isActive = false,
    List<FormFieldModel>? fields,
  }) : fields = fields ?? [];

  Map<String, dynamic> toJson() {
    return {
      'scheme_name': 'forms_builder',
      'name': name,
      'description': description,
      'connected_id': connectedId.trim().isEmpty ? null : connectedId.trim(),
      'status': isActive ? 'active' : 'inactive',
      'builder': fields.map((f) => f.toJson()).toList(),
    };
  }

  String toPrettyJson() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(toJson());
  }
}
