# Deployment Checklist

- [ ] `firebase login`
- [ ] `cd functions && npm i && npm run build`
- [ ] `firebase deploy --only functions:findBestFreezonePackages`
- [ ] Review/merge Firestore rules for `freezones` (read-only for catalog)
- [ ] Configure Firebase Functions billing location (if needed)
- [ ] Add environment config for any secrets (none required here)
- [ ] Run tests: `npm test`
