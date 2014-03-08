CHECK=\033[32m✔\033[39m
DONE="\n$(CHECK) Done.\n"

SERVER=docker
SERVER_USER=tchen
PROJECT=teamspark
DEPLOY_PATH=deployment/$(PROJECT)
BUILD=build
APP=$(BUILD)/app
DB=$(BUILD)/data


DOCKER=$(shell which docker)
METEOR=$(shell which meteor)
SSH=$(shell which ssh)
TAR=$(shell which tar)
RSYNC=$(shell which rsync)
MKDIR=$(shell which mkdir)
CP=$(shell which cp)
RM=$(shell which rm)

remote_deploy:
	@$(RSYNC) -au --exclude .meteor --exclude build . $(SERVER):/home/$(SERVER_USER)/deployment/$(PROJECT)
	@$(SSH) -t $(SERVER) "echo Deploy $(PROJECT) to the $(SERVER) server.; cd $(DEPLOY_PATH); make deploy;"

prepare:
	@$(MKDIR) -p $(APP) $(DB) $(DB)/db $(DB)/log
	@$(CP) docker/app.docker $(APP)
	@$(CP) docker/db.* $(DB)

bundle:
	@echo "Bundling the meteor environment..."
	@$(METEOR) bundle tmp.tgz
	@$(TAR) zxvf tmp.tgz
	@$(RSYNC) -au bundle/. $(APP)
	@$(RM) -rf bundle
	@$(RM) tmp.tgz

app_image:
	@cd $(APP); mv app.docker Dockerfile; $(DOCKER) build -t tchen/ts_app .

db_image:
	@cd $(DB); mv db.docker Dockerfile; $(DOCKER) build -t tchen/ts_mongo .


deploy: prepare app_image
	@$(ECHO) $(DONE)