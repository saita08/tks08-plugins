---
name: Easter Egg Knowledge
description: >-
  This skill should be used when the user asks to "add an easter egg",
  "hide something fun in the code", "plant an easter egg", "add a hidden feature",
  "add a secret", "implement a konami code", "make a fun 404 page",
  "add humor to the codebase", or discusses embedding hidden surprises,
  jokes, or delightful secrets in software products. Provides expert-level
  guidance on easter egg implementation patterns, psychology, and best practices.
---

# Easter Egg Knowledge

Expert-level guidance for designing and implementing software easter eggs. An easter egg is a hidden feature, message, or interaction planted in software to delight those who discover it.

## Core Philosophy: The Three Laws

1. **Zero-Cost Law**: An easter egg MUST NOT affect performance, security, or UX when not triggered. It is invisible until found.
2. **Delight Law**: The purpose of an easter egg is joy. If it annoys, confuses, or harms, it has failed.
3. **Discovery Law**: The best easter eggs reward curiosity. They are found, not shown.

## Pattern Taxonomy

Easter eggs are classified by their trigger mechanism. Choose based on the project's technology and audience.

### Developer-Facing Patterns
| Pattern | Trigger | Best For | Difficulty |
|---------|---------|----------|------------|
| Console Messages | Open DevTools / run CLI | Dev tools, APIs | Easy |
| Source Code Comments | Read source | Open source, libraries | Easy |
| Hidden API Endpoints | Call undocumented route | REST APIs, servers | Easy |
| Fun Loading Messages | Wait for process | CLI tools, build scripts | Easy |

### User-Facing Patterns
| Pattern | Trigger | Best For | Difficulty |
|---------|---------|----------|------------|
| Keyboard Sequences | Type specific keys (e.g. Konami) | Web apps, games | Medium |
| Click Patterns | Tap element N times | Mobile, web apps | Medium |
| Date/Time Triggers | Specific date or time | Any product | Easy |
| URL Parameters | Add query param / hash | Web applications | Easy |
| CSS Animations | Triggered by class toggle | Web frontends | Medium |
| Mini-Games | Complex activation | Flagship products | Hard |
| Creative 404 Pages | Visit non-existent URL | Any web product | Medium |
| Audio/Sound Effects | Various triggers | Games, media apps | Medium |

## Implementation Decision Guide

When deciding what easter egg to plant, consider:

1. **Who will find it?** Developers (console/comments/API) vs. end users (UI/keyboard/click)
2. **What is the tech stack?** Web (CSS/JS), CLI (ASCII art/messages), API (endpoints/status codes), Mobile (gestures)
3. **How disruptive can it be?** Subtle (comments, console) vs. visible (animations, games)
4. **How much effort to invest?** Quick win (loading messages, comments) vs. polished feature (mini-game, interactive 404)

## Implementation Workflow

To implement an easter egg:

1. **Analyze the codebase**: Identify the tech stack, framework, and architecture. Determine what patterns are feasible.
2. **Propose candidates**: Suggest 2-4 easter egg options suitable for the project. For each, explain the trigger, effect, discovery difficulty, and implementation effort.
3. **Implement with care**:
   - Follow the Zero-Cost Law (lazy-load, event-driven, no polling)
   - Follow security rules (no auth bypass, no info exposure, sanitize inputs)
   - Follow accessibility rules (respect `prefers-reduced-motion`, provide ESC dismiss, WCAG 2.3.1 flash limits)
4. **Add humor authentically**: The tone should match the product's personality. A developer CLI can be irreverent; a healthcare app should be warm and gentle.

## Humor Guidelines

Easter eggs live and die by their humor. Keep these principles:

- **Specificity is funnier than generality**: "Reticulating splines..." (SimCity) beats "Loading..."
- **Shared references create belonging**: HTTP 418, "42", Konami code tap into developer culture
- **Surprise amplifies delight**: An easter egg in an unexpected place (spreadsheet -> flight sim) is more memorable
- **Self-deprecating humor is safe**: Poking fun at your own code/product is universally charming
- **Timing matters**: A joke during frustration (404 page, loading screen) has more impact than one during success
- **Know the audience**: Developer jokes (segfault puns) for dev tools, universal humor (cute animals) for consumer apps

## Quick Reference: Classic Easter Egg Elements

### Famous Triggers
- Konami code: Up Up Down Down Left Right Left Right B A
- Logo rapid-tap (7x for Android Developer Options)
- `import antigravity` (Python)
- HTTP 418 I'm a teapot (RFC 2324)
- "42" - The Answer to Life, the Universe, and Everything

### Timeless Loading Messages
"Reticulating splines...", "Dividing by zero... wait, don't--", "Proving P=NP... just kidding.",
"Asking the rubber duck...", "Blaming it on DNS...", "Convincing AI to not take over..."

### Contexts That Cry Out for Easter Eggs
- 404 / error pages (turn frustration into delight)
- Version / about screens (reward the curious)
- CLI `--help` or `--version` output (developer camaraderie)
- Empty states / zero-data screens (make the blank page interesting)
- Loading / progress indicators (make the wait bearable)

## Additional Resources

### Reference Files

For detailed implementation code and patterns, consult:
- **`references/implementation-patterns.md`** - Complete code examples for all 13 pattern types (keyboard sequences, click patterns, CSS animations, mini-games, CLI patterns, etc.)
- **`references/best-practices.md`** - Security rules, accessibility guidelines, performance checklist, emotional design framework
- **`references/hall-of-fame.md`** - Curated collection of iconic easter eggs through software history with design lessons
