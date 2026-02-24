#!/bin/bash
# Script to add .tr(context) translation calls to all hardcoded English strings
# in the doer_app Flutter project

cd "/Volumes/Crucial X9/AssignX/doer_app"

# Use Python for complex text processing
python3 << 'PYTHON_SCRIPT'
import os
import re

BASE = "/Volumes/Crucial X9/AssignX/doer_app/lib"

# Files to skip (non-UI: models, services, repositories, routes, configs, etc.)
SKIP_PATTERNS = [
    '/data/',
    '/providers/',
    '/core/config/',
    '/core/constants/',
    '/core/errors/',
    '/core/router/',
    '/core/services/',
    '/core/theme/',
    '/core/utils/',
    '/core/validators/',
    '/core/translation/',
    '/shared/utils/',
    'main.dart',
    'app.dart',
]

# Files to process
TARGET_DIRS = [
    os.path.join(BASE, 'features'),
    os.path.join(BASE, 'shared', 'widgets'),
]

def should_skip(filepath):
    for pattern in SKIP_PATTERNS:
        if pattern in filepath:
            return True
    return False

def get_relative_import(filepath):
    """Calculate relative import path from file to translation_extensions.dart"""
    file_dir = os.path.dirname(filepath)
    target = os.path.join(BASE, 'core', 'translation', 'translation_extensions.dart')

    # Calculate relative path
    rel = os.path.relpath(target, file_dir)
    return rel

def needs_import(content):
    """Check if file already has the translation import"""
    return 'translation_extensions.dart' not in content

def add_import(content, filepath):
    """Add translation_extensions import to the file"""
    rel_path = get_relative_import(filepath)
    import_line = f"import '{rel_path}';\n"

    # Find the last import line
    lines = content.split('\n')
    last_import_idx = -1
    for i, line in enumerate(lines):
        if line.strip().startswith('import '):
            last_import_idx = i

    if last_import_idx >= 0:
        lines.insert(last_import_idx + 1, import_line.rstrip())
        return '\n'.join(lines)

    # If no imports found, add at top after any library directive
    return import_line + content

def is_ui_string_context(before_quote, full_line):
    """Check if this string is in a UI context that should be translated"""
    # Skip route paths
    if "context.go(" in full_line or "context.push(" in full_line:
        return False
    if "RouteNames." in full_line:
        return False
    if "go('/" in full_line or "push('/" in full_line:
        return False

    # Skip asset paths
    if 'assets/' in full_line:
        return False

    # Skip URLs
    if 'http' in full_line and '://' in full_line:
        return False

    # Skip debug/print
    if 'print(' in full_line or 'debugPrint(' in full_line or 'log(' in full_line:
        return False

    # Skip package names / identifiers
    if 'package:' in full_line:
        return False

    # Skip already translated
    if '.tr(context)' in full_line:
        return False

    # Skip key/value identifiers
    if re.search(r"key:\s*['\"]", full_line):
        return False
    if re.search(r"name:\s*['\"]", full_line) and 'displayName' not in full_line and 'userName' not in full_line:
        # Skip route/field names, but not display names
        if 'fieldName' in full_line:
            return False

    # Skip format patterns, regex, special characters only
    stripped = full_line.strip()

    return True

def process_file(filepath):
    """Process a single Dart file to add .tr(context) calls"""
    with open(filepath, 'r') as f:
        content = f.read()

    original = content

    # Patterns that indicate UI string contexts where .tr(context) should be added
    # We need to be very careful and precise

    changes_made = False

    # Pattern 1: Text('string') or Text("string") - direct Text widget with string literal
    # This handles: Text('Hello'), const Text('Hello')
    def replace_text_widget(match):
        prefix = match.group(1)  # 'Text(' or similar
        quote = match.group(2)   # quote char
        string_content = match.group(3)  # the string content
        end_quote = match.group(4)  # closing quote

        # Skip empty strings
        if not string_content.strip():
            return match.group(0)

        # Skip if already has .tr
        if '.tr(context)' in match.group(0):
            return match.group(0)

        # Skip single characters that are likely not translatable
        if len(string_content) <= 1 and string_content not in ('D',):
            return match.group(0)

        # Skip strings that are just numbers, symbols, or format patterns
        if re.match(r'^[\d\s\.\,\:\-\+\%\$\#\@\!\*\/\\\|\&\^\~\`]+$', string_content):
            return match.group(0)

        # Skip strings that start with $ (interpolation already)
        if string_content.startswith('$'):
            return match.group(0)

        return f"{prefix}{quote}{string_content}{end_quote}.tr(context)"

    # Process Text('...') widgets - single quoted
    content = re.sub(
        r"(Text\s*\(\s*)(')([^']+?)(')\s*(?=[\),\s])",
        replace_text_widget,
        content
    )

    # Process Text("...") widgets - double quoted
    content = re.sub(
        r'(Text\s*\(\s*)(")([^"]+?)(")\s*(?=[\),\s])',
        replace_text_widget,
        content
    )

    # Pattern 2: Named parameters that take strings for UI display
    # hintText: 'string', labelText: 'string', title: Text('string'), etc.
    ui_params = [
        'hintText', 'labelText', 'helperText', 'errorText',
        'tooltip', 'semanticLabel', 'label',
    ]

    for param in ui_params:
        # Single quoted
        def make_param_replacer(p):
            def replacer(match):
                prefix = match.group(1)
                string_content = match.group(2)
                if not string_content.strip() or '.tr(context)' in match.group(0):
                    return match.group(0)
                if len(string_content) <= 1:
                    return match.group(0)
                return f"{prefix}{string_content}'.tr(context)"
            return replacer

        content = re.sub(
            rf"({param}:\s*')([^']+?)'(?!\.tr)",
            make_param_replacer(param),
            content
        )
        content = re.sub(
            rf'({param}:\s*")([^"]+?)"(?!\.tr)',
            lambda m: f'{m.group(1)}{m.group(2)}".tr(context)' if m.group(2).strip() and len(m.group(2)) > 1 else m.group(0),
            content
        )

    # Pattern 3: SnackBar content Text
    # Already handled by Text() pattern above

    # Pattern 4: AppBar title with const Text - need to handle const removal
    # title: const Text('string') -> title: Text('string'.tr(context))
    # This is handled later in const removal

    # Pattern 5: TextSpan(text: 'string')
    content = re.sub(
        r"(TextSpan\s*\(\s*text:\s*')([^']{2,}?)'(?!\.tr)",
        lambda m: f"{m.group(1)}{m.group(2)}'.tr(context)" if m.group(2).strip() else m.group(0),
        content
    )

    # Pattern 6: title: 'string' in widget constructors (like AlertDialog)
    # Be careful: only when it looks like a UI title, not a route name
    content = re.sub(
        r"(title:\s*)(const\s+)?Text\(\s*'([^']{2,}?)'\s*\)",
        lambda m: f"{m.group(1)}Text('{m.group(3)}'.tr(context))" if '.tr(context)' not in m.group(0) else m.group(0),
        content
    )
    content = re.sub(
        r'(title:\s*)(const\s+)?Text\(\s*"([^"]{2,}?)"\s*\)',
        lambda m: f'{m.group(1)}Text("{m.group(3)}".tr(context))' if '.tr(context)' not in m.group(0) else m.group(0),
        content
    )

    # Pattern 7: content: Text('string') and content: const Text('string')
    content = re.sub(
        r"(content:\s*)(const\s+)?Text\(\s*'([^']{2,}?)'\s*\)",
        lambda m: f"{m.group(1)}Text('{m.group(3)}'.tr(context))" if '.tr(context)' not in m.group(0) else m.group(0),
        content
    )

    # Pattern 8: child: Text('string') and child: const Text('string')
    content = re.sub(
        r"(child:\s*)(const\s+)?Text\(\s*'([^']{2,}?)'\s*(?=,|\)))",
        lambda m: f"{m.group(1)}Text('{m.group(3)}'.tr(context)" if '.tr(context)' not in m.group(0) else m.group(0),
        content
    )

    # Pattern 9: label: Text('string')
    content = re.sub(
        r"(label:\s*)(const\s+)?Text\(\s*'([^']{2,}?)'\s*\)",
        lambda m: f"{m.group(1)}Text('{m.group(3)}'.tr(context))" if '.tr(context)' not in m.group(0) else m.group(0),
        content
    )

    # Fix double .tr(context).tr(context)
    content = content.replace(".tr(context).tr(context)", ".tr(context)")

    # Fix triple quotes issue: '.tr(context)'.tr(context)
    content = re.sub(r"'\.tr\(context\)'\.tr\(context\)", "'.tr(context)", content)

    # Remove const from widgets that now have .tr(context)
    # Pattern: const Text('...'.tr(context)) -> Text('...'.tr(context))
    content = re.sub(r'\bconst\s+(Text\([^)]*\.tr\(context\))', r'\1', content)

    # Also handle: const Row/Column/... that contain .tr(context) children
    # This is trickier - we need to remove const from parent widgets
    # For now, handle the most common cases

    # Remove const from SnackBar that contains .tr(context)
    content = re.sub(r'\bconst\s+(SnackBar\s*\([^;]*\.tr\(context\))', r'\1', content, flags=re.DOTALL)

    # Remove const from Row that contains .tr(context)
    lines = content.split('\n')
    new_lines = []
    i = 0
    while i < len(lines):
        line = lines[i]
        # Check if this line has 'const' and a widget, and subsequent lines have .tr(context)
        # Simple approach: if a line has 'const Text(' and '.tr(context)' remove const
        if 'const' in line and '.tr(context)' in line:
            line = re.sub(r'\bconst\s+(?=Text\(|Row\(|Column\(|Padding\(|Container\(|SizedBox\()', '', line)
        new_lines.append(line)
        i += 1
    content = '\n'.join(new_lines)

    if content != original:
        changes_made = True

        # Add import if needed
        if needs_import(content) and '.tr(context)' in content:
            content = add_import(content, filepath)

        with open(filepath, 'w') as f:
            f.write(content)

        return True

    return False

# Collect all .dart files to process
files_to_process = []
for target_dir in TARGET_DIRS:
    for root, dirs, files in os.walk(target_dir):
        for filename in files:
            if filename.endswith('.dart'):
                filepath = os.path.join(root, filename)
                if not should_skip(filepath):
                    files_to_process.append(filepath)

print(f"Found {len(files_to_process)} files to process")

processed = 0
for filepath in sorted(files_to_process):
    rel_path = os.path.relpath(filepath, BASE)
    result = process_file(filepath)
    if result:
        processed += 1
        print(f"  Modified: {rel_path}")
    else:
        print(f"  Skipped (no changes): {rel_path}")

print(f"\nDone! Modified {processed} of {len(files_to_process)} files")
PYTHON_SCRIPT
