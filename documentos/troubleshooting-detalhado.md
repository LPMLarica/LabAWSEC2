# 🔧 Troubleshooting Detalhado - AWS EC2

## Índice
1. [Problemas de Conexão SSH](#problemas-de-conexão-ssh)
2. [Problemas com Servidor Web](#problemas-com-servidor-web)
3. [Problemas de Performance](#problemas-de-performance)
4. [Problemas de Rede](#problemas-de-rede)
5. [Problemas de Armazenamento](#problemas-de-armazenamento)
6. [Problemas de Inicialização](#problemas-de-inicialização)
7. [Erros Comuns do AWS Console](#erros-comuns-do-aws-console)

---

## Problemas de Conexão SSH

### ❌ Erro: "Host key verification failed"

**Sintomas:**
```bash
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
Host key verification failed.
```

**Causa:**
A chave do host mudou (nova instância com mesmo IP, ou reinstalação)

**Solução:**
```bash
# Remover chave antiga do known_hosts
ssh-keygen -R X.X.X.X

# Ou editar manualmente
nano ~/.ssh/known_hosts
# Remover linha correspondente ao IP

# Conectar novamente
ssh -i chave.pem ec2-user@X.X.X.X
```

---

## Problemas com Servidor Web

### ❌ Erro: "This site can't be reached"

**Diagnóstico Completo:**

```bash
# 1. Verificar se Apache está rodando
sudo systemctl status httpd
# ou
sudo systemctl status apache2

# 2. Verificar se porta 80 está em uso
sudo netstat -tuln | grep :80
# ou
sudo ss -tuln | grep :80

# 3. Testar localmente na instância
curl localhost
curl 127.0.0.1

# 4. Verificar logs de erro
sudo tail -f /var/log/httpd/error_log
# ou
sudo tail -f /var/log/apache2/error.log
```

**Soluções por Cenário:**

**Cenário 1: Apache não está rodando**
```bash
# Iniciar Apache
sudo systemctl start httpd

# Verificar status
sudo systemctl status httpd

# Se falhar ao iniciar, verificar configuração
sudo apachectl configtest

# Ver erro específico
sudo journalctl -xe
```

**Cenário 2: Porta 80 bloqueada no Security Group**
```
AWS Console:
1. EC2 > Security Groups
2. Selecionar SG da instância
3. Inbound Rules > Edit
4. Adicionar: HTTP (80) | TCP | 0.0.0.0/0
```

**Cenário 3: Firewall local bloqueando**
```bash
# Para firewalld
sudo firewall-cmd --list-all
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --reload

# Para ufw
sudo ufw status
sudo ufw allow http
sudo ufw allow 80/tcp

# Para iptables
sudo iptables -L -n | grep 80
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
```

**Cenário 4: SELinux bloqueando**
```bash
# Verificar status SELinux
getenforce

# Ver contexto de segurança
ls -Z /var/www/html

# Configurar contexto correto
sudo chcon -R -t httpd_sys_content_t /var/www/html

# Ou desabilitar temporariamente (não recomendado)
sudo setenforce 0
```

---

### ❌ Erro: "403 Forbidden"

**Sintomas:**
```
Forbidden
You don't have permission to access this resource.
```

**Causas e Soluções:**

1. **Permissões de arquivo incorretas**
   ```bash
   # Verificar permissões atuais
   ls -la /var/www/html/
   
   # Corrigir permissões
   sudo chmod 755 /var/www/html
   sudo chmod 644 /var/www/html/index.html
   
   # Corrigir proprietário
   sudo chown -R apache:apache /var/www/html  # CentOS/RHEL
   sudo chown -R www-data:www-data /var/www/html  # Ubuntu/Debian
   ```

2. **Diretiva Directory incorreta**
   ```bash
   # Editar configuração Apache
   sudo nano /etc/httpd/conf/httpd.conf
   
   # Procurar e verificar:
   <Directory "/var/www/html">
       Options Indexes FollowSymLinks
       AllowOverride None
       Require all granted  # Deve ser "granted", não "denied"
   </Directory>
   
   # Reiniciar Apache
   sudo systemctl restart httpd
   ```

3. **Arquivo index.html não existe**
   ```bash
   # Verificar se existe
   ls -la /var/www/html/index.html
   
   # Criar arquivo básico
   echo "<h1>Teste</h1>" | sudo tee /var/www/html/index.html
   ```

---

### ❌ Erro: "500 Internal Server Error"

**Diagnóstico:**
```bash
# 1. Ver logs de erro em tempo real
sudo tail -f /var/log/httpd/error_log

# 2. Ver últimas 50 linhas de erro
sudo tail -50 /var/log/httpd/error_log

# 3. Filtrar erros críticos
sudo grep -i "error\|critical\|alert" /var/log/httpd/error_log
```

**Causas Comuns:**

1. **.htaccess com sintaxe incorreta**
2. **Módulos Apache faltando**
3. **Permissões de script PHP/Python incorretas**
4. **Limite de memória excedido**

**Solução Geral:**
```bash
# Testar configuração
sudo apachectl configtest

# Verificar módulos carregados
sudo httpd -M

# Desabilitar .htaccess temporariamente
sudo mv /var/www/html/.htaccess /var/www/html/.htaccess.bak

# Reiniciar com verbose
sudo systemctl restart httpd
sudo journalctl -u httpd -n 50
```

---

## Problemas de Performance

### ❌ Instância Lenta / Alto CPU Usage

**Monitoramento:**
```bash
# 1. Verificar CPU
top
htop  # se instalado

# Ver processos ordenados por CPU
ps aux --sort=-%cpu | head

# 2. Verificar memória
free -h
cat /proc/meminfo

# 3. Verificar disco I/O
iostat -x 1 10
iotop  # se instalado

# 4. Verificar rede
iftop  # se instalado
netstat -i
```

**Soluções:**

1. **CPU Alto - Apache**
   ```bash
   # Otimizar configuração MPM
   sudo nano /etc/httpd/conf.modules.d/00-mpm.conf
   
   # Ajustar valores
   <IfModule mpm_prefork_module>
       StartServers          5
       MinSpareServers       5
       MaxSpareServers       10
       MaxRequestWorkers     150
       MaxConnectionsPerChild 1000
   </IfModule>
   
   # Reiniciar
   sudo systemctl restart httpd
   ```

2. **Memória Insuficiente**
   ```bash
   # Criar swap file
   sudo dd if=/dev/zero of=/swapfile bs=1M count=2048
   sudo chmod 600 /swapfile
   sudo mkswap /swapfile
   sudo swapon /swapfile
   
   # Tornar permanente
   echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
   ```

3. **Disco Cheio**
   ```bash
   # Verificar uso de disco
   df -h
   
   # Encontrar arquivos grandes
   sudo du -h / | sort -rh | head -20
   
   # Limpar logs antigos
   sudo journalctl --vacuum-time=7d
   sudo rm -rf /var/log/*.gz
   
   # Limpar cache de pacotes
   sudo yum clean all  # CentOS/RHEL
   sudo apt clean      # Ubuntu/Debian
   ```

---

## Problemas de Rede

### ❌ Instância não consegue acessar Internet

**Diagnóstico:**
```bash
# 1. Testar conectividade básica
ping 8.8.8.8
ping google.com

# 2. Verificar DNS
nslookup google.com
dig google.com

# 3. Verificar rota padrão
ip route show
route -n

# 4. Verificar interface de rede
ip addr show
ifconfig
```

**Soluções:**

1. **Subnet sem Internet Gateway**
   ```
   AWS Console:
   1. VPC > Subnets
   2. Verificar Route Table associada
   3. Route Table deve ter: 0.0.0.0/0 -> igw-xxxxx
   ```

2. **DNS não configurado**
   ```bash
   # Verificar resolução DNS
   cat /etc/resolv.conf
   
   # Adicionar DNS público
   echo "nameserver 8.8.8.8" | sudo tee -a /etc/resolv.conf
   echo "nameserver 1.1.1.1" | sudo tee -a /etc/resolv.conf
   ```

3. **Network ACL bloqueando**
   ```
   VPC > Network ACLs:
   - Inbound: Permitir all traffic
   - Outbound: Permitir all traffic
   ```

---

## Problemas de Armazenamento

### ❌ Disco Cheio (No space left on device)

**Análise:**
```bash
# 1. Verificar uso geral
df -h

# 2. Encontrar diretórios grandes
sudo du -h --max-depth=1 / | sort -rh | head

# 3. Encontrar arquivos grandes
sudo find / -type f -size +100M -exec ls -lh {} \; 2>/dev/null

# 4. Verificar inodes
df -i
```

**Limpeza:**
```bash
# Logs do sistema
sudo journalctl --vacuum-size=100M
sudo find /var/log -type f -name "*.gz" -delete
sudo find /var/log -type f -name "*.old" -delete

# Cache de pacotes
sudo yum clean all
sudo apt clean

# Arquivos temporários
sudo rm -rf /tmp/*
sudo rm -rf /var/tmp/*

# Docker (se instalado)
docker system prune -a
```

**Expandir Volume EBS:**
```bash
# 1. No AWS Console:
#    EC2 > Volumes > Modify Volume > Aumentar tamanho

# 2. Na instância, crescer partição:
sudo growpart /dev/xvda 1

# 3. Expandir filesystem:
# Para ext4:
sudo resize2fs /dev/xvda1
# Para xfs:
sudo xfs_growfs -d /

# 4. Verificar
df -h
```

---

## Problemas de Inicialização

### ❌ Instância não passa nos Status Checks

**Status Check Failed: Instance**

**Causa:** Problema no SO ou configuração

**Solução:**
```bash
# 1. Ver System Log
AWS Console > EC2 > Instance > Actions > 
Instance Settings > Get System Log

# 2. Analisar User Data
Actions > Instance Settings > Edit User Data

# 3. Parar e Iniciar (não Reboot)
Actions > Instance State > Stop
Aguardar parar completamente
Actions > Instance State > Start
```

**Status Check Failed: System**

**Causa:** Problema no hardware/hypervisor AWS

**Solução:**
```bash
# Criar AMI da instância
Actions > Image > Create Image

# Lançar nova instância a partir da AMI
EC2 > AMIs > Launch Instance from AMI

# Ou simplesmente parar e iniciar novamente
# AWS irá realocar em novo hardware
```

---

## Erros Comuns do AWS Console

### ❌ "You are not authorized to perform this operation"

**Solução:**
```
1. Verificar permissões IAM do usuário
2. IAM > Users > Seu usuário > Permissions
3. Adicionar policy necessária:
   - AmazonEC2FullAccess (desenvolvimento)
   - Ou policy customizada
```

### ❌ "Instance limit exceeded"

**Solução:**
```
1. Service Quotas > EC2
2. Ver limite atual de instâncias
3. Solicitar aumento:
   - Request quota increase
   - Justificar necessidade
   - Aguardar aprovação (geralmente 24-48h)
```

### ❌ "Insufficient capacity"

**Solução:**
```
1. Tentar outra Availability Zone
2. Tentar tipo de instância diferente
3. Aguardar alguns minutos e tentar novamente
```

---

## 🛠️ Scripts de Diagnóstico Automatizado

### Script Completo de Health Check

```bash
#!/bin/bash
# health-check.sh - Diagnóstico completo da instância

echo "=== HEALTH CHECK EC2 ==="
echo ""

echo "1. INFORMAÇÕES DA INSTÂNCIA:"
curl -s http://169.254.169.254/latest/meta-data/instance-id
echo ""

echo "2. STATUS DE SERVIÇOS:"
systemctl is-active httpd || systemctl is-active apache2
systemctl is-active sshd

echo ""
echo "3. USO DE RECURSOS:"
echo "CPU:"
top -bn1 | grep "Cpu(s)" | awk '{print $2}' | awk -F'%' '{print $1}'
echo "Memória:"
free -h | grep Mem | awk '{print $3 "/" $2}'
echo "Disco:"
df -h / | tail -1 | awk '{print $3 "/" $2 " (" $5 " usado)"}'

echo ""
echo "4. CONECTIVIDADE:"
ping -c 3 8.8.8.8 > /dev/null 2>&1 && echo "Internet: OK" || echo "Internet: FALHA"

echo ""
echo "5. PORTAS ABERTAS:"
sudo netstat -tuln | grep LISTEN

echo ""
echo "=== FIM DO HEALTH CHECK ==="
```

---

## 📞 Quando Contactar o Suporte AWS

Entre em contato se:
- Status Check System falha persistentemente
- Performance degradada sem causa aparente
- Problemas de conectividade regional
- Limites de serviço precisam ser aumentados urgentemente

**Como abrir ticket:**
```
AWS Console > Support > Create Case
Selecione o tipo apropriado e forneça:
- Instance ID
- Região
- Logs relevantes
- Steps to reproduce
```

---

## 📚 Recursos Adicionais

- [AWS EC2 Troubleshooting](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-troubleshoot.html)
- [AWS Knowledge Center](https://aws.amazon.com/premiumsupport/knowledge-center/)
- [AWS re:Post](https://repost.aws/) - Fórum da comunidade

---

**Última atualização:** Outubro 2025  
**Mantenedor:** Laboratório DIO - AWS EC2Connection timed out"

**Sintomas:**
```bash
ssh: connect to host X.X.X.X port 22: Connection timed out
```

**Causas Possíveis:**

1. **Security Group não permite SSH**
   ```
   Solução:
   1. AWS Console > EC2 > Security Groups
   2. Selecionar o SG da instância
   3. Inbound Rules > Edit
   4. Adicionar regra: SSH (22) do seu IP
   ```

2. **IP Público mudou**
   ```bash
   # Verificar IP atual da instância
   aws ec2 describe-instances --instance-ids i-1234567890abcdef0 \
     --query 'Reservations[0].Instances[0].PublicIpAddress'
   ```

3. **Instância não está rodando**
   ```
   Verificar: AWS Console > EC2 > Instances
   Estado deve ser: "running"
   Status Checks: 2/2 checks passed
   ```

4. **Network ACL bloqueando tráfego**
   ```
   Verificar: VPC > Network ACLs
   Certifique-se que há regras ALLOW para porta 22
   ```

**Solução Passo a Passo:**

```bash
# 1. Verificar conectividade básica
ping X.X.X.X

# 2. Verificar se porta SSH está aberta
telnet X.X.X.X 22
# ou
nc -zv X.X.X.X 22

# 3. Verificar rota e traceroute
traceroute X.X.X.X

# 4. Testar com verbose mode
ssh -vvv -i chave.pem ec2-user@X.X.X.X
```

---

### ❌ Erro: "Permission denied (publickey)"

**Sintomas:**
```bash
Permission denied (publickey,gssapi-keyex,gssapi-with-mic)
```

**Causas e Soluções:**

1. **Permissões incorretas da chave**
   ```bash
   # Problema
   ls -la chave.pem
   # Output: -rw-r--r-- (incorreto)
   
   # Solução
   chmod 400 chave.pem
   ls -la chave.pem
   # Output: -r-------- (correto)
   ```

2. **Usuário incorreto**
   ```bash
   # Amazon Linux / Amazon Linux 2
   ssh -i chave.pem ec2-user@X.X.X.X
   
   # Ubuntu
   ssh -i chave.pem ubuntu@X.X.X.X
   
   # CentOS
   ssh -i chave.pem centos@X.X.X.X
   
   # RHEL
   ssh -i chave.pem ec2-user@X.X.X.X
   
   # Debian
   ssh -i chave.pem admin@X.X.X.X
   ```

3. **Chave pública não corresponde**
   ```bash
   # Verificar fingerprint da chave
   ssh-keygen -lf chave.pem
   
   # Comparar com AWS Console
   EC2 > Key Pairs > Selecionar a chave > Verificar fingerprint
   ```

4. **Arquivo de chave corrompido**
   ```bash
   # Verificar formato da chave
   head -1 chave.pem
   # Deve mostrar: -----BEGIN RSA PRIVATE KEY-----
   
   # Se corrompido, restaurar do backup ou criar nova instância
   ```

---
