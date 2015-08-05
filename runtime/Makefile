.PHONY: runtime upload all

runtime:
	mkdir -p runtime
	python lutrisrt.py
	echo "`date +%s`" > runtime/VERSION

get_steam_runtime:
	git clone https://github.com/ValveSoftware/steam-runtime.git

update_steam_runtime:
	cd steam-runtime && git pull

steam_runtime:
	cd steam-runtime && python2 build-runtime.py

upload:
	scp runtime/lutris-runtime-amd64.tar.gz lutris.net:/srv/files/runtime/
	scp runtime/lutris-runtime-i386.tar.gz lutris.net:/srv/files/runtime/
	scp runtime/VERSION lutris.net:/srv/files/runtime/
