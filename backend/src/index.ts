import 'dotenv/config';
import express from 'express';
import serviceRouter from './routes/serviceApplication.js';
import { globalLimiter } from './middleware/rateLimiter.js';

const app = express();

// Apply global rate limiter to all routes
app.use(globalLimiter);

app.use(express.json({ limit: '2mb' }));
app.use(express.urlencoded({ extended: true }));

app.get('/health', (_req, res) => {
    res.json({ ok: true, env: 'server', time: new Date().toISOString() });
});

app.use('/api/service', serviceRouter);

const port = Number(process.env.PORT || 3000);
app.listen(port, () => {
    console.log(`WAZEET backend listening on http://localhost:${port}`);
    console.log(`Rate limiting enabled: 100 req/15min global, 10 req/hour for /api/service/application`);
    if (process.env.API_KEY) {
        console.log('API key authentication enabled for service endpoints');
    }
    if (process.env.JWT_SECRET) {
        console.log('JWT authentication available (use jwtAuth middleware if needed)');
    }
});
