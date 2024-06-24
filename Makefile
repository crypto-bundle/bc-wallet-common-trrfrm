#!make
include ./env-trrfrm.env
export $(shell sed 's/=.*//' env-trrfrm.env)

trrfrm_apply:
	terraform -chdir=deploy/trrfrm/init apply

trrfrm_init:
	terraform -chdir=deploy/trrfrm/init init -reconfigure

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
		-f trrfrm.dockerfile .

	docker push $(target_container_path):$(build_tag)
	docker push $(target_container_path):latest

deploy:
	$(if $(and $(env),$(repository)),,$(error 'env' and/or 'repository' is not defined))

	$(eval git_short=$(or $(shell git rev-parse --short HEAD),0000000))
	$(eval build_tag=$(env)-$(git_short)-$(shell date +%s))
	$(eval parent_container_path=$(repository)/crypto-bundle/bc-wallet-common-trrfrm:latest)
	$(eval target_container_path=$(repository)/crypto-bundle/bc-wallet-common-trrfrm-base)
	$(eval context=$(or $(context),k0s-dev-cluster))
	$(eval platform=$(or $(platform),linux/amd64))

	docker build \
		--ssh default=$(SSH_AUTH_SOCK) \
		--platform $(platform) \
		--build-arg PARENT_CONTAINER_IMAGE_NAME=$(parent_container_path) \
		--tag $(target_container_path):$(build_tag) \
		--tag $(target_container_path):latest \
		-f base.dockerfile .

	docker push $(target_container_path):$(build_tag)
	docker push $(target_container_path):latest

	helm --kube-context $(context) dependency update ./deploy/helm/init

	helm --kube-context $(context) template --debug \
		--set "global.env=$(env)" \
		--set "terraformer.image.path=$(target_container_path)" \
		--set "terraformer.image.tag=$(build_tag)" \
		--values=./deploy/helm/init/values.yaml \
		--values=./deploy/helm/init/values_local.yaml \
		./deploy/helm/init > job.yaml

	helm --kube-context $(context) upgrade \
		--install bc-wallet-common-trrfrmr-base \
		--set "global.env=$(env)" \
		--set "terraformer.image.path=$(target_container_path)" \
		--set "terraformer.image.tag=$(build_tag)" \
		--values=./deploy/helm/init/values.yaml \
		--values=./deploy/helm/init/values_local.yaml \
		./deploy/helm/init

.PHONY: deploy trrfrm_init trrfrm_apply build_trrfrm