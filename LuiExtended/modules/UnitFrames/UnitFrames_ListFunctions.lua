-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
local printToChat = LUIE.PrintToChat

-- Unit Frames namespace
--- @class (partial) UnitFrames
local UnitFrames = LUIE.UnitFrames

local moduleName = UnitFrames.moduleName
local g_AvaCustFrames = UnitFrames.AvaCustFrames                   -- Another set of custom frames. Currently designed only to provide AvA Player Target reticleover frame
local g_DefaultFrames = UnitFrames.DefaultFrames                   -- Default Unit Frames are not referenced by external modules
local g_MaxChampionPoint = UnitFrames.MaxChampionPoint             -- Keep this value in local constant
local g_defaultTargetNameLabel = UnitFrames.defaultTargetNameLabel -- Reference to default UI target name label
local g_defaultThreshold = UnitFrames.defaultThreshold
local g_isRaid = UnitFrames.isRaid                                 -- Used by resurrection tracking function to determine if we should use abbreviated or unabbreviated text for resurrection.
local g_powerError = UnitFrames.powerError
local g_savedHealth = UnitFrames.savedHealth
local g_statFull = UnitFrames.statFull
local g_targetThreshold = UnitFrames.targetThreshold
local g_healthThreshold = UnitFrames.healthThreshold
local g_magickaThreshold = UnitFrames.magickaThreshold
local g_staminaThreshold = UnitFrames.staminaThreshold
local g_targetUnitFrame = UnitFrames.targetUnitFrame
local playerDisplayName = UnitFrames.playerDisplayName
-- -----------------------------------------------------------------------------
function UnitFrames.AddCurrentPetsToCustomList(list)
    for i = 1, MAX_PET_UNIT_TAGS do
        local unitTag = "playerpet" .. i
        if DoesUnitExist(unitTag) and (GetUnitType(unitTag) == COMBAT_UNIT_TYPE_PLAYER_PET) then
            local unitName = GetUnitName(unitTag)
            if unitName ~= "" and unitName ~= nil then
                if LUIE.IsDevDebugEnabled() then
                    LUIE.Debug(unitName)
                end
                UnitFrames.AddToCustomList(list, unitName)
            end
        end
    end
end

-- -----------------------------------------------------------------------------
-- Bulk list add from menu buttons
function UnitFrames.AddBulkToCustomList(list, t)
    if t ~= nil then
        for k, v in pairs(t) do
            UnitFrames.AddToCustomList(list, k)
        end
    end
end

-- -----------------------------------------------------------------------------
function UnitFrames.ClearCustomList(list)
    local listRef = list == UnitFrames.SV.whitelist and GetString(LUIE_STRING_CUSTOM_LIST_UF_WHITELIST) or ""
    for k, v in pairs(list) do
        list[k] = nil
    end
    ZO_GetChatSystem():Maximize()
    ZO_GetChatSystem().primaryContainer:FadeIn()
    printToChat(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_CLEARED), listRef), true)
end

-- -----------------------------------------------------------------------------
-- List Handling (Add) Pet Whitelist
function UnitFrames.AddToCustomList(list, input)
    local listRef = list == UnitFrames.SV.whitelist and GetString(LUIE_STRING_CUSTOM_LIST_UF_WHITELIST) or ""
    if input ~= "" then
        list[input] = true
        ZO_GetChatSystem():Maximize()
        ZO_GetChatSystem().primaryContainer:FadeIn()
        printToChat(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_ADDED_NAME), input, listRef), true)
    end
end

-- -----------------------------------------------------------------------------
-- List Handling (Remove) Pet Whitelist
function UnitFrames.RemoveFromCustomList(list, input)
    local listRef = list == UnitFrames.SV.whitelist and GetString(LUIE_STRING_CUSTOM_LIST_UF_WHITELIST) or ""
    if input ~= "" then
        list[input] = nil
        ZO_GetChatSystem():Maximize()
        ZO_GetChatSystem().primaryContainer:FadeIn()
        printToChat(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_REMOVED_NAME), input, listRef), true)
    end
end

-- -----------------------------------------------------------------------------
return UnitFrames
