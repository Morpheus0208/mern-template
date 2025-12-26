import { Router } from 'express';
import { register, login, getProfile } from '../controllers/user.controller';
import { validate } from '../middlewares/validate';
import { auth } from '../middlewares/auth';
import { createUserSchema, loginSchema } from '../schemas/user.schema';

const router = Router();

router.post('/register', validate(createUserSchema), register);
router.post('/login', validate(loginSchema), login);
router.get('/profile', auth, getProfile);

export { router as userRoutes };
