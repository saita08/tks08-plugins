# Design Principles for AI Companies

Principles for designing AI companies that actually run on Agent Teams. Derived from two production deployments (game studio, investment advisory firm).

## Principles

### 1. Do Not Bind People to Rooms 1:1

**Good (function-based rooms)**:
```
members/     # People live here
projects/    # Rooms per project
docs/        # Deliverables go here
```
Who uses which room depends on the task. Cross-department work happens naturally.

**Bad (person-bound rooms)**:
```
research/    # Elena only
quant/       # Nate only
strategy/    # Sophia only
```
When people and rooms are 1:1, cross-functional collaboration becomes difficult.

### 2. Keep CLAUDE.md Short, Delegate to References

CLAUDE.md is loaded at every session start. Long files increase boot cost and consume context window.

**Target**: Under 200 lines. Delegate details to COMPANY.md, members/, and standards/.

**Required items**:
- Self-awareness (who am I, what company, what role)
- Organization overview (table with members/ references)
- Leadership principles and escalation criteria
- Standup procedure
- Spawn template
- File reference map

### 3. Always Provide a Spawn Template

Reproducibility in Agent Teams depends on "how you spawn Teammates." Without a template, different prompts are used each time and employee behavior varies across sessions.

**Template example**:
```
When spawning a Teammate:
1. Read members/{name}.md
2. Read relevant standards/*.md
3. Compose spawn prompt:

"You are {company}'s {title} {name}.
{contents of members file}
Current task: {specific instructions}
Applicable policies: {standards content}
Save deliverables to: {path}"
```

### 4. Use Round-Based Meeting Rules

Agent Teams' communication model (Team Lead -> Teammate -> Team Lead) is turn-based. Round-based meeting protocol matches this naturally.

**Basic rounds**:
- Round 1: Each employee presents ideas (no critique)
- Round 2: Cross-feedback (direct discussion between employees allowed)
- Round 3: CEO/President presents draft, employees refine

**Why it matters**: Without rounds, the CEO individually interviews each employee and reports "we had a meeting." This is a reporting session, not a meeting — no inter-employee discussion emerges.

### 5. Place Employees Along Tension Axes

If everyone reaches the same conclusion, there's no point in having an organization. Design tension axes:

- Optimism vs pessimism (offense vs defense)
- Qualitative vs quantitative (intuition vs data)
- Short-term vs long-term (today's profit vs 3-year vision)
- Customer-facing vs technical (user experience vs implementation cost)

Tension is healthy. The CEO/President integrates.

### 6. Create Deliverables Policy on Day One

Without unified storage locations, naming conventions, and formats, chaos accumulates across sessions.

**Minimum decisions**:
- Meeting minutes storage and naming (e.g., `docs/meeting-001.md`)
- Project deliverable storage (e.g., `projects/{name}/`)
- File naming case (kebab-case recommended)
- Version control policy (use git, never put version numbers in filenames)

### 7. Limit Room Count to Context Capacity

Team Lead must grasp the whole organization at session start. More rooms = more overhead.

**Guidelines**:
- 5 or fewer rooms: Team Lead can easily oversee everything
- 6-8 rooms: Caution needed. File reference map is mandatory
- 9+ rooms: Not recommended. Use subdirectories instead

### 8. Partition Inbox by Recipient

All departments' messages in one directory creates noise.

**Recommended**: Split by recipient (`shared/inbox/{name}/`) or use naming convention like `{PRIORITY}-from-{sender}-to-{recipient}-{date}.md` for filtering.

### 9. Build Constitutional Guardrails into the Organization

Apply Constitutional AI principles to company design. The organization should have built-in mechanisms for self-correction and value alignment.

**Structural checks and balances**:
- CEO/President reviews all Teammate outputs before reporting to Owner (first-pass filter)
- Employees with opposing viewpoints review each other's work (peer critique)
- Escalation criteria act as constitutional boundaries — hard limits that cannot be overridden by any single agent
- Meeting minutes create an audit trail for constitutional compliance

**Value alignment hierarchy**:
```
Owner's values and directives (highest priority)
  -> COMPANY.md principles and code of conduct
    -> standards/ policies
      -> Individual employee judgment
```

When a conflict arises between levels, the higher level always wins. An employee cannot override company policy. Company policy cannot override Owner directives.

**Self-correction protocol**:
- When an employee's output contradicts COMPANY.md principles, the CEO/President must flag and correct before proceeding
- When the CEO/President's decision contradicts Owner's known preferences, escalate rather than proceed
- Include a "challenge" mechanism: any employee can raise a concern about value misalignment, and it must be addressed before the decision is finalized

**Red lines** (non-negotiable boundaries to define in COMPANY.md):
- Actions that require Owner approval regardless of urgency
- Ethical boundaries specific to the business domain
- Scope limits (what the company will NOT do)

### 10. Design for Graceful Degradation

Sessions may be interrupted, context may be lost, or a Teammate may produce unexpected output. Design the organization to handle these gracefully.

- All important state is persisted to files (never rely on in-memory context alone)
- Decision logs include enough context to be understood without prior conversation
- Each session's standup procedure reconstructs state from files, not memory
- If a Teammate's output is incoherent, the CEO/President discards and re-spawns rather than trying to salvage

## Anti-Patterns

### Copying Fortune 500 Org Charts

Agent Teams is optimized for small teams. Replicating a large corporate structure doesn't work.

### Over-Differentiating Speech Patterns

"Ends sentences with ~desu wa" or "Uses archaic first-person pronouns" — unnecessary. Thinking tendencies and judgment criteria matter more on Agent Teams.

### Always Spawning All Employees

Only spawn who's needed. Spawning everyone simultaneously disperses context. 2-3 people per topic is appropriate.

### Deferring Policies

"Let's run it first, then make rules" fails. You'll end up with a meeting rule after the first meeting gets called out as "just individual interviews" (true story).

### Skipping the Constitutional Layer

Without explicit value hierarchies and self-correction mechanisms, agents may optimize locally (completing their task) at the expense of global alignment (company values, Owner intent). The constitutional layer prevents drift across sessions.
