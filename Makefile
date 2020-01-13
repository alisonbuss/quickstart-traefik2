
WORKING_DIRECTORY        ?= `pwd`

SWARM_COMPOSE_TRAEFIK    ?= $(WORKING_DIRECTORY)/swarm-compose/swarm-compose.traefik.yml

NETWORK_PUBLIC_NAME      ?= network_swarm_public
NETWORK_PRIVATE_NAME	 ?= network_swarm_private

VOLUME_SHARED_NAME       ?= volume_swarm_shared
VOLUME_SHARED_PATH       ?= $(WORKING_DIRECTORY)/volumes/shared

VOLUME_CERTIFICATES_NAME ?= volume_swarm_certificates
VOLUME_CERTIFICATES_PATH ?= $(WORKING_DIRECTORY)/volumes/certificates

# Print information from the Docker.
info:
	@echo "---Images:" && docker image ls && echo "\n"; 
	@echo "---Networks:" && docker network ls && echo "\n";
	@echo "---Volumes:" && docker volume ls && echo "\n";
	@echo "---Containers:" && docker container ls && echo "\n";
	@echo "---Nodes:" && docker node ls && echo "\n";
	@echo "---Services:" && docker service ls && echo "\n";

# Print information from the networks.
network-list:
	@docker network ls;

# Create networks for Docker Swarm.
network-create:
	@docker network create --driver=overlay $(NETWORK_PUBLIC_NAME);
	@docker network create --driver=overlay $(NETWORK_PRIVATE_NAME);

# Remove networks of the Docker Swarm.
network-remove:
	-@docker network rm $(NETWORK_PUBLIC_NAME) && sleep 2s;
	-@docker network rm $(NETWORK_PRIVATE_NAME);

# Print information from the volumes.
volume-list:
	@docker volume ls;

# Create volumes for Docker Swarm.
volume-create:
	-@docker volume create --name $(VOLUME_SHARED_NAME) \
		--driver local \
		--opt type=none \
		--opt device=$(VOLUME_SHARED_PATH) \
		--opt o=bind;

	-@docker volume create --name $(VOLUME_CERTIFICATES_NAME) \
		--driver local \
		--opt type=none \
		--opt device=$(VOLUME_CERTIFICATES_PATH) \
		--opt o=bind;

# Remove volumes of the Docker Swarm.
volume-remove:
	-@docker volume rm $(VOLUME_SHARED_NAME) && sleep 2s;
	-@docker volume rm $(VOLUME_CERTIFICATES_NAME);

# Print information from the services of the Docker Swarm.
services:
	@docker service ls;


### STACK TRAEFIK ###

# Up a stack of the Traefik in Docker Swarm.
stack-up-traefik:
	@docker stack deploy --compose-file $(SWARM_COMPOSE_TRAEFIK) traefik;

# Remove stack of the Traefik in Docker Swarm.
stack-remove-traefik:
	@docker stack rm traefik;


### STACK APP ###

# Up a stack of the Application in Docker Swarm.
stack-up-app:
	@docker stack deploy --compose-file $(WORKING_DIRECTORY)/swarm-compose/swarm-compose.app.yml app;

# Remove stack of the Application in Docker Swarm.
stack-remove-app:
	@docker stack rm app;


stack-all-up: network-create volume-create stack-up-traefik stack-up-app 

stack-all-rm: stack-remove-traefik stack-remove-app network-remove volume-remove


### VIEW DOCUMENTATION ###
help:
	@echo ' '
	@echo 'Usage: make <TARGETS> ... [OPTIONS]'
	@echo ' '
	@echo 'TARGETS:'
	@echo ' '
	@echo '  Information:'
	@echo '     info              Print information from the Docker.'
	@echo '     services          Print information from the services of the Docker Swarm.'
	@echo ' '
	@echo '  Network:'
	@echo '     network-list      Print information from the networks.'
	@echo '     network-create    Create networks for Docker Swarm.'
	@echo '     network-remove    Remove networks of the Docker Swarm.'
	@echo ' '
	@echo '  Volume:'
	@echo '     volume-list       Print information from the volumes.'
	@echo '     volume-create     Create volumes for Docker Swarm.'
	@echo '     volume-remove     Remove volumes of the Docker Swarm.'
	@echo ' '
	@echo '  Stack:'
	@echo '     stack-up-traefik        Up a stack of the Traefik in Docker Swarm.'
	@echo '     stack-remove-traefik    Remove stack of the Traefik in Docker Swarm.'
	@echo ' '
	@echo '     stack-up-app            Up a stack of the Application in Docker Swarm.'
	@echo '     stack-remove-app        Remove stack of the Application in Docker Swarm.'
	@echo ' '
	@echo '  Help:'
	@echo '     help    Print this help message.'
	@echo ' '
	@echo 'OPTIONS:'
	@echo ' '
	@echo '   WORKING_DIRECTORY           Specify the current working directory, the default is [`pwd`].'
	@echo '   SWARM_COMPOSE_TRAEFIK       The default is [./swarm-compose/swarm-compose.traefik.yml].'
	@echo ' '
	@echo '   NETWORK_PUBLIC_NAME         The default is [network_swarm_public].'
	@echo '   NETWORK_PRIVATE_NAME        The default is [network_swarm_private].'
	@echo ' '
	@echo '   VOLUME_SHARED_NAME          The default is [volume_swarm_shared].'
	@echo '   VOLUME_SHARED_PATH          The default is [./volumes/shared].'
	@echo ' '
	@echo '   VOLUME_CERTIFICATES_NAME    The default is [volume_swarm_certificates].'
	@echo '   VOLUME_CERTIFICATES_PATH    The default is [./volumes/certificates].'
	@echo ' '
