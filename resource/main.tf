############################################################################################################
#                                                                                                          #
#                                                                                                          #
#                                    CRIAÇÃO DA VPC - VIRTUAL PRIVATE CLOUD                                #
#                                                                                                          #
#                                                                                                          #
############################################################################################################

resource "aws_vpc" "main" {
  count = var.create ? 1 : 0

  cidr_block                       = var.cidr_block
  enable_dns_hostnames             = var.enable_dns_hostnames
  enable_dns_support               = var.enable_dns_support
  instance_tenancy                 = var.instance_tenancy
  assign_generated_ipv6_cidr_block = var.assign_generated_ipv6_cidr_block

  tags = merge({ Name = var.vpc_name },

    var.default_tags
  )
}

############################################################################################################
#                                                                                                          #
#                                                                                                          #
#                                    CRIAÇÃO DO DHCP OPTIONS + ASSOCIATION                                 #
#                                                                                                          #
#                                                                                                          #
############################################################################################################

resource "aws_vpc_dhcp_options" "dhcp_options" {
  count = var.create ? length(var.dhcp_options) : 0

  domain_name         = lookup(var.dhcp_options[count.index], "domain_name", "${var.region}.compute.internal")
  domain_name_servers = lookup(var.dhcp_options[count.index], "domain_name_servers", null)

  tags = merge({ Name = lookup(var.dhcp_options[count.index], "Name", "${var.vpc_name}-DHCP") },

    var.default_tags
  )
}

resource "aws_vpc_dhcp_options_association" "dhcp-opts-assoc" {
  count = var.create ? length(var.dhcp_options) : 0

  vpc_id          = data.aws_vpc.main.id
  dhcp_options_id = aws_vpc_dhcp_options.dhcp_options.0.id
}

############################################################################################################
#                                                                                                          #
#                                                                                                          #
#                                         SUBNET PÚBLICA (CASO PRECISE)                                    #
#                                                                                                          #
#                                                                                                          #
############################################################################################################

resource "aws_subnet" "public" {
  depends_on = [aws_vpc.main]

  count = var.create ? length(var.subnet_public) : 0

  vpc_id = data.aws_vpc.main.id

  cidr_block              = lookup(var.subnet_public[count.index], "cidr_block", null)
  availability_zone       = lookup(var.subnet_public[count.index], "availability_zone", null)
  map_public_ip_on_launch = lookup(var.subnet_public[count.index], "map_public_ip_on_launch", null)

  tags = merge({ Name = lookup(var.subnet_public[count.index], "tag_name", null) },

    lookup(var.subnet_public[count.index], "tag_public", null),

    var.default_tags
  )
}

############################################################################################################
#                                                                                                          #
#                                                                                                          #
#                                              INTERNET GATEWAY :)                                         #
#                                                                                                          #
#                                                                                                          #
############################################################################################################

resource "aws_internet_gateway" "main" {
  count = var.create && length(var.subnet_public) > 0 ? 1 : 0

  vpc_id = data.aws_vpc.main.id

  tags = merge({ Name = format("%s", "${var.vpc_name}-Internet-Gateway") },

    var.default_tags
  )
}

############################################################################################################
#                                                                                                          #
#                                                                                                          #
#                                        ROUTE TABLE PUBLICO + ASSOCIATION                                 #
#                                                                                                          #
#                                                                                                          #
############################################################################################################

resource "aws_route_table" "public" {
  depends_on = [aws_vpc.main]

  count = var.create && length(var.subnet_public) > 0 ? 1 : 0

  vpc_id = data.aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.0.id
  }

  tags = merge({ Name = "${var.vpc_name}-Public-Route-Table" },

    var.default_tags
  )
}

resource "aws_route_table_association" "public" {
  count = var.create ? length(var.subnet_public) : 0

  route_table_id = element(aws_route_table.public.*.id, count.index)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
}

############################################################################################################
#                                                                                                          #
#                                                                                                          #
#                                     ELASTIC IP + NAT GATEWAY - PÚBLICO                                   #
#                                                                                                          #
#                                                                                                          #
############################################################################################################

resource "aws_eip" "public" {
  count = var.create && var.enable_nat_gateway ? length(var.subnet_public) : 0

  domain = "vpc"

  tags = merge({ Name = "${var.vpc_name}-Elastic-IP" },

    var.default_tags
  )

  depends_on = [aws_internet_gateway.main]

}

resource "aws_nat_gateway" "public" {
  count = var.create && var.enable_nat_gateway ? length(var.subnet_public) : 0

  allocation_id = element(aws_eip.public.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)

  tags = merge({ Name = "${var.vpc_name}-NAT-Gateway" },

    var.default_tags
  )
}

############################################################################################################
#                                                                                                          #
#                                                                                                          #
#                                              SUBNET PRIVADA :)                                           #
#                                                                                                          #
#                                                                                                          #
############################################################################################################

resource "aws_subnet" "private" {
  depends_on = [aws_vpc.main]

  count = var.create ? length(var.subnet_private) : 0

  vpc_id = data.aws_vpc.main.id

  cidr_block              = lookup(var.subnet_private[count.index], "cidr_block", null)
  availability_zone       = lookup(var.subnet_private[count.index], "availability_zone", null)
  map_public_ip_on_launch = lookup(var.subnet_private[count.index], "map_public_ip_on_launch", null)

  tags = merge({ Name = lookup(var.subnet_private[count.index], "tag_name", null) },

    lookup(var.subnet_private[count.index], "tag_private", null),

    var.default_tags
  )
}

############################################################################################################
#                                                                                                          #
#                                                                                                          #
#                                     ROUTE TABLE PRIVADO + ASSOCIATION                                    #
#                                                                                                          #
#                                                                                                          #
############################################################################################################

resource "aws_route_table" "private" {
  count = var.create ? length(var.subnet_private) : 0

  vpc_id = data.aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.public.*.id, count.index)
  }

  tags = merge({ Name = format("%s", "${var.vpc_name}-Private-Route-Table") },

    var.default_tags
  )

  lifecycle {
    ignore_changes = [route]
  }
}

resource "aws_route_table_association" "private" {
  count = var.create ? length(var.subnet_private) : 0

  route_table_id = element(aws_route_table.private.*.id, count.index)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
}

############################################################################################################
#                                                                                                          #
#                                                                                                          #
#                                             NETWORK ACL DEFAULT :)                                       #
#                                                                                                          #
#                                                                                                          #
############################################################################################################

resource "aws_default_network_acl" "default" {
  count = var.create ? 1 : 0

  default_network_acl_id = aws_vpc.main.0.default_network_acl_id

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    icmp_code  = 0
    icmp_type  = 0
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    icmp_code  = 0
    icmp_type  = 0
    from_port  = 0
    to_port    = 0
  }

  tags = merge({ Name = "${var.vpc_name}-Network-ACL" },

    var.default_tags
  )

  lifecycle {
    ignore_changes = [subnet_ids]
  }
}

############################################################################################################
#                                                                                                          #
#                                                                                                          #
#                                   VPC FLOW LOGS - (LOGS DO TRÁFEGO DE REDE)                              #
#                                                                                                          #
#                                                                                                          #
############################################################################################################

resource "aws_flow_log" "vpc_flow_log" {
  count = var.create ? length(var.flow_logs) : 0

  vpc_id          = data.aws_vpc.main.id
  log_destination = aws_cloudwatch_log_group.cw-log-group.0.arn
  iam_role_arn    = aws_iam_role.flow_logs_role.0.arn
  traffic_type    = lookup(var.flow_logs[count.index], "traffic_type", null)
  log_format      = lookup(var.flow_logs[count.index], "log_format", null)

  tags = merge({ Name = "${var.vpc_name}-Flow-Logs" },

    var.default_tags
  )

}

############################################################################################################
#                                                                                                          #
#                             CLOUDWATCH LOG GROUP - (TRÁFEGO DE REDE PELO CLOUDWATCH)                     #
#                                                                                                          #
#                                      > DIFERENTE DO VPC FLOW LOGS <                                      #
#                                                                                                          #
############################################################################################################

resource "aws_cloudwatch_log_group" "cw-log-group" {
  count = var.create ? length(var.flow_logs) : 0

  name              = "${var.vpc_name}-Log-Group"
  retention_in_days = lookup(var.flow_logs[count.index], "retention_in_days", null)
}

############################################################################################################
#                                                                                                          #
#                                                                                                          #
#                                       VPC FLOW LOGS - (IAM ROLE + POLICY)                                #
#                                                                                                          #
#                                                                                                          #
############################################################################################################

resource "aws_iam_role" "flow_logs_role" {
  count = var.create ? length(var.flow_logs) : 0

  name = "${var.vpc_name}-Flow-Logs-Role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "flow_logs_policy" {
  count = var.create ? length(var.flow_logs) : 0

  name   = "${var.vpc_name}-Flow-Logs-Policy"
  role   = aws_iam_role.flow_logs_role.0.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "${aws_cloudwatch_log_group.cw-log-group.0.arn}"
    }
  ]
}
EOF
}
