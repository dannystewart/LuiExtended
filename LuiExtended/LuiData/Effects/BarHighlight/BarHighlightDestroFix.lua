-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData

local Data = LuiData.Data
--- @class (partial) Effects
local Effects = Data.Effects

--------------------------------------------------------------------------------------------------------------------------------
-- Local Constants.
--------------------------------------------------------------------------------------------------------------------------------

local WEAPONTYPE_NONE = WEAPONTYPE_NONE
local WEAPONTYPE_FIRE_STAFF = WEAPONTYPE_FIRE_STAFF
local WEAPONTYPE_LIGHTNING_STAFF = WEAPONTYPE_LIGHTNING_STAFF
local WEAPONTYPE_FROST_STAFF = WEAPONTYPE_FROST_STAFF

--------------------------------------------------------------------------------------------------------------------------------
-- EFFECTS TABLE FOR BAR HIGHLIGHT RELATED OVERRIDES
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
-- When a bar ability proc with a matching id appears, display the toggle highlight
--------------------------------------------------------------------------------------------------------------------------------

-- Switch backbar slotId's when we have a certain type of staff equipped
-- Back Bar ID will unfortunately return either the base ability or the element type of the Staff we are using in our current weapon pair, so have to check for ALL of these conditions
--- @class (partial) BarHighlightDestroFix
--- @field [integer] table<WeaponType,integer>
local barHighlightDestroFix =
{
    -- Base Ability
    [28858] = { [WEAPONTYPE_NONE] = 28858, [WEAPONTYPE_FIRE_STAFF] = 28807, [WEAPONTYPE_LIGHTNING_STAFF] = 28854, [WEAPONTYPE_FROST_STAFF] = 28849 }, -- Wall of Elements
    [39052] = { [WEAPONTYPE_NONE] = 39052, [WEAPONTYPE_FIRE_STAFF] = 39053, [WEAPONTYPE_LIGHTNING_STAFF] = 39073, [WEAPONTYPE_FROST_STAFF] = 39067 }, -- Unstable Wall of Elements
    [39011] = { [WEAPONTYPE_NONE] = 39011, [WEAPONTYPE_FIRE_STAFF] = 39012, [WEAPONTYPE_LIGHTNING_STAFF] = 39018, [WEAPONTYPE_FROST_STAFF] = 39028 }, -- Elemental Blockade
    [29091] = { [WEAPONTYPE_NONE] = 29091, [WEAPONTYPE_FIRE_STAFF] = 29073, [WEAPONTYPE_LIGHTNING_STAFF] = 29089, [WEAPONTYPE_FROST_STAFF] = 29078 }, -- Destructive Touch
    [38984] = { [WEAPONTYPE_NONE] = 38984, [WEAPONTYPE_FIRE_STAFF] = 38985, [WEAPONTYPE_LIGHTNING_STAFF] = 38993, [WEAPONTYPE_FROST_STAFF] = 38989 }, -- Destructive Clench
    [38937] = { [WEAPONTYPE_NONE] = 38937, [WEAPONTYPE_FIRE_STAFF] = 38944, [WEAPONTYPE_LIGHTNING_STAFF] = 38978, [WEAPONTYPE_FROST_STAFF] = 38970 }, -- Destructive Reach
    [28800] = { [WEAPONTYPE_NONE] = 28800, [WEAPONTYPE_FIRE_STAFF] = 28794, [WEAPONTYPE_LIGHTNING_STAFF] = 28799, [WEAPONTYPE_FROST_STAFF] = 28798 }, -- Impulse
    [39143] = { [WEAPONTYPE_NONE] = 39143, [WEAPONTYPE_FIRE_STAFF] = 39145, [WEAPONTYPE_LIGHTNING_STAFF] = 39147, [WEAPONTYPE_FROST_STAFF] = 39146 }, -- Elemental Ring
    [39161] = { [WEAPONTYPE_NONE] = 39161, [WEAPONTYPE_FIRE_STAFF] = 39162, [WEAPONTYPE_LIGHTNING_STAFF] = 39167, [WEAPONTYPE_FROST_STAFF] = 39163 }, -- Pulsar

    -- Fire Staff
    [28807] = { [WEAPONTYPE_NONE] = 28858, [WEAPONTYPE_FIRE_STAFF] = 28807, [WEAPONTYPE_LIGHTNING_STAFF] = 28854, [WEAPONTYPE_FROST_STAFF] = 28849 }, -- Wall of Elements
    [39053] = { [WEAPONTYPE_NONE] = 39052, [WEAPONTYPE_FIRE_STAFF] = 39053, [WEAPONTYPE_LIGHTNING_STAFF] = 39073, [WEAPONTYPE_FROST_STAFF] = 39067 }, -- Unstable Wall of Elements
    [39012] = { [WEAPONTYPE_NONE] = 39011, [WEAPONTYPE_FIRE_STAFF] = 39012, [WEAPONTYPE_LIGHTNING_STAFF] = 39018, [WEAPONTYPE_FROST_STAFF] = 39028 }, -- Elemental Blockade
    [29073] = { [WEAPONTYPE_NONE] = 29091, [WEAPONTYPE_FIRE_STAFF] = 29073, [WEAPONTYPE_LIGHTNING_STAFF] = 29089, [WEAPONTYPE_FROST_STAFF] = 29078 }, -- Destructive Touch
    [38985] = { [WEAPONTYPE_NONE] = 38984, [WEAPONTYPE_FIRE_STAFF] = 38985, [WEAPONTYPE_LIGHTNING_STAFF] = 38993, [WEAPONTYPE_FROST_STAFF] = 38989 }, -- Destructive Clench
    [38944] = { [WEAPONTYPE_NONE] = 38937, [WEAPONTYPE_FIRE_STAFF] = 38944, [WEAPONTYPE_LIGHTNING_STAFF] = 38978, [WEAPONTYPE_FROST_STAFF] = 38970 }, -- Destructive Reach
    [28794] = { [WEAPONTYPE_NONE] = 28800, [WEAPONTYPE_FIRE_STAFF] = 28794, [WEAPONTYPE_LIGHTNING_STAFF] = 28799, [WEAPONTYPE_FROST_STAFF] = 28798 }, -- Impulse
    [39145] = { [WEAPONTYPE_NONE] = 39143, [WEAPONTYPE_FIRE_STAFF] = 39145, [WEAPONTYPE_LIGHTNING_STAFF] = 39147, [WEAPONTYPE_FROST_STAFF] = 39146 }, -- Elemental Ring
    [39162] = { [WEAPONTYPE_NONE] = 39161, [WEAPONTYPE_FIRE_STAFF] = 39162, [WEAPONTYPE_LIGHTNING_STAFF] = 39167, [WEAPONTYPE_FROST_STAFF] = 39163 }, -- Pulsar

    -- Lightning Staff
    [28854] = { [WEAPONTYPE_NONE] = 28858, [WEAPONTYPE_FIRE_STAFF] = 28807, [WEAPONTYPE_LIGHTNING_STAFF] = 28854, [WEAPONTYPE_FROST_STAFF] = 28849 }, -- Wall of Elements
    [39073] = { [WEAPONTYPE_NONE] = 39052, [WEAPONTYPE_FIRE_STAFF] = 39053, [WEAPONTYPE_LIGHTNING_STAFF] = 39073, [WEAPONTYPE_FROST_STAFF] = 39067 }, -- Unstable Wall of Elements
    [39018] = { [WEAPONTYPE_NONE] = 39011, [WEAPONTYPE_FIRE_STAFF] = 39012, [WEAPONTYPE_LIGHTNING_STAFF] = 39018, [WEAPONTYPE_FROST_STAFF] = 39028 }, -- Elemental Blockade
    [29089] = { [WEAPONTYPE_NONE] = 29091, [WEAPONTYPE_FIRE_STAFF] = 29073, [WEAPONTYPE_LIGHTNING_STAFF] = 29089, [WEAPONTYPE_FROST_STAFF] = 29078 }, -- Destructive Touch
    [38993] = { [WEAPONTYPE_NONE] = 38984, [WEAPONTYPE_FIRE_STAFF] = 38985, [WEAPONTYPE_LIGHTNING_STAFF] = 38993, [WEAPONTYPE_FROST_STAFF] = 38989 }, -- Destructive Clench
    [38978] = { [WEAPONTYPE_NONE] = 38937, [WEAPONTYPE_FIRE_STAFF] = 38944, [WEAPONTYPE_LIGHTNING_STAFF] = 38978, [WEAPONTYPE_FROST_STAFF] = 38970 }, -- Destructive Reach
    [28799] = { [WEAPONTYPE_NONE] = 28800, [WEAPONTYPE_FIRE_STAFF] = 28794, [WEAPONTYPE_LIGHTNING_STAFF] = 28799, [WEAPONTYPE_FROST_STAFF] = 28798 }, -- Impulse
    [39147] = { [WEAPONTYPE_NONE] = 39143, [WEAPONTYPE_FIRE_STAFF] = 39145, [WEAPONTYPE_LIGHTNING_STAFF] = 39147, [WEAPONTYPE_FROST_STAFF] = 39146 }, -- Elemental Ring
    [39167] = { [WEAPONTYPE_NONE] = 39161, [WEAPONTYPE_FIRE_STAFF] = 39162, [WEAPONTYPE_LIGHTNING_STAFF] = 39167, [WEAPONTYPE_FROST_STAFF] = 39163 }, -- Pulsar

    -- Frost Staff
    [28849] = { [WEAPONTYPE_NONE] = 28858, [WEAPONTYPE_FIRE_STAFF] = 28807, [WEAPONTYPE_LIGHTNING_STAFF] = 28854, [WEAPONTYPE_FROST_STAFF] = 28849 }, -- Wall of Elements
    [39067] = { [WEAPONTYPE_NONE] = 39052, [WEAPONTYPE_FIRE_STAFF] = 39053, [WEAPONTYPE_LIGHTNING_STAFF] = 39073, [WEAPONTYPE_FROST_STAFF] = 39067 }, -- Unstable Wall of Elements
    [39028] = { [WEAPONTYPE_NONE] = 39011, [WEAPONTYPE_FIRE_STAFF] = 39012, [WEAPONTYPE_LIGHTNING_STAFF] = 39018, [WEAPONTYPE_FROST_STAFF] = 39028 }, -- Elemental Blockade
    [29078] = { [WEAPONTYPE_NONE] = 29091, [WEAPONTYPE_FIRE_STAFF] = 29073, [WEAPONTYPE_LIGHTNING_STAFF] = 29089, [WEAPONTYPE_FROST_STAFF] = 29078 }, -- Destructive Touch
    [38990] = { [WEAPONTYPE_NONE] = 38984, [WEAPONTYPE_FIRE_STAFF] = 38985, [WEAPONTYPE_LIGHTNING_STAFF] = 38993, [WEAPONTYPE_FROST_STAFF] = 38989 }, -- Destructive Clench
    [38970] = { [WEAPONTYPE_NONE] = 38937, [WEAPONTYPE_FIRE_STAFF] = 38944, [WEAPONTYPE_LIGHTNING_STAFF] = 38978, [WEAPONTYPE_FROST_STAFF] = 38970 }, -- Destructive Reach
    [28798] = { [WEAPONTYPE_NONE] = 28800, [WEAPONTYPE_FIRE_STAFF] = 28794, [WEAPONTYPE_LIGHTNING_STAFF] = 28799, [WEAPONTYPE_FROST_STAFF] = 28798 }, -- Impulse
    [39146] = { [WEAPONTYPE_NONE] = 39143, [WEAPONTYPE_FIRE_STAFF] = 39145, [WEAPONTYPE_LIGHTNING_STAFF] = 39147, [WEAPONTYPE_FROST_STAFF] = 39146 }, -- Elemental Ring
    [39163] = { [WEAPONTYPE_NONE] = 39161, [WEAPONTYPE_FIRE_STAFF] = 39162, [WEAPONTYPE_LIGHTNING_STAFF] = 39167, [WEAPONTYPE_FROST_STAFF] = 39163 }, -- Pulsar

    -- Ultimates

    -- Elemental Storm
    [83619] = { [WEAPONTYPE_NONE] = 83619, [WEAPONTYPE_FIRE_STAFF] = 83625, [WEAPONTYPE_FROST_STAFF] = 83628, [WEAPONTYPE_LIGHTNING_STAFF] = 85130 }, -- elemental storm
    [83625] = { [WEAPONTYPE_NONE] = 83619, [WEAPONTYPE_FIRE_STAFF] = 83625, [WEAPONTYPE_FROST_STAFF] = 83628, [WEAPONTYPE_LIGHTNING_STAFF] = 85130 }, -- fire
    [83628] = { [WEAPONTYPE_NONE] = 83619, [WEAPONTYPE_FIRE_STAFF] = 83625, [WEAPONTYPE_FROST_STAFF] = 83628, [WEAPONTYPE_LIGHTNING_STAFF] = 85130 }, -- ice
    [83630] = { [WEAPONTYPE_NONE] = 83619, [WEAPONTYPE_FIRE_STAFF] = 83625, [WEAPONTYPE_FROST_STAFF] = 83628, [WEAPONTYPE_LIGHTNING_STAFF] = 85130 }, -- shock

    -- Eye of the Storm
    [83642] = { [WEAPONTYPE_NONE] = 83642, [WEAPONTYPE_FIRE_STAFF] = 83682, [WEAPONTYPE_FROST_STAFF] = 83684, [WEAPONTYPE_LIGHTNING_STAFF] = 83686 }, -- eye of the storm
    [83682] = { [WEAPONTYPE_NONE] = 83642, [WEAPONTYPE_FIRE_STAFF] = 83682, [WEAPONTYPE_FROST_STAFF] = 83684, [WEAPONTYPE_LIGHTNING_STAFF] = 83686 }, -- fire
    [83684] = { [WEAPONTYPE_NONE] = 83642, [WEAPONTYPE_FIRE_STAFF] = 83682, [WEAPONTYPE_FROST_STAFF] = 83684, [WEAPONTYPE_LIGHTNING_STAFF] = 83686 }, -- ice
    [83686] = { [WEAPONTYPE_NONE] = 83642, [WEAPONTYPE_FIRE_STAFF] = 83682, [WEAPONTYPE_FROST_STAFF] = 83684, [WEAPONTYPE_LIGHTNING_STAFF] = 83686 }, -- shock

    -- Elemental Rage
    [84434] = { [WEAPONTYPE_NONE] = 84434, [WEAPONTYPE_FIRE_STAFF] = 85126, [WEAPONTYPE_FROST_STAFF] = 85128, [WEAPONTYPE_LIGHTNING_STAFF] = 85130 }, -- elemental rage
    [85126] = { [WEAPONTYPE_NONE] = 84434, [WEAPONTYPE_FIRE_STAFF] = 85126, [WEAPONTYPE_FROST_STAFF] = 85128, [WEAPONTYPE_LIGHTNING_STAFF] = 85130 }, -- fire
    [85128] = { [WEAPONTYPE_NONE] = 84434, [WEAPONTYPE_FIRE_STAFF] = 85126, [WEAPONTYPE_FROST_STAFF] = 85128, [WEAPONTYPE_LIGHTNING_STAFF] = 85130 }, -- ice
    [85130] = { [WEAPONTYPE_NONE] = 84434, [WEAPONTYPE_FIRE_STAFF] = 85126, [WEAPONTYPE_FROST_STAFF] = 85128, [WEAPONTYPE_LIGHTNING_STAFF] = 85130 }, -- shock
}

--- @class (partial) BarHighlightDestroFix
Effects.BarHighlightDestroFix = barHighlightDestroFix
