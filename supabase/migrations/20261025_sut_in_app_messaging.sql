-- SUT in-app messaging migration (apply in Supabase SQL Editor as project owner).
-- Does not alter or delete existing tables/data.
create table if not exists public.sut_messages (
  id uuid primary key default gen_random_uuid(),
  sender_id uuid not null references auth.users(id) on delete restrict,
  recipient_id uuid not null references auth.users(id) on delete cascade,
  title text not null default 'SUT Announcement',
  body text not null check (char_length(body) between 1 and 5000),
  channel text not null default 'in_app' check (channel = 'in_app'),
  status text not null default 'sent' check (status in ('sent','read','failed')),
  created_at timestamptz not null default now(),
  read_at timestamptz
);
create index if not exists sut_messages_recipient_created_idx
  on public.sut_messages (recipient_id, created_at desc);

alter table public.sut_messages enable row level security;

-- Admins can create messages only when their role is stored server-side in user_roles.
drop policy if exists sut_messages_admin_insert on public.sut_messages;
create policy sut_messages_admin_insert on public.sut_messages
  for insert to authenticated
  with check (
    sender_id = auth.uid()
    and exists (
      select 1 from public.user_roles ur
      where ur.user_id = auth.uid()
        and ur.role in ('admin','superadmin')
    )
  );

-- Recipients can read only their own inbox. Admins can inspect messages for support/audit.
drop policy if exists sut_messages_recipient_or_admin_select on public.sut_messages;
create policy sut_messages_recipient_or_admin_select on public.sut_messages
  for select to authenticated
  using (
    recipient_id = auth.uid()
    or exists (
      select 1 from public.user_roles ur
      where ur.user_id = auth.uid()
        and ur.role in ('admin','superadmin')
    )
  );

-- Recipients can mark their own messages read; they cannot change body/sender/recipient.
drop policy if exists sut_messages_recipient_update_read on public.sut_messages;
create policy sut_messages_recipient_update_read on public.sut_messages
  for update to authenticated
  using (recipient_id = auth.uid())
  with check (recipient_id = auth.uid());

grant select, insert on public.sut_messages to authenticated;
grant update (read_at) on public.sut_messages to authenticated;
comment on table public.sut_messages is 'SUT in-app inbox messages. Apply this migration before using Admin Console in-app announcements.';
