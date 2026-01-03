-- Enable Row Level Security (RLS) for Gliblio Jobs tables

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