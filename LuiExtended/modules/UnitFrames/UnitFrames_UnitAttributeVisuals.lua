-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class (partial) UnitFrames
local UnitFrames = LUIE.UnitFrames

local eventManager = GetEventManager()
local windowManager = GetWindowManager()

-- -----------------------------------------------------------------------------

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
-- Runs on the EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED listener.
---
--- @param eventId integer
--- @param unitTag string
--- @param unitAttributeVisual UnitAttributeVisual
--- @param statType DerivedStats
--- @param attributeType Attributes
--- @param powerType CombatMechanicFlags
--- @param value number
--- @param maxValue number
--- @param sequenceId integer
function UnitFrames.OnVisualizationAdded(eventId, unitTag, unitAttributeVisual, statType, attributeType, powerType, value, maxValue, sequenceId)
    if unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING then
        UnitFrames.UpdateShield(unitTag, value, maxValue)
    elseif unitAttributeVisual == ATTRIBUTE_VISUAL_TRAUMA then
        UnitFrames.UpdateTrauma(unitTag, value, maxValue)
    elseif unitAttributeVisual == ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER or unitAttributeVisual == ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER then
        UnitFrames.UpdateRegen(unitTag, statType, attributeType, powerType)
    elseif unitAttributeVisual == ATTRIBUTE_VISUAL_INCREASED_STAT or unitAttributeVisual == ATTRIBUTE_VISUAL_DECREASED_STAT then
        UnitFrames.UpdateStat(unitTag, statType, attributeType, powerType)
    elseif unitAttributeVisual == ATTRIBUTE_VISUAL_UNWAVERING_POWER then
        UnitFrames.UpdateInvulnerable(unitTag)
    end
end

-- -----------------------------------------------------------------------------
-- Runs on the EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED listener.
---
--- @param eventId integer
--- @param unitTag string
--- @param unitAttributeVisual UnitAttributeVisual
--- @param statType DerivedStats
--- @param attributeType Attributes
--- @param powerType CombatMechanicFlags
--- @param value number
--- @param maxValue number
--- @param sequenceId integer
function UnitFrames.OnVisualizationRemoved(eventId, unitTag, unitAttributeVisual, statType, attributeType, powerType, value, maxValue, sequenceId)
    if unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING then
        UnitFrames.UpdateShield(unitTag, 0, maxValue)
    elseif unitAttributeVisual == ATTRIBUTE_VISUAL_TRAUMA then
        UnitFrames.UpdateTrauma(unitTag, 0, maxValue)
    elseif unitAttributeVisual == ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER or unitAttributeVisual == ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER then
        UnitFrames.UpdateRegen(unitTag, statType, attributeType, powerType)
    elseif unitAttributeVisual == ATTRIBUTE_VISUAL_INCREASED_STAT or unitAttributeVisual == ATTRIBUTE_VISUAL_DECREASED_STAT then
        UnitFrames.UpdateStat(unitTag, statType, attributeType, powerType)
    elseif unitAttributeVisual == ATTRIBUTE_VISUAL_UNWAVERING_POWER then
        UnitFrames.UpdateInvulnerable(unitTag)
    end
end

-- -----------------------------------------------------------------------------
-- Runs on the EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED listener.
---
--- @param eventId integer
--- @param unitTag string
--- @param unitAttributeVisual UnitAttributeVisual
--- @param statType DerivedStats
--- @param attributeType Attributes
--- @param powerType CombatMechanicFlags
--- @param oldValue number
--- @param newValue number
--- @param oldMaxValue number
--- @param newMaxValue number
--- @param sequenceId integer
function UnitFrames.OnVisualizationUpdated(eventId, unitTag, unitAttributeVisual, statType, attributeType, powerType, oldValue, newValue, oldMaxValue, newMaxValue, sequenceId)
    if unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING then
        UnitFrames.UpdateShield(unitTag, newValue, newMaxValue)
    elseif unitAttributeVisual == ATTRIBUTE_VISUAL_TRAUMA then
        UnitFrames.UpdateTrauma(unitTag, newValue, newMaxValue)
    elseif unitAttributeVisual == ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER or unitAttributeVisual == ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER then
        UnitFrames.UpdateRegen(unitTag, statType, attributeType, powerType)
    elseif unitAttributeVisual == ATTRIBUTE_VISUAL_INCREASED_STAT or unitAttributeVisual == ATTRIBUTE_VISUAL_DECREASED_STAT then
        UnitFrames.UpdateStat(unitTag, statType, attributeType, powerType)
    elseif unitAttributeVisual == ATTRIBUTE_VISUAL_UNWAVERING_POWER then
        UnitFrames.UpdateInvulnerable(unitTag)
    end
end

-- -----------------------------------------------------------------------------
-- Updates Invulnerable Overlay for given unit.
-- Called from EVENT_UNIT_ATTRIBUTE_VISUAL_* listeners.
---
--- @param unitTag string
function UnitFrames.UpdateInvulnerable(unitTag)
    if g_savedHealth[unitTag] == nil then
        -- if LUIE.IsDevDebugEnabled() then
        --     LUIE.Debug("LUIE DEBUG: Stored health is nil: ", unitTag)
        -- end
        return
    end

    local healthValue, _, healthEffectiveMax, _ = unpack(g_savedHealth[unitTag])
    -- Update frames
    if g_DefaultFrames[unitTag] then
        UnitFrames.UpdateAttribute(unitTag, COMBAT_MECHANIC_FLAGS_HEALTH, g_DefaultFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH], healthValue, healthEffectiveMax, false, false)
    end
    if UnitFrames.CustomFrames[unitTag] then
        UnitFrames.UpdateAttribute(unitTag, COMBAT_MECHANIC_FLAGS_HEALTH, UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH], healthValue, healthEffectiveMax, false, false)
    end
    if g_AvaCustFrames[unitTag] then
        UnitFrames.UpdateAttribute(unitTag, COMBAT_MECHANIC_FLAGS_HEALTH, g_AvaCustFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH], healthValue, healthEffectiveMax, false, false)
    end
end

-- Updates shield value for given unit.1
-- Called from EVENT_UNIT_ATTRIBUTE_VISUAL_* listeners.
--- @param unitTag string
--- @param value number
--- @param maxValue number
function UnitFrames.UpdateShield(unitTag, value, maxValue)
    if g_savedHealth[unitTag] == nil then
        -- if LUIE.IsDevDebugEnabled() then
        --     LUIE.Debug("LUIE DEBUG: Stored health is nil: ", unitTag, " | Shield Value: ", value, " | Shield Max: ", maxValue)
        -- end
        return
    end

    g_savedHealth[unitTag][4] = value

    local healthValue, _, healthEffectiveMax, _ = unpack(g_savedHealth[unitTag])
    -- Update frames
    if g_DefaultFrames[unitTag] then
        UnitFrames.UpdateAttribute(unitTag, COMBAT_MECHANIC_FLAGS_HEALTH, g_DefaultFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH], healthValue, healthEffectiveMax, false, false)
        UnitFrames.UpdateShieldBar(g_DefaultFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH], value, healthEffectiveMax)
    end
    if UnitFrames.CustomFrames[unitTag] then
        UnitFrames.UpdateAttribute(unitTag, COMBAT_MECHANIC_FLAGS_HEALTH, UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH], healthValue, healthEffectiveMax, false, false)
        UnitFrames.UpdateShieldBar(UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH], value, healthEffectiveMax)
    end
    if g_AvaCustFrames[unitTag] then
        UnitFrames.UpdateAttribute(unitTag, COMBAT_MECHANIC_FLAGS_HEALTH, g_AvaCustFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH], healthValue, healthEffectiveMax, false, false)
        UnitFrames.UpdateShieldBar(g_AvaCustFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH], value, healthEffectiveMax)
    end
end

-- Updates trauma value for given unit.
-- Called from EVENT_UNIT_ATTRIBUTE_VISUAL_* listeners.
--- @param unitTag string
--- @param value number
--- @param maxValue number
function UnitFrames.UpdateTrauma(unitTag, value, maxValue)
    if g_savedHealth[unitTag] == nil then
        return
    end

    g_savedHealth[unitTag][5] = value

    local healthValue, _, healthEffectiveMax, _ = unpack(g_savedHealth[unitTag])
    -- Update frames
    if g_DefaultFrames[unitTag] then
        UnitFrames.UpdateAttribute(unitTag, COMBAT_MECHANIC_FLAGS_HEALTH, g_DefaultFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH], healthValue, healthEffectiveMax, true, false)
        UnitFrames.UpdateTraumaBar(g_DefaultFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH], value, healthValue, healthEffectiveMax)
    end
    if UnitFrames.CustomFrames[unitTag] then
        UnitFrames.UpdateAttribute(unitTag, COMBAT_MECHANIC_FLAGS_HEALTH, UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH], healthValue, healthEffectiveMax, true, false)
        UnitFrames.UpdateTraumaBar(UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH], value, healthValue, healthEffectiveMax)
    end
    if g_AvaCustFrames[unitTag] then
        UnitFrames.UpdateAttribute(unitTag, COMBAT_MECHANIC_FLAGS_HEALTH, g_AvaCustFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH], healthValue, healthEffectiveMax, true, false)
        UnitFrames.UpdateTraumaBar(g_AvaCustFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH], value, healthValue, healthEffectiveMax)
    end
end

-- Here actual update of shield bar on attribute is done
---
--- @param attributeFrame table|{shield:StatusBarControl,shieldbackdrop:BackdropControl}
--- @param shieldValue number
--- @param healthEffectiveMax number
function UnitFrames.UpdateShieldBar(attributeFrame, shieldValue, healthEffectiveMax)
    if attributeFrame == nil or attributeFrame.shield == nil then
        return
    end

    local hideShield = not (shieldValue > 0)

    if hideShield then
        attributeFrame.shield:SetValue(0)
    else
        if UnitFrames.SV.CustomSmoothBar then
            -- Make it twice faster then default UI ones: last argument .085
            ZO_StatusBar_SmoothTransition(attributeFrame.shield, shieldValue, healthEffectiveMax, false, nil, 250)
        else
            attributeFrame.shield:SetMinMax(0, healthEffectiveMax)
            attributeFrame.shield:SetValue(shieldValue)
        end
    end

    attributeFrame.shield:SetHidden(hideShield)
    if attributeFrame.shieldbackdrop then
        attributeFrame.shieldbackdrop:SetHidden(hideShield)
    end
end

-- Here actual update of trauma bar on attribute is done
---
--- @param attributeFrame table|{trauma:StatusBarControl}
--- @param traumaValue number
--- @param healthValue number
--- @param healthEffectiveMax number
function UnitFrames.UpdateTraumaBar(attributeFrame, traumaValue, healthValue, healthEffectiveMax)
    if attributeFrame == nil or attributeFrame.trauma == nil then
        return
    end

    local hideTrauma = not (traumaValue > 0)

    if hideTrauma then
        attributeFrame.trauma:SetValue(0)
    else
        -- We don't use a smooth bar transition here - this immediately replaces the HP bar and the HP value smooth transitions
        attributeFrame.trauma:SetMinMax(0, healthEffectiveMax)
        attributeFrame.trauma:SetValue(healthValue)
    end

    attributeFrame.trauma:SetHidden(hideTrauma)
end

-- Reroutes call for regen/degen animation for given unit.
-- Called from EVENT_UNIT_ATTRIBUTE_VISUAL_* listeners.
--- @param unitTag string
--- @param statType DerivedStats
--- @param attributeType Attributes
--- @param powerType CombatMechanicFlags
function UnitFrames.UpdateRegen(unitTag, statType, attributeType, powerType)
    if powerType ~= COMBAT_MECHANIC_FLAGS_HEALTH then
        return
    end

    -- Calculate actual value, and fallback to 0 if we call this function with nil parameters
    local value1 = (GetUnitAttributeVisualizerEffectInfo(unitTag, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, statType, attributeType, powerType) or 0)
    local value2 = (GetUnitAttributeVisualizerEffectInfo(unitTag, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, statType, attributeType, powerType) or 0)
    if value1 < 0 then
        value1 = 1
    end
    if value2 > 0 then
        value2 = -1
    end
    local value = value1 + value2

    -- Here we assume, that every unitTag entry in tables has COMBAT_MECHANIC_FLAGS_HEALTH key
    if g_DefaultFrames[unitTag] and g_DefaultFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH] then
        UnitFrames.DisplayRegen(g_DefaultFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].regen1, value > 0)
        UnitFrames.DisplayRegen(g_DefaultFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].regen2, value > 0)
        UnitFrames.DisplayRegen(g_DefaultFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].degen1, value < 0)
        UnitFrames.DisplayRegen(g_DefaultFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].degen2, value < 0)
    end
    if UnitFrames.CustomFrames[unitTag] and UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH] then
        UnitFrames.DisplayRegen(UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].regen1, value > 0)
        UnitFrames.DisplayRegen(UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].regen2, value > 0)
        UnitFrames.DisplayRegen(UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].degen1, value < 0)
        UnitFrames.DisplayRegen(UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].degen2, value < 0)
    end
    if g_AvaCustFrames[unitTag] and g_AvaCustFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH] then
        UnitFrames.DisplayRegen(g_AvaCustFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].regen1, value > 0)
        UnitFrames.DisplayRegen(g_AvaCustFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].regen2, value > 0)
        UnitFrames.DisplayRegen(g_AvaCustFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].degen1, value < 0)
        UnitFrames.DisplayRegen(g_AvaCustFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].degen2, value < 0)
    end
end

-- Performs actual display of animation control if any
---
--- @param control {animation:AnimationObject, timeline:AnimationTimeline}|object
--- @param isShown boolean
function UnitFrames.DisplayRegen(control, isShown)
    if control == nil then
        return
    end

    control:SetHidden(not isShown)
    if isShown then
        -- We restart the animation here only if its not already playing (prevents sharp fades mid-animation)
        if control.animation:IsPlaying() then
            return
        end
        control.timeline:SetPlaybackType(ANIMATION_PLAYBACK_LOOP, LOOP_INDEFINITELY)
        control.timeline:PlayFromStart()
    else
        control.timeline:SetPlaybackLoopsRemaining(0)
    end
end

-- Updates decreasedArmor texture for given unit.
-- While this applicable only to custom frames, we do not need to split this function into 2 different ones
-- Called from EVENT_UNIT_ATTRIBUTE_VISUAL_* listeners.
--- @param unitTag string
--- @param statType DerivedStats
--- @param attributeType Attributes
--- @param powerType CombatMechanicFlags
function UnitFrames.UpdateStat(unitTag, statType, attributeType, powerType)
    -- Build a list of UI controls to hold this statType on different UnitFrames lists
    local statControls = {}

    if UnitFrames.CustomFrames[unitTag] and UnitFrames.CustomFrames[unitTag][powerType] and UnitFrames.CustomFrames[unitTag][powerType].stat and UnitFrames.CustomFrames[unitTag][powerType].stat[statType] then
        table.insert(statControls, UnitFrames.CustomFrames[unitTag][powerType].stat[statType])
    end
    if g_AvaCustFrames[unitTag] and g_AvaCustFrames[unitTag][powerType] and g_AvaCustFrames[unitTag][powerType].stat and g_AvaCustFrames[unitTag][powerType].stat[statType] then
        table.insert(statControls, g_AvaCustFrames[unitTag][powerType].stat[statType])
    end

    -- If we have a control, proceed next
    if #statControls > 0 then
        -- Calculate actual value, and fallback to 0 if we call this function with nil parameters
        local value = (GetUnitAttributeVisualizerEffectInfo(unitTag, ATTRIBUTE_VISUAL_INCREASED_STAT, statType, attributeType, powerType) or 0) + (GetUnitAttributeVisualizerEffectInfo(unitTag, ATTRIBUTE_VISUAL_DECREASED_STAT, statType, attributeType, powerType) or 0)

        for _, control in pairs(statControls) do
            -- Hide proper controls if they exist
            if control.dec then
                control.dec:SetHidden(value >= 0)
            end
            if control.inc then
                control.inc:SetHidden(value <= 0)
            end
        end
    end
end

return UnitFrames
