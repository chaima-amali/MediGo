"""
Automatic Sync Service
Runs sync scripts once at startup and schedules periodic syncs to push local rows to Supabase.
This calls the existing sync scripts in the backend/ folder.
"""

import os
import subprocess
import threading
import time
from apscheduler.schedulers.background import BackgroundScheduler
from apscheduler.triggers.interval import IntervalTrigger

# Backend root (two levels up from this file: app/services -> backend)
BACKEND_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
PYTHON = os.environ.get('PYTHON_EXECUTABLE') or os.sys.executable


class SyncService:
    def __init__(self, app=None, interval_minutes: int = 5):
        self.scheduler = BackgroundScheduler()
        self.app = app
        self.interval = interval_minutes

    def start(self):
        # Run initial sync in background so startup is not blocked
        t = threading.Thread(target=self._initial_run, daemon=True)
        t.start()

        # Schedule periodic syncs
        self.scheduler.add_job(
            func=self._run_sync,
            trigger=IntervalTrigger(minutes=self.interval),
            id='automatic_sync_job',
            name='Automatic sync to Supabase',
            replace_existing=True,
        )
        self.scheduler.start()
        print(f'✅ Sync service started (every {self.interval} minutes)')

    def _initial_run(self):
        # Small delay to allow app to finish initialization
        time.sleep(2)
        self._run_sync()

    def _run_sync(self):
        scripts = [
            'sync_users.py',
            'sync_local_to_supabase.py',
            'sync_local_plans_occurrences.py',
        ]

        for script in scripts:
            script_path = os.path.join(BACKEND_ROOT, script)
            if not os.path.exists(script_path):
                print(f'⚠️ Sync script not found: {script_path}')
                continue

            try:
                print(f'🔁 Running sync: {script}')
                result = subprocess.run(
                    [PYTHON, script_path],
                    cwd=BACKEND_ROOT,
                    capture_output=True,
                    text=True,
                    encoding='utf-8',
                    errors='replace',
                    timeout=300,
                )

                stdout_text = (result.stdout or '')
                stderr_text = (result.stderr or '')

                if result.returncode == 0:
                    out = stdout_text.strip()
                    print(f'✅ Sync {script} completed. Output:\n{out}')
                else:
                    print(f'❌ Sync {script} failed (code {result.returncode}).')
                    print('--- stdout ---')
                    print(stdout_text)
                    print('--- stderr ---')
                    print(stderr_text)

            except Exception as e:
                print(f'❌ Error running {script}: {e}')


# Module-level singleton
_sync_service = None


def init_sync_service(app=None, interval_minutes: int = 5):
    global _sync_service
    if _sync_service is None:
        _sync_service = SyncService(app=app, interval_minutes=interval_minutes)
        _sync_service.start()
    return _sync_service
