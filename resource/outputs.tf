output "vpc_id" {
  value = data.aws_vpc.main.id
}

output "vpc_cidr" {
  value = data.aws_vpc.main.cidr_block
}

output "subnet_private" {
  value = length(aws_subnet.private) > 1 ? aws_subnet.private.*.cidr_block : null
}

output "subnet_private_id" {
  value = length(aws_subnet.private) > 1 ? aws_subnet.private.*.id : null
}

output "subnet_public_id" {
  value = length(aws_subnet.private) > 1 ? aws_subnet.public.*.id : null
}

output "subnet_public" {
  value = length(aws_subnet.public) > 1 ? aws_subnet.public.*.cidr_block : null
}

output "internet_gateway" {
  value = length(aws_internet_gateway.main) > 0 ? aws_internet_gateway.main.0.id : null
}

output "elastic_ip" {
  value = length(aws_eip.public) > 1 ? aws_eip.public.*.public_ip : null
}

output "nat_gateway_public_ip" {
  value = length(aws_nat_gateway.public) > 1 ? aws_nat_gateway.public.*.public_ip : null
}

output "nat_gateway_private_ip" {
  value = length(aws_nat_gateway.public) > 1 ? aws_nat_gateway.public.*.private_ip : null
}

output "nat_gateway_id" {
  value = length(aws_nat_gateway.public) > 1 ? aws_nat_gateway.public.*.id : null
}

output "nat_gateway_sn" {
  value = length(aws_nat_gateway.public) > 1 ? aws_nat_gateway.public.*.subnet_id : null
}

output "rt_private_id" {
  value = length(aws_route_table.private) > 1 ? aws_route_table.private.*.id : null
}

output "rt_public_id" {
  value = length(aws_route_table.public) > 1 ? aws_route_table.public.*.id : null
}