from __future__ import print_function
import os
import subprocess
import shutil

RUNTIME_DIR = "runtime"


def get_libs():
    libs = {}
    with open('packages', 'r') as packages:
        packages_lines = packages.readlines()
    for line in packages_lines:
        line = line.strip()
        if line.startswith('#'):
            continue
        parts = line.split()
        package_name = parts[0]
        libraries = parts[1:]
        libs[package_name] = libraries
    return libs


def get_ldconfig_libs():
    """Return libs available when running ldconfig -p"""
    ldconfig = subprocess.Popen(['ldconfig', '-p'],
                                stdout=subprocess.PIPE).communicate()[0]
    return [line.strip().split()
            for line in ldconfig.decode().split('\n')
            if line.startswith('\t')]


def find_lib_paths(required_libs):
    lib_paths = []
    ld_libs = []
    for parts in get_ldconfig_libs():
        if parts[0] in required_libs:
            print("Found ", parts[0])
            lib_paths.append(parts[-1])
            ld_libs.append(parts[0])
    libs_not_found = list(set(required_libs) - set(ld_libs))
    for lib in libs_not_found[:]:
        if os.path.exists(lib):
            print("Found ", lib)
            lib_paths.append(lib)
            libs_not_found.remove(lib)
    if len(libs_not_found) > 0:
        print('Required libraries not found:', ' '.join(libs_not_found))
    return lib_paths


def build_runtime():
    required_libs = []
    libs = get_libs()
    subprocess.Popen(
        ['sudo', 'apt-get', 'install', '--allow-downgrades', '--allow-remove-essential', '--allow-change-held-packages', '-q=2'] + list(libs.keys())
    ).communicate()
    for lib_package in libs:
        required_libs += libs[lib_package]
    lib_paths = find_lib_paths(required_libs)
    for lib in lib_paths:
        exists = os.path.exists(lib)
        if exists:
            print("Copying", lib)
            shutil.copy(lib, RUNTIME_DIR)
        else:
            print("Library not found", lib)


if __name__ == "__main__":
    if not os.path.exists(RUNTIME_DIR):
        os.makedirs(RUNTIME_DIR)
    build_runtime()
