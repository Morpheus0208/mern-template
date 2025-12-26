#!/bin/bash

# ===========================================
# HEALTH CHECK SCRIPT
# ===========================================
# Vérifie l'état de tous les services
# À exécuter via cron toutes les 5 minutes

set -e

# ===========================================
# Configuration
# ===========================================
LOG_FILE="/var/log/healthcheck.log"
ALERT_EMAIL="ton@email.com"
DISCORD_WEBHOOK=""  # Optionnel

# Seuils d'alerte
CPU_THRESHOLD=80
MEMORY_THRESHOLD=85
DISK_THRESHOLD=80

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

DATE=$(date '+%Y-%m-%d %H:%M:%S')
ERRORS=()

log() {
    echo "[$DATE] $1" | tee -a "$LOG_FILE"
}

alert() {
    local message="$1"
    ERRORS+=("$message")
    log "❌ ALERTE: $message"
}

# ===========================================
# 1. Vérification CPU
# ===========================================
check_cpu() {
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d. -f1)
    
    if [ "$CPU_USAGE" -gt "$CPU_THRESHOLD" ]; then
        alert "CPU à ${CPU_USAGE}% (seuil: ${CPU_THRESHOLD}%)"
    else
        log "✅ CPU: ${CPU_USAGE}%"
    fi
}

# ===========================================
# 2. Vérification Mémoire
# ===========================================
check_memory() {
    MEMORY_USAGE=$(free | grep Mem | awk '{printf("%.0f", $3/$2 * 100)}')
    
    if [ "$MEMORY_USAGE" -gt "$MEMORY_THRESHOLD" ]; then
        alert "Mémoire à ${MEMORY_USAGE}% (seuil: ${MEMORY_THRESHOLD}%)"
    else
        log "✅ Mémoire: ${MEMORY_USAGE}%"
    fi
}

# ===========================================
# 3. Vérification Disque
# ===========================================
check_disk() {
    DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')
    
    if [ "$DISK_USAGE" -gt "$DISK_THRESHOLD" ]; then
        alert "Disque à ${DISK_USAGE}% (seuil: ${DISK_THRESHOLD}%)"
    else
        log "✅ Disque: ${DISK_USAGE}%"
    fi
}

# ===========================================
# 4. Vérification Containers Docker
# ===========================================
check_docker() {
    # Vérifier que Docker tourne
    if ! systemctl is-active --quiet docker; then
        alert "Docker n'est pas actif !"
        return
    fi
    
    # Vérifier chaque container
    docker ps --format '{{.Names}}' | while read container; do
        STATUS=$(docker inspect --format='{{.State.Health.Status}}' "$container" 2>/dev/null || echo "no-healthcheck")
        
        if [ "$STATUS" = "unhealthy" ]; then
            alert "Container $container est unhealthy"
        elif [ "$STATUS" = "healthy" ] || [ "$STATUS" = "no-healthcheck" ]; then
            log "✅ Container: $container"
        fi
    done
    
    # Vérifier containers arrêtés inattendus
    STOPPED=$(docker ps -a --filter "status=exited" --format '{{.Names}}' | grep -E 'api-|traefik' || true)
    if [ -n "$STOPPED" ]; then
        alert "Containers arrêtés: $STOPPED"
    fi
}

# ===========================================
# 5. Vérification des endpoints API
# ===========================================
check_endpoints() {
    # Liste des endpoints à vérifier
    ENDPOINTS=(
        "http://localhost:5000/api/health|api-prod"
        "http://localhost:5001/api/health|api-dev"
    )
    
    for endpoint_info in "${ENDPOINTS[@]}"; do
        URL="${endpoint_info%%|*}"
        NAME="${endpoint_info##*|}"
        
        HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "$URL" 2>/dev/null || echo "000")
        
        if [ "$HTTP_CODE" = "200" ]; then
            log "✅ Endpoint $NAME: OK"
        else
            alert "Endpoint $NAME indisponible (HTTP $HTTP_CODE)"
        fi
    done
}

# ===========================================
# 6. Vérification SSL
# ===========================================
check_ssl() {
    DOMAINS=("api.monapp.com" "api-dev.monapp.com")
    
    for domain in "${DOMAINS[@]}"; do
        EXPIRY=$(echo | openssl s_client -servername "$domain" -connect "$domain":443 2>/dev/null | openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2)
        
        if [ -n "$EXPIRY" ]; then
            EXPIRY_EPOCH=$(date -d "$EXPIRY" +%s 2>/dev/null || date -j -f "%b %d %T %Y %Z" "$EXPIRY" +%s 2>/dev/null)
            NOW_EPOCH=$(date +%s)
            DAYS_LEFT=$(( (EXPIRY_EPOCH - NOW_EPOCH) / 86400 ))
            
            if [ "$DAYS_LEFT" -lt 14 ]; then
                alert "SSL $domain expire dans $DAYS_LEFT jours"
            else
                log "✅ SSL $domain: $DAYS_LEFT jours restants"
            fi
        fi
    done
}

# ===========================================
# 7. Vérification services système
# ===========================================
check_services() {
    SERVICES=("docker" "fail2ban" "ufw")
    
    for service in "${SERVICES[@]}"; do
        if systemctl is-active --quiet "$service"; then
            log "✅ Service $service: actif"
        else
            alert "Service $service inactif !"
        fi
    done
}

# ===========================================
# 8. Vérification logs d'erreurs
# ===========================================
check_logs() {
    # Erreurs Docker récentes (dernière heure)
    DOCKER_ERRORS=$(docker ps -q | xargs -I {} docker logs --since 1h {} 2>&1 | grep -iE 'error|fatal|panic' | wc -l)
    
    if [ "$DOCKER_ERRORS" -gt 10 ]; then
        alert "$DOCKER_ERRORS erreurs dans les logs Docker (dernière heure)"
    fi
    
    # Tentatives SSH échouées
    SSH_FAILS=$(grep "Failed password" /var/log/auth.log 2>/dev/null | tail -100 | wc -l)
    
    if [ "$SSH_FAILS" -gt 20 ]; then
        alert "$SSH_FAILS tentatives SSH échouées récemment"
    fi
}

# ===========================================
# Exécution des checks
# ===========================================
echo ""
log "========== HEALTH CHECK =========="

check_cpu
check_memory
check_disk
check_docker
check_endpoints
check_services
check_logs
# check_ssl  # Décommenter quand les domaines sont configurés

log "==================================="

# ===========================================
# Envoi des alertes
# ===========================================
if [ ${#ERRORS[@]} -gt 0 ]; then
    ALERT_MESSAGE="🚨 ALERTES VPS $(hostname)\n\n"
    for error in "${ERRORS[@]}"; do
        ALERT_MESSAGE+="• $error\n"
    done
    
    # Discord
    if [ -n "$DISCORD_WEBHOOK" ]; then
        curl -s -H "Content-Type: application/json" \
             -d "{\"content\": \"$ALERT_MESSAGE\"}" \
             "$DISCORD_WEBHOOK"
    fi
    
    # Email (nécessite msmtp ou sendmail configuré)
    # echo -e "$ALERT_MESSAGE" | mail -s "🚨 Alerte VPS $(hostname)" "$ALERT_EMAIL"
    
    log "📧 Alertes envoyées (${#ERRORS[@]} problèmes)"
    exit 1
else
    log "✅ Tous les checks OK"
    exit 0
fi
