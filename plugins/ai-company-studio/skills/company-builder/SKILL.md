---
name: company-builder
description: >
  This skill should be used when the user asks to "create an AI company",
  "build a virtual company", "set up a company with AI employees",
  "make an AI-only organization", or wants to design and generate
  a repository structure that functions as an AI-only company.
  Provides a guided workflow from world-building concept design
  through file generation.
version: 0.1.0
---

# AI Company Builder

Guide for building "AI-only companies" as repositories.

World model: repository = company, directory = room, file = employee / policy / deliverable.

The generated company can be operated using Claude Code Agent Teams (Team Lead = CEO, Teammates = employees). The design principles in this skill ensure the world-building is structurally sound for this purpose, but the primary goal is creating a coherent company world.

## Governing Principles

All behavior in this skill is governed by these principles. When in doubt, refer back here.

1. **Owner sovereignty** — The user decides. The plugin proposes, explains trade-offs, and waits. Never advance without confirmation. Never silently override a choice.
2. **World integrity** — Every generated file must be explainable within the world model. No orphaned references, no files without a role, no aspirational content that doesn't match reality.
3. **Minimal viable structure** — Generate only what the company needs now. Unused structure creates the illusion of capability. When in doubt, generate less.
4. **Transparency** — Every convention has a reason. If a structure exists because of Agent Teams constraints or operational pitfalls, say so in the file. No hidden magic.
5. **Non-destruction** — The plugin creates; it never overwrites or deletes without explicit Owner permission.

## References

Load these as needed during execution:

- `references/design-principles.md` — Design principles and anti-patterns for AI company world-building
- `references/file-templates.md` — Templates for each file type with required fields
- `references/operations-guide.md` — Post-build guide for running the company across sessions

## Workflow

Execute 6 phases in order. Each phase requires Owner confirmation before proceeding (Governing Principle 1).

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

Recommend team size. The scale determines the company's organizational structure:

- **3-4 people**: Startup. CEO + few specialists. No departments — everyone is one team. One person may cover multiple roles. Directory structure is flat (projects/ or task-based workspaces)
- **5-8 people**: Mid-size. Departments become meaningful (2-3 people per department). Department directories and department-level meetings make sense. Clear leadership vs specialist separation
- **9+ people**: Not recommended. The CEO cannot effectively manage this many direct reports

**Start small** (Principle 3). A lean company is easier to operate and expand. Adding a member later is just creating a file in `members/`. A 1-person department is not a department — it's a person with a title. Departments only make sense when at least 2 people share them.

#### 2b. Employee Design

For each employee, define:

- Name (English names recommended for identification)
- Title and domain
- Personality/thinking tendency ("light" — no speech pattern differentiation needed, just domain expertise and judgment style differences)
- Specific task list

**Critical** (Principle 2): Personality traits create productive disagreement. If everyone reaches the same conclusion, there's no point in having an organization. Place employees along tension axes: optimism vs pessimism, qualitative vs quantitative, offense vs defense, customer-facing vs technical.

#### 2c. Authority Structure

Use 3 layers as baseline:

1. **Owner (user)**: Final decision-maker
2. **CEO/President**: Daily management, cross-department coordination, reporting to Owner
3. **Employees**: Domain-specific work

#### 2d. Escalation Criteria

Define what can be decided autonomously vs what requires Owner approval. Ambiguity here causes the company to either go rogue or stall on every decision.

Present organization proposal and get approval.

---

### Phase 3: Directory Design

Load `references/design-principles.md` and follow its principles.

#### Required Structure

```
company-name/
├── CLAUDE.md           # CEO/President consciousness (loaded at session start)
├── COMPANY.md          # Company philosophy / code of conduct
├── members/            # Employee files (1 file per person)
├── standards/          # Internal policies (meeting rules, deliverables, hiring)
├── docs/               # Meeting minutes, decision logs
└── shared/             # Shared space (inbox, knowledge-base)
```

#### Business-Specific Directories

Add based on business type AND company scale:

**Small (3-4 people)** — No department directories. Use task-based or project-based workspaces:
- Game studio: `projects/{title-name}/`
- Consulting: `clients/{client-name}/`
- General: organize by what the company produces, not by who produces it

**Mid-size (5-8 people)** — Department directories are appropriate when at least 2 people share a department:
- Investment advisory: `research/` (2-3 analysts), `strategy/` (2 strategists)
- Agency: `design/` (2 designers), `development/` (2 developers)
- Each department directory can hold department-specific meeting minutes and deliverables

**In both cases**: Employees are defined in `members/` and can work in any directory. Department membership is noted in employee files, but employees are not confined to their department's directory.

**Principle**: Directories should be places where artifacts accumulate — whether organized by project, by department function, or by output type. Avoid creating a directory that only one person ever uses.

Present directory structure and get approval.

---

### Phase 4: File Generation

Load `references/file-templates.md` and generate in this order:

#### 4a. Directory Creation

Confirm save path with user. If the target directory already contains files, warn the Owner before proceeding (Principle 5). Create all directories with `mkdir -p`. Place `.gitkeep` in directories that start empty (e.g., `docs/`, `shared/`, `archive/`) so they survive `git commit`.

#### 4b. CLAUDE.md (CEO/President Consciousness)

This file defines who the CEO is and how the company operates. It is auto-loaded at session start. Must include:

1. Self-awareness (who I am, what company, what role)
2. Company summary (details -> COMPANY.md)
3. Organization overview (employee list -> members/)
4. Leadership principles
5. Escalation criteria
6. Standup (morning briefing) procedure
7. **Employee call procedure** (standardized steps for bringing an employee into a session)
8. File reference map

**Keep it concise** (Principle 3). Target under 200 lines. Details go in other files via references.

**Employee call procedure is mandatory** (Principle 4). This is how the CEO "calls an employee into the room." Without a standardized procedure, the same employee may behave differently each time they are called. (In Agent Teams terms, this becomes the spawn prompt template.)

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

**Output format is critical.** Without it, employee outputs are inconsistent and the CEO's integration work increases.

#### 4e. standards/ (Internal Policies)

Create at minimum:

- `meeting-rules.md` — Meeting rules with round-based progression
- `deliverables.md` — Deliverables management (storage, naming, format)
- `hiring-policy.md` — Hiring/termination rules

Add more based on business type.

**Round-based meeting rules are strongly recommended.** When the CEO facilitates a meeting, a round structure (Round 1: ideas, Round 2: cross-feedback, Round 3: integration) ensures that employees discuss with each other, not just report to the CEO individually.

#### 4f. standards/operations.md (Operations Guide)

Generate a company-specific operations guide. Load `references/operations-guide.md` as the source of general knowledge, then tailor it to this company's scale, business type, and structure.

The generated `standards/operations.md` should include:

1. **Standup procedure** — adapted to this company's specific directories and roles
2. **File lifecycle rules** — where this company's artifacts go, when to archive
3. **Organization scaling guidance** — when and how to add people, departments, directories (include: "If the company grows past 5 people, consider introducing department directories")
4. **Periodic maintenance checklist** — what the CEO should review monthly
5. **Growth stage triggers** — "Signs You're Ready for the Next Stage" signals (from the template)

**This file must live inside the generated repository** (Principle 4), not in the plugin. After creation, the plugin is no longer involved — the CEO and the company's own files are the only reference.

#### 4g. Business-Specific Files

Create ROOM.md for business-specific directories if they need functional definition. Each ROOM.md includes:

1. Room name
2. Mission (1-2 sentences)
3. Tasks performed in this room
4. Authority and constraints
5. Cross-department dependencies (who sends what, who receives what)
6. Deliverable storage locations

**Do NOT put personality information in ROOM.md.** People info belongs in members/.

Not every directory needs a ROOM.md. Storage directories like `docs/` or `archive/` don't need one.

---

### Phase 5: Verification

Verify the generated files against Principle 2 (world integrity):

1. **Directory structure check**: `find` command to list all files, confirm nothing is missing
2. **CLAUDE.md coherence test**: Read CLAUDE.md and verify the CEO's world is internally consistent — no aspirational content, no references to things that don't exist
3. **Reference integrity**: Verify file reference map in CLAUDE.md matches actual files
4. **Call procedure check**: Confirm members/ files contain enough information for the CEO to call each employee

Report results. Fix any issues.

---

### Phase 6: Embed First-Day Task

The company exists on disk but has never been "turned on." The plugin cannot test the company itself — that happens in a separate session where the CEO wakes up for the first time.

Generate `docs/first-task.md`:

```markdown
# First Day Task

This is the company's first task. Run it to confirm everything works.

1. Call 1-2 employees into the session
2. Hold a meeting on "our company logo concept" — run Rounds 1 through 3
3. Save the result as `docs/meeting-001.md`
4. Report conclusions to the Owner

This file can be deleted after the test.
```

Present the following to the Owner:

1. The company has been generated at `{path}`
2. To start the company, open a new Claude Code session in that directory:
   ```
   cd {path}
   claude
   ```
3. Claude will read CLAUDE.md and wake up as the CEO
4. The CEO will find `docs/first-task.md` during standup — a test task to confirm everything works
5. After the test succeeds, `first-task.md` can be deleted

If the Owner plans to use Agent Teams, they can start with `claude --agent-teams` instead. The CEO's employee call procedure will work as spawn templates.
