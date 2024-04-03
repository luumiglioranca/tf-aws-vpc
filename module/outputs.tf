output "vpc_id" {
  value = module.create_vpc.vpc_id
}

output "vpc_cidr" {
  value = module.create_vpc.vpc_cidr
}


output "subnets_private" {
  value = [
    "${module.create_vpc.subnet_private[0]}",
    "${module.create_vpc.subnet_private[1]}",
  ]
}

output "subnet_private_id" {
  value = [
    "${module.create_vpc.subnet_private_id[0]}",
    "${module.create_vpc.subnet_private_id[1]}"
  ]
}

output "subnets_public" {
  value = [
    "${module.create_vpc.subnet_public[0]}",
    "${module.create_vpc.subnet_public[1]}",
  ]
}

output "subnet_public_id" {
  value = [
    "${module.create_vpc.subnet_public_id[0]}",
    "${module.create_vpc.subnet_public_id[1]}"
  ]
}