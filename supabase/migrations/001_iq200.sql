create extension if not exists pgcrypto;

create table if not exists profiles(id uuid primary key references auth.users(id) on delete cascade,email text,display_name text,avatar_url text,phone text,is_seller boolean default false,created_at timestamptz default now());
create table if not exists stores(id uuid primary key default gen_random_uuid(),owner_uid uuid unique references profiles(id) on delete cascade,name text not null,slug text unique,description text,location text,phone text,social_links jsonb default '{}'::jsonb,created_at timestamptz default now());
create table if not exists products(id uuid primary key default gen_random_uuid(),store_id uuid references stores(id) on delete cascade,seller_id uuid references profiles(id) on delete cascade,title text not null,description text,price numeric not null check(price>=0),currency text not null default 'USD',category text,location text,image_url text,delivery_available boolean default false,delivery_status text default 'Not started',status text default 'active',created_at timestamptz default now());
create table if not exists product_media(id uuid primary key default gen_random_uuid(),product_id uuid references products(id) on delete cascade,url text not null,storage_path text,created_at timestamptz default now());
create table if not exists store_followers(store_id uuid references stores(id) on delete cascade,user_id uuid references profiles(id) on delete cascade,created_at timestamptz default now(),primary key(store_id,user_id));
create table if not exists notifications(id uuid primary key default gen_random_uuid(),user_id uuid references profiles(id) on delete cascade,type text,title text,message text,data jsonb default '{}'::jsonb,read boolean default false,created_at timestamptz default now());
create table if not exists public_orders(id uuid primary key default gen_random_uuid(),buyer_id uuid references profiles(id) on delete cascade,title text not null,description text not null,budget numeric not null,currency text not null,location text,contact_phone text,delivery_required boolean default false,status text default 'open',created_at timestamptz default now());
create table if not exists public_order_responses(id uuid primary key default gen_random_uuid(),public_order_id uuid references public_orders(id) on delete cascade,seller_id uuid references profiles(id) on delete cascade,offer_price numeric,currency text,message text,created_at timestamptz default now());
create table if not exists conversations(id uuid primary key default gen_random_uuid(),created_at timestamptz default now());
create table if not exists conversation_participants(conversation_id uuid references conversations(id) on delete cascade,user_id uuid references profiles(id) on delete cascade,primary key(conversation_id,user_id));
create table if not exists messages(id uuid primary key default gen_random_uuid(),conversation_id uuid references conversations(id) on delete cascade,sender_id uuid references profiles(id) on delete cascade,body text,image_url text,audio_url text,created_at timestamptz default now());
create table if not exists orders(id uuid primary key default gen_random_uuid(),buyer_id uuid references profiles(id),seller_id uuid references profiles(id),product_id uuid references products(id),quantity int default 1,price numeric,currency text,delivery_status text default 'Not started',created_at timestamptz default now());

alter table products add column if not exists seller_id uuid references profiles(id) on delete cascade;
alter table products add column if not exists location text;
alter table products add column if not exists image_url text;
alter table products add column if not exists delivery_available boolean default false;
alter table products add column if not exists delivery_status text default 'Not started';
alter table stores add column if not exists phone text;
alter table stores add column if not exists social_links jsonb default '{}'::jsonb;
alter table public_orders add column if not exists contact_phone text;
alter table public_orders add column if not exists delivery_required boolean default false;

insert into storage.buckets(id,name,public) values('media','media',true) on conflict(id) do update set public=true;

drop policy if exists media_public_read on storage.objects;
create policy media_public_read on storage.objects for select using(bucket_id='media');
drop policy if exists media_auth_insert on storage.objects;
create policy media_auth_insert on storage.objects for insert to authenticated with check(bucket_id='media' and (storage.foldername(name))[1]=auth.uid()::text);
drop policy if exists media_owner_update on storage.objects;
create policy media_owner_update on storage.objects for update to authenticated using(bucket_id='media' and owner_id=auth.uid()::text) with check(bucket_id='media' and owner_id=auth.uid()::text);
drop policy if exists media_owner_delete on storage.objects;
create policy media_owner_delete on storage.objects for delete to authenticated using(bucket_id='media' and owner_id=auth.uid()::text);

alter table profiles enable row level security; alter table stores enable row level security; alter table products enable row level security; alter table product_media enable row level security; alter table store_followers enable row level security; alter table notifications enable row level security; alter table public_orders enable row level security; alter table public_order_responses enable row level security; alter table conversations enable row level security; alter table conversation_participants enable row level security; alter table messages enable row level security; alter table orders enable row level security;

drop policy if exists profiles_public_select on profiles; create policy profiles_public_select on profiles for select using(true);
drop policy if exists profiles_self_insert on profiles; create policy profiles_self_insert on profiles for insert to authenticated with check(id=auth.uid());
drop policy if exists profiles_self_update on profiles; create policy profiles_self_update on profiles for update to authenticated using(id=auth.uid()) with check(id=auth.uid());
drop policy if exists stores_public_select on stores; create policy stores_public_select on stores for select using(true);
drop policy if exists stores_owner_write on stores; create policy stores_owner_write on stores for all to authenticated using(owner_uid=auth.uid()) with check(owner_uid=auth.uid());
drop policy if exists products_public_select on products; create policy products_public_select on products for select using(status='active' or seller_id=auth.uid());
drop policy if exists products_owner_write on products; create policy products_owner_write on products for all to authenticated using(seller_id=auth.uid()) with check(seller_id=auth.uid());
drop policy if exists media_public_select on product_media; create policy media_public_select on product_media for select using(true);
drop policy if exists media_owner_write on product_media; create policy media_owner_write on product_media for all to authenticated using(exists(select 1 from products p where p.id=product_id and p.seller_id=auth.uid())) with check(exists(select 1 from products p where p.id=product_id and p.seller_id=auth.uid()));
drop policy if exists followers_public_select on store_followers; create policy followers_public_select on store_followers for select using(user_id=auth.uid() or exists(select 1 from stores s where s.id=store_id and s.owner_uid=auth.uid()));
drop policy if exists followers_self_insert on store_followers; create policy followers_self_insert on store_followers for insert to authenticated with check(user_id=auth.uid());
drop policy if exists followers_self_delete on store_followers; create policy followers_self_delete on store_followers for delete to authenticated using(user_id=auth.uid());
drop policy if exists notifications_self on notifications; create policy notifications_self on notifications for all to authenticated using(user_id=auth.uid()) with check(user_id=auth.uid());
drop policy if exists requests_public_select on public_orders; create policy requests_public_select on public_orders for select using(true);
drop policy if exists requests_self_insert on public_orders; create policy requests_self_insert on public_orders for insert to authenticated with check(buyer_id=auth.uid());
drop policy if exists requests_self_update on public_orders; create policy requests_self_update on public_orders for update to authenticated using(buyer_id=auth.uid()) with check(buyer_id=auth.uid());
drop policy if exists responses_select on public_order_responses; create policy responses_select on public_order_responses for select using(seller_id=auth.uid() or exists(select 1 from public_orders r where r.id=public_order_id and r.buyer_id=auth.uid()));
drop policy if exists responses_insert on public_order_responses; create policy responses_insert on public_order_responses for insert to authenticated with check(seller_id=auth.uid());

drop function if exists notify_new_product() cascade;
create or replace function notify_new_product() returns trigger language plpgsql security definer as $$ begin insert into notifications(user_id,type,title,message,data) select sf.user_id,'new_product','New product from a store you follow',new.title,jsonb_build_object('product_id',new.id,'store_id',new.store_id) from store_followers sf where sf.store_id=new.store_id and sf.user_id<>new.seller_id; return new; end; $$;
drop trigger if exists trg_new_product_notify on products; create trigger trg_new_product_notify after insert on products for each row execute function notify_new_product();

drop function if exists notify_new_request() cascade;
create or replace function notify_new_request() returns trigger language plpgsql security definer as $$ begin insert into notifications(user_id,type,title,message,data) select p.id,'public_request','New public buying request',new.title,jsonb_build_object('request_id',new.id) from profiles p where p.is_seller=true and p.id<>new.buyer_id; return new; end; $$;
drop trigger if exists trg_new_request_notify on public_orders; create trigger trg_new_request_notify after insert on public_orders for each row execute function notify_new_request();

create or replace function start_conversation(other_uid uuid) returns uuid language plpgsql security definer set search_path=public as $$ declare cid uuid; begin if other_uid is null or other_uid=auth.uid() then raise exception 'Invalid participant'; end if; select cp.conversation_id into cid from conversation_participants cp where cp.user_id=auth.uid() and exists(select 1 from conversation_participants cp2 where cp2.conversation_id=cp.conversation_id and cp2.user_id=other_uid) limit 1; if cid is null then insert into conversations default values returning id into cid; insert into conversation_participants values(cid,auth.uid()),(cid,other_uid); end if; return cid; end; $$;
grant execute on function start_conversation(uuid) to authenticated;

create index if not exists products_currency_price_idx on products(currency,price) where status='active';
create index if not exists products_store_idx on products(store_id); create index if not exists products_category_idx on products(category); create index if not exists notifications_user_idx on notifications(user_id,created_at desc); create index if not exists requests_created_idx on public_orders(created_at desc);
