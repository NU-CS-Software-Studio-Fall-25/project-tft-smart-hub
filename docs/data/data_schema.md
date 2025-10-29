
## 🧩 TFT Smart Hub — Data Schema

This document specifies the data schema used by TFT Smart Hub for ingesting and serving Riot/Community data and derived analytics.

---

## 1. Table: champions

| Field      | Type                           | Description                        | Example                                     |
|----------- |--------------------------------|------------------------------------|---------------------------------------------|
| id         | string (PK)                    | Unique champion id from Riot data  | "TFT9_Irelia"                              |
| name       | string                         | Display name                       | "Irelia"                                   |
| cost       | int                            | Cost (1–5)                         | 1                                           |
| image_full | string                         | Full image filename                | "TFT9_Irelia.TFT_Set9.png"                 |
| sprite     | string                         | Sprite sheet filename              | "tft-champion0.png"                        |
| group      | string                         | Image group                        | "tft-champion"                             |
| x          | int                            | Sprite x                           | 0                                           |
| y          | int                            | Sprite y                           | 0                                           |
| w          | int                            | Sprite width                       | 48                                          |
| h          | int                            | Sprite height                      | 48                                          |
| set_number | int                            | Set version number                 | 15                                          |
| traits     | array<string> (FK → traits.id) | Associated traits                  | ["TFT15_Bastion","TFT15_Rebel"]           |
| updated_at | datetime                       | Last sync timestamp                | "2025-10-29T00:00:00Z"                      |

Note: traits are generated from Community Dragon's champion-to-traits mapping.

---

## 2. Table: traits

| Field      | Type        | Description             | Example                    |
|------------|-------------|-------------------------|----------------------------|
| id         | string (PK) | Trait ID                | "TFT15_Bastion"           |
| name       | string      | Display name            | "Bastion"                  |
| image_full | string      | Full image filename     | "Trait_Icon_Bastion.png"  |
| sprite     | string      | Sprite sheet filename   | "tft-trait0.png"          |
| group      | string      | Image group             | "tft-trait"               |
| x          | int         | Sprite x                | 0                          |
| y          | int         | Sprite y                | 0                          |
| w          | int         | Sprite width            | 48                         |
| h          | int         | Sprite height           | 48                         |
| thresholds | array<int>  | Active breakpoints      | [2,4,6,8]                  |
| set_number | int         | TFT set number          | 15                         |
| updated_at | datetime    | Timestamp of last sync  | "2025-10-29T00:00:00Z"     |

---

## 3. Table: items

| Field       | Type          | Description             | Example                                  |
|-------------|---------------|-------------------------|------------------------------------------|
| id          | string (PK)   | Item ID                 | "TFT_Item_InfinityEdge"                 |
| name        | string        | Display name            | "Infinity Edge"                          |
| image_full  | string        | Full image filename     | "TFT_Item_InfinityEdge.png"             |
| sprite      | string        | Sprite sheet filename   | "tft-item0.png"                          |
| group       | string        | Image group             | "tft-item"                               |
| x           | int           | Sprite x                | 0                                        |
| y           | int           | Sprite y                | 0                                        |
| w           | int           | Sprite width            | 48                                       |
| h           | int           | Sprite height           | 48                                       |
| builds_from | array<string> | Component item IDs      | ["TFT_Item_BFSword","TFT_Item_BFSword"] |
| set_number  | int           | TFT set number          | 15                                       |
| updated_at  | datetime      | Timestamp of last sync  | "2025-10-29T00:00:00Z"                   |

---

## 4. Table: augments

| Field      | Type        | Description             | Example                    |
|------------|-------------|-------------------------|----------------------------|
| id         | string (PK) | Augment ID              | "TFT6_Augment_SalvageBin" |
| name       | string      | Display name            | "Salvage Bin"             |
| image_full | string      | Image filename          | "Salvage2.png"            |
| sprite     | string      | Sprite sheet filename   | "tft-augment0.png"        |
| group      | string      | Image group             | "tft-augment"             |
| x          | int         | Sprite x                | 48                         |
| y          | int         | Sprite y                | 0                          |
| w          | int         | Sprite width            | 48                         |
| h          | int         | Sprite height           | 48                         |
| set_number | int         | TFT set number          | 15                         |
| updated_at | datetime    | Timestamp of last sync  | "2025-10-29T00:00:00Z"     |

---

## 5. Table: players

| Field     | Type                         | Description            | Example               |
|-----------|------------------------------|------------------------|-----------------------|
| puuid     | string (PK)                  | Riot Player Unique ID  | "kb12xZ2a-..."       |
| game_name | string                       | Riot ID name           | "MB DavidAs"         |
| tagline   | string                       | Riot tagline           | "TFTQC"              |
| region    | enum(americas, asia, europe) | Region                 | "americas"           |
| platform  | enum(na1,kr,euw1,...)        | Platform               | "na1"                |
| rank      | string                       | Current rank           | "Diamond I"          |
| last_seen | datetime                     | Last match date        | "2025-10-28T22:00:00Z" |

---

## 6. Table: matches

| Field             | Type        | Description             | Example                  |
|-------------------|-------------|-------------------------|--------------------------|
| match_id          | string (PK) | Unique match identifier | "NA1_5375756533"        |
| data_version      | string      | API data version        | "6"                     |
| region            | enum        | Region host             | "americas"              |
| game_datetime     | datetime    | Game start time         | "2025-09-18T16:50:53Z"  |
| game_length       | float       | Duration (seconds)      | 2201.68                  |
| game_version      | string      | Client version          | "15.19.713.5912"        |
| queue_id          | int         | Queue type              | 1100                     |
| tft_game_type     | string      | Game type               | "standard"              |
| tft_set_core_name | string      | Set core name           | "TFTSet15"              |
| tft_set_number    | int         | Set number              | 15                       |
| created_at        | datetime    | First import time       | "2025-10-29T00:00:00Z"  |

---

## 7. Table: participants

Up to 8 participants per match. One record corresponds to (match_id + puuid).

| Field                  | Type                  | Description             | Example           |
|------------------------|-----------------------|-------------------------|-------------------|
| id                     | autoincrement (PK)    | Primary key             | 1                 |
| match_id               | FK → matches.match_id | Reference to match      | "NA1_5375756533" |
| puuid                  | FK → players.puuid    | Player reference        | "kb12xZ2a-..."   |
| placement              | int                   | Placement (1–8)         | 3                 |
| level                  | int                   | Player level            | 9                 |
| gold_left              | int                   | Remaining gold          | 3                 |
| players_eliminated     | int                   | Eliminations            | 2                 |
| total_damage_to_players| int                   | Damage dealt            | 144               |
| win                    | boolean               | Win flag                | true              |
| last_round             | int                   | Final round reached     | 37                |
| time_eliminated        | float                 | Time eliminated         | 2178.9            |

---

## 8. Table: participant_traits

| Field          | Type                 | Description        | Example          |
|----------------|----------------------|--------------------|------------------|
| participant_id | FK → participants.id | Link to participant| 1                |
| trait_id       | FK → traits.id       | Trait used         | "TFT15_Bastion" |
| num_units      | int                  | Number of units    | 2                |
| style          | int                  | Tier style (0–4)   | 1                |
| tier_current   | int                  | Current tier       | 1                |
| tier_total     | int                  | Max tier           | 3                |

---

## 9. Table: participant_units

| Field          | Type                  | Description        | Example                                                                |
|----------------|-----------------------|--------------------|------------------------------------------------------------------------|
| participant_id | FK → participants.id  | Parent participant | 1                                                                      |
| character_id   | FK → champions.id     | Champion ID        | "TFT15_Jinx"                                                          |
| rarity         | int                   | Rarity level       | 4                                                                      |
| tier           | int                   | Star level         | 2                                                                      |
| item_names     | array<string>         | Equipped items     | ["TFT_Item_PowerGauntlet","TFT_Item_SpearOfShojin"]                 |

---

## 10. Table: composition_stats (derived)

Derived table computed from matches/participants to support recommendation and analytics.

| Field         | Type               | Description         | Example                                           |
|---------------|--------------------|---------------------|---------------------------------------------------|
| id            | autoincrement (PK) | —                   | 1                                                 |
| champion_set  | array<string>      | Champion IDs        | ["TFT15_Ahri","TFT15_Sett","TFT15_Karma"]     |
| trait_set     | array<string>      | Trait IDs           | ["TFT15_Bastion","TFT15_Ionia"]                |
| avg_placement | float              | Average placement   | 3.2                                               |
| win_rate      | float              | Win rate            | 0.18                                              |
| sample_size   | int                | Number of matches   | 512                                               |
| last_updated  | datetime           | Updated timestamp   | "2025-10-29T00:00:00Z"                           |

---

## 🔗 11. Relationship Overview (ER Diagram Summary)

players ───< participants >─── matches
			   │     │
			   │     ├──< participant_units >── champions
			   │
			   └──< participant_traits >── traits
