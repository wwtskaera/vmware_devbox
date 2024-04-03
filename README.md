## Getting Started
Note: this packer build requires that vmware workstation be installed. Another prerequisite is that an assets directory be created with the archlinux iso. We aren't tracking it in git though.
```sh
packer init archbase.pkr.hcl
packer build archbase.pkr.hcl
```