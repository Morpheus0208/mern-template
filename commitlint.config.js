// commitlint.config.js
// Documentation: https://commitlint.js.org/

module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    // Type de commit obligatoire
    'type-enum': [
      2,
      'always',
      [
        'feat',     // Nouvelle fonctionnalité
        'fix',      // Correction de bug
        'docs',     // Documentation
        'style',    // Formatage (pas de changement de code)
        'refactor', // Refactorisation
        'perf',     // Amélioration des performances
        'test',     // Ajout ou modification de tests
        'build',    // Changements du système de build
        'ci',       // Changements CI/CD
        'chore',    // Maintenance (dépendances, config...)
        'revert',   // Revert d'un commit précédent
      ],
    ],
    // Type en minuscules
    'type-case': [2, 'always', 'lower-case'],
    // Type non vide
    'type-empty': [2, 'never'],
    // Scope en minuscules (optionnel)
    'scope-case': [2, 'always', 'lower-case'],
    // Sujet non vide
    'subject-empty': [2, 'never'],
    // Sujet sans point final
    'subject-full-stop': [2, 'never', '.'],
    // Sujet en minuscules
    'subject-case': [2, 'always', 'lower-case'],
    // Longueur max du header
    'header-max-length': [2, 'always', 100],
  },
};
