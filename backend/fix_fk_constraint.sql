-- =====================================================
-- FIX FK CONSTRAINT TYPO IN SUPABASE
-- =====================================================
-- The FK constraint references "meedicine_plan" (typo) instead of "medicine_plan"
-- Run these queries in Supabase SQL Editor

-- 1. First, check the current FK constraint definition
SELECT 
    conname AS constraint_name,
    pg_get_constraintdef(oid) AS constraint_definition
FROM pg_constraint 
WHERE conrelid = 'occurrence_plan'::regclass 
  AND contype = 'f';

-- 2. Drop the incorrect FK constraint
-- (The constraint name should be fk_occurrence_plan_medicine_plan based on the error)
ALTER TABLE occurrence_plan 
DROP CONSTRAINT IF EXISTS fk_occurrence_plan_medicine_plan;

-- 3. Recreate the FK constraint with correct table name
ALTER TABLE occurrence_plan 
ADD CONSTRAINT fk_occurrence_plan_medicine_plan 
FOREIGN KEY (plan_id) 
REFERENCES medicine_plan(plan_id) 
ON DELETE CASCADE;

-- 4. Verify the fix - this should return the new constraint
SELECT 
    conname AS constraint_name,
    pg_get_constraintdef(oid) AS constraint_definition
FROM pg_constraint 
WHERE conrelid = 'occurrence_plan'::regclass 
  AND contype = 'f'
  AND conname = 'fk_occurrence_plan_medicine_plan';
