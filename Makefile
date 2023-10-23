#!make

PROJECT_NAME := board-game-maker
DOCKER_NETWORK := $(PROJECT_NAME)-network

#port
MYSQL_PORT := 3306
API_PORT := 8080

#container name
DATABASE_CONTAINER := $(PROJECT_NAME)-backend-db
API_CONTAINER := $(PROJECT_NAME)-backend-api

#path
DATABASE_FOLDER := $(CURDIR)/db
API_FOLDER := $(CURDIR)/api
ENVFILE_FOLDER := $(CURDIR)/envfiles

##Network
.PHONY: network.create
network.create:
	@docker network create --driver bridge $(DOCKER_NETWORK)

.PHONY: network.remove
network.remove:
	@docker network rm $(DOCKER_NETWORK)


#Database
.PHONY: db.build
db.build:
	@docker build \
		-f $(DATABASE_FOLDER)/Dockerfile \
		-t $(DATABASE_CONTAINER) $(DATABASE_FOLDER) 

.PHONY: db.start
db.start:
	@docker run -d --rm \
		--env-file $(ENVFILE_FOLDER)/.db \
		--net $(DOCKER_NETWORK) \
		--name $(DATABASE_CONTAINER) \
		--volume $(DATABASE_FOLDER)/data:/var/lib/mysql:rw \
		--publish $(MYSQL_PORT):3306 \
		$(DATABASE_CONTAINER)

.PHONY: db.exec
db.exec:
	@docker exec -it $(DATABASE_CONTAINER) /bin/bash


## api for pub/sub chats
.PHONY: api.build
api.build:
	@docker build -f $(API_FOLDER)/Dockerfile -t $(API_CONTAINER) $(API_FOLDER)

.PHONY: api.up
api.up:
	@docker run --rm -it \
	 --network $(DOCKER_NETWORK) \
	 --env-file $(ENVFILE_FOLDER)/.api \
	 --volume $(API_FOLDER):/usr/src/api:rw \
	 --publish $(API_PORT):$(API_PORT) \
	 --name $(API_CONTAINER) \
	 $(API_CONTAINER)
	
