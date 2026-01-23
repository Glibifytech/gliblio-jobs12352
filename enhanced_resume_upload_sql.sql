-- Update the existing glibliojob_apply_now_detail table to enhance resume functionality
-- The table already has a resume_url column, but we'll ensure it's properly configured

-- Add file metadata columns to the existing table if they don't exist
ALTER TABLE public.glibliojob_apply_now_detail 
ADD COLUMN IF NOT EXISTS resume_file_name TEXT,
ADD COLUMN IF NOT EXISTS resume_file_size BIGINT,
ADD COLUMN IF NOT EXISTS resume_file_type TEXT,
ADD COLUMN IF NOT EXISTS resume_uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- Create storage bucket for resumes if it doesn't exist
INSERT INTO storage.buckets (id, name, public, avif_autodetection, file_size_limit, allowed_mime_types)
SELECT 'job-resumes', 'job-resumes', true, false, 5242880, '{application/pdf,application/msword,application/vnd.openxmlformats-officedocument.wordprocessingml.document}'
WHERE NOT EXISTS (SELECT FROM storage.buckets WHERE id = 'job-resumes');

-- Create RLS policies for storage if they don't exist
CREATE POLICY "Users can upload resumes" ON storage.objects
FOR INSERT TO authenticated
WITH CHECK (bucket_id = 'job-resumes' AND (auth.uid() = owner OR EXISTS (
    SELECT 1 FROM public.glibliojob_apply_now_detail 
    WHERE glibliojob_apply_now_detail.applicant_id = auth.uid()
)));

CREATE POLICY "Users can read their own resumes" ON storage.objects
FOR SELECT TO authenticated
USING (bucket_id = 'job-resumes' AND (auth.uid() = owner OR EXISTS (
    SELECT 1 FROM public.glibliojob_apply_now_detail 
    WHERE glibliojob_apply_now_detail.applicant_id = auth.uid()
)));

CREATE POLICY "Users can update their own resumes" ON storage.objects
FOR UPDATE TO authenticated
USING (bucket_id = 'job-resumes' AND auth.uid() = owner);

CREATE POLICY "Users can delete their own resumes" ON storage.objects
FOR DELETE TO authenticated
USING (bucket_id = 'job-resumes' AND auth.uid() = owner);

-- Ensure RLS is enabled on the application table
ALTER TABLE public.glibliojob_apply_now_detail ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for job applications
CREATE POLICY "Users can view their own applications" ON public.glibliojob_apply_now_detail
FOR SELECT TO authenticated
USING (auth.uid() = applicant_id);

CREATE POLICY "Users can create their own applications" ON public.glibliojob_apply_now_detail
FOR INSERT TO authenticated
WITH CHECK (auth.uid() = applicant_id);

CREATE POLICY "Users can update their own applications" ON public.glibliojob_apply_now_detail
FOR UPDATE TO authenticated
USING (auth.uid() = applicant_id);

CREATE POLICY "Users can delete their own applications" ON public.glibliojob_apply_now_detail
FOR DELETE TO authenticated
USING (auth.uid() = applicant_id);

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS idx_glibliojob_apply_now_detail_applicant_id 
ON public.glibliojob_apply_now_detail(applicant_id);
CREATE INDEX IF NOT EXISTS idx_glibliojob_apply_now_detail_job_id 
ON public.glibliojob_apply_now_detail(job_id);