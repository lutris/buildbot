#!/bin/bash

set -e

GAME_PATCH=1
WINEX11_PATCH=1
CORE_PATCH=1
HOTFIX_PATCH=1
MFPLAT_PATCH=1
PERFORMANCE_PATCH=1
REVERT_PATCH=1

highlight_start='\033[7m'
highlight_end='\033[0m'

#if [ $1 = fshack ]; then
    FSHACK=1
#fi

if [ $1 = pa ]; then
    FSHACK=1
    PA_ENABLE=1
fi

### (1) PREP SECTION ###

    #WINE STAGING
    cd wine-staging-src
    git reset --hard HEAD
    git clean -dfx

    # faudio revert fix in staging:
    patch -Np1 < ../patches/hotfixes/staging/x3daudio_staging_revert.patch

    echo -e ""$highlight_start"Syscall emu"$highlight_end""
    patch -Np1 < ../patches/core/29-stg_syscall_emu-009.patch

    cd ..

### END PREP SECTION ###

### (2) WINE PATCHING ###

    cd wine-src
    git reset --hard HEAD
    git clean -dfx

### (2-1) PROBLEMATIC COMMIT REVERT SECTION ###

if [ $REVERT_PATCH = 1 ]; then

 if [ $MFPLAT_PATCH = 1 ]; then

    # https://github.com/ValveSoftware/Proton/issues/1295#issuecomment-859185208
    echo -e ""$highlight_start"these break Tokyo Xanadu Xe+"$highlight_end""
    git revert --no-commit 2ad44002da683634de768dbe49a0ba09c5f26f08
    git revert --no-commit dfa4c07941322dbcad54507cd0acf271a6c719ab

    echo -e ""$highlight_start"revert in favor of proton stub to allow ffxiv intro videos to work"$highlight_end""
    git revert --no-commit 98a2689f76ecbe097a0219d7ee332b4f6382bc59
    git revert --no-commit 186b99c2acbcd6c172e73db6f40aa8da6e7d07dd
    git revert --no-commit 83023a9f2b4840a97c5b587a2ba6c2f05a44b7b0
    git revert --no-commit 8c7ad5fc397e4814c33fa4b85be505db94d70016
    git revert --no-commit fc5719e4c57079b19bde8d169bf0b55194649e73
    git revert --no-commit 766617d6f0e50b03e9fd43b4bc29bdcddb19daf1
    git revert --no-commit 91c993bb78f50ea2d4c8159bda87901364c432bb
    git revert --no-commit 940110d38700808563ee17d77cd59c45c00fd716
    git revert --no-commit 177c232936dbc17cf212aed389f312d543d0c432
    git revert --no-commit 1541d6b6d8877b9799219e1f56c460b4ccd4744c
    git revert --no-commit 22472a3feb84a1d1857a035feb9883fdce39f6bb
    git revert --no-commit b1fc2a49ffe5573d20d5972a8900ef9b5cc3ae83
    git revert --no-commit a7508d54db6ef67b139fe15e964c644a304e30ce
    git revert --no-commit fa3fa0e3d5ee2d7e3a6afc67997a38c2fae6e8dc
    git revert --no-commit 85747f0abe0b013d9f287a33e10738e28d7418e9

    echo -e ""$highlight_start"mfplat early reverts to re-enable staging mfplat patches"$highlight_end""
    git revert --no-commit 11d1e967b6be4e948ad49cc893e27150c220b02d
    git revert --no-commit cb41e4b1753891f5aa22cb617e8dd124c3dd8983
    git revert --no-commit 03d92af78a5000097b26560bba97320eb013441a
    git revert --no-commit 4d2a628dfe9e4aad9ba772854717253d0c6a7bb7
    git revert --no-commit 78f916f598b4e0acadbda2c095058bf8a268eb72
    git revert --no-commit 4f58d8144c5c1d3b86e988f925de7eb02c848e6f
    git revert --no-commit 747905c674d521b61923a6cff1d630c85a74d065
    git revert --no-commit f3624e2d642c4f5c1042d24a70273db4437fcef9
    git revert --no-commit 769057b9b281eaaba7ee438dedb7f922b0903472
    git revert --no-commit 639c04a5b4e1ffd1d8328f60af998185a04d0c50
    git revert --no-commit 54f825d237c1dcb0774fd3e3f4cfafb7c243aab5
    git revert --no-commit cad38401bf091917396b24ad9c92091760cc696f
    git revert --no-commit 894e0712459ec2d48b1298724776134d2a966f66
    git revert --no-commit 42da77bbcfeae16b5f138ad3f2a3e3030ae0844b
    git revert --no-commit 2f7e7d284bddd27d98a17beca4da0b6525d72913
    git revert --no-commit f4b3eb7efbe1d433d7dcf850430f99f0f0066347
    git revert --no-commit 72b3cb68a702284122a16cbcdd87a621c29bb7a8
    git revert --no-commit a1a51f54dcb3863f9accfbf8c261407794d2bd13
    git revert --no-commit 3e0a9877eafef1f484987126cd453cc36cfdeb42
    git revert --no-commit 5d0858ee9887ef5b99e09912d4379880979ab974
    git revert --no-commit d1662e4beb4c1b757423c71107f7ec115ade19f5
    git revert --no-commit dab54bd849cd9f109d1a9d16cb171eddec39f2a1
    git revert --no-commit 3864d2355493cbadedf59f0c2ee7ad7a306fad5a
    git revert --no-commit fca2f6c12b187763eaae23ed4932d6d049a469c3
    git revert --no-commit 63fb4d8270d1db7a0034100db550f54e8d9859f1
    git revert --no-commit 25adac6ede88d835110be20de0164d28c2187977
    git revert --no-commit dc1a1ae450f1119b1f5714ed99b6049343676293
    git revert --no-commit aafbbdb8bcc9b668008038dc6fcfba028c4cc6f6
    git revert --no-commit 682093d0bdc24a55fcde37ca4f9cc9ed46c3c7df
    git revert --no-commit 21dc092b910f80616242761a00d8cdab2f8aa7bd
    git revert --no-commit d7175e265537ffd24dbf8fd3bcaaa1764db03e13
    git revert --no-commit 5306d0ff3c95e7b9b1c77fa2bb30b420d07879f7
    git revert --no-commit 00bc5eb73b95cbfe404fe18e1d0aadacc8ab4662
    git revert --no-commit a855591fd29f1f47947459f8710b580a4f90ce3a
    git revert --no-commit 34d85311f33335d2babff3983bb96fb0ce9bae5b
    git revert --no-commit 42c82012c7ac992a98930011647482fc94c63a87
    git revert --no-commit 4398e8aba2d2c96ee209f59658c2aa6caf26687a
    git revert --no-commit c9f5903e5a315989d03d48e4a53291be48fd8d89
    git revert --no-commit 56dde41b6d91c589d861dca5d50ffa9f607da1db
    git revert --no-commit c3811e84617e409875957b3d0b43fc5be91f01f6
    git revert --no-commit 799c7704e8877fe2ee73391f9f2b8d39e222b8d5
    git revert --no-commit 399ccc032750e2658526fc70fa0bfee7995597df
    git revert --no-commit f7b45d419f94a6168e3d9a97fb2df21f448446f1
    git revert --no-commit 6cb1d1ec4ffa77bbc2223703b93033bd86730a60
    git revert --no-commit 7c02cd8cf8e1b97df8f8bfddfeba68d7c7b4f820
    git revert --no-commit 6f8d366b57e662981c68ba0bd29465f391167de9
    git revert --no-commit 74c2e9020f04b26e7ccf217d956ead740566e991
    git revert --no-commit 04d94e3c092bbbaee5ec1331930b11af58ced629
    git revert --no-commit 538b86bfc640ddcfd4d28b1e2660acdef0ce9b08
    git revert --no-commit 3b8579d8a570eeeaf0d4e0667e748d484df138aa
    git revert --no-commit 970c1bc49b804d0b7fa515292f27ac2fb4ef29e8
    git revert --no-commit f26e0ba212e6164eb7535f472415334d1a9c9044
    git revert --no-commit bc52edc19d8a45b9062d9568652403251872026e
    git revert --no-commit b3655b5be5f137281e8757db4e6985018b21c296
    git revert --no-commit 95ffc879882fdedaf9fdf40eb1c556a025ae5bfd
    git revert --no-commit 0dc309ef6ac54484d92f6558d6ca2f8e50eb28e2
    git revert --no-commit 25948222129fe48ac4c65a4cf093477d19d25f18
    git revert --no-commit 7f481ea05faf02914ecbc1932703e528511cce1a
    git revert --no-commit c45be242e5b6bc0a80796d65716ced8e0bc5fd41
    git revert --no-commit d5154e7eea70a19fe528f0de6ebac0186651e0f3
    git revert --no-commit d39747f450ad4356868f46cfda9a870347cce9dd
    git revert --no-commit 250f86b02389b2148471ad67bcc0775ff3b2c6ba
    git revert --no-commit 40ced5e054d1f16ce47161079c960ac839910cb7
    git revert --no-commit 8bd3c8bf5a9ea4765f791f1f78f60bcf7060eba6
    git revert --no-commit 87e4c289e46701c6f582e95c330eefb6fc5ec68a
    git revert --no-commit 51b6d45503e5849f28cce1a9aa9b7d3dba9de0fe
    git revert --no-commit c76418fbfd72e496c800aec28c5a1d713389287f
    git revert --no-commit 37e9f0eadae9f62ccae8919a92686695927e9274
    git revert --no-commit dd182a924f89b948010ecc0d79f43aec83adfe65
    git revert --no-commit 4f10b95c8355c94e4c6f506322b80be7ae7aa174
    git revert --no-commit 4239f2acf77d9eaa8166628d25c1336c1599df33
    git revert --no-commit 3dd8eeeebdeec619570c764285bdcae82dee5868
    git revert --no-commit 831c6a88aab78db054beb42ca9562146b53963e7
    git revert --no-commit 2d0dc2d47ca6b2d4090dfe32efdba4f695b197ce

    fi

    echo -e ""$highlight_start"revert faudio updates -- WINE faudio does not have WMA decoding (notably needed for Skyrim voices) so we still need to provide our own with gstreamer support"$highlight_end""
    git revert --no-commit a80c5491600c00a54dfc8251a75706ce86d2a08f
    git revert --no-commit 22c26a2dde318b5b370fc269cab871e5a8bc4231
    patch -RNp1 < ../patches/hotfixes/pending/revert-d8be858-faudio.patch

fi

### END PROBLEMATIC COMMIT REVERT SECTION ###


### (2-2) WINE STAGING APPLY SECTION ###

    # these cause window freezes/hangs with origin
    # -W winex11-_NET_ACTIVE_WINDOW \
    # -W winex11-WM_WINDOWPOSCHANGING \

    # This was found to cause hangs in various games
    # Notably DOOM Eternal and Resident Evil Village
    # -W ntdll-NtAlertThreadByThreadId

    # Sancreed — 11/21/2021
    # Heads up, it appears that a bunch of Ubisoft Connect games (3/3 I had installed and could test) will crash
    # almost immediately on newer Wine Staging/TKG inside pe_load_debug_info function unless the dbghelp-Debug_Symbols staging # patchset is disabled.
    # -W dbghelp-Debug_Symbols

    # Disable when using external FAudio
    # -W xactengine3_7-callbacks \

    if [ $PA_ENABLE = 1 ]; then
        echo -e ""$highlight_start"applying staging patches"$highlight_end""
        ../wine-staging-src/patches/patchinstall.sh DESTDIR="." --all \
        -W winex11-_NET_ACTIVE_WINDOW \
        -W winex11-WM_WINDOWPOSCHANGING \
        -W winex11-MWM_Decorations \
        -W winex11-key_translation \
        -W dbghelp-Debug_Symbols \
        -W xactengine3_7-callbacks \
        -W winemenubuilder-integration \
        -W dwrite-FontFallback
    else
        echo -e ""$highlight_start"applying staging patches"$highlight_end""
        ../wine-staging-src/patches/patchinstall.sh DESTDIR="." --all \
        -W winex11-_NET_ACTIVE_WINDOW \
        -W winex11-WM_WINDOWPOSCHANGING \
        -W winex11-MWM_Decorations \
        -W winex11-key_translation \
        -W dbghelp-Debug_Symbols \
        -W xactengine3_7-callbacks \
        -W winemenubuilder-integration \
        -W dwrite-FontFallback \
        -W winepulse-PulseAudio_Support
    fi

### END WINE STAGING APPLY SECTION ###

### (2-3) GAME PATCH SECTION ###

if [ $GAME_PATCH = 1 ]; then

    echo -e ""$highlight_start"mech warrior online, enabled with WINE_MWO_HACK=1"$highlight_end""
    patch -Np1 < ../patches/app-patches/mwo.patch

    echo -e ""$highlight_start"ffxiv"$highlight_end""
    patch -Np1 < ../patches/app-patches/ffxiv-launcher-fix.patch

    echo -e ""$highlight_start"assetto corsa"$highlight_end""
    patch -Np1 < ../patches/app-patches/assettocorsa-hud.patch

    echo -e ""$highlight_start"mk11 patch"
    # this is needed so that online multi-player does not crash
    patch -Np1 < ../patches/app-patches/mk11.patch

    echo -e ""$highlight_start"killer instinct vulkan fix"$highlight_end""
    patch -Np1 < ../patches/app-patches/killer-instinct-winevulkan_fix.patch

    echo -e ""$highlight_start"Castlevania Advance fix"$highlight_end""
    patch -Np1 < ../patches/app-patches/castlevania-advance-collection.patch

    echo -e ""$highlight_start"Lego Island fix"$highlight_end""
    patch -Np1 < ../patches/app-patches/legoisland_168726.patch

    echo -e ""$highlight_start"Planet Zoo fix"$highlight_end""
    patch -Np1 < ../patches/app-patches/planetzoo.patch

    echo -e ""$highlight_start"valve rdr2 fixes"$highlight_end""
    patch -Np1 < ../patches/app-patches/rdr2-fixes.patch

    echo -e ""$highlight_start"valve rdr2 bcrypt fixes"$highlight_end""
    patch -Np1 < ../patches/app-patches/bcrypt_rdr2_fixes.patch

    echo -e ""$highlight_start"proton quake champions patches"$highlight_end""
    patch -Np1 < ../patches/app-patches/quake_champions_syscall.patch

    echo -e ""$highlight_start"rockstar installer heap fix"$highlight_end""
    patch -Np1 < ../patches/app-patches/rockstar_installer_fix_heap.patch

    echo -e ""$highlight_start"Adds a stub for StorageDeviceSeekPenaltyProperty, needed for Star Citizen 3.13"$highlight_end""
    patch -Np1 < ../patches/app-patches/star-citizen-StorageDeviceSeekPenaltyProperty.patch

    echo -e ""$highlight_start"Makes macromedia director launchable"$highlight_end""
    patch -Np1 < ../patches/app-patches/macromedia_director.patch

    echo -e ""$highlight_start"dotnetfx35.exe: Add stub program."$highlight_end""
    patch -Np1 < ../patches/app-patches/dotnetfx35_stuf.patch
    
fi

### END GAME PATCH SECTION ###

### (2-4) CORE PATCH SECTION ###

if [ $CORE_PATCH = 1 ]; then

    echo -e ""$highlight_start"clock monotonic"$highlight_end""
    patch -Np1 < ../patches/core/01-use_clock_monotonic.patch

    echo -e ""$highlight_start"applying fsync patches"$highlight_end""
    patch -Np1 < ../patches/core/02-fsync_staging.patch

    echo -e ""$highlight_start"proton futex waitv patches"$highlight_end""
    patch -Np1 < ../patches/core/03-fsync_futex_waitv.patch

    echo -e ""$highlight_start"LAA"$highlight_end""
    patch -Np1 < ../patches/core/04-LAA_staging.patch

    echo -e ""$highlight_start"pa-audio"$highlight_end""
    patch -Np1 < ../patches/core/05-pa-staging.patch

    echo -e ""$highlight_start"Apply Lutris registry patch"$highlight_end""
    patch -Np1 < ../patches/registry/LutrisClient-registry-overrides-section.patch

    echo -e ""$highlight_start"amd ags"$highlight_end""
    patch -Np1 < ../patches/core/08-amd_ags.patch

    echo -e ""$highlight_start"msvcrt overrides"$highlight_end""
    patch -Np1 < ../patches/core/09-msvcrt_nativebuiltin.patch

    echo -e ""$highlight_start"atiadlxx needed for cod games"$highlight_end""
    patch -Np1 < ../patches/core/10-atiadlxx.patch

    echo -e ""$highlight_start"powershell add wrapper"$highlight_end""
    patch -Np1 < ../patches/core/11-powershell-add-wrapper.patch

    echo -e ""$highlight_start"valve registry entries"

    echo -e ""$highlight_start"registry 1"$highlight_end""
    patch -Np1 < ../patches/registry/01_wolfenstein2_registry.patch
    echo -e ""$highlight_start"registry 2"$highlight_end""
    patch -Np1 < ../patches/registry/02_rdr2_registry.patch
    echo -e ""$highlight_start"registry 3"$highlight_end""
    patch -Np1 < ../patches/registry/03_nier_sekiro_ds3_registry.patch
    echo -e ""$highlight_start"registry 4"$highlight_end""
    patch -Np1 < ../patches/registry/04_cod_registry.patch
    echo -e ""$highlight_start"registry 5"$highlight_end""
    patch -Np1 < ../patches/registry/05_spellforce_registry.patch
    echo -e ""$highlight_start"registry 6"$highlight_end""
    patch -Np1 < ../patches/registry/06_shadow_of_war_registry.patch
    echo -e ""$highlight_start"registry 7"$highlight_end""
    patch -Np1 < ../patches/registry/07_nfs_registry.patch
    echo -e ""$highlight_start"registry 8"$highlight_end""
    patch -Np1 < ../patches/registry/08_FH4_registry.patch
    echo -e ""$highlight_start"registry 9"$highlight_end""
    patch -Np1 < ../patches/registry/09_nvapi_registry.patch
    echo -e ""$highlight_start"registry 10"$highlight_end""
    patch -Np1 < ../patches/registry/10-Civ6Launcher_Workaround.patch
    echo -e ""$highlight_start"registry 11"$highlight_end""
    patch -Np1 < ../patches/registry/11-Dirt_5.patch
    echo -e ""$highlight_start"registry 12"$highlight_end""
    patch -Np1 < ../patches/registry/12_death_loop_registry.patch
    echo -e ""$highlight_start"registry 13"$highlight_end""
    patch -Np1 < ../patches/registry/13_disable_libglesv2_for_nw.js.patch
    echo -e ""$highlight_start"registry 14"$highlight_end""
    patch -Np1 < ../patches/registry/14_atiadlxx_builtin_for_gotg.patch
    echo -e ""$highlight_start"registry 15"$highlight_end""
    patch -Np1 < ../patches/registry/15-msedgewebview-registry.patch
    echo -e ""$highlight_start"registry 16"$highlight_end""
    patch -Np1 < ../patches/registry/16-FH5-amd_ags_registry.patch
    echo -e ""$highlight_start"registry 17"$highlight_end""
    patch -Np1 < ../patches/registry/17-Age-of-Empires-IV-registry.patch
    echo -e ""$highlight_start"registry 18"$highlight_end""
    patch -Np1 < ../patches/registry/18_sims3_mshtml.patch
    echo -e ""$highlight_start"registry 19"$highlight_end""
    patch -Np1 < ../patches/registry/19-winemenubuilder.patch

    echo -e ""$highlight_start"apply staging bcrypt patches on top of rdr2 fixes"$highlight_end""
    patch -Np1 < ../patches/hotfixes/staging/0002-bcrypt-Add-support-for-calculating-secret-ecc-keys.patch
    patch -Np1 < ../patches/hotfixes/staging/0003-bcrypt-Add-support-for-OAEP-padded-asymmetric-key-de.patch
    patch -Np1 < ../patches/hotfixes/staging/bcrypt_BGenerateKeyPair_ECDH_P384.patch

    echo -e ""$highlight_start"set prefix win10"$highlight_end""
    patch -Np1 < ../patches/core/12-win10_default.patch

    echo -e ""$highlight_start"keyboard+mouse focus fixes"$highlight_end""
    patch -Np1 < ../patches/core/16-keyboard-input-and-mouse-focus-fixes.patch

    echo -e ""$highlight_start"CPU topology overrides"$highlight_end""
    patch -Np1 < ../patches/core/17-cpu-topology-overrides.patch

    if [ $FSHACK = 1 ]; then

    echo -e ""$highlight_start"fullscreen hack"
    
    echo -e ""$highlight_start"fshack 1"$highlight_end""
    patch -Np1 < ../patches/fshack/01-vulkan-1-prefer-builtin.patch

    echo -e ""$highlight_start"fshack 2"$highlight_end""
    patch -Np1 < ../patches/fshack/02-vulkan-childwindow.patch

    echo -e ""$highlight_start"fshack 3"$highlight_end""
    patch -Np1 < ../patches/fshack/03-window-manager-fixes.patch

    echo -e ""$highlight_start"fshack 4"$highlight_end""
    patch -Np1 < ../patches/fshack/04-fullscreen-hack.patch

    echo -e ""$highlight_start"Winevulkan"$highlight_end""
    patch -Np1 < ../patches/fshack/09-winevulkan_update.mypatch

    echo -e ""$highlight_start"OpenXR"$highlight_end""
    patch -Np1 < ../patches/fshack/07-OpenXR-patches.patch
    
    echo -e ""$highlight_start"Shared resources"$highlight_end""
    patch -Np1 < ../patches/fshack/08-shared_resources.patch

    echo -e ""$highlight_start"fullscreen hack fsr patch"$highlight_end""
    patch -Np1 < ../patches/fshack/05-fshack_amd_fsr.patch

    echo -e ""$highlight_start"Adds envar to fake reported resolution"$highlight_end""
    patch -Np1 < ../patches/fshack/06-fake_current_res_patches.patch

    echo -e ""$highlight_start"fsr add more resolutions"$highlight_end""
    patch -Np1 < ../patches/fshack/10-add_more_fsr_resolutions.patch

    fi

    echo -e ""$highlight_start"QPC performance patch"$highlight_end""
    patch -Np1 < ../patches/core/21-QPC.patch

    echo -e ""$highlight_start"LFH performance patch"$highlight_end""
    patch -Np1 < ../patches/core/22-LFH.patch

    echo -e ""$highlight_start"proton battleye patches"$highlight_end""
    patch -Np1 < ../patches/core/20-battleye_patches.patch

    echo -e ""$highlight_start"tabtip uiautomationcore patches"$highlight_end""
    patch -Np1 < ../patches/core/23-tabtip-uiautomationcore.patch

    echo -e ""$highlight_start"proton eac patches"$highlight_end""
    patch -Np1 < ../patches/core/24-eac_support.patch

    echo -e ""$highlight_start"Apply white theme"$highlight_end""
    patch -Np1 < ../patches/core/25-josh-flat-theme.patch

    echo -e ""$highlight_start"Disable nvapi"$highlight_end""
    patch -Np1 < ../patches/core/26-nvidia-hate.patch

    echo -e ""$highlight_start"AC Odyssey dialogue fix"$highlight_end""
    patch -Np1 < ../patches/app-patches/ac_odyssey_dialogues_fix.patch

    echo -e ""$highlight_start"Mono envars"$highlight_end""
    patch -Np1 < ../patches/core/27-monogecko_runtime.patch

    echo -e ""$highlight_start"Wine name change"$highlight_end""
    patch -Np1 < ../patches/core/30-wine-name.patch

fi

### END CORE PATCH SECTION ###

### START MFPLAT PATCH SECTION ###

if [ $MFPLAT_PATCH = 1 ]; then

    echo -e ""$highlight_start"mfplat 1"$highlight_end""
    patch -Np1 < ../patches/hotfixes/mfplat/mfplat-reverts/0001-Revert-winegstreamer-Get-rid-of-the-WMReader-typedef.patch
    echo -e ""$highlight_start"mfplat 2"$highlight_end""
    patch -Np1 < ../patches/hotfixes/mfplat/mfplat-reverts/0002-Revert-wmvcore-Move-the-async-reader-implementation-.patch
    echo -e ""$highlight_start"mfplat 3"$highlight_end""
    patch -Np1 < ../patches/hotfixes/mfplat/mfplat-reverts/0003-Revert-winegstreamer-Get-rid-of-the-WMSyncReader-typ.patch
    echo -e ""$highlight_start"mfplat 4"$highlight_end""
    patch -Np1 < ../patches/hotfixes/mfplat/mfplat-reverts/0004-Revert-wmvcore-Move-the-sync-reader-implementation-t.patch
    echo -e ""$highlight_start"mfplat 5"$highlight_end""
    patch -Np1 < ../patches/hotfixes/mfplat/mfplat-reverts/0005-Revert-winegstreamer-Translate-GST_AUDIO_CHANNEL_POS.patch
    echo -e ""$highlight_start"mfplat 6"$highlight_end""
    patch -Np1 < ../patches/hotfixes/mfplat/mfplat-reverts/0006-Revert-winegstreamer-Trace-the-unfiltered-caps-in-si.patch
    echo -e ""$highlight_start"mfplat 7"$highlight_end""
    patch -Np1 < ../patches/hotfixes/mfplat/mfplat-reverts/0007-Revert-winegstreamer-Avoid-seeking-past-the-end-of-a.patch
    echo -e ""$highlight_start"mfplat 8"$highlight_end""
    patch -Np1 < ../patches/hotfixes/mfplat/mfplat-reverts/0008-Revert-winegstreamer-Avoid-passing-a-NULL-buffer-to-.patch
    echo -e ""$highlight_start"mfplat 9"$highlight_end""
    patch -Np1 < ../patches/hotfixes/mfplat/mfplat-reverts/0009-Revert-winegstreamer-Use-array_reserve-to-reallocate.patch
    echo -e ""$highlight_start"mfplat 10"$highlight_end""
    patch -Np1 < ../patches/hotfixes/mfplat/mfplat-reverts/0010-Revert-winegstreamer-Handle-zero-length-reads-in-src.patch
    echo -e ""$highlight_start"mfplat 11"$highlight_end""
    patch -Np1 < ../patches/hotfixes/mfplat/mfplat-reverts/0011-Revert-winegstreamer-Convert-the-Unix-library-to-the.patch
    echo -e ""$highlight_start"mfplat 12"$highlight_end""
    patch -Np1 < ../patches/hotfixes/mfplat/mfplat-reverts/0012-Revert-winegstreamer-Return-void-from-wg_parser_stre.patch
    echo -e ""$highlight_start"mfplat 13"$highlight_end""
    patch -Np1 < ../patches/hotfixes/mfplat/mfplat-reverts/0013-Revert-winegstreamer-Move-Unix-library-definitions-i.patch
    echo -e ""$highlight_start"mfplat 14"$highlight_end""
    patch -Np1 < ../patches/hotfixes/mfplat/mfplat-reverts/0014-Revert-winegstreamer-Remove-the-no-longer-used-start.patch
    echo -e ""$highlight_start"mfplat 15"$highlight_end""
    patch -Np1 < ../patches/hotfixes/mfplat/mfplat-reverts/0015-Revert-winegstreamer-Set-unlimited-buffering-using-a.patch
    echo -e ""$highlight_start"mfplat 16"$highlight_end""
    patch -Np1 < ../patches/hotfixes/mfplat/mfplat-reverts/0016-Revert-winegstreamer-Initialize-GStreamer-in-wg_pars.patch
    echo -e ""$highlight_start"mfplat 17"$highlight_end""
    patch -Np1 < ../patches/hotfixes/mfplat/mfplat-reverts/0017-Revert-winegstreamer-Use-a-single-wg_parser_create-e.patch
    echo -e ""$highlight_start"mfplat 18"$highlight_end""
    patch -Np1 < ../patches/hotfixes/mfplat/mfplat-reverts/0018-Revert-winegstreamer-Fix-return-code-in-init_gst-fai.patch
    echo -e ""$highlight_start"mfplat 19"$highlight_end""
    patch -Np1 < ../patches/hotfixes/mfplat/mfplat-reverts/0019-Revert-winegstreamer-Allocate-source-media-buffers-i.patch
    echo -e ""$highlight_start"mfplat 20"$highlight_end""
    patch -Np1 < ../patches/hotfixes/mfplat/mfplat-reverts/0020-Revert-winegstreamer-Duplicate-source-shutdown-path-.patch
    echo -e ""$highlight_start"mfplat 21"$highlight_end""
    patch -Np1 < ../patches/hotfixes/mfplat/mfplat-reverts/0021-Revert-winegstreamer-Properly-clean-up-from-failure-.patch
    echo -e ""$highlight_start"mfplat 22"$highlight_end""
    patch -Np1 < ../patches/hotfixes/mfplat/mfplat-reverts/0022-Revert-winegstreamer-Factor-out-more-of-the-init_gst.patch
    echo -e ""$highlight_start"mfplat 23"$highlight_end""
    patch -Np1 < ../patches/hotfixes/mfplat/mfplat-streaming-support/0001-winegstreamer-Activate-source-pad-in-push-mode-if-it.patch
    echo -e ""$highlight_start"mfplat 24"$highlight_end""
    patch -Np1 < ../patches/hotfixes/mfplat/mfplat-streaming-support/0002-winegstreamer-Push-stream-start-and-segment-events-i.patch
    echo -e ""$highlight_start"mfplat 25"$highlight_end""
    patch -Np1 < ../patches/hotfixes/mfplat/mfplat-streaming-support/0003-winegstreamer-Introduce-H.264-decoder-transform.patch
    echo -e ""$highlight_start"mfplat 26"$highlight_end""
    patch -Np1 < ../patches/hotfixes/mfplat/mfplat-streaming-support/0004-winegstreamer-Implement-GetInputAvailableType-for-de.patch
    echo -e ""$highlight_start"mfplat 27"$highlight_end""
    patch -Np1 < ../patches/hotfixes/mfplat/mfplat-streaming-support/0005-winegstreamer-Implement-GetOutputAvailableType-for-d.patch
    echo -e ""$highlight_start"mfplat 28"$highlight_end""
    patch -Np1 < ../patches/hotfixes/mfplat/mfplat-streaming-support/0006-winegstreamer-Implement-SetInputType-for-decode-tran.patch
    echo -e ""$highlight_start"mfplat 29"$highlight_end""
    patch -Np1 < ../patches/hotfixes/mfplat/mfplat-streaming-support/0007-winegstreamer-Implement-SetOutputType-for-decode-tra.patch
    echo -e ""$highlight_start"mfplat 30"$highlight_end""
    patch -Np1 < ../patches/hotfixes/mfplat/mfplat-streaming-support/0008-winegstreamer-Implement-Get-Input-Output-StreamInfo-.patch
    echo -e ""$highlight_start"mfplat 31"$highlight_end""
    patch -Np1 < ../patches/hotfixes/mfplat/mfplat-streaming-support/0009-winegstreamer-Add-push-mode-path-for-wg_parser.patch
    echo -e ""$highlight_start"mfplat 32"$highlight_end""
    patch -Np1 < ../patches/hotfixes/mfplat/mfplat-streaming-support/0010-winegstreamer-Implement-Process-Input-Output-for-dec.patch
    echo -e ""$highlight_start"mfplat 33"$highlight_end""
    patch -Np1 < ../patches/hotfixes/mfplat/mfplat-streaming-support/0011-winestreamer-Implement-ProcessMessage-for-decoder-tr.patch
    echo -e ""$highlight_start"mfplat 34"$highlight_end""
    patch -Np1 < ../patches/hotfixes/mfplat/mfplat-streaming-support/0012-winegstreamer-Semi-stub-GetAttributes-for-decoder-tr.patch
    echo -e ""$highlight_start"mfplat 35"$highlight_end""
    patch -Np1 < ../patches/hotfixes/mfplat/mfplat-streaming-support/0013-winegstreamer-Register-the-H.264-decoder-transform.patch
    echo -e ""$highlight_start"mfplat 36"$highlight_end""
    patch -Np1 < ../patches/hotfixes/mfplat/mfplat-streaming-support/0014-winegstreamer-Introduce-AAC-decoder-transform.patch
    echo -e ""$highlight_start"mfplat 37"$highlight_end""
    patch -Np1 < ../patches/hotfixes/mfplat/mfplat-streaming-support/0015-winegstreamer-Register-the-AAC-decoder-transform.patch
    echo -e ""$highlight_start"mfplat 38"$highlight_end""
    patch -Np1 < ../patches/hotfixes/mfplat/mfplat-streaming-support/0016-winegstreamer-Rename-GStreamer-objects-to-be-more-ge.patch
    echo -e ""$highlight_start"mfplat 39"$highlight_end""
    patch -Np1 < ../patches/hotfixes/mfplat/mfplat-streaming-support/0017-winegstreamer-Report-streams-backwards-in-media-sour.patch
    echo -e ""$highlight_start"mfplat 40"$highlight_end""
    patch -Np1 < ../patches/hotfixes/mfplat/mfplat-streaming-support/0018-winegstreamer-Implement-Process-Input-Output-for-aud.patch
    echo -e ""$highlight_start"mfplat 41"$highlight_end""
    patch -Np1 < ../patches/hotfixes/mfplat/mfplat-streaming-support/0019-winegstreamer-Implement-Get-Input-Output-StreamInfo-.patch
    echo -e ""$highlight_start"mfplat 42"$highlight_end""
    patch -Np1 < ../patches/hotfixes/mfplat/mfplat-streaming-support/0020-winegstreamer-Semi-stub-Get-Attributes-functions-for.patch
    echo -e ""$highlight_start"mfplat 43"$highlight_end""
    patch -Np1 < ../patches/hotfixes/mfplat/mfplat-streaming-support/0021-winegstreamer-Introduce-color-conversion-transform.patch
    echo -e ""$highlight_start"mfplat 44"$highlight_end""
    patch -Np1 < ../patches/hotfixes/mfplat/mfplat-streaming-support/0022-winegstreamer-Register-the-color-conversion-transfor.patch
    echo -e ""$highlight_start"mfplat 45"$highlight_end""
    patch -Np1 < ../patches/hotfixes/mfplat/mfplat-streaming-support/0023-winegstreamer-Implement-GetInputAvailableType-for-co.patch
    echo -e ""$highlight_start"mfplat 46"$highlight_end""
    patch -Np1 < ../patches/hotfixes/mfplat/mfplat-streaming-support/0024-winegstreamer-Implement-SetInputType-for-color-conve.patch
    echo -e ""$highlight_start"mfplat 47"$highlight_end""
    patch -Np1 < ../patches/hotfixes/mfplat/mfplat-streaming-support/0025-winegstreamer-Implement-GetOutputAvailableType-for-c.patch
    echo -e ""$highlight_start"mfplat 48"$highlight_end""
    patch -Np1 < ../patches/hotfixes/mfplat/mfplat-streaming-support/0026-winegstreamer-Implement-SetOutputType-for-color-conv.patch
    echo -e ""$highlight_start"mfplat 49"$highlight_end""
    patch -Np1 < ../patches/hotfixes/mfplat/mfplat-streaming-support/0027-winegstreamer-Implement-Process-Input-Output-for-col.patch
    echo -e ""$highlight_start"mfplat 50"$highlight_end""
    patch -Np1 < ../patches/hotfixes/mfplat/mfplat-streaming-support/0028-winegstreamer-Implement-ProcessMessage-for-color-con.patch
    echo -e ""$highlight_start"mfplat 51"$highlight_end""
    patch -Np1 < ../patches/hotfixes/mfplat/mfplat-streaming-support/0029-winegstreamer-Implement-Get-Input-Output-StreamInfo-.patch
    echo -e ""$highlight_start"mfplat 52"$highlight_end""
    patch -Np1 < ../patches/hotfixes/mfplat/mfplat-streaming-support/0030-mf-topology-Forward-failure-from-SetOutputType-when-.patch
    echo -e ""$highlight_start"mfplat 53"$highlight_end""
    patch -Np1 < ../patches/hotfixes/mfplat/mfplat-streaming-support/0031-winegstreamer-Handle-flush-command-in-audio-converst.patch
    echo -e ""$highlight_start"mfplat 54"$highlight_end""
    patch -Np1 < ../patches/hotfixes/mfplat/mfplat-streaming-support/0032-winegstreamer-In-the-default-configuration-select-on.patch
    echo -e ""$highlight_start"mfplat 55"$highlight_end""
    patch -Np1 < ../patches/hotfixes/mfplat/mfplat-streaming-support/0033-winegstreamer-Implement-MF_SD_LANGUAGE.patch
    echo -e ""$highlight_start"mfplat 56"$highlight_end""
    patch -Np1 < ../patches/hotfixes/mfplat/mfplat-streaming-support/0034-winegstreamer-Only-require-videobox-element-for-pars.patch
    echo -e ""$highlight_start"mfplat 57"$highlight_end""
    patch -Np1 < ../patches/hotfixes/mfplat/mfplat-streaming-support/0035-winegstreamer-Don-t-rely-on-max_size-in-unseekable-p.patch
    echo -e ""$highlight_start"mfplat 58"$highlight_end""
    patch -Np1 < ../patches/hotfixes/mfplat/mfplat-streaming-support/0036-winegstreamer-Implement-MFT_MESSAGE_COMMAND_FLUSH-fo.patch
    echo -e ""$highlight_start"mfplat 59"$highlight_end""
    patch -Np1 < ../patches/hotfixes/mfplat/mfplat-streaming-support/0037-winegstreamer-Default-Frame-size-if-one-isn-t-availa.patch
    echo -e ""$highlight_start"mfplat 60"$highlight_end""
    patch -Np1 < ../patches/hotfixes/mfplat/mfplat-streaming-support/0038-mfplat-Stub-out-MFCreateDXGIDeviceManager-to-avoid-t.patch
    echo -e ""$highlight_start"mfplat 61"$highlight_end""
    patch -Np1 < ../patches/hotfixes/mfplat/mfplat-streaming-support/0039-aperture-hotfix.patch

    echo -e ""$highlight_start"proton mfplat dll register patch"$highlight_end""
    patch -Np1 < ../patches/core/13-mediafoundation_dllreg.patch
    patch -Np1 < ../patches/core/14-mfplat-hacks.patch

    # Needed for Nier Replicant
    echo -e ""$highlight_start"proton mfplat nier replicant patch"$highlight_end""
    patch -Np1 < ../patches/hotfixes/staging/mfplat_dxgi_stub.patch

    # Needed for mfplat video format conversion, notably resident evil 8
    echo -e ""$highlight_start"proton mfplat video conversion patches"$highlight_end""
    patch -Np1 < ../patches/core/15-winegstreamer_updates.patch

    # Needed for godfall intro
    echo -e ""$highlight_start"mfplat godfall fix"$highlight_end""
    patch -Np1 < ../patches/hotfixes/mfplat/mfplat-godfall-hotfix.patch

    # missing http: scheme workaround see: https://github.com/ValveSoftware/Proton/issues/5195
    echo -e ""$highlight_start"The Good Life (1452500) workaround"$highlight_end""
    patch -Np1 < ../patches/app-patches/thegoodlife-mfplat-http-scheme-workaround.patch

    echo -e ""$highlight_start"FFXIV Video playback mfplat includes"$highlight_end""
    patch -Np1 < ../patches/app-patches/ffxiv-mfplat-additions.patch

fi

### END MFPLAT PATCH SECTION ###

### PERFORMANCE SECTION ###

if [ $PERFORMANCE_PATCH = 1 ]; then

    echo -e ""$highlight_start"Applying performance patches"

    echo -e ""$highlight_start"performance 1"$highlight_end""
    patch -Np1 < ../patches/performance/optimize-server-read-big-buffer.patch

    echo -e ""$highlight_start"performance 2"$highlight_end""
    patch -Np1 < ../patches/performance/ps0001-wininet-Improve-InternetGetConnectedStateExW-to-ha.patch

    echo -e ""$highlight_start"performance 3"$highlight_end""
    patch -Np1 < ../patches/performance/ps0010-netprofm-set-ret-NULL-if-no-more-connections.patch

    echo -e ""$highlight_start"performance 4"$highlight_end""
    patch -Np1 < ../patches/performance/ps0033-p0001-server-Don-t-reallocate-a-buffer-for-every-r.patch

    echo -e ""$highlight_start"performance 5"$highlight_end""
    patch -Np1 < ../patches/performance/ps0033-p0002-server-Don-t-reallocate-reply-when-size-chan.patch

    echo -e ""$highlight_start"performance 6"$highlight_end""
    patch -Np1 < ../patches/performance/ps0033-p0003-server-Always-send-replies-with-writev.patch

    echo -e ""$highlight_start"performance 7"$highlight_end""
    patch -Np1 < ../patches/performance/ps0033-p0004-server-Use-a-pool-for-small-most-thread_wait.patch

    echo -e ""$highlight_start"performance 8"$highlight_end""
    patch -Np1 < ../patches/performance/ps0084-wineboot-Generate-ProductId-from-host-s-machine-id.patch

    echo -e ""$highlight_start"performance 9"$highlight_end""
    patch -Np1 < ../patches/performance/ps0091-kernelbase-Cache-last-used-locale-sortguid-mapping.patch

    echo -e ""$highlight_start"performance 10"$highlight_end""
    patch -Np1 < ../patches/performance/ps0248-ntdll-server-Write-system-handle-info-directly-to-.patch

    echo -e ""$highlight_start"performance 11"$highlight_end""
    patch -Np1 < ../patches/performance/ps0264-p0002-server-Enable-link-time-optimization.patch

    echo -e ""$highlight_start"performance 12"$highlight_end""
    patch -Np1 < ../patches/performance/ps0299-p0001-fixup-server-Create-esync-file-descriptors-f.patch

    echo -e ""$highlight_start"performance 13"$highlight_end""
    patch -Np1 < ../patches/performance/ps0299-p0002-fixup-server-Create-eventfd-file-descriptors.patch

    echo -e ""$highlight_start"performance 14"$highlight_end""
    patch -Np1 < ../patches/performance/ps0299-p0003-fixup-server-Create-eventfd-descriptors-for-.patch

fi

### END PERFORMANCE SECTION ###

### WINEX11 SECTION ###

if [ $WINEX11_PATCH = 1 ]; then

    echo -e ""$highlight_start"Applying winex11 patches"

    echo -e ""$highlight_start"winex11 1"$highlight_end""
    patch -Np1 < ../patches/winex11/ps0019-winex11.drv-Add-a-taskbar-button-for-a-minimized-o.patch

    echo -e ""$highlight_start"winex11 2"$highlight_end""
    patch -Np1 < ../patches/winex11/unity-alt-tab-fix.patch

    echo -e ""$highlight_start"winex11 3"$highlight_end""
    patch -Np1 < ../patches/winex11/winex11_limit_resources-nmode.patch

    if [ $FSHACK = 1 ]; then
    
    echo -e ""$highlight_start"winex11 4"$highlight_end""
    patch -Np1 < ../patches/winex11/winex11.drv_fix_focus_delay.patch

    echo -e ""$highlight_start"winex11 5"$highlight_end""
    patch -Np1 < ../patches/winex11/winex11-fs-no_above_state.patch

    else

    echo -e ""$highlight_start"winex11 4"$highlight_end""
    patch -Np1 < ../patches/winex11/winex11-fs-no_above_state-nofshack.patch

    fi

fi

### END WINEX11 SECTION ###

### WINE HOTFIX SECTION ###

if [ $HOTFIX_PATCH = 1 ]; then

    echo -e ""$highlight_start"Applying performance patches"$highlight_end""

    # keep this in place, proton and wine tend to bounce back and forth and proton uses a different URL.
    # We can always update the patch to match the version and sha256sum even if they are the same version
#    echo -e ""$highlight_start"hotfix to update mono version"$highlight_end""
#    patch -Np1 < ../patches/hotfixes/pending/hotfix-update_mono_version.patch

    echo -e ""$highlight_start"add halo infinite patches"$highlight_end""
    patch -Np1 < ../patches/hotfixes/pending/halo-infinite-twinapi.appcore.dll.patch

    # https://github.com/Frogging-Family/wine-tkg-git/commit/ca0daac62037be72ae5dd7bf87c705c989eba2cb
    echo -e ""$highlight_start"unity crash hotfix"$highlight_end""
    patch -Np1 < ../patches/hotfixes/pending/unity_crash_hotfix.patch

fi

### END WINE HOTFIX SECTION ###

    ./dlls/winevulkan/make_vulkan
    ./tools/make_requests
    autoreconf -f
