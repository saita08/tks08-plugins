---
description: Guides users through deploying Google Apps Script projects using clasp. Triggered when users ask about GAS deployment, clasp usage, or updating GAS versions.
allowed-tools:
  - Bash
---

This skill provides guidance for deploying Google Apps Script projects using clasp, ensuring existing deployments are updated rather than creating new ones.

## The Trap

Running `clasp deploy` without the `-i` flag creates a NEW deployment instead of updating an existing one. This changes the URL and breaks all existing integrations.

## Correct Workflow

1. Push code: `clasp push`
2. List existing deployments: `clasp deployments`
3. Create a new version: `clasp version "description"`
4. Update existing deployment: `clasp deploy -i <deployment-id> -V <version> -d "description"`

The `-i` flag is critical - it specifies which deployment to update.

## When User Asks to Deploy

1. Check if `.clasp.json` exists in the current directory
2. Run `clasp push` to upload the code
3. Run `clasp deployments` to list existing deployments
   - If only one deployment exists (excluding @HEAD), use it automatically
   - If multiple exist, ask user which one to update
4. Run `clasp version` to create a new version, parse the version number from output
5. Run `clasp deploy -i <deployment-id> -V <version-number>` to update

## Wrong Approach (Never Do This)

```bash
clasp deploy  # This creates a NEW deployment!
```

## Prerequisites

- clasp installed (`bun add -g @google/clasp` or `npm install -g @google/clasp`)
- `clasp login` completed
- `.clasp.json` exists in the project
