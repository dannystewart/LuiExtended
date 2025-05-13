--- @diagnostic disable: duplicate-index
-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData
local Data = LuiData.Data
-- For debug function - convert result reason codes to string value
--- @class DebugStatus
local DebugStatus =
{
    [STATUS_EFFECT_TYPE_BLEED] = "BLEED",
    [STATUS_EFFECT_TYPE_BLIND] = "BLIND",
    [STATUS_EFFECT_TYPE_CHARM] = "CHARM",
    [STATUS_EFFECT_TYPE_DAZED] = "DAZED",
    [STATUS_EFFECT_TYPE_DISEASE] = "DISEASE",
    [STATUS_EFFECT_TYPE_ENVIRONMENT] = "ENVIRONMENT",
    [STATUS_EFFECT_TYPE_FEAR] = "FEAR",
    [STATUS_EFFECT_TYPE_LEVITATE] = "LEVITATE",
    [STATUS_EFFECT_TYPE_MAGIC] = "MAGIC",
    [STATUS_EFFECT_TYPE_MESMERIZE] = "MESMERIZE",
    [STATUS_EFFECT_TYPE_NEARSIGHT] = "NEARSIGHT",
    [STATUS_EFFECT_TYPE_NONE] = "NONE",
    [STATUS_EFFECT_TYPE_PACIFY] = "PACIFY",
    [STATUS_EFFECT_TYPE_POISON] = "POISON",
    [STATUS_EFFECT_TYPE_PUNCTURE] = "PUNCTURE",
    [STATUS_EFFECT_TYPE_ROOT] = "ROOT",
    [STATUS_EFFECT_TYPE_SILENCE] = "SILENCE",
    [STATUS_EFFECT_TYPE_SNARE] = "SNARE",
    [STATUS_EFFECT_TYPE_STUN] = "STUN",
    [STATUS_EFFECT_TYPE_TRAUMA] = "TRAUMA",
    [STATUS_EFFECT_TYPE_WEAKNESS] = "WEAKNESS",
    [STATUS_EFFECT_TYPE_WOUND] = "WOUND",
}

--- @type DebugStatus
Data.DebugStatus = DebugStatus
