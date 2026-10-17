# Operator Access — Say What the Key Holder Can See

## What application-level encryption cannot stop

Whoever runs the application holds, or can reach, the key it uses. An operator who can deploy code can deploy code that decrypts and prints; an operator who can read the secret store can decrypt an export by hand. Application-level encryption therefore protects against people and systems who have the data but not the key: a leaked export, a backup copied elsewhere, a read-only database credential, a provider-side snapshot, staff browsing raw tables. It does not make the operator unable to see the data, and no design that keeps server-side features can.

State this boundary in the design record, so nobody later reads "encrypted" as "unreadable by us".

## Narrowing what operators can do

Operator access cannot be removed while the server reads the data, but it can be made narrow, visible, and accountable.

- Separate duties: the people who deploy code, the people who can read secrets, and the people who can query production data are, where the team allows, not all the same person, and no routine task needs all three.
- Decrypt only through the application or a dedicated tool that checks authorization and writes an audit log, never through ad hoc scripts with the raw key.
- Make access to plaintext an exception: a recorded reason, a time limit, and a review afterwards, often called break-glass access.
- Log key use in the KMS, and alert on use from unexpected identities or at unexpected volume.
- Keep production data out of development and support tooling; use synthetic or masked data there.
- For a solo operator, the same controls reduce to the honest minimum: the key and its backup are held by the accountable person only, direct production queries are rare and recorded, and the privacy policy describes this truthfully.

## End-to-end encryption and what it costs

Client-side or end-to-end encryption, where only users' devices hold the keys, is the only design in which the operator genuinely cannot read the data. Weigh it against what it removes.

- Every server-side feature that reads the data stops: server-side search, generated documents, reports and totals across records, server-side AI features, and sending the data to external services on the user's behalf.
- Sharing among members of a team requires distributing keys between devices and handling members who leave.
- Account recovery becomes key recovery. A user who loses every device and the recovery secret loses the data, and the operator can do nothing.
- Multi-device use requires syncing keys securely.

It fits products whose value does not depend on the server understanding the data, such as messaging, password managers, and private notes. For products whose features are computed from the data on the server, it is usually the wrong layer, and the honest alternative is narrow operator access plus truthful disclosure.

## Saying only what is true

What the service tells users about encryption is a promise, and a broken one costs trust that no feature regains. Claim "encrypted at rest" when the provider does so; claim "we encrypt sensitive fields with keys stored separately" when the application does so; claim "we cannot read your data" only when the operator truly holds no key. Describe what operators can access and under what conditions in the privacy policy, in the same plain terms used in the design record.
