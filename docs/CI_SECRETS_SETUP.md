# CI Secrets Setup (Beta Deploy)

This guide shows how to add the required GitHub Actions secrets for the workflow in `.github/workflows/deploy-beta.yml`.

Never commit keys or JSON credentials to the repo. Use GitHub Actions secrets instead.

## iOS (TestFlight)
Add these repository secrets (Settings → Secrets and variables → Actions → New repository secret):

- APP_STORE_CONNECT_KEY_ID
- APP_STORE_CONNECT_ISSUER_ID
- APP_STORE_CONNECT_KEY_CONTENT
- MATCH_PASSWORD
- MATCH_GIT_URL
- MATCH_GIT_BASIC_AUTHORIZATION
- FASTLANE_USER
- FASTLANE_PASSWORD
- FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD

Notes:
- `APP_STORE_CONNECT_KEY_CONTENT` must contain the full contents of your `.p8` private key. Keep the header/footer lines. Example:
  ```
  -----BEGIN PRIVATE KEY-----
  ...
  -----END PRIVATE KEY-----
  ```
- `MATCH_*` values come from your match repo and password.

## Android (Play Console Internal Testing)
Add these repository secrets:

- ANDROID_KEYSTORE_BASE64
- ANDROID_KEY_PROPERTIES
- PLAY_STORE_CONFIG_JSON

### Prepare values

1) Keystore (base64)

If your file is `android/app/upload-keystore.jks` locally:

```sh
base64 -in android/app/upload-keystore.jks | pbcopy
```
Paste into `ANDROID_KEYSTORE_BASE64`.

2) key.properties

Compose the text (replace with your real values):

```
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=YOUR_KEY_ALIAS
storeFile=upload-keystore.jks
```
Paste into `ANDROID_KEY_PROPERTIES`.

3) Play Store service account JSON

Open the service account JSON you downloaded from Google Cloud/Play Console (the one used for Play Console uploads). Copy its entire contents and paste into `PLAY_STORE_CONFIG_JSON`.

If pasting multiline JSON causes issues, base64-encode it and adjust the workflow step like this:

```yaml
- name: Setup Play Store Service Account
  env:
    PLAY_STORE_CONFIG_JSON_BASE64: ${{ secrets.PLAY_STORE_CONFIG_JSON_BASE64 }}
  run: |
    echo "$PLAY_STORE_CONFIG_JSON_BASE64" | base64 -d > android/play-store-credentials.json
```

Then add the secret `PLAY_STORE_CONFIG_JSON_BASE64` with the base64 of the JSON:

```sh
base64 -in path/to/service-account.json | pbcopy
```

## Triggering the workflow

- Manual: Actions → Deploy Beta Builds → Run workflow → choose platform (ios/android/both)
- Tag-based: push a tag like `v1.2.3-beta` to trigger automatically

## Troubleshooting
- Missing characters/fonts on web build: add proper font assets to `pubspec.yaml` and bundle Noto fonts if you need wide unicode coverage.
- If signing fails on iOS: ensure `MATCH_*` and App Store Connect key values are correct and the `.p8` content is stored with header/footer lines.
- If Play Store upload fails: verify the service account has the correct Play Console permissions (Release Manager/Editor).
