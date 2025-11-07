# Quick Start — Find Best Packages

1. Install deps:
   ```bash
   cd functions
   npm i
   ```
2. Build & deploy the callable:
   ```bash
   npm run build
   firebase deploy --only functions:findBestFreezonePackages
   ```
3. (Flutter) Use `FreezoneFinderService.findBestPackages(...)` to call the function.

> For local testing without Firestore, pass `catalog` in the request body.
