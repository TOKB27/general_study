resource "aws_instance" "tf-ec2-01" {
  ami           = "ami-0dfa284c9d7b2adad"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.tf-vpc-01-pub-01-a.id
  key_name = "TF-AWS-KEY"

  tags = {
    Name = "TF-EC2-01"
    Env = "TF-WORK"
  }
}
