import { z } from 'zod';

// Schéma utilisateur
export const userSchema = z.object({
  id: z.string().uuid(),
  email: z.string().email('Email invalide'),
  username: z.string().min(3, 'Minimum 3 caractères').max(50, 'Maximum 50 caractères'),
  password: z.string().min(8, 'Minimum 8 caractères'),
  createdAt: z.date(),
  updatedAt: z.date(),
});

// Schéma pour la création (sans id et dates)
export const createUserSchema = userSchema.omit({
  id: true,
  createdAt: true,
  updatedAt: true,
});

// Schéma pour le login
export const loginSchema = z.object({
  email: z.string().email('Email invalide'),
  password: z.string().min(1, 'Mot de passe requis'),
});

// Types inférés
export type User = z.infer<typeof userSchema>;
export type CreateUser = z.infer<typeof createUserSchema>;
export type LoginCredentials = z.infer<typeof loginSchema>;
