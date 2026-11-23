variable "eks_auto_mode" {
  description = "true = EKS Auto Mode (AWS manages nodes). false = regular EKS with a managed node group. Pick before creating the cluster; switching an existing cluster isn't clean."
  type        = bool
  default     = true
}

variable "node_instance_types" {
  description = "Instance types for the managed node group (regular mode only)"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_desired_size" {
  description = "Desired node count for the managed node group (regular mode only)"
  type        = number
  default     = 2
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
    error_message = "Set at least one CIDR, and don't use 0.0.0.0/0."
  }
}
