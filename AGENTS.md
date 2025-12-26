# CLAUDE.md - Instructions pour Claude Code

Ce fichier fournit le contexte et les instructions pour travailler sur ce projet avec Claude Code.

## 📁 Structure du projet

```
mern-template/
├── client/                 # Frontend React + Vite + TypeScript
│   ├── src/
│   │   ├── components/
│   │   │   ├── atoms/      # Composants de base (custom)
│   │   │   ├── molecules/  # Combinaisons d'atomes
│   │   │   ├── organisms/  # Sections complexes
│   │   │   ├── templates/  # Layouts de page
│   │   │   ├── pages/      # Pages complètes
│   │   │   └── ui/         # Composants shadcn/ui
│   │   ├── hooks/          # Custom React hooks
│   │   ├── lib/            # Utilitaires (cn, etc.)
│   │   ├── services/       # Appels API (axios)
│   │   ├── schemas/        # Schémas Zod
│   │   └── styles/         # CSS global + Tailwind
│   └── tests/e2e/          # Tests Playwright
│
├── server/                 # Backend Express + MongoDB
│   └── src/
│       ├── config/         # Configuration (DB, etc.)
│       ├── controllers/    # Logique métier
│       ├── middlewares/    # Auth, validation, errors
│       ├── models/         # Modèles Mongoose
│       ├── routes/         # Routes API
│       ├── schemas/        # Schémas Zod
│       └── utils/          # Utilitaires
│
├── .github/workflows/      # CI/CD GitHub Actions
└── .husky/                 # Git hooks
```

## 🛠️ Commandes principales

```bash
# Développement
npm run dev              # Lance client (port 3000) + server (port 5000)
npm run dev:client       # Lance uniquement le client
npm run dev:server       # Lance uniquement le serveur

# Qualité du code
npm run lint             # ESLint (client + server)
npm run lint:fix         # ESLint avec auto-fix
npm run lint:files       # Vérifie le nommage des fichiers (ls-lint)
npm run format           # Prettier - formate le code
npm run format:check     # Prettier - vérifie sans modifier
npm run check-all        # Lint + lint:files + format:check

# Tests
npm run test             # Tests unitaires (Vitest)
npm run test:e2e         # Tests E2E (Playwright)

# Build
npm run build            # Build client + server
```

## 📋 Conventions de code

### Nommage des fichiers

| Type | Convention | Exemple |
|------|------------|---------|
| Composants React | PascalCase | `Button.tsx`, `UserCard.tsx` |
| Hooks | camelCase + use | `useAuth.ts`, `useFetch.ts` |
| Utils/lib | camelCase | `formatDate.ts`, `utils.ts` |
| Controllers | kebab.controller | `user.controller.ts` |
| Routes | kebab.routes | `user.routes.ts` |
| Models | PascalCase | `User.ts` |
| Schemas | kebab.schema | `user.schema.ts` |
| Tests E2E | kebab.spec | `home.spec.ts` |

### Messages de commit (Conventional Commits)

```bash
# Format
type(scope): description

# Types
feat:     # Nouvelle fonctionnalité
fix:      # Correction de bug
docs:     # Documentation
style:    # Formatage (pas de changement de code)
refactor: # Refactorisation
perf:     # Performance
test:     # Tests
build:    # Build system
ci:       # CI/CD
chore:    # Maintenance

# Exemples
feat(auth): add Google OAuth login
fix(cart): resolve quantity update bug
docs(readme): add installation steps
```

### Variables TypeScript

```typescript
// Variables et fonctions : camelCase
const userName = 'John';
const fetchUserData = () => {};

// Composants React : PascalCase
const UserCard = () => {};

// Constantes : UPPER_CASE
const API_URL = 'https://api.example.com';

// Booléens : préfixe is/has/can
const isLoading = true;
const hasPermission = false;

// Interfaces backend : préfixe I
interface IUser {}

// Types : PascalCase
type ButtonVariant = 'primary' | 'secondary';
```

## 🎨 UI avec shadcn/ui

Les composants UI sont dans `client/src/components/ui/`.

### Ajouter un composant shadcn

```bash
cd client
npx shadcn@latest add button
npx shadcn@latest add dialog
npx shadcn@latest add form
```

### Utilisation

```tsx
import { Button } from '@ui/button';
import { Input } from '@ui/input';
import { Card, CardHeader, CardTitle, CardContent } from '@ui/card';

const MyComponent = () => (
  <Card>
    <CardHeader>
      <CardTitle>Titre</CardTitle>
    </CardHeader>
    <CardContent>
      <Input placeholder="Email" />
      <Button>Envoyer</Button>
    </CardContent>
  </Card>
);
```

## 🔐 API Backend

### Endpoints existants

| Méthode | Endpoint | Description | Auth |
|---------|----------|-------------|------|
| POST | `/api/users/register` | Inscription | Non |
| POST | `/api/users/login` | Connexion | Non |
| GET | `/api/users/profile` | Profil utilisateur | Oui |
| GET | `/api/health` | Health check | Non |

### Créer une nouvelle route

1. **Schema** (validation) : `server/src/schemas/[name].schema.ts`
2. **Model** (MongoDB) : `server/src/models/[Name].ts`
3. **Controller** (logique) : `server/src/controllers/[name].controller.ts`
4. **Routes** (endpoints) : `server/src/routes/[name].routes.ts`
5. **Enregistrer** dans `server/src/index.ts`

## 🧪 Tests

### Tests unitaires (Vitest)

```typescript
// client/src/components/Button.test.tsx
import { render, screen } from '@testing-library/react';
import { Button } from './Button';

describe('Button', () => {
  it('renders correctly', () => {
    render(<Button>Click me</Button>);
    expect(screen.getByText('Click me')).toBeInTheDocument();
  });
});
```

### Tests E2E (Playwright)

```typescript
// client/tests/e2e/home.spec.ts
import { test, expect } from '@playwright/test';

test('homepage loads', async ({ page }) => {
  await page.goto('/');
  await expect(page.locator('h1')).toBeVisible();
});
```

## 🚀 CI/CD (Trunk-Based Development)

### Workflow

```
feature branch → PR → CI (tests) → merge main → 🔵 DEV → tag v* → 🟢 PROD
```

### Commandes quotidiennes

```bash
# 1. Nouvelle feature
git checkout main && git pull
git checkout -b feat/ma-feature

# 2. Développer et committer
git add .
git commit -m "feat(scope): description"

# 3. Pousser et créer PR
git push origin feat/ma-feature
# → CI vérifie automatiquement

# 4. Après merge, déployer en prod
git checkout main && git pull
git tag v1.0.0
git push origin v1.0.0
```

### Environnements

| Env | URL | Déclencheur |
|-----|-----|-------------|
| 🔵 DEV | dev.monapp.com | Merge sur main |
| 🟢 PROD | monapp.com | Tag v* |

Voir `WORKFLOW.md` pour le guide complet.

## 📝 Tâches courantes pour Claude Code

### Créer un nouveau composant React

```bash
# 1. Créer le dossier et fichiers
mkdir -p client/src/components/atoms/MonComposant
touch client/src/components/atoms/MonComposant/MonComposant.tsx
touch client/src/components/atoms/MonComposant/index.ts

# 2. Implémenter le composant avec TypeScript + Tailwind
# 3. Exporter depuis index.ts
```

### Créer une nouvelle route API

```bash
# 1. Créer le schema Zod
touch server/src/schemas/[name].schema.ts

# 2. Créer le model Mongoose
touch server/src/models/[Name].ts

# 3. Créer le controller
touch server/src/controllers/[name].controller.ts

# 4. Créer les routes
touch server/src/routes/[name].routes.ts

# 5. Enregistrer dans index.ts
```

### Ajouter un hook personnalisé

```bash
touch client/src/hooks/use[Name].ts
```

## ⚠️ Points d'attention

1. **Toujours** utiliser les alias d'import (`@/`, `@ui/`, `@hooks/`, etc.)
2. **Toujours** valider les données avec Zod (client ET server)
3. **Ne jamais** commit sans vérifier `npm run check-all`
4. **Respecter** les conventions de nommage (ls-lint bloque sinon)
5. **Utiliser** les composants shadcn/ui pour l'UI
6. **Documenter** les nouvelles fonctionnalités dans ce fichier

## 🔗 Ressources

- [shadcn/ui](https://ui.shadcn.com/)
- [Tailwind CSS](https://tailwindcss.com/docs)
- [Zod](https://zod.dev/)
- [Playwright](https://playwright.dev/)
- [Conventional Commits](https://www.conventionalcommits.org/)
