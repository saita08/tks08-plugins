# Capture Recipes

How to detect each kind of visual surface and how to photograph it. Detect from evidence in the repository, not from the project's name. A recipe is worthless if it captures only one happy state, so each surface carries the states worth taking separately.

The commands below use tools that may not be present. Never install anything from a capture step; when a tool is missing, record the alternative and a one-line install suggestion and leave the choice to the user. Where a command writes to a path, write to a directory you can read back from and name files so the surface and state are unambiguous, e.g. `tengan-shots/web-dashboard-mobile.png`.

## The recipe file shape

`/tengan:open` writes `.claude/tengan.local.md`. Frontmatter carries the machine-readable surface list; the body carries the human-readable recipe. Shape:

```markdown
---
surfaces:
  - name: web-dashboard
    kind: web
    tool: playwright
    ready: true
  - name: ios-app
    kind: ios-simulator
    tool: xcrun-simctl
    ready: false
---

## web-dashboard (web)

Capture command, prerequisites, states, and — if the tool is missing — the
alternative and install suggestion, written out per surface.
```

Keep `ready` honest: `true` only when the tool is present and the surface can be captured now.

## iOS simulator

Detection: an `.xcodeproj` or `.xcworkspace`, a `Package.swift` with an iOS target, or a `*.xcodeproj/project.pbxproj` referencing `IPHONEOS_DEPLOYMENT_TARGET`. A SwiftUI or UIKit source tree is corroborating evidence.

Capture the booted simulator:

```bash
xcrun simctl io booted screenshot tengan-shots/ios-<state>.png
```

The simulator must be booted and the app running at the state you want. To capture several devices, boot each and repeat: `xcrun simctl list devices` shows what is available, `xcrun simctl boot "<udid>"` boots one. States worth separating: the primary screen, an empty-data state, an error or offline state, a long-content state that tests scrolling and truncation, and both a small device (e.g. iPhone SE) and a large one (e.g. Pro Max) because layout that holds on one can collapse on the other.

Missing tool: `xcrun simctl` ships with Xcode. If Xcode is absent there is no alternative on the machine; the install suggestion is to install Xcode from the App Store, which is the user's call.

## Web app (headless)

Detection: a `package.json` with a web framework (`react`, `vue`, `svelte`, `next`, `vite`, `astro`), an `index.html`, or a running dev server. A deployed URL in the README or config counts as a web surface too — see the deployed section below.

Preferred, if Playwright is available:

```bash
npx playwright screenshot --viewport-size=390,844 "http://localhost:3000" tengan-shots/web-mobile.png
npx playwright screenshot --viewport-size=1440,900 "http://localhost:3000" tengan-shots/web-desktop.png
```

Fallback with headless Chrome:

```bash
chrome --headless --screenshot=tengan-shots/web.png --window-size=1440,900 "http://localhost:3000"
```

The binary is `chrome`, `google-chrome`, `chromium`, or on macOS `"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"`. Headless Chrome captures a single viewport per run and does not run scripted interaction, so it reaches fewer states than Playwright.

States worth separating: mobile and desktop viewports at minimum, because responsive layout is exactly where breakage hides; the empty state, the error state, and a loading state if the app has one; a form with long or invalid input; and any authenticated view, which needs a logged-in session — see the note on auth below.

Missing tool: if neither Playwright nor a Chrome binary is present, record that and suggest `npx playwright install chromium` as the opt-in path.

## Remotion video

Detection: `remotion` in `package.json` dependencies, a `remotion.config.ts`, or a `src/Root.tsx` registering compositions.

Capture a still at a specific frame rather than rendering the whole video:

```bash
npx remotion still src/index.ts <CompositionId> tengan-shots/remotion-frame<N>.png --frame=<N>
```

A video is a timeline, so one frame proves almost nothing. Take stills at several points: the opening frame, one or two mid-points where the main content sits, and the final frame. Text that animates in, elements that should have left the screen, a transition that overshoots — these only show at the frames where they happen.

Missing tool: Remotion is an npm dependency; if `npx remotion` fails, the project's dependencies are not installed, and the suggestion is to run the project's install step (`npm install` or equivalent).

## Plain video file

Detection: a produced `.mp4`, `.mov`, `.webm`, or `.gif` that the work generated or changed, referenced by the task.

Extract frames with ffmpeg at several time points:

```bash
ffmpeg -i output.mp4 -vf "select='eq(n,0)'" -frames:v 1 tengan-shots/video-start.png
ffmpeg -i output.mp4 -ss 00:00:03 -frames:v 1 tengan-shots/video-mid.png
ffmpeg -sseof -1 -i output.mp4 -update 1 tengan-shots/video-end.png
```

As with Remotion, sample the start, the middle, and the end at minimum; a single frame cannot show motion or timing problems.

Missing tool: `ffmpeg` is not universally installed. Suggest `brew install ffmpeg` on macOS or the platform's package manager, as the user's choice.

## Chrome extension

Detection: a `manifest.json` with `manifest_version` and extension fields (`action`, `content_scripts`, `background`), typically alongside `popup.html` or content-script sources.

Load the unpacked extension into a Playwright-controlled Chromium and capture its surfaces. The popup, the options page, and any injected content-script UI are separate states. This needs a short Playwright script rather than the one-line `screenshot` subcommand, because the extension must be loaded with `--load-extension` and its popup reached through the extension's own URL. Record in the recipe that this surface needs a script, and write that script at capture time using Playwright's persistent-context launch with `args: ['--load-extension=<path>', '--disable-extensions-except=<path>']`.

Missing tool: same as web — suggest `npx playwright install chromium`.

## Deployed web app, including Apps Script

Detection: a public URL in the README, in a deploy config, or given by the user. Google Apps Script web apps (a `/exec` URL) are captured the same way as any deployed page.

Capture the public URL headless, exactly like a local web app but pointing at the deployed URL:

```bash
npx playwright screenshot --viewport-size=1440,900 "https://example.com/app" tengan-shots/deployed-desktop.png
```

Sending a request to a deployed URL reaches an external service. That is fine for a page the user pointed you at; do not crawl beyond the given URL. Authenticated deployed views have the same session requirement as any auth-gated surface.

Missing tool: same Playwright / headless-Chrome fallback as the web surface.

## Static images, PDF, SVG

Detection: the work produced or changed an `.png`, `.jpg`, `.pdf`, or `.svg`, or the user points at one.

No capture step is needed — read the file directly with the Read tool. Read handles images natively and reads PDFs by page range. For an SVG, if Read does not render it, rasterize it first with a headless browser or a tool like `rsvg-convert` and read the resulting PNG. This is the smallest surface and needs no recipe ceremony; the doctrine is the same, just look at it.

## A note on authenticated surfaces

Any screen behind a login cannot be captured cold — the capture reaches the login wall, not the screen. Reaching it needs a pre-established session: a saved storage state, a test account whose credentials the user supplies, or a dev bypass the project already has. Record in the recipe that the surface needs auth and how the session is obtained for this project; if that is not known, capture what is reachable and report that the authenticated states could not be reached without setup. Do not embed credentials in `.claude/tengan.local.md` — reference where they come from, never their values.
