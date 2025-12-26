#!/bin/bash

# ===========================================
# SECURITY SETUP - VPS Hardening
# ===========================================
# À exécuter en root après le setup initial

set -e

echo "🔒 Configuration sécurité VPS..."

# ===========================================
# 1. SSH Hardening
# ===========================================
echo "🔑 Durcissement SSH..."

# Backup config originale
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

# Configuration SSH sécurisée
cat > /etc/ssh/sshd_config.d/hardening.conf << 'EOF'
# Désactiver login root
PermitRootLogin no

# Désactiver authentification par mot de passe
PasswordAuthentication no

# Désactiver les mots de passe vides
PermitEmptyPasswords no

# Utiliser uniquement SSH Protocol 2
Protocol 2

# Timeout de connexion
ClientAliveInterval 300
ClientAliveCountMax 2

# Limiter les tentatives
MaxAuthTries 3

# Désactiver X11 forwarding
X11Forwarding no

# Désactiver les tunnels
AllowTcpForwarding no
AllowAgentForwarding no
EOF

# Redémarrer SSH
systemctl restart sshd

echo "✅ SSH durci"

# ===========================================
# 2. Fail2Ban Configuration
# ===========================================
echo "🛡️ Configuration Fail2Ban..."

cat > /etc/fail2ban/jail.local << 'EOF'
[DEFAULT]
bantime = 1h
findtime = 10m
maxretry = 5
banaction = ufw

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 24h

[nginx-http-auth]
enabled = true
filter = nginx-http-auth
port = http,https
logpath = /var/log/nginx/error.log

[nginx-botsearch]
enabled = true
filter = nginx-botsearch
port = http,https
logpath = /var/log/nginx/access.log
maxretry = 2
EOF

systemctl restart fail2ban

echo "✅ Fail2Ban configuré"

# ===========================================
# 3. Automatic Security Updates
# ===========================================
echo "🔄 Configuration mises à jour automatiques..."

apt install -y unattended-upgrades apt-listchanges

cat > /etc/apt/apt.conf.d/50unattended-upgrades << 'EOF'
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}";
    "${distro_id}:${distro_codename}-security";
    "${distro_id}ESMApps:${distro_codename}-apps-security";
    "${distro_id}ESM:${distro_codename}-infra-security";
};

Unattended-Upgrade::Package-Blacklist {
};

Unattended-Upgrade::DevRelease "auto";
Unattended-Upgrade::AutoFixInterruptedDpkg "true";
Unattended-Upgrade::MinimalSteps "true";
Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot "false";
Unattended-Upgrade::Automatic-Reboot-Time "04:00";
EOF

cat > /etc/apt/apt.conf.d/20auto-upgrades << 'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::AutocleanInterval "7";
EOF

echo "✅ Mises à jour automatiques configurées"

# ===========================================
# 4. Firewall Rules Additionnelles
# ===========================================
echo "🔥 Configuration firewall avancée..."

# Limiter les connexions SSH (anti brute-force)
ufw limit ssh

# Bloquer les pings (optionnel)
# ufw deny proto icmp

echo "✅ Firewall configuré"

# ===========================================
# 5. Kernel Hardening
# ===========================================
echo "🧠 Durcissement kernel..."

cat >> /etc/sysctl.conf << 'EOF'

# Sécurité réseau
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 2048
net.ipv4.tcp_synack_retries = 2

# Protection mémoire
kernel.randomize_va_space = 2
EOF

sysctl -p

echo "✅ Kernel durci"

# ===========================================
# 6. Audit Logging
# ===========================================
echo "📝 Configuration des logs d'audit..."

apt install -y auditd

cat > /etc/audit/rules.d/hardening.rules << 'EOF'
# Surveiller les modifications de fichiers sensibles
-w /etc/passwd -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/group -p wa -k identity
-w /etc/sudoers -p wa -k sudo_changes
-w /etc/ssh/sshd_config -p wa -k ssh_changes

# Surveiller les commandes sudo
-a always,exit -F arch=b64 -S execve -F euid=0 -k rootcmd
EOF

systemctl enable auditd
systemctl restart auditd

echo "✅ Audit logs configurés"

# ===========================================
# 7. Docker Security
# ===========================================
echo "🐳 Sécurisation Docker..."

# Limiter les ressources par défaut
cat > /etc/docker/daemon.json << 'EOF'
{
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "10m",
        "max-file": "3"
    },
    "live-restore": true,
    "userland-proxy": false
}
EOF

systemctl restart docker

echo "✅ Docker sécurisé"

echo ""
echo "=========================================="
echo "🎉 SÉCURITÉ CONFIGURÉE !"
echo "=========================================="
echo ""
echo "Résumé :"
echo "  ✅ SSH durci (no root, no password)"
echo "  ✅ Fail2Ban actif (ban 24h après 3 échecs)"
echo "  ✅ Mises à jour automatiques"
echo "  ✅ Firewall renforcé"
echo "  ✅ Kernel durci"
echo "  ✅ Audit logs actifs"
echo "  ✅ Docker sécurisé"
echo ""
echo "⚠️  IMPORTANT : Teste la connexion SSH dans un autre terminal"
echo "    avant de fermer cette session !"
echo ""
