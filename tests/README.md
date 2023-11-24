## Metodologia

install terraform: https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli

```
git clone https://github.com/matheus-nicolay/k3s_terraform_aws-ec2

nano variables.conf

cd terraform/vpc

cd terraform/master_node
```

#NECESSÁRIO O LINK DO ELB

- **Variáveis:**
    - Chave e zona da AWS
    - SSH Public key

- **Passo-a-passo:**
    - Criação VPC
        - Criação Security Group
    - Criação do Master Node
        - Necessário armazenar: K3S_TOKEN, K3S_URL, IP Interno, hostname
        - Instalação Terraform, pip3 e prometheus_api_client
        - Apply do metrics-server, kube-state-metrics, Prometheus e Node exporter
        - Baixar códigos Terraform do worker node e instalar k3s-autoscalling como serviço (Considerar variável de Chave e zona da AWS)
    - Criação dos 2 Worker Node
    - Deploy da aplicação e do hpa

```
git clone

install terraform, install kubectl

nano variables.conf

terraform apply vpc
terraform apply master_node
	#resto do passo-a-passo feito no master node
	#fazer master node retornar o kubectl
```
