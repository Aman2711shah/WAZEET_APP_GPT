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
      description:
          'Complete visa and immigration services for tourists, residents, and families visiting or relocating to the UAE',
      icon: 'flight',
      color: '0xFF6D5DF6',
      serviceTypes: [
        ServiceType(
          id: 'tourist_visa',
          name: 'Tourist Visa',
          description:
              'Short-term visit visas for tourism, family visits, and exploration',
          icon: 'luggage',
          categoryId: 'visa',
          subServices: [
            SubService(
              id: 'tourist_30_single',
              name: '30-day Single Entry Visa',
              description:
                  'Perfect for short vacations and first-time visitors to the UAE',
              icon: 'beach_access',
              serviceTypeId: 'tourist_visa',
              premium: PricingTier(cost: 950, timeline: '36 hours (express)'),
              standard: PricingTier(
                cost: 650,
                timeline: '3-4 working days (standard)',
              ),
              documentRequirements: [
                'Passport with 6+ months validity',
                'Recent passport-sized photo (white background)',
                'Confirmed return flight tickets',
                'Hotel reservation or UAE host letter',
                'National ID for Iraq, Iran, Afghanistan, Pakistan nationals',
              ],
            ),
            SubService(
              id: 'tourist_60_multi',
              name: '60-day Single/Multiple Entry Visa',
              description:
                  'Extended stay option with multiple entry flexibility for frequent visitors',
              icon: 'card_travel',
              serviceTypeId: 'tourist_visa',
              premium: PricingTier(cost: 1150, timeline: '36 hours (express)'),
              standard: PricingTier(
                cost: 850,
                timeline: '3-4 working days (standard)',
              ),
              documentRequirements: [
                'Passport with 6+ months validity',
                'Recent passport-sized photo',
                'Return tickets',
                'Hotel reservation or sponsor letter',
                'Travel history (if requested)',
              ],
            ),
            SubService(
              id: 'tourist_90_multi',
              name: '90-day Multiple Entry Visa',
              description:
                  'Long-term tourist visa ideal for business tourism and extended family visits',
              icon: 'event',
              serviceTypeId: 'tourist_visa',
              premium: PricingTier(cost: 1500, timeline: '48 hours (express)'),
              standard: PricingTier(
                cost: 1200,
                timeline: '4-5 working days (standard)',
              ),
              documentRequirements: [
                'Passport copy',
                'Photo (white background)',
                'Confirmed itinerary and accommodation',
                'Bank statement (last 3 months)',
              ],
            ),
            SubService(
              id: 'tourist_5year',
              name: '5-year Multiple Entry Visa',
              description:
                  'Premium long-term visa for frequent UAE visitors with substantial financial standing',
              icon: 'verified',
              serviceTypeId: 'tourist_visa',
              premium: PricingTier(
                cost: 2200,
                timeline: '3-4 working days (priority)',
              ),
              standard: PricingTier(
                cost: 1850,
                timeline: '5-7 working days (standard)',
              ),
              documentRequirements: [
                'Passport copy (valid 6+ months)',
                'Photo (white background)',
                'Return flights for first visit',
                'Proof of accommodation',
                'Bank statement (6 months, min USD 4,000 balance)',
              ],
            ),
          ],
        ),
        ServiceType(
          id: 'residence_visa',
          name: 'Residence Visa',
          description:
              'Long-term residency solutions for employment, investment, and family sponsorship',
          icon: 'home',
          categoryId: 'visa',
          subServices: [
            SubService(
              id: 'employment_visa',
              name: 'Employment Visa',
              description:
                  'Work permit and residence visa for sponsored employees',
              icon: 'work',
              serviceTypeId: 'residence_visa',
              premium: PricingTier(
                cost: '6000-7500',
                timeline: '2-3 weeks (fast-track)',
              ),
              standard: PricingTier(cost: '4500-6000', timeline: '3-4 weeks'),
              documentRequirements: [
                'Passport copy',
                'Entry permit',
                'MOHRE-approved employment contract',
                'Offer letter from UAE employer',
                'Attested educational certificates',
                'Medical fitness certificate',
                'Emirates ID application',
              ],
            ),
            SubService(
              id: 'family_sponsorship',
              name: 'Family Sponsorship Visa',
              serviceTypeId: 'residence_visa',
              premium: PricingTier(cost: '4200-5200', timeline: '2-3 weeks'),
              standard: PricingTier(cost: '3200-4200', timeline: '3-4 weeks'),
              documentRequirements: [
                'Sponsor\'s passport & residence visa',
                'Marriage/birth certificates (attested)',
                'Ejari tenancy contract',
                'Salary certificate meeting eligibility',
                'Bank statements (last 3 months)',
              ],
            ),
            SubService(
              id: 'investor_residence',
              name: 'Investor Visa',
              serviceTypeId: 'residence_visa',
              premium: PricingTier(cost: '7000-9000', timeline: '2-3 weeks'),
              standard: PricingTier(cost: '5500-7000', timeline: '3-4 weeks'),
              documentRequirements: [
                'Passport',
                'Investment/ownership proof',
                'Trade license & MOA',
                'Bank statements',
                'Medical fitness & Emirates ID',
              ],
            ),
            SubService(
              id: 'student_visa',
              name: 'Student Visa',
              serviceTypeId: 'residence_visa',
              premium: PricingTier(cost: '4200-5000', timeline: '2-3 weeks'),
              standard: PricingTier(cost: '3200-4200', timeline: '3-4 weeks'),
              documentRequirements: [
                'Passport copy',
                'University admission/offer letter',
                'Sponsor documents or financial proof',
                'Medical fitness certificate',
              ],
            ),
            SubService(
              id: 'golden_visa',
              name: 'Golden Visa (5/10 years)',
              serviceTypeId: 'residence_visa',
              premium: PricingTier(cost: 'AED 10,000+', timeline: '2-4 weeks'),
              standard: PricingTier(cost: 'AED 8,000+', timeline: '4-6 weeks'),
              documentRequirements: [
                'Passport & Emirates ID',
                'Investment proof or employment contract',
                'Salary/income statements',
                'Attested qualifications (if applicable)',
              ],
            ),
            SubService(
              id: 'green_visa',
              name: 'Green Visa (Freelancers/Skilled Workers)',
              serviceTypeId: 'residence_visa',
              premium: PricingTier(cost: '5000-7000', timeline: '2-3 weeks'),
              standard: PricingTier(cost: '3800-5200', timeline: '3-4 weeks'),
              documentRequirements: [
                'Passport',
                'Proof of freelance permit or work contract',
                'Educational/experience certificates',
                'Bank statements',
              ],
            ),
          ],
        ),
        ServiceType(
          id: 'visa_renewal',
          name: 'Visa Renewal Services',
          categoryId: 'visa',
          subServices: [
            SubService(
              id: 'residence_renewal',
              name: 'Residence Visa Renewal',
              serviceTypeId: 'visa_renewal',
              premium: PricingTier(cost: 3200, timeline: '5-7 working days'),
              standard: PricingTier(cost: 2400, timeline: '7-10 working days'),
              documentRequirements: [
                'Original passport',
                'Current residence visa copy',
                'Valid Emirates ID',
                'Medical fitness certificate',
                'Updated employment contract',
                'Ejari tenancy agreement',
              ],
            ),
            SubService(
              id: 'visit_visa_extension',
              name: 'Visit Visa Extension (30-day increments)',
              serviceTypeId: 'visa_renewal',
              premium: PricingTier(cost: 1200, timeline: '24-36 hours'),
              standard: PricingTier(cost: 850, timeline: '2-3 working days'),
              documentRequirements: [
                'Original passport',
                'Current visit visa copy',
                'Travel itinerary updates',
                'Proof of funds/accommodation',
              ],
            ),
          ],
        ),
        ServiceType(
          id: 'entry_permits',
          name: 'Entry Permits',
          categoryId: 'visa',
          subServices: [
            SubService(
              id: 'tourist_entry_permit',
              name: 'Tourist Entry Permit',
              serviceTypeId: 'entry_permits',
              premium: PricingTier(cost: 650, timeline: '24 hours'),
              standard: PricingTier(cost: 450, timeline: '3 working days'),
              documentRequirements: [
                'Passport copy (6 months validity)',
                'Passport photo',
                'Confirmed travel dates',
                'Accommodation proof',
              ],
            ),
            SubService(
              id: 'employment_entry_permit',
              name: 'Employment Entry Permit',
              serviceTypeId: 'entry_permits',
              premium: PricingTier(cost: 900, timeline: '2-3 working days'),
              standard: PricingTier(cost: 650, timeline: '5 working days'),
              documentRequirements: [
                'Passport copy',
                'Employment contract',
                'Sponsor trade license',
                'Company establishment card',
              ],
            ),
            SubService(
              id: 'family_entry_permit',
              name: 'Family Entry Permit',
              serviceTypeId: 'entry_permits',
              premium: PricingTier(cost: 780, timeline: '2 working days'),
              standard: PricingTier(cost: 580, timeline: '4 working days'),
              documentRequirements: [
                'Passport copy (sponsor & dependant)',
                'Attested relationship documents',
                'Salary certificate',
                'Ejari tenancy',
              ],
            ),
            SubService(
              id: 'mission_entry_permit',
              name: 'Mission Entry Permit',
              serviceTypeId: 'entry_permits',
              premium: PricingTier(cost: 1100, timeline: '2 working days'),
              standard: PricingTier(cost: 850, timeline: '4 working days'),
              documentRequirements: [
                'Passport copy',
                'Mission contract/offer letter',
                'Company documents & quota',
                'Sponsor undertaking letter',
              ],
            ),
          ],
        ),
        ServiceType(
          id: 'visa_extension',
          name: 'Visa Extension',
          categoryId: 'visa',
          subServices: [
            SubService(
              id: 'tourist_extension',
              name: 'Tourist Visa Extension (Single/Multi Trip)',
              serviceTypeId: 'visa_extension',
              premium: PricingTier(
                cost: 'AED 600 + fees',
                timeline: '24-48 hours (express)',
              ),
              standard: PricingTier(
                cost: 'AED 600 + VAT',
                timeline: '3 working days',
              ),
              documentRequirements: [
                'Passport copy (6+ months validity)',
                'Existing visa copy',
                'Proof of onward travel',
              ],
            ),
            SubService(
              id: 'friend_relative_extension',
              name: 'Friends & Relatives Visit Extension',
              serviceTypeId: 'visa_extension',
              premium: PricingTier(
                cost: 'AED 650 + deposits',
                timeline: '24-48 hours',
              ),
              standard: PricingTier(
                cost: 'AED 600 + VAT',
                timeline: '3 working days',
              ),
              documentRequirements: [
                'Sponsor passport & Emirates ID',
                'Relationship proof (marriage/birth certificate)',
                'Tenancy contract & latest utility bill',
              ],
            ),
            SubService(
              id: 'business_visit_extension',
              name: 'Business Visit Visa Extension',
              serviceTypeId: 'visa_extension',
              premium: PricingTier(
                cost: 'AED 700 + VAT',
                timeline: '2 working days',
              ),
              standard: PricingTier(
                cost: 'AED 600 + VAT',
                timeline: '3-4 working days',
              ),
              documentRequirements: [
                'Passport copy',
                'Company invitation letter',
                'Valid insurance',
              ],
            ),
            SubService(
              id: 'job_seek_extension',
              name: 'Job Opportunity Visit Extension',
              serviceTypeId: 'visa_extension',
              premium: PricingTier(
                cost: 'AED 650 + deposit',
                timeline: '2 working days',
              ),
              standard: PricingTier(
                cost: 'AED 600 + deposit',
                timeline: '3-4 working days',
              ),
              documentRequirements: [
                'Passport copy',
                'Financial security deposit receipt',
                'Updated CV or qualification letters',
              ],
            ),
            SubService(
              id: 'medical_visit_extension',
              name: 'Medical Visa Extension',
              serviceTypeId: 'visa_extension',
              premium: PricingTier(cost: 'AED 700 + VAT', timeline: '24 hours'),
              standard: PricingTier(
                cost: 'AED 600 + VAT',
                timeline: '2-3 working days',
              ),
              documentRequirements: [
                'Passport & visa copy',
                'Hospital/clinic letter',
                'Medical insurance',
              ],
            ),
          ],
        ),
        ServiceType(
          id: 'visa_cancellation',
          name: 'Visa Cancellation',
          categoryId: 'visa',
          subServices: [
            SubService(
              id: 'cancellation_inside',
              name: 'Inside UAE Cancellation',
              serviceTypeId: 'visa_cancellation',
              premium: PricingTier(
                cost: 'AED 190 + Amer fees',
                timeline: '24 hours',
              ),
              standard: PricingTier(
                cost: 'AED 190',
                timeline: '2 working days',
              ),
              documentRequirements: [
                'Passport',
                'Visa copy',
                'Emirates ID',
                'Cancellation form or NOC',
              ],
            ),
            SubService(
              id: 'cancellation_outside',
              name: 'Outside UAE Cancellation',
              serviceTypeId: 'visa_cancellation',
              premium: PricingTier(
                cost: 'AED 190 + courier',
                timeline: '24-48 hours',
              ),
              standard: PricingTier(
                cost: 'AED 190',
                timeline: '2-3 working days',
              ),
              documentRequirements: [
                'Passport copy',
                'Exit stamp proof',
                'Company authorization (if sponsored)',
              ],
            ),
          ],
        ),
        ServiceType(
          id: 'work_visa_issuance',
          name: 'Work Visa Issuance',
          categoryId: 'visa',
          subServices: [
            SubService(
              id: 'work_contract_entry',
              name: 'Work Visa Linked to Job Contract',
              serviceTypeId: 'work_visa_issuance',
              premium: PricingTier(
                cost: 'AED 200 + 5% VAT + AED 500 (inside UAE)',
                timeline: '3-4 working days',
              ),
              standard: PricingTier(
                cost: 'AED 200 + VAT',
                timeline: '5 working days',
              ),
              documentRequirements: [
                'Personal photo',
                'Passport copy (6+ months validity)',
                'MOHRE approved work permit',
                'Sponsor trade license & establishment card',
              ],
            ),
          ],
        ),
        ServiceType(
          id: 'visit_visa_issuance',
          name: 'Visit Visa Issuance',
          categoryId: 'visa',
          subServices: [
            SubService(
              id: 'tourist_single_entry',
              name: 'Single-entry Tourist Visa (30/60 days)',
              serviceTypeId: 'visit_visa_issuance',
              premium: PricingTier(
                cost: 'AED 300 + VAT',
                timeline: '24-48 hours',
              ),
              standard: PricingTier(
                cost: 'AED 200 + VAT',
                timeline: '3 working days',
              ),
              documentRequirements: [
                'Passport copy',
                'Personal photo',
                'National ID for restricted nationalities',
                'Confirmed onward ticket & medical insurance',
              ],
            ),
            SubService(
              id: 'relative_visit',
              name: 'Relative/Friend Visit Visa',
              serviceTypeId: 'visit_visa_issuance',
              premium: PricingTier(
                cost: 'AED 400 + deposits',
                timeline: '3 working days',
              ),
              standard: PricingTier(
                cost: 'AED 200-400 + deposit',
                timeline: '4-5 working days',
              ),
              documentRequirements: [
                'Sponsor original passport & Emirates ID',
                'Marriage/birth certificate (attested)',
                'Attested tenancy with 60+ days validity',
                'Latest DEWA bill',
                'Salary certificate or attested labour contract',
              ],
            ),
            SubService(
              id: 'five_year_multi',
              name: '5-year Multi-entry Tourist Visa',
              serviceTypeId: 'visit_visa_issuance',
              premium: PricingTier(
                cost: 'AED 3,713.5',
                timeline: '48 hours - 5 business days',
              ),
              standard: PricingTier(
                cost: 'AED 3,500+',
                timeline: '5 business days',
              ),
              documentRequirements: [
                'Passport copy (6+ months validity)',
                'Personal photo',
                '6-month bank statement (min USD 4,000 balance)',
                'Health insurance',
                'Round-trip ticket',
              ],
            ),
            SubService(
              id: 'job_seeker_visit',
              name: 'Visit Visa to Explore Job Opportunities',
              serviceTypeId: 'visit_visa_issuance',
              premium: PricingTier(
                cost: 'AED 400 + deposit',
                timeline: '3 working days',
              ),
              standard: PricingTier(
                cost: 'AED 300 + deposit',
                timeline: '4-5 working days',
              ),
              documentRequirements: [
                'Relationship proof/justification',
                'Financial security deposit receipt',
                'CV or qualification copy',
                'Residence permit (for GCC spouses if applicable)',
              ],
            ),
          ],
        ),
        ServiceType(
          id: 'residency_entry_services',
          name: 'Residency & Admin Services',
          categoryId: 'visa',
          subServices: [
            SubService(
              id: 'residency_entry_permit',
              name: 'Issuance of Residency Visa Entry Permit',
              serviceTypeId: 'residency_entry_services',
              premium: PricingTier(
                cost: 'AED 500-750',
                timeline: '3-5 working days',
              ),
              standard: PricingTier(
                cost: 'AED 380-500',
                timeline: '5-7 working days',
              ),
              documentRequirements: [
                'Passport copy',
                'Sponsor documents',
                'Entry permit application',
                'Medical insurance',
              ],
            ),
            SubService(
              id: 'green_visa_entry',
              name: 'Issuance of Green Visa Entry Permit',
              serviceTypeId: 'residency_entry_services',
              premium: PricingTier(
                cost: 'AED 650-850',
                timeline: '3-5 working days',
              ),
              standard: PricingTier(
                cost: 'AED 500-650',
                timeline: '5-7 working days',
              ),
              documentRequirements: [
                'Passport copy',
                'Proof of freelancing/remote work contract',
                'Educational certificates',
                'Bank statements',
              ],
            ),
            SubService(
              id: 'status_adjustment',
              name: 'Status Adjustment',
              serviceTypeId: 'residency_entry_services',
              premium: PricingTier(
                cost: 'AED 750 + inside country fee',
                timeline: '2 working days',
              ),
              standard: PricingTier(
                cost: 'AED 600 + fee',
                timeline: '3-4 working days',
              ),
              documentRequirements: [
                'Entry permit',
                'Passport',
                'Current visa/exit stamp',
                'Status change application',
              ],
            ),
            SubService(
              id: 'tourist_quota',
              name: 'Adding Quotas for Tourist Establishments',
              serviceTypeId: 'residency_entry_services',
              premium: PricingTier(
                cost: 'AED 1500+',
                timeline: '5-7 working days',
              ),
              standard: PricingTier(
                cost: 'AED 1000+',
                timeline: '7-10 working days',
              ),
              documentRequirements: [
                'Tourism license',
                'Quota justification letter',
                'Previous utilization reports',
              ],
            ),
            SubService(
              id: 'sponsorship_file_individual',
              name: 'Sponsorship File (Individual)',
              serviceTypeId: 'residency_entry_services',
              premium: PricingTier(
                cost: 'AED 500 + deposit',
                timeline: '2 working days',
              ),
              standard: PricingTier(
                cost: 'AED 350 + deposit',
                timeline: '3-4 working days',
              ),
              documentRequirements: [
                'Sponsor passport & Emirates ID',
                'Salary certificate or bank statement',
                'Tenancy contract (Ejari) & utility bill',
                'Family book (for citizens)',
              ],
            ),
          ],
        ),
      ],
    ),

    // Government Human Resources Services
    ServiceCategory(
      id: 'gov_hr',
      name: 'Government HR Services',
      icon: 'groups',
      color: '0xFF7E57C2',
      serviceTypes: [
        ServiceType(
          id: 'fahr_services',
          name: 'FAHR (Federal Authority for Government HR)',
          categoryId: 'gov_hr',
          subServices: [
            SubService(
              id: 'fahr_onboarding',
              name: 'GOVReady Onboarding Program',
              serviceTypeId: 'fahr_services',
              premium: PricingTier(
                cost: 'Included for federal entities',
                timeline: 'Program duration 4-6 weeks',
              ),
              standard: PricingTier(
                cost: 'Included',
                timeline: 'Self-paced modules',
              ),
              documentRequirements: [
                'Federal employee assignment letter',
                'Access to FAHR LMS',
              ],
            ),
            SubService(
              id: 'fahr_hr_systems',
              name: 'HR System Development',
              serviceTypeId: 'fahr_services',
              premium: PricingTier(
                cost: 'Custom engagement',
                timeline: 'Project specific',
              ),
              standard: PricingTier(
                cost: 'Request proposal',
                timeline: 'Project specific',
              ),
              documentRequirements: [
                'Scope of services (recruitment, career, performance, etc.)',
                'Stakeholder contacts',
              ],
            ),
            SubService(
              id: 'fahr_ai_hr',
              name: 'AI-enabled HR Projects',
              serviceTypeId: 'fahr_services',
              premium: PricingTier(cost: 'Custom', timeline: 'Roadmap-driven'),
              standard: PricingTier(cost: 'Custom', timeline: 'Roadmap-driven'),
              documentRequirements: [
                'Workforce data readiness',
                'Compliance requirements',
                'Project brief (predictive analytics, digital reviews, etc.)',
              ],
            ),
          ],
        ),
        ServiceType(
          id: 'dghr_services',
          name: 'DGHR (Dubai Government HR Department)',
          categoryId: 'gov_hr',
          subServices: [
            SubService(
              id: 'dghr_recruitment',
              name: 'Recruitment & Selection',
              serviceTypeId: 'dghr_services',
              premium: PricingTier(
                cost: 'Included for Dubai Govt entities',
                timeline: 'As per hiring plan',
              ),
              standard: PricingTier(
                cost: 'Included',
                timeline: 'As per hiring plan',
              ),
              documentRequirements: [
                'Approved manpower request',
                'Job description & budget',
              ],
            ),
            SubService(
              id: 'dghr_career_development',
              name: 'Career & Performance Development',
              serviceTypeId: 'dghr_services',
              premium: PricingTier(
                cost: 'Program-specific',
                timeline: 'Quarterly/annual cycles',
              ),
              standard: PricingTier(
                cost: 'Program-specific',
                timeline: 'Quarterly/annual cycles',
              ),
              documentRequirements: [
                'Employee competency profiles',
                'Development objectives',
              ],
            ),
            SubService(
              id: 'dghr_training_development',
              name: 'Training & Development Programs',
              serviceTypeId: 'dghr_services',
              premium: PricingTier(
                cost: 'Program-specific',
                timeline: 'Per training calendar',
              ),
              standard: PricingTier(
                cost: 'Program-specific',
                timeline: 'Per training calendar',
              ),
              documentRequirements: [
                'Training nomination list',
                'Skills gap analysis',
              ],
            ),
            SubService(
              id: 'dghr_performance_management',
              name: 'Performance Management',
              serviceTypeId: 'dghr_services',
              premium: PricingTier(
                cost: 'Included',
                timeline: 'Annual/quarterly cycles',
              ),
              standard: PricingTier(
                cost: 'Included',
                timeline: 'Annual/quarterly cycles',
              ),
              documentRequirements: [
                'Employee KPIs',
                'Previous appraisal data',
              ],
            ),
            SubService(
              id: 'dghr_leave_benefits',
              name: 'Leave & Benefits Administration',
              serviceTypeId: 'dghr_services',
              premium: PricingTier(cost: 'Included', timeline: 'Per request'),
              standard: PricingTier(cost: 'Included', timeline: 'Per request'),
              documentRequirements: [
                'Leave application',
                'Supporting documents (medical, travel, etc.)',
              ],
            ),
            SubService(
              id: 'dghr_policy_development',
              name: 'HR Policy Development',
              serviceTypeId: 'dghr_services',
              premium: PricingTier(
                cost: 'Consultation-based',
                timeline: 'Policy drafting cycle',
              ),
              standard: PricingTier(
                cost: 'Consultation-based',
                timeline: 'Policy drafting cycle',
              ),
              documentRequirements: [
                'Policy scope document',
                'Stakeholder review inputs',
              ],
            ),
            SubService(
              id: 'dghr_wellness',
              name: 'Employee Wellness & Emiratisation',
              serviceTypeId: 'dghr_services',
              premium: PricingTier(cost: 'Included', timeline: 'Ongoing'),
              standard: PricingTier(cost: 'Included', timeline: 'Ongoing'),
              documentRequirements: [
                'Wellness program proposal (if new)',
                'Emiratisation KPI targets',
              ],
            ),
          ],
        ),
        ServiceType(
          id: 'dge_services',
          name: 'Dept. of Government Enablement (Abu Dhabi)',
          categoryId: 'gov_hr',
          subServices: [
            SubService(
              id: 'dge_talent',
              name: 'Talent Identification & Recruitment',
              serviceTypeId: 'dge_services',
              premium: PricingTier(
                cost: 'Included for Abu Dhabi Govt',
                timeline: 'Per recruitment cycle',
              ),
              standard: PricingTier(
                cost: 'Included',
                timeline: 'Per recruitment cycle',
              ),
              documentRequirements: ['Vacancy brief', 'Selection criteria'],
            ),
            SubService(
              id: 'dge_leadership',
              name: 'Leadership & Career Development',
              serviceTypeId: 'dge_services',
              premium: PricingTier(
                cost: 'Program-specific',
                timeline: '4-8 weeks',
              ),
              standard: PricingTier(
                cost: 'Program-specific',
                timeline: '8-12 weeks',
              ),
              documentRequirements: [
                'Participant nominations',
                'Competency gaps',
              ],
            ),
            SubService(
              id: 'dge_training_skills',
              name: 'Training & Skill Development',
              serviceTypeId: 'dge_services',
              premium: PricingTier(
                cost: 'Program-specific',
                timeline: 'Per training cycle',
              ),
              standard: PricingTier(
                cost: 'Program-specific',
                timeline: 'Per training cycle',
              ),
              documentRequirements: [
                'Skills development plan',
                'Nomination approvals',
              ],
            ),
            SubService(
              id: 'dge_performance_management',
              name: 'Performance Management',
              serviceTypeId: 'dge_services',
              premium: PricingTier(
                cost: 'Included',
                timeline: 'Annual/quarterly cycles',
              ),
              standard: PricingTier(
                cost: 'Included',
                timeline: 'Annual/quarterly cycles',
              ),
              documentRequirements: [
                'Employee KPIs',
                'Previous appraisal data',
              ],
            ),
            SubService(
              id: 'dge_organizational_development',
              name: 'Organizational Development',
              serviceTypeId: 'dge_services',
              premium: PricingTier(
                cost: 'Consultation-based',
                timeline: 'Project-specific',
              ),
              standard: PricingTier(
                cost: 'Consultation-based',
                timeline: 'Project-specific',
              ),
              documentRequirements: [
                'Org structure charts',
                'Change management objectives',
              ],
            ),
            SubService(
              id: 'dge_emiratisation',
              name: 'Emiratisation & Engagement Programs',
              serviceTypeId: 'dge_services',
              premium: PricingTier(cost: 'Included', timeline: 'Ongoing'),
              standard: PricingTier(cost: 'Included', timeline: 'Ongoing'),
              documentRequirements: [
                'Current Emiratisation data',
                'Engagement survey results',
              ],
            ),
          ],
        ),
        ServiceType(
          id: 'sharjah_hr_services',
          name: 'Sharjah Dept. of Human Resources',
          categoryId: 'gov_hr',
          subServices: [
            SubService(
              id: 'shj_policy_info',
              name: 'HR Policy & Benefits Information',
              serviceTypeId: 'sharjah_hr_services',
              premium: PricingTier(
                cost: 'Included',
                timeline: 'Same day response',
              ),
              standard: PricingTier(
                cost: 'Included',
                timeline: '2 working days',
              ),
              documentRequirements: ['Employee ID', 'Policy inquiry details'],
            ),
            SubService(
              id: 'shj_leave_management',
              name: 'Leave & Benefits Management',
              serviceTypeId: 'sharjah_hr_services',
              premium: PricingTier(cost: 'Included', timeline: 'Per request'),
              standard: PricingTier(cost: 'Included', timeline: 'Per request'),
              documentRequirements: [
                'Leave application',
                'Supporting documents (medical, travel, etc.)',
              ],
            ),
            SubService(
              id: 'shj_career_training',
              name: 'Career Development & Training',
              serviceTypeId: 'sharjah_hr_services',
              premium: PricingTier(
                cost: 'Program-specific',
                timeline: 'Course duration',
              ),
              standard: PricingTier(
                cost: 'Program-specific',
                timeline: 'Course duration',
              ),
              documentRequirements: ['Training request', 'Development plan'],
            ),
            SubService(
              id: 'shj_training_opportunities',
              name: 'Training Opportunities',
              serviceTypeId: 'sharjah_hr_services',
              premium: PricingTier(
                cost: 'Program-specific',
                timeline: 'As scheduled',
              ),
              standard: PricingTier(
                cost: 'Program-specific',
                timeline: 'As scheduled',
              ),
              documentRequirements: [
                'Training nomination',
                'Eligibility proof',
              ],
            ),
          ],
        ),
      ],
    ),

    // Banking Services
    ServiceCategory(
      id: 'banking',
      name: 'Banking Services',
      description:
          'Business and personal banking solutions including account opening and payment services',
      icon: 'account_balance',
      color: '0xFF4CAF50',
      serviceTypes: [
        ServiceType(
          id: 'corporate_banking',
          name: 'Corporate Bank Accounts',
          description:
              'Business banking accounts for companies operating in the UAE',
          icon: 'business',
          categoryId: 'banking',
          subServices: [
            SubService(
              id: 'business_current_account',
              name: 'Business Current Account',
              description:
                  'Essential operating account for daily business transactions and payments',
              icon: 'account_balance_wallet',
              serviceTypeId: 'corporate_banking',
              premium: PricingTier(
                cost: '2000-3500',
                timeline: '3-5 working days',
              ),
              standard: PricingTier(
                cost: '1200-2000',
                timeline: '5-7 working days',
              ),
              documentRequirements: [
                'Trade license & MOA',
                'Passport/visa/Emirates ID for all partners',
                'Board resolution/partner resolution',
                'Tenancy contract (Ejari) & utility bill',
                'Business plan & source of funds proof',
              ],
            ),
            SubService(
              id: 'corporate_savings_account',
              name: 'Corporate Savings Account',
              description:
                  'Interest-bearing account for business surplus funds and reserve capital',
              icon: 'savings',
              serviceTypeId: 'corporate_banking',
              premium: PricingTier(
                cost: '1500-2800',
                timeline: '4-6 working days',
              ),
              standard: PricingTier(
                cost: '900-1500',
                timeline: '6-8 working days',
              ),
              documentRequirements: [
                'Trade license copy',
                'Shareholder passports',
                'Company stamp & specimen signatures',
                'Audited/unaudited financials',
                'Projected cash-flow statement',
              ],
            ),
            SubService(
              id: 'merchant_account',
              name: 'Merchant / Payment Gateway Account',
              description:
                  'Accept online and card payments for e-commerce and retail businesses',
              icon: 'credit_card',
              serviceTypeId: 'corporate_banking',
              premium: PricingTier(cost: '2500-4000', timeline: '2-3 weeks'),
              standard: PricingTier(cost: '1800-2500', timeline: '3-4 weeks'),
              documentRequirements: [
                'Trade license & MOA',
                'Website/platform screenshots',
                'Payment gateway agreements',
                'Processing volumes & chargeback policy',
              ],
            ),
            SubService(
              id: 'multicurrency_account',
              name: 'Multi-currency Account',
              serviceTypeId: 'corporate_banking',
              premium: PricingTier(
                cost: '1800-2600',
                timeline: '3-5 working days',
              ),
              standard: PricingTier(
                cost: '1200-1800',
                timeline: '5-7 working days',
              ),
              documentRequirements: [
                'Trade license & shareholder IDs',
                'Cross-border transaction history',
                'Customer/supplier contracts',
                'Sanctions/compliance declarations',
              ],
            ),
          ],
        ),
        ServiceType(
          id: 'personal_banking',
          name: 'Personal Banking',
          categoryId: 'banking',
          subServices: [
            SubService(
              id: 'savings_account',
              name: 'Savings Account',
              serviceTypeId: 'personal_banking',
              premium: PricingTier(
                cost: '600-900',
                timeline: '1-2 working days',
              ),
              standard: PricingTier(
                cost: '350-500',
                timeline: '3 working days',
              ),
              documentRequirements: [
                'Passport copy',
                'Residence visa & Emirates ID',
                'Proof of address (utility bill/Ejari)',
                'Bank reference letter',
              ],
            ),
            SubService(
              id: 'current_account',
              name: 'Current Account',
              serviceTypeId: 'personal_banking',
              premium: PricingTier(
                cost: '600-900',
                timeline: '1-2 working days',
              ),
              standard: PricingTier(
                cost: '350-500',
                timeline: '3 working days',
              ),
              documentRequirements: [
                'Passport & visa copy',
                'Emirates ID',
                'Salary certificate or bank statement',
                'Employer NOC (if required)',
              ],
            ),
            SubService(
              id: 'salary_account',
              name: 'Salary Account',
              serviceTypeId: 'personal_banking',
              premium: PricingTier(cost: 400, timeline: '1 working day'),
              standard: PricingTier(cost: 250, timeline: '2-3 working days'),
              documentRequirements: [
                'Passport & Emirates ID',
                'Residence visa',
                'Salary certificate',
                'Employment contract/WPS record',
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
      description:
          'Corporate tax, VAT registration, and compliance services with FTA',
      icon: 'receipt_long',
      color: '0xFFFF9800',
      serviceTypes: [
        ServiceType(
          id: 'corporate_tax',
          name: 'Corporate Tax',
          description:
              'UAE Corporate Tax registration and filing services for businesses',
          icon: 'corporate_fare',
          categoryId: 'tax',
          subServices: [
            SubService(
              id: 'corp_registration',
              name: 'Registration',
              description:
                  'Register your business with the Federal Tax Authority for Corporate Tax',
              icon: 'app_registration',
              serviceTypeId: 'corporate_tax',
              premium: PricingTier(cost: 1000, timeline: '1-2 days'),
              standard: PricingTier(cost: 500, timeline: '2-3 working days'),
              documentRequirements: [
                'Valid Trade/Commercial License (including branch licenses if any)',
                'Certificate of Incorporation / Memorandum of Association / Partnership Agreement',
                'Commercial Registration Certificate (if issued separately)',
                'Passport & Emirates ID of owners with >25% shareholding',
                'Passport & Emirates ID of authorized signatory',
                'Proof of authorization (Power of Attorney or board resolution)',
                'Bank letter with account IBAN (optional)',
                'Accepted formats: PDF (max 15MB each)',
              ],
            ),
            SubService(
              id: 'corp_submission',
              name: 'Tax Submission',
              description:
                  'File quarterly and annual corporate tax returns with FTA',
              icon: 'description',
              serviceTypeId: 'corporate_tax',
              premium: PricingTier(cost: 700, timeline: '1 day'),
              standard: PricingTier(cost: 500, timeline: '2-3 working days'),
              documentRequirements: [
                'Audited financial statements',
                'Tax calculation data',
              ],
            ),
            SubService(
              id: 'corp_tax_deregistration',
              name: 'Corporate Tax Deregistration',
              description:
                  'Cancel corporate tax account when business ceases or becomes exempt',
              icon: 'do_not_disturb_on',
              serviceTypeId: 'corporate_tax',
              premium: PricingTier(
                cost: 'Request quote',
                timeline: '5-7 working days',
              ),
              standard: PricingTier(
                cost: 'FTA fees',
                timeline: '7-14 working days',
              ),
              documentRequirements: [
                'Reason for deregistration (Sale / Merger / Re-domiciliation / Cessation / Other)',
                'Documentary evidence of sale/merger/re-domiciliation/cessation (contracts, resolutions)',
                'Final corporate tax return and payment confirmation',
                'Audited/unaudited financial statements up to cessation date',
                'Clearance of outstanding tax liabilities (if any)',
                'Liquidation certificate or trade license cancellation (if applicable)',
                'Other relevant supporting documents',
                'Accepted file types: PDF, JPG, PNG, JPEG, XLSX (<=5MB each)',
              ],
            ),
          ],
        ),
        ServiceType(
          id: 'vat',
          name: 'VAT Services',
          description:
              'Registration, filing, refunds and group services for VAT',
          icon: 'calculate',
          categoryId: 'tax',
          subServices: [
            SubService(
              id: 'vat_registration',
              name: 'VAT Registration',
              serviceTypeId: 'vat',
              premium: PricingTier(cost: 1000, timeline: '1 day'),
              standard: PricingTier(cost: 500, timeline: '2-3 working days'),
              documentRequirements: [
                'Valid Trade License (include branch licenses if any)',
                'Certificate of Incorporation / MOA / Partnership Agreement (if applicable)',
                'Commercial registration certificate or licensing authority document',
                'Emirates ID & Passport of owners and authorized signatory',
                'Power of Attorney (if signatory not in MOA)',
                'Official turnover declaration letter (monthly sales & taxable supplies)',
                'Supporting revenue invoices / LPOs / contracts / ownership deeds / lease agreements',
                'At least 5 VAT invoices with values above threshold (for expenses justification)',
                'Expected revenues evidence (purchase orders, signed contracts)',
                'Bank letter with account details (company or individual for sole establishment)',
                'Customs information (if applicable)',
                'Club/charity/association registration docs (if applicable)',
                'Government Decree (if Federal/Emirate entity)',
                'Proof of ownership of premises (title deed or tenancy)',
                'Accepted formats: PDF & DOC (<=15MB each)',
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
            SubService(
              id: 'vat_deregistration',
              name: 'VAT Deregistration',
              description: 'Cancel VAT TRN when eligible under FTA rules',
              icon: 'remove_circle_outline',
              serviceTypeId: 'vat',
              premium: PricingTier(
                cost: 'Request quote',
                timeline: '3-5 working days',
              ),
              standard: PricingTier(
                cost: 'FTA fees',
                timeline: '5-10 working days',
              ),
              documentRequirements: [
                'Basis & sub-reason for deregistration selection',
                'Cancelled trade license / liquidation letter / board resolution (if ceased)',
                'Sale contract or amended license (if sold)',
                'Proof of cessation for natural person (activity stop evidence)',
                'Financial turnover templates (taxable income & expenses to date)',
                'Latest financial statements (Trial Balance / P&L / Balance Sheet)',
                'Letter from Ministry of Labour confirming number of employees (if required)',
                'Official declaration of not exceeding threshold in next 30 days (if below limits)',
                'Charts of business itinerary & supply chain (if outside scope/exempt)',
                'Sample invoices (if requested)',
                'Duplicate TRN support letter (if duplicate)',
                'Head office TRN certificate & delegation letter (for branch)',
                'Individual institution consolidated letter (for multiple sole establishments)',
                'Final VAT return & liability settlement proof',
                'Accepted file types: PDF, Excel, Docs, JPG, PNG, JPEG (<=5MB each)',
              ],
            ),
            SubService(
              id: 'vat_refund_excess',
              name: 'Refund of Excess Amounts to Registrants',
              description: 'Claim refunds when input tax exceeds output tax',
              icon: 'paid',
              serviceTypeId: 'vat',
              premium: PricingTier(
                cost: 'Included',
                timeline: '5-10 working days',
              ),
              standard: PricingTier(
                cost: 'FTA fees',
                timeline: '10-20 working days',
              ),
              documentRequirements: [
                'VAT returns showing excess credit',
                'Bank account IBAN confirmation',
              ],
            ),
            SubService(
              id: 'vat_refund_foreign_visitors',
              name: 'VAT Refund for Foreign Business Visitors',
              description: 'Refund scheme for non-UAE established businesses',
              icon: 'public',
              serviceTypeId: 'vat',
              premium: PricingTier(
                cost: 'Included',
                timeline: '20-30 working days',
              ),
              standard: PricingTier(
                cost: 'FTA fees',
                timeline: '30-45 working days',
              ),
              documentRequirements: [
                'Proof of business establishment abroad',
                'Eligible UAE tax invoices',
                'Passport copy',
              ],
            ),
            SubService(
              id: 'vat_change_apportionment',
              name: 'Changing the Input Tax Apportionment Method',
              description:
                  'Request approval for alternative apportionment method',
              icon: 'tune',
              serviceTypeId: 'vat',
              premium: PricingTier(
                cost: 'Included',
                timeline: '10-15 working days',
              ),
              standard: PricingTier(
                cost: 'FTA fees',
                timeline: '15-25 working days',
              ),
              documentRequirements: [
                'Current apportionment calculations',
                'Proposed method rationale and impact',
              ],
            ),
            SubService(
              id: 'vat_ecs_supplier_licensing',
              name: 'Exhibitions & Conferences Supplier Licensing',
              description: 'VAT special scheme supplier registration',
              icon: 'confirmation_number',
              serviceTypeId: 'vat',
              premium: PricingTier(
                cost: 'Included',
                timeline: '5-10 working days',
              ),
              standard: PricingTier(
                cost: 'FTA fees',
                timeline: '10-15 working days',
              ),
              documentRequirements: [
                'Scenario A (Space Supplier): Supplier License Request Form',
                'Valid business license with appropriate activity',
                'Official premises registration certificate (or Zoning Compliance Permit & site plan)',
                'Site plan of area (location, dimensions, hall size)',
                'Company profile signed by authorized signatory',
                'Lease contract or ownership document of premises',
                'Passport/Emirates ID of authorized signatory',
                'Scenario B (Event Organizer): Event Organizer License Request Form',
                'Valid business license (or certificate of incorporation for non-resident)',
                'Event permit from competent authority',
                'Sample ticket showing price & event name (if available)',
                'Passport/Emirates ID of authorized signatory',
              ],
            ),
            SubService(
              id: 'vat_group_registration',
              name: 'Tax Group Registration',
              description:
                  'Register two or more related entities as a VAT group',
              icon: 'group_add',
              serviceTypeId: 'vat',
              premium: PricingTier(
                cost: 'Request quote',
                timeline: '5-7 working days',
              ),
              standard: PricingTier(
                cost: 'FTA fees',
                timeline: '7-14 working days',
              ),
              documentRequirements: [
                'Valid trade license for each member',
                'Passport/Emirates ID of authorized signatory of each member',
                'Proof of authorization (POA/board resolution) for signatory',
                'Monthly turnover declarations (stamped, with financial evidences)',
                'Group structure chart showing representative member & all members',
                'No objection letters from each member authorizing representative member',
                'Legislation copy (if government entity)',
                'Taxable supplies evidence (audit reports, calc sheets, revenue forecast, invoices, contracts)',
                'Taxable expenses evidence (expense budget, audit/unaudited financials)',
                'Articles of Association / Partnership Agreement',
                'Certificate of Incorporation (if applicable)',
                'Ownership information documents',
                'Customs details (if applicable)',
                'Club/charity/association registration docs (if applicable)',
                'Government Decree (if Federal/Emirate entity)',
                'Organization profile & activity summary (if Other legal person)',
                'Emirates ID & passport of manager, owner, senior management',
                'Property title deed (if applicable)',
                'Accepted file types: PDF, JPG, PNG, JPEG (<=5MB each)',
                'Required forms: taxable supplies turnover template; taxable expenses turnover template; turnover declaration letter form',
              ],
            ),
            SubService(
              id: 'vat_group_amendment',
              name: 'Tax Group Records Amendment',
              description: 'Add/remove members or update VAT group details',
              icon: 'manage_accounts',
              serviceTypeId: 'vat',
              premium: PricingTier(
                cost: 'Included',
                timeline: '3-5 working days',
              ),
              standard: PricingTier(
                cost: 'FTA fees',
                timeline: '5-10 working days',
              ),
              documentRequirements: [
                'Addition: trade licenses, passports/Emirates IDs of new member authorized signatory',
                'Addition: authorization proof (POA or board resolution)',
                'Addition: monthly turnover declaration + supporting invoices/contracts/title deeds/lease agreements',
                'Addition: updated group structure & no objection letters',
                'Removal: proof of no longer meeting tax group requirements',
                'Removal: updated group structure post-removal',
                'Financial audit report (if requested)',
                'Turnover declaration templates (taxable supplies & taxable expenses)',
                'Accepted file types: PDF, Excel, Docs, JPG, PNG, JPEG (<=5MB each)',
              ],
            ),
            SubService(
              id: 'vat_group_deregistration',
              name: 'Deregistration of Tax Groups',
              description: 'Cancel the VAT group registration',
              icon: 'person_remove',
              serviceTypeId: 'vat',
              premium: PricingTier(
                cost: 'Included',
                timeline: '5-7 working days',
              ),
              standard: PricingTier(
                cost: 'FTA fees',
                timeline: '7-14 working days',
              ),
              documentRequirements: [
                'Proof of not meeting tax group requirements OR discretionary deregistration request',
                'Turnover declarations (taxable income & expenses from effective registration date to current)',
                'Final VAT returns & liability settlement',
                'Supporting financial statements (Trial Balance, P&L, Balance Sheet)',
                'Any relevant board resolutions',
              ],
            ),
            SubService(
              id: 'vat_refund_tourists',
              name: 'VAT Refund for Tourists',
              description: 'Retail tourist refund scheme payouts',
              icon: 'luggage',
              serviceTypeId: 'vat',
              premium: PricingTier(
                cost: 'Included',
                timeline: 'Same day to 5 days',
              ),
              standard: PricingTier(
                cost: 'No service fee',
                timeline: 'Same day',
              ),
              documentRequirements: [
                'Eligible tax invoices',
                'Passport and boarding pass',
              ],
            ),
            SubService(
              id: 'tourist_refund_retailer_registration',
              name: 'Retailer Registration in Tourist Refund Scheme',
              description:
                  'Register as participating retailer for tourist refunds',
              icon: 'storefront',
              serviceTypeId: 'vat',
              premium: PricingTier(
                cost: 'Included',
                timeline: '5-7 working days',
              ),
              standard: PricingTier(
                cost: 'FTA fees',
                timeline: '7-10 working days',
              ),
              documentRequirements: [
                'Trade license',
                'POS integration details',
              ],
            ),
            SubService(
              id: 'vat_refund_new_residence',
              name: 'Tax Refund for UAE Nationals Building New Residences',
              description: 'VAT refund on construction of a new home',
              icon: 'home',
              serviceTypeId: 'vat',
              premium: PricingTier(
                cost: 'Included',
                timeline: '15-25 working days',
              ),
              standard: PricingTier(
                cost: 'FTA fees',
                timeline: '25-45 working days',
              ),
              documentRequirements: [
                'Proof of UAE nationality',
                'Completion certificate',
                'Tax invoices for materials/services',
              ],
            ),
            SubService(
              id: 'vat_refund_mosques',
              name: 'Refund of Input Tax on Mosques',
              description:
                  'Refund of input tax incurred on construction/operation of mosques',
              icon: 'mosque',
              serviceTypeId: 'vat',
              premium: PricingTier(
                cost: 'Included',
                timeline: '20-30 working days',
              ),
              standard: PricingTier(
                cost: 'FTA fees',
                timeline: '30-45 working days',
              ),
              documentRequirements: [
                'Approval from relevant authority',
                'Eligible tax invoices',
              ],
            ),
            SubService(
              id: 'refunds_missions_diplomatic',
              name: 'VAT & Excise Refunds for Diplomatic Missions',
              description:
                  'Refunds for missions, diplomatic bodies and international organizations',
              icon: 'flag_circle',
              serviceTypeId: 'vat',
              premium: PricingTier(
                cost: 'Included',
                timeline: '20-30 working days',
              ),
              standard: PricingTier(
                cost: 'FTA fees',
                timeline: '30-45 working days',
              ),
              documentRequirements: [
                'Accreditation letter',
                'Eligible tax invoices',
              ],
            ),
          ],
        ),
        // Excise Tax
        ServiceType(
          id: 'excise_tax',
          name: 'Excise Tax Services',
          description: 'Registrations, designated zones and goods records',
          icon: 'inventory',
          categoryId: 'tax',
          subServices: [
            SubService(
              id: 'excise_tax_registration',
              name: 'Excise Tax Registration',
              description:
                  'Register for excise tax (tobacco, energy drinks, etc.)',
              icon: 'assignment_add',
              serviceTypeId: 'excise_tax',
              premium: PricingTier(
                cost: 'Request quote',
                timeline: '5-10 working days',
              ),
              standard: PricingTier(
                cost: 'FTA fees',
                timeline: '10-15 working days',
              ),
              documentRequirements: [
                'Valid Trade/Business License',
                'Passport / Emirates ID of authorized signatory',
                'Legislation / decree (if government entity)',
                'Proof of authorization for signatory (POA / board resolution)',
                'Official declaration of excise activity (production/import/stockpiling) & start date',
                'Product list with HS codes',
                'Bank letter validating account (IBAN)',
                'Articles of Association / Power of Attorney documents',
                'Certificate of Incorporation (if incorporated legal person)',
                'Partnership Agreement (if applicable)',
                'Ownership information documents',
                'Club/charity/association registration docs (if applicable)',
                'Government Decree (if Federal/Emirate entity)',
                'Organization profile & activity summary',
                'Emirates ID/passport of owners',
              ],
            ),
            SubService(
              id: 'excise_tax_deregistration',
              name: 'Excise Tax Deregistration',
              icon: 'remove_circle',
              description: 'Cancel excise registration if eligible',
              serviceTypeId: 'excise_tax',
              premium: PricingTier(
                cost: 'Included',
                timeline: '5-7 working days',
              ),
              standard: PricingTier(
                cost: 'FTA fees',
                timeline: '7-14 working days',
              ),
              documentRequirements: [
                'Reason for deregistration (no longer liable / cancellation / sale)',
                'Proof of cessation of excise activities (import/production/stockpiling)',
                'Financial Audit Report',
                'Declaration of intent not to conduct excise activities next 12 months',
                'Signed & stamped audited inventory stock for preceding 12 months',
                'Trade license cancellation certificate (if applicable)',
                'Amended MOA / sale contract (if business sold)',
              ],
            ),
            SubService(
              id: 'excise_goods_registration',
              name: 'Excise Goods Registration',
              icon: 'category',
              description: 'Register specific excise goods (SKUs)',
              serviceTypeId: 'excise_tax',
              premium: PricingTier(
                cost: 'Included',
                timeline: '5-7 working days',
              ),
              standard: PricingTier(
                cost: 'FTA fees',
                timeline: '7-10 working days',
              ),
              documentRequirements: [
                'Goods detailed specifications (ingredients, components)',
                'Pictures of goods and labels/packaging artwork',
                'Certificate of Compliance for Excise Tax (sweetened products)',
                'Product Registration Certificates (special nutrition beverages)',
                'Manufacturer’s Certificate (≥75% milk/dairy beverages)',
              ],
            ),
            SubService(
              id: 'excise_goods_amendment',
              name: 'Amendment of Excise Goods Record',
              icon: 'edit',
              description: 'Update registered excise goods details',
              serviceTypeId: 'excise_tax',
              premium: PricingTier(
                cost: 'Included',
                timeline: '3-5 working days',
              ),
              standard: PricingTier(
                cost: 'FTA fees',
                timeline: '5-7 working days',
              ),
              documentRequirements: [
                'Official request letter with all item details & price amendments',
                'Proof of company relation with brand',
                'Retail selling price proof (3 major retailers or 5 others; 3 different months)',
                'Reclassification requests: official letter, brand relation proof, evidence for reclassification',
                'Accepted file types: PDF, JPG, PNG, JPEG (<=5MB each)',
              ],
            ),
            SubService(
              id: 'excise_digital_tax_stamps',
              name: 'Digital Tax Stamps Request',
              icon: 'qr_code',
              description: 'Request DTS for tobacco products',
              serviceTypeId: 'excise_tax',
              premium: PricingTier(
                cost: 'SICPA fees',
                timeline: '3-5 working days',
              ),
              standard: PricingTier(
                cost: 'SICPA fees',
                timeline: '5-7 working days',
              ),
              documentRequirements: [
                'Excise goods registration approval',
                'Registration for Importer Form',
                'Certify system account setup details',
                'Factory/import plan specifics (production or import cycles)',
                'Non-Disclosure Agreement (NDA) from De La Rue (submitted later)',
              ],
            ),
            SubService(
              id: 'excise_dz_registration',
              name: 'Registration of Designated Zones',
              icon: 'map',
              description: 'Register a designated zone for excise tax',
              serviceTypeId: 'excise_tax',
              premium: PricingTier(
                cost: 'Request quote',
                timeline: '10-15 working days',
              ),
              standard: PricingTier(
                cost: 'FTA fees',
                timeline: '15-25 working days',
              ),
              documentRequirements: [
                'Official site plan (plot number) issued, stamped & signed by Free Zone Authority',
                'Detailed warehouse plan (areas & types of goods) signed & stamped',
                'Excise goods flow & movement plan',
                'Inventory system description letter + screenshots (signed & stamped)',
                'Declaration of movement procedures (entry/exit of excise goods)',
                'CCTV installation & operation evidence (images)',
                'Access control procedures letter + images of tools used',
                'Images showing goods & identification method',
                'Evidence of regular stock transaction logging & approved reports',
                '12 months monthly financial reports (value & excise tax amount)',
                'Monthly average value & excise tax amount for month-end holdings',
                'Estimate of excise tax suspended for goods entering zone',
                'Bank guarantee (original) or undertaking letter',
                'Passport/Emirates ID of authorized signatory',
                'Proof of authorization (POA / board resolution)',
                'Accepted file types: Excel, PDF, JPG, PNG, JPEG (<=5MB each)',
              ],
            ),
            SubService(
              id: 'excise_dz_renewal',
              name: 'Renewal of Designated Zone Registration',
              icon: 'autorenew',
              description: 'Renew designated zone status',
              serviceTypeId: 'excise_tax',
              premium: PricingTier(
                cost: 'Included',
                timeline: '5-10 working days',
              ),
              standard: PricingTier(
                cost: 'FTA fees',
                timeline: '10-15 working days',
              ),
              documentRequirements: [
                'Stock & record management system capability docs',
                'Entry/removal process documentation for excise goods',
                'Access control measures documentation',
                'Monitoring process for unpaid excise goods entering zone',
                'Monitoring process for transfers from/to other zones (unpaid excise tax)',
                'Financial guarantee calculation documents',
                'Warehouse keeper latest annual financial statements',
                'MOHRE certificate (number of employees)',
                'Official site plan (plot number)',
                'Detailed warehouse plan',
                'Excise goods flow & movement plan',
                'Inventory system description letter + screenshots',
                'Movement procedures declaration',
                'Physical security evidence (space adequacy, marking, locks, windows barriers, alarms, H&S certificate, perimeter fencing, controlled gates, trained security, access logs, lighting, robust CCTV)',
                'Access control procedures letter + images',
                'Images of goods & identification method',
                'Evidence of regular stock logging & approved reports',
                '12 months monthly financial reports (value & excise tax)',
                'Monthly average value & excise tax (month-end holdings)',
                'Estimate of suspended excise tax',
                'Financial guarantee & undertaking letter (if requested)',
                'Passport/Emirates ID & authorization proof of signatory',
                'Accepted file types: Excel, PDF, JPG, PNG, JPEG (<=5MB each)',
              ],
            ),
            SubService(
              id: 'excise_dz_deregistration',
              name: 'Deregistration of Designated Zones',
              icon: 'cancel',
              description: 'Cancel designated zone registration',
              serviceTypeId: 'excise_tax',
              premium: PricingTier(
                cost: 'Included',
                timeline: '5-10 working days',
              ),
              standard: PricingTier(
                cost: 'FTA fees',
                timeline: '10-15 working days',
              ),
              documentRequirements: [
                'Declaration of excise goods quantities on deregistration date (excise & selling price)',
                'Reason for deregistration declaration',
                'Liquidation/cancellation certificate or supporting evidence',
                'Letter listing owners shares, owners TRNs, share evidence, goods disclosure & responsibility affirmation',
                'Any other supporting documents',
              ],
            ),
            SubService(
              id: 'warehouse_keeper_registration',
              name: 'Warehouse Keeper Registration',
              icon: 'warehouse',
              description: 'Register as excise warehouse keeper',
              serviceTypeId: 'excise_tax',
              premium: PricingTier(
                cost: 'Request quote',
                timeline: '7-10 working days',
              ),
              standard: PricingTier(
                cost: 'FTA fees',
                timeline: '10-15 working days',
              ),
              documentRequirements: [
                'Valid Trade License/Business License',
                'Passport/Emirates ID of authorized signatory',
                'Proof of authorization (POA / board resolution)',
                'Declaration letter on entity letterhead describing excise goods activities (production/import/stockpiling) & start date',
              ],
            ),
            SubService(
              id: 'warehouse_keeper_amendment',
              name: 'Amendment of Warehouse Keeper Records',
              icon: 'manage_accounts',
              description: 'Update details for registered warehouse keeper',
              serviceTypeId: 'excise_tax',
              premium: PricingTier(
                cost: 'Included',
                timeline: '3-5 working days',
              ),
              standard: PricingTier(
                cost: 'FTA fees',
                timeline: '5-7 working days',
              ),
              documentRequirements: [
                'All updated company documents relevant to change',
                'Updated financial guarantee (if applicable)',
                'Any other documents required to be amended or added',
              ],
            ),
            SubService(
              id: 'excise_loss_damage_declaration',
              name: 'Declaration of Lost/Damaged Excise Goods',
              icon: 'report',
              description:
                  'Declare physical loss, natural shortage or lab samples',
              serviceTypeId: 'excise_tax',
              premium: PricingTier(
                cost: 'Included',
                timeline: '3-5 working days',
              ),
              standard: PricingTier(
                cost: 'FTA fees',
                timeline: '5-10 working days',
              ),
              documentRequirements: [
                'Incident report and evidence',
                'Inventory records',
              ],
            ),
          ],
        ),
        // Customs Clearance Companies
        ServiceType(
          id: 'customs_clearance',
          name: 'Customs Clearance Companies',
          description: 'Registration and management for clearance companies',
          icon: 'local_shipping',
          categoryId: 'tax',
          subServices: [
            SubService(
              id: 'customs_clearance_registration',
              name: 'Registration of Customs Clearance Companies',
              icon: 'assignment',
              description: 'Register a customs clearance company with FTA',
              serviceTypeId: 'customs_clearance',
              premium: PricingTier(
                cost: 'Request quote',
                timeline: '5-7 working days',
              ),
              standard: PricingTier(
                cost: 'FTA fees',
                timeline: '7-14 working days',
              ),
              documentRequirements: [
                'Phase 1: Registration Application in EmaraTax portal',
                'Phase 1: Valid Trade License attachment',
                'Phase 2: Two hard copies of Tax Service Agreement & Addendum (VAT clearing only)',
                'Phase 2: Original Financial Guarantee (VAT & Excise clearing company)',
                'Phase 3: FTA signed Tax Service Agreement & Addendum (VAT clearing company only)',
              ],
            ),
            SubService(
              id: 'clearance_company_guarantee_amendment',
              name: 'Amendment of Clearance Company Financial Guarantee',
              icon: 'security',
              description: 'Amend or update the financial guarantee',
              serviceTypeId: 'customs_clearance',
              premium: PricingTier(
                cost: 'Included',
                timeline: '3-5 working days',
              ),
              standard: PricingTier(
                cost: 'FTA fees',
                timeline: '5-7 working days',
              ),
              documentRequirements: [
                'Amendment application in EmaraTax portal',
                'Original or revised Financial Guarantee (TINCO / TINCE as applicable)',
              ],
            ),
            SubService(
              id: 'clearance_company_deregistration',
              name: 'Clearance Companies Deregistration',
              icon: 'disabled_by_default',
              description: 'Cancel clearance company registration',
              serviceTypeId: 'customs_clearance',
              premium: PricingTier(
                cost: 'Included',
                timeline: '5-7 working days',
              ),
              standard: PricingTier(
                cost: 'FTA fees',
                timeline: '7-14 working days',
              ),
              documentRequirements: [
                'De-registration application in EmaraTax portal',
              ],
            ),
          ],
        ),
        // Tax Agents & Agencies
        ServiceType(
          id: 'tax_agents',
          name: 'Tax Agents & Agencies',
          description: 'Registration and record management for agents/agencies',
          icon: 'support_agent',
          categoryId: 'tax',
          subServices: [
            SubService(
              id: 'tax_agent_registration',
              name: 'Tax Agent Registration',
              icon: 'person_add',
              description: 'Register as an FTA-approved tax agent',
              serviceTypeId: 'tax_agents',
              premium: PricingTier(
                cost: 'Request quote',
                timeline: '10-15 working days',
              ),
              standard: PricingTier(
                cost: 'FTA fees',
                timeline: '15-25 working days',
              ),
              documentRequirements: [
                'Natural Person: Bachelor/Master in tax/accounting/recognized scientific field OR alternative degree + recognized international tax cert',
                'Natural Person: Proof of experience (employment contract in law/tax/accounting)',
                'Natural Person: Police Clearance / Good Conduct Certificate',
                'Natural Person: IELTS/TOEFL (if language selected is English)',
                'Natural Person: Diploma certificate in VAT or Corporate Tax',
                'Natural Person: Emirates ID & Passport copies',
                'Natural Person: FTA Arabic exam results (if requested)',
                'Juridical Person: Business/Trade license (audit/tax/law firm)',
                'Juridical Person: Certificate of Incorporation',
                'Juridical Person: Letter of appointment of director/partner supervising services',
                'Professional indemnity insurance (individual or agency coverage)',
                'Accepted file types: PDF, DOC, DOCX (<=15MB each)',
              ],
            ),
            SubService(
              id: 'tax_agency_registration',
              name: 'Tax Agency Registration',
              icon: 'business',
              description: 'Register a tax agency with FTA',
              serviceTypeId: 'tax_agents',
              premium: PricingTier(
                cost: 'Request quote',
                timeline: '7-10 working days',
              ),
              standard: PricingTier(
                cost: 'FTA fees',
                timeline: '10-15 working days',
              ),
              documentRequirements: [
                'Valid trade/business license',
                'Professional indemnity insurance policy',
                'Passport/Emirates ID of authorized signatory',
                'Passport/Emirates ID of owners',
                'Memorandum of Association or Selling Contract',
                'Details of qualified tax agent(s) linked to agency',
                'Accepted file formats: PDF, DOC (<=15MB each)',
              ],
            ),
            SubService(
              id: 'taxagent_linking',
              name: 'Linking a Tax Agent to a Tax Agency',
              icon: 'link',
              description: 'Associate an approved agent with an agency',
              serviceTypeId: 'tax_agents',
              premium: PricingTier(
                cost: 'Included',
                timeline: '1-2 working days',
              ),
              standard: PricingTier(
                cost: 'FTA fees',
                timeline: '2-3 working days',
              ),
              documentRequirements: [
                'Agent TRN and agency TRN details',
                'Valid professional indemnity insurance policy listing agent or agent number',
                'Accepted formats: PDF, DOC (<=15MB each)',
              ],
            ),
            SubService(
              id: 'tax_agent_record_amendment',
              name: 'Amendment of Tax Agent Records',
              icon: 'edit_note',
              description: 'Update records for registered tax agents',
              serviceTypeId: 'tax_agents',
              premium: PricingTier(
                cost: 'Included',
                timeline: '2-3 working days',
              ),
              standard: PricingTier(
                cost: 'FTA fees',
                timeline: '3-5 working days',
              ),
              documentRequirements: [
                'Renewal: Updated passport, Emirates ID, residency visa',
                'Renewal: Letter from Tax Agency confirming employment',
                'Renewal: Police Clearance / Good Conduct Certificate',
                'Renewal: Valid Professional Indemnity Insurance',
                'Renewal: Tax Agent Status Renewal Declaration Form',
                'Delinking: Application by Tax Agent and Tax Agency',
                'Amendment: Documents requiring update (qualifications/contact)',
              ],
            ),
          ],
        ),
        // Certificates
        ServiceType(
          id: 'tax_certificates',
          name: 'Certificates',
          description: 'Issuance of registration and tax certificates',
          icon: 'assignment_turned_in',
          categoryId: 'tax',
          subServices: [
            SubService(
              id: 'issuance_registration_certificates',
              name: 'Issuance of Registration Certificates',
              icon: 'badge',
              description: 'Obtain registration confirmation certificates',
              serviceTypeId: 'tax_certificates',
              premium: PricingTier(
                cost: 'Included',
                timeline: '1-2 working days',
              ),
              standard: PricingTier(
                cost: 'FTA fees',
                timeline: '2-3 working days',
              ),
              documentRequirements: [
                'None required (certificate printable directly)',
              ],
            ),
            SubService(
              id: 'issuance_tax_certificates',
              name: 'Issuance of Tax Certificates',
              icon: 'workspace_premium',
              description:
                  'Tax residency and commercial activities certificates',
              serviceTypeId: 'tax_certificates',
              premium: PricingTier(
                cost: 'Request quote',
                timeline: '3-5 working days',
              ),
              standard: PricingTier(
                cost: 'FTA fees',
                timeline: '5-7 working days',
              ),
              documentRequirements: [
                'Passport & Emirates ID',
                'Lease agreement & recent utility bills',
                'Bank statements',
                'For Clearance Certificate – Business Closing: turnover financial document & closure evidence',
                'For Clearance Certificate – Below Mandatory Threshold: turnover document',
                'For branch closure (non-registered VAT branch): proof of no pending liabilities & closure docs',
              ],
            ),
          ],
        ),
        // General Requests & Clarifications
        ServiceType(
          id: 'tax_requests',
          name: 'Requests & Clarifications',
          description: 'Inquiries, reconsiderations and exceptions',
          icon: 'help_outline',
          categoryId: 'tax',
          subServices: [
            SubService(
              id: 'request_submit_inquiry',
              name: 'Request to Submit Inquiry',
              icon: 'live_help',
              description: 'Submit an inquiry to the FTA',
              serviceTypeId: 'tax_requests',
              premium: PricingTier(
                cost: 'Included',
                timeline: '1-2 working days',
              ),
              standard: PricingTier(cost: 'Free', timeline: '2-5 working days'),
              documentRequirements: ['Inquiry details'],
            ),
            SubService(
              id: 'reconsideration_request',
              name: 'Reconsideration Request',
              icon: 'gavel',
              description: 'Ask FTA to reconsider a decision',
              serviceTypeId: 'tax_requests',
              premium: PricingTier(
                cost: 'Included',
                timeline: '10-20 working days',
              ),
              standard: PricingTier(
                cost: 'FTA fees',
                timeline: '20-30 working days',
              ),
              documentRequirements: [
                'Decision reference',
                'Supporting documents',
              ],
            ),
            SubService(
              id: 'tax_clarification_request',
              name: 'Tax Clarifications Request',
              icon: 'question_mark',
              description: 'Request a binding clarification from FTA',
              serviceTypeId: 'tax_requests',
              premium: PricingTier(
                cost: 'Included',
                timeline: '15-25 working days',
              ),
              standard: PricingTier(
                cost: 'FTA fees',
                timeline: '25-35 working days',
              ),
              documentRequirements: ['Facts and tax analysis'],
            ),
            SubService(
              id: 'admin_penalty_waiver_or_installment',
              name: 'Administrative Penalty Waiver / Installment',
              icon: 'receipt_long',
              description: 'Request waiver or installment of penalties',
              serviceTypeId: 'tax_requests',
              premium: PricingTier(
                cost: 'Included',
                timeline: '10-20 working days',
              ),
              standard: PricingTier(
                cost: 'FTA fees',
                timeline: '20-30 working days',
              ),
              documentRequirements: [
                'Penalty notice',
                'Hardship or justification evidence',
              ],
            ),
            SubService(
              id: 'complaint_feedback',
              name: 'Complaint Request / Feedback',
              icon: 'feedback',
              description: 'Submit complaints or general feedback',
              serviceTypeId: 'tax_requests',
              premium: PricingTier(
                cost: 'Included',
                timeline: '1-3 working days',
              ),
              standard: PricingTier(cost: 'Free', timeline: '3-5 working days'),
              documentRequirements: ['Details of complaint/feedback'],
            ),
            SubService(
              id: 'submit_suggestions',
              name: 'Submit Suggestions',
              icon: 'lightbulb',
              description: 'Share suggestions to improve services',
              serviceTypeId: 'tax_requests',
              premium: PricingTier(
                cost: 'Included',
                timeline: '1-3 working days',
              ),
              standard: PricingTier(cost: 'Free', timeline: '3-5 working days'),
              documentRequirements: ['Suggestion details'],
            ),
            SubService(
              id: 'admin_exception_request',
              name: 'Administrative Exception Request',
              icon: 'rule',
              description:
                  'Apply for exception from certain administrative rules',
              serviceTypeId: 'tax_requests',
              premium: PricingTier(
                cost: 'Included',
                timeline: '10-15 working days',
              ),
              standard: PricingTier(
                cost: 'FTA fees',
                timeline: '15-25 working days',
              ),
              documentRequirements: ['Justification and supporting evidence'],
            ),
            SubService(
              id: 'tax_records_amendment',
              name: 'Tax Records Amendment',
              icon: 'edit_attributes',
              description: 'Update taxpayer profile and records',
              serviceTypeId: 'tax_requests',
              premium: PricingTier(
                cost: 'Included',
                timeline: '2-3 working days',
              ),
              standard: PricingTier(
                cost: 'FTA fees',
                timeline: '3-5 working days',
              ),
              documentRequirements: [
                'Valid trade license',
                'Articles & Certificate of Incorporation (if available)',
                'Commercial registration certificate',
                'Continuity Certificate (old & new license numbers where applicable)',
                'Supporting documents for each amendment type (e.g., address change, ownership)',
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
      icon: 'account_balance_wallet',
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
      icon: 'description',
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
      icon: 'trending_up',
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
        ServiceType(
          id: 'expansion_consulting',
          name: 'Expansion Consulting',
          categoryId: 'expansion',
          subServices: [
            SubService(
              id: 'market_entry',
              name: 'Market Entry Strategy',
              serviceTypeId: 'expansion_consulting',
              premium: PricingTier(cost: 4000, timeline: '5 days'),
              standard: PricingTier(cost: 2500, timeline: '8 days'),
              documentRequirements: ['Business plan', 'market research'],
            ),
            SubService(
              id: 'location_analysis',
              name: 'Location Analysis & Feasibility',
              serviceTypeId: 'expansion_consulting',
              premium: PricingTier(cost: 3500, timeline: '4 days'),
              standard: PricingTier(cost: 2000, timeline: '7 days'),
              documentRequirements: ['Site requirements', 'budget'],
            ),
          ],
        ),
      ],
    ),

    // Banking & Finance (Extended)
    ServiceCategory(
      id: 'banking_extended',
      name: 'Banking & Finance',
      icon: 'account_balance',
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
        ServiceType(
          id: 'investment_advisory',
          name: 'Investment Advisory',
          categoryId: 'banking_extended',
          subServices: [
            SubService(
              id: 'portfolio_setup',
              name: 'Portfolio Setup & Review',
              serviceTypeId: 'investment_advisory',
              premium: PricingTier(cost: 2500, timeline: '3 days'),
              standard: PricingTier(cost: 1500, timeline: '5 days'),
              documentRequirements: ['Financial statements', 'risk profile'],
            ),
            SubService(
              id: 'wealth_management',
              name: 'Wealth Management Consultation',
              serviceTypeId: 'investment_advisory',
              premium: PricingTier(cost: 3500, timeline: '4 days'),
              standard: PricingTier(cost: 2000, timeline: '7 days'),
              documentRequirements: ['Investment goals', 'ID proof'],
            ),
          ],
        ),
      ],
    ),

    // Marketing & Sales Boost
    ServiceCategory(
      id: 'marketing',
      name: 'Marketing & Sales Boost',
      icon: 'smartphone',
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
        ServiceType(
          id: 'content_creation',
          name: 'Content Creation',
          categoryId: 'marketing',
          subServices: [
            SubService(
              id: 'video_production',
              name: 'Video Production',
              serviceTypeId: 'content_creation',
              premium: PricingTier(cost: 4000, timeline: '5 days'),
              standard: PricingTier(cost: 2500, timeline: '8 days'),
              documentRequirements: ['Script', 'brand guidelines'],
            ),
            SubService(
              id: 'blog_writing',
              name: 'Blog Writing & SEO',
              serviceTypeId: 'content_creation',
              premium: PricingTier(cost: 1200, timeline: '2 days'),
              standard: PricingTier(cost: 700, timeline: '4 days'),
              documentRequirements: ['Topics', 'keywords'],
            ),
          ],
        ),
      ],
    ),

    // International Trade & Logistics
    ServiceCategory(
      id: 'trade_logistics',
      name: 'International Trade & Logistics',
      icon: 'local_shipping',
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
        ServiceType(
          id: 'customs_advisory',
          name: 'Customs Advisory',
          categoryId: 'trade_logistics',
          subServices: [
            SubService(
              id: 'tariff_consult',
              name: 'Tariff & Duty Consultation',
              serviceTypeId: 'customs_advisory',
              premium: PricingTier(cost: 2000, timeline: '2 days'),
              standard: PricingTier(cost: 1200, timeline: '4 days'),
              documentRequirements: ['Product list', 'import docs'],
            ),
            SubService(
              id: 'compliance_training',
              name: 'Compliance Training',
              serviceTypeId: 'customs_advisory',
              premium: PricingTier(cost: 2500, timeline: '3 days'),
              standard: PricingTier(cost: 1500, timeline: '5 days'),
              documentRequirements: ['Employee list', 'training needs'],
            ),
          ],
        ),
      ],
    ),

    // HR & Talent Management
    ServiceCategory(
      id: 'hr_talent',
      name: 'HR & Talent Management',
      icon: 'groups',
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
      icon: 'gavel',
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
        ServiceType(
          id: 'corporate_compliance',
          name: 'Corporate Compliance',
          categoryId: 'legal',
          subServices: [
            SubService(
              id: 'policy_drafting',
              name: 'Policy Drafting & Review',
              serviceTypeId: 'corporate_compliance',
              premium: PricingTier(cost: 1800, timeline: '3 days'),
              standard: PricingTier(cost: 1200, timeline: '5 days'),
              documentRequirements: ['Existing policies', 'company profile'],
            ),
            SubService(
              id: 'risk_assessment',
              name: 'Risk Assessment & Mitigation',
              serviceTypeId: 'corporate_compliance',
              premium: PricingTier(cost: 2200, timeline: '4 days'),
              standard: PricingTier(cost: 1400, timeline: '7 days'),
              documentRequirements: ['Risk register', 'audit reports'],
            ),
          ],
        ),
      ],
    ),

    // Investor Attraction & Certification
    ServiceCategory(
      id: 'investor',
      name: 'Investor Attraction & Certification',
      icon: 'diamond',
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

    // Residency Services
    ServiceCategory(
      id: 'residency_services',
      name: 'Residency Services',
      icon: 'card_travel',
      color: '0xFF5C6BC0',
      serviceTypes: [
        ServiceType(
          id: 'residency_lifecycle',
          name: 'Residency Visa Lifecycle',
          categoryId: 'residency_services',
          subServices: [
            SubService(
              id: 'golden_residency',
              name: 'Golden Residency (5/10 years)',
              serviceTypeId: 'residency_lifecycle',
              premium: PricingTier(cost: 'AED 10,000+', timeline: '4-6 weeks'),
              standard: PricingTier(cost: 'AED 8,500+', timeline: '6-8 weeks'),
              documentRequirements: [
                'Passport & Emirates ID copies',
                'Proof of AED 2M investment or qualifying assets',
                'Health insurance',
                'Bank statements & salary letters',
              ],
            ),
            SubService(
              id: 'standard_residency',
              name: 'Residency Visa Issuance',
              serviceTypeId: 'residency_lifecycle',
              premium: PricingTier(
                cost: 'AED 5,000-6,000',
                timeline: '2-3 weeks',
              ),
              standard: PricingTier(
                cost: 'AED 3,800-4,800',
                timeline: '3-4 weeks',
              ),
              documentRequirements: [
                'Passport & colored visa page',
                'Entry permit',
                'Medical fitness & Emirates ID biometrics',
                'Sponsor documents (passport, salary certificate, tenancy)',
              ],
            ),
            SubService(
              id: 'residency_renewal_service',
              name: 'Residency Visa Renewal',
              serviceTypeId: 'residency_lifecycle',
              premium: PricingTier(
                cost: 'AED 3,200',
                timeline: '5-7 working days',
              ),
              standard: PricingTier(
                cost: 'AED 2,400',
                timeline: '7-10 working days',
              ),
              documentRequirements: [
                'Passport & current visa',
                'Emirates ID',
                'Medical fitness certificate',
                'Updated employment contract & tenancy',
              ],
            ),
            SubService(
              id: 'residency_data_amendment',
              name: 'Residency Data Amendment',
              serviceTypeId: 'residency_lifecycle',
              premium: PricingTier(
                cost: 'AED 900',
                timeline: '3-4 working days',
              ),
              standard: PricingTier(
                cost: 'AED 650',
                timeline: '5-7 working days',
              ),
              documentRequirements: [
                'Passport & visa copy',
                'Supporting proof for data change',
                'Emirates ID',
              ],
            ),
            SubService(
              id: 'residency_cancellation_service',
              name: 'Residency Visa Cancellation',
              serviceTypeId: 'residency_lifecycle',
              premium: PricingTier(
                cost: 'AED 225 (company)',
                timeline: '24 hours',
              ),
              standard: PricingTier(
                cost: 'AED 190 (individual)',
                timeline: '2 working days',
              ),
              documentRequirements: [
                'Passport & visa copy',
                'Cancellation form',
                'Sponsor authorization',
              ],
            ),
            SubService(
              id: 'green_residency',
              name: 'Green Residency',
              serviceTypeId: 'residency_lifecycle',
              premium: PricingTier(
                cost: 'AED 5,500-7,000',
                timeline: '3-4 weeks',
              ),
              standard: PricingTier(
                cost: 'AED 4,000-5,500',
                timeline: '4-6 weeks',
              ),
              documentRequirements: [
                'Passport copy',
                'Freelance permit or specialist contract',
                'Bank statements & salary slips',
                'Medical fitness & insurance',
              ],
            ),
          ],
        ),
        ServiceType(
          id: 'residency_support',
          name: 'Residency Support & Guidance',
          categoryId: 'residency_services',
          subServices: [
            SubService(
              id: 'residency_standard_docs',
              name: 'Standard Document Pack',
              serviceTypeId: 'residency_support',
              premium: PricingTier(
                cost: 'Included',
                timeline: 'Checklist review within 1 day',
              ),
              standard: PricingTier(cost: 'Included', timeline: 'Self-service'),
              documentRequirements: [
                'Original UAE birth certificate (new-borns)',
                'Colored passport copy with residence page',
                'Attested tenancy (60+ days validity)',
                'Latest DEWA bill',
                'Arabic salary certificate or attested labour contract',
                'Sponsor passport & Emirates ID',
                'Marriage/birth certificates (attested)',
              ],
            ),
            SubService(
              id: 'residency_fee_reference',
              name: 'Knowledge & Innovation Dirham Guidance',
              serviceTypeId: 'residency_support',
              premium: PricingTier(
                cost: 'Reference only',
                timeline: 'Real-time advisory',
              ),
              standard: PricingTier(
                cost: 'Reference only',
                timeline: 'Self-service',
              ),
              documentRequirements: [
                'Knowledge Dirham AED 10 per transaction',
                'Innovation Dirham AED 10 per transaction',
                'Fee inside UAE AED 500 (when applicable)',
                'Amer service fee (varies)',
              ],
            ),
          ],
        ),
      ],
    ),

    // Citizenship and Personal Status
    ServiceCategory(
      id: 'citizenship_status',
      name: 'Citizenship & Personal Status',
      icon: 'badge',
      color: '0xFF8E24AA',
      serviceTypes: [
        ServiceType(
          id: 'passport_services',
          name: 'Passport Issuance Services',
          categoryId: 'citizenship_status',
          subServices: [
            SubService(
              id: 'passport_renewal',
              name: 'Passport Renewal',
              serviceTypeId: 'passport_services',
              premium: PricingTier(
                cost: 'AED 400',
                timeline: '1-2 working days',
              ),
              standard: PricingTier(
                cost: 'AED 285',
                timeline: '3 working days',
              ),
              documentRequirements: [
                'Expired passport',
                'Emirates ID',
                'Recent passport photo',
              ],
            ),
            SubService(
              id: 'passport_replacement',
              name: 'Passport Replacement',
              serviceTypeId: 'passport_services',
              premium: PricingTier(
                cost: 'AED 600',
                timeline: '1-2 working days',
              ),
              standard: PricingTier(
                cost: 'AED 400',
                timeline: '3 working days',
              ),
              documentRequirements: [
                'Existing passport',
                'Emirates ID',
                'Supporting letter (if damaged)',
              ],
            ),
            SubService(
              id: 'new_passport',
              name: 'New Ordinary Passport',
              serviceTypeId: 'passport_services',
              premium: PricingTier(cost: 'AED 400', timeline: '2 working days'),
              standard: PricingTier(
                cost: 'AED 285',
                timeline: '4 working days',
              ),
              documentRequirements: [
                'Citizenship documents',
                'Family book copy',
                'Birth certificate',
                'Photos',
              ],
            ),
            SubService(
              id: 'lost_damaged_passport',
              name: 'Lost/Damaged Passport Replacement',
              serviceTypeId: 'passport_services',
              premium: PricingTier(
                cost: 'AED 600 + penalties',
                timeline: '2 working days',
              ),
              standard: PricingTier(
                cost: 'AED 400 + penalties',
                timeline: '3-4 working days',
              ),
              documentRequirements: [
                'Police report',
                'Passport copy (if available)',
                'Emirates ID',
                'Travel itinerary',
              ],
            ),
            SubService(
              id: 'passport_statements',
              name: 'Issuance of Statements',
              serviceTypeId: 'passport_services',
              premium: PricingTier(cost: 'AED 150', timeline: '1 working day'),
              standard: PricingTier(
                cost: 'AED 100',
                timeline: '2 working days',
              ),
              documentRequirements: [
                'Request letter',
                'Emirates ID',
                'Passport copy',
              ],
            ),
          ],
        ),
        ServiceType(
          id: 'family_book_service',
          name: 'Family Book Service',
          categoryId: 'citizenship_status',
          subServices: [
            SubService(
              id: 'family_book_issuance',
              name: 'Issuance of Family Book',
              serviceTypeId: 'family_book_service',
              premium: PricingTier(cost: 'AED 200', timeline: '2 working days'),
              standard: PricingTier(
                cost: 'AED 150',
                timeline: '3-4 working days',
              ),
              documentRequirements: [
                'Marriage certificate',
                'Birth certificates',
                'Citizenship proof',
                'Emirates ID',
              ],
            ),
          ],
        ),
      ],
    ),

    // Violator Follow Up
    ServiceCategory(
      id: 'violator_follow_up',
      name: 'Violator Follow Up',
      icon: 'warning',
      color: '0xFFFF7043',
      serviceTypes: [
        ServiceType(
          id: 'violation_management',
          name: 'Violation Management',
          categoryId: 'violator_follow_up',
          subServices: [
            SubService(
              id: 'violation_inquiry',
              name: 'Violation Inquiry',
              serviceTypeId: 'violation_management',
              premium: PricingTier(cost: 'AED 150', timeline: 'Same day'),
              standard: PricingTier(
                cost: 'AED 0 (self-service)',
                timeline: 'Online 24/7',
              ),
              documentRequirements: ['Passport or Emirates ID', 'Visa number'],
            ),
            SubService(
              id: 'fine_payment',
              name: 'Fine Payment Processing',
              serviceTypeId: 'violation_management',
              premium: PricingTier(
                cost: 'AED 50 service fee',
                timeline: 'Instant',
              ),
              standard: PricingTier(
                cost: 'AED 0 (portal payment)',
                timeline: 'Same day',
              ),
              documentRequirements: [
                'Fine reference number',
                'Bank card or payment voucher',
              ],
            ),
            SubService(
              id: 'violation_tracking',
              name: 'Violation Status Tracking',
              serviceTypeId: 'violation_management',
              premium: PricingTier(cost: 'Included', timeline: 'Daily updates'),
              standard: PricingTier(cost: 'Included', timeline: 'Self-service'),
              documentRequirements: ['Reference number', 'Contact email/phone'],
            ),
          ],
        ),
      ],
    ),

    // Entry and Exit
    ServiceCategory(
      id: 'entry_exit',
      name: 'Entry & Exit',
      icon: 'work',
      color: '0xFF4DD0E1',
      serviceTypes: [
        ServiceType(
          id: 'entry_exit_services',
          name: 'Entry & Exit Management',
          categoryId: 'entry_exit',
          subServices: [
            SubService(
              id: 'smart_gate_registration',
              name: 'Smart Gate Registration',
              serviceTypeId: 'entry_exit_services',
              premium: PricingTier(
                cost: 'AED 150 (assisted)',
                timeline: 'Same day',
              ),
              standard: PricingTier(
                cost: 'AED 0 (self-service)',
                timeline: '10 minutes',
              ),
              documentRequirements: ['Passport', 'Emirates ID', 'Biometrics'],
            ),
            SubService(
              id: 'entry_exit_inquiry',
              name: 'Entry/Exit Travel History Inquiry',
              serviceTypeId: 'entry_exit_services',
              premium: PricingTier(cost: 'AED 120', timeline: '1 working day'),
              standard: PricingTier(
                cost: 'AED 100',
                timeline: '2 working days',
              ),
              documentRequirements: [
                'Passport copy',
                'Application form',
                'Purpose of request',
              ],
            ),
            SubService(
              id: 'border_management_support',
              name: 'Border Management Support',
              serviceTypeId: 'entry_exit_services',
              premium: PricingTier(
                cost: 'AED 250',
                timeline: 'Same day coordination',
              ),
              standard: PricingTier(
                cost: 'AED 150',
                timeline: '1-2 working days',
              ),
              documentRequirements: [
                'Travel itinerary',
                'Passport & visa copies',
              ],
            ),
          ],
        ),
      ],
    ),

    // Establishment Support Services
    ServiceCategory(
      id: 'establishment_support',
      name: 'Establishments Support Services',
      icon: 'hotel',
      color: '0xFF26A69A',
      serviceTypes: [
        ServiceType(
          id: 'establishment_services',
          name: 'Establishment Services',
          categoryId: 'establishment_support',
          subServices: [
            SubService(
              id: 'est_sponsorship',
              name: 'Establishment Sponsorship',
              serviceTypeId: 'establishment_services',
              premium: PricingTier(
                cost: 'AED 1,500',
                timeline: '5 working days',
              ),
              standard: PricingTier(
                cost: 'AED 1,000',
                timeline: '7 working days',
              ),
              documentRequirements: [
                'Trade license copy',
                'Establishment card',
                'Authorized signatory passport',
                'Office lease/Ejari',
              ],
            ),
            SubService(
              id: 'employee_visa_quota',
              name: 'Employee Visa Quota Management',
              serviceTypeId: 'establishment_services',
              premium: PricingTier(
                cost: 'AED 1,200',
                timeline: '5 working days',
              ),
              standard: PricingTier(
                cost: 'AED 900',
                timeline: '7 working days',
              ),
              documentRequirements: [
                'Current quota report',
                'Employee roster',
                'Company profile & financials',
              ],
            ),
            SubService(
              id: 'establishment_data_update',
              name: 'Establishment Data Updates',
              serviceTypeId: 'establishment_services',
              premium: PricingTier(cost: 'AED 500', timeline: '3 working days'),
              standard: PricingTier(
                cost: 'AED 350',
                timeline: '5 working days',
              ),
              documentRequirements: [
                'Updated license copy',
                'New authorized signatory documents',
                'Tenancy contract',
              ],
            ),
          ],
        ),
      ],
    ),

    // Immigration Legal Services
    ServiceCategory(
      id: 'immigration_legal',
      name: 'Immigration Legal Services',
      icon: 'school',
      color: '0xFFAB47BC',
      serviceTypes: [
        ServiceType(
          id: 'immigration_legal_affairs',
          name: 'Legal Affairs',
          categoryId: 'immigration_legal',
          subServices: [
            SubService(
              id: 'legal_consultation',
              name: 'Legal Consultation',
              serviceTypeId: 'immigration_legal_affairs',
              premium: PricingTier(cost: 'AED 500', timeline: '1 hour session'),
              standard: PricingTier(
                cost: 'AED 350',
                timeline: 'Next-day session',
              ),
              documentRequirements: [
                'Case summary',
                'Contracts/visas',
                'Identification documents',
              ],
            ),
            SubService(
              id: 'dispute_resolution_legal',
              name: 'Immigration Dispute Resolution',
              serviceTypeId: 'immigration_legal_affairs',
              premium: PricingTier(cost: 'AED 2,500', timeline: '2-4 weeks'),
              standard: PricingTier(cost: 'AED 1,800', timeline: '4-6 weeks'),
              documentRequirements: [
                'Case files',
                'Correspondence',
                'Contracts & visas',
              ],
            ),
            SubService(
              id: 'legal_document_auth',
              name: 'Legal Document Authentication',
              serviceTypeId: 'immigration_legal_affairs',
              premium: PricingTier(cost: 'AED 750', timeline: '2 working days'),
              standard: PricingTier(
                cost: 'AED 500',
                timeline: '3-4 working days',
              ),
              documentRequirements: [
                'Original documents',
                'Notarized translations',
                'Proof of authority',
              ],
            ),
          ],
        ),
      ],
    ),

    // Service Access & Channels
    ServiceCategory(
      id: 'service_channels',
      name: 'Service Access Channels',
      icon: 'language',
      color: '0xFF42A5F5',
      serviceTypes: [
        ServiceType(
          id: 'channel_access',
          name: 'Access Options',
          categoryId: 'service_channels',
          subServices: [
            SubService(
              id: 'smart_portal',
              name: 'Smart GDRFA Portal',
              serviceTypeId: 'channel_access',
              premium: PricingTier(
                cost: 'Online 24/7',
                timeline: 'Immediate submission',
              ),
              standard: PricingTier(
                cost: 'Online 24/7',
                timeline: 'Immediate submission',
              ),
              documentRequirements: [
                'smart.gdrfad.gov.ae login',
                'UAE Pass or email OTP',
              ],
            ),
            SubService(
              id: 'gdrfa_website',
              name: 'GDRFA Website',
              serviceTypeId: 'channel_access',
              premium: PricingTier(
                cost: 'Online 24/7',
                timeline: 'Immediate submission',
              ),
              standard: PricingTier(
                cost: 'Online 24/7',
                timeline: 'Immediate submission',
              ),
              documentRequirements: [
                'gdrfad.gov.ae account',
                'Document uploads in PDF/JPG',
              ],
            ),
            SubService(
              id: 'gdrfa_mobile_app',
              name: 'GDRFA Mobile Application',
              serviceTypeId: 'channel_access',
              premium: PricingTier(
                cost: 'iOS/Android',
                timeline: 'Instant updates',
              ),
              standard: PricingTier(
                cost: 'iOS/Android',
                timeline: 'Instant updates',
              ),
              documentRequirements: [
                'UAE Pass login',
                'Push notification opt-in',
              ],
            ),
            SubService(
              id: 'amer_centers',
              name: 'Amer Service Centers',
              serviceTypeId: 'channel_access',
              premium: PricingTier(
                cost: 'AED 100 service fee',
                timeline: 'Same day ticket',
              ),
              standard: PricingTier(
                cost: 'AED 50 service fee',
                timeline: 'Same day ticket',
              ),
              documentRequirements: ['Physical documents', 'Token number'],
            ),
            SubService(
              id: 'online_services',
              name: 'Online Services 24/7',
              serviceTypeId: 'channel_access',
              premium: PricingTier(
                cost: 'Included',
                timeline: 'Automated tracking',
              ),
              standard: PricingTier(
                cost: 'Included',
                timeline: 'Self-service tracking',
              ),
              documentRequirements: [
                'Application number',
                'Email/SMS contact info',
              ],
            ),
          ],
        ),
        ServiceType(
          id: 'application_process',
          name: 'Standard Application Process',
          categoryId: 'service_channels',
          subServices: [
            SubService(
              id: 'process_overview',
              name: 'Application Checklist',
              serviceTypeId: 'application_process',
              premium: PricingTier(
                cost: 'Included',
                timeline: 'Guided session (30 min)',
              ),
              standard: PricingTier(cost: 'Included', timeline: 'Self-paced'),
              documentRequirements: [
                '1) Login',
                '2) Fill form',
                '3) Attach documents',
                '4) Pay fees',
                '5) Submit',
                '6) Track status',
              ],
            ),
          ],
        ),
      ],
    ),

    // Medical Fitness Services
    ServiceCategory(
      id: 'medical_fitness',
      name: 'Medical Fitness Services',
      icon: 'medical_services',
      color: '0xFFE57373',
      serviceTypes: [
        ServiceType(
          id: 'medical_tests',
          name: 'Medical Fitness Tests',
          categoryId: 'medical_fitness',
          subServices: [
            SubService(
              id: 'new_visa_medical',
              name: 'New Visa Medical Test',
              serviceTypeId: 'medical_tests',
              premium: PricingTier(cost: 520, timeline: 'Same day (VIP)'),
              standard: PricingTier(cost: 350, timeline: '24-48 hours'),
              documentRequirements: [
                'Entry permit copy',
                'Original passport',
                'Passport photo',
                'Contact number & email',
              ],
            ),
            SubService(
              id: 'renewal_medical',
              name: 'Visa Renewal Medical Test',
              serviceTypeId: 'medical_tests',
              premium: PricingTier(cost: 480, timeline: '24 hours'),
              standard: PricingTier(cost: 320, timeline: '24-48 hours'),
              documentRequirements: [
                'Residence visa copy',
                'Original passport',
                'Emirates ID (renewal cases)',
                'Passport photo',
              ],
            ),
            SubService(
              id: 'vip_medical',
              name: 'VIP Service (6-12 hours)',
              serviceTypeId: 'medical_tests',
              premium: PricingTier(cost: 1200, timeline: '6-12 hours'),
              standard: PricingTier(cost: 900, timeline: 'Within 24 hours'),
              documentRequirements: [
                'Passport',
                'Entry permit/residence visa',
                'Contact details',
                'Profession details (nursery, F&B, healthcare, etc.)',
              ],
            ),
            SubService(
              id: 'vvip_medical',
              name: 'VVIP Lounge Service',
              serviceTypeId: 'medical_tests',
              premium: PricingTier(
                cost: 2200,
                timeline: '30 minutes - few hours',
              ),
              standard: PricingTier(cost: 1500, timeline: 'Same day'),
              documentRequirements: [
                'Passport',
                'Residence visa/entry permit',
                'Emirates ID (if available)',
                'Preferred appointment window',
              ],
            ),
          ],
        ),
      ],
    ),

    // Emirates ID Services
    ServiceCategory(
      id: 'emirates_id',
      name: 'Emirates ID Services',
      icon: 'badge',
      color: '0xFF26A69A',
      serviceTypes: [
        ServiceType(
          id: 'emirates_id_services',
          name: 'Emirates ID Applications',
          categoryId: 'emirates_id',
          subServices: [
            SubService(
              id: 'emirates_id_new',
              name: 'New Emirates ID Application',
              serviceTypeId: 'emirates_id_services',
              premium: PricingTier(cost: 420, timeline: '48 hours'),
              standard: PricingTier(cost: 270, timeline: '3-5 working days'),
              documentRequirements: [
                'Valid passport',
                'Residence visa copy',
                'Entry permit',
                'Biometric data (fingerprints and photo)',
              ],
            ),
            SubService(
              id: 'emirates_id_renewal',
              name: 'Emirates ID Renewal',
              serviceTypeId: 'emirates_id_services',
              premium: PricingTier(cost: 380, timeline: '48 hours'),
              standard: PricingTier(cost: 250, timeline: '3-4 working days'),
              documentRequirements: [
                'Passport & visa copy',
                'Existing Emirates ID',
                'Updated photo (if requested)',
                'Biometrics (if data older than 10 years)',
              ],
            ),
            SubService(
              id: 'emirates_id_replacement',
              name: 'ID Replacement (Lost/Damaged)',
              serviceTypeId: 'emirates_id_services',
              premium: PricingTier(cost: 450, timeline: '48 hours'),
              standard: PricingTier(cost: 300, timeline: '3-4 working days'),
              documentRequirements: [
                'Passport & visa copy',
                'Police report (if lost)',
                'Existing Emirates ID (if damaged)',
                'Recent photograph',
              ],
            ),
            SubService(
              id: 'emirates_id_update',
              name: 'Update of Non-essential Data',
              serviceTypeId: 'emirates_id_services',
              premium: PricingTier(cost: 250, timeline: '2 working days'),
              standard: PricingTier(cost: 150, timeline: '3-4 working days'),
              documentRequirements: [
                'Emirates ID',
                'Supporting documents for new data',
                'Passport copy',
              ],
            ),
          ],
        ),
      ],
    ),

    // Business Setup & Licensing
    ServiceCategory(
      id: 'business_setup',
      name: 'Business Setup & Licensing',
      icon: 'business',
      color: '0xFF9575CD',
      serviceTypes: [
        ServiceType(
          id: 'trade_license_services',
          name: 'Trade License Services',
          categoryId: 'business_setup',
          subServices: [
            SubService(
              id: 'commercial_license',
              name: 'Commercial License',
              serviceTypeId: 'trade_license_services',
              premium: PricingTier(cost: 25000, timeline: '2-3 weeks'),
              standard: PricingTier(cost: 18000, timeline: '3-4 weeks'),
              documentRequirements: [
                'Passport & visa copy (investor/manager)',
                'Trade name approval',
                'Initial approval certificate',
                'MOA & shareholder passport copies',
                'Ejari tenancy contract',
                'Business plan & NOC (if required)',
              ],
            ),
            SubService(
              id: 'professional_license',
              name: 'Professional License',
              serviceTypeId: 'trade_license_services',
              premium: PricingTier(cost: 18000, timeline: '2-3 weeks'),
              standard: PricingTier(cost: 13000, timeline: '3-4 weeks'),
              documentRequirements: [
                'Attested educational certificates',
                'Professional qualification proof',
                'Passport & visa copies',
                'Trade name approval',
                'Tenancy agreement',
                'Service agent agreement (UAE national)',
              ],
            ),
            SubService(
              id: 'industrial_license',
              name: 'Industrial License',
              serviceTypeId: 'trade_license_services',
              premium: PricingTier(cost: 28000, timeline: '3-4 weeks'),
              standard: PricingTier(cost: 22000, timeline: '4-6 weeks'),
              documentRequirements: [
                'Approvals from relevant ministries',
                'Passport/residence copies',
                'Detailed business plan & factory report',
                'Environmental approvals',
                'Partnership contract & trade license copy',
              ],
            ),
            SubService(
              id: 'tourism_license',
              name: 'Tourism License',
              serviceTypeId: 'trade_license_services',
              premium: PricingTier(cost: 20000, timeline: '2-3 weeks'),
              standard: PricingTier(cost: 15000, timeline: '3-4 weeks'),
              documentRequirements: [
                'Tourism authority approvals',
                'Qualified staff certificates',
                'Business premises documentation',
                'Standard setup documents (passport, MOA, tenancy)',
              ],
            ),
            SubService(
              id: 'ecommerce_license',
              name: 'E-Commerce License',
              serviceTypeId: 'trade_license_services',
              premium: PricingTier(cost: 12000, timeline: '1-2 weeks'),
              standard: PricingTier(cost: 9000, timeline: '2-3 weeks'),
              documentRequirements: [
                'Website/platform details',
                'Payment gateway agreements',
                'Standard business setup documents',
              ],
            ),
          ],
        ),
        ServiceType(
          id: 'business_registration',
          name: 'Business Registration Steps',
          categoryId: 'business_setup',
          subServices: [
            SubService(
              id: 'location_and_activity',
              name: 'Location & Activity Selection',
              serviceTypeId: 'business_registration',
              premium: PricingTier(cost: 'AED 5,000+', timeline: '1-2 weeks'),
              standard: PricingTier(cost: 'AED 3,500+', timeline: '2-3 weeks'),
              documentRequirements: [
                'Chosen jurisdiction (Mainland/Free Zone/Offshore)',
                'Shortlisted business activities',
                'Shareholder passports & profiles',
              ],
            ),
            SubService(
              id: 'trade_name_reservation',
              name: 'Trade Name Reservation & Initial Approval',
              serviceTypeId: 'business_registration',
              premium: PricingTier(cost: 800, timeline: '1-2 days'),
              standard: PricingTier(cost: 600, timeline: '3-4 days'),
              documentRequirements: [
                '3 preferred trade names',
                'Passport copies',
                'Activity list',
              ],
            ),
            SubService(
              id: 'moa_preparation',
              name: 'MOA Preparation & External Approvals',
              serviceTypeId: 'business_registration',
              premium: PricingTier(cost: 4200, timeline: '3-5 days'),
              standard: PricingTier(cost: 2800, timeline: '5-7 days'),
              documentRequirements: [
                'Shareholding structure',
                'Capital distribution',
                'External approvals (if required)',
                'Attested documents (if foreign shareholders)',
              ],
            ),
            SubService(
              id: 'ded_submission',
              name: 'DED Submission & License Issuance',
              serviceTypeId: 'business_registration',
              premium: PricingTier(cost: 'AED 6,000+', timeline: '2-4 days'),
              standard: PricingTier(cost: 'AED 4,500+', timeline: '4-7 days'),
              documentRequirements: [
                'Complete application pack',
                'Ejari tenancy contract',
                'Payment receipts & approvals',
              ],
            ),
          ],
        ),
      ],
    ),

    // Document Attestation Services
    ServiceCategory(
      id: 'attestation',
      name: 'Document Attestation Services',
      icon: 'assignment',
      color: '0xFFFFC107',
      serviceTypes: [
        ServiceType(
          id: 'mofa_attestation',
          name: 'MOFA Attestation',
          categoryId: 'attestation',
          subServices: [
            SubService(
              id: 'educational_attestation',
              name: 'Educational Certificates',
              serviceTypeId: 'mofa_attestation',
              premium: PricingTier(cost: 750, timeline: '2-3 business days'),
              standard: PricingTier(cost: 450, timeline: '3-5 business days'),
              documentRequirements: [
                'Original degree/diploma/transcript',
                'Home country notarization & MOFA attestation',
                'UAE Embassy attestation',
                'Passport & UAE visa copies',
                'Arabic translation (if needed)',
              ],
            ),
            SubService(
              id: 'personal_attestation',
              name: 'Personal Documents',
              serviceTypeId: 'mofa_attestation',
              premium: PricingTier(cost: 600, timeline: '2-3 business days'),
              standard: PricingTier(cost: 350, timeline: '3-5 business days'),
              documentRequirements: [
                'Birth/marriage/police clearance certificates',
                'Home country attestations',
                'UAE Embassy stamp',
                'Passport & visa copy',
              ],
            ),
            SubService(
              id: 'commercial_attestation',
              name: 'Commercial Documents',
              serviceTypeId: 'mofa_attestation',
              premium: PricingTier(cost: 2600, timeline: '1-3 business days'),
              standard: PricingTier(cost: 2000, timeline: '3-4 business days'),
              documentRequirements: [
                'Contracts/POA/invoices/origin certificates',
                'Chamber of Commerce/legalization',
                'Company trade license & Emirates ID',
                'Courier details for return',
              ],
            ),
          ],
        ),
      ],
    ),

    // Real Estate Services
    ServiceCategory(
      id: 'real_estate',
      name: 'Real Estate Services',
      icon: 'location_city',
      color: '0xFF90CAF9',
      serviceTypes: [
        ServiceType(
          id: 'property_registration',
          name: 'Property Registration',
          categoryId: 'real_estate',
          subServices: [
            SubService(
              id: 'title_deed_issuance',
              name: 'Title Deed Issuance',
              serviceTypeId: 'property_registration',
              premium: PricingTier(cost: 4800, timeline: '3-5 working days'),
              standard: PricingTier(cost: 3500, timeline: '5-7 working days'),
              documentRequirements: [
                'Original title deed',
                'Sales agreement',
                'Buyer & seller Emirates IDs & passports',
                'Payment proof',
                'Developer NOC',
              ],
            ),
            SubService(
              id: 'ownership_transfer',
              name: 'Ownership Transfer',
              serviceTypeId: 'property_registration',
              premium: PricingTier(cost: 5200, timeline: '3-5 working days'),
              standard: PricingTier(cost: 3800, timeline: '5-7 working days'),
              documentRequirements: [
                'Title deed & sales contract',
                'Passports & Emirates IDs',
                'Bank clearance letter (if mortgaged)',
                'No objection certificate from developer',
              ],
            ),
            SubService(
              id: 'mortgage_registration',
              name: 'Mortgage Registration',
              serviceTypeId: 'property_registration',
              premium: PricingTier(cost: 4200, timeline: '3-4 working days'),
              standard: PricingTier(cost: 3000, timeline: '5 working days'),
              documentRequirements: [
                'Bank offer letter',
                'Title deed copies',
                'Passport & Emirates ID',
                'Insurance documents (if required)',
              ],
            ),
          ],
        ),
        ServiceType(
          id: 'tenancy_services',
          name: 'Tenancy Services',
          categoryId: 'real_estate',
          subServices: [
            SubService(
              id: 'ejari_registration',
              name: 'Ejari Registration',
              serviceTypeId: 'tenancy_services',
              premium: PricingTier(cost: 550, timeline: '1 working day'),
              standard: PricingTier(cost: 380, timeline: '2 working days'),
              documentRequirements: [
                'Tenancy contract',
                'Title deed copy',
                'Landlord & tenant Emirates IDs',
                'Passport copies',
              ],
            ),
            SubService(
              id: 'tenancy_renewal',
              name: 'Tenancy Contract Renewal',
              serviceTypeId: 'tenancy_services',
              premium: PricingTier(cost: 450, timeline: '1 working day'),
              standard: PricingTier(cost: 300, timeline: '2 working days'),
              documentRequirements: [
                'Renewed tenancy contract',
                'Previous Ejari certificate',
                'IDs/passports',
              ],
            ),
            SubService(
              id: 'tenancy_dispute',
              name: 'Tenancy Dispute Resolution',
              serviceTypeId: 'tenancy_services',
              premium: PricingTier(cost: 1200, timeline: '5-10 working days'),
              standard: PricingTier(cost: 800, timeline: '10-15 working days'),
              documentRequirements: [
                'Original contract & Ejari',
                'Payment receipts',
                'Evidence/photos/notices',
              ],
            ),
          ],
        ),
        ServiceType(
          id: 'rera_licensing',
          name: 'RERA Licensing & Registration',
          categoryId: 'real_estate',
          subServices: [
            SubService(
              id: 'agency_license_new',
              name: 'Real Estate Agency License - Issuance',
              serviceTypeId: 'rera_licensing',
              premium: PricingTier(
                cost: 'AED 5,000 + guarantee',
                timeline: '2-3 weeks',
              ),
              standard: PricingTier(
                cost: 'AED 3,500 + guarantee',
                timeline: '3-4 weeks',
              ),
              documentRequirements: [
                'Valid trade license',
                'Dubai office location lease',
                'Authorized representative documents',
                'Bank guarantee & professional certificates',
              ],
            ),
            SubService(
              id: 'agency_license_renewal_rera',
              name: 'Agency License Renewal',
              serviceTypeId: 'rera_licensing',
              premium: PricingTier(cost: 'AED 3,000', timeline: '1 week'),
              standard: PricingTier(
                cost: 'AED 2,000',
                timeline: '10 working days',
              ),
              documentRequirements: [
                'Updated compliance records',
                'Financial statements',
                'Insurance & office lease renewals',
              ],
            ),
            SubService(
              id: 'professional_registration',
              name: 'Real Estate Professional Registration',
              serviceTypeId: 'rera_licensing',
              premium: PricingTier(
                cost: 'AED 1,000',
                timeline: '5 working days',
              ),
              standard: PricingTier(
                cost: 'AED 500',
                timeline: '7 working days',
              ),
              documentRequirements: [
                'Passport/Emirates ID',
                'Employment letter from agency',
                'Experience certificates',
                'Passed competency exam',
              ],
            ),
            SubService(
              id: 'exhibition_license',
              name: 'Real Estate Exhibition License',
              serviceTypeId: 'rera_licensing',
              premium: PricingTier(cost: 'AED 5,000', timeline: '2 weeks'),
              standard: PricingTier(cost: 'AED 3,500', timeline: '3 weeks'),
              documentRequirements: [
                'Venue approval',
                'Developer participation list',
                'Marketing collateral',
                'Safety compliance plan',
              ],
            ),
          ],
        ),
        ServiceType(
          id: 'rera_transactions',
          name: 'RERA Property Transactions',
          categoryId: 'real_estate',
          subServices: [
            SubService(
              id: 'property_sale_registration',
              name: 'Property Sale Registration',
              serviceTypeId: 'rera_transactions',
              premium: PricingTier(
                cost: '2% of property value',
                timeline: '3-5 working days',
              ),
              standard: PricingTier(
                cost: '2% of property value',
                timeline: '5 working days',
              ),
              documentRequirements: [
                'Buyer & seller IDs',
                'Title deed',
                'Proof of payment & valuation certificate',
              ],
            ),
            SubService(
              id: 'lease_registration',
              name: 'Property Lease Registration',
              serviceTypeId: 'rera_transactions',
              premium: PricingTier(
                cost: '4% of annual rent',
                timeline: '1-2 working days',
              ),
              standard: PricingTier(
                cost: '4% of annual rent',
                timeline: '3 working days',
              ),
              documentRequirements: [
                'Lease contract',
                'Tenant & landlord IDs',
                'Payment proof',
              ],
            ),
            SubService(
              id: 'lease_renewal_rera',
              name: 'Lease Renewal Registration',
              serviceTypeId: 'rera_transactions',
              premium: PricingTier(
                cost: '4% of annual rent',
                timeline: '1 working day',
              ),
              standard: PricingTier(
                cost: '4% of annual rent',
                timeline: '2 working days',
              ),
              documentRequirements: [
                'Renewal terms',
                'Updated payment proof',
                'Existing Ejari certificate',
              ],
            ),
            SubService(
              id: 'title_transfer',
              name: 'Property Title Transfer',
              serviceTypeId: 'rera_transactions',
              premium: PricingTier(
                cost: 'Varies by transfer type',
                timeline: '3-5 working days',
              ),
              standard: PricingTier(
                cost: 'Varies',
                timeline: '5-7 working days',
              ),
              documentRequirements: [
                'Transfer deed',
                'POA if applicable',
                'Proof of payment',
              ],
            ),
            SubService(
              id: 'mortgage_registration_rera',
              name: 'Mortgage Registration',
              serviceTypeId: 'rera_transactions',
              premium: PricingTier(
                cost: 'AED 500-2,000',
                timeline: '3 working days',
              ),
              standard: PricingTier(
                cost: 'AED 500-2,000',
                timeline: '5 working days',
              ),
              documentRequirements: [
                'Bank mortgage agreement',
                'Title deed',
                'Borrower ID & valuation report',
              ],
            ),
            SubService(
              id: 'mortgage_release_rera',
              name: 'Mortgage Release',
              serviceTypeId: 'rera_transactions',
              premium: PricingTier(cost: 'AED 500', timeline: '3 working days'),
              standard: PricingTier(
                cost: 'AED 300',
                timeline: '5 working days',
              ),
              documentRequirements: [
                'Bank clearance letter',
                'Original mortgage registration',
              ],
            ),
          ],
        ),
        ServiceType(
          id: 'rera_disputes',
          name: 'RERA Dispute Resolution',
          categoryId: 'real_estate',
          subServices: [
            SubService(
              id: 'landlord_tenant_dispute',
              name: 'Landlord-Tenant Dispute Resolution',
              serviceTypeId: 'rera_disputes',
              premium: PricingTier(cost: 'AED 1,500', timeline: '2-4 weeks'),
              standard: PricingTier(cost: 'AED 800', timeline: '4-6 weeks'),
              documentRequirements: [
                'Lease contract & payment receipts',
                'Evidence of dispute (photos, notices)',
              ],
            ),
            SubService(
              id: 'transaction_dispute',
              name: 'Property Transaction Dispute',
              serviceTypeId: 'rera_disputes',
              premium: PricingTier(cost: 'AED 2,000', timeline: '4-8 weeks'),
              standard: PricingTier(cost: 'AED 1,200', timeline: '6-10 weeks'),
              documentRequirements: [
                'Sales agreement',
                'Payment schedule',
                'Developer/agent correspondence',
              ],
            ),
            SubService(
              id: 'agent_complaint',
              name: 'Real Estate Agent Complaint Handling',
              serviceTypeId: 'rera_disputes',
              premium: PricingTier(cost: 'AED 500', timeline: '2-3 weeks'),
              standard: PricingTier(cost: 'AED 300', timeline: '3-4 weeks'),
              documentRequirements: [
                'Complaint form',
                'Contract copy',
                'Proof of misconduct',
              ],
            ),
          ],
        ),
        ServiceType(
          id: 'rera_valuation',
          name: 'Valuation & Assessment',
          categoryId: 'real_estate',
          subServices: [
            SubService(
              id: 'property_valuation',
              name: 'Property Valuation',
              serviceTypeId: 'rera_valuation',
              premium: PricingTier(
                cost: 'AED 2,000',
                timeline: '3 working days',
              ),
              standard: PricingTier(
                cost: 'AED 500-1,500',
                timeline: '5 working days',
              ),
              documentRequirements: [
                'Property details & access',
                'Title deed',
                'Recent renovation info',
              ],
            ),
            SubService(
              id: 'market_reports',
              name: 'Market Analysis & Reports',
              serviceTypeId: 'rera_valuation',
              premium: PricingTier(cost: 'AED 1,500', timeline: '1 week'),
              standard: PricingTier(cost: 'AED 900', timeline: '10 days'),
              documentRequirements: [
                'Target area or property type',
                'Analysis objectives',
              ],
            ),
          ],
        ),
        ServiceType(
          id: 'rera_documentation',
          name: 'Documentation & Amendments',
          categoryId: 'real_estate',
          subServices: [
            SubService(
              id: 'document_verification',
              name: 'Property Document Verification',
              serviceTypeId: 'rera_documentation',
              premium: PricingTier(cost: 'AED 500', timeline: '3 working days'),
              standard: PricingTier(
                cost: 'AED 300',
                timeline: '5 working days',
              ),
              documentRequirements: [
                'Title deed or lease contract',
                'Supporting documents',
              ],
            ),
            SubService(
              id: 'document_amendment',
              name: 'Property Document Amendment',
              serviceTypeId: 'rera_documentation',
              premium: PricingTier(cost: 'AED 500', timeline: '3 working days'),
              standard: PricingTier(
                cost: 'AED 100-300',
                timeline: '5 working days',
              ),
              documentRequirements: [
                'Existing registration',
                'Correction request & evidence',
              ],
            ),
            SubService(
              id: 'property_noc',
              name: 'No Objection Certificate (NOC)',
              serviceTypeId: 'rera_documentation',
              premium: PricingTier(
                cost: 'AED 1,000',
                timeline: '3 working days',
              ),
              standard: PricingTier(
                cost: 'AED 700',
                timeline: '5 working days',
              ),
              documentRequirements: [
                'Property ownership proof',
                'Reason for NOC (sale, mortgage release, etc.)',
              ],
            ),
          ],
        ),
        ServiceType(
          id: 'rera_compliance',
          name: 'Complaints & Compliance',
          categoryId: 'real_estate',
          subServices: [
            SubService(
              id: 'consumer_complaint',
              name: 'Consumer Protection Complaint',
              serviceTypeId: 'rera_compliance',
              premium: PricingTier(cost: 'AED 300', timeline: '2-3 weeks'),
              standard: PricingTier(cost: 'AED 150', timeline: '3-4 weeks'),
              documentRequirements: [
                'Complaint form',
                'Evidence of fraud/misrepresentation',
                'Agency/agent details',
              ],
            ),
            SubService(
              id: 'developer_complaint',
              name: 'Developer Complaint',
              serviceTypeId: 'rera_compliance',
              premium: PricingTier(cost: 'AED 400', timeline: '3-5 weeks'),
              standard: PricingTier(cost: 'AED 200', timeline: '5-6 weeks'),
              documentRequirements: [
                'Purchase agreement',
                'Construction/progress proof',
                'Correspondence with developer',
              ],
            ),
            SubService(
              id: 'advertising_monitoring',
              name: 'Advertising Compliance Monitoring',
              serviceTypeId: 'rera_compliance',
              premium: PricingTier(cost: 'AED 500', timeline: '2 weeks'),
              standard: PricingTier(cost: 'AED 300', timeline: '3 weeks'),
              documentRequirements: [
                'Advertising samples',
                'Campaign approvals',
                'Property fact sheets',
              ],
            ),
          ],
        ),
      ],
    ),

    // Vehicle & Transportation Services (RTA Dubai)
    ServiceCategory(
      id: 'transport',
      name: 'Vehicle & Transportation Services (RTA)',
      icon: 'directions_car',
      color: '0xFFA1887F',
      serviceTypes: [
        ServiceType(
          id: 'driving_license_rta',
          name: 'RTA Driving License Services',
          categoryId: 'transport',
          subServices: [
            SubService(
              id: 'driving_license_application',
              name: 'Driving License Application (New)',
              serviceTypeId: 'driving_license_rta',
              premium: PricingTier(
                cost: 'AED 4,530 (total approx)',
                timeline: '6-8 weeks',
              ),
              standard: PricingTier(
                cost: 'AED 3,640 (total approx)',
                timeline: '8-10 weeks',
              ),
              documentRequirements: [
                'Valid ID/passport',
                'Residence visa',
                'Medical certificate (eye test + general health)',
                'Learning permit',
                'Driving school completion certificate',
              ],
            ),
            SubService(
              id: 'driving_license_renewal_rta',
              name: 'Driving License Renewal',
              serviceTypeId: 'driving_license_rta',
              premium: PricingTier(
                cost: 'AED 300 (over 21) / AED 100 (under 21)',
                timeline: '1-5 working days',
              ),
              standard: PricingTier(
                cost: 'AED 300 (over 21) / AED 100 (under 21)',
                timeline: '3-7 working days',
              ),
              documentRequirements: [
                'Current/expired driving license',
                'Valid ID/passport',
                'Medical fitness certificate (if over 60)',
              ],
            ),
            SubService(
              id: 'license_conversion',
              name: 'License Conversion',
              serviceTypeId: 'driving_license_rta',
              premium: PricingTier(cost: 850, timeline: '5 working days'),
              standard: PricingTier(cost: 600, timeline: '7 working days'),
              documentRequirements: [
                'Original license (eligible country)',
                'Passport & visa',
                'Emirates ID',
                'Eye test certificate',
              ],
            ),
            SubService(
              id: 'learners_permit',
              name: 'Learner\'s Permit',
              serviceTypeId: 'driving_license_rta',
              premium: PricingTier(
                cost: 'AED 250-300',
                timeline: '1-2 working days',
              ),
              standard: PricingTier(
                cost: 'AED 250-300',
                timeline: '2-3 working days',
              ),
              documentRequirements: [
                'Driving school enrollment certificate',
                'Medical clearance',
                'ID copy',
              ],
            ),
            SubService(
              id: 'international_permit',
              name: 'International Driving Permit',
              serviceTypeId: 'driving_license_rta',
              premium: PricingTier(cost: 450, timeline: 'Same day'),
              standard: PricingTier(cost: 300, timeline: '2 working days'),
              documentRequirements: [
                'UAE driving license copy',
                'Passport copy',
                'Passport photos',
                'Travel itinerary (optional)',
              ],
            ),
          ],
        ),
        ServiceType(
          id: 'vehicle_registration_rta',
          name: 'Vehicle Registration & Renewal',
          categoryId: 'transport',
          subServices: [
            SubService(
              id: 'new_vehicle_registration',
              name: 'Vehicle Registration (New)',
              serviceTypeId: 'vehicle_registration_rta',
              premium: PricingTier(
                cost: 'AED 350-420 (light) / AED 800 (heavy)',
                timeline: 'Same day',
              ),
              standard: PricingTier(
                cost: 'AED 350-420 (light) / AED 800 (heavy)',
                timeline: '1-2 working days',
              ),
              documentRequirements: [
                'Bill of sale',
                'Manufacturer\'s documents',
                'Insurance policy',
                'Customs clearance (imports)',
              ],
            ),
            SubService(
              id: 'vehicle_registration_renewal',
              name: 'Vehicle Registration Renewal',
              serviceTypeId: 'vehicle_registration_rta',
              premium: PricingTier(
                cost: 'AED 350 (light) / AED 800 (heavy)',
                timeline: 'Same day',
              ),
              standard: PricingTier(
                cost: 'AED 350 (light) / AED 800 (heavy)',
                timeline: '1-3 working days',
              ),
              documentRequirements: [
                'Current registration card',
                'Insurance certificate',
                'Vehicle inspection report',
                'ID/corporate documents',
              ],
            ),
            SubService(
              id: 'vehicle_ownership_transfer',
              name: 'Vehicle Ownership Transfer',
              serviceTypeId: 'vehicle_registration_rta',
              premium: PricingTier(
                cost: 'AED 350 (transfer) + AED 50 (selling)',
                timeline: 'Same day',
              ),
              standard: PricingTier(
                cost: 'AED 350 (transfer) + AED 50 (selling)',
                timeline: '1-2 working days',
              ),
              documentRequirements: [
                'Vehicle registration document',
                'ID/corporate documents of both parties',
                'Agreed bill of sale',
              ],
            ),
            SubService(
              id: 'export_certificate',
              name: 'Export Certificate',
              serviceTypeId: 'vehicle_registration_rta',
              premium: PricingTier(cost: 780, timeline: '2 working days'),
              standard: PricingTier(cost: 520, timeline: '4 working days'),
              documentRequirements: [
                'Passport & Emirates ID',
                'Vehicle registration',
                'Export declaration',
                'Customs clearance',
              ],
            ),
          ],
        ),
        ServiceType(
          id: 'rta_other_services',
          name: 'Other RTA Services',
          categoryId: 'transport',
          subServices: [
            SubService(
              id: 'traffic_violation_payment',
              name: 'Traffic Violation & Fine Payment',
              serviceTypeId: 'rta_other_services',
              premium: PricingTier(
                cost: 'AED 100-1,000+ (varies)',
                timeline: '24/7 online payment',
              ),
              standard: PricingTier(
                cost: 'AED 100-1,000+ (varies)',
                timeline: 'Payment within 30 days',
              ),
              documentRequirements: [
                'Fine notice number',
                'Vehicle registration number',
                'Driver\'s license number',
              ],
            ),
            SubService(
              id: 'vehicle_inspection',
              name: 'Vehicle Inspection',
              serviceTypeId: 'rta_other_services',
              premium: PricingTier(
                cost: 'AED 170-200',
                timeline: '20-30 minutes',
              ),
              standard: PricingTier(
                cost: 'AED 170-200',
                timeline: '30-45 minutes',
              ),
              documentRequirements: [
                'Vehicle registration',
                'Vehicle (for physical inspection)',
              ],
            ),
            SubService(
              id: 'license_plate_services',
              name: 'License Plate Services',
              serviceTypeId: 'rta_other_services',
              premium: PricingTier(
                cost: 'AED 35-50 (standard)',
                timeline: '1 day',
              ),
              standard: PricingTier(
                cost: 'AED 35-50 (standard)',
                timeline: '1-2 days',
              ),
              documentRequirements: [
                'Vehicle registration',
                'ID',
                'Application form',
              ],
            ),
            SubService(
              id: 'vehicle_impound_release',
              name: 'Vehicle Impound & Release Services',
              serviceTypeId: 'rta_other_services',
              premium: PricingTier(
                cost: 'Fines + AED 30-50/day storage',
                timeline: '1-3 hours',
              ),
              standard: PricingTier(
                cost: 'Fines + AED 30-50/day storage',
                timeline: '3-5 hours',
              ),
              documentRequirements: [
                'Payment of fines',
                'Vehicle inspection clearance',
                'Registration/insurance renewal',
              ],
            ),
          ],
        ),
      ],
    ),

    // Labour & Employment Services (MOHRE)
    ServiceCategory(
      id: 'labour',
      name: 'Labour & Employment Services (MOHRE)',
      icon: 'build',
      color: '0xFF4DB6AC',
      serviceTypes: [
        ServiceType(
          id: 'mohre_work_permits',
          name: 'Work Permit & Employment Services',
          categoryId: 'labour',
          subServices: [
            SubService(
              id: 'work_permit_issuance',
              name: 'Work Permit Issuance',
              serviceTypeId: 'mohre_work_permits',
              premium: PricingTier(
                cost: 'AED 500-1200',
                timeline: '3-5 working days (digital approval)',
              ),
              standard: PricingTier(
                cost: 'Varies by worker type',
                timeline: '5-7 working days',
              ),
              documentRequirements: [
                'Valid job offer from UAE employer',
                'Company trade license & establishment card',
                'Employee passport copy & personal photo',
                'Signed employment contract',
              ],
            ),
            SubService(
              id: 'work_permit_renewal_full',
              name: 'Work Permit Renewal',
              serviceTypeId: 'mohre_work_permits',
              premium: PricingTier(
                cost: 'AED 500-1000',
                timeline: '3 working days',
              ),
              standard: PricingTier(
                cost: 'Contract-based fees',
                timeline: '5 working days',
              ),
              documentRequirements: [
                'Active labour contract',
                'Passport & visa copy',
                'Updated salary details',
              ],
            ),
            SubService(
              id: 'work_permit_cancellation_full',
              name: 'Work Permit Cancellation',
              serviceTypeId: 'mohre_work_permits',
              premium: PricingTier(
                cost: 'AED 190-325 + Amer fees',
                timeline: '24-48 hours',
              ),
              standard: PricingTier(
                cost: 'AED 190-325',
                timeline: '2-3 working days',
              ),
              documentRequirements: [
                'Employee passport & visa copy',
                'Cancellation request (employee or employer)',
                'Clearance certificate / exit proof',
              ],
            ),
            SubService(
              id: 'domestic_work_permit',
              name: 'Domestic Worker Permit Issuance',
              serviceTypeId: 'mohre_work_permits',
              premium: PricingTier(cost: 'AED 300-500', timeline: '7-14 days'),
              standard: PricingTier(
                cost: 'AED 300-500',
                timeline: '10-14 days',
              ),
              documentRequirements: [
                'Employment contract',
                'Medical fitness certificate',
                'Background clearance',
                'Training completion (if applicable)',
              ],
            ),
            SubService(
              id: 'labour_contract_registration',
              name: 'Labour Contract Registration',
              serviceTypeId: 'mohre_work_permits',
              premium: PricingTier(
                cost: 'Included with permit',
                timeline: 'Same day digital approval',
              ),
              standard: PricingTier(
                cost: 'Included',
                timeline: '1-2 working days',
              ),
              documentRequirements: [
                'Employee & employer details',
                'Salary and benefits breakdown',
                'Job responsibilities & duration',
              ],
            ),
            SubService(
              id: 'labour_contract_amendment',
              name: 'Labour Contract Amendment',
              serviceTypeId: 'mohre_work_permits',
              premium: PricingTier(
                cost: 'AED 200-400',
                timeline: '3 working days',
              ),
              standard: PricingTier(
                cost: 'AED 150-250',
                timeline: '5 working days',
              ),
              documentRequirements: [
                'Existing contract',
                'Updated salary/position/duration details',
                'Mutual consent from both parties',
              ],
            ),
            SubService(
              id: 'wps_registration',
              name: 'WPS Registration',
              serviceTypeId: 'mohre_work_permits',
              premium: PricingTier(
                cost: 'AED 1200 service fee',
                timeline: '3 working days',
              ),
              standard: PricingTier(
                cost: 'AED 800 service fee',
                timeline: '5 working days',
              ),
              documentRequirements: [
                'Company trade license & establishment card',
                'Bank account linkage letter',
                'Employee salary list',
              ],
            ),
          ],
        ),
        ServiceType(
          id: 'mohre_disputes',
          name: 'Dispute Resolution & Grievances',
          categoryId: 'labour',
          subServices: [
            SubService(
              id: 'labour_dispute_resolution',
              name: 'Labour Dispute Resolution',
              serviceTypeId: 'mohre_disputes',
              premium: PricingTier(
                cost: 'Free mediation',
                timeline: '5-10 working days',
              ),
              standard: PricingTier(
                cost: 'Free',
                timeline: '10-15 working days',
              ),
              documentRequirements: [
                'Employment contract',
                'Correspondence & evidence',
                'Salary records',
              ],
            ),
            SubService(
              id: 'wage_claim',
              name: 'Wage Claim Filing',
              serviceTypeId: 'mohre_disputes',
              premium: PricingTier(
                cost: 'Free filing',
                timeline: 'Case-by-case',
              ),
              standard: PricingTier(cost: 'Free', timeline: 'Case-by-case'),
              documentRequirements: [
                'Salary slips or WPS statements',
                'Bank statements',
                'Proof of non-payment',
              ],
            ),
            SubService(
              id: 'employee_grievance',
              name: 'Employee Grievance Handling',
              serviceTypeId: 'mohre_disputes',
              premium: PricingTier(
                cost: 'Free digital submission',
                timeline: '7 working days',
              ),
              standard: PricingTier(cost: 'Free', timeline: '10 working days'),
              documentRequirements: [
                'Complaint form',
                'Evidence of violation (harassment, unsafe conditions, etc.)',
                'Employer details',
              ],
            ),
          ],
        ),
        ServiceType(
          id: 'mohre_establishment',
          name: 'Establishment & Business Services',
          categoryId: 'labour',
          subServices: [
            SubService(
              id: 'work_permit_quotas',
              name: 'Work Permit Quota Allocation',
              serviceTypeId: 'mohre_establishment',
              premium: PricingTier(
                cost: 'AED 1200',
                timeline: '5 working days',
              ),
              standard: PricingTier(
                cost: 'AED 800',
                timeline: '7 working days',
              ),
              documentRequirements: [
                'Business size & activity details',
                'Emiratisation compliance report',
                'Economic contribution proof',
              ],
            ),
            SubService(
              id: 'establishment_registration',
              name: 'Establishment Registration',
              serviceTypeId: 'mohre_establishment',
              premium: PricingTier(
                cost: 'AED 1500',
                timeline: '5 working days',
              ),
              standard: PricingTier(
                cost: 'AED 1000',
                timeline: '7 working days',
              ),
              documentRequirements: [
                'Trade license & registration documents',
                'Ownership details',
                'Bank information',
              ],
            ),
            SubService(
              id: 'establishment_record_update',
              name: 'Update Establishment Records',
              serviceTypeId: 'mohre_establishment',
              premium: PricingTier(cost: 'AED 500', timeline: '3 working days'),
              standard: PricingTier(
                cost: 'AED 350',
                timeline: '5 working days',
              ),
              documentRequirements: [
                'Change request (name, address, activity)',
                'Supporting legal documents',
              ],
            ),
            SubService(
              id: 'establishment_card',
              name: 'Establishment Card Issuance',
              serviceTypeId: 'mohre_establishment',
              premium: PricingTier(cost: 'AED 700', timeline: '3 working days'),
              standard: PricingTier(
                cost: 'AED 500',
                timeline: '5 working days',
              ),
              documentRequirements: [
                'Trade license copy',
                'Authorized signatory passport & Emirates ID',
                'Office lease',
              ],
            ),
            SubService(
              id: 'pro_card_service',
              name: 'PRO Card Issuance',
              serviceTypeId: 'mohre_establishment',
              premium: PricingTier(cost: 'AED 600', timeline: '3 working days'),
              standard: PricingTier(
                cost: 'AED 400',
                timeline: '5 working days',
              ),
              documentRequirements: [
                'PRO passport & Emirates ID',
                'Employment letter / authorization',
                'Background clearance',
              ],
            ),
            SubService(
              id: 'emiratisation_compliance',
              name: 'Emiratisation Compliance Advisory',
              serviceTypeId: 'mohre_establishment',
              premium: PricingTier(cost: 'AED 2000', timeline: '2 weeks'),
              standard: PricingTier(cost: 'AED 1500', timeline: '3 weeks'),
              documentRequirements: [
                'Current Emiratisation percentage',
                'Training program data',
                'Incentive eligibility proof',
              ],
            ),
          ],
        ),
        ServiceType(
          id: 'mohre_recruitment',
          name: 'Recruitment & Agency Services',
          categoryId: 'labour',
          subServices: [
            SubService(
              id: 'agency_license_issuance',
              name: 'Employment Agency License Issuance',
              serviceTypeId: 'mohre_recruitment',
              premium: PricingTier(
                cost: 'AED 5000+ bank guarantee',
                timeline: '3-4 weeks',
              ),
              standard: PricingTier(
                cost: 'AED 4000+ guarantee',
                timeline: '4-6 weeks',
              ),
              documentRequirements: [
                'Business license & office lease',
                'Bank guarantee',
                'Manager credentials',
              ],
            ),
            SubService(
              id: 'agency_license_renewal',
              name: 'Agency License Renewal',
              serviceTypeId: 'mohre_recruitment',
              premium: PricingTier(cost: 'AED 2500', timeline: '2 weeks'),
              standard: PricingTier(cost: 'AED 1800', timeline: '3 weeks'),
              documentRequirements: [
                'Updated compliance reports',
                'Financial statements',
                'Guarantee renewal proof',
              ],
            ),
            SubService(
              id: 'agency_license_amendment',
              name: 'Agency License Amendment',
              serviceTypeId: 'mohre_recruitment',
              premium: PricingTier(
                cost: 'AED 1500',
                timeline: '7 working days',
              ),
              standard: PricingTier(
                cost: 'AED 1000',
                timeline: '10 working days',
              ),
              documentRequirements: [
                'Existing license',
                'Requested amendment details',
                'Supporting approvals',
              ],
            ),
            SubService(
              id: 'agency_license_cancellation',
              name: 'Agency License Cancellation',
              serviceTypeId: 'mohre_recruitment',
              premium: PricingTier(cost: 'AED 1000', timeline: '2 weeks'),
              standard: PricingTier(cost: 'AED 700', timeline: '3 weeks'),
              documentRequirements: [
                'Clearance certificates',
                'Final settlement evidence',
                'Returned bank guarantee',
              ],
            ),
            SubService(
              id: 'agency_branch_opening',
              name: 'Recruitment Agency Branch Opening',
              serviceTypeId: 'mohre_recruitment',
              premium: PricingTier(cost: 'AED 2500', timeline: '3 weeks'),
              standard: PricingTier(cost: 'AED 1800', timeline: '4 weeks'),
              documentRequirements: [
                'Existing license',
                'Branch location approval',
                'Staffing plan',
              ],
            ),
          ],
        ),
        ServiceType(
          id: 'mohre_compliance',
          name: 'Compliance & Regulation',
          categoryId: 'labour',
          subServices: [
            SubService(
              id: 'labour_law_audit',
              name: 'Labour Law Compliance Audit',
              serviceTypeId: 'mohre_compliance',
              premium: PricingTier(cost: 'AED 3000', timeline: '2 weeks'),
              standard: PricingTier(cost: 'AED 2000', timeline: '3 weeks'),
              documentRequirements: [
                'Contract samples',
                'Wage payment data',
                'Leave & safety policies',
              ],
            ),
            SubService(
              id: 'contract_validation',
              name: 'Labour Contract Validation',
              serviceTypeId: 'mohre_compliance',
              premium: PricingTier(cost: 'AED 800', timeline: '3 working days'),
              standard: PricingTier(
                cost: 'AED 500',
                timeline: '5 working days',
              ),
              documentRequirements: [
                'Draft contract',
                'Benefit structure',
                'Role description',
              ],
            ),
            SubService(
              id: 'work_permit_inquiry',
              name: 'Work Permit Inquiry',
              serviceTypeId: 'mohre_compliance',
              premium: PricingTier(
                cost: 'AED 150 (assisted)',
                timeline: 'Same day',
              ),
              standard: PricingTier(
                cost: 'Free (self-service)',
                timeline: '24/7 portal',
              ),
              documentRequirements: [
                'Work permit number',
                'Employee & employer IDs',
              ],
            ),
          ],
        ),
      ],
    ),

    // Pension & Social Security
    ServiceCategory(
      id: 'pension',
      name: 'Pension & Social Security',
      icon: 'trending_up',
      color: '0xFF8D6E63',
      serviceTypes: [
        ServiceType(
          id: 'gpssa_services',
          name: 'GPSSA Registration',
          categoryId: 'pension',
          subServices: [
            SubService(
              id: 'gpssa_government',
              name: 'Government Sector Registration',
              serviceTypeId: 'gpssa_services',
              premium: PricingTier(cost: 1400, timeline: '5 working days'),
              standard: PricingTier(cost: 900, timeline: '7 working days'),
              documentRequirements: [
                'Insured start service form',
                'Emirates ID & family book copy',
                'Appointment decision/employment contract',
                'Health fitness certificate',
                'Existing pension certificate (if any)',
              ],
            ),
            SubService(
              id: 'gpssa_private',
              name: 'Private Sector Registration',
              serviceTypeId: 'gpssa_services',
              premium: PricingTier(cost: 1200, timeline: '5 working days'),
              standard: PricingTier(cost: 800, timeline: '7 working days'),
              documentRequirements: [
                'MOHRE-approved employment contract',
                'Passport & Emirates ID',
                'Company trade license',
                'Salary certificate',
              ],
            ),
            SubService(
              id: 'pension_calculation',
              name: 'Pension Calculation & Advisory',
              serviceTypeId: 'gpssa_services',
              premium: PricingTier(cost: 950, timeline: '3 working days'),
              standard: PricingTier(cost: 650, timeline: '5 working days'),
              documentRequirements: [
                'Employment history',
                'Salary slips',
                'Contribution statements',
              ],
            ),
            SubService(
              id: 'gratuity_processing',
              name: 'End-of-Service Gratuity',
              serviceTypeId: 'gpssa_services',
              premium: PricingTier(cost: 750, timeline: '5 working days'),
              standard: PricingTier(cost: 500, timeline: '7 working days'),
              documentRequirements: [
                'Final settlement calculation',
                'Employment contract',
                'Service termination documents',
              ],
            ),
          ],
        ),
      ],
    ),

    // Healthcare Services (MOHAP)
    ServiceCategory(
      id: 'healthcare',
      name: 'Healthcare Services (MOHAP)',
      icon: 'local_hospital',
      color: '0xFFEF5350',
      serviceTypes: [
        ServiceType(
          id: 'healthcare_admin',
          name: 'Healthcare Registration',
          categoryId: 'healthcare',
          subServices: [
            SubService(
              id: 'health_insurance',
              name: 'Health Insurance Enrollment',
              serviceTypeId: 'healthcare_admin',
              premium: PricingTier(cost: 1200, timeline: '2 working days'),
              standard: PricingTier(cost: 800, timeline: '4 working days'),
              documentRequirements: [
                'Passport & Emirates ID',
                'Visa copy',
                'Medical history (if required)',
                'Employer/sponsor approval',
              ],
            ),
            SubService(
              id: 'dha_provider',
              name: 'DHA Provider Registration',
              serviceTypeId: 'healthcare_admin',
              premium: PricingTier(cost: 3500, timeline: '2-3 weeks'),
              standard: PricingTier(cost: 2500, timeline: '4-6 weeks'),
              documentRequirements: [
                'Professional qualifications',
                'Home country license',
                'Experience certificates',
                'Passports & Emirates IDs',
                'Clinic/Facility documents',
              ],
            ),
            SubService(
              id: 'medical_licensing',
              name: 'Medical Licensing',
              serviceTypeId: 'healthcare_admin',
              premium: PricingTier(cost: 4200, timeline: '3-4 weeks'),
              standard: PricingTier(cost: 3200, timeline: '5-6 weeks'),
              documentRequirements: [
                'Primary source verification',
                'License exam results',
                'Good standing certificates',
              ],
            ),
            SubService(
              id: 'hospital_approvals',
              name: 'Hospital/Clinic Approvals',
              serviceTypeId: 'healthcare_admin',
              premium: PricingTier(cost: 5200, timeline: '4-6 weeks'),
              standard: PricingTier(cost: 3800, timeline: '6-8 weeks'),
              documentRequirements: [
                'Facility layout & tenancy',
                'Staff licensing',
                'Health & safety compliance',
              ],
            ),
          ],
        ),
        ServiceType(
          id: 'mohap_pharmaceutical',
          name: 'MOHAP Pharmaceutical Services',
          categoryId: 'healthcare',
          subServices: [
            SubService(
              id: 'pharma_import_permit',
              name: 'Pharmaceutical Import Permits',
              serviceTypeId: 'mohap_pharmaceutical',
              premium: PricingTier(
                cost: 'Varies by import type',
                timeline: '5-10 working days',
              ),
              standard: PricingTier(
                cost: 'Varies by import type',
                timeline: '7-14 working days',
              ),
              documentRequirements: [
                'Commercial license',
                'Warehouse license',
                'Company registration documents',
                'Import authorization letter',
              ],
            ),
            SubService(
              id: 'health_professional_licensing',
              name: 'Health Professional Licensing & Renewal',
              serviceTypeId: 'mohap_pharmaceutical',
              premium: PricingTier(
                cost: 'Varies by profession',
                timeline: '2-3 weeks',
              ),
              standard: PricingTier(
                cost: 'Varies by profession',
                timeline: '3-4 weeks',
              ),
              documentRequirements: [
                'Academic certificates',
                'Professional qualifications',
                'Experience certificates',
                'Passport copy',
                'Clearance from previous employer',
              ],
            ),
            SubService(
              id: 'medical_leave_attestation',
              name: 'Medical Leave & Report Attestation',
              serviceTypeId: 'mohap_pharmaceutical',
              premium: PricingTier(
                cost: 'Varies per attestation',
                timeline: '1-3 working days',
              ),
              standard: PricingTier(
                cost: 'Varies per attestation',
                timeline: '2-5 working days',
              ),
              documentRequirements: [
                'Medical report/leave document',
                'Employer request letter',
              ],
            ),
            SubService(
              id: 'clinical_trial_accreditation',
              name: 'Clinical Trial & Research Center Accreditation',
              serviceTypeId: 'mohap_pharmaceutical',
              premium: PricingTier(
                cost: 'Based on facility type',
                timeline: '4-6 weeks',
              ),
              standard: PricingTier(
                cost: 'Based on facility type',
                timeline: '6-8 weeks',
              ),
              documentRequirements: [
                'Facility documentation',
                'Compliance certificates',
                'Research protocol',
              ],
            ),
            SubService(
              id: 'narcotic_drug_import',
              name: 'Narcotic Drug Import Authorization',
              serviceTypeId: 'mohap_pharmaceutical',
              premium: PricingTier(
                cost: 'Licensing + approval fees',
                timeline: '2-4 weeks',
              ),
              standard: PricingTier(
                cost: 'Licensing + approval fees',
                timeline: '4-6 weeks',
              ),
              documentRequirements: [
                'Import license',
                'Health facility authorization',
                'DEA registration (international)',
                'Detailed inventory',
              ],
            ),
            SubService(
              id: 'pharmacy_home_delivery',
              name: 'Pharmacy Home Delivery Permit',
              serviceTypeId: 'mohap_pharmaceutical',
              premium: PricingTier(
                cost: 'Annual permit fee',
                timeline: '2 weeks',
              ),
              standard: PricingTier(
                cost: 'Annual permit fee',
                timeline: '3-4 weeks',
              ),
              documentRequirements: [
                'Pharmacy license',
                'Insurance documentation',
                'Logistics plan',
              ],
            ),
            SubService(
              id: 'narcotic_hospital_pharmacy',
              name: 'Narcotic Drugs Approval - Hospital Pharmacies',
              serviceTypeId: 'mohap_pharmaceutical',
              premium: PricingTier(
                cost: 'Application + inspection fees',
                timeline: '3-4 weeks',
              ),
              standard: PricingTier(
                cost: 'Application + inspection fees',
                timeline: '4-6 weeks',
              ),
              documentRequirements: [
                'Hospital pharmacy license',
                'Inventory management plan',
                'Security measures documentation',
              ],
            ),
            SubService(
              id: 'pharma_product_amendments',
              name: 'Pharmaceutical Product Amendments',
              serviceTypeId: 'mohap_pharmaceutical',
              premium: PricingTier(
                cost: 'Amendment review fee',
                timeline: '15-30 working days',
              ),
              standard: PricingTier(
                cost: 'Amendment review fee',
                timeline: '30-45 working days',
              ),
              documentRequirements: [
                'Original registration documents',
                'Amendment request letter',
                'New product specifications',
              ],
            ),
            SubService(
              id: 'personal_medicine_import',
              name: 'Personal Medicine Import Permits',
              serviceTypeId: 'mohap_pharmaceutical',
              premium: PricingTier(
                cost: 'Application processing fee',
                timeline: 'Pre-approval before entry',
              ),
              standard: PricingTier(
                cost: 'Application processing fee',
                timeline: 'Standard processing',
              ),
              documentRequirements: [
                'Medical prescription',
                'Patient identification',
                'Doctor\'s letter of necessity',
              ],
            ),
          ],
        ),
      ],
    ),

    // Education Services (MOE)
    ServiceCategory(
      id: 'education',
      name: 'Education Services (MOE)',
      icon: 'school',
      color: '0xFF64B5F6',
      serviceTypes: [
        ServiceType(
          id: 'education_services',
          name: 'School & Student Services',
          categoryId: 'education',
          subServices: [
            SubService(
              id: 'school_enrollment',
              name: 'School Registration & Admission',
              serviceTypeId: 'education_services',
              premium: PricingTier(
                cost: 'Free for UAE nationals',
                timeline: '2-4 weeks',
              ),
              standard: PricingTier(
                cost: 'Varies by emirate for residents',
                timeline: '3-5 weeks',
              ),
              documentRequirements: [
                'Birth certificate (attested)',
                'Passport/residence visa',
                'Parent ID',
                'Academic records (for transfers)',
                'Vaccination certificates',
              ],
            ),
            SubService(
              id: 'school_transfer',
              name: 'School Transfer',
              serviceTypeId: 'education_services',
              premium: PricingTier(cost: 1400, timeline: '3-5 working days'),
              standard: PricingTier(cost: 900, timeline: '5-7 working days'),
              documentRequirements: [
                'Transfer certificate',
                'Academic transcripts',
                'Passport & Emirates ID',
                'Current visa copy',
              ],
            ),
            SubService(
              id: 'school_certificate_attestation',
              name: 'School Certificate Attestation & Verification',
              serviceTypeId: 'education_services',
              premium: PricingTier(
                cost: 'AED 100-200',
                timeline: 'Same-day (urgent)',
              ),
              standard: PricingTier(
                cost: 'AED 100-200',
                timeline: '3-7 working days',
              ),
              documentRequirements: [
                'Original certificate',
                'Identification document',
                'Attestation request form',
              ],
            ),
            SubService(
              id: 'academic_achievement_certificates',
              name: 'Academic Achievement Certificates',
              serviceTypeId: 'education_services',
              premium: PricingTier(
                cost: 'AED 50-150',
                timeline: '3-5 working days',
              ),
              standard: PricingTier(
                cost: 'AED 50-150',
                timeline: '5-7 working days',
              ),
              documentRequirements: [
                'Student ID',
                'Parent authorization',
                'Graduation documents',
              ],
            ),
            SubService(
              id: 'higher_education_scholarships',
              name: 'Higher Education Scholarships',
              serviceTypeId: 'education_services',
              premium: PricingTier(
                cost: 'No application fee',
                timeline: 'Scholarship covers costs',
              ),
              standard: PricingTier(
                cost: 'No application fee',
                timeline: 'Per selection cycle',
              ),
              documentRequirements: [
                'High school certificate/EmSAT scores',
                'English proficiency test (IELTS/TOEFL)',
                'University admission letter',
                'Good conduct certificate',
                'Passport copy',
                'Academic records',
                'Family income documentation',
              ],
            ),
            SubService(
              id: 'student_visa_support',
              name: 'Educational Visa Support',
              serviceTypeId: 'education_services',
              premium: PricingTier(cost: 4200, timeline: '2-3 weeks'),
              standard: PricingTier(cost: 3000, timeline: '3-4 weeks'),
              documentRequirements: [
                'School/University offer letter',
                'Sponsor passport & bank statements',
                'Accommodation proof',
                'Medical fitness certificate',
              ],
            ),
          ],
        ),
        ServiceType(
          id: 'moe_institutional',
          name: 'Institutional Services',
          categoryId: 'education',
          subServices: [
            SubService(
              id: 'curriculum_accreditation',
              name: 'Curriculum Development & Academic Accreditation',
              serviceTypeId: 'moe_institutional',
              premium: PricingTier(
                cost: 'Accreditation review fee',
                timeline: '6-8 weeks',
              ),
              standard: PricingTier(
                cost: 'Accreditation review fee',
                timeline: '8-12 weeks',
              ),
              documentRequirements: [
                'Curriculum framework',
                'Teacher qualifications',
                'Facilities assessment',
                'Compliance documentation',
              ],
            ),
            SubService(
              id: 'teacher_certification',
              name: 'Teacher Certification & License',
              serviceTypeId: 'moe_institutional',
              premium: PricingTier(
                cost: 'License issuance/renewal fee',
                timeline: '2-3 weeks',
              ),
              standard: PricingTier(
                cost: 'License issuance/renewal fee',
                timeline: '3-4 weeks',
              ),
              documentRequirements: [
                'Academic degree',
                'Professional teaching qualification',
                'Background clearance',
                'Health certificate',
              ],
            ),
            SubService(
              id: 'special_needs_assessment',
              name: 'Special Needs Education Assessment',
              serviceTypeId: 'moe_institutional',
              premium: PricingTier(
                cost: 'Assessment fee varies',
                timeline: '2-4 weeks',
              ),
              standard: PricingTier(
                cost: 'Assessment fee varies',
                timeline: '4-6 weeks',
              ),
              documentRequirements: [
                'Medical assessment reports',
                'Previous academic records',
                'Parental consent',
                'Psychological evaluation',
              ],
            ),
            SubService(
              id: 'private_school_registration',
              name: 'Private School Registration & Approval',
              serviceTypeId: 'moe_institutional',
              premium: PricingTier(
                cost: 'Registration + annual licensing fee',
                timeline: '8-12 weeks',
              ),
              standard: PricingTier(
                cost: 'Registration + annual licensing fee',
                timeline: '12-16 weeks',
              ),
              documentRequirements: [
                'Building ownership/lease',
                'Curriculum plan',
                'Staff qualifications',
                'Facilities inspection',
                'Financial documentation',
              ],
            ),
          ],
        ),
      ],
    ),

    // Notary & Legal Services
    ServiceCategory(
      id: 'notary',
      name: 'Notary & Legal Services',
      icon: 'edit',
      color: '0xFFB0BEC5',
      serviceTypes: [
        ServiceType(
          id: 'notary_services',
          name: 'Notary Public Services',
          categoryId: 'notary',
          subServices: [
            SubService(
              id: 'poa_notarization',
              name: 'Power of Attorney',
              serviceTypeId: 'notary_services',
              premium: PricingTier(cost: 950, timeline: '1-2 working days'),
              standard: PricingTier(cost: 650, timeline: '3 working days'),
              documentRequirements: [
                'Draft POA in Arabic or bilingual',
                'Emirates ID & passport of signatories',
                'Supporting contracts (if required)',
                'Witness details (if needed)',
              ],
            ),
            SubService(
              id: 'contract_attestation_notary',
              name: 'Contract Attestation',
              serviceTypeId: 'notary_services',
              premium: PricingTier(cost: 850, timeline: '1-2 working days'),
              standard: PricingTier(cost: 550, timeline: '3 working days'),
              documentRequirements: [
                'Original contracts',
                'Company trade license',
                'Authorized signatory documents',
                'Emirates ID & passports',
              ],
            ),
            SubService(
              id: 'affidavits',
              name: 'Affidavits & Declarations',
              serviceTypeId: 'notary_services',
              premium: PricingTier(cost: 650, timeline: 'Same day'),
              standard: PricingTier(cost: 450, timeline: '2 working days'),
              documentRequirements: [
                'Draft affidavit text',
                'Supporting evidence',
                'Valid ID documents',
              ],
            ),
            SubService(
              id: 'will_registration',
              name: 'Will Registration',
              serviceTypeId: 'notary_services',
              premium: PricingTier(cost: 3500, timeline: '3-5 working days'),
              standard: PricingTier(cost: 2500, timeline: '5-7 working days'),
              documentRequirements: [
                'Draft will (English/Arabic)',
                'Passport & Emirates ID',
                'Marriage/birth certificates (if referenced)',
                'Asset list & beneficiary details',
              ],
            ),
          ],
        ),
      ],
    ),

    // Telecommunications Services
    ServiceCategory(
      id: 'telecom',
      name: 'Telecommunications Services',
      icon: '📶',
      color: '0xFF4FC3F7',
      serviceTypes: [
        ServiceType(
          id: 'telecom_services',
          name: 'Mobile & Internet',
          categoryId: 'telecom',
          subServices: [
            SubService(
              id: 'new_connection',
              name: 'New Connection Setup',
              serviceTypeId: 'telecom_services',
              premium: PricingTier(cost: 450, timeline: 'Same day'),
              standard: PricingTier(cost: 300, timeline: '2 working days'),
              documentRequirements: [
                'Emirates ID',
                'Passport copy',
                'Residence visa',
              ],
            ),
            SubService(
              id: 'postpaid_plan',
              name: 'Postpaid Plan Activation',
              serviceTypeId: 'telecom_services',
              premium: PricingTier(cost: 400, timeline: '1 working day'),
              standard: PricingTier(cost: 250, timeline: '2 working days'),
              documentRequirements: [
                'Emirates ID',
                'Salary certificate',
                'Security deposit',
              ],
            ),
            SubService(
              id: 'prepaid_sim',
              name: 'Prepaid SIM Registration',
              serviceTypeId: 'telecom_services',
              premium: PricingTier(cost: 150, timeline: 'Same day'),
              standard: PricingTier(cost: 100, timeline: 'Same day'),
              documentRequirements: [
                'Emirates ID for registration',
                'Passport copy (tourists)',
              ],
            ),
            SubService(
              id: 'internet_connection',
              name: 'Home/Office Internet Connection',
              serviceTypeId: 'telecom_services',
              premium: PricingTier(cost: 650, timeline: '2 working days'),
              standard: PricingTier(cost: 420, timeline: '3-5 working days'),
              documentRequirements: [
                'Ejari/tenancy contract',
                'Emirates ID',
                'Security deposit (if required)',
              ],
            ),
          ],
        ),
      ],
    ),

    // Utility Services (DEWA/SEWA)
    ServiceCategory(
      id: 'utilities',
      name: 'Utility Services (DEWA/SEWA)',
      icon: 'power',
      color: '0xFFFF7043',
      serviceTypes: [
        ServiceType(
          id: 'dewa_services',
          name: 'DEWA Services',
          categoryId: 'utilities',
          subServices: [
            SubService(
              id: 'dewa_new_connection',
              name: 'New Connection (Move-in Service)',
              serviceTypeId: 'dewa_services',
              premium: PricingTier(
                cost: 'Security deposit + connection fee',
                timeline: '3-5 working days',
              ),
              standard: PricingTier(
                cost: 'Security deposit + connection fee',
                timeline: '5-7 working days',
              ),
              documentRequirements: [
                'UAE ID',
                'Tenancy contract',
                'Property ownership document',
              ],
            ),
            SubService(
              id: 'dewa_bill_payment',
              name: 'Bill Payment Services',
              serviceTypeId: 'dewa_services',
              premium: PricingTier(
                cost: 'No fees (bill amount only)',
                timeline: '24/7 online',
              ),
              standard: PricingTier(
                cost: 'No fees (bill amount only)',
                timeline: '24/7 online',
              ),
              documentRequirements: ['Account number', 'Payment method'],
            ),
            SubService(
              id: 'account_transfer',
              name: 'Account Transfer / Move-in Move-out',
              serviceTypeId: 'dewa_services',
              premium: PricingTier(cost: 550, timeline: '1-2 working days'),
              standard: PricingTier(cost: 380, timeline: '3 working days'),
              documentRequirements: [
                'Previous DEWA account number',
                'New tenancy contract',
                'Clearance certificate',
              ],
            ),
          ],
        ),
        ServiceType(
          id: 'sewa_services',
          name: 'SEWA Services (Sharjah)',
          categoryId: 'utilities',
          subServices: [
            SubService(
              id: 'sewa_connection',
              name: 'SEWA Connection Services',
              serviceTypeId: 'sewa_services',
              premium: PricingTier(
                cost: 'Security deposit + connection fee',
                timeline: '3-5 working days',
              ),
              standard: PricingTier(
                cost: 'Security deposit + connection fee',
                timeline: '5-7 working days',
              ),
              documentRequirements: [
                'Emirates ID',
                'Tenancy contract',
                'Passport copy',
              ],
            ),
            SubService(
              id: 'sewa_bill_payment',
              name: 'SEWA Bill Payment',
              serviceTypeId: 'sewa_services',
              premium: PricingTier(cost: 'No fees', timeline: '24/7 online'),
              standard: PricingTier(cost: 'No fees', timeline: '24/7 online'),
              documentRequirements: ['Account number'],
            ),
          ],
        ),
      ],
    ),

    // Tourism Services (DET Dubai)
    ServiceCategory(
      id: 'tourism',
      name: 'Tourism Services (DET)',
      icon: 'castle',
      color: '0xFFAB47BC',
      serviceTypes: [
        ServiceType(
          id: 'tourism_licensing',
          name: 'Tourism Licensing',
          categoryId: 'tourism',
          subServices: [
            SubService(
              id: 'hotel_license',
              name: 'Hotel License & Classification',
              serviceTypeId: 'tourism_licensing',
              premium: PricingTier(
                cost: 'License + classification fee',
                timeline: '8-12 weeks',
              ),
              standard: PricingTier(
                cost: 'License + classification fee',
                timeline: '12-16 weeks',
              ),
              documentRequirements: [
                'Building approval',
                'Safety certifications',
                'Facility inspection reports',
                'Management qualifications',
              ],
            ),
            SubService(
              id: 'tour_operator_permit',
              name: 'Tour Operator Counter Permit',
              serviceTypeId: 'tourism_licensing',
              premium: PricingTier(
                cost: 'AED 1,520 per year',
                timeline: '2-3 weeks',
              ),
              standard: PricingTier(
                cost: 'AED 1,520 per year',
                timeline: '3-4 weeks',
              ),
              documentRequirements: [
                'Business registration',
                'Counter lease agreement',
                'Staff qualifications',
              ],
            ),
            SubService(
              id: 'tour_guide_license',
              name: 'Tour Guide License Badge',
              serviceTypeId: 'tourism_licensing',
              premium: PricingTier(
                cost: 'Annual renewal required',
                timeline: '2-3 weeks',
              ),
              standard: PricingTier(
                cost: 'Annual renewal required',
                timeline: '3-4 weeks',
              ),
              documentRequirements: [
                'Language proficiency',
                'Background clearance',
                'Training certificate',
              ],
            ),
            SubService(
              id: 'desert_safari_permit',
              name: 'Desert Safari & Adventure Activity Permits',
              serviceTypeId: 'tourism_licensing',
              premium: PricingTier(
                cost: 'Permit + liability insurance',
                timeline: '4-6 weeks',
              ),
              standard: PricingTier(
                cost: 'Permit + liability insurance',
                timeline: '6-8 weeks',
              ),
              documentRequirements: [
                'Safari vehicle registration',
                'Driver certifications',
                'Liability insurance',
              ],
            ),
          ],
        ),
      ],
    ),

    // Social Welfare Services
    ServiceCategory(
      id: 'social_welfare',
      name: 'Social Welfare Services',
      icon: 'volunteer_activism',
      color: '0xFFEC407A',
      serviceTypes: [
        ServiceType(
          id: 'cda_services',
          name: 'CDA (Community Development Authority)',
          categoryId: 'social_welfare',
          subServices: [
            SubService(
              id: 'financial_benefits',
              name: 'Financial Social Benefits',
              serviceTypeId: 'cda_services',
              premium: PricingTier(
                cost: 'Up to AED 50,000 (one-time)',
                timeline: 'Based on assessment',
              ),
              standard: PricingTier(
                cost: 'Monthly allowance for low-income families',
                timeline: 'Based on assessment',
              ),
              documentRequirements: [
                'Income proof',
                'Family size documentation',
                'Emirates ID',
              ],
            ),
            SubService(
              id: 'temporary_housing',
              name: 'Temporary Housing Benefit',
              serviceTypeId: 'cda_services',
              premium: PricingTier(
                cost: 'Provided until permanent solutions',
                timeline: 'Case-by-case',
              ),
              standard: PricingTier(
                cost: 'Provided until permanent solutions',
                timeline: 'Case-by-case',
              ),
              documentRequirements: [
                'Housing need documentation',
                'Family details',
              ],
            ),
            SubService(
              id: 'family_development',
              name: 'Family Development Programs',
              serviceTypeId: 'cda_services',
              premium: PricingTier(
                cost: 'Free counseling & support',
                timeline: 'Ongoing programs',
              ),
              standard: PricingTier(
                cost: 'Free counseling & support',
                timeline: 'Ongoing programs',
              ),
              documentRequirements: ['Registration form', 'Family details'],
            ),
          ],
        ),
      ],
    ),

    // Intellectual Property Services
    ServiceCategory(
      id: 'intellectual_property',
      name: 'Intellectual Property (IP) Services',
      icon: 'copyright',
      color: '0xFF26A69A',
      serviceTypes: [
        ServiceType(
          id: 'trademark_services',
          name: 'Trademark Registration',
          categoryId: 'intellectual_property',
          subServices: [
            SubService(
              id: 'trademark_registration',
              name: 'Trademark Registration',
              serviceTypeId: 'trademark_services',
              premium: PricingTier(
                cost: 'AED 6,500 (total)',
                timeline: '90 days initial decision',
              ),
              standard: PricingTier(
                cost: 'AED 6,500 (total)',
                timeline: '120+ days complete process',
              ),
              documentRequirements: [
                'Trademark representation/image',
                'List of goods/services (Nice Classification)',
                'Power of attorney (foreign applicants)',
                'Proof of use (if applicable)',
              ],
            ),
            SubService(
              id: 'geographical_indication',
              name: 'Geographical Indication Registration',
              serviceTypeId: 'trademark_services',
              premium: PricingTier(cost: 'AED 6,500', timeline: '90+ days'),
              standard: PricingTier(cost: 'AED 6,500', timeline: '120+ days'),
              documentRequirements: [
                'Product documentation',
                'Geographical origin proof',
              ],
            ),
          ],
        ),
        ServiceType(
          id: 'patent_services',
          name: 'Patent Registration',
          categoryId: 'intellectual_property',
          subServices: [
            SubService(
              id: 'patent_application',
              name: 'New Patent Application',
              serviceTypeId: 'patent_services',
              premium: PricingTier(
                cost: 'AED 1,000 (individual) / AED 2,000 (company)',
                timeline: '3-12 months examination',
              ),
              standard: PricingTier(
                cost: 'AED 1,000 (individual) / AED 2,000 (company)',
                timeline: '12-18 months complete',
              ),
              documentRequirements: [
                'Detailed patent specification',
                'Drawings',
                'Claims defining invention scope',
                'English translation (if not Arabic)',
                'Power of attorney (if using agent)',
              ],
            ),
            SubService(
              id: 'patent_examination',
              name: 'Search & Examination',
              serviceTypeId: 'patent_services',
              premium: PricingTier(
                cost: 'AED 7,000 (1st) / AED 5,000 (2nd/3rd)',
                timeline: '42 months from fees paid',
              ),
              standard: PricingTier(
                cost: 'AED 7,000 (1st) / AED 5,000 (2nd/3rd)',
                timeline: '42+ months',
              ),
              documentRequirements: [
                'Patent application documentation',
                'Examination request',
              ],
            ),
          ],
        ),
        ServiceType(
          id: 'copyright_services',
          name: 'Copyright Registration',
          categoryId: 'intellectual_property',
          subServices: [
            SubService(
              id: 'copyright_registration',
              name: 'Copyright Registration',
              serviceTypeId: 'copyright_services',
              premium: PricingTier(
                cost: 'Registration fees',
                timeline: '4-8 weeks',
              ),
              standard: PricingTier(
                cost: 'Registration fees',
                timeline: '8-12 weeks',
              ),
              documentRequirements: [
                'Work samples/documentation',
                'Copyright registration application',
              ],
            ),
          ],
        ),
      ],
    ),

    // Port & Maritime Services
    ServiceCategory(
      id: 'port_maritime',
      name: 'Port & Maritime Services',
      icon: 'sailing',
      color: '0xFF5C6BC0',
      serviceTypes: [
        ServiceType(
          id: 'jebel_ali_port',
          name: 'Jebel Ali Port Services',
          categoryId: 'port_maritime',
          subServices: [
            SubService(
              id: 'container_handling',
              name: 'Container Handling (FCL/LCL)',
              serviceTypeId: 'jebel_ali_port',
              premium: PricingTier(
                cost: 'Per container/shipment',
                timeline: 'As per schedule',
              ),
              standard: PricingTier(
                cost: 'Per container/shipment',
                timeline: 'Standard processing',
              ),
              documentRequirements: [
                'Bill of lading',
                'Shipping documents',
                'Customs clearance',
              ],
            ),
            SubService(
              id: 'cargo_operations',
              name: 'Cargo Operations & Transshipment',
              serviceTypeId: 'jebel_ali_port',
              premium: PricingTier(
                cost: 'Per operation',
                timeline: 'Scheduled operations',
              ),
              standard: PricingTier(
                cost: 'Per operation',
                timeline: 'Standard schedule',
              ),
              documentRequirements: [
                'Cargo documentation',
                'Transfer authorization',
              ],
            ),
            SubService(
              id: 'warehousing',
              name: 'Warehousing & Logistics',
              serviceTypeId: 'jebel_ali_port',
              premium: PricingTier(
                cost: 'Per sq meter/per day',
                timeline: 'As needed',
              ),
              standard: PricingTier(
                cost: 'Per sq meter/per day',
                timeline: 'Standard rates',
              ),
              documentRequirements: [
                'Storage agreement',
                'Inventory documentation',
              ],
            ),
          ],
        ),
        ServiceType(
          id: 'khalifa_port',
          name: 'Khalifa Port Services',
          categoryId: 'port_maritime',
          subServices: [
            SubService(
              id: 'khalifa_container',
              name: 'Container & General Cargo',
              serviceTypeId: 'khalifa_port',
              premium: PricingTier(
                cost: 'Per container/shipment',
                timeline: 'Scheduled operations',
              ),
              standard: PricingTier(
                cost: 'Per container/shipment',
                timeline: 'Standard processing',
              ),
              documentRequirements: [
                'Shipping documents',
                'Bill of lading',
                'Customs clearance',
              ],
            ),
            SubService(
              id: 'khalifa_bulk',
              name: 'Dry Bulk & Liquid/Gas Cargo',
              serviceTypeId: 'khalifa_port',
              premium: PricingTier(
                cost: 'Per ton/volume',
                timeline: 'Scheduled operations',
              ),
              standard: PricingTier(
                cost: 'Per ton/volume',
                timeline: 'Standard schedule',
              ),
              documentRequirements: ['Cargo manifests', 'Safety documentation'],
            ),
          ],
        ),
      ],
    ),

    // Import-Export & Trade Services
    ServiceCategory(
      id: 'import_export',
      name: 'Import-Export & Trade Services',
      icon: 'local_shipping',
      color: '0xFF42A5F5',
      serviceTypes: [
        ServiceType(
          id: 'trade_registration',
          name: 'Trade Registration',
          categoryId: 'import_export',
          subServices: [
            SubService(
              id: 'import_export_code',
              name: 'Import-Export Code Registration',
              serviceTypeId: 'trade_registration',
              premium: PricingTier(
                cost: 'AED 500-2,000 annual',
                timeline: '3-5 working days',
              ),
              standard: PricingTier(
                cost: 'AED 500-2,000 annual',
                timeline: '5-7 working days',
              ),
              documentRequirements: [
                'Trade license copy',
                'Certificate of registration',
                'Passport copies of owners/partners',
                'Company memorandum of association',
                'Authority letter from business owner',
              ],
            ),
            SubService(
              id: 'customs_clearance',
              name: 'Customs Clearance Services',
              serviceTypeId: 'trade_registration',
              premium: PricingTier(
                cost: '5% standard duty + 5% VAT',
                timeline: 'Same day to 3 days',
              ),
              standard: PricingTier(
                cost: '5% standard duty + 5% VAT',
                timeline: '3-5 working days',
              ),
              documentRequirements: [
                'Commercial invoice',
                'Packing list',
                'Bill of lading/Airway bill',
                'Insurance document',
                'Certificate of origin',
                'Product-specific certificates',
              ],
            ),
          ],
        ),
        ServiceType(
          id: 'product_registration',
          name: 'Product Registration & Standards',
          categoryId: 'import_export',
          subServices: [
            SubService(
              id: 'food_product_registration',
              name: 'Food Product Registration',
              serviceTypeId: 'product_registration',
              premium: PricingTier(
                cost: 'Registration + testing fees',
                timeline: '5-15 working days',
              ),
              standard: PricingTier(
                cost: 'Registration + testing fees',
                timeline: '10-20 working days',
              ),
              documentRequirements: [
                'Halal certification (meat products)',
                'Laboratory testing results',
                'Arabic labeling',
                'Nutritional information',
                'Health & hygiene documentation',
              ],
            ),
            SubService(
              id: 'pharmaceutical_registration',
              name: 'Pharmaceutical Product Registration',
              serviceTypeId: 'product_registration',
              premium: PricingTier(
                cost: 'MOHAP registration fees',
                timeline: '3-6 months',
              ),
              standard: PricingTier(
                cost: 'MOHAP registration fees',
                timeline: '6-12 months',
              ),
              documentRequirements: [
                'Manufacturing authorization certificate',
                'Bilingual labeling (Arabic/English)',
                'Complete ingredient list',
                'GS1-compliant barcodes',
              ],
            ),
            SubService(
              id: 'cosmetics_registration',
              name: 'Cosmetics Product Registration',
              serviceTypeId: 'product_registration',
              premium: PricingTier(
                cost: 'Dubai Municipality + ESMA fees',
                timeline: '10-15 working days',
              ),
              standard: PricingTier(
                cost: 'Dubai Municipality + ESMA fees',
                timeline: '15-20 working days',
              ),
              documentRequirements: [
                'Ingredient documentation',
                'Product safety assessment',
                'Laboratory tests',
                'Bilingual packaging',
                'Stability testing reports',
              ],
            ),
            SubService(
              id: 'electronics_certification',
              name: 'Electronics & Appliance Certification (ECAS)',
              serviceTypeId: 'product_registration',
              premium: PricingTier(
                cost: 'Certification fees',
                timeline: '4-6 weeks',
              ),
              standard: PricingTier(
                cost: 'Certification fees',
                timeline: '6-8 weeks',
              ),
              documentRequirements: [
                'Technical specifications',
                'Testing against UAE standards',
                'Conformity assessment',
              ],
            ),
          ],
        ),
      ],
    ),

    // Free Zone Business Services
    ServiceCategory(
      id: 'free_zone',
      name: 'Free Zone Business Services',
      icon: 'business_center',
      color: '0xFF66BB6A',
      serviceTypes: [
        ServiceType(
          id: 'dafza_licensing',
          name: 'DAFZA (Dubai Airport Free Zone)',
          categoryId: 'free_zone',
          subServices: [
            SubService(
              id: 'dafza_zero_visa',
              name: 'Zero Visa Package',
              serviceTypeId: 'dafza_licensing',
              premium: PricingTier(cost: 'AED 23,000', timeline: '1-2 weeks'),
              standard: PricingTier(cost: 'AED 23,000', timeline: '2-3 weeks'),
              documentRequirements: [
                'Business plan',
                'Passport copies',
                'Application form',
              ],
            ),
            SubService(
              id: 'dafza_one_visa',
              name: '1 Visa Package',
              serviceTypeId: 'dafza_licensing',
              premium: PricingTier(cost: 'AED 26,000', timeline: '2-3 weeks'),
              standard: PricingTier(cost: 'AED 26,000', timeline: '3-4 weeks'),
              documentRequirements: [
                'License + Establishment Card + 1 Visa',
                'Business documents',
                'Employee documents',
              ],
            ),
            SubService(
              id: 'dafza_two_visa',
              name: '2 Visa Package',
              serviceTypeId: 'dafza_licensing',
              premium: PricingTier(cost: 'AED 29,000', timeline: '2-3 weeks'),
              standard: PricingTier(cost: 'AED 29,000', timeline: '3-4 weeks'),
              documentRequirements: [
                'License + Office + 2 Visas',
                'Business plan',
                'Employee documentation',
              ],
            ),
            SubService(
              id: 'dafza_trading_license',
              name: 'Annual Trading License',
              serviceTypeId: 'dafza_licensing',
              premium: PricingTier(
                cost: 'AED 50,000/year',
                timeline: '2-3 weeks',
              ),
              standard: PricingTier(
                cost: 'AED 50,000/year',
                timeline: '3-4 weeks',
              ),
              documentRequirements: [
                'Company registration',
                'Trade activity documentation',
              ],
            ),
          ],
        ),
      ],
    ),
  ];
}
