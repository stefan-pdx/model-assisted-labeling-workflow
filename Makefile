PIPELINE_TASKS_REPOSITORY_URL ?= $(shell terraform output --raw pipeline_tasks_repository_url)

AWS_REGION ?= $(shell terraform output --raw aws_region)

PIPELINE_STATE_MACHINE_ARN ?= $(shell terraform output --raw pipeline_state_machine_arn)

all: init apply login build push run

init:
	pip install --target modules/pipeline/files/packages/layer/python labelbox
	terraform init

apply:
	terraform apply -auto-approve

login:
	aws ecr get-login-password --region $(AWS_REGION) | docker login --username AWS --password-stdin 763104351884.dkr.ecr.us-west-2.amazonaws.com
	aws ecr get-login-password --region $(AWS_REGION) | docker login --username AWS --password-stdin $(PIPELINE_TASKS_REPOSITORY_URL)

build:
	docker build -t $(PIPELINE_TASKS_REPOSITORY_URL):latest -f modules/pipeline/files/Dockerfile modules/pipeline/files

push:
	docker push $(PIPELINE_TASKS_REPOSITORY_URL):latest

run:
	aws stepfunctions start-execution --state-machine-arn $(PIPELINE_STATE_MACHINE_ARN)