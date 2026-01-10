"""
Quick test to verify new route files have correct syntax
"""

import sys
import os

# Add backend to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

print("✅ Testing route file syntax...")

try:
    # Test if files can be parsed (syntax check)
    import ast
    
    files_to_check = [
        'app/routes/tracking.py',
        'app/routes/statistics.py'
    ]
    
    for file_path in files_to_check:
        with open(file_path, 'r', encoding='utf-8') as f:
            code = f.read()
            ast.parse(code)
        print(f"✅ {file_path} - Syntax OK")
    
    print("\n✅ All files have valid Python syntax!")
    print("\n📋 API Endpoints Created:")
    print("  🔹 /api/tracking/medicines - Medicine tracking CRUD")
    print("  🔹 /api/tracking/plans - Medicine plans/schedules")
    print("  🔹 /api/tracking/occurrences - Dose occurrences")
    print("  🔹 /api/tracking/dosage-checks - Daily dosage checking")
    print("  🔹 /api/tracking/intake-logs - Medication intake logs")
    print("  🔹 /api/statistics/overview - User statistics overview")
    print("  🔹 /api/statistics/medicine - Per-medicine statistics")
    print("  🔹 /api/statistics/daily - Daily statistics")
    print("  🔹 /api/statistics/weekly - Weekly trends")
    print("  🔹 /api/statistics/monthly - Monthly trends")
    print("  🔹 /api/statistics/adherence-trend - 30-day adherence trend")
    print("\n📖 See MEDICINE_API_DOCUMENTATION.md for full details")
    
except SyntaxError as e:
    print(f"❌ Syntax Error in {file_path}: {e}")
    sys.exit(1)
except Exception as e:
    print(f"❌ Error: {e}")
    sys.exit(1)
