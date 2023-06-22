# docker-kd

This is created from https://github.com/UKHomeOffice/kd - in particular around container creation with dependency kubectl

Usage documentation remains unchanged from above kd repo

## Versioning
The container image will be based on the Kubectl release version which is also used as the KD version. A definitive list can be found https://github.com/kubernetes/kubernetes/releases

However, due to automated ACP build processes and other dependencies such as kubectl the tag following tag format will be used:
`<Kubernetes Version>-build.x` where x is an incrementing integer

Upon satisfactory testing, the build version will be promoted to both the helm version tag and latest in quay.io

Versioning will be maintained by updating the `.semver` file. E.g. should Kubernetes 3.99.999 release, the `.semver` file will need to be `3.99.999-build.0`