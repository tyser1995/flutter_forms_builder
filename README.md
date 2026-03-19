# Flutter Forms Builder

A drag-and-drop form builder built with Flutter that exports form definitions as JSON.

## Features

- **Drag-and-drop canvas** — drag field types from the palette onto the canvas, or tap to add
- **Reorderable fields** — drag the handle to reorder, or use the up/down arrow buttons
- **Field editor** — configure each field's label, required flag, and options via an edit dialog
- **Live JSON output** — the form definition updates in real time as you build
- **Copy to clipboard** — one-click copy of the generated JSON
- **Submit & Cancel** — validates required inputs before submitting

## Form Metadata

| Field | Type | Description |
|---|---|---|
| Name | `VARCHAR(255)` | Name of the form |
| Connected ID | `UUID` | ID of the application using this form |
| Description | `TEXT` | Long-form description of the form |
| Status | `VARCHAR(20)` | `active` or `inactive` |

## Supported Field Types

| Type | Description |
|---|---|
| Label | Static text / section header |
| Text | Single-line text input |
| Multi-line | Resizable multi-line text area |
| Number | Numeric input |
| Radio Button | Single-choice selection with configurable options |
| Checkbox | Boolean toggle |
| Dropdown | Single-choice dropdown with configurable options |
| Image Upload | File upload field |
| Image Upload / Capture | File upload with camera capture option |
| Wet Signature | Signature pad field |
| Goods and Services | Item list with quantities |
| Datepicker | Date selection with calendar picker |

## JSON Output Format

```json
{
  "scheme_name": "forms_builder",
  "name": "My Form",
  "description": "Long-form description of the form.",
  "connected_id": "550e8400-e29b-41d4-a716-446655440000",
  "status": "active",
  "builder": [
    {
      "id": "field_abc123",
      "order": 0,
      "type": "text",
      "label": "Full Name",
      "required": true
    },
    {
      "id": "field_def456",
      "order": 1,
      "type": "dropdown",
      "label": "Status",
      "required": false,
      "options": ["Active", "Inactive", "Pending"]
    }
  ]
}
```

## Database

### Schema: `forms_builder`

#### Table: `forms_builder.forms`

| Column | Type | Constraints | Description |
|---|---|---|---|
| `id` | `UUID` | `PRIMARY KEY` | Auto-generated identifier |
| `name` | `VARCHAR(255)` | `NOT NULL` | Form name |
| `description` | `TEXT` | | Long-form description |
| `connected_id` | `UUID` | `NULL` | Reference to the consuming application |
| `status` | `VARCHAR(20)` | `NOT NULL DEFAULT 'inactive'` | `active` or `inactive` |
| `builder` | `JSONB` | `NOT NULL DEFAULT '[]'` | Field definitions |
| `created_at` | `TIMESTAMPTZ` | `NOT NULL DEFAULT NOW()` | Creation timestamp |
| `updated_at` | `TIMESTAMPTZ` | `NOT NULL DEFAULT NOW()` | Last update timestamp (auto-managed) |

### Migrations

| File | Description |
|---|---|
| `001_create_forms_builder_schema.sql` | Creates schema, `forms` table, `updated_at` trigger, and GIN index on `builder` |
| `002_add_connected_id.sql` | Adds `connected_id UUID NULL` column with index |

Run migrations in order:

```bash
psql -U <user> -d <database> -f migrations/001_create_forms_builder_schema.sql
psql -U <user> -d <database> -f migrations/002_add_connected_id.sql
```

## Getting Started

### Prerequisites

- Flutter SDK `>=3.0.0`
- Chrome (for web) or Windows desktop

### Run

```bash
# Web (Chrome)
flutter run -d chrome

# Windows desktop
flutter run -d windows
```

## Project Structure

```
flutter_forms_builder/
├── migrations/
│   ├── 001_create_forms_builder_schema.sql
│   └── 002_add_connected_id.sql
└── lib/
    ├── main.dart
    ├── models/
    │   ├── form_field_model.dart        # FieldType enum + FormFieldModel with toJson()
    │   └── form_definition_model.dart   # Form metadata + fields → toPrettyJson()
    ├── pages/
    │   └── form_builder_page.dart       # Main page: metadata panel, palette, canvas
    └── widgets/
        ├── edit_field_dialog.dart        # Dialog to configure field properties
        └── json_output_panel.dart        # Live JSON viewer with copy button
```
