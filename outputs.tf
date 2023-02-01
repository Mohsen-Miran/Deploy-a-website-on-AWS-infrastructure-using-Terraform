output "VPC-ID-US-EAST-1" {
  value = aws_vpc.vpc_useast.id
}

output "Test-VPC-NorthVirginia-IGW" {
  value = aws_internet_gateway.igw.id
}

output "Test-VPC-NorthVirginia-Public1-CiderBlock" {
  value = aws_subnet.subnet_1.cidr_block
}

output "Test-VPC-NorthVirginia-Public1-ID" {
  value = aws_subnet.subnet_1.id
}

output "Test-VPC-NorthVirginia-Public2-CiderBlock" {
  value = aws_subnet.subnet_2.cidr_block
}

output "Test-VPC-NorthVirginia-Public2-ID" {
  value = aws_subnet.subnet_2.id
}

output "Test-VPC-NorthVirginia-Private1-CiderBlock" {
  value = aws_subnet.subnet_3.cidr_block
}

output "Test-VPC-NorthVirginia-Private1-ID" {
  value = aws_subnet.subnet_3.id
}

output "Test-VPC-NorthVirginia-RouteTable-Name" {
  description = "The name of public route table:"
  value = aws_route_table.internet_route.tags.Name  
}

output "Test-VPC-NorthVirginia-RouteTable-Id" {  
  value = aws_route_table.internet_route.id  
}

output "WebSRVs-KeyPair-Name" {  
  value = aws_key_pair.app-instance-key.id
}

output "WebSRVs-Instances-Id" {
  value = {
    for instance in aws_instance.WebSRVs :    
	instance.tags.Name => instance.id
  }
}

output "WebSRVs-Public-IPs" {
  value = {
    for instance in aws_instance.WebSRVs :
    instance.tags.Name => instance.public_ip
  }
}

output "WebSRVs-Public-DNS-Name" {
  value = {
    for instance in aws_instance.WebSRVs :
    instance.tags.Name => instance.public_dns
  }
}

# This chunk of template can also be put inside outputs.tf for better segregation 
#output "Jenkins-Main-Node-Public-IP" {
#  value = aws_instance.jenkins-master.public_ip
#}


