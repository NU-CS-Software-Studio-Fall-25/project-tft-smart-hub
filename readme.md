# TFT Smart Hub

A modern web platform for analyzing and visualizing TFT team compositions, inspired by [tftactics.gg](https://tftactics.gg) and [tactics.tools](https://tactics.tools).

Unlike existing tools, TFT Smart Hub focuses on personalized team composition recommendations — helping players find optimal builds based on their current incomplete board and game state.

## Smart Composition Recommendation

Users input their current (incomplete) composition, then click "Recommend" to receive a list of possible compositions that are:

1. High win-rate
Derived from real match data; these comps statistically perform well across many games.

2. Relevant to the user’s current team
Shares units or traits with the current board, making it easy to pivot toward strong comps without starting from scratch.
(This matters because unit rolls are random, so overlapping units increase achievability.)

Achievable
3. Avoids recommending unrealistic builds (too expensive, too item-dependent, or requiring rare augments).
Focuses on comps the player can actually reach in the current stage of the game.

4. Personalized (future)
Considers unique player advantages such as specific items, augments (hexes), or emblems, to avoid wasting current strengths.

## Composition Types

There are two distinct sources of team compositions:
1. Statistical: Curated by the website using aggregated real match data. Includes metrics such as win rate, average placement, and popularity.

2. User-Created: Submitted by community members. Can include descriptions, notes, and early/mid/late game transitions.


Section	Description
1. Recommendation (Core)	Central feature. Users input their current team, and the system recommends best achievable compositions.

2. Champion List	Displays all champions with filters and sorting (e.g., by cost, trait, tier).

3. Item List	Shows all items and combinations; supports filtering and sorting by type, tier, or usage rate.

4. User Section	After logging in, users can:
• Save recommended (Type 1) compositions
• Create their own (Type 2) compositions
• View and manage saved comps (separated by type).

5. (Future) Composition Library	A global gallery of all comps (both Type 1 & 2).
Users can browse, like, comment, and save.
Includes a toggle between "Official" and "User-Created" comps.


