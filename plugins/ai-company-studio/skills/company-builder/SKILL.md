---
name: company-builder
description: >
  This skill should be used when the user asks to "create an AI company",
  "build an Agent Teams organization", "set up a virtual company",
  "make a company with AI agents", or wants to design and generate
  a repository structure that functions as an AI-only company for
  Claude Code Agent Teams. Provides a guided workflow from concept
  design through file generation.
version: 0.1.0
---

# AI Company Builder

Guide for building "AI-only companies" as repositories using Agent Teams.

World model: repository = company, directory = room, file = employee / policy / deliverable.

## References

Load these as needed during execution:

- `references/design-principles.md` — Design principles and anti-patterns (lessons from real deployments)
- `references/file-templates.md` — Templates for each file type with required fields
- `references/operations-guide.md` — Post-build operations guide (standup, file lifecycle, spawn procedures)

## Workflow

Execute 5 phases in order. Use AskUserQuestion at each phase to confirm with the user.

Respect the user's language preference. If the user communicates in Japanese, generate all company files in Japanese. If in English, generate in English.

---

### Phase 1: Concept Design

Ask the user (skip what's already clear):

1. **Company name** — Name and origin/meaning (if any)
2. **Business type** — What does the company do? (investment advisory, game studio, consulting, media, etc.)
3. **World-building tone** — Realistic or playful?
4. **Owner's role** — How involved is the user? (final approver? vision provider? active participant?)
5. **Internal language** — Japanese / English / other

Confirm concept summary before proceeding.

---

### Phase 2: Organization Design

#### 2a. Scale

Recommend based on Agent Teams constraints:

- **3-5 people**: Startup, small project. CEO + few specialists. Many concurrent roles
- **6-8 people**: Mid-size. Department differentiation begins. C-Suite vs members
- **9+ people**: Not recommended. Context overhead for Team Lead is too high

**Principle: Start small.** Question scope before adding headcount. Adding a member later is just creating a file in `members/`.

#### 2b. Employee Design

For each employee, define:

- Name (English names recommended for spawn identification)
- Title and domain
- Personality/thinking tendency ("light" — no speech pattern differentiation needed, just domain expertise and judgment style differences)
- Specific task list

**Critical**: Personality traits are a device for "disagreement" in Agent Teams. If everyone reaches the same conclusion, there's no point in having an organization. Place employees along tension axes: optimism vs pessimism, qualitative vs quantitative, offense vs defense, customer-facing vs technical.

#### 2c. Authority Structure

Use 3 layers as baseline:

1. **Owner (user)**: Final decision-maker
2. **CEO/President (Team Lead)**: Daily management, cross-department coordination, reporting to Owner
3. **Employees (Teammates)**: Domain-specific work

#### 2d. Escalation Criteria

Define what can be decided autonomously vs what requires Owner approval. Ambiguity here causes agents to either go rogue or block on every decision.

Present organization proposal and get approval.

---

### Phase 3: Directory Design

Load `references/design-principles.md` and follow its principles.

#### Required Structure

```
company-name/
├── CLAUDE.md           # CEO/President consciousness (Team Lead bootstrap)
├── COMPANY.md          # Company philosophy / code of conduct
├── members/            # Employee files (1 file per person)
├── standards/          # Internal policies (meeting rules, deliverables, hiring)
├── docs/               # Meeting minutes, decision logs
└── shared/             # Shared space (inbox, knowledge-base)
```

#### Business-Specific Rooms

Add based on business type. Examples:

- Game studio: `projects/{title-name}/`
- Investment advisory: `research/`, `strategy/`, `risk/`
- Consulting: `clients/{client-name}/`, `deliverables/`

**Principle**: Do NOT bind people to rooms 1:1. Rooms are tied to functions, not people.

Present directory structure and get approval.

---

### Phase 4: File Generation

Load `references/file-templates.md` and generate in this order:

#### 4a. Directory Creation

Confirm save path with user. Create all directories with `mkdir -p`.

#### 4b. CLAUDE.md (CEO/President Consciousness)

Auto-loaded at Team Lead session start. Must include:

1. Self-awareness (who I am, what company, what role)
2. Company summary (details -> COMPANY.md)
3. Organization overview (employee list -> members/)
4. Leadership principles
5. Escalation criteria
6. Standup (morning briefing) procedure
7. **Spawn template** (specific steps for launching Teammates)
8. File reference map

**Keep it concise.** Target under 200 lines. Details go in other files via references.

**Spawn template is mandatory.** Without it, each spawn uses a different prompt and employee behavior varies across sessions.

#### 4c. COMPANY.md (Philosophy & Policies)

Include:

1. Company overview and world-building rules
2. Business philosophy / code of conduct
3. Business policies (communication protocol, escalation criteria)
4. Meeting rules summary (reference to standards/meeting-rules.md)
5. Deliverables management summary (reference to standards/deliverables.md)

#### 4d. members/{name}.md (Employee Files)

Create for all employees except CEO/President. Each file includes:

1. Name and title
2. Domain
3. Personality / thinking tendency
4. Specific task list
5. Judgment criteria
6. **Output format** (required structure for this employee's deliverables)

**Output format is critical.** Without it, Teammate outputs are inconsistent and Team Lead integration cost increases.

#### 4e. standards/ (Internal Policies)

Create at minimum:

- `meeting-rules.md` — Meeting rules with round-based progression
- `deliverables.md` — Deliverables management (storage, naming, format)
- `hiring-policy.md` — Hiring/termination rules

Add more based on business type.

**Round-based meeting rules are strongly recommended.** This pattern matches Agent Teams' turn-based communication model (Team Lead -> Teammate -> Team Lead) and is proven in production.

#### 4f. Business-Specific Files

Create ROOM.md for business-specific directories. Each ROOM.md includes:

1. Room name
2. Mission (1-2 sentences)
3. Tasks performed in this room
4. Authority and constraints
5. Cross-department dependencies (who sends what, who receives what)
6. Deliverable storage locations

**Do NOT put personality information in ROOM.md.** People info belongs in members/.

---

### Phase 5: Verification

Verify the generated files:

1. **Directory structure check**: `find` command to list all files, confirm nothing is missing
2. **CLAUDE.md bootstrap test**: Read CLAUDE.md and self-check if CEO/President behavior is coherent
3. **Reference integrity**: Verify file reference map in CLAUDE.md matches actual files
4. **Spawn template check**: Confirm members/ files are in a format that works with spawn prompts

Report results. Fix any issues.

Finally, inform the user about `references/operations-guide.md` for post-build operations.

## Prohibitions

- Do NOT bind people to rooms 1:1 (prevents cross-department work)
- Do NOT make CLAUDE.md too long (increases boot cost)
- Do NOT give all employees the same personality (discussions converge too quickly)
- Do NOT skip the spawn template (reproducibility is lost)
- Do NOT run multi-person discussions without meeting rules (chaos)
