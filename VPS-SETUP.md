# 🚀 Guide : Setup VPS Hetzner + Docker + Vercel

Ce guide t'accompagne pas à pas pour configurer ton hébergement.

## Architecture finale

```
┌─────────────────────────────────────────────────────────────────────────┐
│                                                                          │
│                           VERCEL (Gratuit)                              │
│                             Frontend                                     │
│                                                                          │
│   monapp.com ──────────────► Production                                 │
│   preview.vercel.app ──────► DEV                                        │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                                                                          │
│                      VPS HETZNER (4€/mois)                              │
│                                                                          │
│   ┌─────────────────────────────────────────────────────────────────┐   │
│   │                         TRAEFIK                                  │   │
│   │                    (Reverse Proxy + SSL)                         │   │
│   │                                                                  │   │
│   │   api.monapp.com ────────► api-prod (:5000)                     │   │
│   │   api-dev.monapp.com ────► api-dev (:5001)                      │   │
│   │                                                                  │   │
│   └─────────────────────────────────────────────────────────────────┘   │
│                                                                          │
│   ┌───────────────────┐              ┌───────────────────┐             │
│   │    api-prod       │              │    api-dev        │             │
│   │    (Docker)       │              │    (Docker)       │             │
│   │    Port 5000      │              │    Port 5001      │             │
│   └───────────────────┘              └───────────────────┘             │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                                                                          │
│                       MONGODB ATLAS (Gratuit)                           │
│                                                                          │
│   myapp-dev ◄──────────────── DEV                                       │
│   myapp-prod ◄─────────────── PROD                                      │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Coût total

| Service | Coût |
|---------|------|
| VPS Hetzner CX22 | 4€/mois |
| Vercel | Gratuit |
| MongoDB Atlas M0 | Gratuit |
| Domaine (.com) | ~10€/an |
| **Total** | **~5€/mois** |

---

## Étape 1 : Créer le VPS Hetzner (10 min)

### 1.1 Créer un compte

1. Va sur [hetzner.com/cloud](https://www.hetzner.com/cloud)
2. Crée un compte

### 1.2 Créer un serveur

1. **New Project** → `mes-apps`
2. **Add Server**
3. Configuration :

| Option | Valeur |
|--------|--------|
| Location | Falkenstein (moins cher) ou Helsinki |
| Image | **Ubuntu 24.04** |
| Type | **CX22** (2 vCPU, 4GB RAM) - 4,51€ |
| SSH Key | Ajouter ta clé publique (voir ci-dessous) |
| Name | `vps-prod` |

### 1.3 Créer une clé SSH (si pas déjà fait)

```bash
# Sur ton Mac
ssh-keygen -t ed25519 -C "ton-email@example.com"

# Afficher la clé publique
cat ~/.ssh/id_ed25519.pub

# Copier et coller dans Hetzner
```

### 1.4 Noter l'IP du serveur

```
IP du serveur : xxx.xxx.xxx.xxx
```

---

## Étape 2 : Configurer le DNS (5 min)

Chez ton registrar (OVH, Cloudflare, Gandi...) :

| Type | Nom | Valeur | TTL |
|------|-----|--------|-----|
| A | @ | xxx.xxx.xxx.xxx | 300 |
| A | api | xxx.xxx.xxx.xxx | 300 |
| A | api-dev | xxx.xxx.xxx.xxx | 300 |

Attendre 5-10 minutes pour la propagation.

---

## Étape 3 : Configurer le VPS (15 min)

### 3.1 Se connecter

```bash
ssh root@xxx.xxx.xxx.xxx
```

### 3.2 Script de setup automatique

Copie-colle ce script complet :

```bash
#!/bin/bash

# ===========================================
# SETUP VPS - À exécuter en root
# ===========================================

# Variables
NEW_USER="deploy"

echo "🚀 Setup VPS Hetzner..."

# 1. Mise à jour système
echo "📦 Mise à jour du système..."
apt update && apt upgrade -y

# 2. Installer Docker
echo "🐳 Installation de Docker..."
curl -fsSL https://get.docker.com | sh

# 3. Installer Docker Compose
echo "🐳 Installation de Docker Compose..."
apt install -y docker-compose-plugin

# 4. Créer utilisateur deploy
echo "👤 Création de l'utilisateur deploy..."
useradd -m -s /bin/bash -G docker,sudo $NEW_USER

# 5. Configurer SSH pour l'utilisateur deploy
echo "🔑 Configuration SSH..."
mkdir -p /home/$NEW_USER/.ssh
cp ~/.ssh/authorized_keys /home/$NEW_USER/.ssh/
chown -R $NEW_USER:$NEW_USER /home/$NEW_USER/.ssh
chmod 700 /home/$NEW_USER/.ssh
chmod 600 /home/$NEW_USER/.ssh/authorized_keys

# 6. Permettre sudo sans mot de passe
echo "$NEW_USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$NEW_USER

# 7. Installer Git
echo "📦 Installation de Git..."
apt install -y git

# 8. Créer le dossier des apps
echo "📁 Création du dossier apps..."
mkdir -p /home/$NEW_USER/apps
chown -R $NEW_USER:$NEW_USER /home/$NEW_USER/apps

# 9. Configurer le firewall
echo "🔥 Configuration du firewall..."
apt install -y ufw
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow http
ufw allow https
ufw --force enable

# 10. Installer fail2ban (sécurité)
echo "🔒 Installation de fail2ban..."
apt install -y fail2ban
systemctl enable fail2ban
systemctl start fail2ban

echo ""
echo "✅ Setup terminé !"
echo ""
echo "📋 Prochaines étapes :"
echo "   1. Déconnecte-toi : exit"
echo "   2. Reconnecte-toi : ssh deploy@xxx.xxx.xxx.xxx"
echo ""
```

### 3.3 Exécuter le script

```bash
# Coller le script puis exécuter
bash setup.sh

# Ou directement :
# Copier le contenu et le coller dans le terminal
```

### 3.4 Se reconnecter en tant que deploy

```bash
exit
ssh deploy@xxx.xxx.xxx.xxx
```

---

## Étape 4 : Déployer l'application (10 min)

### 4.1 Cloner le projet

```bash
cd ~/apps
git clone https://github.com/TON-USERNAME/TON-REPO.git
cd TON-REPO
```

### 4.2 Créer le fichier .env

```bash
cp .env.vps.example .env
nano .env
```

Remplir les valeurs :

```bash
DOMAIN=monapp.com
ACME_EMAIL=ton-email@example.com
MONGODB_URI_DEV=mongodb+srv://...
MONGODB_URI_PROD=mongodb+srv://...
JWT_SECRET_DEV=xxx
JWT_SECRET_PROD=yyy
```

### 4.3 Préparer Traefik

```bash
# Créer le fichier pour les certificats SSL
touch traefik/acme.json
chmod 600 traefik/acme.json
```

### 4.4 Lancer les services

```bash
# Démarrer tout
docker compose up -d

# Vérifier que tout tourne
docker compose ps

# Voir les logs
docker compose logs -f
```

### 4.5 Tester

```bash
# Test DEV
curl https://api-dev.monapp.com/api/health

# Test PROD
curl https://api.monapp.com/api/health
```

---

## Étape 5 : Configurer MongoDB Atlas (5 min)

### 5.1 Créer un compte

1. Va sur [mongodb.com/atlas](https://www.mongodb.com/atlas)
2. Crée un compte gratuit

### 5.2 Créer un cluster

1. **Build a Database** → **M0 FREE**
2. Provider: AWS
3. Region: Paris (eu-west-3)
4. Cluster name: `production`

### 5.3 Configurer l'accès

1. **Database Access** → Add User
   - Username: `app-user`
   - Password: (générer)
   - Role: `readWriteAnyDatabase`

2. **Network Access** → Add IP
   - **Allow Access from Anywhere** (0.0.0.0/0)

### 5.4 Récupérer les connection strings

```
MONGODB_URI_DEV=mongodb+srv://app-user:PASSWORD@cluster.mongodb.net/myapp-dev
MONGODB_URI_PROD=mongodb+srv://app-user:PASSWORD@cluster.mongodb.net/myapp-prod
```

---

## Étape 6 : Configurer Vercel (5 min)

### 6.1 Importer le projet

1. Va sur [vercel.com](https://vercel.com)
2. **Add New** → **Project**
3. Import ton repo GitHub
4. Configure :
   - Framework: Vite
   - Root Directory: `client`
   - Build Command: `npm run build`
   - Output Directory: `dist`

### 6.2 Variables d'environnement

| Variable | Preview | Production |
|----------|---------|------------|
| `VITE_API_URL` | https://api-dev.monapp.com | https://api.monapp.com |
| `VITE_ENV` | development | production |

### 6.3 Récupérer les tokens

- **Account Settings** → **Tokens** → Créer
- **Project Settings** → Copier **Project ID** et **Org ID**

---

## Étape 7 : Configurer GitHub (5 min)

### 7.1 Secrets

Repository → Settings → Secrets → Actions

| Secret | Valeur |
|--------|--------|
| `VPS_HOST` | xxx.xxx.xxx.xxx |
| `VPS_USER` | deploy |
| `VPS_SSH_KEY` | Contenu de `~/.ssh/id_ed25519` (clé privée) |
| `VERCEL_TOKEN` | Token Vercel |
| `VERCEL_ORG_ID` | Org ID |
| `VERCEL_PROJECT_ID` | Project ID |

### 7.2 Variables

| Variable | Valeur |
|----------|--------|
| `DEV_URL` | https://preview.vercel.app |
| `PROD_URL` | https://monapp.com |
| `DEV_API_URL` | https://api-dev.monapp.com |
| `PROD_API_URL` | https://api.monapp.com |

### 7.3 Protéger main

Settings → Branches → Add rule

```
Branch: main
✅ Require pull request
✅ Require status checks (lint, test-unit, test-e2e, build)
```

---

## Étape 8 : Premier déploiement (2 min)

```bash
# Sur ton Mac
git add .
git commit -m "feat: add VPS deployment configuration"
git push origin main

# → Déploiement automatique DEV
```

Puis pour la production :

```bash
git tag v1.0.0
git push origin v1.0.0

# → Déploiement automatique PROD
```

---

## Commandes utiles sur le VPS

```bash
# Se connecter
ssh deploy@xxx.xxx.xxx.xxx

# Aller dans le projet
cd ~/apps/mon-projet

# Voir les containers
docker compose ps

# Voir les logs
docker compose logs -f api-prod
docker compose logs -f api-dev

# Redémarrer un service
docker compose restart api-prod

# Rebuild et redémarrer
docker compose up -d --build api-prod

# Nettoyer les vieilles images
docker image prune -f

# Voir l'utilisation des ressources
docker stats
```

---

## Ajouter un nouveau projet

```bash
# 1. Cloner le nouveau projet
cd ~/apps
git clone https://github.com/xxx/nouveau-projet.git
cd nouveau-projet

# 2. Configurer le .env
cp .env.vps.example .env
nano .env

# 3. Modifier le docker-compose pour des ports différents
# api-dev: 5003:5000
# api-prod: 5002:5000

# 4. Modifier les domaines dans docker-compose.yml
# api.nouveauprojet.com, api-dev.nouveauprojet.com

# 5. Lancer
docker compose up -d
```

---

## Dépannage

### Le site affiche une erreur 502

```bash
# Vérifier que le container tourne
docker compose ps

# Voir les logs
docker compose logs api-prod

# Redémarrer
docker compose restart api-prod
```

### Certificat SSL non valide

```bash
# Vérifier les logs Traefik
docker compose logs traefik

# Vérifier que le DNS pointe bien vers le VPS
dig api.monapp.com

# Régénérer les certificats
rm traefik/acme.json
touch traefik/acme.json
chmod 600 traefik/acme.json
docker compose restart traefik
```

### Plus de place disque

```bash
# Voir l'espace disque
df -h

# Nettoyer Docker
docker system prune -a --volumes
```

### Le déploiement GitHub échoue

1. Vérifier les secrets (VPS_SSH_KEY doit être la clé privée complète)
2. Vérifier que le user `deploy` peut accéder au repo
3. Vérifier les logs dans GitHub Actions
