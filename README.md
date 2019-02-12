# Terraform Configurations for Infrastructure

This repository contains a collection of sample/example [Terraform](https://www.terraform.io/) configurations for providing infrastructure to run self-managed/DIY [Kubernetes](https://kubernetes.io/) clusters.

## Structure

The structure of the repository is as follows:

```
(root)
   |- docs
   |- <platform 1>
       |- modules
       |- <environment 1>
           |- network
           |- storage
           |- identity
           |- net-security
           |- <other resources>
       |- <environment 2>
       |- <environment 3>
   |- <platform 2>
   |- <platform 3>
   |- ...
```

Each top-level directory in the repository (with the exception of the `docs` directory, which holds documentation for the repository) represents a target infrastructure platform (OCI, AWS, GCP, Azure, IBM Cloud, etc.).

Within each platform-specific directory, each environment (production, staging, test, development, etc.) will have its own directory. Each platform-specific directory will also have a `modules` directory containing modules for that particular infrastructure platform.

Within each environment-specific directory, each major resource will have a resource-specific directory.

## Contributing

Please observe the following guidelines when contributing to this repository:

1. All changes should be made in their own branch. The `master` branch represents the production-ready version of the Terraform configurations that is applied to infrastructure.

2. Before submitting a PR to merge changes from a branch into `master`, please rebase your branch against `master` to help keep the Git history clean.

3. When submitting a PR to merge changes from a branch into `master`, please limit changes in a PR to a particular platform. Do not submit PRs where changes span multiple platforms; instead, break those into separate PRs. For example, if you have changes for both the `oci` and `aws` platform configurations, those changes should be submitted in two PRs: one for the `oci` changes and one for the `aws` changes.

## License

The contents of this repository are licensed under the MIT License.
