
WORKING_DIRECTORY   ?= `pwd`
DOCKER_COMPOSE_FILE ?= $(WORKING_DIRECTORY)/docker-compose.swarm.file.yml

info:
	@echo "---Images:" && docker image ls && echo "\n"; 
	@echo "---Networks:" && docker network ls && echo "\n";
	@echo "---Volumes:" && docker volume ls && echo "\n";
	@echo "---Containers:" && docker container ls && echo "\n";
	@echo "---Nodes:" && docker node ls && echo "\n";
	@echo "---Services:" && docker service ls && echo "\n";

network-list:
	@docker network ls;

network-create:
	@docker network create --driver=overlay network_swarm_public;
	@docker network create --driver=overlay network_swarm_private;

network-remove:
	-@docker network rm network_swarm_public;
	-@docker network rm network_swarm_private;

volume-list:
	@docker volume ls;

volume-create:
	-@docker volume create --name "volume_swarm_shared" \
		--driver local \
		--opt type=none \
		--opt device=$(WORKING_DIRECTORY)/volumes/shared \
		--opt o=bind;

	-@docker volume create --name "volume_swarm_certificates" \
		--driver local \
		--opt type=none \
		--opt device=$(WORKING_DIRECTORY)/volumes/certificates \
		--opt o=bind;

volume-remove:
	-@docker volume rm volume_swarm_shared;
	-@docker volume rm volume_swarm_certificates;

services:
	@docker service ls;

stack-build: network-create volume-create

stack-deploy:
	@docker stack deploy --compose-file $(DOCKER_COMPOSE_FILE) traefik;

stack-remove:
	@docker stack rm traefik;

clear: stack-remove network-remove volume-remove
	# @docker stop $(docker ps -a -q) && \
	# 	docker rm $(docker ps -a -q) && \
	# 	docker rmi $(docker images -q) && \
	# 	docker volume rm $(docker volume ls -q) && \
	# 	docker system prune -a;
