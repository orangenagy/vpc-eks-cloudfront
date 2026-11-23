#!/usr/bin/env bash
# Builds an arm64 EKS AL2023 AMI with the Nitro Sandboxes (pod isolation)
# runtime, using AWS's own amazon-eks-ami Packer build.
#
# Requires: packer, make, git, jq, aws cli. Builds in the account's default VPC.
# Takes roughly 20-30 minutes. Prints the AMI ID at the end; put it in
# terraform.tfvars as sandbox_ami_id.
#
# Usage: ami/build-sandbox-ami.sh            (defaults below)
#        K8S=1.37 AWS_PROFILE=terraform ami/build-sandbox-ami.sh
set -o errexit -o nounset -o pipefail

K8S="${K8S:-1.37}"
REGION="${REGION:-eu-west-2}"
export AWS_PROFILE="${AWS_PROFILE:-terraform}"
# Build instance: arm64, and supports Nitro Enclaves
INSTANCE_TYPE="${INSTANCE_TYPE:-m6g.large}"
# Pinned amazon-eks-ami commit (2026-11-20) so builds are repeatable
EKS_AMI_REF="${EKS_AMI_REF:-e0eaf56a3687412f15b050419156bde62fe55696}"

for bin in packer make git aws jq; do
  command -v "$bin" >/dev/null || { echo "ERROR: $bin not found" >&2; exit 1; }
done

workdir="$(mktemp -d)"
trap 'rm -rf "$workdir"' EXIT

git clone --quiet https://github.com/awslabs/amazon-eks-ami.git "$workdir/amazon-eks-ami"
git -C "$workdir/amazon-eks-ami" checkout --quiet "$EKS_AMI_REF"

cd "$workdir/amazon-eks-ami"
make build \
  os_distro=al2023 \
  k8s="$K8S" \
  arch=arm64 \
  enable_pod_isolation=true \
  aws_region="$REGION" \
  instance_type="$INSTANCE_TYPE"

ami_id="$(jq -r '.builds[-1].artifact_id' ./*manifest.json | cut -d: -f2)"
echo
echo "Built AMI: $ami_id"
echo "Add to terraform.tfvars:  sandbox_ami_id = \"$ami_id\""
