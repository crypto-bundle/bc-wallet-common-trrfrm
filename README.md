# bc-wallet-common-trrfrm

## Description

Toolchain for infrastructure preparation flow. Repository contains library Helm-chart for running Terraform jobs. 
Also, repository contains base Docker Terraform wrapper image.

### Terraform

### Docker container

### Helm chart

### Environment variables

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

Some environment variables, like `PGPASSWORD` and `PGUSER` passed to Kubernetes Job via _.env_ file 
through [Vault Secret injection](https://developer.hashicorp.com/vault/docs/platform/k8s/injector/examples).
You can control it via [values.yaml](deploy/helm/library/values.yaml) file.

## Usage examples

## Contributors
* Author and maintainer - [@gudron (Alex V Kotelnikov)](https://github.com/gudron)

## Licence

**bc-wallet-common-trrfrm** is licensed under the [MIT NON-AI](./LICENSE) License.