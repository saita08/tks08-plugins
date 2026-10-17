# Construction — Authenticated, Bound, and Versioned

## Use authenticated encryption from a standard library

Encrypt with an AEAD, authenticated encryption with associated data, so that tampering is detected on decryption rather than producing silently wrong plaintext. OWASP names GCM and CCM as the first preference and AES with a 256-bit key as the default strength. AES-GCM is on Japan's CRYPTREC e-Government Recommended Ciphers List, which matters for the breach-reporting question in `key-management.md`. ChaCha20-Poly1305 is the usual alternative where AES hardware is absent.

Call the platform's standard primitives: the Web Crypto API in browsers and edge runtimes, the language's standard crypto module, or a misuse-resistant library such as libsodium or Google Tink. Never implement a mode, padding, or key derivation by hand, and never use ECB or unauthenticated CBC.

## Nonces: unique per key, and counted

GCM fails catastrophically if a nonce repeats under the same key: confidentiality and authenticity are both lost for the affected messages. Generate a fresh 96-bit nonce from a CSPRNG for every encryption and store it with the ciphertext. NIST SP 800-38D limits a key used with random 96-bit nonces to 2^32 encryptions, because beyond that the chance of a repeat exceeds the bound the standard sets. A small product never approaches that limit, but a high-volume one can, and the limit is one of the reasons rotation exists. A nonce-misuse-resistant mode such as AES-GCM-SIV softens the consequence of a repeat where the library offers it.

## Bind the ciphertext to its place

Pass associated data that names where the ciphertext belongs: the table or record type, the column, and the row's identifier, and the tenant identifier in a multi-tenant system. The associated data is authenticated but not encrypted. Without it, an attacker who can write to the database can move a valid ciphertext from one row or one tenant to another, and it decrypts cleanly in the wrong place. With it, the move fails authentication. Associated data must be reconstructible at read time from values that do not change, so do not bind to anything that is updated.

## Make the format name its key

Store each value as a self-describing envelope, for example a short prefix that marks it as encrypted and gives a format version and a key identifier, followed by the nonce and the ciphertext with its tag. The Rails Active Record Encryption guide calls this storing a reference to the key in the message; it costs a few bytes and makes rotation possible without guessing which key to try. The marker also lets the reader tell an encrypted value from a plain one during migration.

## Envelope encryption and per-tenant keys

In envelope encryption a data encryption key (DEK) encrypts the data, and a key encryption key (KEK) encrypts the DEK. The wrapped DEK is stored next to the data; the KEK stays in a key management service and never leaves it. The Google Cloud KMS documentation gives the practice directly: generate DEKs locally, never store a plaintext DEK, and never use the same DEK to encrypt data from two different users. OWASP adds that the KEK must be stored separately from the DEK and be at least as strong.

Two benefits follow. Rotating the KEK requires rewrapping small DEKs, not re-encrypting the data. And a DEK per tenant or per user makes deletion real: destroying that DEK renders every copy of that tenant's data unreadable, including copies held in backups and recovery snapshots that the application cannot reach. This is called crypto-shredding, and it is often the only way to make "deleted" true for provider-held backups.

A single application key held in the platform's secret store is a legitimate simpler starting point. Move to envelope encryption when a KMS is available, when per-tenant deletion matters, or when the volume makes rotation by re-encryption expensive.

## Migrating existing rows

Existing plaintext rows are moved without stopping the service, in this order.

1. Deploy a reader that accepts both plain and encrypted values, recognizing the encrypted ones by their marker, while writes remain plain. Rails names this transitional mode `support_unencrypted_data` and recommends switching it off once migration ends.
2. Deploy writes that encrypt.
3. Backfill old rows in small batches, idempotently, skipping values that already carry the marker, so the job can be interrupted and rerun.
4. Verify that no plain value remains, by counting rows without the marker, not by trusting the job's log.
5. Remove the plain-value path from the reader, so a plain value appearing later is an error rather than silently accepted.

Take a backup before the backfill, and treat that backup as plaintext personal data with its own deletion date.

## What breaks once a field is encrypted

Say these before the change, not after.

- The database can no longer search, sort, aggregate, or constrain the field (`what-to-encrypt.md`).
- Operators reading tables directly see ciphertext, so investigations go through the application or a controlled decryption tool.
- Losing the key means losing the data, permanently (`key-management.md`).
- Ciphertext is longer than plaintext, so column limits and payload sizes may need room.
