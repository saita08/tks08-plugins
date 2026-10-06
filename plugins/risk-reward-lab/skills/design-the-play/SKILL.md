---
name: design-the-play
description: This skill should be used when designing or changing the core of a game's play — the player's choices (which move, what to buy, what to read), the opponents' behaviour, time pressure, and the reward of the moment something is won — and when a game is called "単調", "〜だけやればいい", "関係が薄い", "魅力が少ない", "monotonous", "one move wins", "dominant strategy", "nothing to read", or "the parts feel unrelated". Builds play that no single move can win, and verifies it by simulation and a playable sample before it goes in.
user-invocable: false
allowed-tools: Read
---

# Design the Play

This skill holds how to build a game's play, and how to rebuild it when a player says "I only need to do this" or "the parts feel unrelated". How numbers are chosen and measured lives in the sibling skill `balance-by-simulation`.

The value at the core: play is a choice the player makes between risk and return, so a move that carries no risk, a risk that pays no return, or a single move that beats thinking is a defect, however polished the rest is.

## 1. The core of fun is risk and return

Before building play, and before fixing it, write down where the risks and the returns are. Stand on Masahiro Sakurai's definition: game play is the give-and-take of taking a risk to earn a return (keynote at CEDEC 2012, "Why do you make games?", [Famitsu](https://www.famitsu.com/news/201208/20019854.html); a reconstruction of his talk on the essence of games, [Denfaminicogamer](https://news.denfaminicogamer.jp/kikakuthetower/171130b)). A risk is what the player dislikes, loses, or what leads to failure. A return is the gain that removes a risk or moves the player forward.

- Put the large return right next to the large risk. The closer to danger, the more there is to take. Sakurai's example is the "Nagoya shot" in *Space Invaders*: firing from the most dangerous spot, with the invaders right above the cannon, where the largest risk and the largest return coincide.
- The player chooses whether to take the risk. A safe move returns a little, a dangerous one returns a lot. Every move keeps a reason to be taken.
- Let skill show in shrinking the risk while still collecting the return. The clues in section 4 are the material for that.
- When the game is called monotonous, look first for a move with no risk, or a risk with no return.

## 2. Find the best single move

Before fixing anything, simulate every strategy that repeats one move and nothing else. If the best of them matches or beats a thinking strategy, that is the cause of the monotony.

## 3. Tabulate each move's risk and return

Make a table with moves as rows and the opponent's states as columns, and write in each cell what happens. Read the table as relations between moves: fixing one row can erase the role of the row next to it.

- When moves cannot be told apart by what they cost, tell them apart by how the opponent takes them. The same move makes a comfortable opponent dig in out of pride and a cornered one fold.
- Do not fix an opponent's strength or limit at the start. Move it by what happens in play, and show why it moved through the opponent's reaction. Move it by rules; do not use mechanisms whose reasons the designer cannot explain, such as machine learning.

## 4. Show the clues to be read in a form the eye can read

- Show an opponent's slack not as a number but as a clue in steps readable at a glance, such as a change in the opponent's face or posture. A number removes the moment of doubt and turns reading into arithmetic.
- A clue handed over in an earlier scene does not stay on the decision screen. Something close to the answer in front of the player kills the pleasure of reading and remembering. Put only an entrance on the decision screen that the player can open to look back, and do not stop the clock while it is open, so spending time to look back is itself a trade-off.
- A clue about an opponent appears after the opponent acts. One that appears before anyone moves reads as a signal without a reason.
- A clue is never the answer. Give direction and rough strength, never the ratio or the hit itself. A clue that does not apply carries no mark and stays as atmosphere.
- Make clues present every round. When many rounds have nothing that applies, the parts feel unrelated. Hold a number of them as variations of one family at different strengths.
- Study the standard forms of clue-reading games first and decide where to depart: hand over clear rules and put the difficulty in applying them (*Papers, Please*), or show the opponent's next move at the point of decision (*Slay the Spire*, *Into the Breach*).

## 5. Time pressure is not a test of reflexes

- Do not let the fastest press win. Just before a timed decision closes, put a short held moment in which opponents cannot act, during which pressing early or late gives the same result.
- Give waiting its own gain and loss, for example: waiting into the held moment makes the opponents harder to beat. Without it, "always wait to the end" wins alone.
- Do not erase clues with time. Erasing them makes a game the slow decider loses badly.
- Put two decision speeds into the simulation and confirm that speed makes no difference to the score.

## 6. A chosen upgrade has a price

An upgrade picked from a few cards at each break is not free; free means the strongest one is always picked. Price it near the score gain of a strategy that buys every time, measured by simulation, so buying without thought does not pay and choosing when to buy does. Remove any that make things too easy when stacked with other mechanisms. What is paid for always works, and cannot be chosen where it would not.

## 7. The moment of winning something is not overlaid with numbers

Something won for the first time comes before the gain-and-loss numbers, alone and large in the middle of the screen: a cover lifts, a single flash, a short sound and vibration, words like "Added to the collection" and its name. It stops there and waits for a press. On the press it shrinks back to its place and the number scene follows. From the second time on, use a short form. With reduced motion, switch only the shape.

## 8. How many things to collect

- Set the count seen in one run against the total and count how many runs a full round takes before building. If half are already seen by the second run, there are too few.
- Within one run, never show the same thing twice.
- Give each collectable a name and a small incident told in two or three sentences. The name is part of the product, so do not shorten it for the screen's convenience.

## 9. How to write humour

- Deadpan: state it flatly and seriously, slightly off. A small incident for each one, and one punchline at the end.
- Write jokes per family, each to suit its family. Keep names, headlines and the tone of the stories in one key.
- Explanatory text (buttons, an upgrade's effect, how to play) is never a joke.

## 10. How to verify and how to show

- Before it goes in, pass the play-shape checks of `balance-by-simulation` in simulation.
- When a choice belongs to someone else, line up playable samples and let them play before deciding.
- The how-to-play pages teach how to read each added mechanism. The explanation of another mode (a daily single run, say) states only what differs from the main game.
- One page, one sentence, and nothing the screen already shows. Behind each sentence, show the real screen it talks about, advanced with a fixed seed and a stopped clock to the scene and frozen there, with the part it talks about outlined.
