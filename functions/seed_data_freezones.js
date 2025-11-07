// Minimal seed data for quick testing (local use / script / import to Firestore as needed)
module.exports = [
  {
    id: "ifza-basic",
    name: "IFZA Basic",
    freezone: "IFZA",
    emirate: "Dubai",
    basePriceAED: 11500,
    includedActivities: 1,
    includedVisas: 0,
    activityPriceAED: 600,
    visaFeeAED: 3000,
    processingFeeAED: 500,
    emirateSurchargeAED: 0,
    vatPercent: 5,
    tags: ["popular"],
    promos: [
      { id: "new-year", kind: "percent", amount: 10, startDate: "2025-01-01", endDate: "2025-03-31" }
    ]
  },
  {
    id: "rakez-starter",
    name: "RAKEZ Starter",
    freezone: "RAKEZ",
    emirate: "Ras Al Khaimah",
    basePriceAED: 6500,
    includedActivities: 1,
    includedVisas: 1,
    activityPriceAED: 400,
    visaFeeAED: 2200,
    processingFeeAED: 250,
    emirateSurchargeAED: 0,
    vatPercent: 5,
    tags: ["budget"]
  },
  {
    id: "spc-ultimate",
    name: "SPC Ultimate",
    freezone: "SPC",
    emirate: "Sharjah",
    basePriceAED: 14000,
    includedActivities: 3,
    includedVisas: 2,
    activityPriceAED: 500,
    visaFeeAED: 2600,
    processingFeeAED: 400,
    emirateSurchargeAED: 0,
    vatPercent: 5,
    tags: ["media","publishing"]
  }
];
