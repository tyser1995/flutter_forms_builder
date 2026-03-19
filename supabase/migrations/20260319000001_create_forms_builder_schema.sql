-- Migration: 001_create_forms_builder_schema
-- Schema: forms_builder
-- Created: 2026-03-19

CREATE SCHEMA IF NOT EXISTS forms_builder;

CREATE TABLE IF NOT EXISTS forms_builder.forms (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  name        VARCHAR(255) NOT NULL,
  description TEXT,
  status      VARCHAR(20)  NOT NULL DEFAULT 'inactive' CHECK (status IN ('active', 'inactive')),
  builder     JSONB        NOT NULL DEFAULT '[]'::jsonb,
  created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

-- Auto-update updated_at on row change
CREATE OR REPLACE FUNCTION forms_builder.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_forms_updated_at
  BEFORE UPDATE ON forms_builder.forms
  FOR EACH ROW EXECUTE FUNCTION forms_builder.set_updated_at();

-- Indexes
CREATE INDEX IF NOT EXISTS idx_forms_status ON forms_builder.forms (status);
CREATE INDEX IF NOT EXISTS idx_forms_builder_gin ON forms_builder.forms USING GIN (builder);
