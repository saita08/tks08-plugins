# External Services — Data That Leaves Is Kept on Their Terms

## Encryption at rest says nothing about data you send away

To use an external API, such as transcription, a language model, OCR, payments, email, or analytics, the application sends it plaintext. From that moment, what happens to the data is decided by the service's terms, not by the application's encryption. A carefully encrypted database can still leak through a service that keeps every request for months or trains on it. So the question for external services is not "is it encrypted" but "what do they keep, for how long, for what use, and can we stop it".

## The questions to ask of every service

For each service that receives stored or user-provided data, find a documented answer to each question.

1. Retention by default: is the request or its content stored at all, and for how long? Is that the same for every endpoint? Services often differ by endpoint and by feature.
2. Retention for abuse monitoring or safety: is content kept for a separate period even when ordinary storage is switched off?
3. Training and product improvement: is content used to train models or improve the service by default, can it be opted out, and does an opt-out apply to data sent before it?
4. Zero-retention options: is there a setting, request parameter, or contract under which nothing is kept, and what does it require, such as an enterprise plan, an approval process, or a particular endpoint?
5. Deletion: is there an API to delete stored inputs and outputs, and how long do backups keep them after deletion?
6. Location and sub-processors: in which countries is the data processed and stored, and which other companies handle it?
7. Human access: can the service's staff review content, and under what conditions?

Also confirm what the application actually sends. The parameter that disables storage must be present in the code, and the payload should contain only the fields the feature needs; minimizing the request is cheaper than any contract.

## Where the answers are, and how to record them

The answers live in the service's data-usage or privacy documentation for its API, its API reference, its data processing agreement, its trust or security page, and its sub-processor list. Consumer terms and API terms often differ, so read the ones that apply to the account in use. Record for each service the answer, the source URL, and the date it was read, and recheck before launch and whenever the service or the plan changes, because these pages change without notice. Where the documentation does not say, record "not documented" rather than assuming the favorable answer, and ask the vendor in writing.

When the answer is unfavorable, the choices are, in order of preference: send less; switch the storage off or use a deletion API right after use; move to a plan or contract that keeps nothing; switch to a service whose terms fit; or keep using it and tell users plainly what is sent and kept.

## The Japanese legal frame

Under the Act on the Protection of Personal Information, sending personal data to a service that processes it on the business's behalf is generally treated as outsourcing (Article 27(5)(i)), which needs no consent from the individual but obliges the business to supervise the contractor (Article 25). The Commission's Q&A 7-53 sets the test for cloud services: what matters is not whether stored data contains personal data but whether the provider is to handle it. A provider that by contract does not handle the stored personal data and controls access appropriately is not receiving it at all, so there is no provision and no supervision duty, though the business keeps its own security obligations (Q&A 7-54). An external API that reads the content to produce a result is handling it, so that exception does not apply.

When the service is located abroad, Article 28 on provision to a third party in a foreign country comes into play, and the security-control measures include understanding the external environment, meaning the personal-information regime of the country where the data is handled (General Rules guideline 10-7; Q&A 10-25 for foreign cloud services). Both affect what the privacy policy must say.

These are summaries of the published guidance for orientation, not legal advice. Whether a particular service is outsourcing, provision, or neither, and what the privacy policy must disclose, goes to a qualified person before launch.
