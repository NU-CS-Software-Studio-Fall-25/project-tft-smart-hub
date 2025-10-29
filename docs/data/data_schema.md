
### 1. champions

Field	| Type	| Description |	Example |
id |	string (PK) |	Unique champion id from Riot data |	"TFT9_Irelia" |
name	string	Display name	"Irelia"
tier	int	Cost (1–5)	1
image_full	string	Full image filename	"TFT9_Irelia.TFT_Set9.png"
sprite	string	Sprite sheet filename	"tft-champion0.png"
group	string	Image group	"tft-champion"
x	int	Sprite x	0
y	int	Sprite y	0
w	int	Sprite width	48
h	int	Sprite height	48
set_number	int	Set version number	15
traits	array<string> (FK → traits.id)	Associated traits	["TFT15_Bastion","TFT15_Rebel"]
updated_at	datetime	Last sync timestamp	"2025-10-29T00:00:00Z"

Version

Composition_type1 

Composition_type2

Champion

Traits
