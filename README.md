# 🚀 Laboratório AWS EC2 - Gerenciamento de Instâncias

## 📋 Sobre o Projeto

Este repositório documenta minha jornada de aprendizado no gerenciamento de instâncias EC2 (Elastic Compute Cloud) na AWS, desenvolvido como parte do bootcamp na DIO (Digital Innovation One).

## 🎯 Objetivos Alcançados

- ✅ Compreender a arquitetura do Amazon EC2
- ✅ Criar e configurar instâncias EC2
- ✅ Gerenciar grupos de segurança e networking
- ✅ Implementar boas práticas de segurança
- ✅ Documentar processos técnicos de forma estruturada

## 📚 Índice

1. [Conceitos Fundamentais](#conceitos-fundamentais)
2. [Passo a Passo da Implementação](#passo-a-passo-da-implementação)
3. [Configurações Realizadas](#configurações-realizadas)
4. [Grupos de Segurança](#grupos-de-segurança)
5. [Melhores Práticas](#melhores-práticas)
6. [Troubleshooting](#troubleshooting)
7. [Recursos Adicionais](#recursos-adicionais)

## 🔍 Conceitos Fundamentais

### O que é Amazon EC2?

Amazon Elastic Compute Cloud (EC2) é um serviço web que fornece capacidade computacional redimensionável na nuvem. Ele foi projetado para facilitar a computação em nuvem em escala web para desenvolvedores.

### Principais Características

- **Elasticidade**: Escalabilidade automática conforme demanda
- **Controle Total**: Acesso root completo às instâncias
- **Flexibilidade**: Múltiplas opções de sistema operacional e configuração
- **Integração**: Funciona perfeitamente com outros serviços AWS
- **Segurança**: Grupos de segurança e VPC para isolamento de rede

### Tipos de Instâncias

| Família | Uso Ideal | Exemplo |
|---------|-----------|---------|
| **t3/t2** | Uso geral, burst performance | Desenvolvimento, testes |
| **m5/m6** | Balanceado (CPU/memória) | Aplicações web, bancos de dados |
| **c5/c6** | Otimizado para computação | Processamento batch, gaming |
| **r5/r6** | Otimizado para memória | Cache, banco de dados em memória |
| **p3/p4** | GPU (Machine Learning) | IA, renderização 3D |

## 🛠️ Passo a Passo da Implementação

### 1. Preparação do Ambiente

**Pré-requisitos:**
- Conta AWS ativa (free tier disponível)
- Conhecimento básico de Linux/Windows
- Console AWS configurado

### 2. Criando a Primeira Instância EC2

#### 2.1 Acessar o Console EC2

```
AWS Console > Services > EC2 > Launch Instance
```

#### 2.2 Configurações Básicas

**Nome da Instância:**
```
meu-servidor-web-01
```

**Escolha da AMI (Amazon Machine Image):**
- Amazon Linux 2023 (recomendado para beginners)
- Ubuntu Server 22.04 LTS
- Windows Server 2022

#### 2.3 Seleção do Tipo de Instância

Para aprendizado, utilizei:
```
Tipo: t2.micro (elegível para free tier)
vCPUs: 1
Memória: 1 GB
```

#### 2.4 Configuração de Par de Chaves (Key Pair)

```bash
# Criar novo par de chaves
Nome: minha-chave-ec2
Tipo: RSA
Formato: .pem (Linux/Mac) ou .ppk (Windows/PuTTY)
```

⚠️ **IMPORTANTE**: Salve o arquivo .pem em local seguro! Não é possível recuperá-lo depois.

#### 2.5 Configurações de Rede

```
VPC: Default VPC
Subnet: Default
Auto-assign Public IP: Enable
```

### 3. Configuração de Grupos de Segurança

#### Security Group Criado

```
Nome: web-server-sg
Descrição: Security group para servidor web
```

#### Regras de Entrada (Inbound Rules)

| Tipo | Protocolo | Porta | Origem | Descrição |
|------|-----------|-------|--------|-----------|
| SSH | TCP | 22 | Meu IP | Acesso administrativo |
| HTTP | TCP | 80 | 0.0.0.0/0 | Tráfego web |
| HTTPS | TCP | 443 | 0.0.0.0/0 | Tráfego web seguro |

#### Regras de Saída (Outbound Rules)

```
All traffic: 0.0.0.0/0 (padrão)
```

### 4. Configuração de Armazenamento

```
Volume Type: gp3 (SSD de uso geral)
Size: 8 GB (free tier)
Delete on Termination: Yes
Encryption: Enabled (recomendado)
```

### 5. Lançamento da Instância

```bash
# Resumo da configuração
Instância: t2.micro
SO: Amazon Linux 2023
Storage: 8GB gp3
Security: web-server-sg
Key Pair: minha-chave-ec2
```

## 🔐 Conectando à Instância

### Via SSH (Linux/Mac)

```bash
# Ajustar permissões da chave
chmod 400 minha-chave-ec2.pem

# Conectar à instância
ssh -i "minha-chave-ec2.pem" ec2-user@<PUBLIC_IP>

# Exemplo:
ssh -i "minha-chave-ec2.pem" ec2-user@54.123.45.67
```

### Via PuTTY (Windows)

1. Converter .pem para .ppk usando PuTTYgen
2. Configurar host: `ec2-user@<PUBLIC_IP>`
3. Auth > Credentials > carregar arquivo .ppk
4. Conectar

### Via EC2 Instance Connect (Browser)

```
EC2 Console > Instances > Select Instance > Connect > EC2 Instance Connect
```

## ⚙️ Configurações Realizadas

### Instalação de Servidor Web (Apache)

```bash
# Atualizar sistema
sudo yum update -y

# Instalar Apache
sudo yum install httpd -y

# Iniciar serviço
sudo systemctl start httpd

# Habilitar inicialização automática
sudo systemctl enable httpd

# Verificar status
sudo systemctl status httpd
```

### Criação de Página Web de Teste

```bash
# Criar arquivo HTML
sudo nano /var/www/html/index.html
```

```html
<!DOCTYPE html>
<html>
<head>
    <title>Minha Instância EC2</title>
</head>
<body>
    <h1>Servidor EC2 Funcionando!</h1>
    <p>Laboratório DIO - AWS EC2</p>
</body>
</html>
```

### Teste de Conectividade

```bash
# Testar localmente
curl localhost

# Acessar via navegador
http://<PUBLIC_IP>
```

## 📊 Monitoramento

### CloudWatch Metrics

Métricas monitoradas automaticamente:
- CPU Utilization
- Network In/Out
- Disk Read/Write Operations
- Status Check (System/Instance)

### Configurar Alarmes

```
CloudWatch > Alarms > Create Alarm
Métrica: CPUUtilization
Condição: > 80%
Ação: Enviar notificação SNS
```

## 💰 Gerenciamento de Custos

### Free Tier Limits

```
750 horas/mês de instâncias t2.micro
30 GB de armazenamento EBS
2 milhões de requisições de E/S
```

### Dicas de Economia

1. **Stop vs Terminate**: Pare instâncias quando não estiver usando
2. **Reserved Instances**: Para workloads previsíveis (economia de até 75%)
3. **Spot Instances**: Para workloads flexíveis (economia de até 90%)
4. **Right-sizing**: Use o tipo de instância adequado

## 🛡️ Melhores Práticas

### Segurança

1. **Nunca expor chaves privadas publicamente**
2. **Usar IAM roles ao invés de credenciais hardcoded**
3. **Restringir acesso SSH ao seu IP específico**
4. **Manter sistema operacional atualizado**
5. **Habilitar CloudTrail para auditoria**

### Backup e Recuperação

```bash
# Criar snapshot do volume EBS
AWS Console > EC2 > Volumes > Actions > Create Snapshot

# Criar AMI da instância
AWS Console > EC2 > Instances > Actions > Image > Create Image
```

### Tags e Organização

```
Name: web-server-prod-01
Environment: Production
Project: DIO-Lab
Owner: seu-nome
CostCenter: Learning
```

## 🔧 Troubleshooting

### Problema: Não Consigo Conectar via SSH

**Soluções:**

1. Verificar Security Group permite SSH (porta 22)
2. Verificar permissões da chave: `chmod 400 chave.pem`
3. Verificar se usou o usuário correto (ec2-user, ubuntu, admin)
4. Verificar se instância está em estado "running"
5. Verificar se tem IP público atribuído

### Problema: Site Não Carrega

**Soluções:**

1. Verificar Security Group permite HTTP (porta 80)
2. Verificar se Apache está rodando: `systemctl status httpd`
3. Verificar firewall local: `sudo iptables -L`
4. Testar conectividade local: `curl localhost`

### Problema: Instância Não Inicia

**Soluções:**

1. Verificar Status Checks no console
2. Ver System Log no console
3. Verificar se atingiu limites do free tier
4. Criar nova instância a partir de snapshot

## 📈 Próximos Passos

- [ ] Implementar Auto Scaling
- [ ] Configurar Load Balancer
- [ ] Integrar com RDS
- [ ] Implementar CI/CD
- [ ] Explorar containers com ECS
- [ ] Estudar Lambda para serverless

## 📚 Recursos Adicionais

### Documentação Oficial

- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)
- [AWS Free Tier](https://aws.amazon.com/free/)
- [EC2 Best Practices](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-best-practices.html)

### Cursos e Tutoriais

- [AWS Skill Builder](https://skillbuilder.aws/)
- [AWS re:Invent Videos](https://www.youtube.com/user/AmazonWebServices)
- [AWS Workshops](https://workshops.aws/)

### Ferramentas Úteis

- [AWS CLI](https://aws.amazon.com/cli/) - Interface de linha de comando
- [AWS Systems Manager](https://aws.amazon.com/systems-manager/) - Gerenciamento unificado
- [Terraform](https://www.terraform.io/) - Infrastructure as Code

## 🤝 Contribuições

Este é um projeto de aprendizado pessoal, mas sugestões são bem-vindas! Sinta-se à vontade para:

- Abrir issues com dúvidas
- Sugerir melhorias na documentação
- Compartilhar suas próprias experiências

## 📝 Licença

Este projeto está sob a licença MIT. Sinta-se livre para usar este material para seus estudos.

## ✍️ Autor

**Seu Nome**
- LinkedIn: [Larissa-Campos](https://www.linkedin.com/in/larissa-campos-a70284239)
- GitHub: [@LPMLarica](https://github.com/LPMLarica)
- DIO: [Larissa Cardoso](https://web.dio.me/users/larissacamposcardoso)

---

⭐ Se este repositório foi útil para você, considere dar uma estrela!

**Desenvolvido com dedicação durante o Bootcamp DIO** 🚀