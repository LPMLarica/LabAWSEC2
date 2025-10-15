#!/bin/bash

################################################################################
# Script de Instalação e Configuração do Apache Web Server
# Autor: Laboratório DIO - AWS EC2
# Descrição: Automatiza a instalação do Apache, configuração básica e 
#            criação de página web de demonstração
# Compatível com: Amazon Linux 2023, Amazon Linux 2, CentOS, RHEL
################################################################################

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Função para imprimir mensagens coloridas
print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERRO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[AVISO]${NC} $1"
}

# Verificar se está rodando como root
if [[ $EUID -ne 0 ]]; then
   print_error "Este script precisa ser executado como root (use sudo)"
   exit 1
fi

print_message "Iniciando instalação do Apache Web Server..."

# Detectar distribuição Linux
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    print_message "Sistema operacional detectado: $PRETTY_NAME"
else
    print_error "Não foi possível detectar o sistema operacional"
    exit 1
fi

# Atualizar sistema
print_message "Atualizando pacotes do sistema..."
if [[ "$OS" == "amzn" ]] || [[ "$OS" == "centos" ]] || [[ "$OS" == "rhel" ]]; then
    yum update -y
elif [[ "$OS" == "ubuntu" ]] || [[ "$OS" == "debian" ]]; then
    apt-get update -y
    apt-get upgrade -y
else
    print_warning "Distribuição não reconhecida. Tentando prosseguir..."
fi

# Instalar Apache
print_message "Instalando Apache..."
if [[ "$OS" == "amzn" ]] || [[ "$OS" == "centos" ]] || [[ "$OS" == "rhel" ]]; then
    yum install httpd -y
    SERVICE_NAME="httpd"
elif [[ "$OS" == "ubuntu" ]] || [[ "$OS" == "debian" ]]; then
    apt-get install apache2 -y
    SERVICE_NAME="apache2"
else
    print_error "Não foi possível instalar Apache para esta distribuição"
    exit 1
fi

# Verificar se instalação foi bem sucedida
if [ $? -eq 0 ]; then
    print_message "Apache instalado com sucesso!"
else
    print_error "Falha na instalação do Apache"
    exit 1
fi

# Iniciar serviço Apache
print_message "Iniciando serviço Apache..."
systemctl start $SERVICE_NAME

# Habilitar Apache para iniciar no boot
print_message "Configurando Apache para iniciar automaticamente no boot..."
systemctl enable $SERVICE_NAME

# Verificar status
print_message "Verificando status do serviço..."
systemctl status $SERVICE_NAME --no-pager

# Criar diretório para página web se não existir
WEB_DIR="/var/www/html"
if [ ! -d "$WEB_DIR" ]; then
    mkdir -p $WEB_DIR
fi

# Criar página HTML de demonstração
print_message "Criando página web de demonstração..."
cat > $WEB_DIR/index.html << 'EOF'
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Laboratório AWS EC2 - DIO</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }
        
        .container {
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            padding: 40px;
            max-width: 800px;
            text-align: center;
            animation: fadeIn 1s ease-in;
        }
        
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(-20px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        h1 {
            color: #333;
            margin-bottom: 20px;
            font-size: 2.5em;
        }
        
        .badge {
            display: inline-block;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 10px 20px;
            border-radius: 25px;
            margin: 10px;
            font-weight: bold;
        }
        
        .info-box {
            background: #f8f9fa;
            border-left: 4px solid #667eea;
            padding: 20px;
            margin: 20px 0;
            text-align: left;
            border-radius: 5px;
        }
        
        .info-box h3 {
            color: #667eea;
            margin-bottom: 10px;
        }
        
        .info-box p {
            color: #666;
            line-height: 1.6;
        }
        
        .success {
            color: #28a745;
            font-size: 1.2em;
            margin: 20px 0;
        }
        
        .footer {
            margin-top: 30px;
            color: #666;
            font-size: 0.9em;
        }
        
        .server-info {
            background: #e9ecef;
            padding: 15px;
            border-radius: 10px;
            margin: 20px 0;
            font-family: 'Courier New', monospace;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Servidor EC2 Ativo!</h1>
        
        <div class="badge">AWS EC2</div>
        <div class="badge">Apache</div>
        <div class="badge">DIO</div>
        
        <p class="success">✓ Servidor web configurado com sucesso!</p>
        
        <div class="info-box">
            <h3>📚 Sobre este Laboratório</h3>
            <p>
                Este servidor foi configurado como parte do laboratório de 
                <strong>Gerenciamento de Instâncias EC2</strong> oferecido pela 
                Digital Innovation One (DIO). O objetivo é demonstrar na prática 
                os conceitos de computação em nuvem utilizando Amazon Web Services.
            </p>
        </div>
        
        <div class="info-box">
            <h3>🛠️ Tecnologias Utilizadas</h3>
            <p>
                <strong>Infraestrutura:</strong> Amazon EC2<br>
                <strong>Web Server:</strong> Apache HTTP Server<br>
                <strong>Sistema Operacional:</strong> Amazon Linux 2023<br>
                <strong>Segurança:</strong> Security Groups e SSH Key Pairs
            </p>
        </div>
        
        <div class="server-info">
            <strong>Informações do Servidor:</strong><br>
            Data/Hora: <span id="datetime"></span><br>
            User Agent: <span id="useragent"></span>
        </div>
        
        <div class="footer">
            <p>Desenvolvido com dedicação durante o Bootcamp DIO 💜</p>
            <p>© 2025 - Laboratório AWS EC2</p>
        </div>
    </div>
    
    <script>
        // Atualizar data/hora
        document.getElementById('datetime').textContent = new Date().toLocaleString('pt-BR');
        
        // Mostrar user agent
        document.getElementById('useragent').textContent = navigator.userAgent.substring(0, 80) + '...';
    </script>
</body>
</html>
EOF

# Definir permissões corretas
print_message "Configurando permissões..."
chown -R apache:apache $WEB_DIR 2>/dev/null || chown -R www-data:www-data $WEB_DIR 2>/dev/null
chmod -R 755 $WEB_DIR

# Configurar firewall se disponível
print_message "Verificando configuração de firewall..."
if command -v firewall-cmd &> /dev/null; then
    print_message "Configurando firewall-cmd..."
    firewall-cmd --permanent --add-service=http
    firewall-cmd --permanent --add-service=https
    firewall-cmd --reload
elif command -v ufw &> /dev/null; then
    print_message "Configurando ufw..."
    ufw allow 'Apache'
    ufw allow 'Apache Full'
fi

# Obter IP público da instância
print_message "Obtendo informações da instância..."
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null)
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id 2>/dev/null)
AVAILABILITY_ZONE=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone 2>/dev/null)

# Exibir resumo da instalação
echo ""
echo "========================================================================"
print_message "Instalação concluída com sucesso!"
echo "========================================================================"
echo ""
echo "  Informações da Instância:"
echo "  ----------------------------"
echo "  Instance ID: $INSTANCE_ID"
echo "  Availability Zone: $AVAILABILITY_ZONE"
echo "  IP Público: $PUBLIC_IP"
echo ""
echo "  Acesso ao Servidor:"
echo "  ----------------------------"
if [ -n "$PUBLIC_IP" ]; then
    echo "  URL: http://$PUBLIC_IP"
else
    echo "  URL: http://[SEU-IP-PUBLICO]"
fi
echo ""
echo "  Comandos Úteis:"
echo "  ----------------------------"
echo "  Verificar status:  sudo systemctl status $SERVICE_NAME"
echo "  Parar serviço:     sudo systemctl stop $SERVICE_NAME"
echo "  Iniciar serviço:   sudo systemctl start $SERVICE_NAME"
echo "  Reiniciar serviço: sudo systemctl restart $SERVICE_NAME"
echo "  Ver logs:          sudo journalctl -u $SERVICE_NAME -f"
echo ""
echo "========================================================================"
echo ""

# Testar servidor localmente
print_message "Testando servidor localmente..."
sleep 2
if curl -s http://localhost | grep -q "Servidor EC2 Ativo"; then
    print_message "Teste local: ✓ SUCESSO"
else
    print_warning "Teste local falhou. Verifique as configurações."
fi

print_message "Script finalizado!"
exit 0