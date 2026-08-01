provider "aws" {
  region = var.destination_region
}

provider "aws" {
  alias  = "central"
  region = var.source_region
}
