# Design Principles for AI Company World-Building

Principles for designing AI companies that feel like real organizations and function when operated.

## Principles

### 1. Separate People from Places

Employees live in `members/`. Directories represent workspaces, not individuals.

**Good (function-based directories)**:
```
members/     # People live here
projects/    # Workspaces per project
docs/        # Deliverables go here
```
Who works in which directory depends on the task. Cross-functional collaboration happens naturally.

**Bad (person-bound directories)**:
```
research/    # Alice only
analysis/    # Bob only
strategy/    # Carol only
```
When people and directories are 1:1, the company becomes rigid. An employee can only work "in their room" and collaboration requires awkward handoffs.

### 2. Keep the CEO's Mind Small

CLAUDE.md defines the CEO's consciousness. It's loaded at every session start — think of it as the CEO's morning routine. A long file means a slow, distracted CEO.

**Target**: Under 200 lines. Delegate details to COMPANY.md, members/, and standards/.

**What the CEO needs to know on waking**:
- Who am I, what company, what role
- Organization overview (table with members/ references)
- Leadership principles and escalation criteria
- How to start the day (standup procedure)
- How to call an employee (call procedure)
- Where things are (file reference map)

### 3. Standardize How the CEO Calls Employees

When the CEO brings an employee into a session, the procedure must be consistent. Otherwise the same employee behaves differently each time — as if they forget who they are between shifts.

The CEO spawns employees as separate Teammates via Agent Teams. The call procedure defines the spawn prompt template:

```
To call an employee:
1. Read members/{name}.md to build context
2. Read relevant standards/*.md for applicable policies
3. Compose a spawn prompt including all of the above plus the specific task
4. Spawn the employee as a Teammate
```

The CEO must never read the employee file and act as that employee within its own context. Every employee is a separate agent.

This is the company's "onboarding procedure" — every employee goes through the same process every time they come to work.

### 4. Use Round-Based Meetings

A meeting is not the CEO interviewing employees one by one. A meeting is employees discussing with each other while the CEO facilitates.

**Basic rounds**:
- Round 1: Each employee presents ideas (no critique)
- Round 2: Cross-feedback (employees evaluate each other's ideas)
- Round 3: CEO presents a draft, employees refine

**Why rounds work**: Without structure, the CEO naturally defaults to sequential 1-on-1 conversations. Rounds force inter-employee interaction, which is the whole point of having a team.

Between rounds, employees can and should message each other directly via Agent Teams direct messages. Don't force all communication through the CEO — if employee A's idea affects employee B's domain, they should discuss it directly. All agreements must be reported to the CEO.

### 5. Design Employees for Productive Disagreement

If everyone reaches the same conclusion, there's no point in having an organization. Design tension axes:

- Optimism vs pessimism (offense vs defense)
- Qualitative vs quantitative (intuition vs data)
- Short-term vs long-term (today's profit vs 3-year vision)
- Customer-facing vs technical (user experience vs implementation cost)

Tension is healthy. The CEO integrates opposing views into balanced decisions.

### 6. Establish Policies on Day One

Without unified storage locations, naming conventions, and meeting formats, the company accumulates chaos across sessions.

**Minimum policies to create upfront**:
- Meeting rules (how meetings are structured)
- Deliverables management (where things go, what they're called)
- Hiring/termination rules (how the company grows and shrinks)

Don't wait for problems to appear before creating these. The problems are predictable.

### 7. Match Directory Structure to Company Scale

The directory structure should reflect the company's size, not an aspirational org chart.

**Small companies (3-4 people)**: No department directories. Everyone is one team.
- Directories are organized by what the company produces: `projects/`, `clients/`, etc.
- Organizational structure (roles, specialties) lives in members/ files and COMPANY.md
- A "department" is just a label on an employee, not a physical space

**Mid-size companies (5-8 people)**: Department directories make sense — IF at least 2 people share a department.
- Department directories serve as workspaces where the department's artifacts accumulate
- Department-level meetings can happen (e.g., "research team, discuss this among yourselves")
- The CEO can delegate to a department rather than managing every individual

**In both cases**, distinguish workspaces from storage:

- `projects/`, `research/` — workspaces. Employees actively collaborate here
- `docs/` — storage. Meeting minutes accumulate here
- `archive/` — cold storage. Nobody visits unless digging up history

Only workspace directories need ROOM.md files. Storage directories don't need formalization.

**Key rule**: Don't create a directory that only one person ever uses. That's not a room — it's a desk.

### 8. Organize Communication Channels

If all messages pile up in one directory, the CEO wastes time sorting through noise.

**Recommended**: Split by recipient (`shared/inbox/{name}/`) or use naming convention like `{PRIORITY}-from-{sender}-to-{recipient}-{date}.md` for filtering.

### 9. Build a Value Hierarchy

The company needs a "constitution" — a clear priority order for decision-making:

```
Owner's values and directives (highest priority)
  -> COMPANY.md principles and code of conduct
    -> standards/ policies
      -> Individual employee judgment
```

When a conflict arises between levels, the higher level always wins. An employee cannot override company policy. Company policy cannot override Owner directives.

**Self-correction mechanisms**:
- When an employee's output contradicts COMPANY.md principles, the CEO flags and corrects before proceeding
- When the CEO's decision contradicts Owner's known preferences, escalate rather than proceed
- Any employee can raise a concern about value misalignment, and it must be addressed before the decision is finalized

**Red lines** (non-negotiable boundaries to define in COMPANY.md):
- Actions that require Owner approval regardless of urgency
- Ethical boundaries specific to the business domain
- Scope limits (what the company will NOT do)

### 10. Persist Everything to Files

The company's memory lives in files, not in anyone's head. Sessions end, context is lost, but files remain.

- All important state is persisted to files
- Decision logs include enough context to be understood without prior conversation
- Each session's standup procedure reconstructs state from files
- If an employee's output is incoherent, the CEO discards and re-calls rather than trying to salvage

## Anti-Patterns

### Copying Fortune 500 Org Charts

An AI company with 3-8 people doesn't need 10 departments. Design for the company you have, not the company you admire.

### Over-Differentiating Speech Patterns

"Ends sentences with ~desu wa" or "Uses archaic first-person pronouns" — this doesn't contribute to the quality of work. Thinking tendencies and judgment criteria matter. Speech patterns are cosmetic.

### Always Calling All Employees

Only call who's needed. Bringing everyone into every discussion wastes the CEO's time and dilutes focus. 2-3 people per topic is usually sufficient.

### Deferring Policies

"Let's run it first, then make rules" fails. The first meeting will devolve into individual interviews with the CEO, and you'll wish you had meeting rules from the start.

### Skipping the Value Hierarchy

Without explicit value priorities and self-correction mechanisms, employees may optimize for their own tasks at the expense of the company's principles. The value hierarchy prevents drift across sessions.
