-- SQL commands to grant anonymous access to job listings for guest users
-- This will allow guest users to browse job listings without authentication

-- 1. Grant SELECT permission to anon role on the jobs table
GRANT USAGE ON SCHEMA public TO anon;
GRANT SELECT ON TABLE public.glibliojob_job_details TO anon;

-- 2. Create RLS policy to allow anonymous users to view active job listings
DROP POLICY IF EXISTS "Allow anon read access to active job listings" ON public.glibliojob_job_details;

CREATE POLICY "Allow anon read access to active job listings" 
ON public.glibliojob_job_details 
FOR SELECT 
TO anon 
USING (
  is_active = true
);

-- 3. If there are additional related tables, grant access to them as well
-- Assuming glibliojob_post_job is the related table based on the repository code
GRANT SELECT ON TABLE public.glibliojob_post_job TO anon;

-- 4. Create RLS policy for the related table if it exists
-- Note: This assumes the table has the same access pattern
-- You may need to adjust based on the actual table structure
DO $$ 
BEGIN
  IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'glibliojob_post_job') THEN
    DROP POLICY IF EXISTS "Allow anon read access to job posts" ON public.glibliojob_post_job;
    
    CREATE POLICY "Allow anon read access to job posts" 
    ON public.glibliojob_post_job 
    FOR SELECT 
    TO anon 
    USING (true);
  END IF;
END $$;

-- 5. Ensure service_role can still access the tables (in case RLS was blocking it)
GRANT SELECT ON TABLE public.glibliojob_job_details TO service_role;
GRANT SELECT ON TABLE public.glibliojob_post_job TO service_role;

-- 6. If you have a user_profiles table that stores poster information
-- that needs to be visible to guests, grant access to it as well
DO $$ 
BEGIN
  IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'user_profiles') THEN
    GRANT SELECT ON TABLE public.user_profiles TO anon;
    
    DROP POLICY IF EXISTS "Allow anon read access to public profiles" ON public.user_profiles;
    
    CREATE POLICY "Allow anon read access to public profiles" 
    ON public.user_profiles 
    FOR SELECT 
    TO anon 
    USING (true);
  END IF;
END $$;

-- 7. Refresh the schema cache
NOTIFY pgrst, 'reload schema';