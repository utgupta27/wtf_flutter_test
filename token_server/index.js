require('dotenv').config();
const express = require('express');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');

const app = express();
app.use(express.json());
app.use((_req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET,POST,PATCH,OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Content-Type');
  if (_req.method === 'OPTIONS') {
    return res.sendStatus(204);
  }
  next();
});

const APP_ACCESS_KEY = process.env.HMS_APP_ACCESS_KEY;
const APP_SECRET = process.env.HMS_APP_SECRET;
const PORT = process.env.PORT || 3000;
const HMS_ENABLED = Boolean(APP_ACCESS_KEY && APP_SECRET);

// In-memory sync store (demo / local dev)
const messages = new Map();
const callRequests = new Map();
const sessionLogs = new Map();
const roomsByRequest = new Map();
/** @type {Map<string, { chatId: string, userId: string, isTyping: boolean, at: string, expiresAt: number }>} */
const typingSessions = new Map();

const MESSAGE_STATUSES = ['sending', 'sent', 'read'];
const STATUS_RANK = { sending: 0, sent: 1, read: 2 };
const TYPING_TTL_MS = 3000;

function mergeMessageStatus(current, incoming) {
  const a = STATUS_RANK[current] ?? 0;
  const b = STATUS_RANK[incoming] ?? 0;
  return a >= b ? current : incoming;
}

function canTransitionStatus(from, to) {
  if (from === to) {
    return true;
  }
  if (from === 'sending' && to === 'sent') {
    return true;
  }
  if (from === 'sent' && to === 'read') {
    return true;
  }
  if (from === 'sending' && to === 'read') {
    return true;
  }
  return false;
}

function pruneTypingSessions() {
  const now = Date.now();
  for (const [key, session] of typingSessions.entries()) {
    if (session.expiresAt <= now || !session.isTyping) {
      typingSessions.delete(key);
    }
  }
}
const CALL_STATUSES = ['pending', 'approved', 'declined', 'cancelled'];

function parseMessage(body) {
  const required = ['id', 'chatId', 'senderId', 'receiverId', 'text', 'createdAt'];
  for (const key of required) {
    if (!body[key]) {
      return { error: `Missing field: ${key}` };
    }
  }
  const status =
    typeof body.status === 'string'
      ? body.status
      : MESSAGE_STATUSES[body.status] || 'sent';
  if (!MESSAGE_STATUSES.includes(status)) {
    return { error: 'Invalid status' };
  }
  return {
    id: String(body.id),
    chatId: String(body.chatId),
    senderId: String(body.senderId),
    receiverId: String(body.receiverId),
    text: String(body.text),
    createdAt: String(body.createdAt),
    status,
    updatedAt: body.updatedAt || body.createdAt,
  };
}

function parseCallRequest(body) {
  const required = [
    'id',
    'memberId',
    'trainerId',
    'requestedAt',
    'scheduledFor',
    'note',
  ];
  for (const key of required) {
    if (body[key] === undefined || body[key] === null) {
      return { error: `Missing field: ${key}` };
    }
  }
  const status =
    typeof body.status === 'string'
      ? body.status
      : CALL_STATUSES[body.status] || 'pending';
  return {
    id: String(body.id),
    memberId: String(body.memberId),
    trainerId: String(body.trainerId),
    requestedAt: String(body.requestedAt),
    scheduledFor: String(body.scheduledFor),
    note: String(body.note),
    status,
    declineReason: body.declineReason || null,
    updatedAt: body.updatedAt || body.requestedAt,
  };
}

function hasApprovedConflict(trainerId, scheduledFor, excludeId) {
  for (const req of callRequests.values()) {
    if (req.id === excludeId) {
      continue;
    }
    if (
      req.trainerId === trainerId &&
      req.scheduledFor === scheduledFor &&
      req.status === 'approved'
    ) {
      return true;
    }
  }
  return false;
}

function signToken(roomId, userId, role) {
  const issuedAt = Math.floor(Date.now() / 1000);
  const payload = {
    access_key: APP_ACCESS_KEY,
    room_id: roomId,
    user_id: userId,
    role,
    type: 'app',
    version: 2,
    iat: issuedAt,
    nbf: issuedAt,
  };
  return jwt.sign(payload, APP_SECRET, {
    algorithm: 'HS256',
    expiresIn: '24h',
    jwtid: uuidv4(),
  });
}

function issueToken(roomId, userId, role, res) {
  if (!HMS_ENABLED) {
    return res.status(503).json({
      error: 'HMS credentials not configured. Set HMS_APP_ACCESS_KEY and HMS_APP_SECRET.',
    });
  }
  if (!roomId || !userId || !role) {
    return res.status(400).json({ error: 'roomId, userId, and role are required' });
  }
  const token = signToken(roomId, userId, role);
  return res.json({ token });
}

// --- Token ---
app.post('/token', (req, res) => {
  const { roomId, userId, role } = req.body;
  return issueToken(roomId, userId, role, res);
});

app.get('/token', (req, res) => {
  const { roomId, userId, role } = req.query;
  return issueToken(roomId, userId, role, res);
});

// --- Messages ---
app.post('/sync/messages', (req, res) => {
  const parsed = parseMessage(req.body);
  if (parsed.error) {
    return res.status(400).json({ error: parsed.error });
  }
  const existing = messages.get(parsed.id);
  const now = new Date().toISOString();
  let merged;
  if (existing) {
    merged = {
      ...existing,
      ...parsed,
      status: mergeMessageStatus(existing.status, parsed.status),
      updatedAt: now,
    };
  } else {
    merged = {
      ...parsed,
      status: 'sent',
      updatedAt: now,
    };
  }
  messages.set(parsed.id, merged);
  return res.status(existing ? 200 : 201).json(merged);
});

app.get('/sync/messages', (req, res) => {
  const { chatId, since } = req.query;
  if (!chatId) {
    return res.status(400).json({ error: 'chatId is required' });
  }
  const sinceMs = since ? Date.parse(since) : 0;
  const list = [...messages.values()]
    .filter((m) => m.chatId === chatId)
    .filter((m) => Date.parse(m.updatedAt || m.createdAt) >= sinceMs)
    .sort((a, b) => Date.parse(a.createdAt) - Date.parse(b.createdAt));
  return res.json({ messages: list });
});

app.patch('/sync/messages/:id/status', (req, res) => {
  const msg = messages.get(req.params.id);
  if (!msg) {
    return res.status(404).json({ error: 'Message not found' });
  }
  const status = req.body.status;
  if (!MESSAGE_STATUSES.includes(status)) {
    return res.status(400).json({ error: 'Invalid status' });
  }
  if (!canTransitionStatus(msg.status, status)) {
    return res.status(400).json({
      error: `Invalid status transition: ${msg.status} -> ${status}`,
    });
  }
  const updated = {
    ...msg,
    status,
    updatedAt: new Date().toISOString(),
  };
  messages.set(req.params.id, updated);
  return res.json(updated);
});

// --- Typing presence (ephemeral) ---
app.post('/sync/typing', (req, res) => {
  const { chatId, userId, isTyping } = req.body;
  if (!chatId || !userId) {
    return res.status(400).json({ error: 'chatId and userId are required' });
  }
  const key = `${chatId}:${userId}`;
  const at = new Date().toISOString();
  if (isTyping) {
    typingSessions.set(key, {
      chatId: String(chatId),
      userId: String(userId),
      isTyping: true,
      at,
      expiresAt: Date.now() + TYPING_TTL_MS,
    });
  } else {
    typingSessions.delete(key);
  }
  pruneTypingSessions();
  return res.status(200).json({ chatId, userId, isTyping: Boolean(isTyping), at });
});

app.get('/sync/typing', (req, res) => {
  const { chatId } = req.query;
  if (!chatId) {
    return res.status(400).json({ error: 'chatId is required' });
  }
  pruneTypingSessions();
  const now = Date.now();
  const typing = [...typingSessions.values()].filter(
    (s) => s.chatId === chatId && s.isTyping && s.expiresAt > now,
  );
  return res.json({ typing });
});

// --- Call requests ---
app.post('/sync/call-requests', (req, res) => {
  const parsed = parseCallRequest(req.body);
  if (parsed.error) {
    return res.status(400).json({ error: parsed.error });
  }
  if (
    parsed.status === 'approved' &&
    hasApprovedConflict(parsed.trainerId, parsed.scheduledFor, parsed.id)
  ) {
    return res.status(409).json({ error: 'Slot already approved for this trainer' });
  }
  const existing = callRequests.get(parsed.id);
  const merged = existing
    ? { ...existing, ...parsed, updatedAt: new Date().toISOString() }
    : parsed;
  callRequests.set(parsed.id, merged);
  return res.status(201).json(merged);
});

app.get('/sync/call-requests', (req, res) => {
  const { trainerId, memberId } = req.query;
  let list = [...callRequests.values()];
  if (trainerId) {
    list = list.filter((r) => r.trainerId === trainerId);
  }
  if (memberId) {
    list = list.filter((r) => r.memberId === memberId);
  }
  list.sort(
    (a, b) => Date.parse(b.requestedAt) - Date.parse(a.requestedAt),
  );
  return res.json({ callRequests: list });
});

app.patch('/sync/call-requests/:id', (req, res) => {
  const existing = callRequests.get(req.params.id);
  if (!existing) {
    return res.status(404).json({ error: 'CallRequest not found' });
  }
  const status = req.body.status || existing.status;
  if (!CALL_STATUSES.includes(status)) {
    return res.status(400).json({ error: 'Invalid status' });
  }
  if (
    status === 'approved' &&
    hasApprovedConflict(existing.trainerId, existing.scheduledFor, existing.id)
  ) {
    return res.status(409).json({ error: 'Slot already approved for this trainer' });
  }
  const updated = {
    ...existing,
    status,
    declineReason: req.body.declineReason ?? existing.declineReason,
    updatedAt: new Date().toISOString(),
  };
  callRequests.set(req.params.id, updated);

  if (status === 'approved') {
    const roomMeta = {
      id: `room-meta-${req.params.id}`,
      callRequestId: req.params.id,
      hmsRoomId: `room-${req.params.id}`,
      hmsRoleMember: 'member',
      hmsRoleTrainer: 'trainer',
    };
    roomsByRequest.set(req.params.id, roomMeta);
  }

  return res.json(updated);
});

// --- Session logs ---
app.post('/sync/session-logs', (req, res) => {
  const body = req.body;
  if (!body.id || !body.memberId || !body.trainerId) {
    return res.status(400).json({ error: 'id, memberId, trainerId required' });
  }
  const existing = sessionLogs.get(body.id);
  const merged = existing ? { ...existing, ...body } : body;
  sessionLogs.set(body.id, merged);
  return res.status(201).json(merged);
});

app.get('/sync/session-logs', (req, res) => {
  const { memberId, trainerId } = req.query;
  let list = [...sessionLogs.values()];
  if (memberId) {
    list = list.filter((l) => l.memberId === memberId);
  }
  if (trainerId) {
    list = list.filter((l) => l.trainerId === trainerId);
  }
  list.sort((a, b) => Date.parse(b.startedAt) - Date.parse(a.startedAt));
  return res.json({ sessionLogs: list });
});

// --- Rooms ---
app.post('/rooms', (req, res) => {
  const { callRequestId } = req.body;
  if (!callRequestId) {
    return res.status(400).json({ error: 'callRequestId required' });
  }
  const roomMeta = {
    id: `room-meta-${callRequestId}`,
    callRequestId,
    hmsRoomId: `room-${callRequestId}`,
    hmsRoleMember: 'member',
    hmsRoleTrainer: 'trainer',
  };
  roomsByRequest.set(callRequestId, roomMeta);
  return res.status(201).json(roomMeta);
});

app.get('/rooms/by-request/:callRequestId', (req, res) => {
  const room = roomsByRequest.get(req.params.callRequestId);
  if (!room) {
    return res.status(404).json({ error: 'Room not found' });
  }
  return res.json(room);
});

app.get('/health', (_req, res) =>
  res.json({
    status: 'ok',
    hms: HMS_ENABLED,
    messages: messages.size,
    typingSessions: typingSessions.size,
  }),
);

app.listen(PORT, () => {
  console.log(`WTF sync + token server on http://localhost:${PORT}`);
  if (!HMS_ENABLED) {
    console.warn('HMS disabled — sync API works; POST /token returns 503 until .env is set.');
  }
});
