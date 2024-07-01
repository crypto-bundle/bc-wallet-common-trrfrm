# Change Log

## [v0.0.2] - 02.07.2024
### Fixed
* Fixed bug with `installment_name` trrfrm variable

## [v0.0.1] - 01.07.2024
### Added 
* Content of [README.md file](./README.md)
* Added support terraform variables for k8s namespace and installment name
  * `k8s_namespace`
  * `installment_name`
### Changed
* Common cryptobundle JWT init flow
* Changed entrypoint init flow
### Fixed
* Fixed problems with vault policies for trrfrm-init and trrfrm-worker users
* Fixed problems with PostgreSQL user permissions
* Fixed problems with Vault k8s auth service account

## [initial] - 24.06.2024
### Added
* Created Terraform project
* **Trrfrm** library Helm-chart
* **Trrfrm-init** Helm-chart