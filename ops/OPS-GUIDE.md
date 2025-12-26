# 🔧 Guide OPS : Surveillance et Sécurité VPS

Ce guide explique comment configurer la surveillance, les backups et la sécurité de ton VPS.

## Vue d'ensemble

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           VPS - OPS STACK                               │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  🔒 SÉCURITÉ                    📊 MONITORING                           │
│  ┌─────────────────────┐        ┌─────────────────────┐                │
│  │ • SSH durci         │        │ • Health checks     │                │
│  │ • Fail2Ban          │        │ • Uptime Kuma       │                │
│  │ • Firewall UFW      │        │ • Dozzle (logs)     │                │
│  │ • Auto-updates      │        │ • Alertes Discord   │                │
│  │ • Audit logs        │        │                     │                │
│  └─────────────────────┘        └─────────────────────┘                │
│                                                                          │
│  💾 BACKUPS                     🔄 MAINTENANCE                          │
│  ┌─────────────────────┐        ┌─────────────────────┐                │
│  │ • Quotidien 3h AM   │        │ • Hebdo dimanche    │                │
│  │ • Rétention 7 jours │        │ • Nettoyage Docker  │                │
│  │ • Configs + volumes │        │ • Rotation logs     │                │
│  │ • Sync cloud (opt)  │        │ • Mises à jour      │                │
│  └─────────────────────┘        └─────────────────────┘                │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 1. Sécurité - Setup initial

### Exécuter le script de sécurité

```bash
# Se connecter en root
ssh root@ton-vps

# Télécharger et exécuter
cd ~/apps/ton-projet
chmod +x ops/scripts/security-setup.sh
sudo ./ops/scripts/security-setup.sh
```

### Ce qui est configuré

| Composant | Configuration |
|-----------|--------------|
| **SSH** | No root login, no password, clés uniquement |
| **Fail2Ban** | Ban 24h après 3 échecs SSH |
| **Firewall** | Ports 22, 80, 443 uniquement |
| **Updates** | Mises à jour sécurité automatiques |
| **Kernel** | Protections réseau activées |
| **Audit** | Logs des accès sensibles |
| **Docker** | Logs limités, live-restore activé |

### Vérifier la sécurité

```bash
# Status Fail2Ban
sudo fail2ban-client status sshd

# IPs bannies
sudo fail2ban-client get sshd banned

# Débannir une IP
sudo fail2ban-client unban IP

# Status firewall
sudo ufw status verbose

# Dernières connexions
last -n 20

# Tentatives échouées
grep "Failed password" /var/log/auth.log | tail -20
```

---

## 2. Backups automatiques

### Configurer les backups

```bash
# Rendre le script exécutable
chmod +x ops/scripts/backup.sh

# Tester manuellement
./ops/scripts/backup.sh

# Vérifier les backups
ls -la /home/deploy/backups/
```

### Ce qui est sauvegardé

| Donnée | Fréquence | Rétention |
|--------|-----------|-----------|
| Configs apps (.env, docker-compose) | Quotidien 3h | 7 jours |
| Volumes Docker | Quotidien 3h | 7 jours |
| Certificats SSL | Quotidien 3h | 7 jours |

### Sync vers stockage externe (recommandé)

#### Option A : Hetzner Storage Box (3€/mois pour 100GB)

```bash
# Installer rclone
curl https://rclone.org/install.sh | sudo bash

# Configurer
rclone config
# → New remote
# → Name: hetzner
# → Type: sftp
# → Host: uXXXXX.your-storagebox.de
# → User: uXXXXX
# → Pass: ton-mot-de-passe

# Tester
rclone ls hetzner:

# Modifier backup.sh pour activer le sync
```

#### Option B : Backblaze B2 (gratuit 10GB)

```bash
# Installer b2
pip install b2

# Configurer
b2 authorize-account

# Modifier backup.sh
```

---

## 3. Health Checks

### Configurer les checks

```bash
# Rendre exécutable
chmod +x ops/scripts/healthcheck.sh

# Tester
./ops/scripts/healthcheck.sh

# Voir les résultats
cat /var/log/healthcheck.log
```

### Ce qui est vérifié

| Check | Seuil alerte | Fréquence |
|-------|--------------|-----------|
| CPU | > 80% | 5 min |
| Mémoire | > 85% | 5 min |
| Disque | > 80% | 5 min |
| Containers Docker | unhealthy/stopped | 5 min |
| Endpoints API | HTTP != 200 | 5 min |
| Services système | inactif | 5 min |
| Certificats SSL | < 14 jours | 5 min |

### Configurer les alertes Discord

1. Créer un webhook Discord :
   - Serveur → Paramètres → Intégrations → Webhooks → Nouveau

2. Modifier `healthcheck.sh` :
```bash
DISCORD_WEBHOOK="https://discord.com/api/webhooks/xxx/yyy"
```

---

## 4. Monitoring Dashboard (Optionnel)

### Installer Uptime Kuma + Dozzle

```bash
# Lancer la stack monitoring
docker compose -f ops/monitoring/docker-compose.monitoring.yml up -d

# Accéder
# Uptime Kuma : http://IP:3001
# Dozzle      : http://IP:9999
```

### Configurer Uptime Kuma

1. Créer un compte admin
2. Ajouter des monitors :

| Monitor | URL | Intervalle |
|---------|-----|------------|
| API Prod | https://api.monapp.com/api/health | 60s |
| API Dev | https://api-dev.monapp.com/api/health | 60s |
| Frontend | https://monapp.com | 60s |

3. Configurer les notifications :
   - Discord
   - Email
   - Telegram
   - Slack

### Dashboard Dozzle

- Voir les logs de tous les containers en temps réel
- Filtrer par container
- Rechercher dans les logs

---

## 5. Maintenance automatique

### Configurer la maintenance

```bash
chmod +x ops/scripts/maintenance.sh

# Tester
./ops/scripts/maintenance.sh
```

### Ce qui est nettoyé

| Action | Fréquence |
|--------|-----------|
| Containers Docker arrêtés | Hebdo |
| Images Docker non utilisées | Hebdo |
| Volumes orphelins | Hebdo |
| Cache apt | Hebdo |
| Vieux logs journald | Hebdo (> 7j) |
| Logs apps > 10MB | Hebdo |
| Logs compressés > 30j | Hebdo |

---

## 6. Configurer Cron

### Installer toutes les tâches planifiées

```bash
# Éditer le crontab
sudo crontab -e

# Coller le contenu de ops/crontab.conf
# Adapter les chemins vers ton projet
```

### Résumé des tâches

| Tâche | Fréquence | Heure |
|-------|-----------|-------|
| Health check | Toutes les 5 min | * |
| Backup | Quotidien | 3h00 |
| Maintenance | Hebdomadaire | Dimanche 4h00 |
| Nettoyage logs | Quotidien | 5h00 |

### Vérifier le cron

```bash
# Voir les tâches
sudo crontab -l

# Logs cron
grep CRON /var/log/syslog | tail -20
```

---

## 7. Commandes utiles

### Sécurité

```bash
# Voir les connexions actives
w
who

# Voir les ports ouverts
ss -tuln
netstat -tuln

# Voir les processus
htop
top

# Scan de sécurité rapide
sudo lynis audit system
```

### Monitoring

```bash
# Ressources en temps réel
htop
docker stats

# Espace disque
df -h
du -sh /home/deploy/*

# Logs récents
docker compose logs -f --tail=100

# Logs système
journalctl -f
```

### Backup & Restore

```bash
# Backup manuel
./ops/scripts/backup.sh

# Lister les backups
ls -la /home/deploy/backups/

# Restaurer une config
tar -xzf backup_file.tar.gz -C /destination/

# Restaurer un volume Docker
docker run --rm \
    -v volume_name:/target \
    -v /home/deploy/backups:/backup \
    alpine tar -xzf /backup/volume_xxx.tar.gz -C /target
```

---

## 8. Checklist de sécurité

### Initial

- [ ] Script security-setup.sh exécuté
- [ ] Connexion SSH testée avec user deploy
- [ ] Root login désactivé vérifié
- [ ] Fail2Ban actif
- [ ] Firewall UFW actif
- [ ] Mises à jour auto activées

### Mensuel

- [ ] Vérifier les IPs bannies
- [ ] Vérifier les logs d'audit
- [ ] Vérifier l'espace disque
- [ ] Tester la restauration d'un backup
- [ ] Vérifier les certificats SSL

### En cas d'incident

1. Vérifier les logs : `docker compose logs -f`
2. Vérifier les ressources : `htop`
3. Vérifier les backups disponibles
4. Rollback si nécessaire
5. Documenter l'incident

---

## 9. Coût total OPS

| Service | Coût |
|---------|------|
| VPS Hetzner CX22 | 4€/mois |
| Hetzner Storage Box 100GB (backup) | 3€/mois (optionnel) |
| Uptime Kuma | Gratuit (self-hosted) |
| **Total** | **4-7€/mois** |
