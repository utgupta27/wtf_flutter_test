require('dotenv').config();
const express = require('express');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');

const app = express();
app.use(express.json());

const APP_ACCESS_KEY = process.env.HMS_APP_ACCESS_KEY;
const APP_SECRET = process.env.HMS_APP_SECRET;
const PORT = process.env.PORT || 3000;

if (!APP_ACCESS_KEY || !APP_SECRET) {
  console.error('Missing HMS_APP_ACCESS_KEY or HMS_APP_SECRET in .env');
  process.exit(1);
}

// POST /token — generate a 100ms app token for a participant
app.post('/token', (req, res) => {
  const { roomId, userId, role } = req.body;

  if (!roomId || !userId || !role) {
    return res.status(400).json({ error: 'roomId, userId, and role are required' });
  }

  const issuedAt = Math.floor(Date.now() / 1000);

  const payload = {
    access_key: APP_ACCESS_KEY,
    room_id: roomId,
    user_id: userId,
    role: role,
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
app.get('/health', (_req, res) => res.json({ status: 'ok' }));

app.listen(PORT, () => {
  console.log(`100ms token server running on http://localhost:${PORT}`);
});
