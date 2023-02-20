module "vpc-subnets" {
  source = "./Network"

  vpc-cidrs         = var.vpc-cidrs
  public-cidr-subs  = var.public-cidr-subs
  AZ                = var.AZ
  private-cidr-subs = var.private-cidr-subs
  public-traffic    = var.public-traffic
}


module "Cluster" {

    source = "./Cluster"
    private-Subnets = module.vpc-subnets.private-subnet-ids
  
}