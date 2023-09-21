# This is used for creating new buildbot docker images (for example when we want to change the buildbot container/VM host distro)
# Currently based off debian 12 bookworm
#
# ATTENTION:
# You must prepare podman to be able to login to docker hub before attempting to push images
# Create an account then create a token
# https://hub.docker.com/settings/security?generateToken=true
#
# Then:
# podman login docker.io
# Username: <username>
# Password: <token>

#!/bin/bash
cat << EOF > imageprep.sh
#!/bin/bash
useradd -s /bin/bash -m vagrant
mkdir -p /vagrant
chmod 777 /vagrant
echo -e 'vagrant\nvagrant\n' | passwd vagrant
apt-get update && apt-get install -y git sudo
usermod -aG sudo vagrant
cd /home/vagrant
git clone http://github.com/lutris/buildbot lutris-buildbot
chown -R vagrant:vagrant /home/vagrant/lutris-buildbot/
chmod +x /home/vagrant/lutris-buildbot/setup-buildbot.sh
cd /home/vagrant/lutris-buildbot/
./setup-buildbot.sh
EOF
chmod +x imageprep.sh
docker pull debian:bookworm
docker create --interactive --name bookworm debian:bookworm
docker start bookworm
docker cp imageprep.sh bookworm:/
rm imageprep.sh
docker exec bookworm bash -c "./imageprep.sh"
docker exec bookworm bash -c "rm imageprep.sh"
docker stop bookworm

# Change gloriouseggroll/lutris_buildbot:bookworm to your Docker repo and tag
docker commit bookworm gloriouseggroll/lutris_buildbot:bookworm
docker push gloriouseggroll/lutris_buildbot:bookworm

