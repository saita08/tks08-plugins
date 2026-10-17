---
name: data-encryption
description: This skill should be used when designing how an application protects the data it stores and the keys that protect it — when the user mentions "データを暗号化したい", "暗号化して保存", "どの項目を暗号化するか", "暗号化の鍵の管理", "鍵の置き場所", "鍵のローテーション", "鍵を替えられるか", "鍵を失くしたら", "運営がデータを見られる", "エンドツーエンド暗号化", "外部 API にデータを送っても大丈夫か", "送ったデータが保存されるか", "漏えい等報告", "encrypt the data at rest", "which fields should be encrypted", "where should the key live", "rotate the encryption key", "what if we lose the key", "can the operator read user data", "end-to-end encryption", "does this API keep what we send", or plans application-level encryption, envelope encryption, a KMS, key rotation, or a data-retention check of a third-party API. Provides product-agnostic principles for choosing what to encrypt, building the ciphertext, keeping keys, facing operator access, and verifying what external services keep, checked against OWASP, NIST, cloud KMS documentation, and Japan's Personal Information Protection Commission guidance as of 2026.
user-invocable: false
allowed-tools: Read
---

# Encrypting Stored Data and Keeping Its Keys

This skill holds the judgment for protecting the data an application stores. It was distilled from designing application-level encryption for a working web product, then rewritten as product-agnostic principles and checked against the standards of 2026: the OWASP Cryptographic Storage and Key Management Cheat Sheets, NIST SP 800-57 and SP 800-38D, the envelope-encryption documentation of the major cloud KMS offerings, and the guidelines and Q&A of Japan's Personal Information Protection Commission.

One value sits at the core. Encryption protects against a named threat, and only against that threat. The provider's encryption at rest already defeats a stolen disk and does nothing against a leaked database export; application-level encryption defeats a leaked export and does nothing against the application itself, which decrypts on every request. So every decision here begins by naming who could read the data and through which door, and a field is encrypted where that door is real and the cost in lost features is known and accepted. "Encrypt everything" is not a design; it is the absence of one.

The references are split by concern. Read only the one that matches the question at hand.

- `references/what-to-encrypt.md` — scope. The layers of encryption and the threat each one answers, choosing fields by sensitivity against what the database must still do with them, blind indexes and deterministic encryption for the lookups that remain, the copies of a value that escape the column, and what deliberately stays plain. Read when deciding which data to encrypt.
- `references/construction.md` — the ciphertext. Authenticated encryption, nonces and their limits, binding a ciphertext to its place with associated data, a versioned format that names its key, envelope encryption and per-tenant keys, and moving existing rows without downtime. Read when it is time to write the encryption code.
- `references/key-management.md` — the key. Generation, where a key lives and who can reach it, the backup copy kept elsewhere, rotation and cryptoperiods, the plan for a compromised key, and why key separation decides whether a breach must be reported in Japan. Read when creating, storing, rotating, or recovering a key.
- `references/operator-access.md` — the people who run the service. What application-level encryption cannot stop when the operator holds the key, the controls that narrow operator access, what end-to-end encryption actually costs, and saying only what is true about it. Read when the question is whether the operator can see the data.
- `references/external-services.md` — data that leaves. Why encryption at rest says nothing about a third-party API, the questions to ask of every service the data is sent to, where to find and record the answers, and the Japanese legal frame for outsourcing and cross-border transfer. Read before sending stored data to an external API, or when reviewing one already in use.

Keep three postures when applying these principles. First, numbers such as cryptoperiods and nonce limits come from the cited standards; check the current text before relying on one, because standards are revised. Second, the legal notes describe the Japanese guidance as published and are not legal advice; anything that decides a contract, a privacy policy, or a breach report goes to a qualified person. Third, state what a design does not protect as plainly as what it does; an encryption scheme presented as stronger than it is costs more trust than one that was never built.

## Sources

- OWASP, [Cryptographic Storage Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Cryptographic_Storage_Cheat_Sheet.html) and [Key Management Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Key_Management_Cheat_Sheet.html)
- NIST, [SP 800-57 Part 1 Rev. 5, Recommendation for Key Management](https://doi.org/10.6028/NIST.SP.800-57pt1r5) and [SP 800-38D, Galois/Counter Mode](https://doi.org/10.6028/NIST.SP.800-38D)
- Google Cloud, [Envelope encryption](https://docs.cloud.google.com/kms/docs/envelope-encryption)
- Rails, [Active Record Encryption](https://guides.rubyonrails.org/active_record_encryption.html)
- Paragon Initiative, [CipherSweet security properties of blind indexes](https://ciphersweet.paragonie.com/security)
- IPA and CRYPTREC, [暗号鍵管理システム設計指針(基本編) and its checklist](https://www.ipa.go.jp/security/crypto/guideline/ckms.html), the Japanese government-backed guideline for designing a key management system, version 1.1 of April 2026
- CRYPTREC, [e-Government Recommended Ciphers List](https://www.cryptrec.go.jp/list.html)
- Personal Information Protection Commission, [General Rules guideline](https://www.ppc.go.jp/personalinfo/legal/guidelines_tsusoku/) and [Q&A on the guidelines](https://www.ppc.go.jp/personalinfo/faq/APPI_QA/)
