-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class (partial) CombatTextEventListener : ZO_CallbackObject
local CombatTextEventListener = ZO_CallbackObject:Subclass()

local eventManager = GetEventManager()

local moduleName = LUIE.name .. "CombatText"

--- @type integer
local eventPostfix = 1 -- Used to create unique name when registering multiple times to the same game event

--- @return CombatTextEventListener
function CombatTextEventListener:New()
    --- @class CombatTextEventListener
    local obj = setmetatable({}, self)
    return obj
end

--- @param event integer
--- @param callback function
--- @param ... any a list of event filters in format filterType1, filterArg1, filterType2, filterArg2, etc.
function CombatTextEventListener:RegisterForEvent(event, callback, ...)
    eventManager:RegisterForEvent("LUIE_CombatText_EVENT_" .. tostring(event) .. "_" .. tostring(eventPostfix), event, function (eventCode, ...)
        callback(...)
    end)

    -- vararg ... is a list of event filters in format filterType1, filterArg1, filterType2, filterArg2, etc.
    -- example: obj:RegisterForEvent(EVENT_POWER_UPDATE, func, REGISTER_FILTER_UNIT_TAG, 'player', REGISTER_FILTER_POWER_TYPE, POWERTYPE_ULTIMATE)
    local filtersCount = select("#", ...)
    local filters = filtersCount > 0 and { ... }
    for i = 1, filtersCount, 2 do
        eventManager:AddFilterForEvent("LUIE_CombatText_EVENT_" .. tostring(event) .. "_" .. tostring(eventPostfix), event, filters[i], filters[i + 1])
    end

    eventPostfix = eventPostfix + 1
end

--- @param name string
--- @param minInterval integer
--- @param callback function
function CombatTextEventListener:RegisterForUpdate(name, minInterval, callback)
    eventManager:RegisterForUpdate("LUIE_CombatText_EVENT_" .. name .. "_" .. tostring(eventPostfix), minInterval, callback)
end

--- @param ... any
function CombatTextEventListener:TriggerEvent(...)
    LUIE:FireCallbacks(...)
end

--- @class (partial) CombatTextEventListener
LUIE.CombatTextEventListener = CombatTextEventListener
