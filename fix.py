import os
import re

for root, dirs, files in os.walk("."):
    for file in files:
        if file.endswith(".tscn"):
            path = os.path.join(root, file)

            with open(path, "r", encoding="utf-8") as f:
                data = f.read()

            new_data = re.sub(
                r'libraries/ = SubResource\("([^"]+)"\)',
                r'libraries = {\n&"": SubResource("\1")\n}',
                data
            )

            if new_data != data:
                print("Fixed:", path)
                with open(path, "w", encoding="utf-8") as f:
                    f.write(new_data)