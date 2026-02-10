---
name: review-policy
description: Coding standards and quality criteria applied during code review. Use this skill when asked about code review, review policy, coding standards, or quality criteria.
---

# Code Review Quality Criteria

Evaluate code against the following criteria. Listed in priority order.

## 1. Focus on Essential Logic

- Is essential complexity (business logic) properly separated from accidental complexity (null checks, type conversions, error handling boilerplate)?
- Is the intent expressed directly without being buried under boilerplate?

## 2. Proper Placement of Responsibilities

- Are null checks and precondition validations performed only once at the data entry point?
- Do internal functions assume valid data and focus only on essential logic?
- Are the same checks repeated in multiple places?

## 3. Making Invalid States Unrepresentable via Types

- Are types designed to make invalid states unrepresentable, instead of relying on nullable types?
- Are discriminated unions or similar patterns used to make checks unnecessary?

## 4. Clear Conditional Branching

- Are early returns (guard clauses) used for error cases to keep nesting shallow?
- Are all logically possible cases handled explicitly (no implicit behavior)?
- Are complex conditions extracted into explanatory or summary variables?

## 5. Variable Scope and Immutability

- Are variables declared just before use with minimal scope?
- Is reassignment avoided in favor of const?
- Are conditional value assignments consolidated into single assignments (ternary, etc.)?

## 6. Appropriate Defensive Programming

- Are there unreachable checks or excessive defensive code?
- Is proper defense in place for external input, post-async state, and uncertain initialization order?
- Are necessary and unnecessary defenses clearly distinguished?

## 7. Constants and Magic Numbers

- Are meaningful numeric literals given named constants?
- Are related constants grouped into objects?

## 8. Function Design

- Are complex conditions and generic logic extracted into utils?
- Does each function focus on a single task?
- Are parameter counts kept to 5 or fewer (more suggests excessive responsibility)?
- Are unrelated sub-problems (string manipulation, date calculation, etc.) separated from business logic?

## 9. Naming

- Do function names use specific verbs (avoiding generic get/set/remove)?
- Does the name alone convey intent (without needing JSDoc or comments)?
- Do numeric variables include units (timeoutMs, sizeBytes, etc.)?
- Do boolean-returning functions use is/has/can/should prefixes?
- Do functions that return null on failure use a try prefix?
- Are min/max, first/last, begin/end used appropriately for ranges and limits?

## 10. Comments and Documentation

- Do comments explain "why" rather than "what"?
- Do public APIs have JSDoc?
- Are JSDoc, parameter names, and return types updated when implementations change?

## 11. Error Handling

- Are console.warn and console.error used appropriately?
- Are there unnecessary warnings on unreachable code?
- Are appropriate notification mechanisms used where user notification is needed?
