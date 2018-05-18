Lutris runtime
--------------

The Lutris runtime is a set of shared libs used by the Lutris client in order
to avoid depending on what's installed on the system, thus providing support
for a large quantity of games out of the box.

The scripts provided build the Steam runtime (used as a base), then install
the packages for extra libs used by Lutris. You must be running Ubuntu 14.04.
Then, with ldconfig -p, it looks for the path of the required .so paths and
copies them into the runtime directory.

Extra libraries that are not available in Ubuntu are included directly in the
repo. Here's a list of these libs and their source:

- libfmodex                   http://www.fmod.org/browse-fmod-ex-api/
- libmodplug                  OpenSuse 11.4
- libpng14                    ?
- libpng15                    Proteus
- libSDL1.2                   http://www.libsdl.org/download-1.2.php
- libSDL2-2.0                 Fedora 20
- libSoundTouch1              Ubuntu 16.04 (Required by PCSX2)
- libharfbuzz0                Ubuntu 17.04 (Ubuntu 16.04 version too old to run MAME on Arch)
