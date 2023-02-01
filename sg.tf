# Create a security group 
resource "aws_security_group" "websrvs-sg" {
  provider    = aws.region
  name        = "WebSRVs-SG"
  description = "Allow web inbound terrafic"
  vpc_id      = aws_vpc.vpc_useast.id
  tags = {
    Name = "WebSRVs-SG"
  }
  ingress {
    description = "Allow 80 from our public IP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.external_ip]
  }
  ingress {
    description = "allow 443 from our public IP"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.external_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.external_ip]
  }
}

