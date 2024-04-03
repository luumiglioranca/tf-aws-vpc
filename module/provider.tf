########################################################################################################
#                                                                                                      #
#                                     CONNECT PROVIDER - AWS    :)                                     #
#                                                                                                      #
########################################################################################################

provider "aws" {
  #Região onde será configurado seu recurso. Deixei us-east-1 como default
  region  = "us-east-1" 

  #Conta mãe que será responsável pelo provisionamento do recurso.
  profile = "" 
  
  #Assume Role necessária para o provisionamento de recurso, caso seja via role.
  assume_role {
    role_arn = "" #Role que será assumida pela sua conta principal :)
  }
}

#Configurações de backend, neste caso para armazenar o estado do recurso via Bucket S3.
terraform {
  backend "s3" {
    #Profile (conta) de onde está o bucket que você irá armazenar seu tfstate 
    profile                     = "" 

    #Nome do Bucket
    bucket                      = "" 

    #Caminho da chave para o recurso que será criado
    key                         = "caminho-da-chave/exemplo/vpc-peering/terraform.tfstate"

    #Região onde será configurado seu recurso. Deixei us-east-1 como default
    region                      = "us-east-1" 

    #Valores de segurança. Encriptação, Validação de credenciais e Check da API.
    encrypt                     = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
  }
}

########################################################################################################
#                                                                                                      #
#                                     DECLARAÇÃO DE VARIÁVEIS LOCAIS   :)                              #
#                                                                                                      #
########################################################################################################

locals {
  region        = ""
  cidr_block    = ""
  subnet_ranges = ""
  resource_name = ""
  account_id    = ""

  #Algumas tags caso seja necessário
  #OBS: Se precisar criar uma política de TAG nova seguir: Conta Principal da sua organização > AWS Organizations > Polices > Tag policies > Create Policy :)
  tags = {
    Area = ""
    Ambiente = ""
    SubArea = ""
    Cliente = ""
  }
}