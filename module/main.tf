############################################################################################################
#                                                                                                          #
#                                                                                                          #
#                        MÓDULO PARA CRIAÇÃO DA VPC - VIRTUAL PRIVATE CLOUD [2 AZ'S] :)                    #
#                                                                                                          #
#                                                                                                          #
############################################################################################################

module "create_vpc" {
  source = "git@github.com:luumiglioranca/tf-aws-vpc.git//resource"

  vpc_name                         = local.resource_name
  cidr_block                       = local.cidr_block
  region                           = local.region
  enable_nat_gateway               = "true"
  enable_dns_hostnames             = "true"
  enable_dns_support               = "true"
  instance_tenancy                 = "default"
  assign_generated_ipv6_cidr_block = "false"

  dhcp_options = [{
    domain_name_servers = ["AmazonProvidedDNS"]
  }]

  subnet_public = [
    {
      tag_name                = "${local.resource_name}-pub-1a"
      cidr_block              = "${local.subnet_ranges}.0/26"
      availability_zone       = "${local.region}a"
      map_public_ip_on_launch = "${"true"}"
    },
    {
      tag_name                = "${local.resource_name}-pub-1b"
      cidr_block              = "${local.subnet_ranges}.64/26"
      availability_zone       = "${local.region}b"
      map_public_ip_on_launch = "${"true"}"
    } /*,
    {
      tag_name                = "${local.resource_name}-pub-1c"
      cidr_block              = "${local.subnet_ranges}.64/27"
      availability_zone       = "${local.region}c"
      map_public_ip_on_launch = "${"true"}"
    }*/
  ]

  subnet_private = [
    {
      tag_name          = "${local.resource_name}-priv-1a"
      cidr_block        = "${local.subnet_ranges}.128/26"
      availability_zone = "${local.region}a"
    },
    {
      tag_name          = "${local.resource_name}-priv-1b"
      cidr_block        = "${local.subnet_ranges}.192/26"
      availability_zone = "${local.region}b"
    } /*,
    {
      tag_name                = "${local.resource_name}-priv-1c"
      cidr_block              = "${local.subnet_ranges}.160/27"
      availability_zone       = "${local.region}c"
      map_public_ip_on_launch = "${"true"}"
    }*/
  ]

  default_tags = local.default_tags
}

/* ################### UM EXEMPLO COM 3 ZONAS DE DISPONIBILIDADE ###################

OBS: No caso abaixo, temos um exemplo de 3 subnets públicas e 3 subnets privadas.

Se trata de um /27 com 32 ranges por subnet. Este exemplo deve ser utilizado apenas para ambientes produtivos

No caso de mais ranges por subnet, utilizar um /25 e estender para 64 ou 128 IP's.

subnet_public = [
    {
      tag_name                = "${local.resource_name}-pub-1a"
      cidr_block              = "${local.subnet_ranges}.0/27"
      availability_zone       = "${local.region}a"
      map_public_ip_on_launch = "${"true"}"
    },
    {
      tag_name                = "${local.resource_name}-pub-1b"
      cidr_block              = "${local.subnet_ranges}.32/27"
      availability_zone       = "${local.region}b"
      map_public_ip_on_launch = "${"true"}"
    },
    {
      tag_name                = "${local.resource_name}-pub-1c"
      cidr_block              = "${local.subnet_ranges}.64/27"
      availability_zone       = "${local.region}c"
      map_public_ip_on_launch = "${"true"}"
    }
  ]

  subnet_private = [
    {
      tag_name          = "${local.resource_name}-priv-1a"
      cidr_block        = "${local.subnet_ranges}.96/27"
      availability_zone = "${local.region}a"
    },
    {
      tag_name          = "${local.resource_name}-priv-1b"
      cidr_block        = "${local.subnet_ranges}.128/27"
      availability_zone = "${local.region}b"
    },
    {
      tag_name                = "${local.resource_name}-priv-1c"
      cidr_block              = "${local.subnet_ranges}.160/27"
      availability_zone       = "${local.region}c"
      map_public_ip_on_launch = "${"true"}"
    }
  ]
*/
