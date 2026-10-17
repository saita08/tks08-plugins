# Key Management — The Key Is the Data

Once data is encrypted, the key is what has to be protected, backed up, and accounted for. The OWASP Key Management Cheat Sheet states the stakes: data encrypted with lost keys will never be recovered.

## Generation

Generate a key as random bytes from a CSPRNG, 256 bits for AES-256, inside a KMS where one is available. Never derive a key from a password, a phrase, or anything a person chose. Generate a separate key for each purpose and each environment: the encryption key, a blind-index key, a session-signing key, and development, staging, and production keys are all different. OWASP's reason is containment: a key that serves one purpose limits what its compromise exposes.

## Where the key lives

In order of preference:

1. A key management service or HSM, where the key never leaves and the application calls encrypt and decrypt or unwraps DEKs. Access is by identity, and every use is logged.
2. The platform's secret store, the encrypted secrets of the hosting or serverless platform, injected at runtime. It is the usual starting point on platforms without a KMS.
3. Environment variables set by hand, which OWASP advises against because they leak through diagnostics, crash dumps, and child processes.

Never put a key in source code, version control, a configuration file in the repository, logs, error reports, chat, or tickets. Keep the key outside the database it protects; a key stored next to its data protects nothing.

## Who can reach it

Limit access to the key, and to the ability to change the secret store, to the fewest people and workloads that need it. Ideally no person ever sees the plaintext key; OWASP's minimum is that the system records everyone who can. Prefer an account structure where deploying code does not by itself grant reading secrets.

## The backup copy

A platform secret store is often write-only: the value can be replaced but not read back. Then the only copy is the one in the running service, and losing access to the platform account loses the data. Keep one backup copy, created at generation time, in a separate place with its own access control, such as an organization password manager or an offline sealed record, held by the person accountable for the data. The backup is as sensitive as the key itself. Test that the backup decrypts a known value before relying on it, and again after every rotation.

## Rotation

Design for rotation before the first key is used, because a scheme that cannot rotate cannot recover from a leak. The pieces are already in `construction.md`: every ciphertext names its key, and the reader holds a keyring.

1. Generate the new key and add it to the keyring.
2. Make the new key the one used for writes; reads still accept every key in the ring.
3. Re-encrypt existing values in the background, in the same idempotent, batched way as the first migration.
4. Verify that no value names the old key.
5. Retire the old key from the ring, but keep it in the backup until every backup and recovery snapshot that may contain old ciphertext has expired.

With envelope encryption, rotating the KEK only rewraps DEKs, which is why KMS offerings can rotate automatically.

How often: NIST SP 800-57 Part 1 Rev. 5, Table 1, suggests an originator-usage period of up to two years for a symmetric data-encryption key, meaning the time during which it encrypts new data, with decryption allowed for up to three further years. OWASP adds that the schedule should follow the threat model and the volume of use, since a GCM key also has an encryption-count limit. Rotate immediately on suspicion of compromise, when a person who could reach the key leaves, and when the algorithm's standing changes.

## When the key may have leaked

OWASP requires a compromise-recovery plan that is written and easy to find. It needs, at minimum: who decides that a key is compromised, who performs the rotation, how re-encryption is run and monitored, who is notified, and an inventory of every key, its purpose, its location, and who can reach it. A rotation procedure that has never been run is not a plan; run it once in a non-production environment.

For a review against a published Japanese standard, IPA and CRYPTREC's 暗号鍵管理システム設計指針(基本編), the guideline for designing a cryptographic key management system, comes with a checklist in PDF and Excel that maps each design consideration to what the design document and operations manual must state. It doubles as a commentary on NIST SP 800-130, so it agrees with the practice above, and it is the source to cite when the design has to be justified to Japanese stakeholders.

## Key separation decides breach reporting in Japan

Under Japan's Act on the Protection of Personal Information, a leak of personal data must normally be reported to the Personal Information Protection Commission and the individuals notified, but not when the data was protected by advanced encryption (General Rules guideline, 3-5-3-1). The Commission's Q&A 6-19 sets the conditions. The encryption must, by the technical standard at the time of the incident, make the data hard for a third party to read, for example a technique on the e-Government Recommended Ciphers List or ISO/IEC 18033, properly implemented. And the means of decryption must be properly managed, which requires one of: the encrypted data and the decryption key are kept apart and the key itself is protected from leaking; the encrypted data or the key can be deleted remotely; or the system is designed so a third party cannot use the key.

The practical consequence is that a key stored with the data, or leaked together with it, forfeits the exemption. Where the key lives and who can reach it is therefore a legal question as well as a technical one. Whether a given incident qualifies is decided case by case; take it to a qualified person.
