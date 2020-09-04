# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
.PHONY: docs help test

# Use bash for inline if-statements in arch_patch target
SHELL:=bash
ARCH:=$(shell uname -m)
OWNER?=ttmetro

# Need to list the images in build dependency order
ALL_STACKS:=base-notebook \
	minimal-notebook \
	scipy-notebook
ALL_STACKS=scipy-notebook

ALL_IMAGES:=$(ALL_STACKS)

# Docker buildx platforms
# PLATFORMS:="linux/amd64,linux/arm/v6,linux/arm/v7,linux/arm64"
PLATFORMS:="linux/amd64,linux/arm/v7"

# Linter
HADOLINT="${HOME}/hadolint"
HADOLINT_VERSION="v1.18.0"

help:
# http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
	@echo "ttmetro/docker-stacks"
	@echo "====================="
	@echo "Replace % with a stack directory name (e.g., make build/minimal-notebook)"
	@echo
	@grep -E '^[a-zA-Z0-9_%/-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

arch_patch/%: ## apply hardware architecture specific patches to the Dockerfile
	@if [ -e ./$(notdir $@)/Dockerfile.$(ARCH).patch ]; then \
		if [ -e ./$(notdir $@)/Dockerfile.orig ]; then \
               		cp -f ./$(notdir $@)/Dockerfile.orig ./$(notdir $@)/Dockerfile;\
		else\
                	cp -f ./$(notdir $@)/Dockerfile ./$(notdir $@)/Dockerfile.orig;\
		fi;\
		patch -f ./$(notdir $@)/Dockerfile ./$(notdir $@)/Dockerfile.$(ARCH).patch; \
	fi
	
build/%: DARGS?=
build/%: ## build the latest image for a stack
	docker build $(DARGS) --rm --force-rm -t $(OWNER)/$(notdir $@):latest ./$(notdir $@)
	@echo -n "Built image size: "
	@docker images $(OWNER)/$(notdir $@):latest --format "{{.Size}}"

build-all: $(foreach I,$(ALL_IMAGES),arch_patch/$(I) build/$(I) ) ## build all stacks
build-test-all: $(foreach I,$(ALL_IMAGES),arch_patch/$(I) build/$(I) test/$(I) ) ## build and test all stacks

buildx-amd64/%: DARGS?=
buildx-amd64/%: ## buildx for linux/amd64 single architecture, image stored locally
	docker buildx build $(DARGS) \
		--platform linux/amd64 --load \
		--rm --force-rm -t $(OWNER)/$(notdir $@):latest ./$(notdir $@)
	@echo -n "Built image size: "
	@docker images $(OWNER)/$(notdir $@):latest --format "{{.Size}}"

buildx-all-amd64: $(foreach I,$(ALL_IMAGES),arch_patch/$(I) buildx-amd64/$(I) ) ## build all stacks
buildx-test-all-amd64: $(foreach I,$(ALL_IMAGES),arch_patch/$(I) buildx-amd64/$(I) test/$(I) ) ## build and test all stacks

buildx/%: DARGS?=
buildx/%: ## buildx for $(PLATORMS) multi-architecture, image pushed to DockerHub
	docker buildx build $(DARGS) \
		--platform $(PLATFORMS) --push \
		--rm --force-rm -t $(OWNER)/$(notdir $@):latest ./$(notdir $@)
	@echo -n "Built image size: "
	@docker images $(OWNER)/$(notdir $@):latest --format "{{.Size}}"

buildx-all: $(foreach I,$(ALL_IMAGES),arch_patch/$(I) buildx/$(I) ) ## build all stacks
buildx-test-all: $(foreach I,$(ALL_IMAGES),arch_patch/$(I) buildx/$(I) test/$(I) ) ## build and test all stacks

check-outdated/%: ## check the outdated packages in a stack and produce a report (experimental)
	@TEST_IMAGE="$(OWNER)/$(notdir $@)" pytest test/test_outdated.py

cont-clean-all: cont-stop-all cont-rm-all ## clean all containers (stop + rm)

cont-stop-all: ## stop all containers
	@echo "Stopping all containers ..."
	-docker stop -t0 $(shell docker ps -a -q) 2> /dev/null

cont-rm-all: ## remove all containers
	@echo "Removing all containers ..."
	-docker rm --force $(shell docker ps -a -q) 2> /dev/null

dev/%: ARGS?=
dev/%: DARGS?=
dev/%: PORT?=8888
dev/%: ## run a foreground container for a stack
	docker run -it --rm -p $(PORT):8888 $(DARGS) $(OWNER)/$(notdir $@) $(ARGS)

dev-env: ## install libraries required to build docs and run tests
	@pip install -r requirements-dev.txt

docs: ## build HTML documentation
	make -C docs html

git-commit: LOCAL_PATH?=.
git-commit: GITHUB_SHA?=$(shell git rev-parse HEAD)
git-commit: GITHUB_REPOSITORY?=iot49/docker-stacks
git-commit: GITHUB_TOKEN?=
git-commit: ## commit outstading git changes and push to remote
	@git config --global user.name "GitHub Actions"
	@git config --global user.email "actions@users.noreply.github.com"

	@echo "Publishing outstanding changes in $(LOCAL_PATH) to $(GITHUB_REPOSITORY)" 
	@cd $(LOCAL_PATH) && \
		git remote add publisher https://$(GITHUB_TOKEN)@github.com/$(GITHUB_REPOSITORY).git && \
		git checkout master && \
		git add -A -- . && \
		git commit -m "[ci skip] Automated publish for $(GITHUB_SHA)" || exit 0
	@cd $(LOCAL_PATH) && git push -u publisher master

hook/%: export COMMIT_MSG?=$(shell git log -1 --pretty=%B)
hook/%: export GITHUB_SHA?=$(shell git rev-parse HEAD)
hook/%: export WIKI_PATH?=../wiki
hook/%: ## run post-build hooks for an image
	BUILD_TIMESTAMP="$$(date -u +%FT%TZ)" \
	DOCKER_REPO="$(OWNER)/$(notdir $@)" \
	IMAGE_NAME="$(OWNER)/$(notdir $@):latest" \
	IMAGE_SHORT_NAME="$(notdir $@)" \
	$(SHELL) $(notdir $@)/hooks/run_hook

hook-all: $(foreach I,$(ALL_IMAGES),hook/$(I) ) ## run post-build hooks for all images

img-clean: img-rm-dang img-rm ## clean dangling and jupyter images

img-list: ## list jupyter images
	@echo "Listing $(OWNER) images ..."
	docker images "$(OWNER)/*"

img-rm:  ## remove jupyter images
	@echo "Removing $(OWNER) images ..."
	-docker rmi --force $(shell docker images --quiet "$(OWNER)/*") 2> /dev/null

img-rm-dang: ## remove dangling images (tagged None)
	@echo "Removing dangling images ..."
	-docker rmi --force $(shell docker images -f "dangling=true" -q) 2> /dev/null

lint/%: ARGS?=
lint/%: ## lint the dockerfile(s) for a stack
	@echo "Linting Dockerfiles in $(notdir $@)..."
	@git ls-files --exclude='Dockerfile*' --ignored $(notdir $@) | grep -v ppc64 | xargs -L 1 $(HADOLINT) $(ARGS)
	@echo "Linting done!"

lint-all: $(foreach I,$(ALL_IMAGES),lint/$(I) ) ## lint all stacks

lint-build-test-all: $(foreach I,$(ALL_IMAGES),lint/$(I) build/$(I) test/$(I) ) ## lint, build and test all stacks

lint-install: ## install hadolint
	@echo "Installing hadolint at $(HADOLINT) ..."
	@curl -sL -o $(HADOLINT) "https://github.com/hadolint/hadolint/releases/download/$(HADOLINT_VERSION)/hadolint-$(shell uname -s)-$(shell uname -m)"
	@chmod 700 $(HADOLINT)
	@echo "Installation done!"
	@$(HADOLINT) --version	

pre-commit-all: ## run pre-commit hook on all files
	@pre-commit run --all 

pre-commit-install: ## set up the git hook scripts
	@pre-commit --version
	@pre-commit install

pull/%: DARGS?=
pull/%: ## pull a jupyter image
	docker pull $(DARGS) $(OWNER)/$(notdir $@)

push/%: DARGS?=
push/%: ## push all tags for a jupyter image
	docker push $(DARGS) $(OWNER)/$(notdir $@)

push-all: $(foreach I,$(ALL_IMAGES),push/$(I) ) ## push all tagged images

run/%: DARGS?=
run/%: ## run a bash in interactive mode in a stack
	docker run -it --rm $(DARGS) $(OWNER)/$(notdir $@) $(SHELL)

run-sudo/%: DARGS?=
run-sudo/%: ## run a bash in interactive mode as root in a stack
	docker run -it --rm -u root $(DARGS) $(OWNER)/$(notdir $@) $(SHELL)

test/%: ## run tests against a stack (only common tests or common tests + specific tests)
	@echo "Tests disabled - FIX THIS!"
	# @if [ ! -d "$(notdir $@)/test" ]; then TEST_IMAGE="$(OWNER)/$(notdir $@)" pytest -m "not info" test; \
	# else TEST_IMAGE="$(OWNER)/$(notdir $@)" pytest -m "not info" test $(notdir $@)/test; fi

test-all: $(foreach I,$(ALL_IMAGES),test/$(I)) ## test all stacks
