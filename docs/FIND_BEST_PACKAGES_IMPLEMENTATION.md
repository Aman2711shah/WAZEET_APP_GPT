# Find Best Packages — Implementation Overview

This module provides a deterministic, testable way to rank freezone packages based on user inputs (activities, visas, tenure, preferences).

- **Core algorithm**: `findBestPackages(input, catalog)` returns ranked results with price breakdowns.
- **Pricing**: `pricing.ts` computes subtotal, promo, VAT, and total.
- **Matching**: `match.ts` computes an `exact` boolean and a `distance` penalty for near-misses.
- **Promos**: `promo.ts` supports `flat` and `percent` discounts within active date ranges.

## Usage

```ts
import { findBestPackages } from "./quotes";
import { FinderInput, FreezonePackage } from "./types";
import seed from "../functions/seed_data_freezones";

const input: FinderInput = { activities: 2, visas: 1, preferredEmirates: ["Dubai"] };
const results = findBestPackages(input, seed as FreezonePackage[]);
console.log(results[0].breakdown.total);
```

## Firebase Function

Callable name: **`findBestFreezonePackages`**  
Request: `{ input: FinderInput, catalog?: FreezonePackage[] }`  
Response: `{ results: RankedPackage[] }`
