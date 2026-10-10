# books_marketplace_mobile

Flutter app for the Oldbook used-book marketplace.

## Running

By default the app talks to the staging backend
(`https://oldbooks-api.yellowocean-f7cb6092.southeastasia.azurecontainerapps.io`).

```bash
flutter run                      # staging
flutter build apk --release      # staging
```

To use a backend running on your machine, override the base URL (no trailing
`/`, no `/api/v1`):

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5148   # Android emulator
flutter run --dart-define=API_BASE_URL=http://localhost:5148  # iOS simulator
```

UI preview with in-memory sample data, no backend:
`flutter run --dart-define=UI_PREVIEW=true`.

## Staging notes

- OTP codes arrive by **email**, not SMS. Registration requires an email; the
  code may land in Spam/Promotions. Avoid sending OTPs repeatedly (low quota,
  5 OTP/hour/phone).
- No push notifications are delivered; use the in-app notification list.
- Data may be wiped when the backend resets. Tokens from a dev server are not
  valid on staging: sign out and sign in again.

## Android release

CI: `.github/workflows/android-release.yml`.

- Push to `production`: builds a signed APK, available as a workflow artifact.
- Push a tag `vX.Y.Z` (must match `version:` in `pubspec.yaml`): builds and
  publishes a GitHub Release with `oldbook-X.Y.Z.apk` and its SHA-256.

Release steps:

1. Bump `version:` in `pubspec.yaml` (e.g. `1.0.1+2`; the build number must increase).
2. Merge into `production`.
3. `git tag v1.0.1 production && git push origin v1.0.1`.

Signing uses repo secrets `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`,
`ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`. Local release builds read
`android/key.properties` (git-ignored). Losing the keystore means installed apps
can no longer be updated in place, so keep a backup outside the repo. Optional
repo variable `API_BASE_URL` overrides the staging URL for CI builds.
