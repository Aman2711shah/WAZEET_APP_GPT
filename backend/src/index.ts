import 'dotenv/config';
import express from 'express';
import serviceRouter from './routes/serviceApplication.js';

const app = express();

app.use(express.json({ limit: '2mb' }));
app.use(express.urlencoded({ extended: true }));

app.get('/health', (_req, res) => {
    res.json({ ok: true, env: 'server', time: new Date().toISOString() });
});

app.use('/api/service', serviceRouter);

const port = Number(process.env.PORT || 3000);
app.listen(port, () => {
    console.log(`WAZEET backend listening on http://localhost:${port}`);
});
