# 🌳 Guide : Trunk-Based Development

## Vue d'ensemble

```
┌─────────────────────────────────────────────────────────────────────────┐
│                                                                          │
│  DÉVELOPPEUR                                                             │
│       │                                                                  │
│       │ 1. Créer feature branch                                         │
│       ▼                                                                  │
│  ┌─────────────────────────────────────────┐                           │
│  │         feature/ma-feature              │                           │
│  └────────────────┬────────────────────────┘                           │
│                   │                                                      │
│                   │ 2. Push réguliers                                   │
│                   ▼                                                      │
│  ┌─────────────────────────────────────────┐                           │
│  │        🚀 CI rapide (~2 min)            │                           │
│  │                                          │                           │
│  │  ✅ Lint                                 │                           │
│  │  ✅ Tests Unitaires                      │                           │
│  │  ✅ Build                                │                           │
│  │                                          │                           │
│  │  ❌ Pas de E2E (trop lent)              │                           │
│  └────────────────┬────────────────────────┘                           │
│                   │                                                      │
│                   │ Feedback rapide                                     │
│                   │                                                      │
│                   │ 3. Feature terminée → PR vers main                  │
│                   ▼                                                      │
│  ┌─────────────────────────────────────────┐                           │
│  │        🎭 CI complète (~5 min)          │                           │
│  │                                          │                           │
│  │  ✅ Lint                                 │                           │
│  │  ✅ Tests Unitaires                      │                           │
│  │  ✅ Tests E2E          ← Seulement ici  │                           │
│  │  ✅ Build                                │                           │
│  │  ✅ Commitlint                           │                           │
│  └────────────────┬────────────────────────┘                           │
│                   │                                                      │
│              Si tout ✅                                                  │
│                   │                                                      │
│                   ▼                                                      │
│  ┌─────────────────────────────────────────┐                           │
│  │           Merge PR → main               │                           │
│  └────────────────┬────────────────────────┘                           │
│                   │                                                      │
│                   │ Auto-deploy (CD)                                    │
│                   ▼                                                      │
│  ┌─────────────────────────────────────────┐                           │
│  │           🔵 DEV (Blue)                 │                           │
│  │                                          │                           │
│  │  • Vercel (Frontend Preview)            │                           │
│  │  • Railway (Backend DEV)                │                           │
│  │  • MongoDB Atlas (DEV)                  │                           │
│  └────────────────┬────────────────────────┘                           │
│                   │                                                      │
│                   │ Tests manuels OK → tag                              │
│                   │                                                      │
│                   │ 4. git tag v1.0.0                                   │
│                   ▼                                                      │
│  ┌─────────────────────────────────────────┐                           │
│  │          🟢 PROD (Green)                │                           │
│  │                                          │                           │
│  │  • Vercel (Frontend Production)         │                           │
│  │  • Railway (Backend PROD)               │                           │
│  │  • MongoDB Atlas (PROD)                 │                           │
│  │                                          │                           │
│  │  + Release GitHub créée                 │                           │
│  └─────────────────────────────────────────┘                           │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 📋 Workflow quotidien

### Étape 1 : Créer une branche feature

```bash
# Toujours partir de main à jour
git checkout main
git pull origin main

# Créer une branche avec un nom descriptif
git checkout -b feat/add-login-page

# Conventions de nommage des branches :
# feat/xxx     → Nouvelle fonctionnalité
# fix/xxx      → Correction de bug
# refactor/xxx → Refactorisation
# docs/xxx     → Documentation
```

### Étape 2 : Développer avec des push réguliers

```bash
# Faire des commits atomiques
git add .
git commit -m "feat(auth): add login form component"
git push origin feat/add-login-page

# → CI rapide se lance (lint + unit + build)
# → Feedback en ~2 minutes

# Continuer à développer...
git add .
git commit -m "feat(auth): add form validation"
git push origin feat/add-login-page

# → CI rapide se relance
```

### Étape 3 : Feature terminée → Ouvrir une PR

```bash
# Sur GitHub : créer une Pull Request vers main
# → CI complète se lance (lint + unit + E2E + build)
# → Attend ~5 minutes

# Si E2E échoue, corriger et pusher
git add .
git commit -m "fix(auth): fix form submission"
git push origin feat/add-login-page
```

### Étape 4 : Merger et déployer en DEV

```bash
# Sur GitHub : cliquer "Merge pull request"
# → Déploiement automatique en DEV

# Mettre à jour main localement
git checkout main
git pull origin main

# Supprimer la branche locale
git branch -d feat/add-login-page
```

### Étape 5 : Valider en DEV

```
1. Aller sur l'URL DEV (Vercel Preview)
2. Tester la nouvelle fonctionnalité
3. Vérifier qu'il n'y a pas de régression
4. ✅ OK → Passer à l'étape 6
5. ❌ Problème → Créer un fix et recommencer
```

### Étape 6 : Déployer en PROD

```bash
# Créer un tag de version (versioning sémantique)
git tag v1.0.0
git push origin v1.0.0

# → Déploiement automatique en PROD
# → Release GitHub créée
```

---

## 🏷️ Versioning sémantique

```
v MAJOR . MINOR . PATCH
    │       │       │
    │       │       └── Corrections de bugs (fix)
    │       └────────── Nouvelles fonctionnalités (feat)
    └────────────────── Changements incompatibles (BREAKING)

Exemples :
v1.0.0 → v1.0.1  (bug fix)
v1.0.1 → v1.1.0  (new feature)
v1.1.0 → v2.0.0  (breaking change)
```

---

## 🚨 Hotfix (urgence en production)

```bash
# 1. Créer une branche hotfix
git checkout main
git pull origin main
git checkout -b fix/critical-bug

# 2. Corriger rapidement
git add .
git commit -m "fix(auth): resolve critical login crash"
git push origin fix/critical-bug

# 3. PR + merge rapide (E2E quand même)

# 4. Tag patch immédiat
git checkout main
git pull origin main
git tag v1.0.1
git push origin v1.0.1

# → Déploiement PROD en quelques minutes
```

---

## 🔄 Rollback

### Si la PROD est cassée après un déploiement

```bash
# Option 1 : Redéployer la version précédente
git checkout v1.0.0
git tag v1.0.2-rollback
git push origin v1.0.2-rollback

# Option 2 : Revert le commit problématique
git checkout main
git revert <commit-sha>
git push origin main
# Puis tagger
```

---

## 📊 Résumé des déclencheurs

| Action | CI | E2E | Déploiement |
|--------|----|----|-------------|
| Push sur feature branch | ✅ Rapide | ❌ Non | ❌ Non |
| PR vers main | ✅ Complet | ✅ Oui | ❌ Non |
| Merge sur main | ❌ Non | ❌ Non | 🔵 DEV |
| Tag v* | ❌ Non | ❌ Non | 🟢 PROD |

---

## ✅ Checklist avant merge

- [ ] Tous les tests passent (unit + E2E)
- [ ] Code reviewé
- [ ] Commits bien formatés (conventional commits)
- [ ] Documentation mise à jour si nécessaire

## ✅ Checklist avant tag PROD

- [ ] Testé manuellement en DEV
- [ ] Pas de régression visible
- [ ] Version cohérente (semver)

---

## 📚 Documentation associée

- `HOSTING.md` → Guide de configuration Vercel + Railway + MongoDB Atlas
- `CLAUDE.md` → Instructions pour Claude Code
- `README.md` → Vue d'ensemble du projet
