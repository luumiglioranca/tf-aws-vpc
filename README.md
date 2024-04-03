# Terraform IaC - VPC (VIRTUAL PRIVATE CLOUD)

Terraform module irá provisionar os seguintes recursos:

O codigo irá prover os seguintes recursos na AWS.
* [VPC](https://www.terraform.io/docs/providers/aws/r/vpc.html)
* [VPC Flow Log](https://www.terraform.io/docs/providers/aws/r/flow_log.html)
* [CloudWatch Log](https://www.terraform.io/docs/providers/aws/r/cloudwatch_log_group.html)
* [Subnet](https://www.terraform.io/docs/providers/aws/r/subnet.html)
* [Route](https://www.terraform.io/docs/providers/aws/r/route.html)
* [Route table](https://www.terraform.io/docs/providers/aws/r/route_table.html)
* [Internet Gateway](https://www.terraform.io/docs/providers/aws/r/internet_gateway.html)
* [Network ACL](https://www.terraform.io/docs/providers/aws/r/network_acl.html)
* [NAT Gateway](https://www.terraform.io/docs/providers/aws/r/nat_gateway.html)
* [DHCP Options Set](https://www.terraform.io/docs/providers/aws/r/vpc_dhcp_options.html)
* [Default Network ACL](https://www.terraform.io/docs/providers/aws/r/default_network_acl.html)
* [Elastic IP](https://www.terraform.io/docs/providers/aws/r/eip.html)

**_Importante:_** A documentação da haschicorp é bem completa, se quiserem dar uma olhada, segue o link do glossário com todos os recursos do terraform: https://registry.terraform.io/providers/hashicorp/aws/latest/docs

## Exemplo de um module pré-configurado :)
###  VPC + Subnets - (2 AZ'S na Virginia)
`Caso de uso`: Criando uma VPC com duas subnets publicas e duas privadas 

```bash

locals {
  #Região escolhida
  region     = ""
  
  #Range de rede escolhido. Poderia escolher o cidr com /20, /21, /22, /23, /24 e etc...
  cidr_block = "10.10.10.10/24" 

  #Nome da VPC
  vpc_name   = "VPC-MODULE-TERRAFORM"

  #Conta da AWS que será provisionado o recurso
  account_id = ""

  #Tag default true
  tag_true   = "true"

  #Algumas tags caso seja necessário
  #OBS: Se precisar criar uma política de TAG nova seguir: Conta Principal da sua organização > AWS Organizations > Polices > Tag policies > Create Policy :)
  default_tags = {
    Cliente  = ""
    Area     = ""
    Ambiente = ""
  }
}

module "create_vpc" {
  source = "git@github.com:luumiglioranca/tf-aws-vpc.git//resource"

  vpc_name                         = local.vpc_name
  cidr_block                       = local.cidr_block
  region                           = local.region
  enable_nat_gateway               = local.tag_true
  enable_dns_hostnames             = local.tag_true
  enable_dns_support               = local.tag_true
  instance_tenancy                 = "default"
  assign_generated_ipv6_cidr_block = "false"

  dhcp_options = [{
    domain_name_servers = ["AmazonProvidedDNS"]
  }]

  subnet_public = [
    {
      tag_name                = "${local.vpc_name}-pub-1a"
      cidr_block              = "10.107.50.0/26"
      availability_zone       = "${local.region}a"
      map_public_ip_on_launch = "${local.tag_true}"
    },
    {
      tag_name                = "${local.vpc_name}-pub-1b"
      cidr_block              = "10.107.50.64/26"
      availability_zone       = "${local.region}b"
      map_public_ip_on_launch = "${local.tag_true}"
    }
  ]

  subnet_private = [
    {
      tag_name          = "${local.vpc_name}-priv-1a"
      cidr_block        = "10.107.50.128/26"
      availability_zone = "${local.region}a"
    },
    {
      tag_name          = "${local.vpc_name}-priv-1b"
      cidr_block        = "10.107.50.192/26"
      availability_zone = "${local.region}b"
    }
  ]

  default_tags = local.default_tags
}

```
## Para executar esse módulo você precisará: 

| Name | Version |
| ---- | ------- |
| aws | ~> 3.1 |
| terraform | ~> 0.12 |

## Arquivo Variables 

| Name | Description | Required | Type | Default |
| ---- | ----------- | -------- | ---- | ------- |
| vpc_name | O nome da sua VPC | `yes` | `string` | ` ` |
| region | Escolha qual região está criando a sua VPC | `no` | `string` | `us-east-1` |
| enable_dns_hostnames | Suporte a hostname de DNS na VPC. | `no` | `bool` | `false` |
| enable_dns_support | Suporte a DNS na VPC. | `no` | `bool` | `false` |
| dhcp_options | Block de chave-valor que fornece um recurso de opções VPC DHCP. | `no` | `map` | `{ }` |
| enable_nat_gateway | Quando habilitado, fornece um recurso de NAT Gateway, em conjundo com o Elastic IP. A quantidade de criação deste recurso vai de acordo com o numero de subnet criada. (importante, use quando tiver criando uma VPC com subnet publica e privada). | `no` | `bool` | `false` |
| subnet_public | Block para criação da sua subnet publica. Detalhes logo abaixo. | `no` | `list` | `[ ]` |
| subnet_private | Block para criação da sua subnet privada. Detalhes logo abaixo. | `no` | `list` | `[ ]` |
| default_tags | Block de chave-valor que fornece o taggeamento para todos os recursos criados em sua VPC. | `no` | `map` | `{}` |
| cidr_block | O bloco de CIDR para a sua VPC | `yes` | `string` | ` ` |
| subnet_database | Block para criação de uma subnet para seus database . Detalhes logo abaixo. | `no` | `list` | `[ ]` |
| subnet_cache | Block para criação de uma subnet para os elasticache . Detalhes logo abaixo. | `no` | `list` | `[ ]` |
| flow_logs | Registro de fluxo de uma VPC/Subnet/ENI para capturar um trafego de IP para uma interface de rede. Logs serão enviado para o CloudWatch Logs Group. | `no` | `list` | `[ ]` | 
| vpc_peering_connection | Fornece um recurso para criar uma conexão de VPC Peering VPC-to-VPC na mesma conta. Para VPC Peering entre contas diferentes, consulte [test](test) | `no` | `list` | `[ ]` |

# Variáveis e seus atributos:

PS: Também disponível na documentação

O argumento `subnet_public` possui os seguintes atributos;

- `tag_name`: O nome da sua subnet.
- `cidr_block`: O CIDR da sua subnet.
- `availability_zone`: Qual AZ será criada a sua subnet.
- `map_public_ip_on_launch`: Permite que as instâncias iniciadas na subnet podem receber um endereço IP público.
- `tag_public`: Um mapa de tags exclusiva para a sua subnet.

O argumento `subnet_private` possui os seguintes atributos;

- `tag_name`: O nome da sua subnet.
- `cidr_block`: O CIDR da sua subnet.
- `availability_zone`: Qual AZ será criada a sua subnet.
- `tag_private`: Um mapa de tags exclusiva para a sua subnet.

O argumento `dhcp_opts` possui os seguintes atributos;

- `domain_name`: O nome do domínio de sufixo a ser usado para resolver nomes FQDN. 
- `domain_name_servers`: Lista de servidores de nomes para configurar /etc/resolv.conf.

O argumento `flow_logs` possui os seguintes atributos;

- `traffic_type`: O tipo de tráfego a ser capturado. Valores válidos: ACCEPT, REJECT, ALL.
- `log_format`: Os campos a serem incluídos no registro do log de fluxo, na ordem em que devem aparecer
- `retention_in_days`: Retenção dos logs em dias.

O argumento `vpc_peering_connection` possui os seguintes atributos;

- `accepter_vpc_id`: O ID do VPC com o qual você está criando uma conexão de VPC Peering.
- `accepter_vpc_region`: A região da VPC do aceitante. Valores validos: true, false.
- `auto_accept`: Aceitar ou não a solicitação de peering. O padrão é false.

## Arquivo de Outputs

| Name | Description |
| ---- | ----------- |
| vpc | O ID da VPC criada |
| subnet_private | O CIDR da subnet privada criada |
| subnet_private_id | O Id da subnet privada criada |
| subnet_public | O CIDR da subnet publica criada |
| subnet_public_id | O Id da subnet publica criada |

## Espero que seja útil a todos!!!!! Grande abraço <3

**_Importante:_** Qualquer dificuldade encontrada, melhoria ou se precisarem alterar alguma linha de código, só entrar em contato que te ajudo <3