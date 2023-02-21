module "vpc-subnets" {
  source = "./Network"

  vpc-cidrs         = var.vpc-cidrs
  public-cidr-subs  = var.public-cidr-subs
  AZ                = var.AZ
  private-cidr-subs = var.private-cidr-subs
  public-traffic    = var.public-traffic
}


module "Bastion-Host" {

    source = "./Bastion_host"
    public-Subnets = module.vpc-subnets.public-subnet-ids
    vpc-id = module.vpc-subnets.vpc-id
  
}

module "Cluster" {

    source = "./Cluster"
    private-Subnets = module.vpc-subnets.private-subnet-ids
  
}