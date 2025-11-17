variable "project_id" {
  type        = string
  default     = "mitochondria-476610"
}

variable "region" {
  type        = string
  default     = "us-central1"
}

variable "zone" {
  type        = string
  default     = "us-central1-a"
}

variable "docker_image" {
  type        = string
  default     = "us-central1-docker.pkg.dev/mitochondria-476610/my-php-repo/subhash:v1"
}

