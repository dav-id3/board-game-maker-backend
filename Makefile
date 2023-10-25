#!make

PROJECT_NAME := board-game-maker
DOCKER_NETWORK := $(PROJECT_NAME)-network

#port
MYSQL_PORT := 3306
PUB_PORT := 8080

#container name
DATABASE_CONTAINER := $(PROJECT_NAME)-backend-db
PUB_CONTAINER := $(PROJECT_NAME)-backend-pub

#path
DATABASE_FOLDER := $(CURDIR)/db
PUB_FOLDER := $(CURDIR)/pub
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


## pub for pub/sub chats
.PHONY: pub.build
pub.build:
	@docker build -f $(PUB_FOLDER)/Dockerfile -t $(PUB_CONTAINER) $(PUB_FOLDER)

.PHONY: .up
pub.up:
	@docker run --rm -it \
	 --network $(DOCKER_NETWORK) \
	 --env-file $(ENVFILE_FOLDER)/.pub \
	 --volume $(PUB_FOLDER):/usr/src/pub:rw \
	 --publish $(PUB_PORT):$(PUB_PORT) \
	 --name $(PUB_CONTAINER) \
	 $(PUB_CONTAINER)
	
	