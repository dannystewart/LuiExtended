-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.SpellCastBuffs
local SpellCastBuffs = LUIE.SpellCastBuffs
local LuiData = LuiData
local Data = LuiData.Data
local Effects = Data.Effects
local EffectOverride = Effects.EffectOverride
local DebugAuras = Data.DebugAuras
local DebugResults = Data.DebugResults
local DebugStatus = Data.DebugStatus
local Tooltips = Data.Tooltips
local AssistantIcons = Effects.AssistantIcons

-- -----------------------------------------------------------------------------
-- Core Lua function localizations
-- -----------------------------------------------------------------------------

local pairs = pairs
local string_format = string.format
local zo_strformat = zo_strformat
local zo_iconFormat = zo_iconFormat
local zo_strgsub = zo_strgsub
local zo_round = zo_round
local tostring = tostring

-- API function localizations
local GetAbilityIcon = GetAbilityIcon
local GetAbilityName = GetAbilityName
local GetAbilityDuration = GetAbilityDuration
local GetAbilityCastInfo = GetAbilityCastInfo
local DoesAbilityExist = DoesAbilityExist
local GetDisplayName = GetDisplayName
local GetZoneId = GetZoneId
local GetCurrentMapZoneIndex = GetCurrentMapZoneIndex
local GetPlayerLocationName = GetPlayerLocationName
local GetCurrentMapId = GetCurrentMapId
local GetCurrentMapIndex = GetCurrentMapIndex
local GetMapInfoById = GetMapInfoById
local GetMapPlayerPosition = GetMapPlayerPosition
local GetMapName = GetMapName
local GetMapContentType = GetMapContentType
local GetMapType = GetMapType
local SetMapToPlayerLocation = SetMapToPlayerLocation
local SetMapToMapListIndex = SetMapToMapListIndex
local MapZoomOut = MapZoomOut
local GetFrameTimeMilliseconds = GetFrameTimeMilliseconds
local FormatTimeMilliseconds = FormatTimeMilliseconds

local chatSystem = ZO_GetChatSystem()

-- LUIE utility functions
local AddSystemMessage = LUIE.AddSystemMessage
local GetSlotTrueBoundId = LUIE.GetSlotTrueBoundId
local printToChat = LUIE.PrintToChat

-- -- Add millisecond timestamp to ability debug
-- local function MillisecondTimestampDebug(message)
--     local currentTime = GetGameTimeMilliseconds()
--     local timestamp = FormatTimeMilliseconds(currentTime, TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_MILLISECONDS_NO_HOURS_OR_DAYS, TIME_FORMAT_DIRECTION_NONE)
--     timestamp = zo_strgsub(timestamp, "HH", "")
--     timestamp = zo_strgsub(timestamp, "H ", ":")
--     timestamp = zo_strgsub(timestamp, "hh", "")
--     timestamp = zo_strgsub(timestamp, "h ", ":")
--     timestamp = zo_strgsub(timestamp, "m ", ":")
--     timestamp = zo_strgsub(timestamp, "s ", ":")
--     timestamp = zo_strgsub(timestamp, "A", "")
--     timestamp = zo_strgsub(timestamp, "a", "")
--     timestamp = zo_strgsub(timestamp, "ms", "")
--     message = string_format("|c%s[%s]|r %s", LUIE.TimeStampColorize, timestamp, message)
--     return message
-- end

--- Formats GPS coordinates for display
--- @param number number The raw coordinate value
--- @return number Rounded coordinate value
local function FormatGPSCoords(number)
    return zo_round(number * 100000)
end

--- Formats coordinates for display with proper formatting
--- @param number number The raw coordinate value
--- @return string Formatted coordinate string
local function FormatCoords(number)
    return ("%05.02f"):format(FormatGPSCoords(number) / 100)
end

local function getAbilityName(abilityId, casterUnitTag)
    return GetAbilityName(abilityId, casterUnitTag)
end

local function getAbilityDuration(abilityId, overrideActiveRank, overrideCasterUnitTag)
    return GetAbilityDuration(abilityId, overrideActiveRank, overrideCasterUnitTag)
end

local function getAbilityCastInfo(abilityId, overrideActiveRank, overrideCasterUnitTag)
    return GetAbilityCastInfo(abilityId, overrideActiveRank, overrideCasterUnitTag)
end

-- Debug Display for Combat Events
---
--- @param eventId integer
--- @param result ActionResult
--- @param isError boolean
--- @param abilityName string
--- @param abilityGraphic integer
--- @param abilityActionSlotType ActionSlotType
--- @param sourceName string
--- @param sourceType CombatUnitType
--- @param targetName string
--- @param targetType CombatUnitType
--- @param hitValue integer
--- @param powerType CombatMechanicFlags
--- @param damageType DamageType
--- @param log boolean
--- @param sourceUnitId integer
--- @param targetUnitId integer
--- @param abilityId integer
--- @param overflow integer
function SpellCastBuffs.EventCombatDebug(eventId, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    -- Don't display if this aura is already added to the filter
    if DebugAuras[abilityId] and SpellCastBuffs.SV.ShowDebugFilter then
        return
    end

    local iconFormatted = zo_iconFormat(GetAbilityIcon(abilityId), 16, 16)

    local source = zo_strformat("<<C:1>>", sourceName)
    local target = zo_strformat("<<C:1>>", targetName)
    local ability = zo_strformat("<<C:1>>", getAbilityName(abilityId))
    local duration = getAbilityDuration(abilityId) or 0
    local channeled, durationValue = getAbilityCastInfo(abilityId)
    local showacasttime = "" or GetString(SI_ABILITY_TOOLTIP_CHANNEL_TIME_LABEL)
    local showachantime = "" or GetString(SI_ABILITY_TOOLTIP_CAST_TIME_LABEL)
    if channeled then
        showachantime = (" [Chan] " .. durationValue)
    end
    if durationValue ~= 0 then
        showacasttime = (" [Cast] " .. durationValue)
    end
    if source == LUIE.PlayerNameFormatted then
        source = "Player"
    end
    if target == LUIE.PlayerNameFormatted then
        target = "Player"
    end
    if source == "" and target == "" then
        source = "NIL"
        target = "NIL"
    end

    local formattedResult = DebugResults[result]

    local finalString = (iconFormatted .. " [" .. abilityId .. "] " .. ability .. ": [S] " .. source .. " --> [T] " .. target .. " [D] " .. duration .. showachantime .. showacasttime .. " [R] " .. formattedResult)

    printToChat(finalString)
end

--- - Debug Display for Effect Events.
---
--- @param eventId integer
--- @param changeType EffectResult
--- @param effectSlot integer
--- @param effectName string
--- @param unitTag string
--- @param beginTime number
--- @param endTime number
--- @param stackCount integer
--- @param iconName string
--- @param deprecatedBuffType string
--- @param effectType BuffEffectType
--- @param abilityType AbilityType
--- @param statusEffectType StatusEffectType
--- @param unitName string
--- @param unitId integer
--- @param abilityId integer
--- @param sourceType CombatUnitType
function SpellCastBuffs.EventEffectDebug(eventId, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, deprecatedBuffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
    if DebugAuras[abilityId] and SpellCastBuffs.SV.ShowDebugFilter then
        return
    end

    local iconFormatted = zo_iconFormat(GetAbilityIcon(abilityId), 16, 16)
    local nameFormatted = zo_strformat("<<C:1>>", getAbilityName(abilityId))

    unitName = zo_strformat("<<C:1>>", unitName)
    if unitName == LUIE.PlayerNameFormatted then
        unitName = "Player"
    end
    unitName = unitName .. " (" .. unitTag .. ")"

    -- Get status effect string if available
    local statusEffect = DebugStatus[statusEffectType]

    local finalString
    if EffectOverride[abilityId] and EffectOverride[abilityId].hide then
        finalString = (iconFormatted .. "|c00E200 [" .. abilityId .. "] " .. nameFormatted .. ": [Tag] " .. unitName .. " [Status] " .. statusEffect .. "|r")
        AddSystemMessage(finalString)
        return
    end

    local duration = (endTime - beginTime) * 1000

    local refreshOnly = ""
    if EffectOverride[abilityId] and EffectOverride[abilityId].refreshOnly then
        refreshOnly = " |c00E200(Hidden)|r "
    end

    if changeType == 1 then
        finalString = ("|c00E200Gained:|r " .. refreshOnly .. iconFormatted .. " [" .. abilityId .. "] " .. nameFormatted .. ": [Tag] " .. unitName .. " [Dur] " .. duration .. " [Status] " .. statusEffect)
    elseif changeType == 2 then
        finalString = ("|c00E200Faded:|r " .. iconFormatted .. " [" .. abilityId .. "] " .. nameFormatted .. ": [Tag] " .. unitName .. " [Status] " .. statusEffect)
    else
        finalString = ("|c00E200Refreshed:|r " .. iconFormatted .. " (" .. changeType .. ") [" .. abilityId .. "] " .. nameFormatted .. ": [Tag] " .. unitName .. " [Dur] " .. duration .. " [Status] " .. statusEffect)
    end
    -- finalString = MillisecondTimestampDebug(finalString)
    printToChat(finalString)
end

-- Account specific DEBUG for ArtOfShred (These are only registered to give me some additional debug options)
---
--- @param eventId integer
--- @param result ActionResult
--- @param isError boolean
--- @param abilityName string
--- @param abilityGraphic integer
--- @param abilityActionSlotType ActionSlotType
--- @param sourceName string
--- @param sourceType CombatUnitType
--- @param targetName string
--- @param targetType CombatUnitType
--- @param hitValue integer
--- @param powerType CombatMechanicFlags
--- @param damageType DamageType
--- @param log boolean
--- @param sourceUnitId integer
--- @param targetUnitId integer
--- @param abilityId integer
--- @param overflow integer
function SpellCastBuffs.AuthorCombatDebug(eventId, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    if DebugAuras[abilityId] and SpellCastBuffs.SV.ShowDebugFilter then
        return
    end
    local iconFormatted = zo_iconFormat(GetAbilityIcon(abilityId), 16, 16)
    local nameFormatted = zo_strformat("<<C:1>>", getAbilityName(abilityId))

    local source = zo_strformat("<<C:1>>", sourceName)
    local target = zo_strformat("<<C:1>>", targetName)

    if source == LUIE.PlayerNameFormatted then
        source = "Player"
    end
    if target == LUIE.PlayerNameFormatted then
        target = "Player"
    end
    if source == "" and target == "" then
        source = "NIL"
        target = "NIL"
    end

    local formattedResult = DebugResults[result]

    if EffectOverride[abilityId] and EffectOverride[abilityId].hide then
        local finalString = (iconFormatted .. "[" .. abilityId .. "] " .. nameFormatted .. ": [S] " .. source .. " --> [T] " .. target .. " [R] " .. formattedResult)
        if chatSystem.primaryContainer then
            for k, cc in ipairs(chatSystem.containers) do
                local chatContainer = cc
                local chatWindow = cc.windows[3] or cc.windows[1]
                if chatContainer then
                    chatContainer:AddEventMessageToWindow(chatWindow, finalString, CHAT_CATEGORY_SYSTEM)
                end
            end
        end
    end
end

-- Account specific DEBUG for ArtOfShred (These are only registered to give me some additional debug options)
---
--- @param eventId integer
--- @param changeType EffectResult
--- @param effectSlot integer
--- @param effectName string
--- @param unitTag string
--- @param beginTime number
--- @param endTime number
--- @param stackCount integer
--- @param iconName string
--- @param deprecatedBuffType string
--- @param effectType BuffEffectType
--- @param abilityType AbilityType
--- @param statusEffectType StatusEffectType
--- @param unitName string
--- @param unitId integer
--- @param abilityId integer
--- @param sourceType CombatUnitType
function SpellCastBuffs.AuthorEffectDebug(eventId, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, deprecatedBuffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
    if DebugAuras[abilityId] and SpellCastBuffs.SV.ShowDebugFilter then
        return
    end
    local iconFormatted = zo_iconFormat(GetAbilityIcon(abilityId), 16, 16)
    local nameFormatted = zo_strformat("<<C:1>>", getAbilityName(abilityId))

    unitName = zo_strformat("<<C:1>>", unitName)
    if unitName == LUIE.PlayerNameFormatted then
        unitName = "Player"
    end
    unitName = unitName .. " (" .. unitTag .. ")"

    -- Get status effect string if available
    local statusEffect = DebugStatus[statusEffectType]

    local refreshOnly = ""
    if EffectOverride[abilityId] and EffectOverride[abilityId].refreshOnly then
        refreshOnly = " |c00E200(Refresh Only - Hidden)|r "
    end

    if EffectOverride[abilityId] and EffectOverride[abilityId].hide then
        local finalString = (iconFormatted .. refreshOnly .. "|c00E200 [" .. abilityId .. "] " .. nameFormatted .. ": [Tag] " .. unitName .. " [Status] " .. statusEffect .. "|r")
        if chatSystem.primaryContainer then
            for k, cc in ipairs(chatSystem.containers) do
                local chatContainer = cc
                local chatWindow = cc.windows[3] or cc.windows[1]
                if chatContainer then
                    chatContainer:AddEventMessageToWindow(chatWindow, finalString, CHAT_CATEGORY_SYSTEM)
                end
            end
        end
    end
end

-- -----------------------------------------------------------------------------
-- Map and Zone Information
-- -----------------------------------------------------------------------------

--- @class ZoneMapInfo
--- @field zoneid integer
--- @field locName string
--- @field mapid integer
--- @field mapindex luaindex|nil
--- @field name string
--- @field mapType UIMapType
--- @field mapContentType MapContentType
--- @field zoneIndex luaindex
--- @field description string
--- @field mapX number
--- @field mapY number
--- @field zoneX number
--- @field zoneY number
--- @field worldX number
--- @field worldY number
--- @field mapName string
--- @field zoneName string

--- Collects and returns zone and map information
--- @return ZoneMapInfo Information about current zone and map
local function CollectZoneMapInfo()
    -- Set map to player location and handle callback
    if SetMapToPlayerLocation() == SET_MAP_RESULT_MAP_CHANGED then
        LUIE:FireCallbacks("OnWorldMapChanged")
    end

    -- Get basic zone and map info
    local zoneid = GetZoneId(GetCurrentMapZoneIndex())
    local locName = GetPlayerLocationName()
    local mapid = GetCurrentMapId()
    local mapindex = GetCurrentMapIndex()
    local name, mapType, mapContentType, zoneIndex, description = GetMapInfoById(mapid)

    -- Get coordinates at different map levels
    local mapX, mapY = GetMapPlayerPosition("player")
    local zoneX, zoneY = mapX, mapY
    local worldX, worldY = mapX, mapY
    local mapName = GetMapName()
    local zoneName = mapName

    -- Handle dungeon/subzone cases
    if GetMapContentType() == MAP_CONTENT_DUNGEON or GetMapType() == MAPTYPE_SUBZONE then
        MapZoomOut()
        zoneName = GetMapName()
        zoneX, zoneY = GetMapPlayerPosition("player")
    end

    -- Get world coordinates (except for Coldharbour)
    if not (mapindex == 24 or GetCurrentMapIndex() == 24) then
        SetMapToMapListIndex(1) -- Tamriel
        worldX, worldY = GetMapPlayerPosition("player")
    end

    -- Reset map to player location
    if SetMapToPlayerLocation() == SET_MAP_RESULT_MAP_CHANGED then
        LUIE:FireCallbacks("OnWorldMapChanged")
    end

    -- Return collected information
    return
    {
        zoneid = zoneid,
        locName = locName,
        mapid = mapid,
        mapindex = mapindex,
        name = name,
        mapType = mapType,
        mapContentType = mapContentType,
        zoneIndex = zoneIndex,
        description = description,
        mapX = mapX,
        mapY = mapY,
        zoneX = zoneX,
        zoneY = zoneY,
        worldX = worldX,
        worldY = worldY,
        mapName = mapName,
        zoneName = zoneName,
    }
end

-- -----------------------------------------------------------------------------
-- Slash Command Handlers
-- -----------------------------------------------------------------------------

--- Toggles the ability debug filter on/off.
--- When enabled, shows additional debug information for abilities.
function SpellCastBuffs.TempSlashFilter()
    SpellCastBuffs.SV.ShowDebugFilter = not SpellCastBuffs.SV.ShowDebugFilter
    AddSystemMessage(string_format("LUIE --- Ability Debug Filter %s ---",
                                   SpellCastBuffs.SV.ShowDebugFilter and "Enabled" or "Disabled"))
end

--- Toggles ground damage aura visualization on/off.
--- When enabled, shows visual effects for ground-based damage areas.
--- Reloads player effects after toggling.
function SpellCastBuffs.TempSlashGround()
    SpellCastBuffs.SV.GroundDamageAura = not SpellCastBuffs.SV.GroundDamageAura
    AddSystemMessage(string_format("LUIE --- Ground Damage Auras %s ---",
                                   SpellCastBuffs.SV.GroundDamageAura and "Enabled" or "Disabled"))
    LUIE.SpellCastBuffs.ReloadEffects("player")
end

--- Outputs current zone and map information to chat.
--- Retrieves and displays:
--- - Zone ID and location name
--- - Map ID and index
--- - Map name, type, content type
--- - Zone index and description
--- - GPS coordinates for player
function SpellCastBuffs.TempSlashZoneCheck()
    local info = CollectZoneMapInfo()

    local displayInfo =
    {
        { "--------------------"                                                                                                                             },
        { "ZONE & MAP INFO:"                                                                                                                                 },
        { "--------------------"                                                                                                                             },
        { "Zone Id:",            info.zoneid                                                                                                                 },
        { "Location Name:",      info.locName                                                                                                                },
        { "--------------------"                                                                                                                             },
        { "Map Id:",             info.mapid                                                                                                                  },
        { "Map Index:",          info.mapindex or "nil"                                                                                                      },
        { "--------------------"                                                                                                                             },
        { "GPS Coordinates:"                                                                                                                                 },
        { "Map:",                string_format("%s: %s" .. LUIE_TINY_X_FORMATTER .. "%s", info.mapName, FormatCoords(info.mapX), FormatCoords(info.mapY))    },
        { "Zone:",               string_format("%s: %s" .. LUIE_TINY_X_FORMATTER .. "%s", info.zoneName, FormatCoords(info.zoneX), FormatCoords(info.zoneY)) },
        { "World:",              string_format("Tamriel: %s" .. LUIE_TINY_X_FORMATTER .. "%s", FormatCoords(info.worldX), FormatCoords(info.worldY))         },
        { "--------------------"                                                                                                                             },
        { "Map Name:",           info.name                                                                                                                   },
        { "Map Type:",           info.mapType                                                                                                                },
        { "Map Content Type:",   info.mapContentType                                                                                                         },
        { "Zone Index:",         info.zoneIndex                                                                                                              },
        { "Description:",        info.description                                                                                                            },
        { "--------------------"                                                                                                                             },
    }

    for _, v in ipairs(displayInfo) do
        AddSystemMessage(#v == 1 and v[1] or string_format("%s %s", v[1], v[2]))
    end
end

--- Checks for removed abilities by iterating through LuiData.Data.DebugAuras and checking if each ability still exists.
--- Outputs a list of ability IDs that no longer exist in the game to chat.
function SpellCastBuffs.TempSlashCheckRemovedAbilities()
    AddSystemMessage("Removed AbilityIds:")
    for abilityId in pairs(DebugAuras) do
        if not DoesAbilityExist(abilityId) then
            AddSystemMessage(tostring(abilityId))
        end
    end
end

-- -----------------------------------------------------------------------------
-- Slash Commands Registration
-- -----------------------------------------------------------------------------

-- Slash command mapping
local DEBUG_COMMANDS =
{
    ["/filter"] = SpellCastBuffs.TempSlashFilter,
    ["/ground"] = SpellCastBuffs.TempSlashGround,
    ["/zonecheck"] = SpellCastBuffs.TempSlashZoneCheck,
    ["/abilitydump"] = SpellCastBuffs.TempSlashCheckRemovedAbilities,
}

--- Initializes debug slash commands
--- These commands are only available when developer debug mode is enabled
if LUIE.IsDevDebugEnabled() then
    for command, handler in pairs(DEBUG_COMMANDS) do
        SLASH_COMMANDS[command] = handler
    end
end
-- -----------------------------------------------------------------------------
