# What a User Gains by Pluginizing

This document is the vocabulary the proposal draws on when it tells a user *why* a candidate is worth turning into a plugin. A proposal that only names a candidate asks the user to supply the reasoning themselves. A proposal that names the candidate and the concrete benefit it would bring lets the user weigh the trade honestly, and lowers the cost of declining when the benefit does not apply.

The effects below come in two layers. The foundation is what is gained by making any piece of work reusable at all — the same value that motivates writing a skill. The upper layer is what a plugin adds on top, by virtue of being a larger unit than a skill. Reach for the layer that fits the candidate; do not recite all of it.

## The foundation: the value of making work reusable

These effects apply to any reusable artifact, a plain skill included. They are the baseline reason capturing work pays off.

**It is there for next time, without rediscovery.** Work that has been captured can be found and applied by a later session, or on a later project, without solving the same problem again from scratch. The cost of figuring it out the first time is paid once instead of every time.

**It stays out of the way until it is needed.** A well-formed artifact loads only its name and short description up front, and its full content only when something actually calls for it. Large reference material sitting in the artifact costs nothing until it is read. The context window is a shared resource, and this is how a reusable artifact respects it — which is the same discipline that lets this plugin watch for candidates without polluting the main conversation.

**It keeps steps from being skipped.** When a procedure is written down as explicit steps, the steps stop being quietly dropped under time pressure or fatigue. Encoding the order is what prevents the validation that matters from being the thing that gets cut.

**Bundled scripts beat regenerated code.** When the work includes a script, shipping the script is more reliable than regenerating equivalent code each time, spends no tokens including the code in context, and saves the time of writing it again. A known-good script is a known-good script.

## The upper layer: what a plugin adds beyond a skill

A plugin can do things a lone skill cannot, because it bundles more than knowledge. When a candidate is genuinely plugin-shaped, these are the effects worth naming.

**It can be distributed.** A plugin can be published to a marketplace and installed by other people and other projects. Its reach is wider than a skill living in one repository; the work travels.

**It can run on events, not only on request.** A plugin can ship a hook, so the value arrives at the right moment on its own — on a stop, an edit, a commit — without the user having to remember to invoke anything. Automation that does not depend on being asked is something only the plugin-level vessel provides.

**Its components cooperate.** A plugin lets a skill, an agent, a hook, and an MCP server pull toward one purpose together. When the value of the work is the coordination among parts rather than any single part, the plugin is what holds that coordination.

## Matching the benefit to the candidate

The point of having this vocabulary is to say the *right* thing, not the most things. Let the candidate's strongest axis and its sketched shape choose which benefit to lead with:

- A candidate that scored on **repeatability** leads with *there for next time, without rediscovery*.
- A candidate whose value is **automatic timing** leads with *it can run on events*.
- A candidate whose value is **coordination among parts** leads with *its components cooperate*.
- A candidate worth sharing beyond this repository leads with *it can be distributed*.

One well-aimed benefit persuades more than a list, and it leaves the user a clean decision rather than a sales pitch. The proposal is not trying to win; it is trying to give the user enough to choose well and to decline cheaply.
