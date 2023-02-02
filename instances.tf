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
  vpc_security_group_ids      = [aws_security_group.websrvs-sg.id, aws_security_group.Only-ssh-sg.id]
  subnet_id                   = aws_subnet.subnet_1.id

  tags = {
    Name = join("_", ["WebSRVs", count.index + 1])
  }

  depends_on = [aws_route_table.internet_route]
}


#Create a EBS volume for data persistence
resource "aws_ebs_volume" "ebsvol1" {
  availability_zone = aws_instance.WebSRVs[0].availability_zone
  #This is the size of EBS volume
  size  = 5
  count = 2
  tags = {
    Name = join("_", ["EBSVolume", count.index + 1])
  }
}

#Attatch the volume to first instance
resource "aws_volume_attachment" "attach-ebsvol1" {
  depends_on   = [aws_ebs_volume.ebsvol1]
  device_name  = "/dev/sdh"
  volume_id    = aws_ebs_volume.ebsvol1[0].id
  instance_id  = aws_instance.WebSRVs[0].id
  force_detach = true
}

#Attatch the volume to second instance
resource "aws_volume_attachment" "attach-ebsvol2" {
  depends_on   = [aws_ebs_volume.ebsvol1]
  device_name  = "/dev/sdh"
  volume_id    = aws_ebs_volume.ebsvol1[1].id
  instance_id  = aws_instance.WebSRVs[1].id
  force_detach = true
}


#Mount the volume to first instance
resource "null_resource" "nullmount1" {
  depends_on = [aws_volume_attachment.attach-ebsvol1]
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = tls_private_key.WebSRVs-Key.private_key_pem
    host        = aws_instance.WebSRVs[0].public_ip
  }
  provisioner "remote-exec" {
    inline = [
      "sudo yum -y update",
      "sudo yum -y install httpd php git",
      "sudo systemctl restart httpd",
      "sudo systemctl enable httpd",
      "sudo mkfs.ext4 /dev/xvdh",
      "sudo mount /dev/xdvh /var/www/html",
      "sudo rm -rf /var/www/html/*",
      "sudo git clone https://github.com/Mohsen-Miran/Deploy-a-website-on-AWS-infrastructure-using-Terraform  /var/www/html"
    ]
  }
}

#Mount the volume to first instance
resource "null_resource" "nullmount2" {
  depends_on = [aws_volume_attachment.attach-ebsvol1]
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = tls_private_key.WebSRVs-Key.private_key_pem
    host        = aws_instance.WebSRVs[1].public_ip
  }
  provisioner "remote-exec" {
    inline = [
      "sudo yum -y update",
      "sudo yum -y install httpd php git",
      "sudo systemctl restart httpd",
      "sudo systemctl enable httpd",
      "sudo mkfs.ext4 /dev/xvdh",
      "sudo mount /dev/xdvh /var/www/html",
      "sudo rm -rf /var/www/html/*",
      "sudo git clone https://github.com/Mohsen-Miran/Deploy-a-website-on-AWS-infrastructure-using-Terraform  /var/www/html"
    ]
  }
}
