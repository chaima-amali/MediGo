from datetime import datetime, timedelta

now = datetime.now()
next_test = now + timedelta(minutes=3)

print(f"Current time: {now.strftime('%H:%M:%S')}")
print(f"Next test time: {next_test.strftime('%H:%M')}")
print(f"\nYou need to add medicine for: {next_test.strftime('%H:%M')}")
