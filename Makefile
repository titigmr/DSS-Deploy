EDITOR=vi

include /etc/os-release
export PORT=10000
export DSS_MEM=2g
export COMPOSE_PROJECT_NAME=designer


install-prereq:
ifeq ("$(wildcard /usr/bin/docker)","")
        @echo install docker-ce, still to be tested
        sudo apt-get update
        sudo apt-get install \
        apt-transport-https \
        ca-certificates \
        curl \
        software-properties-common

        curl -fsSL https://download.docker.com/linux/${ID}/gpg | sudo apt-key add -
        sudo add-apt-repository \
                "deb https://download.docker.com/linux/ubuntu \
                `lsb_release -cs` \
                stable"
        sudo apt-get update
        sudo apt-get install -y docker-ce
        sudo curl -L https://github.com/docker/compose/releases/download/1.19.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
endif

volume_create:
	@sudo mkdir -p /data/dss && sudo chown -hR ${USER} /data/dss

network:
	@docker network create ${COMPOSE_PROJECT_NAME} 2> /dev/null; true

requirements: up
	docker exec -it ${COMPOSE_PROJECT_NAME}_dss /home/dataiku/dss/bin/pip install -r requirements.txt

up: check volume_create network
	docker-compose up -d

down:
	docker-compose down

restart: down up

check:
	@docker-compose config
