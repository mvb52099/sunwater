#Latest AMI to be used when spinning up EC2 instance below
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

#Creating EC2 Instance
resource "aws_instance" "web-server" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.amazon_linux_2.id
  vpc_security_group_ids = [aws_security_group.web-server.id]
  subnet_id              = aws_subnet.public[0].id
  user_data              = file("install_httpd.sh")
  key_name               = "ubuntu"
  iam_instance_profile   = aws_iam_instance_profile.ssm_profile.name
  associate_public_ip_address = true 

  tags = {
    Name = "mvb5209-web-server"  
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
}

#Resource to create IAM role 
resource "aws_iam_role" "ssm_role" {
  name = "mvb5209-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

#Resource to attach SSM policy to role above
resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

#Resource to create profile for role above
resource "aws_iam_instance_profile" "ssm_profile" {
  name = "mvb5209-ssm-profile"
  role = aws_iam_role.ssm_role.name
}

