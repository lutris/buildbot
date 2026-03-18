/*
 * Fixup header for Linux builds of ACGC-PC-Port.
 * Force-included before all sources to prevent conflicting declarations
 * of bcmp/bcopy/bzero between the decomp's libultra.h and glibc's strings.h.
 *
 * On Linux, glibc's strings.h declares bcmp/bcopy/bzero with different
 * signatures (const qualifiers, size_t vs u32) than the decomp's libultra.h.
 * Since these are ABI-compatible on i686, we simply block strings.h and let
 * libultra.h provide the only declarations.
 */
#ifndef ACGC_LINUX_FIXUP_H
#define ACGC_LINUX_FIXUP_H

/* Enable GNU extensions (needed for Dl_info, dladdr in pc_main.c) */
#ifndef _GNU_SOURCE
#define _GNU_SOURCE
#endif

/* Force-include errno.h so _GNU_SOURCE takes effect, then undef the errno
 * macro. The decomp uses "errno" as a struct field name (pad->now.errno)
 * which conflicts with glibc's #define errno (*__errno_location()). */
#include <errno.h>
#undef errno

/* Block glibc strings.h to avoid conflicting bcmp/bcopy declarations */
#define _STRINGS_H 1

#endif
