# Datly — Privacy Policy

**Effective date:** 2026-03-01
**Maintainer / Controller:** JHubi1
**Contact:** <me@jhubi1.com>
**Location:** Germany

## Quick summary

- Datly lets registered users capture and upload photos. Uploaded photos are used **only** to train, evaluate, and improve AI/ML models.
- Accounts may be created by administrators or through self-registration (with CAPTCHA verification). Usernames are assigned by admins or chosen during registration and are **not changeable** by users.
- We collect your **username, email address** (required for account creation), and **hashed password**. Email addresses and usernames are **not** included in any training datasets.
- All uploaded images have embedded metadata (EXIF) **fully removed**, are **centre-cropped and resized to 224 × 224 pixels**, and re-encoded before storage (data minimisation).
- When you submit an image, you sign a consent form. We permanently store the submitting client's **IP address**, **browser user-agent**, and a **snapshot of the consent form and your account data** at the time of signing as legal evidence.
- Your **preferred language** is automatically detected from the `Accept-Language` HTTP header and stored in your account.
- Access to the service is **free**.

---

## 1. Controller & contact

The data controller for all processing carried out via Datly is:

**JHubi1**
Email: **<me@jhubi1.com>**
Location: Germany

No Data Protection Officer (DPO) has been formally appointed. For all questions, privacy requests, or to exercise your rights, contact the address above.

## 2. Categories of personal data we collect

### 2.1 Account data

| Data                             | Details                                                                                                                                                          |
| -------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Username**                     | 3–16 alphanumeric characters; assigned by an admin or chosen at self-registration; serves as your primary identifier                                             |
| **Email address**                | Required at account creation; used for transactional notifications (welcome, password reset, account status changes)                                             |
| **Password**                     | Stored only as an **Argon2id hash** (never in plaintext); validated against minimum-complexity rules and the Have I Been Pwned breach database before acceptance |
| **Locale / language preference** | Automatically detected from your browser's `Accept-Language` header and updated on each authenticated request                                                    |
| **Role**                         | One of `external`, `user`, or `admin`; determines access permissions                                                                                             |
| **Account status**               | Whether your account is activated, disabled (with reason), and the date you joined                                                                               |
| **Project assignments**          | List of project IDs you are authorised to contribute to                                                                                                          |

### 2.2 Images you upload

- The original image file content is processed as follows before storage:
  1. All embedded metadata (EXIF, GPS, camera model, timestamps, etc.) is **fully removed**.
  2. Minimal new EXIF data is written: `Software: Datly`, `Copyright: (c) <year> <username>`.
  3. The image is **centre-cropped and resized to 224 × 224 pixels** (cubic interpolation).
  4. A **BlurHash** perceptual placeholder is computed for display purposes.
  5. The processed image is re-encoded as PNG or JPEG and stored under a random UUID filename.
- The original, unprocessed image is **not retained**.

### 2.3 Submission metadata

| Data                     | Details                                          |
| ------------------------ | ------------------------------------------------ |
| **Submission ID**        | Auto-generated integer                           |
| **Project ID**           | The project the image was submitted to           |
| **Submitting user**      | Your username                                    |
| **Status**               | `pending`, `accepted`, `rejected`, or `censored` |
| **Submission timestamp** | Date and time of upload                          |
| **Asset ID**             | Random UUID referencing the stored image file    |
| **Asset MIME type**      | `image/png` or `image/jpeg`                      |
| **Asset BlurHash**       | Perceptual hash for UI placeholders              |

### 2.4 Consent signatures

Each image submission requires a consent signature. The following data is stored as **legal evidence**:

| Data                      | Details                                                                               |
| ------------------------- | ------------------------------------------------------------------------------------- |
| **Signature text**        | The text you type to confirm consent (max 128 characters)                             |
| **Parental signature**    | If applicable, a parental/guardian consent signature (max 128 characters)             |
| **Signature method**      | Currently: `typed`                                                                    |
| **Consent form snapshot** | The exact text of the consent form you agreed to at signing time                      |
| **Consent version**       | Version number of the consent form                                                    |
| **IP address**            | The IP address of the submitting client at the time of signing                        |
| **Browser user-agent**    | The `User-Agent` HTTP header of the submitting client                                 |
| **User snapshot**         | A point-in-time JSON snapshot of your full account record (including hashed password) |
| **Submission snapshot**   | A point-in-time JSON snapshot of the submission record                                |
| **Signed-at timestamp**   | Date and time of signing                                                              |
| **Revocation data**       | If revoked: revocation timestamp and reason                                           |

### 2.5 Network and device metadata

| Data                       | Where used                                                                   | Retained                                                           |
| -------------------------- | ---------------------------------------------------------------------------- | ------------------------------------------------------------------ |
| **IP address**             | Consent signatures; rate limiting; CAPTCHA verification (sent to Cloudflare) | Permanently in signatures; transiently in memory for rate limiting |
| **Browser user-agent**     | Consent signatures                                                           | Permanently in signatures                                          |
| **Accept-Language header** | Locale detection                                                             | Stored as `locale` in your account                                 |

### 2.6 Data we do **not** collect

We do not collect: contact lists, device identifiers, address books, payment data, location data (beyond IP), health data, biometric data, cookies for tracking, or any data from analytics or advertising SDKs. No cookies or similar tracking technologies are used.

> **Important:** Do not upload photos that contain sensitive personal data about others (e.g. biometric data, health information) unless you have an appropriate lawful basis.

## 3. Purposes and legal bases for processing

| Purpose                                                                                                                                    | Data involved                                                                                         | Legal basis (Art. 6 GDPR)                                                                                                                                                      |
| ------------------------------------------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **AI/ML model training** — storing and processing images for training, evaluation, improvement, and benchmarking of AI/ML models           | Uploaded images, submission metadata                                                                  | **Consent (Art. 6(1)(a))** — explicit informed consent given at each upload via the consent signature                                                                          |
| **Account management** — creating, authenticating, and managing your account; sending transactional emails                                 | Username, email, hashed password, role, locale, account status                                        | **Contract performance (Art. 6(1)(b))** — necessary to provide the service you registered for                                                                                  |
| **Security & abuse prevention** — rate limiting, CAPTCHA verification, password breach checking, access control                            | IP address, user-agent, hashed password prefix (5 chars of SHA-1)                                     | **Legitimate interests (Art. 6(1)(f))** — our interest in protecting the service, its users, and data integrity                                                                |
| **Legal evidence of consent** — retaining proof that valid consent was given for image use, including after account or submission deletion | Consent signatures (IP, user-agent, user snapshot, submission snapshot, signature text, consent form) | **Legal obligation (Art. 6(1)(c))** and **Legitimate interests (Art. 6(1)(f))** — to demonstrate compliance with consent requirements (Art. 7(1) GDPR) and project obligations |
| **Transactional communications** — welcome emails, password resets, account status notifications                                           | Email address, username, locale                                                                       | **Contract performance (Art. 6(1)(b))**                                                                                                                                        |

Where we rely on **legitimate interests**, we have conducted a balancing test and determined that the processing is proportionate and does not override your rights. You may request details of this assessment.

Where we rely on **consent**, you may withdraw it at any time (see Section 7). Withdrawal does not affect the lawfulness of processing carried out before withdrawal.

## 4. What you grant us (licence & model use)

By uploading an image and signing the consent form, you grant Datly a **non-exclusive, worldwide, royalty-free, transferable, and sublicensable** licence to store, reproduce, analyse, transform (including anonymisation and feature extraction), and use the image and any derived data for training, validating, evaluating, and improving AI/ML models and for associated research and development. This includes use in internal or external publications or benchmarks in de-identified or aggregated form.

**Important:**

- We remove all original EXIF metadata and resize images before storage; the original file is not retained.
- If you request deletion, we will delete original files and take steps to exclude them from future training. However, information that has already been irreversibly incorporated into a trained model may not be fully removable. We will make reasonable efforts to prevent further use of deleted images in subsequent training runs.
- Usernames and email addresses are **never** included in training datasets or shared model artefacts.

## 5. Data retention

| Data category                                  | Retention period                                                                                                                                                                               |
| ---------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Uploaded images**                            | Until you request deletion, the submission is deleted, or the submission is censored — whichever comes first. No automated expiry.                                                             |
| **Submission records**                         | Deleted when the submission is deleted or the user account is deleted (cascade). Censored submissions retain the record but the image file is deleted.                                         |
| **Account data**                               | Retained until the account is deleted by an administrator at your request.                                                                                                                     |
| **Consent signatures**                         | Retained **indefinitely**, even after account or submission deletion. Signatures are marked as revoked (with timestamp and reason) but not erased, as they serve as legal evidence of consent. |
| **IP addresses & user-agents** (in signatures) | Retained **indefinitely** as part of the consent signature record (see above).                                                                                                                 |
| **JWT authentication tokens**                  | Expire after **180 days**. Tokens are stateless and not stored server-side.                                                                                                                    |
| **Server logs**                                | HTTP request method, status code, and URL path are logged to stderr. Logs are not persisted beyond the server process lifetime unless captured by the hosting environment.                     |

We acknowledge that indefinite retention must be justified under the GDPR's storage limitation principle (Art. 5(1)(e)). We retain consent signatures indefinitely because they constitute evidence of lawful consent (Art. 7(1) GDPR) and are required for compliance with the overarching research project's obligations. We periodically review retention necessity.

There is currently no automated data purging mechanism. If you wish to have your data deleted, contact us (see Section 7).

## 6. Recipients and subprocessors

We share personal data with the following categories of recipients:

| Recipient                    | Data shared                                                  | Purpose                                                                             | Location                                |
| ---------------------------- | ------------------------------------------------------------ | ----------------------------------------------------------------------------------- | --------------------------------------- |
| **Hetzner Online GmbH**      | All stored data (database, image files)                      | Hosting infrastructure (private shared server)                                      | Nuremberg, Germany (EU)                 |
| **Configured SMTP provider** | Email address, username, temporary passwords, account status | Transactional email delivery                                                        | Depends on configuration; see Section 8 |
| **Cloudflare, Inc.**         | CAPTCHA response token, client IP address                    | CAPTCHA verification (Turnstile) during self-registration                           | USA (see Section 8)                     |
| **Have I Been Pwned (HIBP)** | First 5 characters of the SHA-1 hash of your password        | Password breach checking (k-Anonymity model; the full hash never leaves the server) | International                           |

Subprocessors are contractually required to process data only on our instructions and to implement appropriate safeguards. We do **not** sell personal data. De-identified or aggregated research outputs may be published; usernames and email addresses are never included.

## 7. Your rights under the GDPR

Under the GDPR you have the following rights, which you can exercise at any time by contacting **<me@jhubi1.com>**:

| Right                                 | Description                                                                                                                      |
| ------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| **Access** (Art. 15)                  | Obtain confirmation of whether we process your data and receive a copy of it                                                     |
| **Rectification** (Art. 16)           | Have inaccurate data corrected (note: usernames cannot be changed)                                                               |
| **Erasure** (Art. 17)                 | Request deletion of your data ("right to be forgotten"), subject to the limitations below                                        |
| **Restriction** (Art. 18)             | Request that we restrict processing of your data in certain circumstances                                                        |
| **Data portability** (Art. 20)        | Receive your data in a structured, commonly used, machine-readable format                                                        |
| **Objection** (Art. 21)               | Object to processing based on legitimate interests; we will cease processing unless we demonstrate compelling legitimate grounds |
| **Withdrawal of consent** (Art. 7(3)) | Withdraw your consent for image processing at any time; this does not affect the lawfulness of processing before withdrawal      |

**Limitations on erasure:**

- **Consent signatures** (including IP address, user-agent, and account snapshot) are retained even after account deletion as legal evidence of consent. They are marked as revoked but not erased.
- Information already irreversibly incorporated into a trained AI/ML model may not be fully removable. We will exclude deleted images from all future training.

We will respond to your request within **one month** (extendable by two further months for complex requests, with notification). We may require reasonable proof of identity before fulfilling requests. Exercising your rights is free of charge.

## 8. International data transfers

Our primary data storage is within the EU (Hetzner, Germany). However, certain processing involves transfers outside the EEA:

| Transfer                                        | Destination              | Safeguard                                                                                                   |
| ----------------------------------------------- | ------------------------ | ----------------------------------------------------------------------------------------------------------- |
| **Cloudflare Turnstile** (CAPTCHA verification) | USA                      | EU Standard Contractual Clauses (SCCs) and Cloudflare's DPA                                                 |
| **Have I Been Pwned** (password breach check)   | International            | Only a 5-character hash prefix is transmitted (no personal data in practical terms); k-Anonymity model used |
| **SMTP provider** (email delivery)              | Depends on configuration | Appropriate safeguards (SCCs or adequacy decision) applied as required                                      |

Where we transfer personal data outside the EEA, we ensure appropriate safeguards are in place as required by Chapter V GDPR (Arts. 44–49), including EU Standard Contractual Clauses or reliance on an adequacy decision.

## 9. Security measures

We implement appropriate technical and organisational measures (Art. 32 GDPR) to protect your data:

- **Password security:** Argon2id hashing with OWASP-recommended parameters; constant-time hash comparison to prevent timing attacks; minimum-complexity enforcement; breach-database checking
- **Authentication:** RS256 (RSA 2048-bit) JWT tokens with 180-day expiry; asymmetric key signing
- **Access control:** Role-based permissions (external/user/admin); disabled-account enforcement on every request
- **Rate limiting:** Maximum 5 requests per 10 seconds per IP on failed authentication attempts
- **CAPTCHA:** Cloudflare Turnstile for self-registration to prevent automated abuse
- **Data minimisation:** EXIF metadata fully stripped from images; images resized to 224 × 224 px; original files not retained
- **Input validation:** Strict length limits and format validation on all user inputs; path traversal prevention; asset filename validation via regex
- **Encryption in transit:** HTTPS (TLS) for all connections
- **Database security:** SQLite with WAL journal mode, foreign key enforcement, auto-vacuum; stored in a private server environment
- **Log hygiene:** Consent-related query parameters redacted from request logs; passwords never returned in API responses; `Powered-By` header reveals no version information
- **Cryptographic randomness:** `Random.secure()` used for all security-sensitive operations (tokens, salts, UUIDs)
- **CORS policy:** `Cross-Origin-Embedder-Policy: require-corp`, `Cross-Origin-Opener-Policy: same-origin`

No system is absolutely secure. In the event of a personal data breach, we will comply with the notification obligations under Arts. 33–34 GDPR (notification to the supervisory authority within 72 hours, and to affected individuals where the breach poses a high risk).

## 10. Automated decision-making

We do **not** use automated decision-making or profiling that produces legal effects or similarly significantly affects you (Art. 22 GDPR). Image moderation (accept/reject/censor) is performed manually by administrators.

## 11. Data Protection Impact Assessment (DPIA)

Processing personal images to train AI/ML models can be a high-risk activity. Where required by Art. 35 GDPR, we carry out a Data Protection Impact Assessment before launching processing operations likely to result in a high risk to data subjects. You may request summary information about any DPIA we have carried out by contacting **<me@jhubi1.com>**.

## 12. Children and minors

Datly is **not intended** for children under the age of 16 (or the applicable minimum age for digital consent in your jurisdiction). If you are under the applicable minimum age you may only use the service with verifiable parental/guardian consent. Where parental consent is applicable, a separate parental signature is collected alongside your own. Do not upload images of minors unless you have lawful permission.

## 13. Complaints and supervisory authority

If you believe our processing of your personal data infringes the GDPR, you have the right to lodge a complaint with a supervisory authority (Art. 77 GDPR), in particular in the EU Member State of your habitual residence, place of work, or place of the alleged infringement.

In Germany, you may contact the relevant state data protection authority (Landesdatenschutzbeauftragte) or the Federal Commissioner for Data Protection and Freedom of Information (**BfDI**) for federal matters. Filing a complaint is free of charge.

## 14. Changes to this Privacy Policy

We may update this policy from time to time. Material changes will be communicated via the app or by email. The effective date at the top of this document will always reflect the latest version. Continued use of the service after changes constitutes acknowledgement of the updated policy; for changes requiring renewed consent, we will obtain it.

## 15. Contact

For questions, privacy requests, data subject rights, or any other matters:

**JHubi1**
Email: **<me@jhubi1.com>**
