import { priceFor } from "../src/lib/pricing";
import { FreezonePackage } from "../src/types";

describe("pricing", () => {
  const pkg: FreezonePackage = {
    id: "demo",
    name: "Demo Package",
    freezone: "IFZA",
    emirate: "Dubai",
    basePriceAED: 10000,
    includedActivities: 1,
    includedVisas: 0,
    activityPriceAED: 500,
    visaFeeAED: 2500,
    processingFeeAED: 300,
    emirateSurchargeAED: 200,
    vatPercent: 5,
  };

  it("computes totals with VAT", () => {
    const b = priceFor(pkg, 2, 1, new Date("2025-01-01"));
    expect(b.base).toBe(10000);
    expect(b.extraActivities).toBe(500);
    expect(b.visas).toBe(2500);
    expect(b.processing).toBe(300);
    expect(b.emirateSurcharge).toBe(200);
    // subtotal = 10000 + 500 + 2500 + 300 + 200 = 13500
    // vat = 5% = 675, total = 14175
    expect(b.subtotal).toBe(13500);
    expect(b.vat).toBe(675);
    expect(b.total).toBe(14175);
  });
});
