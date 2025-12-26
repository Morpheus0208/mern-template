# 💻 Guide : Configuration VS Code

## Layout souhaité

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           VS CODE                                        │
├───────────────────────────────┬─────────────────────────────────────────┤
│                               │                                          │
│      EXPLORATEUR              │           ÉDITEUR                        │
│                               │                                          │
│   mern-template/              │   ┌─────────────────────────────────┐   │
│   ├── client/                 │   │  Code...                        │   │
│   ├── server/                 │   │                                 │   │
│   ├── ops/                    │   │                                 │   │
│   └── ...                     │   └─────────────────────────────────┘   │
│                               │                                          │
├───────────────────────────────┴─────────────────────────────────────────┤
│                                                                          │
│  TERMINAUX (panneau du bas)                                             │
│                                                                          │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │ 🖥️ Frontend │ ⚙️ Backend │                                       │   │
│  ├──────────────────────────────────────────────────────────────────┤   │
│  │  $ npm run dev                                                   │   │
│  │  VITE v5.0.0 ready in 500ms                                     │   │
│  │  ➜ Local: http://localhost:5173                                 │   │
│  └──────────────────────────────────────────────────────────────────┘   │
│                                                                          │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │ 🤖 Claude Code                                                    │   │
│  ├──────────────────────────────────────────────────────────────────┤   │
│  │  $ claude                                                        │   │
│  │  > _                                                             │   │
│  └──────────────────────────────────────────────────────────────────┘   │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Ouvrir le projet

```bash
cd mern-template
code .
```

---

## Lancer les 3 terminaux

### Méthode rapide (recommandé)

`Cmd+Shift+B` (Mac) ou `Ctrl+Shift+B` (Windows/Linux)

→ Lance la tâche **"🚀 Start All"** qui démarre :
- 🖥️ Frontend Dev
- ⚙️ Backend Dev
- 🤖 Claude Code

### Organiser les terminaux

1. Tu verras 3 onglets de terminaux
2. **Glisse l'onglet "🤖 Claude Code" vers le bas** du panneau
3. Une ligne bleue apparaît → lâche
4. Résultat : 2 groupes (Front+Back en haut, Claude en bas)

---

## Raccourcis utiles

| Action | Mac | Windows/Linux |
|--------|-----|---------------|
| Nouveau terminal | `Cmd+Shift+`` ` | `Ctrl+Shift+`` ` |
| Splitter terminal | `Cmd+\` | `Ctrl+Shift+5` |
| Basculer entre terminaux | `Cmd+Opt+←/→` | `Alt+←/→` |
| Masquer/afficher terminal | `Cmd+J` | `Ctrl+J` |
| Focus terminal | `Ctrl+`` ` | `Ctrl+`` ` |
| Focus éditeur | `Cmd+1` | `Ctrl+1` |
| Lancer tâche build | `Cmd+Shift+B` | `Ctrl+Shift+B` |
| Palette commandes | `Cmd+Shift+P` | `Ctrl+Shift+P` |

---

## Astuces

### Garder le layout

VS Code sauvegarde automatiquement le layout des terminaux. La prochaine fois que tu ouvres le projet, il sera restauré.

### Couleur des terminaux

Pour différencier visuellement :

1. Clic droit sur l'onglet du terminal
2. "Change Color"
3. Choisis une couleur :
   - 🖥️ Frontend → Bleu
   - ⚙️ Backend → Vert
   - 🤖 Claude → Violet

### Icônes des terminaux

1. Clic droit sur l'onglet
2. "Change Icon"
3. Choisis une icône appropriée

---

## Configuration complète settings.json

Si tu veux tout configurer manuellement, ajoute dans `.vscode/settings.json` :

```json
{
  "terminal.integrated.tabs.enabled": true,
  "terminal.integrated.tabs.location": "left",
  "terminal.integrated.defaultProfile.osx": "zsh",
  "terminal.integrated.defaultProfile.linux": "bash",
  "terminal.integrated.splitCwd": "workspaceRoot",
  "terminal.integrated.fontSize": 13,
  "terminal.integrated.lineHeight": 1.2,
  "terminal.integrated.cursorStyle": "line",
  "terminal.integrated.cursorBlinking": true
}
```

---

## Résumé

| Méthode | Difficulté | Automatique |
|---------|------------|-------------|
| `Cmd+Shift+B` (tâches) | ⭐ Facile | Semi-auto |
| Extension Restore Terminals | ⭐⭐ Moyen | ✅ Full auto |
| Manuel | ⭐ Facile | ❌ Manuel |

**Ma recommandation** : Utilise `Cmd+Shift+B` pour lancer les 3 terminaux, puis organise-les une fois manuellement. VS Code se souviendra du layout.
