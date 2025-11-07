import { matchScore } from "../src/lib/match";
import { FreezonePackage, FinderInput } from "../src/types";

const pkg: FreezonePackage = {
  id: "p1",
  name: "Starter",
  freezone: "RAKEZ",
  emirate: "Ras Al Khaimah",
  basePriceAED: 6500,
  includedActivities: 1,
  includedVisas: 1,
  activityPriceAED: 400,
  visaFeeAED: 2200,
};

describe("match", () => {
  it("is exact when within inclusions", () => {
    const input: FinderInput = { activities: 1, visas: 1 };
    const m = matchScore(input, pkg);
    expect(m.exact).toBe(true);
    expect(m.distance).toBe(0);
  });

  it("adds distance when exceeding inclusions", () => {
    const input: FinderInput = { activities: 3, visas: 2 };
    const m = matchScore(input, pkg);
    expect(m.exact).toBe(false);
    expect(m.distance).toBeGreaterThan(0);
  });
});
