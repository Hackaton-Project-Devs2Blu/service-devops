Aqui está o arquivo README completo e unificado, pronto para ser copiado para o seu repositório service-devops:

Markdown

# ⚙️ Engenharia de DevOps, FinOps & SRE - Projeto Patricia

![AWS](https://img.shields.io/badge/Cloud-AWS-orange)
![Terraform](https://img.shields.io/badge/IaC-Terraform-purple)
![FinOps](https://img.shields.io/badge/Cost-Spot%20%26%20Hibernation-green)
![Security](https://img.shields.io/badge/Security-OIDC%20%26%20Zero%20Trust-red)
![Uptime](https://img.shields.io/badge/Deploy-Zero%20Downtime-blue)

Este repositório é o cérebro da infraestrutura do ecossistema **Patricia**. Aqui reside o código Terraform que provisiona o "palco" na AWS para que os microsserviços (Java, C#, Flutter) performem com alta disponibilidade e custo mínimo.

---

## 🏗️ Arquitetura de Nuvem (Infrastructure as Code)

Toda a infraestrutura é declarativa e imutável, gerenciada via **Terraform**. Importante notar a separação de responsabilidades:
1.  **Terraform:** Provisiona a infraestrutura base (VPC, Cluster ECS, RDS, Load Balancers, Security Groups e Repositórios ECR).
2.  **GitHub Actions:** É responsável por construir o código da aplicação, criar a imagem Docker e atualizar a *Service Definition* no ECS.

### 📋 Inventário de Infraestrutura (O que o Terraform sobe)

Abaixo listamos todos os recursos provisionados automaticamente para garantir um ambiente Enterprise-Grade:

* **Networking & Segurança:**
    * **VPC Customizada:** Segmentação de rede para isolamento total.
    * **Subnets Públicas:** Exclusivas para o Load Balancer (ALB).
    * **Subnets Privadas:** Exclusivas para Aplicações e Banco de Dados (sem acesso direto à internet pública).
    * **Security Groups:** Regras de *Least Privilege* (O ALB só fala com a App na porta 8080/443; A App só fala com o Banco na 5432).
* **Compute (ECS Fargate):**
    * **Cluster ECS:** Orquestrador Serverless.
    * **Capacity Providers:** Configuração híbrida (Fargate Spot + Fargate On-Demand).
    * **Task Definitions:** Templates de execução dos containers com injeção de variáveis de ambiente seguras.
* **Delivery & Load Balancing:**
    * **Application Load Balancer (ALB):** Ponto único de entrada, gerenciando SSL e roteamento de tráfego.
    * **Target Groups:** Grupos de roteamento com Health Checks inteligentes configurados.
    * **ECR (Elastic Container Registry):** Repositórios privados para armazenar as imagens Docker versionadas.
* **Dados:**
    * **RDS PostgreSQL:** Instância gerenciada (t4g.micro) com backup automático e criptografia em repouso.

---

## 🚀 Estratégia de Deploy: Zero Downtime

Nossa esteira de CI/CD garante que a SEDEAD nunca pare. Utilizamos a estratégia de **Rolling Update** nativa do ECS, orquestrada pelo GitHub Actions:

1.  **Novo Artefato:** O Actions builda a imagem e envia para o ECR.
2.  **Provisionamento Paralelo:** O ECS sobe os novos containers (v2) ao lado dos antigos (v1).
3.  **Health Check Rigoroso:** O ALB testa a saúde da v2. Se falhar, o deploy é abortado.
4.  **Connection Draining:** Se a v2 estiver saudável, o ALB para de enviar tráfego para a v1 e aguarda o término das requisições ativas.
5.  **Desligamento:** Só então a v1 é desligada.
    * *Resultado:* O usuário não percebe oscilação ou erro 500 durante a atualização.

---

## 💰 FinOps: Otimização Extrema de Custos

Implementamos uma cultura de custo consciente desde o código.

### 1. Hibernação Automática (Smart Scale Down)
Para evitar desperdício de verba pública fora do horário de expediente em ambientes de Dev:
* Um Job automático altera o `desired_count` dos serviços ECS para **0**.
* **O que economizamos:** Computação (CPU/RAM) que custa por segundo.
* **O que mantemos:** O Banco de Dados (RDS) e o Load Balancer (ALB) permanecem ativos para manter a integridade dos dados e o Endpoint DNS.
* *Não destruímos a infraestrutura (Terraform Destroy), apenas hibernamos a computação.*

### 2. Spot Instances
Utilizamos **Fargate Spot**, aproveitando a capacidade ociosa da AWS para reduzir os custos de computação em até **70%** em comparação com instâncias On-Demand.

### 3. Infracost
A cada Pull Request neste repositório, um bot analisa o código Terraform e comenta a previsão de aumento ou redução na fatura mensal da AWS.

---

## 🛡️ Segurança: Zero Trust & DevSecOps

A segurança é garantida em profundidade, não apenas no perímetro.

### Autenticação Moderna (OIDC)
Eliminamos o risco de vazamento de credenciais mestres.
* **Como funciona:** O GitHub Actions não possui chaves de acesso (`AWS_ACCESS_KEY_ID`) salvas.
* **OpenID Connect:** O GitHub troca um token JWT temporário por uma Role AWS de curto prazo e permissões mínimas, válida apenas durante a execução do deploy.

### Pipeline de Blindagem
Antes de qualquer alteração na infraestrutura ser aplicada, ela passa por:
* **TruffleHog:** Varredura profunda no histórico git por segredos/chaves.
* **Checkov:** Auditoria de Compliance no código Terraform (ex: garante que o RDS está criptografado e não é público).
* **Trivy:** Scan de vulnerabilidades (CVEs) nas imagens Docker dos serviços.

### Segredos em Runtime
Nenhuma senha de banco ou chave de API existe hardcoded no repositório. Elas são injetadas nos containers em tempo de execução via **AWS Secrets Manager / Parameter Store**.

---

## 🤖 Observabilidade & ChatOps

* **Logs Centralizados:** Driver `awslogs` configurado para enviar STDOUT/STDERR de todos os containers para o CloudWatch.
* **Discord Alerts:** O time recebe notificações em tempo real sobre:
    * Status dos Deploys (Sucesso/Falha).
    * Status das pipelines de segurança.

---

## 🔧 Gerenciamento (Terraform)

Com a infraestrutura utilizando Backend Remoto (S3 + DynamoDB para State Locking)

