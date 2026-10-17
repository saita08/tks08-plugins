# Scope — Name the Door Before Locking It

## Each layer answers a different threat

Encryption happens at several layers, and each one protects against a different reader. OWASP puts it in one line: which layers are appropriate depends on the threat model.

| Layer | Who holds the key | Defeats | Does not defeat |
|---|---|---|---|
| Disk or storage encryption at rest, run by the provider | The provider | A stolen or discarded disk, a provider-side media leak | Anyone who reaches the data through the provider's normal interfaces: the application, a database console, an export, a compromised account |
| Application-level field encryption | The application, through a key held outside the database | A leaked export or backup, a read-only database compromise, a provider-side snapshot, staff browsing raw tables | The running application and anyone who controls it, because it decrypts on every request |
| Client-side or end-to-end encryption | Only the users' devices | The operator, the provider, and anyone who compromises the server | A compromised device; and it removes every server-side feature that needs to read the data |

Most managed databases already encrypt at rest by default. Confirm this from the provider's documentation and say so, because it answers "is our data encrypted?" for the stolen-disk threat with no work. Then ask the question that remains: through which door could someone read the data without the disk, and is that door worth closing at the application layer?

## Store less first

The OWASP Cryptographic Storage Cheat Sheet opens with the strongest control: the best way to protect sensitive information is to not store it in the first place. Before choosing fields to encrypt, list fields that need not be kept at all, fields that can be kept for a shorter time, and contact details that duplicate what an identity provider already holds. A deleted column needs no key, no rotation, and no breach analysis.

## Choose fields by sensitivity against what the database must do with them

Application-level encryption makes a column opaque to the database. It can still be stored and returned, but the database can no longer search it, sort by it, aggregate it, join on it, or enforce uniqueness over it. So weigh each field on two axes.

- Sensitivity: what harm follows if this field alone leaks. Bank account details, addresses and names of private individuals, identity numbers, health information, free-text notes, and uploaded documents are high. Data about third parties who never agreed to the service, such as a customer's own customers, ranks higher than data about the account holder.
- Database use: whether any query today filters, sorts, groups, sums, or joins on it. Check the code, not the schema; a column can look searchable and be used by nothing.

Encrypt the fields that are sensitive and that the database does not need to read. Fields that drive search, ordering, and totals, such as amounts, dates, status codes, and the names of business counterparties used for lookup, usually stay plain; a leaked amount without a readable name or address rarely identifies anyone. Values that are already public by law, such as published registration numbers, gain nothing from encryption.

When a field is both sensitive and needed for lookup, the choice is explicit and recorded: keep it plain and accept the exposure, or encrypt it and add one of the techniques below.

## When an encrypted field must still be found

- Blind index. Store a keyed hash, such as HMAC with its own key, of a normalized form of the value beside the ciphertext, and look up by that hash. It supports exact-match lookups only: no partial match, no range, no ordering. It leaks equality, so rows with the same value are visibly linked; CipherSweet's documentation recommends truncating the index and keeping the number of indexes small so matches become coincidences rather than proof. Use a key separate from the encryption key.
- Deterministic encryption. The same plaintext always yields the same ciphertext, so equality queries and uniqueness constraints work. The Rails Active Record Encryption guide offers it as an option that trades away security for queryability and recommends non-deterministic encryption unless querying is needed; it also notes that deterministic fields cannot be rotated in the usual way.
- Searching in the application. For small per-tenant datasets, decrypting the tenant's rows and filtering in memory is often simpler and leaks nothing. Measure the size before dismissing it.

Partial-match and full-text search over ciphertext have no orthodox answer at the application layer. If the product needs them on a sensitive field, that is a reason to keep the field plain behind access control, not a reason to invent a scheme.

## A value lives in more places than its column

Encrypting a column is undone by every plain copy of the value elsewhere. Before declaring a field protected, follow it everywhere it goes.

- Snapshots and documents: rendered copies of issued documents, cached previews, JSON blobs that embed the same address or account number. These are rarely searched and are often the richest target, so encrypt them whole.
- Logs, traces, and error reports: request bodies, query parameters, and exception messages. Keep plaintext out of them by construction, not by redaction after the fact.
- Backups, point-in-time recovery, exports, and replicas: provider-managed copies that outlive a deletion. Application-level encryption carries into these automatically; that is much of its value.
- Search indexes, analytics pipelines, caches, and browser storage.
- External services the value is sent to, covered in `external-services.md`.

## What staying plain means

Leaving a field plain is a decision, not an omission. Record which fields stay plain and why, so a later reader does not mistake the choice for a gap and so a later change in use reopens the question. Dates are a common example: needed for ordering and ranges, weakly identifying alone, and expensive to lose in the database.
