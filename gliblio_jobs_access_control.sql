-- Revoke anonymous access and grant only to authenticated users for Gliblio Jobs tables

-- Revoke all permissions from anon role on Gliblio Jobs tables
REVOKE ALL PRIVILEGES ON TABLE glibliojob_job_details FROM anon;
REVOKE ALL PRIVILEGES ON TABLE glibliojob_post_job FROM anon;
REVOKE ALL PRIVILEGES ON TABLE glibliojob_apply_now_detail FROM anon;
REVOKE ALL PRIVILEGES ON TABLE glibliojob_application_status FROM anon;

-- Grant permissions to authenticated users only
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE glibliojob_job_details TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE glibliojob_post_job TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE glibliojob_apply_now_detail TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE glibliojob_application_status TO authenticated;

-- Grant SELECT permission to profiles table to access user profile information
GRANT SELECT ON TABLE profiles TO authenticated;

-- Grant usage on UUID extension to authenticated users
GRANT USAGE ON SCHEMA public TO authenticated;

-- Enable Row Level Security (RLS) for Gliblio Jobs tables
ALTER TABLE glibliojob_job_details ENABLE ROW LEVEL SECURITY;
ALTER TABLE glibliojob_post_job ENABLE ROW LEVEL SECURITY;
ALTER TABLE glibliojob_apply_now_detail ENABLE ROW LEVEL SECURITY;
ALTER TABLE glibliojob_application_status ENABLE ROW LEVEL SECURITY;

-- Create Row Level Security policies

-- Job details policies
CREATE POLICY "Users can view active job details" ON glibliojob_job_details
    FOR SELECT USING (is_active = true);

CREATE POLICY "Users can insert own job details" ON glibliojob_job_details
    FOR INSERT WITH CHECK (auth.uid() = posted_by);

CREATE POLICY "Users can update own job details" ON glibliojob_job_details
    FOR UPDATE USING (auth.uid() = posted_by);

-- Post job policies
CREATE POLICY "Users can view published post jobs" ON glibliojob_post_job
    FOR SELECT USING (status = 'published');

CREATE POLICY "Users can insert own post jobs" ON glibliojob_post_job
    FOR INSERT WITH CHECK (auth.uid() = posted_by);

CREATE POLICY "Users can update own post jobs" ON glibliojob_post_job
    FOR UPDATE USING (auth.uid() = posted_by);

-- Apply now details policies
CREATE POLICY "Users can view own applications" ON glibliojob_apply_now_detail
    FOR SELECT USING (auth.uid() = applicant_id);

CREATE POLICY "Users can apply for jobs" ON glibliojob_apply_now_detail
    FOR INSERT WITH CHECK (auth.uid() = applicant_id);

CREATE POLICY "Users can update own applications" ON glibliojob_apply_now_detail
    FOR UPDATE USING (auth.uid() = applicant_id);

-- Application status policies
CREATE POLICY "Users can view own application status" ON glibliojob_application_status
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM glibliojob_apply_now_detail 
            WHERE glibliojob_apply_now_detail.id = glibliojob_application_status.application_id 
            AND glibliojob_apply_now_detail.applicant_id = auth.uid()
        )
    );