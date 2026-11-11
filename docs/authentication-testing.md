# Testing Chronis authentication locally

Use the local backend's [Swagger UI](http://localhost:8080/swagger-ui.html). Keep the existing data in the `public` schema. These tests do not require deleting tables, schemas or default data.

Passwords, one-time codes, signup proofs, reset tokens, access tokens and refresh tokens should be entered only in Chronis or Swagger. Do not paste them into chat or save them in this document.

## 1. Create a test account

This flow requires an email address that is not already registered in the active database. In Swagger, expand each operation, select **Try it out**, enter the request, and select **Execute**.

1. `POST /api/v1/auth/signup/email/send-code`: enter `{ "email": "YOUR_TEST_EMAIL" }`. A successful response contains a `challengeId`. Retrieve the six-digit code from the email.
2. `POST /api/v1/auth/signup/email/verify-code`: supply `challengeId`, `email` and `code`. A successful response contains `verificationId` and `verificationToken`. The code and proof are time-limited.
3. `POST /api/v1/auth/signup`: supply `fullName`, `email`, a password of 10–72 characters, `emailVerificationId` (the `verificationId` from step 2), and `emailVerificationToken` (the `verificationToken` from step 2). Expect HTTP 201. Save the password privately.

If the address is already registered, use it to test login; a second account cannot be created with the same email. The response to the send-code request does not by itself prove that the email arrived.

## 2. Sign in and refresh

1. `POST /api/v1/auth/login`: provide `username` as the test email and `password` as the test account's password. Expect HTTP 200 and an `accessToken` plus a `refreshToken` inside `data`.
2. `POST /api/v1/auth/refresh`: provide the `refreshToken`. Expect HTTP 200 with a new access token and refresh token. Refresh rotates the refresh token, so use the new one for subsequent refresh tests.
3. After restarting the backend with the Swagger security configuration, select **Authorize** at the top of Swagger and paste the current access token. Protected operations include logout and change-password.

## 3. Password recovery and change

Use the test account. A successful password reset or change invalidates that account's existing sessions on all devices.

1. `POST /api/v1/auth/forgot-password`: provide the test email. HTTP 200 is deliberately generic and does not prove an email was delivered. Check the inbox for the reset code.
2. `POST /api/v1/auth/reset-password`: provide the emailed `token`, `password`, and matching `confirmPassword`. Expect HTTP 200. Sign in with the new password.
3. `POST /api/v1/auth/change-password`: authorize Swagger with the current access token, then provide `currentPassword`, `newPassword`, and matching `confirmNewPassword`. Expect HTTP 200. Sign in again with the changed password.

## 4. Logout

Authorize Swagger with an access token from a fresh login and execute `POST /api/v1/auth/logout`. Expect HTTP 200. Logout revokes **all refresh tokens for that account**, so other devices using the same account will need to sign in again. A revoked refresh token must be rejected.

## 5. Google, Facebook and older email verification

- `POST /api/v1/auth/google` requires a real Google identity token in `idToken`; `POST /api/v1/auth/facebook` requires a real Facebook access token in `accessToken`. The Chronis Google and Facebook sign-in buttons obtain these through the provider's own sign-in flow. Keep provider tokens private.
- `POST /api/v1/auth/resend-verification` and `POST /api/v1/auth/verify-email` are for an existing, unverified account. The current signup flow verifies email **before** creating the account, so a freshly created account is already verified. A generic successful resend response does not prove mail was sent. Do not change an existing account's verification flags merely to test these endpoints.

## Expected negative cases

- Empty or malformed public requests should be rejected with HTTP 400.
- Logout and change-password without a valid access token should return HTTP 401.
- Invalid login or refresh credentials should be rejected with HTTP 401.
- A nonexistent or already verified email receives a generic response from resend-verification; forgot-password also uses a generic response.
- An invalid reset token is rejected. A signup request without a valid email proof cannot create an account.

These checks do not replace a live test of email delivery or a real provider login.
