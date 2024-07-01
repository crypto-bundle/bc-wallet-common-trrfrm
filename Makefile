#!make
include ./env-trrfrm.env
export $(shell sed 's/=.*//' env-trrfrm.env)

trrfrm_apply:
	terraform -chdir=deploy/trrfrm/init apply --var="k8s_namespace=default" --var="installment_name=cbdl_dev_local"

trrfrm_init:
	terraform -chdir=deploy/trrfrm/init init --reconfigure

build_trrfrm:
	$(if $(and $(env),$(repository)),,$(error 'env' and/or 'repository' is not defined))

	$(eval build_tag=$(env)-$(shell git rev-parse --short HEAD)-$(shell date +%s))
	$(eval parent_container_path=hashicorp/terraform:latest)
	$(eval target_container_path=$(repository)/crypto-bundle/bc-wallet-common-trrfrm)
	$(eval context=$(or $(context),k0s-dev-cluster))
	$(eval platform=$(or $(platform),linux/amd64))

	docker build \
		--ssh default=$(SSH_AUTH_SOCK) \
		--platform $(platform) \
		--build-arg PARENT_CONTAINER_IMAGE_NAME=$(parent_container_path) \
		--tag $(target_container_path):$(build_tag) \
		--tag $(target_container_path):latest \
		-f trrfrm-base.dockerfile .

	docker push $(target_container_path):$(build_tag)
	docker push $(target_container_path):latest

build_trrfrm_pg:
	$(if $(and $(env),$(repository)),,$(error 'env' and/or 'repository' is not defined))

	$(eval build_tag=$(env)-$(shell git rev-parse --short HEAD)-$(shell date +%s))
	$(eval parent_container_path=postgres:15)
	$(eval target_container_path=$(repository)/crypto-bundle/bc-wallet-common-trrfrm-pg)
	$(eval context=$(or $(context),k0s-dev-cluster))
	$(eval platform=$(or $(platform),linux/amd64))

	docker build \
		--ssh default=$(SSH_AUTH_SOCK) \
		--platform $(platform) \
		--build-arg PARENT_CONTAINER_IMAGE_NAME=$(parent_container_path) \
		--tag $(target_container_path):$(build_tag) \
		--tag $(target_container_path):latest \
		-f trrfrm-self-init-postgres.dockerfile .

	docker push $(target_container_path):$(build_tag)
	docker push $(target_container_path):latest

deploy:
	$(if $(and $(env),$(repository)),,$(error 'env' and/or 'repository' is not defined))

	$(eval git_short=$(or $(shell git rev-parse --short HEAD),0000000))
	$(eval build_tag=$(env)-$(git_short)-$(shell date +%s))
	$(eval parent_container_path=$(repository)/crypto-bundle/bc-wallet-common-trrfrm:latest)
	$(eval target_container_path=$(repository)/crypto-bundle/bc-wallet-common-trrfrm-self-init)
	$(eval trfrm_working_dir=$(or $(working_dir),/opt/trrfrm))
	$(eval context=$(or $(context),k0s-dev-cluster))
	$(eval platform=$(or $(platform),linux/amd64))
	$(eval trrfrm_project_name=$(or $(project_name),bc-wallet-common-trrfrmr-base))

	docker build \
		--ssh default=$(SSH_AUTH_SOCK) \
		--platform $(platform) \
		--build-arg PARENT_CONTAINER_IMAGE_NAME=$(parent_container_path) \
		--build-arg TRFRM_PROJECT_NAME=$(trrfrm_project_name) \
		--build-arg TRFRM_DIR=$(trfrm_working_dir) \
		--tag $(target_container_path):$(build_tag) \
		--tag $(target_container_path):latest \
		-f trrfrm-self-init.dockerfile .

	docker push $(target_container_path):$(build_tag)
	docker push $(target_container_path):latest
#
	helm --kube-context $(context) dependency update ./deploy/helm/init

#	helm --kube-context $(context) template --debug \
#		--dependency-update \
#		--set "global.env=$(env)" \
#		--set "terraformer.image.path=$(target_container_path)" \
#		--set "terraformer.image.tag=$(build_tag)" \
#		--values=./deploy/helm/init/values.yaml \
#		--values=./deploy/helm/init/values_local.yaml \
#		./deploy/helm/init > job.yaml

	helm --kube-context $(context) upgrade \
		--install $(trrfrm_project_name) \
		--set "global.env=$(env)" \
		--set "terraformer.image.path=$(target_container_path)" \
		--set "terraformer.image.tag=$(build_tag)" \
		--values=./deploy/helm/init/values.yaml \
		--values=./deploy/helm/init/values_local.yaml \
		./deploy/helm/init

.PHONY: deploy trrfrm_init trrfrm_apply build_trrfrm