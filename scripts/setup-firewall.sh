#!/bin/bash

################################################################################
# Script de Configuração de Firewall para Instâncias EC2
# Autor: Laboratório DIO - AWS EC2
# Descrição: Configura regras de firewall local (iptables/ufw/firewalld)
#            seguindo as melhores práticas de segurança
# Uso: sudo ./setup-firewall.sh
################################################################################

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

print_title() {
    echo -e "${BLUE}$1${NC}"
}

# Verificar se está rodando como root
if [[ $EUID -ne 0 ]]; then
   print_error "Este script precisa ser executado como root (use sudo)"
   exit 1
fi

# Banner
echo ""
print_title "========================================================================"
print_title "     CONFIGURAÇÃO DE FIREWALL - AWS EC2"
print_title "     Laboratório DIO - Segurança em Nuvem"
print_title "========================================================================"
echo ""

# Detectar sistema de firewall disponível
detect_firewall() {
    if command -v firewall-cmd &> /dev/null; then
        echo "firewalld"
    elif command -v ufw &> /dev/null; then
        echo "ufw"
    elif command -v iptables &> /dev/null; then
        echo "iptables"
    else
        echo "none"
    fi
}

FIREWALL_TYPE=$(detect_firewall)
print_message "Sistema de firewall detectado: $FIREWALL_TYPE"

# Função para configurar firewalld (CentOS, RHEL, Amazon Linux 2)
configure_firewalld() {
    print_title "\n🔥 Configurando firewalld..."
    
    # Iniciar e habilitar firewalld
    systemctl start firewalld
    systemctl enable firewalld
    
    # Verificar zona ativa
    ACTIVE_ZONE=$(firewall-cmd --get-active-zones | head -n 1)
    print_message "Zona ativa: $ACTIVE_ZONE"
    
    # Regras básicas
    print_message "Aplicando regras básicas..."
    
    # SSH (sempre necessário)
    firewall-cmd --permanent --add-service=ssh
    print_message "✓ SSH (porta 22) - PERMITIDO"
    
    # HTTP
    firewall-cmd --permanent --add-service=http
    print_message "✓ HTTP (porta 80) - PERMITIDO"
    
    # HTTPS
    firewall-cmd --permanent --add-service=https
    print_message "✓ HTTPS (porta 443) - PERMITIDO"
    
    # Portas customizadas (opcional)
    read -p "Deseja adicionar portas customizadas? (s/n): " ADD_CUSTOM
    if [[ $ADD_CUSTOM == "s" ]] || [[ $ADD_CUSTOM == "S" ]]; then
        read -p "Digite a porta (ex: 8080): " CUSTOM_PORT
        read -p "Protocolo (tcp/udp): " PROTOCOL
        firewall-cmd --permanent --add-port=${CUSTOM_PORT}/${PROTOCOL}
        print_message "✓ Porta ${CUSTOM_PORT}/${PROTOCOL} - PERMITIDO"
    fi
    
    # Bloquear ping (ICMP) - opcional
    read -p "Deseja bloquear ping (ICMP)? (s/n): " BLOCK_PING
    if [[ $BLOCK_PING == "s" ]] || [[ $BLOCK_PING == "S" ]]; then
        firewall-cmd --permanent --add-icmp-block=echo-request
        print_message "✓ ICMP (ping) - BLOQUEADO"
    fi
    
    # Recarregar firewall
    firewall-cmd --reload
    
    # Mostrar regras ativas
    print_title "\n📋 Regras Ativas:"
    firewall-cmd --list-all
}

# Função para configurar UFW (Ubuntu, Debian)
configure_ufw() {
    print_title "\n🛡️ Configurando UFW..."
    
    # Resetar regras (opcional)
    read -p "Deseja resetar regras existentes? (s/n): " RESET_RULES
    if [[ $RESET_RULES == "s" ]] || [[ $RESET_RULES == "S" ]]; then
        ufw --force reset
        print_message "Regras resetadas"
    fi
    
    # Política padrão
    print_message "Configurando política padrão..."
    ufw default deny incoming
    ufw default allow outgoing
    print_message "✓ Política: DENY incoming, ALLOW outgoing"
    
    # Regras básicas
    print_message "Aplicando regras básicas..."
    
    # SSH (sempre necessário)
    ufw allow ssh
    print_message "✓ SSH (porta 22) - PERMITIDO"
    
    # HTTP
    ufw allow http
    print_message "✓ HTTP (porta 80) - PERMITIDO"
    
    # HTTPS
    ufw allow https
    print_message "✓ HTTPS (porta 443) - PERMITIDO"
    
    # Portas customizadas (opcional)
    read -p "Deseja adicionar portas customizadas? (s/n): " ADD_CUSTOM
    if [[ $ADD_CUSTOM == "s" ]] || [[ $ADD_CUSTOM == "S" ]]; then
        read -p "Digite a porta (ex: 8080): " CUSTOM_PORT
        read -p "Protocolo (tcp/udp): " PROTOCOL
        ufw allow ${CUSTOM_PORT}/${PROTOCOL}
        print_message "✓ Porta ${CUSTOM_PORT}/${PROTOCOL} - PERMITIDO"
    fi
    
    # Limitar tentativas de SSH (proteção contra brute force)
    read -p "Deseja limitar tentativas de conexão SSH? (s/n): " LIMIT_SSH
    if [[ $LIMIT_SSH == "s" ]] || [[ $LIMIT_SSH == "S" ]]; then
        ufw limit ssh
        print_message "✓ SSH - RATE LIMITING ativado"
    fi
    
    # Habilitar UFW
    print_warning "Habilitando UFW..."
    ufw --force enable
    
    # Mostrar status
    print_title "\n📋 Status do UFW:"
    ufw status verbose
}

# Função para configurar iptables (genérico)
configure_iptables() {
    print_title "\n🔒 Configurando iptables..."
    
    print_warning "ATENÇÃO: Configuração de iptables pode desconectar sua sessão SSH!"
    read -p "Deseja continuar? (s/n): " CONTINUE
    if [[ $CONTINUE != "s" ]] && [[ $CONTINUE != "S" ]]; then
        print_message "Configuração cancelada."
        exit 0
    fi
    
    # Limpar regras existentes
    print_message "Limpando regras existentes..."
    iptables -F
    iptables -X
    iptables -Z
    
    # Política padrão
    print_message "Definindo política padrão..."
    iptables -P INPUT DROP
    iptables -P FORWARD DROP
    iptables -P OUTPUT ACCEPT
    
    # Permitir loopback
    iptables -A INPUT -i lo -j ACCEPT
    print_message "✓ Loopback - PERMITIDO"
    
    # Permitir conexões estabelecidas
    iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
    print_message "✓ Conexões estabelecidas - PERMITIDO"
    
    # SSH
    iptables -A INPUT -p tcp --dport 22 -j ACCEPT
    print_message "✓ SSH (porta 22) - PERMITIDO"
    
    # HTTP
    iptables -A INPUT -p tcp --dport 80 -j ACCEPT
    print_message "✓ HTTP (porta 80) - PERMITIDO"
    
    # HTTPS
    iptables -A INPUT -p tcp --dport 443 -j ACCEPT
    print_message "✓ HTTPS (porta 443) - PERMITIDO"
    
    # Proteção contra ping flood
    iptables -A INPUT -p icmp --icmp-type echo-request -m limit --limit 1/s -j ACCEPT
    print_message "✓ ICMP - RATE LIMITED"
    
    # Proteção contra port scanning
    iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
    iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP
    print_message "✓ Proteção contra port scan - ATIVADO"
    
    # Salvar regras
    print_message "Salvando regras..."
    if command -v iptables-save &> /dev/null; then
        iptables-save > /etc/iptables/rules.v4 2>/dev/null || \
        iptables-save > /etc/sysconfig/iptables 2>/dev/null || \
        iptables-save > /tmp/iptables-rules.txt
        print_message "✓ Regras salvas"
    fi
    
    # Mostrar regras
    print_title "\n📋 Regras Ativas:"
    iptables -L -n -v
}

# Função para criar script de persistência
create_persistence_script() {
    print_message "\nCriando script de persistência..."
    
    cat > /usr/local/bin/restore-firewall.sh << 'EOF'
#!/bin/bash
# Script de restauração de firewall
# Criado automaticamente pelo setup-firewall.sh

if [ -f /etc/iptables/rules.v4 ]; then
    iptables-restore < /etc/iptables/rules.v4
elif [ -f /etc/sysconfig/iptables ]; then
    iptables-restore < /etc/sysconfig/iptables
fi
EOF
    
    chmod +x /usr/local/bin/restore-firewall.sh
    print_message "✓ Script de persistência criado"
}

# Função para verificar Security Groups AWS
check_aws_security_groups() {
    print_title "\n☁️ Verificação de Security Groups AWS"
    print_warning "LEMBRE-SE: As regras de Security Group da AWS são aplicadas ANTES do firewall local!"
    echo ""
    print_message "Certifique-se de que seu Security Group permite:"
    echo "  • SSH (porta 22) - Do seu IP"
    echo "  • HTTP (porta 80) - De 0.0.0.0/0"
    echo "  • HTTPS (porta 443) - De 0.0.0.0/0"
    echo ""
    print_message "Para verificar: AWS Console > EC2 > Security Groups"
}

# Executar configuração baseada no tipo de firewall
case $FIREWALL_TYPE in
    "firewalld")
        configure_firewalld
        ;;
    "ufw")
        configure_ufw
        ;;
    "iptables")
        configure_iptables
        create_persistence_script
        ;;
    "none")
        print_error "Nenhum sistema de firewall detectado!"
        print_message "Instalando iptables..."
        yum install iptables-services -y 2>/dev/null || apt-get install iptables-persistent -y 2>/dev/null
        configure_iptables
        ;;
esac

# Verificar Security Groups AWS
check_aws_security_groups

# Resumo final
echo ""
print_title "========================================================================"
print_title "     ✅ CONFIGURAÇÃO CONCLUÍDA"
print_title "========================================================================"
echo ""
print_message "Firewall configurado com sucesso!"
print_message "Sistema: $FIREWALL_TYPE"
echo ""
print_title "📝 Comandos Úteis:"
echo ""

case $FIREWALL_TYPE in
    "firewalld")
        echo "  Ver status:       sudo firewall-cmd --state"
        echo "  Listar regras:    sudo firewall-cmd --list-all"
        echo "  Adicionar porta:  sudo firewall-cmd --permanent --add-port=PORTA/tcp"
        echo "  Remover porta:    sudo firewall-cmd --permanent --remove-port=PORTA/tcp"
        echo "  Recarregar:       sudo firewall-cmd --reload"
        ;;
    "ufw")
        echo "  Ver status:       sudo ufw status verbose"
        echo "  Adicionar porta:  sudo ufw allow PORTA/tcp"
        echo "  Remover regra:    sudo ufw delete allow PORTA/tcp"
        echo "  Habilitar:        sudo ufw enable"
        echo "  Desabilitar:      sudo ufw disable"
        ;;
    "iptables")
        echo "  Ver regras:       sudo iptables -L -n -v"
        echo "  Salvar regras:    sudo iptables-save > /etc/iptables/rules.v4"
        echo "  Restaurar regras: sudo iptables-restore < /etc/iptables/rules.v4"
        echo "  Limpar regras:    sudo iptables -F"
        ;;
esac

echo ""
print_title "========================================================================"
echo ""

print_message "Script finalizado!"
exit 0