"""Script used to gather runtime libraries"""
import os
import subprocess
import shutil
import logging


def get_logger():
    """Logger setup"""
    logger = logging.getLogger("lutrisrt")
    logger.setLevel(logging.DEBUG)
    formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    handler = logging.StreamHandler()
    handler.setLevel(logging.DEBUG)
    handler.setFormatter(formatter)
    logger.addHandler(handler)
    return logger


LOGGER = get_logger()


LDCONFIG_PATH = "/sbin/ldconfig"
RUNTIME_DIR = "runtime"


def get_runtime_name() -> str:
    """Return the runtime name"""
    release_name = subprocess.check_output(["lsb_release", "-is"]).decode().strip()
    version = subprocess.check_output(["lsb_release", "-rs"]).decode().strip()
    return f"{release_name}-{version}"


def get_libs() -> dict:
    """Return a mapping of package name to .so libraries"""
    runtime_name = get_runtime_name()
    package_file = f"{runtime_name}.packages"
    LOGGER.info("Getting packages from %s", package_file)
    libs = {}
    with open(package_file, 'r', encoding="utf-8") as packages:
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


def get_ldconfig_libs(arch) -> list:
    """Return libs available when running ldconfig -p"""
    ldconfig = subprocess.Popen([LDCONFIG_PATH, '-p'],
                                stdout=subprocess.PIPE).communicate()[0]
    return [line.strip().split()
            for line in ldconfig.decode().split('\n')
            if line.startswith('\t') and arch in line]


def find_lib_paths(required_libs, arch="x86_64") -> list:
    """Return library paths needed by the runtime"""
    lib_paths = []
    ld_libs = []
    for parts in get_ldconfig_libs(arch):
        if parts[0] in required_libs:
            LOGGER.info("Found %s", parts[0])
            lib_paths.append(parts[-1])
            ld_libs.append(parts[0])
    libs_not_found = list(set(required_libs) - set(ld_libs))
    for lib in libs_not_found[:]:
        if os.path.exists(lib):
            LOGGER.info("Found %s", lib)
            lib_paths.append(lib)
            libs_not_found.remove(lib)
    if len(libs_not_found) > 0:
        LOGGER.warning('Required libraries not found: %s', ' '.join(libs_not_found))
    return lib_paths


def build_runtime(arch):
    """Copy libraries from system folders to runtime"""
    required_libs = []
    libs = get_libs()
    LOGGER.info("Installing packages %s", " ".join(libs.keys()))
    subprocess.Popen([
        'sudo',
        'apt-get',
        'install',
    ] + list(libs.keys())).communicate()
    for lib_list in libs.values():
        required_libs += lib_list
    lib_paths = find_lib_paths(required_libs, arch="x86_64")
    runtime_dir = "-".join([get_runtime_name(), arch])
    if not os.path.exists(runtime_dir):
        os.makedirs(runtime_dir)
    for lib in lib_paths:
        if os.path.exists(lib):
            shutil.copy(lib, runtime_dir)
        else:
            LOGGER.warning("Library not found: %s", lib)


if __name__ == "__main__":
    build_runtime("x86_64")
    build_runtime("i386")
