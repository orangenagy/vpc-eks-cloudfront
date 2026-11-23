variable "eks_auto_mode" {
  description = "true = EKS Auto Mode (AWS manages nodes). false = regular EKS with a managed node group. Pick before creating the cluster; switching an existing cluster isn't clean."
  type        = bool
  default     = true
}

variable "node_instance_types" {
  description = "Instance types for the managed node group (regular mode only)."
  type        = list(string)
  default     = ["t3.small"]
}

variable "node_capacity_type" {
  description = "ON_DEMAND or SPOT for the managed node group (regular mode only). Spot is ~60-70% cheaper but nodes can be reclaimed."
  type        = string
  default     = "ON_DEMAND"

  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.node_capacity_type)
    error_message = "Must be ON_DEMAND or SPOT."
  }
}

variable "node_min_size" {
  description = "Minimum node count for the managed node group"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum node count for the managed node group"
  type        = number
  default     = 3
}

variable "node_desired_size" {
  description = "Node count at creation. Keep >= 1 so CoreDNS can start; Terraform ignores later changes, scale with the AWS CLI instead."
  type        = number
  default     = 1
}

variable "public_subnets_only" {
  description = "Cheap mode: run the cluster and nodes in the public subnets (nodes get public IPs) and skip the NAT gateways and VPC endpoints"
  type        = bool
  default     = false
}

variable "api_allowed_cidrs" {
  description = "CIDRs allowed to reach the public EKS API endpoint, e.g. [\"1.2.3.4/32\"]. Nodes use the private endpoint so don't need to be listed."
  type        = list(string)

  validation {
    condition     = length(var.api_allowed_cidrs) > 0 && !contains(var.api_allowed_cidrs, "0.0.0.0/0")
    error_message = "Set api_allowed_cidrs in terraform.tfvars to your IP, e.g. [\"1.2.3.4/32\"] (find it with: curl https://checkip.amazonaws.com). 0.0.0.0/0 is not allowed."
  }
}

variable "sandbox_ami_id" {
  description = "Nitro Sandbox AMI from ami/build-sandbox-ami.sh. Empty = no sandbox node group (regular mode only)."
  type        = string
  default     = ""
}

variable "sandbox_instance_type" {
  description = "Instance type for the sandbox node group. Must support Nitro Sandboxes and match the AMI's arch (arm64)."
  type        = string
  default     = "m6g.large"
}

variable "sandbox_node_desired_size" {
  description = "Sandbox node count at creation (min 0, max 1). Terraform ignores later changes."
  type        = number
  default     = 1
}
