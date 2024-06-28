# bc-wallet-common-trrfrm

## Description

Toolchain for infrastructure preparation flow. Repository contains library Helm-chart for running Terraform jobs. 
Also, repository contains base Docker Terraform wrapper image.

## Trrfrm-Job library chart

## Init Trrfrm-Job

Start of deployment crypto-bundle project is here. You must start from deployment of `bc-wallet-common-trrfrmr-base` kubernetes job.

### Deployment

#### Prepare
Before install helm chart you need to create PostgreSQL database and Vault bucket **bc-wallet-common-trrfrm** application.
Just follow the instructions.

First. Create database and user role
```sql
CREATE DATABASE "bc-wallet-common-trrfrm";
CREATE ROLE "bc-wallet-common-trrfrm-init" PASSWORD 'some_password' NOSUPERUSER CREATEDB CREATEROLE INHERIT LOGIN;
ALTER DATABASE "bc-wallet-common-trrfrm" OWNER TO "bc-wallet-common-trrfrm-init";
```
Create bucket in Hashicorp Vault.
```bash
vault kv put -mount=kv crypto-bundle/bc-wallet-common/trrfrm/init POSTGRESQL_PASSWORD=<some_password of bc-wallet-common-trrfrm-init user>
vault kv put -mount=kv crypto-bundle/bc-wallet-common/trrfrm/init POSTGRESQL_USERNAME=bc-wallet-common-trrfrm-init
```
That's all. Preparation jobs done. Now you can deploy `bc-wallet-common-trrfrmr-base` Helm-chart.

#### Environment variables

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
  Terraform source code must be placed on read-only docker overlay file system.
* `TRFRM_PLUGIN_CACHE_DIR` path to common `bc-wallet-common-trrfrm` Terraform plugins cache directory.

Some environment variables, like `PGPASSWORD` and `PGUSER` passed to Kubernetes Job via _.env_ file
through [Vault Secret injection](https://developer.hashicorp.com/vault/docs/platform/k8s/injector/examples).
You can control it via [values.yaml](deploy/helm/library/values.yaml) file.

#### Configure

#### Install

## Contributors
* Author and maintainer - [@gudron (Alex V Kotelnikov)](https://github.com/gudron)

## Licence

**bc-wallet-common-trrfrm** is licensed under the [MIT NON-AI](./LICENSE) License.