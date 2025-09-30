
# ISMS-P Based Secure Development Rules (v1.0)
# This document defines the mandatory security rules for developers during code implementation.
# Reference: Based on the Information Security Management System - Personal Information (ISMS-P) standard.

## 1. Authentication & Authorization
- **(A-1) User Identification and Authentication**
  - **MUST**: Every user must be individually identifiable. The use of shared accounts is prohibited.
  - **MUST**: Passwords MUST satisfy one of the following policies:
    - (a) 8+ characters with a mix of letters, numbers, and special characters.
    - (b) 10+ characters with a mix of letters and numbers.
  - **MUST**: An account lockout policy MUST be implemented for failed login attempts (e.g., lock the account for 5 minutes after 5 consecutive failures).

- **(A-2) Management of Authentication Credentials**
  - **MUST**: Authentication credentials such as passwords MUST be stored using an adaptive hash function like **bcrypt, scrypt, or Argon2**. (Using SHA-256 alone is prohibited).

- **(A-3) Privilege Management**
  - **MUST**: Grant only the minimum necessary privileges for a role, following the **Principle of Least Privilege**.
  - **MUST**: All actions of granting, changing, and revoking privileges MUST be logged.

- **(A-4) Privileged Access Management**
  - **MUST**: Administrative privileges (e.g., root, admin) MUST be granted to a minimum number of users, and the reason for using such accounts MUST be clearly logged.
  - **SHOULD**: Administrative accounts SHOULD be separate from regular user accounts.

## 2. Access Control
- **(AC-1) System Access**
  - **MUST**: Access to information systems by unauthorized users MUST be blocked.
  - **MUST**: Access logs for critical systems MUST be retained for **at least one year**.

- **(AC-2) Network Access**
  - **MUST**: Public-facing services MUST be located in a **DMZ**, separate from the internal network.
  - **MUST**: Firewalls MUST allow only the minimum necessary ports required for the service. (Prohibit "allow all" rules).

## 3. Cryptography
- **(C-1) Encryption of Sensitive Information**
  - **MUST**: Legally defined sensitive information (e.g., national ID numbers, passport numbers, bank account numbers, credit card numbers) and passwords MUST be encrypted during storage and transmission.
  - **MUST**: Use secure and vetted cryptographic algorithms such as **AES-256**.
  - **MUST NOT**: Do not use homegrown or custom-developed cryptographic algorithms.

- **(C-2) Cryptographic Key Management**
  - **MUST NOT**: Do not hardcode cryptographic keys in source code, configuration files, or comments.
  - **MUST**: Cryptographic keys MUST be managed securely using **environment variables** or a dedicated **Key Management System (KMS, HSM)**.
  - **MUST**: Minimize access to keys and log all lifecycle management procedures, including generation, use, and destruction.

## 4. Secure Development
- **(D-1) Secure Design**
  - **MUST**: Defense mechanisms against major vulnerabilities like the **OWASP Top 10** (e.g., SQL Injection, XSS, CSRF) MUST be incorporated during the design phase.

- **(D-2) Secure Coding**
  - **MUST**: Treat all external input (e.g., request parameters, headers, cookies) as untrusted. **Validation and sanitization** logic MUST always be applied.
  - **MUST**: All SQL queries MUST use **parameterized queries (prepared statements)**. (Dynamic query string concatenation is prohibited).
  - **MUST**: When handling errors, ensure that internal system details (e.g., stack traces, database information) are not exposed to the user.

- **(D-3) Security Testing**
  - **SHOULD**: Periodically scan for security vulnerabilities using static/dynamic analysis tools (**SAST/DAST**).

## 5. Personal Information Handling
- **(P-1) Collection and Use**
  - **MUST**: Collect only the minimum personal information necessary to provide the service. The purpose of collection MUST be clearly disclosed to users, and consent must be obtained.
  - **MUST NOT**: Do not process sensitive information (e.g., beliefs, ideology) or unique identification information without a legal basis or separate user consent.

- **(P-2) Storage and Display**
  - **MUST**: Personal information MUST be **masked** when displayed on screen (e.g., John D**, +1-***-***-1234, test@****.com).
  - **MUST NOT**: Do not use personal information or provide it to third parties beyond the scope of the consented purpose.

- **(P-3) Destruction**
  - **MUST**: When the retention period expires or the processing purpose is achieved, personal information MUST be completely destroyed using an irreversible method.
  - **MUST**: Establish a personal information destruction procedure and maintain a log of all destructions.

## 6. Logging & Management
- **(L-1) Log Recording**
  - **MUST**: Logs for critical activities (e.g., login, access to personal information, privilege changes) MUST be securely retained for **at least one year**.
  - **MUST**: Logs MUST be standardized and include at least the following: [Timestamp, User ID, Source IP Address, Request/Action, Success/Failure Status].
