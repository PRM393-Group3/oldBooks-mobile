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
