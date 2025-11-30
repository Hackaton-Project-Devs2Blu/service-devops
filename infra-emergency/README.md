#  INFRAESTRUTURA DE EMERGÊNCIA (PLANO B)

> **USAR SOMENTE EM CASO DE FALHA TOTAL DO CLUSTER ECS**

Esta pasta contém o código Terraform para subir uma infraestrutura "Monolítica" de emergência. Ela cria uma única instância EC2 (`t3.small`) na `us-east-1` que clona os repositórios, compila o código e sobe tudo via Docker Compose.

---

##  Tempo de Espera (IMPORTANTE)

Ao rodar este pipeline, o Terraform terminará em **~1 minuto**.
**PORÉM**, a aplicação demorará cerca de **5 a 10 minutos** para ficar disponível.

**Por que?**
A máquina precisa instalar o Docker, baixar o código Java/C#, compilar tudo do zero e subir os containers.
*Se você acessar o IP e der "Erro de Conexão", espere mais alguns minutos.*

---

##  Como pegar o IP de Acesso

Como este deploy é rodado via GitHub Actions, o IP da máquina aparecerá nos logs do pipeline.

1. Acesse a aba **Actions** no GitHub.
2. Clique na execução atual do workflow (ex: `Deploy Emergency Infra`).
3. Clique no Job **Terraform Apply**.
4. Role até o final dos logs e procure pela seção **Outputs**, que estará verde ou branca no final do comando.

Você verá algo assim:

```text
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

z_1_acesso_navegador = "http://54.123.45.67"
z_2_acesso_api_java  = "http://54.123.45.67:8080"
z_3_acesso_api_csharp  = "http://54.123.45.67:5000"
z_4_acesso_ssh       = "ssh -i hackaton-bryan.pem ubuntu@54.123.45.67"
```

Acesso:

Frontend: http://54.123.45.67

API Java: http://54.123.45.67:8080

API C#: http://54.123.45.67:5000

🐛 Debugging (Se algo der errado)
Se passaram 10 minutos e o site não abriu, você pode acessar a máquina para ver o que está acontecendo.

1. Acesso SSH
Use a chave hackaton-bryan.pem (que deve estar instalado na SUA máquina).

Bash

ssh -i "hackaton-bryan.pem" ubuntu@<IP_PUBLICO>
2. Verificar Logs de Instalação
Assim que entrar na máquina, rode este comando para ver o script de instalação rodando em tempo real:

Bash

# Vê o log do script user_data (Instalação e Build)
tail -f /var/log/cloud-init-output.log
Se o build acabou, verifique os containers:

Bash

sudo docker ps -a


Limpeza

Assim que a apresentação acabar ou o Cluster principal voltar a funcionar, destrua esta infraestrutura para não gerar custos (a t3.small não é free tier).

Vá no GitHub Actions.

Rode o Workflow de Destroy Emergency