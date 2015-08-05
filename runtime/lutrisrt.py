import os
import subprocess
import shutil

RUNTIME_DIR = "/runtime"


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
            for line in ldconfig.split('\n')
            if line.startswith('\t')]


def find_lib_paths(required_libs):
    lib_paths = []
    for parts in get_ldconfig_libs():
        if parts[0] in required_libs:
            print "Found ", parts[0]
            lib_paths.append(parts[-1])
    return lib_paths


def build_runtime():
    required_libs = []
    libs = get_libs()
    for lib_package in libs:
        print "Installing %s" % lib_package
        subprocess.Popen(
            ['apt-get', 'install', '-y', '-q=2', lib_package]
        ).communicate()
        required_libs += libs[lib_package]
    lib_paths = find_lib_paths(required_libs)
    for lib in lib_paths:
        shutil.copy(lib, RUNTIME_DIR)


if __name__ == "__main__":
    if not os.path.exists(RUNTIME_DIR):
        os.makedirs(RUNTIME_DIR)
    build_runtime()
