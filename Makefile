shell:
	docker exec -it -e "TERM=xterm-256color" buildbot su vagrant

rootshell:
	docker exec -it buildbot bash

teardown:
	docker stop buildbot
	docker rm buildbot

setup:
	mkdir -p builds
	docker create --interactive --name buildbot \
		--mount type=bind,source="$$PWD"/builds,destination=/builds,readonly=false \
		--mount type=bind,source="$$PWD",destination=/home/vagrant/buildbot,readonly=false \
		docker.io/gloriouseggroll/lutris_buildbot:bullseye
	docker start buildbot

