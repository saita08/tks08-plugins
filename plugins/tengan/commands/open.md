---
description: Open the eye on a project — survey it for visual surfaces (simulator, web, video, extension, images), then write a per-surface capture recipe to .claude/tengan.local.md without installing anything.
argument-hint: "[調査対象のパス（省略時はカレントプロジェクト）]"
allowed-tools: Read, Glob, Grep, Bash, Write, Edit
---

# Tengan Open

Survey a project for every surface that a human would otherwise have to look at with their own eyes, and write down how to photograph each one. This command does not judge anything yet; it builds the recipe that `/tengan:look` will follow. The eye is opened here so that later it only has to look.

Read `${CLAUDE_PLUGIN_ROOT}/skills/close-the-visual-loop/references/capture-recipes.md` before surveying. It carries the detection signals — what in a project marks it as an iOS app, a Remotion video, a Chrome extension, a plain video file, and so on — and the exact capture command for each surface, including how to reach its several states. Detect from evidence in the repository, not from what the project is called.

## Step 1 — Detect the surfaces

Walk the repository and decide which visual surfaces it actually has. A single project often has more than one: a web app with a marketing page and an authenticated dashboard is two states of one surface; a repo that ships both an iOS app and a Remotion trailer is two surfaces. Use the detection signals in the reference. Do not assume a surface exists because the reference lists it — record only what this repository shows evidence of.

For each surface, also decide the states worth capturing separately. The reference explains why states matter; a screen photographed only in its happy, populated, medium-width state hides exactly the breakages that visual verification exists to catch.

## Step 2 — Check the tools each surface needs

Every capture command depends on a tool: `xcrun simctl` for the iOS simulator, a headless browser for web, `ffmpeg` for video frames, `npx remotion` for Remotion stills. For each surface you detected, check whether its tool is present. Never install anything. When a tool is missing, write down the alternative capture path if one exists, and a one-line install suggestion the user can choose to run — but leave the choice to the user.

## Step 3 — Write the recipe

Write `.claude/tengan.local.md` in the project. Its purpose is that a later session, with no memory of this survey, can capture every surface by reading this file alone. Use YAML frontmatter for the machine-readable surface list and Markdown below it for the per-surface recipe. Follow the shape in `${CLAUDE_PLUGIN_ROOT}/skills/close-the-visual-loop/references/capture-recipes.md`. For each surface record: its name, the exact capture command, its prerequisites, the states to capture and how each is reached, and — when its tool is missing — the alternative and the install suggestion.

If `.claude/tengan.local.md` already exists, read it first and update it rather than overwriting; a surface the user has already annotated by hand must survive the rewrite.

## Step 4 — Report

Tell the user which surfaces were found, which are ready to capture now, and which need a tool they must choose to install. Do not commit; the user reviews the working tree. Point them at `/tengan:look` as the next step.
