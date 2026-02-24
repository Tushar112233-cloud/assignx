#!/usr/bin/env python3
"""Add .tr(context) translation calls to all hardcoded English strings in doer_app."""

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
    rel = os.path.relpath(target, file_dir)
    return rel


def needs_import(content):
    """Check if file already has the translation import"""
    return 'translation_extensions.dart' not in content


def add_import(content, filepath):
    """Add translation_extensions import to the file"""
    rel_path = get_relative_import(filepath)
    import_line = "import '" + rel_path + "';"

    lines = content.split('\n')
    last_import_idx = -1
    for i, line in enumerate(lines):
        stripped = line.strip()
        if stripped.startswith('import ') and stripped.endswith(';'):
            last_import_idx = i

    if last_import_idx >= 0:
        lines.insert(last_import_idx + 1, import_line)
        return '\n'.join(lines)

    return import_line + '\n' + content


def is_translatable_string(s):
    """Check if a string should be translated"""
    if not s or not s.strip():
        return False
    # Skip very short strings (1 char) unless it's a meaningful letter
    if len(s.strip()) <= 1:
        return False
    # Skip strings that are just numbers/symbols
    if re.match(r'^[\d\s\.\,\:\-\+\%\$\#\@\!\*\/\\\|\&\^\~\`\{\}\[\]]+$', s):
        return False
    # Skip format specifiers
    if s.startswith('%') or s.startswith('$'):
        return False
    # Skip URLs
    if 'http://' in s or 'https://' in s:
        return False
    # Skip paths
    if s.startswith('/') or s.startswith('assets/'):
        return False
    # Skip single special chars
    if s in (':', ' ', ',', '.', '-', '|', 'D', 'AX', 'OR'):
        return False
    return True


def process_file(filepath):
    """Process a single Dart file to add .tr(context) calls"""
    with open(filepath, 'r') as f:
        content = f.read()

    original = content

    # Skip files without any Text widgets or UI string parameters
    if 'Text(' not in content and 'hintText' not in content and 'labelText' not in content and 'tooltip' not in content:
        return False

    # ---- STEP 1: Add .tr(context) to Text widget string literals ----

    # Handle Text('string') - must be careful not to match already-translated or interpolated
    def tr_text_single(m):
        before = m.group(1)
        s = m.group(2)
        after = m.group(3)
        if not is_translatable_string(s):
            return m.group(0)
        if '.tr(context)' in m.group(0):
            return m.group(0)
        return before + s + "'.tr(context)" + after

    def tr_text_double(m):
        before = m.group(1)
        s = m.group(2)
        after = m.group(3)
        if not is_translatable_string(s):
            return m.group(0)
        if '.tr(context)' in m.group(0):
            return m.group(0)
        return before + s + '".tr(context)' + after

    # Text('...') - match Text( then optional whitespace, then single-quoted string, then )
    # Careful: don't match Text( with interpolated strings or multi-line
    content = re.sub(
        r"""(Text\(\s*')([^'\\]*(?:\\.[^'\\]*)*)('\s*(?:,|\)))""",
        tr_text_single,
        content
    )

    content = re.sub(
        r'''(Text\(\s*")([^"\\]*(?:\\.[^"\\]*)*?)("\s*(?:,|\)))''',
        tr_text_double,
        content
    )

    # ---- STEP 2: Named UI parameters ----
    ui_params = ['hintText', 'labelText', 'helperText', 'tooltip']

    for param in ui_params:
        # param: 'string'
        pattern = r"(" + param + r":\s*')([^'\\]*(?:\\.[^'\\]*)*)(')"
        def make_replacer(p):
            def replacer(m):
                before = m.group(1)
                s = m.group(2)
                after = m.group(3)
                if not is_translatable_string(s):
                    return m.group(0)
                if '.tr(context)' in m.group(0):
                    return m.group(0)
                return before + s + "'.tr(context)"
            return replacer
        content = re.sub(pattern, make_replacer(param), content)

    # ---- STEP 3: TextSpan(text: 'string') ----
    content = re.sub(
        r"""(TextSpan\([^)]*text:\s*')([^'\\]{2,}?)('(?:\s*,|\s*\)))""",
        lambda m: m.group(1) + m.group(2) + "'.tr(context)" + m.group(3)[1:] if is_translatable_string(m.group(2)) and '.tr(context)' not in m.group(0) else m.group(0),
        content
    )

    # ---- STEP 4: Fix const conflicts ----
    # Remove const from Text(...) that contains .tr(context)
    content = re.sub(r'\bconst\s+(Text\([^)]*\.tr\(context\))', r'\1', content)

    # Remove const from SnackBar containing .tr(context) - handle multiline
    # Simple approach: line by line, track const + .tr(context) on same declaration
    lines = content.split('\n')
    new_lines = []
    for line in lines:
        if 'const' in line and '.tr(context)' in line:
            line = re.sub(r'\bconst\s+(?=Text\(|SnackBar\(|Row\(|Column\()', '', line)
        new_lines.append(line)
    content = '\n'.join(new_lines)

    # Also handle: const SnackBar( on one line, .tr(context) on following lines
    # We need a multi-line approach for const removal
    content = remove_const_multiline(content)

    # Fix double .tr(context)
    while '.tr(context).tr(context)' in content:
        content = content.replace('.tr(context).tr(context)', '.tr(context)')

    if content != original:
        # Add import if needed
        if needs_import(content) and '.tr(context)' in content:
            content = add_import(content, filepath)

        with open(filepath, 'w') as f:
            f.write(content)
        return True

    return False


def remove_const_multiline(content):
    """Remove const from multiline widget declarations that contain .tr(context)"""
    lines = content.split('\n')
    result = []
    i = 0
    while i < len(lines):
        line = lines[i]
        # Check for const SnackBar(, const Column(, const Row( etc.
        const_match = re.search(r'\bconst\s+(SnackBar|Column|Row|AlertDialog|Container|Padding)\s*\(', line)
        if const_match:
            # Look ahead up to 20 lines for .tr(context)
            block = line
            has_tr = '.tr(context)' in line
            depth = line.count('(') - line.count(')')
            j = i + 1
            while j < len(lines) and j < i + 30 and depth > 0:
                block += '\n' + lines[j]
                if '.tr(context)' in lines[j]:
                    has_tr = True
                depth += lines[j].count('(') - lines[j].count(')')
                j += 1

            if has_tr:
                # Remove const from the opening line
                line = re.sub(r'\bconst\s+(?=' + const_match.group(1) + r'\s*\()', '', line, count=1)

        result.append(line)
        i += 1
    return '\n'.join(result)


# Collect all .dart files to process
files_to_process = []
for target_dir in TARGET_DIRS:
    if not os.path.exists(target_dir):
        print(f"Warning: {target_dir} does not exist")
        continue
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
    try:
        result = process_file(filepath)
        if result:
            processed += 1
            print(f"  Modified: {rel_path}")
        else:
            print(f"  Skipped (no changes): {rel_path}")
    except Exception as e:
        print(f"  ERROR processing {rel_path}: {e}")

print(f"\nDone! Modified {processed} of {len(files_to_process)} files")
