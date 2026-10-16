-- RESPAWN starter schema baseline for Supabase/Postgres.
-- Review and test before production. This is not a complete production migration.
create extension if not exists pgcrypto;

create table if not exists public.game_catalog (
  id text primary key,
  name text not null unique,
  active boolean not null default true
);
insert into public.game_catalog(id,name) values
 ('bgmi','BGMI'),('free-fire-max','Free Fire MAX'),('valorant','VALORANT'),
 ('minecraft','Minecraft'),('roblox','Roblox'),('cod-mobile','Call of Duty: Mobile'),('fortnite','Fortnite')
on conflict do nothing;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text not null,
  username_normalized text generated always as (lower(username)) stored unique,
  display_name text not null default 'Gamer' check (char_length(display_name) between 1 and 40),
  bio text not null default '' check (char_length(bio) <= 180),
  avatar_url text,
  banner_url text,
  visibility text not null default 'private' check (visibility in ('public','private')),
  coarse_region text,
  languages text[] not null default '{}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table if not exists public.user_games (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  game_id text not null references public.game_catalog(id),
  game_username text,
  self_reported_rank text,
  level integer check (level is null or level >= 0),
  preferred_role text,
  game_mode text,
  verification_status text not null default 'self_reported' check (verification_status in ('self_reported','verified')),
  statistics_source text not null default 'user_input',
  created_at timestamptz not null default now(),
  unique(user_id, game_id)
);
create table if not exists public.posts (
  id uuid primary key default gen_random_uuid(),
  author_id uuid not null references public.profiles(id) on delete cascade,
  body text not null check (char_length(body) <= 2000),
  game_id text references public.game_catalog(id),
  media_url text,
  media_type text check (media_type is null or media_type in ('image','video')),
  visibility text not null default 'public' check (visibility in ('public','followers','private')),
  moderation_status text not null default 'visible' check (moderation_status in ('visible','pending','hidden','removed')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists posts_feed_idx on public.posts(created_at desc) where moderation_status='visible';
create table if not exists public.post_likes (
  post_id uuid not null references public.posts(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key(post_id,user_id)
);
create table if not exists public.comments (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.posts(id) on delete cascade,
  author_id uuid not null references public.profiles(id) on delete cascade,
  body text not null check (char_length(body) between 1 and 1000),
  parent_id uuid references public.comments(id) on delete cascade,
  created_at timestamptz not null default now()
);
create table if not exists public.follows (
  follower_id uuid not null references public.profiles(id) on delete cascade,
  followed_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key(follower_id,followed_id),
  check(follower_id <> followed_id)
);
create table if not exists public.saved_posts (
  user_id uuid not null references public.profiles(id) on delete cascade,
  post_id uuid not null references public.posts(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key(user_id,post_id)
);

-- Minimal RLS baseline: private profile reads are limited to owner.
alter table public.profiles enable row level security;
alter table public.user_games enable row level security;
alter table public.posts enable row level security;
alter table public.post_likes enable row level security;
alter table public.comments enable row level security;
alter table public.follows enable row level security;
alter table public.saved_posts enable row level security;

create policy "profiles owner can insert" on public.profiles for insert to authenticated
  with check (id = auth.uid());
create policy "profiles owner can update" on public.profiles for update to authenticated
  using (id = auth.uid()) with check (id = auth.uid());
create policy "public profiles visible, private profiles owner only" on public.profiles for select to authenticated
  using (visibility = 'public' or id = auth.uid());

create policy "user games owner manage" on public.user_games for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "visible posts readable" on public.posts for select to authenticated
  using (moderation_status='visible' and (visibility='public' or author_id=auth.uid()));
create policy "authors create posts" on public.posts for insert to authenticated
  with check (author_id=auth.uid());
create policy "authors update own posts" on public.posts for update to authenticated
  using (author_id=auth.uid()) with check (author_id=auth.uid());
create policy "authors delete own posts" on public.posts for delete to authenticated
  using (author_id=auth.uid());

create policy "likes visible to authenticated" on public.post_likes for select to authenticated using (true);
create policy "users manage own likes" on public.post_likes for insert to authenticated with check (user_id=auth.uid());
create policy "users remove own likes" on public.post_likes for delete to authenticated using (user_id=auth.uid());
create policy "comments readable to authenticated" on public.comments for select to authenticated using (true);
create policy "users create own comments" on public.comments for insert to authenticated with check (author_id=auth.uid());
create policy "users delete own comments" on public.comments for delete to authenticated using (author_id=auth.uid());
create policy "follows visible to authenticated" on public.follows for select to authenticated using (true);
create policy "users follow as self" on public.follows for insert to authenticated with check (follower_id=auth.uid());
create policy "users unfollow as self" on public.follows for delete to authenticated using (follower_id=auth.uid());
create policy "saved posts owner only" on public.saved_posts for select to authenticated using (user_id=auth.uid());
create policy "users save own posts" on public.saved_posts for insert to authenticated with check (user_id=auth.uid());
create policy "users unsave own posts" on public.saved_posts for delete to authenticated using (user_id=auth.uid());

-- IMPORTANT: this starter migration intentionally does not implement coins, chat, admin,
-- reports, tournament verification, or child-safety workflows. Do not deploy as production
-- without a full schema, threat model, policy tests, and server-side trusted operations.
