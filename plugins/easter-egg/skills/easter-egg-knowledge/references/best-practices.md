# Best Practices & Anti-Patterns

Guidelines for implementing easter eggs that delight without causing harm.

## The Zero-Cost Principle

Easter eggs MUST be zero-cost abstractions: they have no performance, security, or UX impact when not triggered.

### Performance

```javascript
// GOOD: Lazy evaluation - cost only on activation
class EasterEggManager {
  constructor() {
    this._listeners = new Map();
  }

  register(trigger, effectLoader) {
    // Store only function reference, do not execute
    this._listeners.set(trigger, effectLoader);
  }

  async fire(trigger) {
    const loader = this._listeners.get(trigger);
    if (!loader) return;
    const effect = await loader();
    effect.run();
  }
}

// BAD: Loading all resources at startup
// import heavyGame from './hidden-game';  // bundled for all users
// import audioFiles from './sounds';       // slows initial load
```

**Checklist:**
- [ ] Code-split / lazy-load easter egg code
- [ ] Use event-driven triggers, NOT setInterval polling
- [ ] Load heavy assets (images, audio) only on activation
- [ ] Consider dead-code elimination in production builds (if intentionally removing)

### Security

```python
# NEVER DO THIS - This is a backdoor, not an easter egg

# NG: Auth bypass
@app.route('/api/secret-admin')
def secret_admin():
    return admin_panel()  # NO authentication check

# NG: Expose debug info
@app.route('/api/debug-all')
def debug_info():
    return jsonify(dict(os.environ))  # Leaks secrets

# NG: Secrets in comments
# AWS_KEY = "AKIA..."  # for testing, don't use in prod  <-- LEAK RISK
```

**Security Rules:**
1. Easter eggs MUST NOT bypass authentication or authorization
2. NEVER expose internal system info (env vars, stack traces, DB schemas)
3. Sanitize user input even for easter egg triggers
4. Hidden endpoints are still subject to security review
5. Source code easter eggs must not hint at sensitive information

### Accessibility

```javascript
// GOOD: Accessibility-aware easter egg
function activateVisualEasterEgg() {
  // 1. Respect motion preferences
  const prefersReducedMotion = window.matchMedia(
    '(prefers-reduced-motion: reduce)'
  ).matches;

  if (prefersReducedMotion) {
    showStaticMessage("You found an easter egg!");
    return;
  }

  // 2. Start animation
  startAnimation();

  // 3. Screen reader announcement
  const announcement = document.createElement('div');
  announcement.setAttribute('role', 'alert');
  announcement.setAttribute('aria-live', 'polite');
  announcement.textContent = 'Easter egg activated! An animation is playing.';
  announcement.classList.add('sr-only');
  document.body.appendChild(announcement);

  // 4. Provide escape mechanism
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') stopAnimation();
  });
}
```

**Accessibility Rules:**
1. Always check `prefers-reduced-motion`
2. Flash rate must be below 3 per second (WCAG 2.3.1)
3. Provide alternative representations (text for audio, text for visual)
4. ESC key must always dismiss/cancel
5. Avoid auto-playing audio (or start muted)

## When Easter Eggs Are Appropriate

### Appropriate Contexts
- Developer tools (CLI, DevTools, SDK)
- Consumer products (games, social media, media apps)
- 404 pages and error screens (mitigate negative experiences)
- Internal tools (team culture building)
- Version info and credits screens
- Documentation (fun code examples)

### Inappropriate Contexts
- Medical, financial, legal mission-critical screens
- Core error handling (users are already frustrated)
- Inside accessibility support features
- Security-related functionality
- Time-critical flows (payment, emergency)
- Culturally or religiously sensitive contexts

## Discoverability Balance

### The Goldilocks Principle

Easter eggs should be neither too easy nor too hard to find.

```
Discovery Difficulty Spectrum:

[Easy] -------------------------------------------- [Hard]
  |                    |                              |
  Seasonal themes    Konami code            Source code only
  404 pages          Click patterns          Binary analysis
  console.log        URL parameters          Encrypted hints
                     Time triggers
```

### Techniques to Guide Discovery
- Subtle visual hints (slightly different UI elements)
- Design for community sharing (social media-worthy reactions)
- Staged hints ("something's off" -> "explore here" -> "found it!")
- Readable source code comments with light hints

## Emotional Design Framework

```
Trigger -> Discovery -> Surprise -> Delight -> Sharing -> Belonging
  |           |            |          |          |           |
  Hide      Search     Unexpected   Reward    Word-of-    Fan
                                              mouth       identity
```

### Key Psychology

1. **Eureka Effect**: Brain releases dopamine on unexpected discovery
2. **Brand Personality**: "Fun humans built this" signal
3. **Social Currency**: "I know a secret" = status boost
4. **Exploration Reward**: Same loop as game design
5. **Developer Culture Symbol**: Signals technical maturity and healthy team culture
