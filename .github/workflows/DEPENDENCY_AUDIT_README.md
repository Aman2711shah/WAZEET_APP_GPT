# Dependency Audit Workflow

Automated monthly dependency audits for the WAZEET Flutter app using GitHub Actions.

## Overview

This workflow automatically checks for outdated Flutter/Dart packages on the 1st of every month and creates GitHub issues when updates are available.

## Features

- 🗓️ **Scheduled Runs**: Automatically runs on the 1st of each month at 9:00 AM UTC
- 🔍 **Comprehensive Scanning**: Checks all dependencies in `pubspec.yaml`
- 📊 **Detailed Reports**: Generates formatted reports with update recommendations
- 🎫 **Auto Issue Creation**: Creates or updates GitHub issues with findings
- 📁 **Artifact Storage**: Saves audit reports for 90 days
- ⚡ **Manual Trigger**: Can be run manually via GitHub Actions UI

## Workflow File

Location: `.github/workflows/dependency-audit.yml`

## Schedule

```yaml
# Runs on the 1st of every month at 9:00 AM UTC
schedule:
  - cron: '0 9 1 * *'
```

**Monthly Schedule:**
- January 1st, 9:00 AM UTC
- February 1st, 9:00 AM UTC
- March 1st, 9:00 AM UTC
- ... (and so on)

## Manual Trigger

You can manually run the audit anytime:

1. Go to **Actions** tab in GitHub
2. Select **Monthly Dependency Audit** workflow
3. Click **Run workflow** button
4. Select branch (usually `main`)
5. Click **Run workflow**

## What It Checks

### Outdated Packages
- Direct dependencies in `pubspec.yaml`
- Dev dependencies
- Transitive dependencies
- Major, minor, and patch version updates

### Security Concerns
- Major version updates (may contain security fixes)
- Flagged vulnerabilities (when available)

## Output

### When Updates Found

1. **GitHub Issue Created**
   - Title: `📦 Monthly Dependency Audit - YYYY-MM-DD`
   - Labels: `dependencies`, `automated`, `maintenance`
   - Contains full audit report

2. **Artifacts Uploaded**
   - `outdated.json` - Machine-readable format
   - `outdated.txt` - Human-readable format
   - `summary.md` - Formatted summary

3. **Issue Content Includes:**
   - List of outdated packages
   - Current vs available versions
   - Update commands
   - Recommended actions

### When All Up-to-Date

- ✅ Workflow completes successfully
- No issue created
- Summary posted to workflow run

## Issue Management

### New Issues
First time outdated packages are detected → Creates new issue

### Existing Issues
Subsequent runs with updates → Adds comment to existing open issue

This prevents issue spam and keeps all updates in one thread.

## Example Issue Output

```markdown
## 📦 Dependency Audit Results

**Audit Date:** 2025-01-01 09:00 UTC

### Outdated Packages

```
Package Name        Current  Upgradable  Resolvable  Latest
go_router           14.2.0   17.0.0      17.0.0      17.0.0
google_sign_in      6.1.5    7.2.0       7.2.0       7.2.0
flutter_riverpod    2.4.0    3.0.3       3.0.3       3.0.3
```

### Recommended Actions

1. Review the outdated packages above
2. Check changelogs for breaking changes
3. Update `pubspec.yaml` with new versions
4. Run `flutter pub get` to install updates
5. Test thoroughly before merging

---

### Update Commands

To update all dependencies to latest compatible versions:
```bash
flutter pub upgrade --major-versions
flutter pub get
flutter analyze
flutter test
```

To update specific packages:
```bash
flutter pub upgrade <package_name> --major-versions
```
```

## Required Permissions

The workflow requires these GitHub permissions:
- `contents: write` - To checkout code
- `pull-requests: write` - For future PR creation (optional)
- `issues: write` - To create/update issues

These are set in the workflow file.

## Setup Instructions

### 1. Verify Workflow File Exists
```bash
ls -la .github/workflows/dependency-audit.yml
```

### 2. Commit and Push
```bash
git add .github/workflows/dependency-audit.yml
git commit -m "Add monthly dependency audit workflow"
git push origin main
```

### 3. Verify in GitHub
- Go to **Actions** tab
- Should see "Monthly Dependency Audit" workflow listed

### 4. Test Manual Run
- Click on the workflow
- Click "Run workflow"
- Verify it completes successfully

## Customization

### Change Schedule
Edit the cron expression in `.github/workflows/dependency-audit.yml`:

```yaml
# Run every 2 weeks
- cron: '0 9 1,15 * *'

# Run weekly on Mondays
- cron: '0 9 * * 1'

# Run quarterly (Jan, Apr, Jul, Oct)
- cron: '0 9 1 1,4,7,10 *'
```

### Change Flutter Version
```yaml
- name: Setup Flutter
  uses: subosito/flutter-action@v2
  with:
    flutter-version: '3.24.0'  # Update this
    channel: 'stable'
```

### Disable Auto Issue Creation
Comment out or remove the "Create Issue" step.

### Add Slack/Discord Notifications
Add a notification step after the audit:

```yaml
- name: Notify Team
  if: steps.outdated.outputs.has_updates == 'true'
  run: |
    curl -X POST -H 'Content-type: application/json' \
    --data '{"text":"📦 New dependency updates available!"}' \
    ${{ secrets.SLACK_WEBHOOK_URL }}
```

## Monitoring

### Check Workflow Runs
- Go to **Actions** tab
- View past runs and their results
- Download artifacts from successful runs

### Check Created Issues
- Go to **Issues** tab
- Filter by label: `dependencies`
- Review and plan updates

## Best Practices

### Monthly Review Process
1. **Week 1**: Workflow runs, issue created
2. **Week 2**: Review issue, check changelogs
3. **Week 3**: Test updates in development
4. **Week 4**: Merge and close issue

### Before Updating
- ✅ Read package changelogs
- ✅ Check for breaking changes
- ✅ Review migration guides
- ✅ Test in development first
- ✅ Run full test suite
- ✅ Test on physical devices

### After Updating
- ✅ Update `CHANGELOG.md`
- ✅ Close the audit issue
- ✅ Deploy to beta testers
- ✅ Monitor for issues

## Troubleshooting

### Workflow Not Running
- Check cron schedule syntax
- Verify workflow is enabled in repo settings
- Check GitHub Actions are enabled for repo

### Permission Errors
- Verify workflow has required permissions
- Check repository settings → Actions → General

### Flutter Version Mismatch
- Update `flutter-version` in workflow
- Match your development version

### No Issue Created
- Check workflow logs for errors
- Verify `issues: write` permission
- Check if issue already exists

## Future Enhancements

Potential improvements:
- [ ] Auto-create PRs with dependency updates
- [ ] Run tests as part of audit
- [ ] Integration with Dependabot
- [ ] Custom notification channels
- [ ] Security vulnerability scanning (when available in Dart)

## Related Documentation

- [Flutter Dependency Management](https://docs.flutter.dev/packages-and-plugins/using-packages)
- [GitHub Actions Cron Syntax](https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows#schedule)
- [Semantic Versioning](https://semver.org/)

## Support

For issues with this workflow:
1. Check GitHub Actions logs
2. Review this documentation
3. Test manual run
4. Check GitHub Actions status page
