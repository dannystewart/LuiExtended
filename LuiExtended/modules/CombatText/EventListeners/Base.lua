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
    local obj = setmetatable({}, self)
    return obj
end

--- @param event any
--- @param func fun(...)
--- @param ... any
function CombatTextEventListener:RegisterForEvent(event, func, ...)
    eventManager:RegisterForEvent("LUIE_CombatText_EVENT_" .. event .. "_" .. eventPostfix, event, function (eventCode, ...)
        func(...)
    end)

    -- vararg ... is a list of event filters in format filterType1, filterArg1, filterType2, filterArg2, etc.
    -- example: obj:RegisterForEvent(EVENT_POWER_UPDATE, func, REGISTER_FILTER_UNIT_TAG, 'player', REGISTER_FILTER_POWER_TYPE, POWERTYPE_ULTIMATE)
    local filtersCount = select("#", ...)
    local filters = filtersCount > 0 and { ... }
    for i = 1, filtersCount, 2 do
        eventManager:AddFilterForEvent("LUIE_CombatText_EVENT_" .. event .. "_" .. eventPostfix, event, filters[i], filters[i + 1])
    end

    eventPostfix = eventPostfix + 1
end

--- @param name any
--- @param timer any
--- @param func fun(...)
--- @param ... any
function CombatTextEventListener:RegisterForUpdate(name, timer, func, ...)
    eventManager:RegisterForUpdate("LUIE_CombatText_EVENT_" .. name .. "_" .. eventPostfix, timer, func)
end

--- @param ... any
function CombatTextEventListener:TriggerEvent(...)
    LUIE:FireCallbacks(...)
end

--- @class (partial) CombatTextEventListener
LUIE.CombatTextEventListener = CombatTextEventListener
