import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/service_item.dart';

final servicesProvider = Provider<List<ServiceCategory>>((ref) {
  return _loadServices();
});

List<ServiceCategory> _loadServices() {
  return [
    // Visa and Immigration Services
    ServiceCategory(
      id: 'visa',
      name: 'Visa & Immigration',
      icon: '✈️',
      color: '0xFF6D5DF6',
      serviceTypes: [
        ServiceType(
          id: 'employment',
          name: 'Employment Visa',
          categoryId: 'visa',
          subServices: [
            SubService(
              id: 'employment_issuance',
              name: 'Issuance',
              serviceTypeId: 'employment',
              premium: PricingTier(cost: 4000, timeline: '5-6 days'),
              standard: PricingTier(cost: 3300, timeline: '6-8 days'),
              documentRequirements: [
                'Passport',
                'Photo',
                'Offer letter',
                'License copy',
              ],
            ),
            SubService(
              id: 'employment_renewal',
              name: 'Renewal',
              serviceTypeId: 'employment',
              premium: PricingTier(cost: 3500, timeline: '4-5 days'),
              standard: PricingTier(cost: 2900, timeline: '5-6 days'),
              documentRequirements: ['Passport', 'Visa', 'Emirates ID'],
            ),
            SubService(
              id: 'employment_cancel',
              name: 'Cancellation',
              serviceTypeId: 'employment',
              premium: PricingTier(cost: 1350, timeline: '2 days'),
              standard: PricingTier(cost: 1100, timeline: '2-3 days'),
              documentRequirements: ['Passport', 'Visa', 'Cancellation form'],
            ),
          ],
        ),
        ServiceType(
          id: 'dependent',
          name: 'Dependent Visa',
          categoryId: 'visa',
          subServices: [
            SubService(
              id: 'dependent_issuance',
              name: 'Issuance',
              serviceTypeId: 'dependent',
              premium: PricingTier(cost: 3500, timeline: '4-5 days'),
              standard: PricingTier(cost: 2900, timeline: '5-7 days'),
              documentRequirements: [
                'Sponsor\'s passport',
                'Visa',
                'Birth/marriage certificate',
                'Tenancy',
              ],
            ),
            SubService(
              id: 'dependent_renewal',
              name: 'Renewal',
              serviceTypeId: 'dependent',
              premium: PricingTier(cost: 3000, timeline: '3-4 days'),
              standard: PricingTier(cost: 2500, timeline: '4-5 days'),
              documentRequirements: ['Sponsor documents', 'Visa', 'Tenancy'],
            ),
            SubService(
              id: 'dependent_cancel',
              name: 'Cancellation',
              serviceTypeId: 'dependent',
              premium: PricingTier(cost: 1350, timeline: '2 days'),
              standard: PricingTier(cost: 1100, timeline: '2-3 days'),
              documentRequirements: ['Passport', 'Visa', 'Cancellation form'],
            ),
          ],
        ),
        ServiceType(
          id: 'investor',
          name: 'Investor Visa',
          categoryId: 'visa',
          subServices: [
            SubService(
              id: 'investor_issuance',
              name: 'Issuance',
              serviceTypeId: 'investor',
              premium: PricingTier(cost: 4700, timeline: '5-7 days'),
              standard: PricingTier(cost: 4000, timeline: '7-10 days'),
              documentRequirements: [
                'Passport',
                'Photo',
                'Emirates ID copy',
                'Trade license',
              ],
            ),
            SubService(
              id: 'investor_renewal',
              name: 'Renewal',
              serviceTypeId: 'investor',
              premium: PricingTier(cost: 3500, timeline: '4-5 days'),
              standard: PricingTier(cost: 2900, timeline: '5-7 days'),
              documentRequirements: ['Passport', 'Visa', 'Emirates ID'],
            ),
            SubService(
              id: 'investor_cancel',
              name: 'Cancellation',
              serviceTypeId: 'investor',
              premium: PricingTier(cost: 1350, timeline: '2 days'),
              standard: PricingTier(cost: 1100, timeline: '2-3 days'),
              documentRequirements: ['Passport', 'Visa', 'Cancellation form'],
            ),
          ],
        ),
        ServiceType(
          id: 'freelance',
          name: 'Freelance Visa',
          categoryId: 'visa',
          subServices: [
            SubService(
              id: 'freelance_issuance',
              name: 'Issuance',
              serviceTypeId: 'freelance',
              premium: PricingTier(cost: 8000, timeline: '6-8 days'),
              standard: PricingTier(cost: 6500, timeline: '8-10 days'),
              documentRequirements: [
                'Passport',
                'Photo',
                'Portfolio/NOC',
                'Bank statement',
              ],
            ),
            SubService(
              id: 'freelance_renewal',
              name: 'Renewal',
              serviceTypeId: 'freelance',
              premium: PricingTier(cost: 7500, timeline: '5-6 days'),
              standard: PricingTier(cost: 6000, timeline: '7-8 days'),
              documentRequirements: ['Passport', 'Visa', 'Emirates ID'],
            ),
            SubService(
              id: 'freelance_cancel',
              name: 'Cancellation',
              serviceTypeId: 'freelance',
              premium: PricingTier(cost: 1350, timeline: '2 days'),
              standard: PricingTier(cost: 1100, timeline: '2-3 days'),
              documentRequirements: ['Passport', 'Visa', 'Cancellation form'],
            ),
          ],
        ),
        ServiceType(
          id: 'golden',
          name: 'Golden Visa',
          categoryId: 'visa',
          subServices: [
            SubService(
              id: 'golden_issuance',
              name: 'Issuance',
              serviceTypeId: 'golden',
              premium: PricingTier(cost: 10000, timeline: '10-12 days'),
              standard: PricingTier(cost: 8500, timeline: '15-20 days'),
              documentRequirements: [
                'Passport',
                'Emirates ID',
                'Investment proof',
              ],
            ),
            SubService(
              id: 'golden_renewal',
              name: 'Renewal',
              serviceTypeId: 'golden',
              premium: PricingTier(cost: 9000, timeline: '8-10 days'),
              standard: PricingTier(cost: 8000, timeline: '12-15 days'),
              documentRequirements: [
                'Passport',
                'Emirates ID',
                'Renewal request',
              ],
            ),
          ],
        ),
        ServiceType(
          id: 'other_visa',
          name: 'Other Visa Services',
          categoryId: 'visa',
          subServices: [
            SubService(
              id: 'emirates_id',
              name: 'Emirates ID Typing',
              serviceTypeId: 'other_visa',
              premium: PricingTier(cost: 780, timeline: '1 day'),
              standard: PricingTier(cost: 700, timeline: '1-2 days'),
              documentRequirements: ['Passport', 'Visa page', 'Photo'],
            ),
            SubService(
              id: 'change_status',
              name: 'Change of Status',
              serviceTypeId: 'other_visa',
              premium: PricingTier(cost: 1250, timeline: '2 days'),
              standard: PricingTier(cost: 1100, timeline: '2-3 days'),
              documentRequirements: ['Entry permit', 'Visa', 'Passport'],
            ),
          ],
        ),
      ],
    ),

    // Banking Services
    ServiceCategory(
      id: 'banking',
      name: 'Banking Services',
      icon: '🏦',
      color: '0xFF4CAF50',
      serviceTypes: [
        ServiceType(
          id: 'personal_account',
          name: 'Personal Bank Account',
          categoryId: 'banking',
          subServices: [
            SubService(
              id: 'personal_open',
              name: 'Open Account',
              serviceTypeId: 'personal_account',
              premium: PricingTier(
                cost: '1000-1200',
                timeline: '1-3 working days',
              ),
              standard: PricingTier(
                cost: '500-605',
                timeline: '3 working days',
              ),
              documentRequirements: [
                'Passport',
                'Emirates ID',
                'Visa page',
                'Salary certificate or bank statement',
              ],
            ),
          ],
        ),
        ServiceType(
          id: 'business_account',
          name: 'Business Bank Account',
          categoryId: 'banking',
          subServices: [
            SubService(
              id: 'business_open',
              name: 'Open Account',
              serviceTypeId: 'business_account',
              premium: PricingTier(
                cost: '1000-5000',
                timeline: '3-5 working days',
              ),
              standard: PricingTier(
                cost: '500-3000',
                timeline: '5-7 working days',
              ),
              documentRequirements: [
                'Trade license',
                'MOA',
                'Passport/visa/Emirates ID of shareholders',
                'Tenancy contract (Ejari)',
                'Utility bill',
              ],
            ),
          ],
        ),
        ServiceType(
          id: 'credit_card',
          name: 'Credit Card',
          categoryId: 'banking',
          subServices: [
            SubService(
              id: 'credit_apply',
              name: 'Application',
              serviceTypeId: 'credit_card',
              premium: PricingTier(
                cost: '1000-1200',
                timeline: '2-5 working days',
              ),
              standard: PricingTier(
                cost: '500-800',
                timeline: '5 working days',
              ),
              documentRequirements: [
                'Salary certificate',
                'Emirates ID',
                'Passport',
                'Credit score check',
              ],
            ),
          ],
        ),
      ],
    ),

    // Federal Tax Authority
    ServiceCategory(
      id: 'tax',
      name: 'Tax Services',
      icon: '📋',
      color: '0xFFFF9800',
      serviceTypes: [
        ServiceType(
          id: 'corporate_tax',
          name: 'Corporate Tax',
          categoryId: 'tax',
          subServices: [
            SubService(
              id: 'corp_registration',
              name: 'Registration',
              serviceTypeId: 'corporate_tax',
              premium: PricingTier(cost: 1000, timeline: '1-2 days'),
              standard: PricingTier(cost: 500, timeline: '2-3 working days'),
              documentRequirements: [
                'Trade license',
                'Emirates ID/Passport',
                'Authorization proof',
              ],
            ),
            SubService(
              id: 'corp_submission',
              name: 'Tax Submission',
              serviceTypeId: 'corporate_tax',
              premium: PricingTier(cost: 700, timeline: '1 day'),
              standard: PricingTier(cost: 500, timeline: '2-3 working days'),
              documentRequirements: [
                'Audited financial statements',
                'Tax calculation data',
              ],
            ),
          ],
        ),
        ServiceType(
          id: 'vat',
          name: 'VAT Services',
          categoryId: 'tax',
          subServices: [
            SubService(
              id: 'vat_registration',
              name: 'VAT Registration',
              serviceTypeId: 'vat',
              premium: PricingTier(cost: 1000, timeline: '1 day'),
              standard: PricingTier(cost: 500, timeline: '2-3 working days'),
              documentRequirements: [
                'Trade license',
                'Emirates ID',
                'Financial records',
                'Turnover forecast',
              ],
            ),
            SubService(
              id: 'vat_filing',
              name: 'VAT Return Filing',
              serviceTypeId: 'vat',
              premium: PricingTier(cost: 2500, timeline: '1 day'),
              standard: PricingTier(cost: 500, timeline: '2-3 working days'),
              documentRequirements: [
                'Input/output VAT invoices',
                'Reverse charge data',
                'Tax ledger',
              ],
            ),
          ],
        ),
      ],
    ),

    // Accounting & Bookkeeping
    ServiceCategory(
      id: 'accounting',
      name: 'Accounting & Bookkeeping',
      icon: '💰',
      color: '0xFF2196F3',
      serviceTypes: [
        ServiceType(
          id: 'bookkeeping',
          name: 'Bookkeeping',
          categoryId: 'accounting',
          subServices: [
            SubService(
              id: 'book_basic',
              name: 'Basic Monthly',
              serviceTypeId: 'bookkeeping',
              premium: PricingTier(cost: 1800, timeline: 'Monthly'),
              standard: PricingTier(cost: 1300, timeline: 'Monthly'),
              documentRequirements: [
                'Bank statements',
                'Sales/purchase invoices',
                'Petty cash receipts',
              ],
            ),
            SubService(
              id: 'book_vat',
              name: 'VAT Reconciliation',
              serviceTypeId: 'bookkeeping',
              premium: PricingTier(cost: 2000, timeline: 'Monthly/Quarterly'),
              standard: PricingTier(cost: 1500, timeline: 'Monthly/Quarterly'),
              documentRequirements: [
                'VAT certificate',
                'Sales/purchase invoices',
                'Tax invoices',
                'Bank statements',
              ],
            ),
          ],
        ),
        ServiceType(
          id: 'accounting_full',
          name: 'Full Accounting',
          categoryId: 'accounting',
          subServices: [
            SubService(
              id: 'acc_full',
              name: 'Full Service',
              serviceTypeId: 'accounting_full',
              premium: PricingTier(cost: 3000, timeline: 'Monthly'),
              standard: PricingTier(cost: 2500, timeline: 'Monthly'),
              documentRequirements: [
                'Bank statements',
                'Trial balance',
                'Invoices',
                'Salary slips',
              ],
            ),
          ],
        ),
      ],
    ),

    // PRO Services
    ServiceCategory(
      id: 'pro',
      name: 'PRO Services',
      icon: '📄',
      color: '0xFF9C27B0',
      serviceTypes: [
        ServiceType(
          id: 'trade_license',
          name: 'Trade License',
          categoryId: 'pro',
          subServices: [
            SubService(
              id: 'license_new',
              name: 'New Application',
              serviceTypeId: 'trade_license',
              premium: PricingTier(
                cost: '3500-5500',
                timeline: '2-4 working days',
              ),
              standard: PricingTier(cost: 2500, timeline: '5-7 working days'),
              documentRequirements: [
                'Passport copy',
                'Name approval',
                'NOC if required',
              ],
            ),
            SubService(
              id: 'license_renewal',
              name: 'Renewal',
              serviceTypeId: 'trade_license',
              premium: PricingTier(
                cost: '2300-3000',
                timeline: '1-3 working days',
              ),
              standard: PricingTier(cost: 1700, timeline: '3-5 working days'),
              documentRequirements: [
                'Trade license',
                'Tenancy',
                'Passport copies of partners',
              ],
            ),
          ],
        ),
        ServiceType(
          id: 'labour',
          name: 'Labour Services',
          categoryId: 'pro',
          subServices: [
            SubService(
              id: 'labour_card',
              name: 'Labour Card Application',
              serviceTypeId: 'labour',
              premium: PricingTier(cost: 1000, timeline: '2-3 working days'),
              standard: PricingTier(cost: 800, timeline: '3-5 working days'),
              documentRequirements: [
                'Passport',
                'Visa page',
                'Company license',
              ],
            ),
          ],
        ),
      ],
    ),

    // Business Expansion Services
    ServiceCategory(
      id: 'expansion',
      name: 'Business Expansion Services',
      icon: '📈',
      color: '0xFF4CAF50',
      serviceTypes: [
        ServiceType(
          id: 'branch_setup',
          name: 'Branch Setup',
          categoryId: 'expansion',
          subServices: [
            SubService(
              id: 'branch_mainland',
              name: 'Branch Setup (Mainland/Freezone/International)',
              serviceTypeId: 'branch_setup',
              premium: PricingTier(cost: 5000, timeline: '2-5 days'),
              standard: PricingTier(cost: 3500, timeline: '5-10 days'),
              documentRequirements: ['License copy', 'shareholder ID', 'MoA'],
            ),
            SubService(
              id: 'activity_addition',
              name: 'Additional Activity Addition (DED or Freezone)',
              serviceTypeId: 'branch_setup',
              premium: PricingTier(cost: 1500, timeline: '1-3 days'),
              standard: PricingTier(cost: 800, timeline: '3-5 days'),
              documentRequirements: ['License', 'application form'],
            ),
            SubService(
              id: 'office_upgrade',
              name: 'Office Upgrade & Facility Leasing',
              serviceTypeId: 'branch_setup',
              premium: PricingTier(cost: 2000, timeline: '2 days'),
              standard: PricingTier(cost: 1200, timeline: '4 days'),
              documentRequirements: ['Current lease', 'office plan'],
            ),
            SubService(
              id: 'trade_name_change',
              name: 'Trade Name Change / License Amendment',
              serviceTypeId: 'branch_setup',
              premium: PricingTier(cost: 1000, timeline: '1-2 days'),
              standard: PricingTier(cost: 500, timeline: '2-4 days'),
              documentRequirements: ['Old license', 'new name'],
            ),
            SubService(
              id: 'business_restructuring',
              name: 'Business Restructuring & Strategy Advisory',
              serviceTypeId: 'branch_setup',
              premium: PricingTier(cost: 3000, timeline: '3-5 days'),
              standard: PricingTier(cost: 1800, timeline: '7-10 days'),
              documentRequirements: ['Business plan', 'MoA', 'shareholder IDs'],
            ),
          ],
        ),
      ],
    ),

    // Banking & Finance (Extended)
    ServiceCategory(
      id: 'banking_extended',
      name: 'Banking & Finance',
      icon: '🏦',
      color: '0xFF2196F3',
      serviceTypes: [
        ServiceType(
          id: 'advanced_banking',
          name: 'Advanced Banking Services',
          categoryId: 'banking_extended',
          subServices: [
            SubService(
              id: 'corp_bank_account',
              name: 'Corporate Bank Account Opening',
              serviceTypeId: 'advanced_banking',
              premium: PricingTier(cost: 1200, timeline: '2-4 days'),
              standard: PricingTier(cost: 800, timeline: '4-6 days'),
              documentRequirements: ['Shareholder passport', 'Emirates ID'],
            ),
            SubService(
              id: 'payment_gateway',
              name: 'Payment Gateway Integration',
              serviceTypeId: 'advanced_banking',
              premium: PricingTier(cost: 800, timeline: '1 day'),
              standard: PricingTier(cost: 500, timeline: '2-3 days'),
              documentRequirements: ['Website & trade license'],
            ),
            SubService(
              id: 'pos_machines',
              name: 'POS Machines & Merchant Accounts',
              serviceTypeId: 'advanced_banking',
              premium: PricingTier(cost: 1000, timeline: '2-3 days'),
              standard: PricingTier(cost: 600, timeline: '3-5 days'),
              documentRequirements: ['Trade license', 'ID', 'account info'],
            ),
            SubService(
              id: 'business_loans',
              name: 'Business Loans & Credit Facilities',
              serviceTypeId: 'advanced_banking',
              premium: PricingTier(cost: 5000, timeline: '5-7 days'),
              standard: PricingTier(cost: 3000, timeline: '10-15 days'),
              documentRequirements: ['Audited financials', 'license'],
            ),
            SubService(
              id: 'financial_auditing',
              name: 'Financial Auditing & Statement Preparation',
              serviceTypeId: 'advanced_banking',
              premium: PricingTier(cost: 2000, timeline: '3-4 days'),
              standard: PricingTier(cost: 1200, timeline: '6-8 days'),
              documentRequirements: ['Bank statements', 'signed letter'],
            ),
          ],
        ),
      ],
    ),

    // Marketing & Sales Boost
    ServiceCategory(
      id: 'marketing',
      name: 'Marketing & Sales Boost',
      icon: '📱',
      color: '0xFFFF9800',
      serviceTypes: [
        ServiceType(
          id: 'digital_marketing',
          name: 'Digital Marketing',
          categoryId: 'marketing',
          subServices: [
            SubService(
              id: 'website_dev',
              name: 'Website Development (with e-commerce integration)',
              serviceTypeId: 'digital_marketing',
              premium: PricingTier(cost: 2500, timeline: '4-6 days'),
              standard: PricingTier(cost: 1500, timeline: '7-10 days'),
              documentRequirements: ['Brand content', 'product info'],
            ),
            SubService(
              id: 'seo_social',
              name: 'SEO & Social Media Marketing (Arabic & English)',
              serviceTypeId: 'digital_marketing',
              premium: PricingTier(cost: 2000, timeline: '3-5 days'),
              standard: PricingTier(cost: 1200, timeline: '5-7 days'),
              documentRequirements: ['Login access', 'brand brief'],
            ),
            SubService(
              id: 'business_profile',
              name: 'Business Profile/Brochure Design',
              serviceTypeId: 'digital_marketing',
              premium: PricingTier(cost: 1000, timeline: '2 days'),
              standard: PricingTier(cost: 600, timeline: '4 days'),
              documentRequirements: ['Business summary', 'trade license'],
            ),
            SubService(
              id: 'lead_generation',
              name: 'Lead Generation Campaigns (LinkedIn/Meta Ads)',
              serviceTypeId: 'digital_marketing',
              premium: PricingTier(cost: 3000, timeline: '4-7 days'),
              standard: PricingTier(cost: 1800, timeline: '6-10 days'),
              documentRequirements: ['Ad budget approval', 'profile'],
            ),
            SubService(
              id: 'google_business',
              name: 'Google Business & Trustpilot Setup',
              serviceTypeId: 'digital_marketing',
              premium: PricingTier(cost: 800, timeline: '2 days'),
              standard: PricingTier(cost: 400, timeline: '3 days'),
              documentRequirements: ['Trade license', 'location info'],
            ),
          ],
        ),
      ],
    ),

    // International Trade & Logistics
    ServiceCategory(
      id: 'trade_logistics',
      name: 'International Trade & Logistics',
      icon: '🚚',
      color: '0xFF9C27B0',
      serviceTypes: [
        ServiceType(
          id: 'trade_services',
          name: 'Trade Services',
          categoryId: 'trade_logistics',
          subServices: [
            SubService(
              id: 'import_export',
              name: 'Import/Export Code Registration',
              serviceTypeId: 'trade_services',
              premium: PricingTier(cost: 1000, timeline: '2-3 days'),
              standard: PricingTier(cost: 600, timeline: '4-6 days'),
              documentRequirements: ['Trade license', 'ID copies'],
            ),
            SubService(
              id: 'customs',
              name: 'Customs Registration & Clearance',
              serviceTypeId: 'trade_services',
              premium: PricingTier(cost: 1500, timeline: '3 days'),
              standard: PricingTier(cost: 800, timeline: '5-7 days'),
              documentRequirements: ['Emirates ID', 'customs code'],
            ),
            SubService(
              id: 'product_registration',
              name: 'Product Registration (Municipality / ESMA)',
              serviceTypeId: 'trade_services',
              premium: PricingTier(cost: 2500, timeline: '5-7 days'),
              standard: PricingTier(cost: 1800, timeline: '7-10 days'),
              documentRequirements: ['Product samples', 'label design'],
            ),
            SubService(
              id: 'warehouse_setup',
              name: 'Warehouse Setup & Logistics Partnerships',
              serviceTypeId: 'trade_services',
              premium: PricingTier(cost: 3000, timeline: '6-8 days'),
              standard: PricingTier(cost: 2000, timeline: '8-12 days'),
              documentRequirements: ['Lease agreement', 'trade license'],
            ),
            SubService(
              id: 'ecommerce_listing',
              name: 'E-commerce Platform Listings (Amazon, Noon, Etsy)',
              serviceTypeId: 'trade_services',
              premium: PricingTier(cost: 1200, timeline: '2-4 days'),
              standard: PricingTier(cost: 800, timeline: '4-6 days'),
              documentRequirements: ['E-commerce account', 'product info'],
            ),
          ],
        ),
      ],
    ),

    // HR & Talent Management
    ServiceCategory(
      id: 'hr_talent',
      name: 'HR & Talent Management',
      icon: '👥',
      color: '0xFF00BCD4',
      serviceTypes: [
        ServiceType(
          id: 'hr_services',
          name: 'HR Services',
          categoryId: 'hr_talent',
          subServices: [
            SubService(
              id: 'visa_quota',
              name: 'Employee Visa Quota Expansion',
              serviceTypeId: 'hr_services',
              premium: PricingTier(cost: 1000, timeline: '2 days'),
              standard: PricingTier(cost: 600, timeline: '3-4 days'),
              documentRequirements: ['Trade license', 'quota request'],
            ),
            SubService(
              id: 'hr_policy',
              name: 'HR Policy Drafting & Recruitment Support',
              serviceTypeId: 'hr_services',
              premium: PricingTier(cost: 1500, timeline: '3 days'),
              standard: PricingTier(cost: 1000, timeline: '4-5 days'),
              documentRequirements: ['CVs', 'JD', 'license'],
            ),
            SubService(
              id: 'payroll',
              name: 'Payroll Management Services',
              serviceTypeId: 'hr_services',
              premium: PricingTier(cost: 1000, timeline: '2 days'),
              standard: PricingTier(cost: 700, timeline: '3-4 days'),
              documentRequirements: ['Employee data'],
            ),
            SubService(
              id: 'emirates_id_medical',
              name: 'Emirates ID Medical & Insurance Assistance',
              serviceTypeId: 'hr_services',
              premium: PricingTier(cost: 800, timeline: '1-2 days'),
              standard: PricingTier(cost: 500, timeline: '2-3 days'),
              documentRequirements: ['Passport', 'visa'],
            ),
            SubService(
              id: 'pro_retainer',
              name: 'PRO Retainer Packages',
              serviceTypeId: 'hr_services',
              premium: PricingTier(cost: 3000, timeline: '3-6 days'),
              standard: PricingTier(cost: 2000, timeline: '5-8 days'),
              documentRequirements: ['License copy', 'ID proof'],
            ),
          ],
        ),
      ],
    ),

    // Legal & Documentation
    ServiceCategory(
      id: 'legal',
      name: 'Legal & Documentation',
      icon: '⚖️',
      color: '0xFF607D8B',
      serviceTypes: [
        ServiceType(
          id: 'legal_services',
          name: 'Legal Services',
          categoryId: 'legal',
          subServices: [
            SubService(
              id: 'mou_nda',
              name: 'MOUs, NDAs, and Agreements Drafting',
              serviceTypeId: 'legal_services',
              premium: PricingTier(cost: 1000, timeline: '2 days'),
              standard: PricingTier(cost: 600, timeline: '3 days'),
              documentRequirements: ['Draft notes', 'shareholder ID'],
            ),
            SubService(
              id: 'trademark',
              name: 'Trademark Registration (UAE, GCC, India)',
              serviceTypeId: 'legal_services',
              premium: PricingTier(cost: 2000, timeline: '3 days'),
              standard: PricingTier(cost: 1200, timeline: '4 days'),
              documentRequirements: ['Logo', 'passport', 'trade license'],
            ),
            SubService(
              id: 'franchise',
              name: 'Franchise Agreement & Licensing',
              serviceTypeId: 'legal_services',
              premium: PricingTier(cost: 3500, timeline: '4-6 days'),
              standard: PricingTier(cost: 2500, timeline: '6-8 days'),
              documentRequirements: ['License', 'business model'],
            ),
            SubService(
              id: 'translation',
              name: 'Legal Translation & Notarization',
              serviceTypeId: 'legal_services',
              premium: PricingTier(cost: 1200, timeline: '2-3 days'),
              standard: PricingTier(cost: 700, timeline: '3-5 days'),
              documentRequirements: ['Legal docs'],
            ),
            SubService(
              id: 'dispute_resolution',
              name: 'Dispute Resolution Services',
              serviceTypeId: 'legal_services',
              premium: PricingTier(cost: 2000, timeline: '4 days'),
              standard: PricingTier(cost: 1500, timeline: '6 days'),
              documentRequirements: ['Contract', 'case info'],
            ),
          ],
        ),
      ],
    ),

    // Investor Attraction & Certification
    ServiceCategory(
      id: 'investor',
      name: 'Investor Attraction & Certification',
      icon: '💎',
      color: '0xFFE91E63',
      serviceTypes: [
        ServiceType(
          id: 'investor_services',
          name: 'Investor Services',
          categoryId: 'investor',
          subServices: [
            SubService(
              id: 'pitch_deck',
              name: 'Investor Pitch Decks & Valuation Reports',
              serviceTypeId: 'investor_services',
              premium: PricingTier(cost: 1500, timeline: '2 days'),
              standard: PricingTier(cost: 1000, timeline: '3 days'),
              documentRequirements: ['Business plan', 'pitch deck'],
            ),
            SubService(
              id: 'golden_visa',
              name: 'Golden Visa Application Support',
              serviceTypeId: 'investor_services',
              premium: PricingTier(cost: 3000, timeline: '4 days'),
              standard: PricingTier(cost: 1800, timeline: '5 days'),
              documentRequirements: ['Visa docs', 'investment proof'],
            ),
            SubService(
              id: 'gov_incentives',
              name: 'Government/Freezone Incentives',
              serviceTypeId: 'investor_services',
              premium: PricingTier(cost: 2000, timeline: '2 days'),
              standard: PricingTier(cost: 1200, timeline: '3 days'),
              documentRequirements: ['Proposal', 'license copy'],
            ),
            SubService(
              id: 'tender_support',
              name: 'Tender Support & Pre-Qualification (PQ) Documents',
              serviceTypeId: 'investor_services',
              premium: PricingTier(cost: 4000, timeline: '5-7 days'),
              standard: PricingTier(cost: 3000, timeline: '7-10 days'),
              documentRequirements: ['Tender invite', 'license'],
            ),
            SubService(
              id: 'iso_certification',
              name: 'ISO Certification Support',
              serviceTypeId: 'investor_services',
              premium: PricingTier(cost: 3500, timeline: '6 days'),
              standard: PricingTier(cost: 2500, timeline: '8 days'),
              documentRequirements: ['Company docs'],
            ),
          ],
        ),
      ],
    ),
  ];
}
