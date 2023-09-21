shell:
	docker exec -it -e "TERM=xterm-256color" buildbot su vagrant

rootshell:
	docker exec -it buildbot bash

teardown:
	docker stop buildbot
	docker rm buildbot

setup:
	docker create --interactive --name buildbot \
		--mount type=bind,source="$$PWD"/builds,destination=/builds,readonly=false \
		--mount type=bind,source="$$PWD",destination=/home/vagrant/buildbot,readonly=false \
		docker.io/gloriouseggroll/lutris_buildbot:bookworm
	docker start buildbot
	# Can be removed after image update
	docker exec -it buildbot usermod -s /bin/bash vagrant
