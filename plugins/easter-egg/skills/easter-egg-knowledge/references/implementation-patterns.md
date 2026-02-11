# Implementation Patterns Catalog

Comprehensive implementation patterns for software easter eggs, organized by trigger mechanism.

## 1. Console / Log Message Patterns

The simplest and most developer-friendly pattern. Effective for developer-facing products.

### ASCII Art Messages

```javascript
// Browser console with styling
console.log(`
%c
  _____         _              _____
 | ____|__ _ __| |_ ___ _ __  | ____|__ _  __ _
 |  _| / _' / __| __/ _ \\ '__| |  _| / _' |/ _' |
 | |__| (_| \\__ \\ ||  __/ |    | |__| (_| | (_| |
 |_____\\__,_|___/\\__\\___|_|    |_____\\__, |\\__, |
                                     |___/ |___/
`, 'color: #6B46C1; font-size: 14px; font-weight: bold;');
```

```python
# Python CLI with conditional trigger
import logging
import datetime

logger = logging.getLogger(__name__)

def process_request(data):
    if datetime.datetime.now().strftime("%H:%M") == "13:37":
        logger.debug("You found the l33t hour. Nice.")
```

```javascript
// Recruitment message (Facebook pattern)
console.log(
  '%cWe are hiring! %chttps://example.com/careers',
  'font-size: 24px; color: #FF6B6B; font-weight: bold;',
  'font-size: 16px; color: #4ECDC4;'
);
```

### Famous Examples
- **Facebook**: Large "Stop!" warning + recruitment info in DevTools console
- **Reddit**: ASCII art logo in page source
- **Netlify**: Recruitment ASCII art in console

## 2. Keyboard Sequence Trigger Patterns

Detecting specific key sequences. The Konami code is the canonical example.

### Robust Key Sequence Detector

```javascript
class KeySequenceDetector {
  constructor(sequence, callback, options = {}) {
    this.sequence = sequence;
    this.callback = callback;
    this.timeout = options.timeout || 2000;
    this.currentIndex = 0;
    this.lastKeyTime = 0;
    this._handler = this._handleKeyDown.bind(this);
  }

  activate() {
    document.addEventListener('keydown', this._handler);
  }

  deactivate() {
    document.removeEventListener('keydown', this._handler);
  }

  _handleKeyDown(event) {
    const now = Date.now();
    if (now - this.lastKeyTime > this.timeout) {
      this.currentIndex = 0;
    }
    this.lastKeyTime = now;

    if (event.key === this.sequence[this.currentIndex]) {
      this.currentIndex++;
      if (this.currentIndex === this.sequence.length) {
        this.currentIndex = 0;
        this.callback();
      }
    } else {
      this.currentIndex = event.key === this.sequence[0] ? 1 : 0;
    }
  }
}

// Konami code
const konamiCode = [
  'ArrowUp', 'ArrowUp', 'ArrowDown', 'ArrowDown',
  'ArrowLeft', 'ArrowRight', 'ArrowLeft', 'ArrowRight',
  'b', 'a'
];

const detector = new KeySequenceDetector(konamiCode, () => {
  // Easter egg activation
});
detector.activate();
```

### Famous Examples
- **Konami Code**: Originated from Gradius (1986), spread to ESPN, BuzzFeed, many websites
- **Disney+**: Type specific character names for hidden effects

## 3. Click Pattern Triggers

Detecting specific click sequences or patterns on UI elements.

```javascript
function createClickEasterEgg(element, requiredClicks, timeWindow, callback) {
  let clicks = 0;
  let timer = null;

  element.addEventListener('click', () => {
    clicks++;
    if (timer) clearTimeout(timer);

    if (clicks >= requiredClicks) {
      clicks = 0;
      callback();
      return;
    }

    timer = setTimeout(() => { clicks = 0; }, timeWindow);
  });
}

// Logo 5x click in 3 seconds
const logo = document.querySelector('.app-logo');
createClickEasterEgg(logo, 5, 3000, () => {
  showHiddenCreditsPage();
});
```

### Famous Examples
- **Android**: Tap version number 7 times in Settings for Developer Options
- **Android**: Tap Android version repeatedly for version-specific mini-game
- **macOS**: Option-click Apple menu for "System Information"

## 4. Date/Time Trigger Patterns

Events triggered by specific dates, times, or temporal conditions.

```javascript
const DATE_EGGS = {
  '01-01': { message: 'Happy New Year!', effect: 'fireworks' },
  '04-01': { message: 'Trust nothing today.', effect: 'invert' },
  '05-04': { message: 'May the Force be with you.', effect: 'starwars' },
  '10-31': { message: 'Spooky!', effect: 'halloween' },
  '03-14': { message: 'Happy Pi Day! 3.14159265...', effect: 'math' },
  '02-14': { message: 'Your code loves you back.', effect: 'hearts' },
  '12-25': { message: 'Happy holidays!', effect: 'snow' },
};

function checkDateEasterEgg() {
  const now = new Date();
  const key = String(now.getMonth() + 1).padStart(2, '0')
    + '-' + String(now.getDate()).padStart(2, '0');
  return DATE_EGGS[key] || null;
}

// Time-based
function checkTimeEasterEgg() {
  const now = new Date();
  const hours = now.getHours();
  const minutes = now.getMinutes();

  if (hours === 13 && minutes === 37) {
    return { message: '1337 MODE ACTIVATED', effect: 'hacker' };
  }
  if (hours === 3 && minutes === 33) {
    return { message: 'The witching hour approaches...', effect: 'dim' };
  }
  return null;
}
```

```python
from datetime import date

SPECIAL_DATES = {
    (12, 25): "Merry Christmas! Here's a gift: all tests pass today.",
    (2, 14): "Happy Valentine's Day! Your code loves you back.",
    (3, 14): f"Happy Pi Day! {3.141592653589793:.15f}",
    (10, 31): "BOO! Watch out for zombie processes.",
    (1, 1): "New year, new bugs. Just kidding. Maybe.",
}

def get_daily_greeting():
    today = date.today()
    return SPECIAL_DATES.get((today.month, today.day))
```

## 5. URL / Query Parameter Patterns

Web applications can use URL paths, query parameters, or hash fragments.

```javascript
function checkURLEasterEggs() {
  const params = new URLSearchParams(window.location.search);

  if (params.get('debug') === 'rainbow') {
    document.body.style.animation = 'rainbow 3s infinite';
    return;
  }
  if (params.get('theme') === 'retro') {
    document.body.classList.add('retro-mode');
    return;
  }
  if (window.location.hash === '#the-cake-is-a-lie') {
    showPortalCake();
    return;
  }
}
```

### Famous Examples
- **Google**: Search "do a barrel roll", "askew", "recursion"
- **YouTube**: Search "do the harlem shake" (page elements dance)

## 6. Hidden API Endpoints

Server-side easter eggs via undocumented endpoints.

```python
from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/api/v1/teapot', methods=['BREW', 'GET'])
def teapot():
    """RFC 2324 compliant teapot endpoint"""
    return jsonify({
        "error": "I'm a teapot",
        "message": "This server is a teapot and cannot brew coffee.",
        "see_also": "https://tools.ietf.org/html/rfc2324"
    }), 418

@app.route('/api/v1/meaning-of-life')
def meaning_of_life():
    return jsonify({"answer": 42, "source": "Deep Thought"})
```

### Famous Examples
- **HTTP 418 I'm a teapot**: RFC 2324 (1998 April Fools)
- **Google**: google.com/teapot returns a teapot animation
- **GitHub API**: Various hidden endpoints and response headers

## 7. Source Code Comment Patterns

Hidden humor in source code, visible only to those who read the code.

```python
# Pattern A: Brutally honest comments
# TODO: This is a terrible hack. I'm sorry.
# FIXME: This works, but I have no idea why.
# HACK: Dear future me, I'm sorry. Dear past me, you were an idiot.

# Pattern B: Literary references
def _parse_legacy_format(data):
    """Here be dragons. This parser handles 15 years of format changes."""
    pass

# Pattern C: Fun constants
THE_ANSWER = 42
SPEED_OF_LIGHT = 299792458  # m/s, also a pretty good password length
TAU = 6.283185307  # because pi is wrong (https://tauday.com)

# Pattern D: HTTP status humor
HTTP_IM_A_TEAPOT = 418
HTTP_ENHANCE_YOUR_CALM = 420  # Twitter's old rate limit code
```

### Famous Examples
- **Linux kernel**: Numerous witty comments throughout
- **Python**: `import this` (The Zen of Python), `import antigravity`
- **Vim**: `:help 42` (Hitchhiker's Guide reference)

## 8. CSS Animation Patterns

Pure CSS visual effects, no JavaScript required.

```css
/* Barrel roll (Google style) */
@keyframes barrel-roll {
  from { transform: rotate(0deg); }
  to   { transform: rotate(360deg); }
}
.do-a-barrel-roll {
  animation: barrel-roll 4s ease-in-out 1;
}

/* Page flip */
.flip-mode {
  transform: scaleY(-1);
  transition: transform 2s ease;
}

/* Rainbow text */
@keyframes rainbow {
  0%   { color: #ff0000; }
  17%  { color: #ff8000; }
  33%  { color: #ffff00; }
  50%  { color: #00ff00; }
  67%  { color: #0000ff; }
  83%  { color: #8000ff; }
  100% { color: #ff0000; }
}
.rainbow-text {
  animation: rainbow 3s linear infinite;
}

/* Matrix effect */
@keyframes matrix-fall {
  0%   { transform: translateY(-100vh); opacity: 0; }
  10%  { opacity: 1; }
  100% { transform: translateY(100vh); opacity: 0; }
}
.matrix-mode::before {
  content: "01001000 01101001";
  position: fixed;
  top: 0; left: 0;
  color: #00ff00;
  font-family: monospace;
  animation: matrix-fall 5s linear infinite;
  pointer-events: none;
}
```

## 9. Mini-Game Embedding

Full games hidden within applications.

```javascript
// Simple number guessing game for console
class NumberGuessingEasterEgg {
  constructor() {
    this.secret = Math.floor(Math.random() * 100) + 1;
    this.attempts = 0;
    this.maxAttempts = 7;
  }

  guess(n) {
    this.attempts++;
    if (n === this.secret) {
      return `Correct! You found it in ${this.attempts} attempts.`;
    }
    if (this.attempts >= this.maxAttempts) {
      return `Game over. The number was ${this.secret}.`;
    }
    return n < this.secret ? 'Higher!' : 'Lower!';
  }
}

if (typeof window !== 'undefined') {
  window.__startGame = () => {
    const game = new NumberGuessingEasterEgg();
    window.__guess = (n) => console.log(game.guess(n));
    console.log('Guess a number between 1 and 100. Use __guess(n) to play.');
  };
}
```

### Famous Examples
- **Chrome T-Rex**: Offline dinosaur runner game
- **Excel 97**: Hidden flight simulator
- **Android Lollipop**: Flappy Bird clone

## 10. CLI-Specific Patterns

Patterns particularly effective for command-line tools and developer tooling.

### Special Flag Responses

```python
def handle_special_flags(args):
    if getattr(args, 'with_cowsay', False):
        print(r"""
         __________________
        < Your code is moo-velous! >
         ------------------
                \   ^__^
                 \  (oo)\_______
                    (__)\       )\/\
                        ||----w |
                        ||     ||
        """)
```

### Magic Input Values

```python
def process_input(value):
    special_responses = {
        "42": "The answer to life, the universe, and everything.",
        "hello world": "Hello, developer! You're doing great.",
        "sudo make me a sandwich": "Okay.",
    }
    if value.lower() in special_responses:
        return special_responses[value.lower()]
    return None
```

### Fun Loading Messages

```python
LOADING_MESSAGES = [
    "Reticulating splines...",           # SimCity
    "Generating witty dialog...",         # Dragon Age
    "Swapping time and space...",
    "Spinning violently around the y-axis...",
    "Tokenizing real life...",
    "Bending the spoon...",
    "Convincing AI to not take over...",
    "Preparing sarcastic comment...",
    "Compiling cat photos...",
    "Dividing by zero... wait, don't--",
    "Proving P=NP... just kidding.",
    "Asking the rubber duck...",
    "Blaming it on DNS...",
]
```

## 11. DevTools Trigger Patterns

Effects that activate when browser developer tools are opened.

```javascript
const devToolsDetector = {
  _isOpen: false,

  check() {
    const threshold = 160;
    const widthDiff = window.outerWidth - window.innerWidth > threshold;
    const heightDiff = window.outerHeight - window.innerHeight > threshold;

    if (widthDiff || heightDiff) {
      if (!this._isOpen) {
        this._isOpen = true;
        this._onOpen();
      }
    } else {
      this._isOpen = false;
    }
  },

  _onOpen() {
    console.log('%cWelcome, fellow developer!', 'font-size: 20px; color: #e74c3c;');
    console.log('%cCurious about how things work? We like that.', 'font-size: 14px;');
  }
};

// NOTE: Polling is unavoidable for DevTools detection as there is no
// native event for it. Use a long interval (1s+) to minimize cost.
// This is an exception to the "no polling" best practice.
setInterval(() => devToolsDetector.check(), 1000);
```

## 12. Creative 404 Pages

Error pages as entertainment.

### Famous Examples
- **GitHub 404**: Star Wars parody Octocat with parallax effect
- **Blizzard 404**: Game character humorous messages
- **Slack 404**: Hamster illustrations with witty messages
- **Bloomberg 404**: Animated stock chart that spells "404"

## 13. Audio/Sound Patterns

Sound-based effects using Web Audio API (no external files needed).

```javascript
function playEasterEggSound(type = 'success') {
  const ctx = new (window.AudioContext || window.webkitAudioContext)();
  const oscillator = ctx.createOscillator();
  const gainNode = ctx.createGain();

  oscillator.connect(gainNode);
  gainNode.connect(ctx.destination);

  const sounds = {
    success: { freq: 523.25, duration: 0.3, type: 'sine' },
    coin:    { freq: 987.77, duration: 0.1, type: 'square' },
    powerup: { freq: 440,    duration: 0.5, type: 'sawtooth' },
  };

  const config = sounds[type] || sounds.success;
  oscillator.frequency.setValueAtTime(config.freq, ctx.currentTime);
  oscillator.type = config.type;
  gainNode.gain.setValueAtTime(0.1, ctx.currentTime);
  gainNode.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + config.duration);

  oscillator.start(ctx.currentTime);
  oscillator.stop(ctx.currentTime + config.duration);
}
```
