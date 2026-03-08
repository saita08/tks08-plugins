# Operations Guide (Reference for Generation)

**This file is a knowledge base used by the plugin during company generation.** It is NOT placed into the generated company. Instead, the plugin uses this as source material to create a company-specific `standards/operations.md` inside the generated repository.

The generated company should be self-contained — the CEO references files within the repository, not plugin files.

---

General knowledge for running AI companies day-to-day: starting sessions, managing files, scaling the organization, and maintaining alignment with founding principles. These patterns are designed to work with Claude Code Agent Teams, where the CEO runs as Team Lead and employees are spawned as Teammates.

---

## Standup (Morning Briefing)

The CEO's routine at the start of every session — like arriving at the office in the morning.

### Procedure

1. **Load CLAUDE.md**: Auto-loaded at session start. The CEO "wakes up" and remembers who they are
2. **Review COMPANY.md**: Re-confirm the company's principles (doesn't need a full re-read every time)
3. **Check recent logs**: Read latest meeting minutes and decision logs in `docs/`. Understand where the previous session left off
4. **Receive Owner instructions**: Ask the Owner what they want to accomplish today
5. **Assign tasks**: Based on Owner instructions, assign work to relevant employees
6. **Log standup**: Save brief standup record in `docs/`
7. **Call employees**: Bring in the employees needed for today's work (not everyone — just who's relevant)

### Standup Log Format

```markdown
# Standup YYYY-MM-DD

## Owner Instructions
- {instruction}

## Task Assignments
| Employee | Task |
|----------|------|
| {name} | {task} |

## Carryover from Previous Session
- {item}
```

---

## File Lifecycle Management

Files accumulate across sessions. Manage with these rules.

### Active vs Archive

- **Active**: Currently referenced or likely to be referenced soon. Keep in normal location
- **Archive**: Reference frequency has dropped. Move to `archive/`

### Archival Criteria

- Meeting minutes: Keep latest 10 active, move older to `archive/docs/`
- Decision logs: Archive after review date has passed
- Project deliverables: Archive completed projects to `archive/projects/`

### Knowledge Base

Repeatedly referenced insights should be summarized in `shared/knowledge-base/`. More efficient than re-reading individual logs each time.

**Example**: Insights from repeated research cycles (e.g., recurring evaluation criteria, common pitfalls) should be consolidated as knowledge, separate from individual reports.

---

## Constitutional Compliance in Operations

### Session-Start Value Check

At each session start, the CEO/President should verify:

1. No pending decisions from previous sessions that conflict with COMPANY.md principles
2. No employee outputs from previous sessions flagged for value-alignment review
3. Owner's new instructions don't conflict with established red lines (if they appear to, clarify with Owner before proceeding)

### Decision Audit Trail

Every significant decision should be traceable:

- **Who** decided (CEO/President? Owner?)
- **What** was decided
- **Why** (rationale referencing COMPANY.md principles where applicable)
- **What alternatives** were considered
- **What risks** were identified

This trail enables post-hoc review of constitutional compliance.

### Value Drift Detection

Over multiple sessions, gradual drift from founding principles can occur. Signs to watch for:

- Employees consistently ignoring certain COMPANY.md principles
- Escalation criteria being routinely bypassed
- Decisions being made without documented rationale
- Meeting minutes showing no inter-employee disagreement (may indicate suppressed dissent)

**Corrective action**: Review COMPANY.md with all employees, reinforce value hierarchy, update policies if the drift reflects a legitimate evolution of the company's direction (with Owner approval).

### Challenge Protocol

Any employee may invoke a "value check" at any time by:

1. Stating which principle they believe is being violated
2. Citing the specific section of COMPANY.md or standards/
3. Proposing an alternative course of action

The CEO/President must address the challenge before proceeding with the original decision. If the challenge is overruled, the rationale must be documented.

---

## Organization Scaling

### Adding New Members

1. Evaluate necessity per `standards/hiring-policy.md`
2. Create new `.md` file in `members/`
3. Update organization table in CLAUDE.md
4. Available to be called from next session

### Adding New Rooms

1. Create new directory
2. Create ROOM.md if the room needs functional definition
3. Update file reference map in CLAUDE.md
4. Add new storage location to `standards/deliverables.md`

### Adding New Policies

Add policies when operations reveal a gap. Don't preemptively create a large number.

**Proven timing for policy additions**:
- First meeting devolves into individual interviews -> add meeting rules
- Deliverables end up in random locations -> add deliverables policy
- Employee decisions misalign with Owner intent -> add escalation criteria
- Constitutional violations go unnoticed -> add audit procedures

---

## Troubleshooting

### CEO/President "forgets" at session start

Check if CLAUDE.md standup procedure includes "read recent logs" step. Add if missing.

### No inter-employee discussion happening

Check if meeting rules include Round 2 (cross-feedback) and explicitly permit direct inter-employee messaging.

### Inconsistent deliverable formats

Check if each employee's `members/{name}.md` defines an "Output Format" section. Add if missing.

### Context window pressure

- Verify CLAUDE.md is under 200 lines
- Confirm old files are being archived
- Check that spawn prompts don't include unnecessary files

### Too many / too few Owner confirmations

Review escalation criteria. Ambiguous criteria cause agents to either over-confirm or proceed without asking.

### Value alignment drift across sessions

Review the constitutional compliance section above. Run a value audit comparing recent decisions against COMPANY.md principles.

---

## Periodic Maintenance

Recommended monthly:

1. **File inventory**: Archive unnecessary files
2. **Knowledge base update**: Extract reusable insights from accumulated logs
3. **Organization review**: Check for unused employees or rooms
4. **Policy review**: Verify policies match operational reality
5. **Constitutional audit**: Review recent decisions for alignment with COMPANY.md principles
