-- Add job_application_resumes table to store uploaded resumes
CREATE TABLE IF NOT EXISTS job_application_resumes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    application_id UUID REFERENCES job_applications(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id),
    file_name TEXT NOT NULL,
    file_url TEXT NOT NULL,
    file_size BIGINT,
    file_type TEXT,
    uploaded_at TIMESTAMP DEFAULT NOW()
);

-- Enable Row Level Security (RLS) for the new table
ALTER TABLE job_application_resumes ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for job_application_resumes table
CREATE POLICY "Users can view their own resume uploads" ON job_application_resumes
FOR SELECT TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Users can upload their own resumes" ON job_application_resumes
FOR INSERT TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own resumes" ON job_application_resumes
FOR DELETE TO authenticated
USING (auth.uid() = user_id);

-- Add column to job_applications table if it doesn't exist to link to resume
-- ALTER TABLE job_applications ADD COLUMN IF NOT EXISTS resume_id UUID REFERENCES job_application_resumes(id);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_job_application_resumes_app_id ON job_application_resumes(application_id);
CREATE INDEX IF NOT EXISTS idx_job_application_resumes_user_id ON job_application_resumes(user_id);

-- Optional: If you want to link applications directly to resumes
-- ALTER TABLE job_applications ADD COLUMN IF NOT EXISTS resume_file_name TEXT;
-- ALTER TABLE job_applications ADD COLUMN IF NOT EXISTS resume_file_url TEXT;