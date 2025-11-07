# PR Notes — Find Best Packages

**Scope**
- Adds a new callable Cloud Function `findBestFreezonePackages`.
- Introduces modular pricing, promo, and match utilities.
- Provides minimal seed data and tests.

**Testing**
- `cd functions && npm i && npm run test`
- Ensure Firebase emulators are configured if you plan to call the function locally.

**Follow-ups**
- Replace request-provided `catalog` with Firestore reads.
- Add composite indexes as needed.
- Expand seed data to the full 17 freezones per product requirements.
