Lutris runtime
--------------

The Lutris runtime is a set of libs used by the Lutris client in order to avoid
depending on what's installed on the system thus providing support for a large
quantity of games out of the box.

The scripts provided build Debian chroots and installs the required packages.
Then, with ldconfig -p, it looks for the path of the required .so paths and
copies them into the runtime directory.

Extra libraries that are not available in Debian are included directly in the
repo. Here's a list of the extra libs and their source:

- libboost-locale1.54.0       Debian sid
- libfmodex                   http://www.fmod.org/browse-fmod-ex-api/
- libmodplug                  OpenSuse 11.4
- libpng14                    ?
- libpng15                    Proteus
- libSDL1.2                   http://www.libsdl.org/download-1.2.php
- libSDL2-2.0                 Fedora 20
