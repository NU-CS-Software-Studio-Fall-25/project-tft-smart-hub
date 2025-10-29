# Data Sources Overview
This document describes where and how TFT Smart Hub retrieves its data.

version: <https://www.leagueoflegends.com/en-us/news/tags/teamfight-tactics-patch-notes/>
static data: <https://developer.riotgames.com/docs/tft>


## 1. Riot Official APIs
- **champion**:
```
{
    "type": "tft-champion",
    "version": "0.0.0",
    "data": {
        "TFT9_Irelia": {
            "id": "TFT9_Irelia",
            "name": "Irelia",
            "tier": 1,
            "image": {
                "full": "TFT9_Irelia.TFT_Set9.png",
                "sprite": "tft-champion0.png",
                "group": "tft-champion",
                "x": 0,
                "y": 0,
                "w": 48,
                "h": 48
            }
        },
        ...
```

- **traits**
```
{
    "type": "tft-trait",
    "version": "15.20.1",
    "data": {
        "TFTTutorial_Assassin": {
            "id": "TFTTutorial_Assassin",
            "name": "Assassin",
            "image": {
                "full": "Trait_Icon_Assassin.png",
                "sprite": "tft-trait0.png",
                "group": "tft-trait",
                "x": 0,
                "y": 0,
                "w": 48,
                "h": 48
            }
        },
        ...
    }
}
```

- **Items**
```
{
    "type": "tft-item",
    "version": "0.0.0",
    "data": {
        "TFT_Consumable_NeekosHelp": {
            "id": "TFT_Consumable_NeekosHelp",
            "name": "Champion Duplicator",
            "image": {
                "full": "TFT_Consumable_NeekosHelp.png",
                "sprite": "tft-item0.png",
                "group": "tft-item",
                "x": 0,
                "y": 0,
                "w": 48,
                "h": 48
            }
        },
    ...
```

- **Arguments**(future)
```
{
    "type": "tft-augment",
    "version": "0.0.0",
    "augment-container": {
        "name": "Hexcore Augments",
        "image": {
            "full": "EOG_AugmentPop_Generic.TFT_Set9.png",
            "sprite": "tft-augment0.png",
            "group": "tft-augment",
            "x": 0,
            "y": 0,
            "w": 48,
            "h": 48
        }
    },
    "data": {
        "TFT6_Augment_SalvageBin": {
            "id": "TFT6_Augment_SalvageBin",
            "name": "Salvage Bin",
            "image": {
                "full": "Salvage2.png",
                "sprite": "tft-augment0.png",
                "group": "tft-augment",
                "x": 48,
                "y": 0,
                "w": 48,
                "h": 48
            }
        }
    ...
```

- **Match**
```
{
    'metadata': {
        'data_version': '6'
        'matc_id': 'NA1_5375756533'
        'participants': ["puuid1", "puuid2", ...]
    },
    'info': {
        'endOfGameResult': 'GameComplete',
        'gameCreation': 1758822924000,
        'gameId': 5375756533,
        'game_datetime': 1758825153633,
        'game_length': 2201.687255859375,
        'game_version': 'Linux Version 15.19.713.5912 (Sep 18 2025/16:50:53) [PUBLIC] <Releases/15.19>',
        'mapId': 22,
        'participants': [
            {
                'companion': CompanionDto,
                'gold_left': 3,
                'last_round': 37,
                'level': 9,  ##
                'missions': {'PlayerScore2': 219},
                'placement': 3,
                'players_eliminated': 2,
                'puuid': <string>,
                'riotIdGameName': 'MB DavidAs',
                'riotIdTagline': 'TFTQC',
                'time_eliminated': 2178.9033203125,
                'total_damage_to_players': 144,
                'traits': [
                    {
                        'name': 'TFT15_Bastion',
                        'num_units': 2,
                        'style': 1,  # (0 = No style, 1 = Bronze, 2 = Silver, 3 = Gold, 4 = Chromatic)
                        'tier_current': 1,
                        'tier_total': 3
                    },
                    ...
                ]
                'units': [
                    {
                        'character_id': 'TFT15_Jinx',
                        'itemNames': ['TFT_Item_PowerGauntlet',
                        'TFT_Item_SpearOfShojin',
                        'TFT_Item_InfinityEdge'],
                        'name': '',
                        'rarity': 4,
                        'tier': 2
                    },
                    ...
                ]
                'win': True
            },
            ...
        ]
        'queue_id': 1100,
        'tft_game_type': 'standard',   ##
        'tft_set_core_name': 'TFTSet15',
        'tft_set_number': 15
    }
}
```

## 2. Community Dragon
- **Champion-Traits**
```
[
  {
    "championId": "TFT15_Aatrox",
    "traits": [
      "Mighty Mech",
      "Juggernaut",
      "Heavyweight"
    ]
  },
  ...
]
```