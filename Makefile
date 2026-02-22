.DEFAULT_GOAL := help

# -------------------------------------------------------------------------------------------------
# Private variables
# -------------------------------------------------------------------------------------------------

_DOCKER_DOTENVLINT_IMAGE=dotenvlinter/dotenv-linter:3.3.0
_DOCKER_FILELINT_IMAGE=cytopia/file-lint:latest-0.8
_DOCKER_HADOLINT_IMAGE=hadolint/hadolint:v2.12.0
_DOCKER_JSONLINT_IMAGE=cytopia/jsonlint:1.6.0
_DOCKER_MAKEFILELINT_IMAGE=cytopia/checkmake:latest-0.5
_DOCKER_MARKDOWNLINT_IMAGE=davidanson/markdownlint-cli2:v0.6.0
_DOCKER_SHELLCHECK_IMAGE=koalaman/shellcheck:v0.9.0
_DOCKER_SHFMT_IMAGE=mvdan/shfmt:v3.6.0
_DOCKER_YAMLLINT_IMAGE=cytopia/yamllint:1

_PROJECT_DIRECTORY=$(dir $(realpath $(firstword $(MAKEFILE_LIST))))

# -------------------------------------------------------------------------------------------------
# Utility functions
# -------------------------------------------------------------------------------------------------

# $1: type
# $2: name
# $3: command
define find-exec
	@find . \
	-type $1 \
	-not -path "**/node_modules/**" \
	-not -path ".git" \
	-not -path ".github" \
	-not -path ".vscode" \
	-not -path ".idea" \
	-name $2 \
	-print0 | \
	xargs -I {} -0 sh -c $3
endef

# check-variable-%: Check if the variable is defined.
check-variable-%:
	@[[ "${${*}}" ]] || (echo '*** Please define variable `${*}` ***' && exit 1)

.PHONY: help
help: Makefile
	@printf "Choose a command run in $(shell basename ${PWD}):\n"
	@LC_ALL=C $(MAKE) -pRrq -f $(firstword $(MAKEFILE_LIST)) : 2>/dev/null | \
	awk -v RS= -F: '/(^|\n)# Files(\n|$$)/,/(^|\n)# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | \
	sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' | sed 's/^/\-\ /'

# -------------------------------------------------------------------------------------------------
# QA Targets
# -------------------------------------------------------------------------------------------------

# Lint --------------------------------------------------------------------------------------------

.PHONY: lint lint-docker
lint: lint-dotenv lint-markdowns lint-shells lint-yamls lint-dockerfile lint-makefile lint-jsons lint-files lint-helm-chart
lint-docker: lint-dotenv-docker lint-markdowns-docker lint-shells-docker lint-yamls-docker lint-dockerfile-docker lint-makefile-docker lint-jsons-docker lint-files-docker lint-helm-chart-docker

.PHONY: lint-dotenv lint-dotenv-docker
lint-dotenv:
	@dotenv-linter -r .

lint-dotenv-docker:
	$(call run-docker-alpine,${_DOCKER_DOTENVLINT_IMAGE},make lint-dotenv)

.PHONY: lint-markdowns lint-markdowns-docker
lint-markdowns:
	@markdownlint-cli2-config ".rules/.markdownlint.yaml" "**/*.md" "#web-client/node_modules"

lint-markdowns-docker:
	@docker run --rm -v ${_PROJECT_DIRECTORY}:/data -w /data --entrypoint markdownlint-cli2-config ${_DOCKER_MARKDOWNLINT_IMAGE} ".rules/.markdownlint.yaml" "**/*.md" "#web-client/node_modules"

.PHONY: lint-shells lint-shells-docker
lint-shells:
	@shellcheck -a -o all -s bash **/*.sh

lint-shells-docker:
	@docker run --rm -v ${_PROJECT_DIRECTORY}:/data -w /data ${_DOCKER_SHELLCHECK_IMAGE} -a -o all -s bash **/*.sh

.PHONY: lint-yamls lint-yamls-docker
lint-yamls:
	@yamllint -c .rules/yamllint.yaml .

lint-yamls-docker:
	@docker run --rm $$(tty -s && echo "-it" || echo) -v ${_PROJECT_DIRECTORY}:/data ${_DOCKER_YAMLLINT_IMAGE} -c .rules/yamllint.yaml .

.PHONY: lint-dockerfile lint-dockerfile-docker
lint-dockerfile:
	@hadolint Dockerfile

lint-dockerfile-docker:
	@docker run --rm -v ${_PROJECT_DIRECTORY}:/data -w /data ${_DOCKER_HADOLINT_IMAGE} hadolint Dockerfile

.PHONY: lint-makefile lint-makefile-docker
lint-makefile:
	@checkmake --config .rules/checkmake.ini Makefile

lint-makefile-docker:
	@docker run --rm -v ${_PROJECT_DIRECTORY}:/data ${_DOCKER_MAKEFILELINT_IMAGE} --config .rules/checkmake.ini Makefile

.PHONY: lint-jsons lint-jsons-docker
lint-jsons:
	$(call find-exec,"f","*.json","jsonlint -c -q -t '  ' {}")

lint-jsons-docker:
	@docker run --rm -v ${_PROJECT_DIRECTORY}:/data ${_DOCKER_JSONLINT_IMAGE} -t '  ' -i './.git/,./.github/,./.vscode/,./.idea/,./static/build,./web-client/node_modules,./web-client/build' *.json

.PHONY: lint-files lint-files-docker
lint-files:
	@file-cr \
	--text \
	--ignore '.git/,.github/,.vscode/,.idea/,static/build,**/node_modules/' \
	--path .
	file-crlf \
	--text \
	--ignore '.git/,.github/,.vscode/,.idea/,static/build,**/node_modules/' \
	--path .
	file-trailing-single-newline \
	--text \
	--ignore '.git/,.github/,.vscode/,.idea/,static/build,**/node_modules/' \
	--path .
	file-trailing-space \
	--text \
	--ignore '.git/,.github/,.vscode/,.idea/,static/build,**/node_modules/' \
	--path .
	file-utf8 \
	--text \
	--ignore '.git/,.github/,.vscode/,.idea/,static/build,**/node_modules/' \
	--path .
	file-utf8-bom \
	--text \
	--ignore '.git/,.github/,.vscode/,.idea/,static/build,**/node_modules/' \
	--path .

lint-files-docker:
	@docker run --rm -v ${_PROJECT_DIRECTORY}:/data ${_DOCKER_FILELINT_IMAGE} file-cr \
	--text \
	--ignore '.git/,.github/,.vscode/,.idea/,static/build,**/node_modules' \
	--path .
	docker run --rm -v ${_PROJECT_DIRECTORY}:/data ${_DOCKER_FILELINT_IMAGE} file-crlf \
	--text \
	--ignore '.git/,.github/,.vscode/,.idea/,static/build,**/node_modules' \
	--path .
	docker run --rm -v ${_PROJECT_DIRECTORY}:/data ${_DOCKER_FILELINT_IMAGE} file-trailing-single-newline \
	--text \
	--ignore '.git/,.github/,.vscode/,.idea/,static/build,**/node_modules' \
	--path .
	docker run --rm -v ${_PROJECT_DIRECTORY}:/data ${_DOCKER_FILELINT_IMAGE} file-trailing-space \
	--text \
	--ignore '.git/,.github/,.vscode/,.idea/,static/build,**/node_modules' \
	--path .
	docker run --rm -v ${_PROJECT_DIRECTORY}:/data ${_DOCKER_FILELINT_IMAGE} file-utf8 \
	--text \
	--ignore '.git/,.github/,.vscode/,.idea/,static/build,**/node_modules' \
	--path .
	docker run --rm -v ${_PROJECT_DIRECTORY}:/data ${_DOCKER_FILELINT_IMAGE} file-utf8-bom \
	--text \
	--ignore '.git/,.github/,.vscode/,.idea/,static/build,**/node_modules' \
	--path .

.PHONY: lint-helm-chart lint-helm-chart-docker
lint-helm-chart:
	@ct lint \
	--charts helm_chart \
	--validate-maintainers=false \
	--config .rules/ct.yaml

lint-helm-chart-docker:
	@docker run -it -v ${_PROJECT_DIRECTORY}:/data -w /data ${_DOCKER_CHART_TESTING_IMAGE} ct lint \
	--charts helm_chart \
	--validate-maintainers=false \
	--config .rules/ct.yaml

# Format ------------------------------------------------------------------------------------------

.PHONY: format format-docker
format: format-files format-shells format-markdowns
format-docker: format-files-docker format-shells-docker format-markdowns-docker

.PHONY: format-files format-files-docker
format-files:
	@file-cr \
	--text \
	--ignore '.git/,.github/,.vscode/,.idea/,static/build,**/node_modules' \
	--fix \
	--path .
	file-crlf \
	--text \
	--ignore '.git/,.github/,.vscode/,.idea/,static/build,**/node_modules' \
	--fix \
	--path .
	file-trailing-single-newline \
	--text \
	--ignore '.git/,.github/,.vscode/,.idea/,static/build,**/node_modules' \
	--fix \
	--path .
	file-trailing-space \
	--text \
	--ignore '.git/,.github/,.vscode/,.idea/,static/build,**/node_modules' \
	--fix \
	--path .
	file-utf8 \
	--text \
	--ignore '.git/,.github/,.vscode/,.idea/,static/build,**/node_modules' \
	--fix \
	--path .
	file-utf8-bom \
	--text \
	--ignore '.git/,.github/,.vscode/,.idea/,static/build,**/node_modules' \
	--fix \
	--path .

format-files-docker:
	@docker run --rm -v ${_PROJECT_DIRECTORY}:/data ${_DOCKER_FILELINT_IMAGE} file-cr \
	--text \
	--ignore '.git/,.github/,.vscode/,.idea/,static/build,**/node_modules' \
	--fix \
	--path .
	@docker run --rm -v ${_PROJECT_DIRECTORY}:/data ${_DOCKER_FILELINT_IMAGE} file-crlf \
	--text \
	--ignore '.git/,.github/,.vscode/,.idea/,static/build,**/node_modules' \
	--fix \
	--path .
	@docker run --rm -v ${_PROJECT_DIRECTORY}:/data ${_DOCKER_FILELINT_IMAGE} file-trailing-single-newline \
	--text \
	--ignore '.git/,.github/,.vscode/,.idea/,static/build,**/node_modules' \
	--fix \
	--path .
	@docker run --rm -v ${_PROJECT_DIRECTORY}:/data ${_DOCKER_FILELINT_IMAGE} file-trailing-space \
	--text \
	--ignore '.git/,.github/,.vscode/,.idea/,static/build,**/node_modules' \
	--fix \
	--path .
	@docker run --rm -v ${_PROJECT_DIRECTORY}:/data ${_DOCKER_FILELINT_IMAGE} file-utf8 \
	--text \
	--ignore '.git/,.github/,.vscode/,.idea/,static/build,**/node_modules' \
	--fix \
	--path .
	@docker run --rm -v ${_PROJECT_DIRECTORY}:/data ${_DOCKER_FILELINT_IMAGE} file-utf8-bom \
	--text \
	--ignore '.git/,.github/,.vscode/,.idea/,static/build,**/node_modules' \
	--fix \
	--path .

.PHONY: format-markdowns format-markdowns-docker
format-markdowns:
	@markdownlint-cli2-fix "**/*.md" "#web-client/node_modules"

format-markdowns-docker:
	@docker run --rm -v ${_PROJECT_DIRECTORY}:/data -w /data --entrypoint="markdownlint-cli2-fix" ${_DOCKER_MARKDOWNLINT_IMAGE} "**/*.md" "#web-client/node_modules"

.PHONY: format-shells format-shells-docker
format-shells:
	@shfmt -i 2 -ci -sr -w .

format-shells-docker:
	@docker run --rm -v ${_PROJECT_DIRECTORY}:/data -w /data ${_DOCKER_SHFMT_IMAGE} -i 2 -ci -sr -w .
