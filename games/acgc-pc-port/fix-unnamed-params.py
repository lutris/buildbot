#!/usr/bin/env python3
"""Fix unnamed parameters in C function definitions.

The ACGC decomp uses C++ idioms like unnamed parameters in function definitions
(e.g. "void foo(ACTOR* actor, GAME*) {") which are valid in C++ but invalid in C.
This script adds dummy parameter names to make the code compile with GCC in C mode.
"""

import os
import re
import sys

# Pointer types: any identifier followed by * (e.g. GAME*, aWeather_Priv*)
# Non-pointer types: known C/decomp types only (int, u32, f32, etc.)
TYPE_PATTERN = r'(?:const\s+)?(?:\w+\s*\*|(?:unsigned\s+|signed\s+)?(?:int|char|short|long|void|u8|u16|u32|s8|s16|s32|f32|f64|float|double)\b)'

# Match an unnamed parameter: a type not followed by an identifier
UNNAMED_PARAM_RE = re.compile(
    r'(?<![a-zA-Z_])(' + TYPE_PATTERN + r')\s*(?=[,)]|$)'
)

# Match a function definition (possibly multi-line):
# optional qualifiers, return type, function name, params in parens, then {
FUNC_DEF_RE = re.compile(
    r'^(?:static\s+|inline\s+|extern\s+)*'
    r'(?:(?:const\s+)?(?:void|int|u8|u16|u32|s8|s16|s32|f32|f64|float|double|char|BOOL|[A-Z_]\w*)\s*\*?\s+)'
    r'(\w+)\s*'
    r'\(([^)]*)\)'
)

counter = 0

def fix_param(m):
    global counter
    counter += 1
    return m.group(1) + ' _p' + str(counter)

def process_file(filepath):
    global counter
    with open(filepath, 'r', errors='replace') as f:
        content = f.read()

    original = content
    counter = 0

    lines = content.split('\n')
    new_lines = []
    i = 0
    while i < len(lines):
        line = lines[i]
        stripped = line.rstrip()
        trimmed = stripped.lstrip()

        # Skip comments, macros, control flow
        if trimmed.startswith(('/', '*', '#', 'if', 'while', 'for', 'switch',
                               'else', 'return', 'case', 'do')):
            new_lines.append(line)
            i += 1
            continue

        # Check for function definition: either single-line (ends with {)
        # or multi-line (next non-empty line is {)
        is_func_def = False
        if '(' in stripped and ')' in stripped:
            if stripped.endswith('{'):
                is_func_def = True
            elif i + 1 < len(lines) and lines[i + 1].strip() == '{':
                is_func_def = True

        if is_func_def:
            m = FUNC_DEF_RE.match(trimmed)
            if m:
                func_name = m.group(1)
                params = m.group(2)
                # Skip (void) - means "no parameters" in C
                if params.strip() != 'void':
                    fixed_params = UNNAMED_PARAM_RE.sub(fix_param, params)
                    if fixed_params != params:
                        line = stripped.replace(
                            func_name + '(' + params + ')',
                            func_name + '(' + fixed_params + ')'
                        )

        new_lines.append(line)
        i += 1

    content = '\n'.join(new_lines)

    if content != original:
        with open(filepath, 'w') as f:
            f.write(content)
        return True
    return False

def main():
    search_dir = sys.argv[1]
    fixed = 0
    for root, dirs, files in os.walk(search_dir):
        for fn in files:
            if fn.endswith(('.c', '.c_inc')):
                filepath = os.path.join(root, fn)
                if process_file(filepath):
                    fixed += 1
    print(f"Fixed unnamed parameters in {fixed} files")

if __name__ == '__main__':
    main()
