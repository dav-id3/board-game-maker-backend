PROJECT_NAME := board-game-maker
DOCKER_NETWORK := $(PROJECT_NAME)-network

API_FOLDER := $(CURDIR)/api
API_PORT := 8080
API_CONTAINER := $(PROJECT_NAME)-backend-api

ENV_FILE_FOLDER := $(CURDIR)/envfiles

##Network
.PHONY: network.create
network.create:
	@docker network create --driver bridge $(DOCKER_NETWORK)

.PHONY: network.remove
network.remove:
	@docker network rm $(DOCKER_NETWORK)


## api for pub/sub chats
.PHONY: api.build
api.build:
	@docker build -f $(API_FOLDER)/Dockerfile -t $(API_CONTAINER) $(API_FOLDER)

.PHONY: api.up
api.up:
	@docker run --rm -it \
	 --network $(DOCKER_NETWORK) \
	 --env-file $(ENV_FILE_FOLDER)/.api \
	 --volume $(API_FOLDER):/usr/src/api:rw \
	 --publish $(API_PORT):$(API_PORT) \
	 --name $(API_CONTAINER) \
	 $(API_CONTAINER)
	
