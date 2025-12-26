# 🚀 MERN Template

Template complet pour démarrer un projet MERN avec les meilleures pratiques.

## Stack Technique

### Frontend (client/)
- **React 18** avec **Vite**
- **TypeScript**
- **Tailwind CSS** pour le styling
- **shadcn/ui** pour les composants UI
- **Atomic Design** (atoms, molecules, organisms, templates, pages)
- **Zod** pour la validation
- **Playwright** pour les tests E2E
- **ESLint Airbnb** + **Prettier**

### Backend (server/)
- **Express.js**
- **MongoDB** avec **Mongoose**
- **TypeScript**
- **Zod** pour la validation
- **JWT** pour l'authentification
- **ESLint Airbnb** + **Prettier**

### Outils de qualité
- **ls-lint** - Conventions de nommage des fichiers
- **commitlint** - Messages de commit conventionnels
- **husky** - Git hooks automatiques

### CI/CD
- **GitHub Actions** - Pipelines automatisés
- **Docker** - Containerisation du backend
- **CLAUDE.md** - Instructions pour Claude Code / agents IA

### Hébergement
- **Frontend** - Vercel (gratuit)
- **Backend** - VPS Hetzner + Docker (~4€/mois)
- **Database** - MongoDB Atlas (gratuit)
- **SSL** - Let's Encrypt via Traefik (gratuit)

## 📁 Structure du projet

```
mern-template/
├── client/                    # Frontend React
│   ├── src/
│   │   ├── components/
│   │   │   ├── atoms/        # Composants de base (Button, Input...)
│   │   │   ├── molecules/    # Combinaisons d'atomes
│   │   │   ├── organisms/    # Sections complexes
│   │   │   ├── templates/    # Layouts de page
│   │   │   └── pages/        # Pages complètes
│   │   ├── hooks/            # Custom hooks
│   │   ├── services/         # Appels API
│   │   ├── schemas/          # Schémas Zod
│   │   ├── utils/            # Utilitaires
│   │   └── styles/           # CSS global
│   ├── tests/
│   │   └── e2e/              # Tests Playwright
│   └── ...config files
│
├── server/                    # Backend Express
│   ├── src/
│   │   ├── config/           # Configuration (DB...)
│   │   ├── controllers/      # Logique métier
│   │   ├── middlewares/      # Auth, validation, errors
│   │   ├── models/           # Modèles Mongoose
│   │   ├── routes/           # Routes API
│   │   ├── schemas/          # Schémas Zod
│   │   └── utils/            # Utilitaires
│   └── ...config files
│
├── .husky/                    # Git hooks
├── .vscode/                   # Configuration VS Code
│   ├── tasks.json             # Tâches (Cmd+Shift+B)
│   ├── settings.json          # Paramètres éditeur
│   └── extensions.json        # Extensions recommandées
├── ops/                       # Scripts OPS (sécurité, backup, monitoring)
├── .ls-lint.yml               # Config nommage fichiers
├── commitlint.config.js       # Config messages commit
└── package.json               # Workspace root
```

## 🛠️ Installation

```bash
# Cloner le template
git clone https://github.com/ton-compte/mern-template.git mon-projet
cd mon-projet

# Supprimer l'historique git pour repartir à zéro
rm -rf .git
git init

# Installer les dépendances
npm install

# Configurer l'environnement
cp server/.env.example server/.env
# Éditer server/.env avec tes valeurs
```

## 🚀 Démarrage

### Option 1 : VS Code (recommandé)

```bash
cd mern-template
code .
```

Puis appuie sur `Cmd+Shift+B` (Mac) ou `Ctrl+Shift+B` (Windows) pour lancer :
- 🖥️ Frontend Dev (client)
- ⚙️ Backend Dev (server)
- 🤖 Claude Code

Voir `VSCODE-SETUP.md` pour configurer le layout des terminaux.

### Option 2 : Terminal

```bash
# Lancer le client et le serveur en parallèle
npm run dev

# Ou séparément
npm run dev:client    # http://localhost:5173
npm run dev:server    # http://localhost:5000
```

## 📝 Scripts disponibles

| Commande | Description |
|----------|-------------|
| `npm run dev` | Lance client + serveur |
| `npm run dev:client` | Lance uniquement le client |
| `npm run dev:server` | Lance uniquement le serveur |
| `npm run build` | Build de production |
| `npm run lint` | Vérifie le code (ESLint) |
| `npm run lint:fix` | Corrige automatiquement |
| `npm run lint:files` | Vérifie le nommage des fichiers |
| `npm run format` | Formate avec Prettier |
| `npm run format:check` | Vérifie le formatage |
| `npm run check-all` | Lint + fichiers + format |
| `npm run test` | Tests unitaires |
| `npm run test:e2e` | Tests E2E Playwright |

## 📋 Conventions de nommage

### Fichiers

| Type | Convention | Exemple |
|------|------------|---------|
| Composants React | PascalCase | `Button.tsx`, `UserCard.tsx` |
| Hooks | camelCase + use | `useAuth.ts`, `useFetch.ts` |
| Utils | camelCase | `formatDate.ts` |
| Controllers | kebab.controller | `user.controller.ts` |
| Routes | kebab.routes | `user.routes.ts` |
| Models | PascalCase | `User.ts` |
| Schemas | kebab.schema | `user.schema.ts` |
| Tests E2E | kebab.spec | `home.spec.ts` |

### Variables (vérifiées par ESLint)

```typescript
// Variables et fonctions : camelCase
const userName = 'John';
const fetchUserData = () => {};

// Composants React : PascalCase
const UserCard = () => {};

// Constantes : UPPER_CASE
const API_URL = 'https://api.example.com';

// Booléens : préfixe is/has/can/should/will/did
const isLoading = true;
const hasPermission = false;

// Interfaces (backend) : préfixe I
interface IUser {}

// Types et Enums : PascalCase
type ButtonVariant = 'primary' | 'secondary';
enum UserRole { ADMIN, USER }
```

### Messages de commit (Conventional Commits)

```bash
# Format
type(scope): description

# Types disponibles
feat:     # Nouvelle fonctionnalité
fix:      # Correction de bug
docs:     # Documentation
style:    # Formatage
refactor: # Refactorisation
perf:     # Performance
test:     # Tests
build:    # Build system
ci:       # CI/CD
chore:    # Maintenance
revert:   # Revert

# Exemples
feat(auth): add login with Google
fix(cart): resolve quantity update bug
docs(readme): add installation steps
refactor(api): simplify error handling
chore(deps): update React to v18.3
```

## 🔒 Git Hooks (automatiques)

### Pre-commit
- Vérifie le nommage des fichiers (`ls-lint`)
- Vérifie le formatage (`prettier`)

### Commit-msg
- Vérifie le format du message de commit (`commitlint`)

## 🧪 Tests

```bash
# Tests unitaires (Vitest)
npm run test

# Tests E2E (Playwright)
npm run test:e2e

# Installer les navigateurs Playwright (première fois)
npx playwright install
```

## 📦 Créer un nouveau composant Atomic

```bash
# Exemple : créer un nouvel atome "Badge"
mkdir -p client/src/components/atoms/Badge
touch client/src/components/atoms/Badge/Badge.tsx
touch client/src/components/atoms/Badge/index.ts
```

Structure recommandée :
```typescript
// Badge.tsx
interface BadgeProps {
  children: React.ReactNode;
  variant?: 'default' | 'success' | 'warning' | 'error';
}

export const Badge = ({ children, variant = 'default' }: BadgeProps) => {
  // ...
};

// index.ts
export { Badge } from './Badge';
```

## 🔐 API Endpoints

| Méthode | Endpoint | Description | Auth |
|---------|----------|-------------|------|
| POST | `/api/users/register` | Inscription | Non |
| POST | `/api/users/login` | Connexion | Non |
| GET | `/api/users/profile` | Profil utilisateur | Oui |
| GET | `/api/health` | Health check | Non |

## 🎨 shadcn/ui

Les composants UI sont dans `client/src/components/ui/`. Pour ajouter de nouveaux composants :

```bash
cd client
npx shadcn@latest add [component-name]

# Exemples
npx shadcn@latest add dialog
npx shadcn@latest add dropdown-menu
npx shadcn@latest add form
```

Composants inclus par défaut :
- `Button` - Boutons avec variantes
- `Input` - Champs de saisie
- `Label` - Labels pour formulaires
- `Card` - Cartes avec header, content, footer

Documentation : https://ui.shadcn.com/docs/components

## 📋 Utiliser ce template pour un nouveau projet

```bash
# 1. Cloner
git clone https://github.com/ton-compte/mern-template.git nom-du-projet

# 2. Nettoyer l'historique
cd nom-du-projet
rm -rf .git
git init

# 3. Installer
npm install

# 4. Configurer
cp server/.env.example server/.env

# 5. Personnaliser le package.json
# Modifier le "name" dans les 3 package.json

# 6. Premier commit
git add .
git commit -m "feat: initial project setup"

# 7. Commencer à coder !
npm run dev
```

## 🤖 CI/CD GitHub Actions

### Workflows

| Événement | CI | Déploiement |
|-----------|----|----|
| Push sur feature branch | Lint + Unit + Build | ❌ |
| PR vers main | Lint + Unit + **E2E** + Build | ❌ |
| Merge sur main | ❌ | 🔵 DEV (Vercel + VPS) |
| Tag v* | ❌ | 🟢 PROD (Vercel + VPS) |

### Déployer en production

```bash
git tag v1.0.0
git push origin v1.0.0
```

### Configuration requise

Voir `VPS-SETUP.md` pour le guide complet de configuration :
- VPS Hetzner
- MongoDB Atlas  
- Vercel
- GitHub Secrets

## 🤖 Claude Code / Agents IA

Le fichier `CLAUDE.md` contient toutes les instructions pour travailler sur ce projet avec Claude Code ou d'autres agents IA :
- Structure du projet
- Conventions de code
- Commandes disponibles
- Tâches courantes

Un symlink `AGENTS.md` pointe vers `CLAUDE.md` pour compatibilité avec d'autres outils.

## 📚 Documentation

| Fichier | Description |
|---------|-------------|
| `README.md` | Vue d'ensemble du projet |
| `CLAUDE.md` | Instructions pour Claude Code / IA |
| `WORKFLOW.md` | Guide Trunk-Based Development |
| `VPS-SETUP.md` | Configuration VPS Hetzner |
| `VSCODE-SETUP.md` | Configuration VS Code + terminaux |
| `ops/OPS-GUIDE.md` | Sécurité, backup, monitoring |

## 📄 License

MIT
