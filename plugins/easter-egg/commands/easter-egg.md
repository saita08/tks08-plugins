---
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion, Skill
description: Plant an easter egg in the current project. Analyzes the codebase, proposes fitting easter eggs, and implements the user's choice.
argument-hint: (no arguments needed - auto-detects project tech stack)
---

Plant an easter egg in the current project through an interactive, conversational flow.

## Constitution (Behavioral Principles)

| # | Principle | Type |
|---|-----------|------|
| C-1 | Always load the `easter-egg:easter-egg-knowledge` skill via the Skill tool before proposing candidates. The skill contains expert knowledge on implementation patterns, best practices, and famous examples. | MUST |
| C-2 | Propose at least 3 easter egg candidates with different trigger types and difficulty levels. Never implement without user selection. | MUST |
| C-3 | Easter eggs MUST NOT affect normal application performance, security, or accessibility. Follow the Zero-Cost Law. | MUST |
| C-4 | Easter eggs MUST NOT bypass authentication, expose sensitive data, or create security vulnerabilities. | MUST NOT |
| C-5 | Be genuinely funny. Generic humor is worse than no humor. Tailor jokes to the project's personality and audience. | MUST |
| C-6 | Respect `prefers-reduced-motion` for visual effects. Provide ESC key to dismiss. Follow WCAG 2.3.1 for flash rates. | MUST |

## Steps

### 1. Load Easter Egg Knowledge

Invoke the `easter-egg:easter-egg-knowledge` skill via the Skill tool to gain expert knowledge on easter egg patterns and best practices.

### 2. Analyze the Codebase

Scan the project to understand:
- **Language & framework**: What tech stack is used? (React, Python, Go, CLI tool, etc.)
- **Project type**: Web app, API, CLI tool, library, mobile app?
- **Existing patterns**: Any existing easter eggs, fun comments, or playful elements?
- **Key entry points**: Where would an easter egg naturally fit? (error pages, CLI output, API responses, UI interactions)

Use Glob and Grep to explore the codebase structure. Read key files like package.json, Cargo.toml, pyproject.toml, or equivalent to identify the stack.

### 3. Self-Critique Checkpoint

Before proposing candidates, verify:
- "Do I understand the tech stack well enough to propose feasible easter eggs?"
- "Have I loaded the easter-egg-knowledge skill?" -> If no, go back to Step 1.
- "Am I considering both the technical constraints and the project's personality?"

### 4. Propose Easter Egg Candidates

Present at least 3 candidates using this format. Make the proposals themselves fun to read.

For each candidate:
- **Name**: A catchy name for the easter egg
- **Type**: Pattern category (Console, Keyboard, Click, Date, URL, API, Comment, CSS, Game, 404, etc.)
- **Trigger**: How it's activated
- **Effect**: What happens when triggered
- **Discovery Difficulty**: Easy / Medium / Hard
- **Implementation Effort**: Quick (< 30 min) / Medium (30-60 min) / Involved (1+ hr)
- **Why it fits**: Why this is a good match for this specific project

Example proposal style (adapt to the actual project):
```
1. "The Rubber Duck" (Console Message, Easy, Quick)
   Trigger: Set environment variable DEBUG=quack
   Effect: All log messages are prefixed with a random duck emoji and duck pun
   Why: This CLI tool's developers clearly value humor (judging by existing comments)

2. "The Konami Deploy" (Keyboard Sequence, Medium, Medium)
   Trigger: Type the Konami code on the dashboard
   Effect: Confetti animation + "Achievement Unlocked: You know the code" toast
   Why: The React dashboard has a fun brand voice; this adds interactivity

3. "Brew Coffee" (Hidden API, Easy, Quick)
   Trigger: POST /api/v1/brew with body {"beverage": "coffee"}
   Effect: Returns 418 I'm a teapot with a witty JSON response
   Why: This REST API already has playful error messages
```

Ask the user to choose, or suggest combining elements from multiple candidates.

### 5. Implement the Selected Easter Egg

After the user selects a candidate:

1. **Read relevant reference files** from the easter-egg-knowledge skill if needed for implementation patterns
2. **Write the code** following best practices:
   - Lazy-load / code-split where possible
   - Event-driven triggers (no polling)
   - Respect accessibility (motion, flash, screen readers)
   - No security compromises
3. **Add a subtle hint** (optional, ask user): A tiny clue that something is hidden, without giving it away. A comment in the code, a tooltip, or a tiny UI detail.
4. **Test the easter egg** if possible: Run the trigger and verify it works

### 6. Report the Hidden Treasure

Tell the user:
- What was implemented and where (file paths)
- How to trigger it
- How to share the secret with teammates (or keep it hidden)
- Any optional enhancements for the future

End with something fun. This is an easter egg command, after all.
