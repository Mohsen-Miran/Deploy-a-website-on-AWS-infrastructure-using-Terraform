#Get Linux AMI ID using SSM Parameter endpoint in us-east-1
data "aws_ssm_parameter" "linuxAmi" {
  provider = aws.region
  name     = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

data "aws_availability_zones" "available" {}

#Create and bootstrap EC2 in us-east-1
resource "aws_instance" "WebSRVs" {
  provider                    = aws.region
  count                       = var.websrvs-count
  ami                         = data.aws_ssm_parameter.linuxAmi.value
  instance_type               = var.instance-type
  key_name                    = aws_key_pair.app-instance-key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.websrvs-sg.id]
  subnet_id                   = aws_subnet.subnet_1.id

  tags = {
    Name = join("_", ["WebSRVs", count.index + 1])
  }

  depends_on = [aws_route_table.internet_route]

  provisioner "remote-exec" {
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = tls_private_key.WebSRVs-Key.private_key_pem
    host        = aws_instance.WebSRVs[0].public_ip
  }
  inline = [
     "sudo yum -y update",
	 "sudo yum -y install httpd php git",
	 "sudo systemctl restart httpd",
	 "sudo systemctl enable httpd",
   ]
 }

}



