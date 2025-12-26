#!/bin/bash

# ===========================================
# MAINTENANCE SCRIPT
# ===========================================
# Nettoyage et optimisation automatique
# À exécuter via cron chaque semaine

set -e

DATE=$(date '+%Y-%m-%d %H:%M:%S')
LOG_FILE="/var/log/maintenance.log"

log() {
    echo "[$DATE] $1" | tee -a "$LOG_FILE"
}

log "========== MAINTENANCE =========="

# ===========================================
# 1. Nettoyage Docker
# ===========================================
log "🐳 Nettoyage Docker..."

# Supprimer les containers arrêtés
docker container prune -f

# Supprimer les images non utilisées
docker image prune -af

# Supprimer les volumes orphelins
docker volume prune -f

# Supprimer les networks non utilisés
docker network prune -f

# Supprimer le cache de build
docker builder prune -af

log "✅ Docker nettoyé"

# ===========================================
# 2. Nettoyage système
# ===========================================
log "🧹 Nettoyage système..."

# Nettoyer apt
apt autoremove -y
apt autoclean

# Vider les vieux logs
journalctl --vacuum-time=7d

# Nettoyer les fichiers temporaires
rm -rf /tmp/* 2>/dev/null || true

log "✅ Système nettoyé"

# ===========================================
# 3. Rotation des logs applicatifs
# ===========================================
log "📜 Rotation des logs..."

# Compresser les logs des apps
find /home/deploy/apps -name "*.log" -size +10M -exec gzip {} \;

# Supprimer les logs compressés > 30 jours
find /home/deploy/apps -name "*.log.gz" -mtime +30 -delete

log "✅ Logs nettoyés"

# ===========================================
# 4. Vérification espace disque
# ===========================================
log "💾 Vérification espace disque..."

DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')
DISK_FREE=$(df -h / | awk 'NR==2 {print $4}')

log "   Utilisation: ${DISK_USAGE}%"
log "   Disponible: ${DISK_FREE}"

# Alerte si > 80%
if [ "$DISK_USAGE" -gt 80 ]; then
    log "⚠️ Espace disque critique !"
fi

# ===========================================
# 5. Mise à jour des images Docker
# ===========================================
log "🔄 Vérification mises à jour Docker..."

# Pull les nouvelles versions des images de base
docker pull node:20-alpine
docker pull traefik:v3.0

log "✅ Images vérifiées"

# ===========================================
# 6. Renouvellement certificats SSL (Traefik le fait auto)
# ===========================================
log "🔐 Vérification certificats SSL..."

# Traefik renouvelle automatiquement, on vérifie juste
for app_dir in /home/deploy/apps/*/; do
    if [ -f "$app_dir/traefik/acme.json" ]; then
        CERT_SIZE=$(stat -f%z "$app_dir/traefik/acme.json" 2>/dev/null || stat -c%s "$app_dir/traefik/acme.json")
        if [ "$CERT_SIZE" -gt 100 ]; then
            log "✅ Certificats $(basename $app_dir): OK"
        fi
    fi
done

# ===========================================
# 7. Vérification sécurité
# ===========================================
log "🔒 Vérification sécurité..."

# IPs bannies par fail2ban
BANNED=$(fail2ban-client status sshd 2>/dev/null | grep "Currently banned" | awk '{print $4}')
log "   IPs bannies SSH: $BANNED"

# Dernières connexions
log "   Dernières connexions:"
last -n 5 | head -5 | while read line; do
    log "     $line"
done

# ===========================================
# 8. Rapport final
# ===========================================
log ""
log "========== RAPPORT =========="
log "Espace disque: ${DISK_USAGE}% utilisé"
log "Containers actifs: $(docker ps -q | wc -l)"
log "Uptime: $(uptime -p)"
log "============================="
log ""
log "✅ Maintenance terminée"
