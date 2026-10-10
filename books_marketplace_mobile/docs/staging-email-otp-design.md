# Staging connection and email OTP: design

Date: 2026-10-10. Source: backend doc "12. Kết nối mobile với server staging".

## Understanding summary

- Point the Flutter app at the Azure staging backend and adopt email-delivered OTP.
- Staging has no SMS; every OTP goes to email, and registration requires an email.
- Users: PRM393 team members testing on devices/emulators.
- Constraints: one default URL constant in `Env`; all new API fields parsed as optional.
- Non-goals: SignalR/auctions backend wiring, editing email, push, real top-up.

## Assumptions

- Staging latency 0.3–1.5 s per request; existing button loading states suffice.
- HTTPS only, no certificate bypass; errors shown by `code`, never raw `message`.
- Dev-server tokens yield 401 on staging; the existing interceptor signs the user out.
- Local backend use requires `--dart-define=API_BASE_URL=...`; debug cleartext config untouched.

## Decision log

| Decision | Alternatives | Why |
|---|---|---|
| Default `API_BASE_URL` = staging | Keep localhost default; debug/release split | Team runs `flutter run` without remembering flags |
| Single-page register form with an email field | Two-step register screen | Smallest change; reuses `OtpField` |
| `sendOtp`/`sendPhoneOtp` return `OtpSent { expiresInSeconds, sentTo? }` | Return a record / keep `int` + separate getter | Mirrors backend DTO, easy to extend |
| `OtpField.target` getter resets OTP state when phone/email changes after sending | Let server reject with `OTP_INVALID` | Doc requires resending after editing email; avoids a confusing failure |
| `UPSTREAM_ERROR` while sending OTP shows "couldn't send the code" and keeps resend enabled | Generic upstream message | Matches doc section 5 |
| `AUTH_EMAIL_TAKEN` shown under the email field with a sign-in hint | Snackbar only | Matches doc section 5 |
| Show `email` read-only on the profile screen | Hide it | Lets testers confirm `GET /me` returns it |
| `connectTimeout` 15 s | Keep 10 s | Doc 3.2; cross-region DB on staging |
| No SignalR package yet | Add `signalr_netcore` + `Env.auctionHub` | Auctions still run on the local simulator (YAGNI) |

## Design

- `lib/core/config/env.dart`: `apiBaseUrl` is a `String.fromEnvironment` constant defaulting to staging; `apiRoot` appends `/api/v1`.
- `lib/features/auth/domain/otp_sent.dart`: parses `expiresInSeconds` and nullable `sentTo`.
- `AuthRepository.sendOtp(email:)` sends `email` only when provided; `register(email:)` is required.
- `Profile.email` (nullable).
- `OtpField`: no `AutofillHints.oneTimeCode`; mail icon; shows "Mã đã gửi tới {sentTo}. Kiểm tra cả thư mục Spam/Quảng cáo." under the field; `canSend` replaces `validatePhone`.
- Forgot password: static notice that the code goes to the account email; snackbar shows `sentTo` when present.
- Change phone: copy now says the code goes to the account email.
- New error code `AUTH_EMAIL_REQUIRED` → "Tài khoản chưa có email, hãy liên hệ hỗ trợ."

## Testing

- Unit: `sendOtp` request body with/without email, `sentTo` parsing, `register` sends email, `Profile.email`.
- Widget: register requires email; editing email after sending resets the OTP state.
- Manual checklist: doc section 7 on staging.
