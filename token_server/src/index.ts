import 'dotenv/config';
import express, { type Request, type Response } from 'express';
import jwt from 'jsonwebtoken';
import { v4 as uuidv4 } from 'uuid';

const app = express();
app.use(express.json());

const APP_ACCESS_KEY = process.env['HMS_APP_ACCESS_KEY'];
const APP_SECRET = process.env['HMS_APP_SECRET'];
const PORT = process.env['PORT'] ?? '3000';

if (!APP_ACCESS_KEY || !APP_SECRET) {
  console.error('Missing HMS_APP_ACCESS_KEY or HMS_APP_SECRET in .env');
  process.exit(1);
}

interface TokenRequestBody {
  roomId: string;
  userId: string;
  role: string;
}

interface TokenPayload {
  access_key: string;
  room_id: string;
  user_id: string;
  role: string;
  type: 'app';
  version: 2;
  iat: number;
  nbf: number;
}

// POST /token — generate a 100ms app token for a room participant
app.post('/token', (req: Request<object, object, TokenRequestBody>, res: Response) => {
  const { roomId, userId, role } = req.body;

  if (!roomId || !userId || !role) {
    res.status(400).json({ error: 'roomId, userId, and role are required' });
    return;
  }

  const issuedAt = Math.floor(Date.now() / 1000);

  const payload: TokenPayload = {
    access_key: APP_ACCESS_KEY,
    room_id: roomId,
    user_id: userId,
    role,
    type: 'app',
    version: 2,
    iat: issuedAt,
    nbf: issuedAt,
  };

  const token = jwt.sign(payload, APP_SECRET, {
    algorithm: 'HS256',
    expiresIn: '24h',
    jwtid: uuidv4(),
  });

  res.json({ token });
});

// GET /health
app.get('/health', (_req: Request, res: Response) => {
  res.json({ status: 'ok' });
});

app.listen(Number(PORT), () => {
  console.log(`100ms token server running on http://localhost:${PORT}`);
});
