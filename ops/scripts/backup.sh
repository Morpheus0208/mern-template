#!/bin/bash

# ===========================================
# BACKUP SCRIPT
# ===========================================
# Sauvegarde les données importantes vers un stockage externe
# À exécuter via cron

set -e

# ===========================================
# Configuration
# ===========================================
BACKUP_DIR="/home/deploy/backups"
APPS_DIR="/home/deploy/apps"
DATE=$(date +%Y-%m-%d_%H-%M-%S)
RETENTION_DAYS=7

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}🔄 Démarrage backup - $DATE${NC}"

# Créer le dossier de backup
mkdir -p "$BACKUP_DIR"

# ===========================================
# 1. Backup des configurations Docker
# ===========================================
echo "📦 Backup configurations..."

for app in "$APPS_DIR"/*/; do
    app_name=$(basename "$app")
    backup_file="$BACKUP_DIR/${app_name}_config_$DATE.tar.gz"
    
    # Sauvegarder docker-compose, .env, traefik config
    tar -czf "$backup_file" \
        -C "$app" \
        --exclude='node_modules' \
        --exclude='dist' \
        --exclude='.git' \
        . 2>/dev/null || true
    
    echo "  ✅ $app_name → $(basename $backup_file)"
done

# ===========================================
# 2. Backup des volumes Docker
# ===========================================
echo "🗄️ Backup volumes Docker..."

docker volume ls -q | while read volume; do
    backup_file="$BACKUP_DIR/volume_${volume}_$DATE.tar.gz"
    
    docker run --rm \
        -v "$volume":/source:ro \
        -v "$BACKUP_DIR":/backup \
        alpine tar -czf "/backup/volume_${volume}_$DATE.tar.gz" -C /source . 2>/dev/null || true
    
    echo "  ✅ Volume $volume"
done

# ===========================================
# 3. Backup Traefik (certificats SSL)
# ===========================================
echo "🔐 Backup certificats SSL..."

for app in "$APPS_DIR"/*/; do
    if [ -f "$app/traefik/acme.json" ]; then
        app_name=$(basename "$app")
        cp "$app/traefik/acme.json" "$BACKUP_DIR/${app_name}_acme_$DATE.json"
        echo "  ✅ Certificats $app_name"
    fi
done

# ===========================================
# 4. Nettoyage des vieux backups
# ===========================================
echo "🧹 Nettoyage backups > $RETENTION_DAYS jours..."

find "$BACKUP_DIR" -type f -mtime +$RETENTION_DAYS -delete
echo "  ✅ Nettoyage terminé"

# ===========================================
# 5. Sync vers stockage externe (optionnel)
# ===========================================

# Option A: Hetzner Storage Box (S3 compatible)
# if command -v rclone &> /dev/null; then
#     echo "☁️ Sync vers Hetzner Storage Box..."
#     rclone sync "$BACKUP_DIR" hetzner:backups/$(hostname)/ --progress
#     echo "  ✅ Sync cloud terminé"
# fi

# Option B: rsync vers autre serveur
# rsync -avz --delete "$BACKUP_DIR/" backup-user@backup-server:/backups/$(hostname)/

# Option C: Backblaze B2
# b2 sync "$BACKUP_DIR" b2://my-bucket/backups/$(hostname)/

# ===========================================
# 6. Rapport
# ===========================================
BACKUP_SIZE=$(du -sh "$BACKUP_DIR" | cut -f1)
BACKUP_COUNT=$(ls -1 "$BACKUP_DIR" | wc -l)

echo ""
echo -e "${GREEN}=========================================="
echo "✅ BACKUP TERMINÉ"
echo "==========================================${NC}"
echo ""
echo "📊 Statistiques :"
echo "   Dossier : $BACKUP_DIR"
echo "   Taille  : $BACKUP_SIZE"
echo "   Fichiers: $BACKUP_COUNT"
echo ""

# ===========================================
# 7. Notification (optionnel)
# ===========================================

# Discord webhook
# DISCORD_WEBHOOK="https://discord.com/api/webhooks/xxx"
# curl -H "Content-Type: application/json" \
#      -d "{\"content\": \"✅ Backup VPS terminé - $BACKUP_SIZE\"}" \
#      "$DISCORD_WEBHOOK"

# Email via msmtp
# echo "Backup terminé - $BACKUP_SIZE" | mail -s "Backup VPS $(hostname)" ton@email.com
