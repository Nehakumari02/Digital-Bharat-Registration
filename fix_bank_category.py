import re

with open("lib/views/dashboard_screen.dart", "r") as f:
    content = f.read()

# Replace category == 'Bank' with (category == 'Bank' || category == 'Banking / Financial Services')
# But ensure we don't accidentally replace if it's already there.
content = content.replace("category == 'Bank' || category == 'Banking / Financial Services'", "category == 'Bank'") # normalize first
content = content.replace("category == 'Bank'", "(category == 'Bank' || category == 'Banking / Financial Services')")

with open("lib/views/dashboard_screen.dart", "w") as f:
    f.write(content)

print("Replaced!")
