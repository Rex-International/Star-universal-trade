-- SUT notification deletion: additive migration; preserves existing messages and data.
-- Apply in Supabase SQL Editor as project owner after the in-app messaging migration.
alter table public.sut_messages
  add column if not exists deleted_at timestamptz;

-- Recipients can soft-delete only their own inbox notification. The underlying
-- announcement/message row remains in the database and is not hard-deleted.
grant update (read_at, deleted_at) on public.sut_messages to authenticated;

comment on column public.sut_messages.deleted_at is
  'Recipient-specific inbox soft-delete timestamp; keeps the message row for audit/history.';
