---@meta

--- @class LUIE_ChampionXP
--- @field backdrop BackdropControl
--- @field bar StatusBarControl
--- @field enlightenment StatusBarControl
--- @field icon TextureControl

--- @class LUIE_Boss_Group
--- @field [`COMBAT_MECHANIC_FLAGS_HEALTH`] LUIE_Boss_Group_Health
--- @field control Control
--- @field name LabelControl
--- @field dead LabelControl
--- @field tlw TopLevelWindow
--- @field unitTag string

--- @class LUIE_Boss_Group_Health
--- @field backdrop BackdropControl
--- @field bar StatusBarControl
--- @field invulnerable StatusBarControl
--- @field invulnerableInlay StatusBarControl
--- @field label LabelControl
--- @field shield StatusBarControl
--- @field threshold integer
--- @field trauma StatusBarControl

--- @class LUIE_PetGroup_Health
--- @field backdrop BackdropControl
--- @field bar StatusBarControl
--- @field label LabelControl
--- @field shield StatusBarControl
--- @field trauma StatusBarControl

--- @class LUIE_PetGroup
--- @field tlw TopLevelWindow
--- @field name LabelControl
--- @field dead LabelControl
--- @field control Control
--- @field [`COMBAT_MECHANIC_FLAGS_HEALTH`] LUIE_PetGroup_Health

--- @class LUIE_RaidGroup_Health
--- @field backdrop BackdropControl
--- @field bar StatusBarControl
--- @field invulnerable StatusBarControl
--- @field invulnerableInlay StatusBarControl
--- @field label LabelControl
--- @field shield StatusBarControl
--- @field trauma StatusBarControl

--- @class LUIE_RaidGroup
--- @field [`COMBAT_MECHANIC_FLAGS_HEALTH`] LUIE_RaidGroup_Health
--- @field tlw TopLevelWindow
--- @field control Control
--- @field name LabelControl
--- @field dead LabelControl
--- @field leader LabelControl
--- @field roleIcon Control
--- @field unitTag string

--- @class LUIE_SmallGroup
--- @field [`COMBAT_MECHANIC_FLAGS_HEALTH`] LUIE_SmallGroup_Health
--- @field tlw TopLevelWindow
--- @field name LabelControl
--- @field dead LabelControl
--- @field control Control

--- @class LUIE_SmallGroup_Health
--- @field backdrop BackdropControl
--- @field bar StatusBarControl
--- @field invulnerable StatusBarControl
--- @field invulnerableInlay StatusBarControl
--- @field label LabelControl
--- @field shield StatusBarControl

--- @class LUIE_Player_Health
--- @field backdrop BackdropControl
--- @field bar StatusBarControl
--- @field invulnerable StatusBarControl
--- @field invulnerableInlay StatusBarControl
--- @field label LabelControl
--- @field shield StatusBarControl
--- @field stat table<integer,{dec:Control,inc:TextureControl}>
--- @field trauma StatusBarControl
--- @field threshold integer

--- @class LUIE_Player_Resource
--- @field backdrop BackdropControl
--- @field bar StatusBarControl
--- @field labelOne LabelControl
--- @field labelTwo LabelControl
--- @field threshold integer

--- @class LUIE_Player
--- @field [`COMBAT_MECHANIC_FLAGS_HEALTH`] LUIE_Player_Health
--- @field [`COMBAT_MECHANIC_FLAGS_MAGICKA`] LUIE_Player_Resource
--- @field [`COMBAT_MECHANIC_FLAGS_STAMINA`] LUIE_Player_Resource
--- @field control Control
--- @field tlw TopLevelWindow
--- @field name LabelControl
--- @field level LabelControl
--- @field levelIcon Control
--- @field ChampionXP LUIE_ChampionXP
--- @field isChampion boolean
--- @field isLevelCap boolean
--- @field isPlayer boolean
--- @field buffs Control|table
--- @field debuffs Control|table
--- @field buffAnchor Control
--- @field avaRankValue integer
--- @field alternative Control
--- @field unitTag string
--- @field topInfo Control
--- @field botInfo Control