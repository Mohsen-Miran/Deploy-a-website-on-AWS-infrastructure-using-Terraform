#Create a private key which can be used to login to the website
resource "tls_private_key" "WebSRVs-Key" {
  algorithm = "RSA"
}

#Create a private key which can be used to login to the website
resource "aws_key_pair" "app-instance-key" {
  provider   = aws.region
  key_name   = "WebSRVs-Key"
  public_key = tls_private_key.WebSRVs-Key.public_key_openssh
}

#Save the key to your local system
resource "local_file" "WebSRVs-Key" {
  content  = tls_private_key.WebSRVs-Key.private_key_pem
  filename = "WebSRVs-Key.pem"
}



