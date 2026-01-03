-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create job details table
CREATE TABLE IF NOT EXISTS glibliojob_job_details (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    title TEXT NOT NULL,
    company_name TEXT NOT NULL,
    location TEXT NOT NULL,
    job_type TEXT CHECK (job_type IN ('full-time', 'part-time', 'contract', 'freelance', 'internship')),
    work_mode TEXT CHECK (work_mode IN ('Remote', 'Hybrid', 'On-site')) DEFAULT 'Remote',
    salary_range_min DECIMAL(10,2),
    salary_range_max DECIMAL(10,2),
    currency TEXT DEFAULT 'NGN',
    description TEXT NOT NULL,
    requirements TEXT[],
    responsibilities TEXT[],
    posted_by UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    is_active BOOLEAN DEFAULT TRUE,
    remote_friendly BOOLEAN DEFAULT FALSE,
    experience_level TEXT CHECK (experience_level IN ('entry', 'mid', 'senior', 'executive')),
    application_deadline TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create post job table (for job posting management)
CREATE TABLE IF NOT EXISTS glibliojob_post_job (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    job_id UUID REFERENCES glibliojob_job_details(id) ON DELETE CASCADE,
    posted_by UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    company_logo_url TEXT,
    company_website TEXT,
    contact_email TEXT,
    contact_phone TEXT,
    status TEXT CHECK (status IN ('draft', 'published', 'paused', 'closed')) DEFAULT 'draft',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create apply now details table (for tracking job applications)
CREATE TABLE IF NOT EXISTS glibliojob_apply_now_detail (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    job_id UUID REFERENCES glibliojob_job_details(id) ON DELETE CASCADE,
    applicant_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    resume_url TEXT,
    cover_letter TEXT,
    application_status TEXT CHECK (application_status IN ('pending', 'reviewed', 'shortlisted', 'interviewed', 'rejected', 'accepted')) DEFAULT 'pending',
    applied_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(job_id, applicant_id)
);

-- Create application status table (for detailed application tracking)
CREATE TABLE IF NOT EXISTS glibliojob_application_status (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    application_id UUID REFERENCES glibliojob_apply_now_detail(id) ON DELETE CASCADE,
    status TEXT CHECK (status IN ('pending', 'reviewed', 'shortlisted', 'interviewed', 'rejected', 'accepted')) NOT NULL,
    status_reason TEXT, -- reason for status change (especially for rejected/accepted)
    updated_by UUID REFERENCES auth.users(id) ON DELETE CASCADE, -- who updated the status
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_glibliojob_job_details_active ON glibliojob_job_details(is_active);
CREATE INDEX IF NOT EXISTS idx_glibliojob_job_details_type ON glibliojob_job_details(job_type);
CREATE INDEX IF NOT EXISTS idx_glibliojob_job_details_location ON glibliojob_job_details(location);
CREATE INDEX IF NOT EXISTS idx_glibliojob_job_details_posted_by ON glibliojob_job_details(posted_by);
CREATE INDEX IF NOT EXISTS idx_glibliojob_apply_now_detail_job_id ON glibliojob_apply_now_detail(job_id);
CREATE INDEX IF NOT EXISTS idx_glibliojob_apply_now_detail_applicant_id ON glibliojob_apply_now_detail(applicant_id);
CREATE INDEX IF NOT EXISTS idx_glibliojob_apply_now_detail_status ON glibliojob_apply_now_detail(application_status);
CREATE INDEX IF NOT EXISTS idx_glibliojob_application_status_application_id ON glibliojob_application_status(application_id);

-- Enable Row Level Security (RLS)
ALTER TABLE glibliojob_job_details ENABLE ROW LEVEL SECURITY;
ALTER TABLE glibliojob_post_job ENABLE ROW LEVEL SECURITY;
ALTER TABLE glibliojob_apply_now_detail ENABLE ROW LEVEL SECURITY;
ALTER TABLE glibliojob_application_status ENABLE ROW LEVEL SECURITY;

-- Create RLS policies

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

-- Create functions

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for updated_at
CREATE TRIGGER update_glibliojob_job_details_updated_at
    BEFORE UPDATE ON glibliojob_job_details
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_glibliojob_post_job_updated_at
    BEFORE UPDATE ON glibliojob_post_job
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_glibliojob_apply_now_detail_updated_at
    BEFORE UPDATE ON glibliojob_apply_now_detail
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insert sample job data
INSERT INTO glibliojob_job_details (
    title, 
    company_name, 
    location, 
    job_type, 
    salary_range_min, 
    salary_range_max, 
    description, 
    requirements, 
    responsibilities,
    experience_level,
    application_deadline
) VALUES
(
    'Flutter Developer',
    'Tech Solutions Ltd',
    'Lagos, Nigeria',
    'full-time',
    150000.00,
    250000.00,
    'We are looking for a skilled Flutter Developer to join our team. You will be responsible for developing and maintaining mobile applications using Flutter framework.',
    ARRAY['3+ years experience with Flutter', 'Dart programming knowledge', 'Experience with REST APIs'],
    ARRAY['Develop mobile applications', 'Write clean, maintainable code', 'Collaborate with design team'],
    'mid',
    NOW() + INTERVAL '30 days'
),
(
    'UI/UX Designer',
    'Creative Minds Inc',
    'Remote',
    'full-time',
    120000.00,
    200000.00,
    'We need a creative UI/UX Designer to create beautiful and functional user interfaces for our mobile and web applications.',
    ARRAY['Portfolio of UI/UX work', 'Experience with Figma/Sketch', 'User research skills'],
    ARRAY['Design user interfaces', 'Create wireframes and prototypes', 'Conduct user testing'],
    'mid',
    NOW() + INTERVAL '21 days'
),
(
    'Backend Developer',
    'Data Systems Co',
    'Abuja, Nigeria',
    'contract',
    200000.00,
    350000.00,
    'We are seeking a Backend Developer with experience in Node.js and database management to build scalable server-side applications.',
    ARRAY['Node.js experience', 'Database design skills', 'REST API development'],
    ARRAY['Build server-side applications', 'Design database schemas', 'Optimize application performance'],
    'senior',
    NOW() + INTERVAL '14 days'
);

-- Insert sample post job data
INSERT INTO glibliojob_post_job (
    job_id,
    company_logo_url,
    company_website,
    contact_email,
    contact_phone,
    status
) VALUES
(
    (SELECT id FROM glibliojob_job_details WHERE title = 'Flutter Developer'),
    'https://example.com/flutter-logo.png',
    'https://techsolutions.com',
    'hr@techsolutions.com',
    '+2348012345678',
    'published'
),
(
    (SELECT id FROM glibliojob_job_details WHERE title = 'UI/UX Designer'),
    'https://example.com/creative-logo.png',
    'https://creativeminds.com',
    'jobs@creativeminds.com',
    '+2348087654321',
    'published'
),
(
    (SELECT id FROM glibliojob_job_details WHERE title = 'Backend Developer'),
    'https://example.com/data-logo.png',
    'https://datasystems.com',
    'careers@datasystems.com',
    '+2348011223344',
    'published'
);