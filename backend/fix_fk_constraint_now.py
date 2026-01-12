"""
Check and fix the FK constraint in Supabase
This script will verify the constraint and provide SQL to fix it
"""
from app import create_app
from app.supabase_client import supabase

app = create_app()

with app.app_context():
    if supabase:
        print("\n" + "="*80)
        print("🔍 CHECKING FK CONSTRAINT ON occurrence_plan")
        print("="*80)
        
        try:
            # Try to query the constraint from PostgreSQL system tables
            query = """
            SELECT 
                conname AS constraint_name,
                pg_get_constraintdef(oid) AS constraint_definition
            FROM pg_constraint 
            WHERE conrelid = 'occurrence_plan'::regclass 
              AND contype = 'f'
              AND conname LIKE '%medicine%';
            """
            
            response = supabase.rpc('exec_sql', {'query': query}).execute()
            print(f"\nConstraint check result: {response}")
            
        except Exception as e:
            print(f"Cannot query constraints directly: {e}")
        
        print("\n" + "="*80)
        print("🔧 FIXING FK CONSTRAINT")
        print("="*80)
        print("\nYou MUST run this SQL in Supabase SQL Editor:")
        print("\n" + "-"*80)
        print("""
-- Step 1: Drop the old constraint with typo
ALTER TABLE occurrence_plan 
DROP CONSTRAINT IF EXISTS fk_occurrence_plan_medicine_plan CASCADE;

-- Step 2: Add the correct constraint
ALTER TABLE occurrence_plan 
ADD CONSTRAINT fk_occurrence_plan_medicine_plan 
FOREIGN KEY (plan_id) 
REFERENCES medicine_plan(plan_id) 
ON DELETE CASCADE;

-- Step 3: Verify the fix
SELECT 
    conname AS constraint_name,
    pg_get_constraintdef(oid) AS constraint_definition
FROM pg_constraint 
WHERE conrelid = 'occurrence_plan'::regclass 
  AND contype = 'f';
""")
        print("-"*80)
        
        print("\n📋 STEPS TO APPLY:")
        print("="*80)
        print("1. Open Supabase Dashboard")
        print("2. Click 'SQL Editor' in left sidebar")
        print("3. Click 'New Query'")
        print("4. Copy the SQL above")
        print("5. Paste and click 'Run'")
        print("6. You should see 'Success. No rows returned'")
        print("\n7. Verify by running the SELECT query at the end")
        print("   It should show the constraint referencing 'medicine_plan'")
        print("="*80)
        
        print("\n⚠️  AFTER FIXING:")
        print("="*80)
        print("1. Restart your backend server (Ctrl+C and run 'python main.py')")
        print("2. In your app, create a new medicine")
        print("3. Set time to 2-3 minutes from now")
        print("4. Watch backend logs - occurrences should insert successfully")
        print("="*80)
