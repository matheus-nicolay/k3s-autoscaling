data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "kubernetes_worker01" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.medium"
  count = 1
  key_name = "kubernetes_cluster_key" # Insira o nome da chave criada antes.
  subnet_id = var.subnet_public_id
  vpc_security_group_ids = [aws_security_group.permitir_ssh_http_nodes.id]
  associate_public_ip_address = true

  tags = {
    Name = "k3s_worker-${count.index}"
    # Insira o nome da instância de sua preferência.
  }

  connection {
    type     = "ssh"
    user     = "ubuntu"
    private_key = file("../kubernetes_cluster_key.pem")
    host     = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC='--tls-san ${self.public_ip}' sh -",
      "sudo hostnamectl set-hostname k3smaster-${self.private_ip}",
      "echo K3S_URL=https://${self.private_ip}:6443",
      "echo K3S_TOKEN=`cat /var/lib/rancher/k3s/server/node-token`"
    ]
  }
}

variable "vpc_id" {
  default = "vpc-05080ed834a4ca1b5" # Orientações para copia da VPC ID abaixo.
}

variable "subnet_public_id" {
  default = "subnet-04869fbe8e9d3b83e" # Orientações para copia da Subnet ID abaixo.
}

resource "aws_security_group" "permitir_ssh_http_nodes" {
  name        = "permitir_ssh_http_worker02"
  description = "Permite SSH e HTTP na instancia EC2"
  vpc_id      = var.vpc_id

    ingress {
    description = "SSH to EC2"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP to EC2"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS to EC2"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "K3S to EC2"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "K3S to EC2-1"
    from_port   = 8472
    to_port     = 8472
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kubelet metrics"
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kubelet2"
    from_port   = 16443
    to_port     = 16443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Flannel Wireguard "
    from_port   = 51820
    to_port     = 51820
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "all traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "permitir_ssh_e_http"
  }

}

data "aws_instances" "k3s_workers" {
  instance_state_names = ["running"]
}

output "instances" {
  value = "${data.aws_instances.k3s_workers.ids}"
}