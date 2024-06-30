# bc-wallet-common-trrfrm

## Description

Trrfrm it's wrapper for Hashicorp Terraform application.

Its just tool for infrastructure preparation flow. Repository contains library Helm-chart for running Terraform jobs. 
Also, repository contains base Docker Terraform wrapper image.

Trrfrm uses PostgreSQL for store terraform state.
Secret and sensitive data for Trrfrm retrives from Hashicopr Vault.
Also, Trrfrm uses Kubernetes persistent volume for store `.terraform` and Terraform plugin cache directories.

## Trrfrm-Job library chart

[Library Helm](./deploy/helm/library/Chart.yaml) chart of Trrfrm-Job. You can write custom Helm-carts which will be based on base chart.

Full Helm library-chart description located in [library README.md](./deploy/helm/library/README.md) file.

## Init Trrfrm-Job

Start of crypto-bundle project deployment is here. Before deploy other crypto-bundle charts u must deploy `bc-wallet-common-trrfrmr-base` kubernetes job.

Bc-wallet-common-trrfrm-init terraform source code located in [./deploy/trrfrm/init](./deploy/trrfrm/init) directory.
Helm-chart is located in [./deploy/helm/init](./deploy/helm/init) directory.

Full Helm chart description located in [chart README.md](./deploy/helm/init/README.md) file.

### Deployment

#### Prepare
Before install helm chart you need to create PostgreSQL database and Vault bucket **bc-wallet-common-trrfrm** application.
Just follow the instructions.

First. Create database and user role
```sql
CREATE DATABASE "bc-wallet-common-trrfrm";
CREATE ROLE "bc-wallet-common-trrfrm-init" PASSWORD 'some_password' NOSUPERUSER CREATEDB CREATEROLE INHERIT LOGIN;
ALTER DATABASE "bc-wallet-common-trrfrm" OWNER TO "bc-wallet-common-trrfrm-init";
ALTER DATABASE "bc-wallet-common-trrfrm" ALTER SCHEMA "bc-wallet-common-trrfrm" OWNER TO "bc-wallet-common-trrfrm-init";
ALTER SEQUENCE "global_states_id_seq" OWNER TO "bc-wallet-common-trrfrm-init";
```
Create bucket in Hashicorp Vault.
```bash
vault kv put -mount=kv crypto-bundle/bc-wallet-common/trrfrm/init POSTGRESQL_PASSWORD=some_password POSTGRESQL_USERNAME=bc-wallet-common-trrfrm-init
```
Now you need to run terraform application manually for first time.

```bash
# copy and feel content on env-trrfrm.env file
cp env-trrfrm-example.env env-trrfrm.env
# load environment variables from .env file
source env-trrfrm.env
# init terraform 
export $(cat env-trrfrm.env | xargs) && terraform -chdir=deploy/trrfrm/init init
# apply terraform project
export $(cat env-trrfrm.env | xargs) && terraform -chdir=deploy/trrfrm/init apply
```

That's all. Preparation jobs done. Now you can deploy `bc-wallet-common-trrfrmr-base` Helm-chart.

#### Environment variables

Trrfrm application works with the following environment variables:

* `VAULT_ADDR` - address of Hashicorp Vault server.
* `VAULT_AUTH_TOKEN_FILE_PATH` - path to file contains Hashicorp Vault authorization token.
  Content of token file will be assigned to `VAULT_TOKEN` environment variable. Default value `/vault/secrets/token`
* `VAULT_TOKEN` - Hashicorp Vault authorization token. Value of this environment variable will be filed by [entrypoint.sh](entrypoint.sh) script during Docker container work.
* `APP_LOCAL_ENV_FILE_PATH` - path to file which contains values of other environment variables.
* `PGHOST` - host address of PostgreSQL server.
* `PGPORT` - host port of PostgreSQL server.
* `PGPASSWORD` - password for access in PostgreSQL database.
* `PGUSER` - password for access in PostgreSQL database.
* `PGDATABASE` - database name for storing Terraform state, Default value - `bc-wallet-common-trrfrm`.
* `PG_SCHEMA_NAME` - database schema name for storing Terraform state of application. Main rule - one schema per applications set.
  For example value of bc-wallet-tron-hdwallet application will contain same value - `bc-wallet-tron-hdwallet`.
* `TRFRM_PROJECT_NAME` - name of instane of **Trrfrm-Job**. You can re-use job template for prepare another applications environments.
* `TRFRM_WORK_DIR` - path to common `bc-wallet-common-trrfrm` directory on persistent store.
* `TRFRM_DATA_DIR` - path to data dir of current `Trrfrm-Job` directory on persistent store.
* `TRFRM_SOURCE_DIR` - path to source code directory of current `Trrfrm Job`.
* `TRRFRM_TMP_EXECUTION_DIR`
  Terraform source code must be placed on read-only docker overlay file system.
* `TRFRM_PLUGIN_CACHE_DIR` path to common `bc-wallet-common-trrfrm` Terraform plugins cache directory.

Some environment variables, like `PGPASSWORD` and `PGUSER` passed to Kubernetes Job via _.env_ file
through [Vault Secret injection](https://developer.hashicorp.com/vault/docs/platform/k8s/injector/examples).
You can control it via [values.yaml](deploy/helm/library/values.yaml) file.

#### Persistent volumes

Trrfrm uses Kubernetes persistent volume for store `.terraform` and Terraform plugin cache directories. 
Persistent volume must be mounted in the path which same with `TRFRM_WORK_DIR` value. This PV in one for all instances of Trrfrm-Jobs.

Example structure of PV content:

```text
/opt/trrfrm/source

/opt/trrfrm/workdir
├── bc-wallet-avalance-hdwallet
│   └── .terrform
├── bc-wallet-bitcoin-hdwallet
│   └── .terrform
├── bc-wallet-common-trrfrm
│   └── .terrform
├── bc-wallet-polygon-hdwallet
│   └── .terrform
├── bc-wallet-tron-hdwallet
│   └── .terrform
└── .terraform.d
    └── plugin-cache
```

#### Build

Before deploy helm chart you must build two docker images:
* Base Trrfrm container image
* CryptoBundle self-init Trrfrm image

Example of base image building

Build arguments:
* `PARENT_CONTAINER_IMAGE_NAME` - parent container image is **base Trrfrm image** - `hashicorp/terraform:latest`
* `TRFRM_SOURCE_DIR` - directory which contains terraform source code of project. By default - `/opt/trrfrm/source`
* `TRFRM_WORK_DIR` - common work directory for all Trrfrm Job instances. Default value - `/opt/trrfrm/work`
* `TRFRM_DATA_DIR` - .terraform data directory for project. by default - $TRFRM_WORK_DIR/$TRFRM_PROJECT_NAME/.terraform

```bash
docker build \
  --ssh default=$(SSH_AUTH_SOCK) \
  --platform linux/amd64 \
  --build-arg PARENT_CONTAINER_IMAGE_NAME=hashicorp/terraform:latest \
  --tag bc-wallet-common-trrfrm:v0.0.1 \
  --tag bc-wallet-common-trrfrm:latest \
  -f trrfrm-base.dockerfile .

docker push bc-wallet-common-trrfrm:v0.0.1
docker push bc-wallet-common-trrfrm:latest
```

Example of building self-init Trrfrm image

Build arguments:
* `PARENT_CONTAINER_IMAGE_NAME` - parent container image is **base Trrfrm image** - `bc-wallet-common-trrfrm:latest`
* `TRFRM_PROJECT_NAME` - Trrfrm project name. For exmaple - project name for **bc-wallet-tron-hdwallet** application - `bc-wallet-tron-hdwallet`.
  For Trrfrm init project - `bc-wallet-common-trrfrm`.
* `TRFRM_SOURCE_DIR` - directory which contains terraform source code of project. By default - `/opt/trrfrm/source`

```bash
docker build \
  --ssh default=$(SSH_AUTH_SOCK) \
  --platform linux/amd64 \
  --build-arg PARENT_CONTAINER_IMAGE_NAME=bc-wallet-common-trrfrm:latest \
  --build-arg TRFRM_PROJECT_NAME=bc-wallet-common-trrfr \
  --build-arg TRFRM_SOURCE_DIR=/opt/trrfrm/source \
  --tag bc-wallet-common-trrfrm-self-init:v0.0.1 \
  --tag bc-wallet-common-trrfrm-self-init:latest \
  -f trrfrm-self-init.dockerfile .

docker push bc-wallet-common-trrfrm-self-init:v0.0.1
docker push bc-wallet-common-trrfrm-self-init:latest
```

#### Configure
You can configure settings of Trrfrm kubernetes by edit [values.yaml](./deploy/helm/init/values.yaml) or
[values_local.yaml](./deploy/helm/init/values_local.yaml) files.
The values in these files overwrite the default values of [Trrfrm library chart](./deploy/helm/library/Chart.yaml)

#### Install
You can deploy Trrfrm Job application via Helm.

```bash
helm --kube-context $(context) dependency update ./deploy/helm/init

helm --kube-context $(context) upgrade \
      --install $(trrfrm_project_name) \
      --set "global.env=$(env)" \
      --set "terraformer.image.path=$(target_container_path)" \
      --set "terraformer.image.tag=$(build_tag)" \
      --values=./deploy/helm/init/values.yaml \
      --values=./deploy/helm/init/values_local.yaml \
      ./deploy/helm/init
```

## Contributors
* Author and maintainer - [@gudron (Alex V Kotelnikov)](https://github.com/gudron)

## Licence

**bc-wallet-common-trrfrm** is licensed under the [MIT NON-AI](./LICENSE) License.