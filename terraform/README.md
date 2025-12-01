☁️ Cloud Infrastructure | Hackathon Project
Este repositório contém a Infraestrutura como Código (IaC) do projeto, provisionando um ambiente de microsserviços escalável, observável e otimizado para custos na AWS.

🏛️ Arquitetura da Solução

![imagem da infraestrutura técnica]([image-url](https://github.com/Hackaton-Project-Devs2Blu/service-devops/blob/develop/terraform/Arquitetura%20Hackaton.png))
A infraestrutura foi desenhada seguindo os pilares do AWS Well-Architected Framework, priorizando Eficiência de Performance, Segurança e Otimização de Custos.

1. Computação: Estratégia de Spot Instances
Utilizamos Amazon ECS com AWS Fargate para eliminar o gerenciamento de servidores (Serverless).

Decisão de Arquitetura (Hackathon vs. Produção):

No Hackathon: Configuramos o cluster para rodar 100% em Fargate Spot. Isso reduz o custo computacional em cerca de 70%, demonstrando uma mentalidade forte de FinOps.

Em Produção Real: A arquitetura está preparada para usar Capacity Providers híbridos, mantendo uma base mínima (base=1) em instâncias On-Demand (para garantir SLA de disponibilidade) e escalando o excedente via Spot (para economia).

2. Rede e Segurança (Zero Trust Network)
Isolamento de Tráfego (Ingress Restricted): Embora os containers rodem em subnets públicas (para evitar o custo de NAT Gateways), eles NÃO aceitam conexões diretas da internet.

O Security Group dos containers aceita tráfego APENAS vindo do Security Group do Application Load Balancer (ALB).

Qualquer tentativa de acesso direto ao IP da task é bloqueada pelo firewall da AWS.

Roteamento: Um único ALB gerencia o tráfego para os 3 microsserviços via Path-Based Routing (/api/java, /api/csharp, /).

3. Observabilidade Centralizada
Logs Automatizados: Todos os containers (Java, C#, Flutter) possuem o driver awslogs configurado.

CloudWatch: Os logs de aplicação (stdout/stderr) e eventos de infraestrutura são enviados automaticamente para Log Groups específicos no Amazon CloudWatch, com retenção configurada para curto prazo (economia de storage).

📂 Estrutura do Projeto
O projeto segue uma estrutura modular para facilitar a manutenção e escalabilidade:

Plaintext

service-devops/
├── bootstrap/             # 🛠️ Config inicial (S3 Backend + OIDC Role para GitHub)
├── infra-emergency/       # 🚨 PLANO B (EC2 Monolítica de Recuperação de Desastres)
├── observability/         # 📊 Dashboards e Alertas (CloudWatch)
├── scripts/               # Scripts auxiliares de automação
└── terraform/             # 🏗️ O Código da Infraestrutura Principal
    ├── modules/           # Módulos Reutilizáveis
    │   ├── alb/           # Load Balancer e Listeners
    │   ├── ecr/           # Repositórios de Imagens Docker
    │   ├── ecs/           # Cluster, Services (Fargate) e Task Definitions
    │   ├── security-group* # Regras de Firewall
    │   └── ...
    ├── main.tf            # Orquestrador dos módulos
    ├── variables.tf       # Definição de variáveis
    └── values.auto.tfvars # Valores por ambiente (ex: Oregon)

 Pré-requisitos e Ferramentas
Para garantir a estabilidade do tfstate e a compatibilidade dos módulos, utilizamos versões estritas:

Terraform: v1.13.1 (Obrigatório)

AWS Provider: 5.46 

AWS CLI: Configurado com credenciais adequadas (ou via OIDC no CI/CD).

 Pipeline de CI/CD (GitHub Actions)
O deploy é totalmente automatizado. Não realizamos deploys manuais para garantir rastreabilidade.

Pull Request: Dispara o terraform plan e gera uma estimativa de custos com Infracost.

Merge na Main: Dispara o terraform apply.

Segurança: A autenticação na AWS é feita via OIDC (OpenID Connect), eliminando o uso de Access Keys permanentes e aumentando a postura de segurança.

 Plano de Recuperação de Desastres (DR)
Caso ocorra uma falha catastrófica na região ou no serviço ECS durante a apresentação/desenvolvimento:

Existe um módulo isolado na pasta infra-emergency.

Este módulo provisiona uma instância EC2 em uma AZ diferente.

Um script user_data clona os repositórios, compila as aplicações e sobe a stack via Docker Compose em ~7 minutos.

🏆 Time Devs2Blu Hackathon
Infraestrutura pensada com muito amor e café.