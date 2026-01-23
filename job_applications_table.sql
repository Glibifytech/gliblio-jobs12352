-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.article_likes (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  article_id uuid NOT NULL,
  user_id uuid NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT article_likes_pkey PRIMARY KEY (id),
  CONSTRAINT article_likes_article_id_fkey FOREIGN KEY (article_id) REFERENCES public.articles(id),
  CONSTRAINT article_likes_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.articles (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  title text NOT NULL,
  content text NOT NULL CHECK (char_length(content) <= 500) NOT VALI),
  likes_count integer DEFAULT 0,
  shares_count integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT articles_pkey PRIMARY KEY (id),
  CONSTRAINT articles_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id),
  CONSTRAINT fk_articles_user_id FOREIGN KEY (user_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.blocks (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  blocker_id uuid,
  blocked_id uuid,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT blocks_pkey PRIMARY KEY (id),
  CONSTRAINT blocks_blocker_id_fkey FOREIGN KEY (blocker_id) REFERENCES auth.users(id),
  CONSTRAINT blocks_blocked_id_fkey FOREIGN KEY (blocked_id) REFERENCES auth.users(id)
);
CREATE TABLE public.comments (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  post_id uuid,
  user_id uuid,
  content text NOT NULL,
  parent_id uuid,
  likes_count integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT comments_pkey PRIMARY KEY (id),
  CONSTRAINT comments_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id),
  CONSTRAINT comments_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.posts(id),
  CONSTRAINT comments_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.comments(id)
);
CREATE TABLE public.deleted_images (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  image_url text NOT NULL,
  deleted_by uuid NOT NULL,
  source_table text NOT NULL,
  source_id uuid,
  deleted_at timestamp with time zone DEFAULT now(),
  cleaned_up boolean DEFAULT false,
  cleaned_up_at timestamp with time zone,
  CONSTRAINT deleted_images_pkey PRIMARY KEY (id),
  CONSTRAINT deleted_images_deleted_by_fkey FOREIGN KEY (deleted_by) REFERENCES auth.users(id)
);
CREATE TABLE public.design_likes (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  design_id uuid NOT NULL,
  user_id uuid NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT design_likes_pkey PRIMARY KEY (id),
  CONSTRAINT design_likes_design_id_fkey FOREIGN KEY (design_id) REFERENCES public.designs(id),
  CONSTRAINT design_likes_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.designs (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  title text NOT NULL,
  description text,
  category text NOT NULL,
  price numeric NOT NULL,
  preview_images ARRAY,
  files ARRAY,
  tags ARRAY,
  likes_count integer DEFAULT 0,
  sales_count integer DEFAULT 0,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT designs_pkey PRIMARY KEY (id),
  CONSTRAINT designs_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.direct_messages (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  sender_id uuid NOT NULL,
  recipient_id uuid NOT NULL,
  content text NOT NULL,
  message_type text DEFAULT 'text'::text,
  media_urls ARRAY,
  read boolean DEFAULT false,
  read_at timestamp with time zone,
  is_deleted boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT direct_messages_pkey PRIMARY KEY (id),
  CONSTRAINT direct_messages_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES auth.users(id),
  CONSTRAINT direct_messages_recipient_id_fkey FOREIGN KEY (recipient_id) REFERENCES auth.users(id)
);
CREATE TABLE public.feature_requests (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  username text NOT NULL,
  title text NOT NULL,
  description text NOT NULL,
  status text DEFAULT 'pending'::text CHECK (status = ANY (ARRAY['pending'::text, 'reviewing'::text, 'approved'::text, 'rejected'::text])),
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT feature_requests_pkey PRIMARY KEY (id),
  CONSTRAINT feature_requests_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.follows (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  follower_id uuid,
  following_id uuid,
  created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT follows_pkey PRIMARY KEY (id),
  CONSTRAINT follows_following_id_fkey FOREIGN KEY (following_id) REFERENCES public.profiles(id),
  CONSTRAINT follows_follower_id_fkey FOREIGN KEY (follower_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.glibliojob_application_status (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  application_id uuid,
  status text NOT NULL CHECK (status = ANY (ARRAY['pending'::text, 'reviewed'::text, 'shortlisted'::text, 'interviewed'::text, 'rejected'::text, 'accepted'::text])),
  status_reason text,
  updated_by uuid,
  notes text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT glibliojob_application_status_pkey PRIMARY KEY (id),
  CONSTRAINT glibliojob_application_status_application_id_fkey FOREIGN KEY (application_id) REFERENCES public.glibliojob_apply_now_detail(id),
  CONSTRAINT glibliojob_application_status_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES auth.users(id)
);
CREATE TABLE public.glibliojob_apply_now_detail (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  job_id uuid,
  applicant_id uuid,
  resume_url text,
  cover_letter text,
  application_status text DEFAULT 'pending'::text CHECK (application_status = ANY (ARRAY['pending'::text, 'reviewed'::text, 'shortlisted'::text, 'interviewed'::text, 'rejected'::text, 'accepted'::text])),
  applied_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT glibliojob_apply_now_detail_pkey PRIMARY KEY (id),
  CONSTRAINT glibliojob_apply_now_detail_job_id_fkey FOREIGN KEY (job_id) REFERENCES public.glibliojob_job_details(id),
  CONSTRAINT glibliojob_apply_now_detail_applicant_id_fkey FOREIGN KEY (applicant_id) REFERENCES auth.users(id)
);
CREATE TABLE public.glibliojob_job_details (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  title text NOT NULL,
  company_name text NOT NULL,
  location text NOT NULL,
  job_type text CHECK (job_type = ANY (ARRAY['full-time'::text, 'part-time'::text, 'contract'::text, 'freelance'::text, 'internship'::text])),
  salary_range_min numeric,
  salary_range_max numeric,
  currency text DEFAULT 'NGN'::text,
  description text NOT NULL,
  requirements ARRAY,
  responsibilities ARRAY,
  posted_by uuid NOT NULL,
  is_active boolean DEFAULT true,
  remote_friendly boolean DEFAULT false,
  experience_level text CHECK (experience_level = ANY (ARRAY['entry'::text, 'mid'::text, 'senior'::text, 'executive'::text])),
  application_deadline timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  work_mode text DEFAULT 'Remote'::text CHECK (work_mode = ANY (ARRAY['Remote'::text, 'Hybrid'::text, 'On-site'::text])),
  poster_username text,
  poster_full_name text,
  poster_avatar_url text,
  CONSTRAINT glibliojob_job_details_pkey PRIMARY KEY (id),
  CONSTRAINT glibliojob_job_details_posted_by_fkey FOREIGN KEY (posted_by) REFERENCES auth.users(id)
);
CREATE TABLE public.glibliojob_post_job (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  job_id uuid,
  posted_by uuid,
  company_logo_url text,
  company_website text,
  contact_email text,
  contact_phone text,
  status text DEFAULT 'draft'::text CHECK (status = ANY (ARRAY['draft'::text, 'published'::text, 'paused'::text, 'closed'::text])),
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT glibliojob_post_job_pkey PRIMARY KEY (id),
  CONSTRAINT glibliojob_post_job_job_id_fkey FOREIGN KEY (job_id) REFERENCES public.glibliojob_job_details(id),
  CONSTRAINT glibliojob_post_job_posted_by_fkey FOREIGN KEY (posted_by) REFERENCES auth.users(id)
);
CREATE TABLE public.hire_request_applications (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  hire_request_id uuid NOT NULL,
  designer_id uuid NOT NULL,
  message text,
  status text DEFAULT 'pending'::text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT hire_request_applications_pkey PRIMARY KEY (id),
  CONSTRAINT hire_request_applications_hire_request_id_fkey FOREIGN KEY (hire_request_id) REFERENCES public.hire_requests(id),
  CONSTRAINT hire_request_applications_designer_id_fkey FOREIGN KEY (designer_id) REFERENCES auth.users(id)
);
CREATE TABLE public.hire_requests (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  title text NOT NULL,
  description text NOT NULL,
  category text NOT NULL,
  budget_min numeric,
  budget_max numeric,
  reference_images ARRAY,
  tags ARRAY,
  applicants_count integer DEFAULT 0,
  status text DEFAULT 'open'::text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT hire_requests_pkey PRIMARY KEY (id),
  CONSTRAINT hire_requests_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.notifications (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid,
  type text NOT NULL CHECK (type = ANY (ARRAY['like'::text, 'comment'::text, 'follow'::text, 'mention'::text, 'system'::text])),
  title text NOT NULL,
  message text NOT NULL,
  data jsonb DEFAULT '{}'::jsonb,
  is_read boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  reference_id uuid,
  shown_at timestamp with time zone,
  CONSTRAINT notifications_pkey PRIMARY KEY (id),
  CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.post_likes (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  post_id uuid NOT NULL,
  user_id uuid NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT post_likes_pkey PRIMARY KEY (id),
  CONSTRAINT post_likes_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.posts(id),
  CONSTRAINT post_likes_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.posts (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid,
  content text,
  media_urls ARRAY DEFAULT '{}'::text[],
  likes_count integer DEFAULT 0,
  liked_by ARRAY DEFAULT '{}'::uuid[],
  comments_count integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT posts_pkey PRIMARY KEY (id),
  CONSTRAINT posts_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.profiles (
  id uuid NOT NULL,
  username text UNIQUE,
  full_name text,
  avatar_url text,
  bio text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  website text,
  deleted boolean DEFAULT false,
  deleted_at timestamp with time zone,
  skills ARRAY DEFAULT '{}'::text[] CHECK (array_length(skills, 1) IS NULL OR array_length(skills, 1) >= 1 AND array_length(skills, 1) <= 6),
  CONSTRAINT profiles_pkey PRIMARY KEY (id),
  CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id)
);
CREATE TABLE public.skill_options (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  skill_name text NOT NULL UNIQUE,
  category text,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT skill_options_pkey PRIMARY KEY (id)
);
CREATE TABLE public.user_image_uploads (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid,
  bucket_id text NOT NULL,
  file_path text NOT NULL,
  uploaded_at timestamp with time zone DEFAULT now(),
  is_deleted boolean DEFAULT false,
  CONSTRAINT user_image_uploads_pkey PRIMARY KEY (id),
  CONSTRAINT user_image_uploads_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.user_profiles (
  id uuid NOT NULL,
  email text NOT NULL UNIQUE,
  full_name text NOT NULL,
  username text UNIQUE,
  avatar_url text,
  bio text,
  role USER-DEFINED DEFAULT 'member'::user_role,
  status USER-DEFINED DEFAULT 'pending_verification'::user_status,
  is_active boolean DEFAULT true,
  last_seen_at timestamp with time zone,
  followers_count integer DEFAULT 0,
  following_count integer DEFAULT 0,
  posts_count integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  website text,
  CONSTRAINT user_profiles_pkey PRIMARY KEY (id),
  CONSTRAINT user_profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id)
);
CREATE TABLE public.user_tokens (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid,
  fcm_token text NOT NULL,
  device_id text,
  device_type text CHECK (device_type = ANY (ARRAY['android'::text, 'ios'::text, 'web'::text])),
  app_version text,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT user_tokens_pkey PRIMARY KEY (id),
  CONSTRAINT user_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);