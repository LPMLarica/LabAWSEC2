# Comandos Úteis - EC2

Referência rápida de comandos essenciais para gerenciamento e manutenção de instâncias EC2.

---

## Índice
1. [Informações da Instância](#informações-da-instância)
2. [Gerenciamento de Serviços](#gerenciamento-de-serviços)
3. [Monitoramento de Recursos](#monitoramento-de-recursos)
4. [Rede e Conectividade](#rede-e-conectividade)
5. [Firewall e Segurança](#firewall-e-segurança)
6. [Gerenciamento de Arquivos](#gerenciamento-de-arquivos)
7. [Logs e Diagnóstico](#logs-e-diagnóstico)
8. [Backup e Recuperação](#backup-e-recuperação)
9. [AWS CLI](#aws-cli)
10. [Otimização e Performance](#otimização-e-performance)

---

## Informações da Instância

### Metadata da Instância EC2
```bash
# Instance ID
curl http://169.254.169.254/latest/meta-data/instance-id

# IP Público
curl http://169.254.169.254/latest/meta-data/public-ipv4

# IP Privado
curl http://169.254.169.254/latest/meta-data/local-ipv4

# Availability Zone
curl http://169.254.169.254/latest/meta-data/placement/availability-zone

# Instance Type
curl http://169.254.169.254/latest/meta-data/instance-type

# Security Groups
curl http://169.254.169.254/latest/meta-data/security-groups

# IAM Role
curl http://169.254.169.254/latest/meta-data/iam/security-credentials/

# Todas as metadata disponíveis
curl http://169.254.169.254/latest/meta-data/
```

### Informações do Sistema
```bash
# Versão do OS
cat /etc/os-release
uname -a

# Hostname
hostname
hostnamectl

# Uptime
uptime
who -b  # Último boot

# Usuários logados
who
w

# Informações de CPU
lscpu
cat /proc/cpuinfo

# Informações de Memória
free -h
cat /proc/meminfo

# Informações de Disco
lsblk
fdisk -l
df -h
```

---

## Gerenciamento de Serviços

### SystemD (Sistemas Modernos)
```bash
# Ver status de um serviço
sudo systemctl status httpd
sudo systemctl status apache2
sudo systemctl status sshd

# Iniciar serviço
sudo systemctl start httpd

# Parar serviço
sudo systemctl stop httpd

# Reiniciar serviço
sudo systemctl restart httpd

# Recarregar configuração (sem downtime)
sudo systemctl reload httpd

# Habilitar serviço no boot
sudo systemctl enable httpd

# Desabilitar serviço no boot
sudo systemctl disable httpd

# Verificar se serviço está habilitado
sudo systemctl is-enabled httpd

# Verificar se serviço está ativo
sudo systemctl is-active httpd

# Listar todos os serviços
sudo systemctl list-units --type=service

# Listar serviços em execução
sudo systemctl list-units --type=service --state=running

# Ver logs de um serviço
sudo journalctl -u httpd

# Ver logs em tempo real
sudo journalctl -u httpd -f

# Ver últimas 50 linhas
sudo journalctl -u httpd -n 50
```

### Apache/HTTPD
```bash
# Testar configuração
sudo apachectl configtest
sudo httpd -t

# Ver módulos carregados
sudo httpd -M
sudo apachectl -M

# Ver virtual hosts configurados
sudo apachectl -S

# Versão do Apache
httpd -v
```

---

## Monitoramento de Recursos

### CPU
```bash
# Monitor interativo
top
htop  # Requer instalação

# Processos ordenados por CPU
ps aux --sort=-%cpu | head

# Uso de CPU em tempo real
mpstat 1 10  # Requer sysstat

# Carga do sistema
uptime
cat /proc/loadavg

# Por core
top -H
```

### Memória
```bash
# Resumo de memória
free -h
free -m

# Detalhado
cat /proc/meminfo
vmstat 1 10

# Processos ordenados por memória
ps aux --sort=-%mem | head

# Verificar swap
swapon --show
cat /proc/swaps

# Cache e buffers
sync; echo 3 > /proc/sys/vm/drop_caches  # Limpar cache
```

### Disco
```bash
# Uso de disco por filesystem
df -h
df -i  # Inodes

# Uso por diretório
du -h --max-depth=1 /
du -sh /*

# Arquivos grandes (>100MB)
sudo find / -type f -size +100M -exec ls -lh {} \;

# I/O de disco
iostat -x 1 10  # Requer sysstat
iotop  # Requer iotop

# Monitor de I/O em tempo real
watch -n 1 iostat

# Detalhes de volumes
lsblk -f
blkid
```

### Processos
```bash
# Listar todos os processos
ps aux
ps -ef

# Árvore de processos
pstree
ps auxf

# Informações de processo específico
ps -p PID -o %cpu,%mem,cmd

# Matar processo
kill PID
kill -9 PID  # Force kill
killall nome_processo

# Processos zumbis
ps aux | grep Z

# Top 10 processos por CPU
ps aux --sort=-%cpu | head -10

# Top 10 processos por memória
ps aux --sort=-%mem | head -10
```

---

## Rede e Conectividade

### Interfaces e Configuração
```bash
# Listar interfaces
ip addr show
ip link show
ifconfig  # Deprecated

# Informações de interface específica
ip addr show eth0

# Estatísticas de interface
ip -s link show eth0
netstat -i
ifconfig eth0

# Configuração de DNS
cat /etc/resolv.conf

# Hostname
hostname
cat /etc/hostname

# Hosts
cat /etc/hosts
```

### Conectividade
```bash
# Ping
ping -c 4 google.com
ping 8.8.8.8

# Traceroute
traceroute google.com
tracepath google.com

# DNS lookup
nslookup google.com
dig google.com
host google.com

# Testar porta específica
telnet IP PORTA
nc -zv IP PORTA  # NetCat

# Testar múltiplas portas
nmap -p 22,80,443 IP  # Requer nmap

# Conexões ativas
netstat -tupln
ss -tupln  # Mais moderno

# Conexões estabelecidas
netstat -an | grep ESTABLISHED
ss -tan | grep ESTAB

# Portas em LISTEN
netstat -tlnp
ss -tlnp

# Tráfego em tempo real
iftop  # Requer instalação
nethogs  # Requer instalação
```

### Requisições HTTP
```bash
# GET request
curl http://example.com
curl -I http://example.com  # Headers apenas

# Seguir redirects
curl -L http://example.com

# Salvar em arquivo
curl -o arquivo.html http://example.com

# Com headers customizados
curl -H "User-Agent: Custom" http://example.com

# POST request
curl -X POST -d "param=value" http://example.com

# Download de arquivo
wget http://example.com/file.zip
wget -c http://example.com/file.zip  # Continuar download

# Testar velocidade
curl -o /dev/null -s -w '%{time_total}\n' http://example.com
```

### Rotas
```bash
# Ver tabela de rotas
ip route show
route -n

# Adicionar rota
sudo ip route add 192.168.1.0/24 via 10.0.0.1

# Remover rota
sudo ip route del 192.168.1.0/24

# Gateway padrão
ip route show default
route -n | grep '^0.0.0.0'
```

---

## Firewall e Segurança

### Firewalld (CentOS/RHEL/Amazon Linux 2)
```bash
# Status
sudo firewall-cmd --state

# Listar todas as regras
sudo firewall-cmd --list-all

# Zona ativa
sudo firewall-cmd --get-active-zones

# Adicionar serviço
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload

# Adicionar porta
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --reload

# Remover porta
sudo firewall-cmd --permanent --remove-port=8080/tcp
sudo firewall-cmd --reload

# Listar serviços disponíveis
sudo firewall-cmd --get-services

# Rich rules
sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="1.2.3.4" accept'
```

### UFW (Ubuntu/Debian)
```bash
# Status
sudo ufw status
sudo ufw status verbose

# Habilitar/Desabilitar
sudo ufw enable
sudo ufw disable

# Permitir serviço
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https

# Permitir porta
sudo ufw allow 8080/tcp
sudo ufw allow 53/udp

# Permitir de IP específico
sudo ufw allow from 1.2.3.4

# Negar
sudo ufw deny 23/tcp

# Deletar regra
sudo ufw delete allow 8080/tcp

# Resetar regras
sudo ufw reset

# Listar regras numeradas
sudo ufw status numbered

# Deletar por número
sudo ufw delete 2

# Rate limiting (proteção brute force)
sudo ufw limit ssh
```

### Iptables
```bash
# Listar regras
sudo iptables -L -n -v

# Listar com números de linha
sudo iptables -L --line-numbers

# Salvar regras
sudo iptables-save > /tmp/iptables-backup.txt

# Restaurar regras
sudo iptables-restore < /tmp/iptables-backup.txt

# Permitir porta
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT

# Bloquear IP
sudo iptables -A INPUT -s 1.2.3.4 -j DROP

# Deletar regra por número
sudo iptables -D INPUT 5

# Flush all rules
sudo iptables -F

# Políticas padrão
sudo iptables -P INPUT DROP
sudo iptables -P FORWARD DROP
sudo iptables -P OUTPUT ACCEPT
```

### SELinux (CentOS/RHEL)
```bash
# Status
getenforce
sestatus

# Desabilitar temporariamente
sudo setenforce 0

# Habilitar
sudo setenforce 1

# Ver contexto de arquivo
ls -Z /var/www/html

# Alterar contexto
sudo chcon -t httpd_sys_content_t /var/www/html/index.html

# Restaurar contextos padrão
sudo restorecon -Rv /var/www/html

# Ver booleans
getsebool -a | grep httpd

# Alterar boolean
sudo setsebool -P httpd_can_network_connect on
```

---

## Gerenciamento de Arquivos

### Navegação e Listagem
```bash
# Listar arquivos
ls -la
ls -lh  # Human readable
ls -ltr  # Ordenar por tempo, mais recente último

# Árvore de diretórios
tree
tree -L 2  # Limitar profundidade

# Encontrar arquivos
find /var/www -name "*.html"
find / -type f -size +100M
find / -mtime -7  # Modificados últimos 7 dias

# Localizar (mais rápido)
locate index.html
sudo updatedb  # Atualizar database

# Qual comando
which httpd
whereis httpd
```

### Manipulação
```bash
# Copiar
cp arquivo.txt destino/
cp -r diretorio/ destino/  # Recursivo
cp -p arquivo.txt destino/  # Preservar atributos

# Mover/Renomear
mv arquivo.txt novo_nome.txt
mv arquivo.txt /novo/caminho/

# Remover
rm arquivo.txt
rm -rf diretorio/  # Recursivo e forçado
rm -i arquivo.txt  # Confirmar

# Criar diretório
mkdir novo_dir
mkdir -p /path/to/nested/dir  # Criar pais

# Links
ln -s /caminho/original link_simbolico
ln /caminho/original hard_link
```

### Permissões
```bash
# Ver permissões
ls -l arquivo.txt

# Alterar permissões
chmod 644 arquivo.txt
chmod 755 script.sh
chmod +x script.sh
chmod -R 755 diretorio/

# Alterar dono
chown usuario arquivo.txt
chown usuario:grupo arquivo.txt
chown -R usuario:grupo diretorio/

# SUID, SGID, Sticky bit
chmod 4755 arquivo  # SUID
chmod 2755 arquivo  # SGID
chmod 1777 /tmp     # Sticky bit
```

### Visualização
```bash
# Ver arquivo completo
cat arquivo.txt
less arquivo.txt
more arquivo.txt

# Primeiras/Últimas linhas
head arquivo.txt
head -n 20 arquivo.txt
tail arquivo.txt
tail -n 50 arquivo.txt

# Seguir arquivo em tempo real
tail -f /var/log/httpd/access_log

# Buscar dentro de arquivo
grep "erro" arquivo.log
grep -i "erro" arquivo.log  # Case insensitive
grep -r "erro" /var/log/  # Recursivo
grep -n "erro" arquivo.log  # Com números de linha

# Contar linhas
wc -l arquivo.txt
```

### Edição
```bash
# Nano (mais fácil)
nano arquivo.txt
# Ctrl+O: Salvar, Ctrl+X: Sair

# Vim
vim arquivo.txt
# i: Insert mode, Esc: Normal mode
# :w: Salvar, :q: Sair, :wq: Salvar e sair

# Substituir texto
sed 's/antigo/novo/g' arquivo.txt
sed -i 's/antigo/novo/g' arquivo.txt  # In-place

# Adicionar linha no final
echo "nova linha" >> arquivo.txt

# Sobrescrever arquivo
echo "conteúdo" > arquivo.txt
```

---

## Logs e Diagnóstico

### System Logs (Journald)
```bash
# Ver todos os logs
sudo journalctl

# Logs de serviço específico
sudo journalctl -u httpd
sudo journalctl -u sshd

# Seguir logs em tempo real
sudo journalctl -f
sudo journalctl -u httpd -f

# Logs desde boot
sudo journalctl -b

# Logs de hoje
sudo journalctl --since today

# Logs entre datas
sudo journalctl --since "2025-01-01" --until "2025-01-31"
sudo journalctl --since "1 hour ago"
sudo journalctl --since "30 min ago"

# Últimas N linhas
sudo journalctl -n 100

# Filtrar por prioridade
sudo journalctl -p err  # Erros
sudo journalctl -p warning  # Avisos

# Limpar logs antigos
sudo journalctl --vacuum-time=7d  # Manter 7 dias
sudo journalctl --vacuum-size=100M  # Manter 100MB

# Ver tamanho dos logs
sudo journalctl --disk-usage
```

### Traditional Logs
```bash
# Logs principais
sudo tail -f /var/log/messages  # Sistema geral
sudo tail -f /var/log/syslog    # Ubuntu/Debian
sudo tail -f /var/log/secure    # Autenticação
sudo tail -f /var/log/auth.log  # Ubuntu/Debian

# Apache/HTTPD
sudo tail -f /var/log/httpd/access_log
sudo tail -f /var/log/httpd/error_log
sudo tail -f /var/log/apache2/access.log  # Ubuntu
sudo tail -f /var/log/apache2/error.log   # Ubuntu

# Filtrar logs
sudo grep "ERROR" /var/log/httpd/error_log
sudo grep -i "failed" /var/log/secure

# Logs de boot
sudo dmesg
sudo dmesg | grep -i error

# Últimos logins
last
last -n 20
lastlog
```

### Análise de Logs
```bash
# Top IPs acessando (Apache)
sudo awk '{print $1}' /var/log/httpd/access_log | sort | uniq -c | sort -rn | head -10

# Requisições por hora
sudo awk '{print $4}' /var/log/httpd/access_log | cut -c 14-15 | sort -n | uniq -c

# Status codes
sudo awk '{print $9}' /var/log/httpd/access_log | sort | uniq -c | sort -rn

# URLs mais acessadas
sudo awk '{print $7}' /var/log/httpd/access_log | sort | uniq -c | sort -rn | head -20

# User agents
sudo awk -F'"' '{print $6}' /var/log/httpd/access_log | sort | uniq -c | sort -rn | head

# Falhas de login SSH
sudo grep "Failed password" /var/log/secure | awk '{print $11}' | sort | uniq -c | sort -rn
```

---

## Backup e Recuperação

### Backup de Arquivos
```bash
# Tar (arquivo compactado)
tar -czf backup.tar.gz /var/www/html
tar -cjf backup.tar.bz2 /var/www/html  # Melhor compressão

# Extrair
tar -xzf backup.tar.gz
tar -xjf backup.tar.bz2

# Ver conteúdo
tar -tzf backup.tar.gz
tar -tjf backup.tar.bz2

# Backup com timestamp
tar -czf backup-$(date +%Y%m%d-%H%M%S).tar.gz /var/www/html

# Rsync (sync/backup incremental)
rsync -avz /var/www/html/ /backup/html/
rsync -avz --delete /var/www/html/ /backup/html/  # Deletar extras

# Rsync remoto
rsync -avz -e ssh /var/www/html/ user@remote:/backup/

# Backup de banco de dados MySQL
mysqldump -u root -p database_name > backup.sql
mysqldump -u root -p --all-databases > all_databases.sql

# Restaurar MySQL
mysql -u root -p database_name < backup.sql
```

### Snapshots EBS
```bash
# Criar snapshot via AWS CLI
aws ec2 create-snapshot \
  --volume-id vol-1234567890abcdef0 \
  --description "Backup Manual $(date +%Y-%m-%d)"

# Listar snapshots
aws ec2 describe-snapshots --owner-ids self

# Criar volume de snapshot
aws ec2 create-volume \
  --snapshot-id snap-1234567890abcdef0 \
  --availability-zone us-east-1a
```

### AMI (Amazon Machine Image)
```bash
# Criar AMI via CLI
aws ec2 create-image \
  --instance-id i-1234567890abcdef0 \
  --name "MyServer-$(date +%Y%m%d)" \
  --description "Backup completo da instância"

# Listar AMIs
aws ec2 describe-images --owners self

# Lançar instância de AMI
aws ec2 run-instances \
  --image-id ami-1234567890abcdef0 \
  --instance-type t2.micro \
  --key-name minha-chave
```

---

## AWS CLI

### Configuração
```bash
# Instalar AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Configurar credenciais
aws configure
# AWS Access Key ID: [sua_chave]
# AWS Secret Access Key: [sua_secret]
# Default region: us-east-1
# Default output format: json

# Verificar configuração
aws sts get-caller-identity
```

### EC2 Commands
```bash
# Listar instâncias
aws ec2 describe-instances

# Listar apenas IDs e nomes
aws ec2 describe-instances \
  --query 'Reservations[*].Instances[*].[InstanceId,Tags[?Key==`Name`].Value|[0]]' \
  --output table

# Instância específica
aws ec2 describe-instances --instance-ids i-1234567890abcdef0

# Iniciar instância
aws ec2 start-instances --instance-ids i-1234567890abcdef0

# Parar instância
aws ec2 stop-instances --instance-ids i-1234567890abcdef0

# Reiniciar instância
aws ec2 reboot-instances --instance-ids i-1234567890abcdef0

# Terminar instância
aws ec2 terminate-instances --instance-ids i-1234567890abcdef0

# Security Groups
aws ec2 describe-security-groups
aws ec2 describe-security-groups --group-ids sg-1234567890abcdef0

# Adicionar regra inbound
aws ec2 authorize-security-group-ingress \
  --group-id sg-1234567890abcdef0 \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0

# Remover regra inbound
aws ec2 revoke-security-group-ingress \
  --group-id sg-1234567890abcdef0 \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0

# Listar volumes EBS
aws ec2 describe-volumes

# Criar snapshot
aws ec2 create-snapshot --volume-id vol-1234567890abcdef0

# Listar AMIs
aws ec2 describe-images --owners self

# Tags
aws ec2 create-tags \
  --resources i-1234567890abcdef0 \
  --tags Key=Environment,Value=Production
```

### CloudWatch
```bash
# Métricas de instância
aws cloudwatch get-metric-statistics \
  --namespace AWS/EC2 \
  --metric-name CPUUtilization \
  --dimensions Name=InstanceId,Value=i-1234567890abcdef0 \
  --start-time 2025-01-01T00:00:00Z \
  --end-time 2025-01-01T23:59:59Z \
  --period 3600 \
  --statistics Average

# Criar alarme
aws cloudwatch put-metric-alarm \
  --alarm-name cpu-mon \
  --alarm-description "Alarme quando CPU > 80%" \
  --metric-name CPUUtilization \
  --namespace AWS/EC2 \
  --statistic Average \
  --period 300 \
  --threshold 80 \
  --comparison-operator GreaterThanThreshold \
  --dimensions Name=InstanceId,Value=i-1234567890abcdef0

# Listar alarmes
aws cloudwatch describe-alarms
```

---

## Otimização e Performance

### Análise de Performance
```bash
# Performance geral
sudo yum install sysstat -y  # CentOS/RHEL
sudo apt install sysstat -y  # Ubuntu

# Estatísticas CPU
mpstat 1 10
sar -u 1 10

# Estatísticas de memória
vmstat 1 10
sar -r 1 10

# Estatísticas de disco I/O
iostat -x 1 10
sar -d 1 10

# Network statistics
sar -n DEV 1 10

# Relatório completo
sar -A
```

### Otimização Apache
```bash
# Ver configuração atual
apachectl -V
httpd -V

# Benchmark
ab -n 1000 -c 10 http://localhost/
# -n: Total de requests
# -c: Concurrent requests

# Otimizar configuração MPM
sudo nano /etc/httpd/conf.modules.d/00-mpm.conf

# Habilitar compressão
sudo nano /etc/httpd/conf.d/deflate.conf
```

### Cache e Performance
```bash
# Limpar cache de memória
sync
echo 3 > /proc/sys/vm/drop_caches

# Limpar cache de pacotes
sudo yum clean all
sudo apt clean

# Verificar serviços desnecessários
systemctl list-unit-files --type=service --state=enabled

# Desabilitar serviço não usado
sudo systemctl disable nome_servico
```

### Tunning de Rede
```bash
# Ver configurações de rede
sysctl -a | grep net

# Aumentar buffers TCP
sudo sysctl -w net.core.rmem_max=16777216
sudo sysctl -w net.core.wmem_max=16777216
sudo sysctl -w net.ipv4.tcp_rmem='4096 87380 16777216'
sudo sysctl -w net.ipv4.tcp_wmem='4096 65536 16777216'

# Tornar permanente
sudo nano /etc/sysctl.conf
# Adicionar as linhas acima
sudo sysctl -p
```

### Monitoramento Contínuo
```bash
# Script de monitoramento
#!/bin/bash
while true; do
    clear
    echo "=== MONITOR DE RECURSOS ==="
    echo ""
    echo "CPU:"
    top -bn1 | grep "Cpu(s)"
    echo ""
    echo "Memória:"
    free -h | grep Mem
    echo ""
    echo "Disco:"
    df -h / | tail -1
    echo ""
    echo "Conexões Apache:"
    netstat -an | grep :80 | wc -l
    sleep 5
done
```

---

## Gerenciamento de Pacotes

### YUM/DNF (Amazon Linux, CentOS, RHEL)
```bash
# Atualizar lista de pacotes
sudo yum update
sudo yum check-update

# Instalar pacote
sudo yum install httpd
sudo yum install -y httpd  # Sim para tudo

# Remover pacote
sudo yum remove httpd

# Procurar pacote
yum search apache
yum list available | grep http

# Informações de pacote
yum info httpd

# Listar pacotes instalados
yum list installed
rpm -qa

# Limpar cache
sudo yum clean all

# Ver histórico
yum history
yum history info 5

# Instalar pacote local
sudo yum localinstall pacote.rpm
sudo rpm -ivh pacote.rpm
```

### APT (Ubuntu, Debian)
```bash
# Atualizar lista de pacotes
sudo apt update

# Atualizar pacotes
sudo apt upgrade
sudo apt full-upgrade

# Instalar pacote
sudo apt install apache2
sudo apt install -y apache2

# Remover pacote
sudo apt remove apache2
sudo apt purge apache2  # Remove config também

# Procurar pacote
apt search apache
apt-cache search apache

# Informações de pacote
apt show apache2

# Listar pacotes instalados
apt list --installed
dpkg -l

# Limpar cache
sudo apt clean
sudo apt autoclean
sudo apt autoremove

# Instalar pacote local
sudo dpkg -i pacote.deb
sudo apt install -f  # Resolver dependências
```

---

## Automação e Cron

### Crontab
```bash
# Editar crontab do usuário
crontab -e

# Listar crontab
crontab -l

# Remover crontab
crontab -r

# Formato: min hora dia mês dia_semana comando
# Exemplos:
# Backup diário às 2h
0 2 * * * /usr/local/bin/backup.sh

# A cada 5 minutos
*/5 * * * * /usr/local/bin/check.sh

# Todo domingo às 3h
0 3 * * 0 /usr/local/bin/weekly.sh

# Todo primeiro dia do mês
0 0 1 * * /usr/local/bin/monthly.sh

# Segunda a sexta às 9h
0 9 * * 1-5 /usr/local/bin/workday.sh

# System crontab
sudo nano /etc/crontab

# Cron logs
sudo grep CRON /var/log/syslog
sudo journalctl -u cron
```

### Scripts Úteis para Automação
```bash
# Script de backup automático
#!/bin/bash
# /usr/local/bin/auto-backup.sh

DATE=$(date +%Y%m%d-%H%M%S)
BACKUP_DIR="/backup"
WEB_DIR="/var/www/html"

tar -czf $BACKUP_DIR/web-$DATE.tar.gz $WEB_DIR
find $BACKUP_DIR -name "web-*.tar.gz" -mtime +7 -delete

# Script de limpeza de logs
#!/bin/bash
# /usr/local/bin/clean-logs.sh

find /var/log -name "*.gz" -mtime +30 -delete
journalctl --vacuum-time=30d

# Script de health check
#!/bin/bash
# /usr/local/bin/health-check.sh

if ! systemctl is-active --quiet httpd; then
    systemctl start httpd
    echo "Apache foi reiniciado em $(date)" >> /var/log/auto-restart.log
fi
```

---

## User Data e Cloud-Init

### Ver User Data
```bash
# Ver user data da instância
curl http://169.254.169.254/latest/user-data

# Ver logs de execução
sudo cat /var/log/cloud-init.log
sudo cat /var/log/cloud-init-output.log
```

### Exemplo de User Data Script
```bash
#!/bin/bash
# User Data para nova instância

# Atualizar sistema
yum update -y

# Instalar Apache
yum install httpd -y

# Iniciar Apache
systemctl start httpd
systemctl enable httpd

# Criar página inicial
cat > /var/www/html/index.html << 'EOF'
<h1>Instância criada automaticamente!<