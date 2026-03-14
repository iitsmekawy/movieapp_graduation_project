import os
import re

def remove_comments(text):
    # Regex to match strings (single and double quoted) and comments
    # This helps avoid removing comments inside strings
    pattern = r'("(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|/\*.*?\*/|//.*?$)'
    
    def replacer(match):
        s = match.group(0)
        if s.startswith('/'):
            return ""  # It's a comment, remove it
        else:
            return s  # It's a string, keep it

    # Flags=re.DOTALL for multi-line comments, re.MULTILINE for // comments
    return re.sub(pattern, replacer, text, flags=re.DOTALL | re.MULTILINE)

def process_directory(directory):
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith(".dart"):
                file_path = os.path.join(root, file)
                print(f"Processing {file_path}...")
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                new_content = remove_comments(content)
                
                # Also remove trailing whitespace and empty lines that might result from comment removal
                lines = [line.rstrip() for line in new_content.splitlines()]
                # Optional: remove multiple consecutive empty lines
                # lines = [line for i, line in enumerate(lines) if line or (i > 0 and lines[i-1])]
                
                final_content = "\n".join(lines)
                
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(final_content)

if __name__ == "__main__":
    target_dir = r'c:\Users\georg_y3k8qjg\StudioProjects\movieapp_graduation_project\lib'
    process_directory(target_dir)
    print("Done!")
