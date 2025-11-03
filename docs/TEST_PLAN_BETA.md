# WAZEET Beta Test Plan

## Purpose
Limited external testing to validate usability, stability, and value with real users under near-production conditions.

## Audience
- Friendly external testers (10–50)
- Mix of iOS/Android/Web users
- Under NDA if required

## Scope (in-scope for Beta)
- All Alpha scope plus: onboarding polish, share/deep links (if any), error messages, empty states, and help entry points.
- Soft performance checks and perceived latency.

## Exclusions
- Full load testing, paid features with real payments unless enabled safely, and any hidden/experimental features.

## Entry Criteria
- Alpha exit criteria met
- Release notes drafted (what to test, known issues)
- Crash reporting and basic analytics on
- Feedback channels set up (GitHub issues template + Google Form/Typeform)

## Exit Criteria
- Crash-free sessions ≥ 99.5%
- No P0/P1; P2s have workarounds
- SUS (System Usability Scale) ≥ 70 from survey
- Key task success rate ≥ 90%

## Distribution
- iOS: TestFlight (Internal then Public beta)
- Android: Play Console Closed Testing (internal + alpha track)
- Web: password-protected staging or feature flag off for GA-only items

## Feedback Channels
- In-app: link to feedback form and support email
- GitHub: use `bug_report` template; add `beta` label
- Optional survey: SUS + short NPS question

## KPIs to Watch
- Crash-free users/sessions
- Time-to-first-interaction
- Task completion funnel (e.g., discover service → view details)
- Retention D1/D7 (if analytics available)

## Test Assignments (Examples)
- Onboarding + navigation: 5 testers
- Community tab exploration: 10 testers
- Services search and drill-down: 10 testers
- Track/Applications: 5 testers

## Release Notes Template
- What’s new
- What to focus on
- Known issues and workarounds
- How to send feedback and logs

## Acceptance Checklist
- [ ] Builds distributed to all platforms
- [ ] Feedback links visible and working
- [ ] Release notes shared with testers
- [ ] Crash/analytics dashboards connected
- [ ] Beta issues triaging cadence established