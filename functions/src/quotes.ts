import { FinderInput, FreezonePackage, RankedPackage } from "./types";
import { priceFor } from "./lib/pricing";
import { matchScore } from "./lib/match";

// In a real implementation you would fetch from Firestore.
// Here we accept a list so the function stays pure/testable.
export function findBestPackages(input: FinderInput, catalog: FreezonePackage[], limit = 5, now = new Date()): RankedPackage[] {
  const ranked: RankedPackage[] = catalog.map(pkg => {
    const m = matchScore(input, pkg);
    const breakdown = priceFor(pkg, input.activities, input.visas, now);
    // Primary sort: total price, Secondary: distance, Tertiary: base price
    const score = breakdown.total + m.distance * 100; // penalize distance
    return { pkg, breakdown, score, exactMatch: m.exact };
  });

  ranked.sort((a, b) => a.score - b.score || a.breakdown.total - b.breakdown.total);
  return ranked.slice(0, limit);
}
