-- Migration: 002_add_connected_id
-- Adds connected_id to forms_builder.forms to reference the application using this form.
-- Created: 2026-03-19

ALTER TABLE forms_builder.forms
  ADD COLUMN IF NOT EXISTS connected_id UUID NULL;

COMMENT ON COLUMN forms_builder.forms.connected_id IS
  'Foreign key reference to the application (or tenant) that owns/uses this form.';

CREATE INDEX IF NOT EXISTS idx_forms_connected_id
  ON forms_builder.forms (connected_id);
