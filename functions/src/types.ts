/**
 * Shared types for Freezone package selection.
 */

export type Emirate = "Dubai" | "Abu Dhabi" | "Sharjah" | "Ajman" | "Ras Al Khaimah" | "Umm Al Quwain" | "Fujairah";

export interface Promo {
  id: string;
  kind: "flat" | "percent";
  amount: number; // flat AED or percent [0-100]
  startDate: string; // ISO date
  endDate: string;   // ISO date
}

export interface FreezonePackage {
  id: string;
  name: string;
  freezone: string;
  emirate: Emirate;
  basePriceAED: number;
  includedActivities: number;
  includedVisas: number;
  activityPriceAED: number;
  visaFeeAED: number;
  emirateSurchargeAED?: number;
  processingFeeAED?: number;
  vatPercent?: number; // default 5
  tags?: string[];
  promos?: Promo[];
  // Optional constraints
  minTenureYears?: number;
  maxTenureYears?: number;
}

export interface FinderInput {
  activities: number;
  visas: number;
  tenureYears?: number;
  preferredEmirates?: Emirate[];
  mustHaveTags?: string[];
}

export interface PriceBreakdown {
  base: number;
  extraActivities: number;
  visas: number;
  emirateSurcharge: number;
  processing: number;
  promo: number;
  vat: number;
  total: number;
  subtotal: number;
}

export interface RankedPackage {
  pkg: FreezonePackage;
  breakdown: PriceBreakdown;
  score: number; // lower is better
  exactMatch: boolean;
}
