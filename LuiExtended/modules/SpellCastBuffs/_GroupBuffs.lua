-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

-- SpellCastBuffs namespace
--- @class (partial) LUIE.SpellCastBuffs
local SpellCastBuffs = LUIE.SpellCastBuffs

local UI = LUIE.UI
local string_format = string.format
local table_insert = table.insert
local table_sort = table.sort
local eventManager = GetEventManager()

-- Default tracked buffs
SpellCastBuffs.DefaultGroupBuffs =
{
    -- Stuff
    [61771] = true,  -- Power Aura
    [93109] = true,  -- Slayer
    [109966] = true, -- Courage
    [163401] = true, -- Spaulder
    [172055] = true, -- Pill
    [151032] = true, -- Encratis

    -- Special
    [61665] = true,  -- Inner Wrath
    [61694] = true,  -- Reckless
    [61745] = true,  -- Berserk
    [147417] = true, -- Combat Prayer

    -- Jobs
    [61506] = true,  -- Ardent Flame
    [40079] = true,  -- Regeneration
    [217460] = true, -- Elemental Harmony
    [217608] = true, -- Spell Power
    [61693] = true,  -- Power of the Light
    [61747] = true,  -- Force Move
}

-- Default tracked debuffs
SpellCastBuffs.DefaultGroupDebuffs =
{
    -- Major Debuffs
    [178118] = true, -- Status Effect Magic (Overcharged)
    [95136] = true,  -- Status Effect Frost (Chill)
    [95134] = true,  -- Status Effect Lightning (Concussion)
    [178123] = true, -- Status Effect Physical (Sundered)
    [178127] = true, -- Status Effect Foulness (Diseased)
    [148801] = true, -- Status Effect Bleeding (Hemorrhaging)

    -- Minor Debuffs
    [120007] = true, -- Crusher
    [120011] = true, -- Engulfing Flames
    [120018] = true, -- Roar of Alkosh
    [17906] = true,  -- Crusher (Glyph of Crushing)
    [17945] = true,  -- Weakening (Glyph of Weakening)
}

-- Bugged long duration buffs that need special handling
SpellCastBuffs.BuggedLongDuration =
{
    [147417] = true, -- Combat Prayer
}

-- Create a buff icon for a unit frame
---
--- @param parent Control|TopLevelWindow
--- @param lastIcon any
--- @param index any
--- @return table|TextureControl
local function CreateBuffIcon(parent, lastIcon, index)
    local iconSize = SpellCastBuffs.SV.GroupBuffIconSize or 24
    local icon = UI:Texture(parent, { LEFT, LEFT }, { iconSize, iconSize }, nil, DL_OVERLAY, false)

    if lastIcon then
        icon:SetAnchor(LEFT, lastIcon, RIGHT, SpellCastBuffs.SV.GroupBuffIconOffset or 5, 0)
    else
        icon:SetAnchor(LEFT, parent, LEFT, SpellCastBuffs.SV.GroupBuffStartX or 75, SpellCastBuffs.SV.GroupBuffStartY or 0)
    end

    -- Add timer label
    local label = UI:Label(icon, { CENTER, CENTER }, nil, { 0, 0 }, string_format("$(BOLD_FONT)|%d|soft-shadow-thick", SpellCastBuffs.SV.GroupBuffTimerSize or 16), "", false)
    local r, g, b, a = unpack(SpellCastBuffs.SV.GroupBuffTimerColor or { 1, 1, 1, 1 })
    label:SetColor(r, g, b, a)
    label:SetDrawLayer(DL_OVERLAY)
    label:SetDrawTier(DT_HIGH)
    label:SetDrawLevel(2)
    label:SetHidden(false)
    label:SetText("")

    icon.timerLabel = label
    icon.expirationTime = nil

    return icon
end

-- Get unit frame from our custom frames
--- @param unitTag string
--- @return TopLevelWindow|Control|nil
local function GetUnitFrame(unitTag)
    local customFrames = LUIE.UnitFrames.CustomFrames
    if customFrames[unitTag] then
        local control = customFrames[unitTag].control
        if control then
            return control
        end
    end
    return nil
end

-- Helper to reposition buff icons in a tight row
local function RepositionBuffIcons(unitFrame)
    local keys = {}
    for id in pairs(unitFrame.buffIconsById) do
        table_insert(keys, id)
    end
    table_sort(keys)

    local lastIcon = nil
    for _, id in ipairs(keys) do
        local bufficon = unitFrame.buffIconsById[id]
        if bufficon and not bufficon:IsHidden() then
            bufficon:ClearAnchors()
            if lastIcon then
                bufficon:SetAnchor(LEFT, lastIcon, RIGHT, SpellCastBuffs.SV.GroupBuffIconOffset or 5, 0)
            else
                bufficon:SetAnchor(LEFT, unitFrame, LEFT, SpellCastBuffs.SV.GroupBuffStartX or 75, SpellCastBuffs.SV.GroupBuffStartY or 0)
            end
            lastIcon = bufficon
        end
    end
end

-- Handle effect changes for group buffs
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
function SpellCastBuffs.OnGroupEffectChanged(eventId, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, deprecatedBuffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
    -- Check if we should track this effect
    local shouldTrack = false
    if effectType == BUFF_EFFECT_TYPE_BUFF and SpellCastBuffs.SV.GroupTrackedBuffs[abilityId] then
        shouldTrack = true
    elseif effectType == BUFF_EFFECT_TYPE_DEBUFF and SpellCastBuffs.SV.GroupTrackedDebuffs[abilityId] then
        shouldTrack = true
    end
    if not shouldTrack then return end

    local unitFrame = GetUnitFrame(unitTag)
    if not unitFrame then return end

    unitFrame.buffIconsById = unitFrame.buffIconsById or {}

    if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then
        -- Skip if duration is 0 and not a bugged long duration buff
        if (not endTime or endTime == 0 or endTime == beginTime) and not SpellCastBuffs.BuggedLongDuration[abilityId] then
            return
        end

        local icon = unitFrame.buffIconsById[abilityId]
        if not icon then
            icon = CreateBuffIcon(unitFrame)
            unitFrame.buffIconsById[abilityId] = icon
        end

        icon:SetTexture(iconName)
        icon:SetHidden(false)

        -- Handle duration
        if SpellCastBuffs.BuggedLongDuration[abilityId] then
            if endTime and endTime > beginTime then
                icon.expirationTime = GetFrameTimeSeconds() + (endTime - beginTime)
            else
                icon.expirationTime = math.huge
            end
        else
            if endTime > 1000000 then endTime = endTime / 1000 end
            icon.expirationTime = GetFrameTimeSeconds() + (endTime - beginTime)
        end

        icon.timerLabel:SetHidden(false)

        -- Reposition icons
        RepositionBuffIcons(unitFrame)
    elseif changeType == EFFECT_RESULT_FADED then
        local icon = unitFrame.buffIconsById[abilityId]
        if icon then
            local now = GetFrameTimeSeconds()

            if abilityId == 93109 and icon.expirationTime and icon.expirationTime > now then
                return
            end
            if icon.expirationTime == math.huge or (icon.expirationTime and icon.expirationTime > now) then
                icon:SetHidden(true)
                icon.timerLabel:SetHidden(true)
                unitFrame.buffIconsById[abilityId] = nil
                -- Reposition icons after removal
                RepositionBuffIcons(unitFrame)
                return
            end
        end
    end
end

-- Update group buff timers
function SpellCastBuffs.UpdateGroupBuffs()
    local now = GetFrameTimeSeconds()

    for i = 1, GetGroupSize() do
        local unitTag = GetGroupUnitTagByIndex(i)
        if DoesUnitExist(unitTag) then
            local unitFrame = GetUnitFrame(unitTag)
            if unitFrame and unitFrame.buffIconsById then
                local repositionNeeded = false
                for _, icon in pairs(unitFrame.buffIconsById) do
                    if not icon:IsHidden() and icon.expirationTime then
                        if icon.expirationTime == math.huge then
                            icon.timerLabel:SetText("∞")
                            icon.timerLabel:SetHidden(false)
                        else
                            local remaining = icon.expirationTime - now
                            if remaining <= 0 then
                                icon:SetHidden(true)
                                icon.timerLabel:SetHidden(true)
                                repositionNeeded = true
                            else
                                icon.timerLabel:SetText(string_format("%.0f", remaining))
                                icon.timerLabel:SetHidden(false)
                            end
                        end
                    end
                end
                if repositionNeeded then
                    RepositionBuffIcons(unitFrame)
                end
            end
        end
    end
end

-- Initialize group buff tracking
function SpellCastBuffs.InitializeGroupBuffs()
    -- Initialize tracked buffs and debuffs from saved vars
    SpellCastBuffs.SV.GroupTrackedBuffs = SpellCastBuffs.SV.GroupTrackedBuffs or {}
    SpellCastBuffs.SV.GroupTrackedDebuffs = SpellCastBuffs.SV.GroupTrackedDebuffs or {}

    -- Set defaults for any new buffs
    for buffId, _ in pairs(SpellCastBuffs.DefaultGroupBuffs) do
        if SpellCastBuffs.SV.GroupTrackedBuffs[buffId] == nil then
            SpellCastBuffs.SV.GroupTrackedBuffs[buffId] = true
        end
    end

    -- Set defaults for any new debuffs
    for debuffId, _ in pairs(SpellCastBuffs.DefaultGroupDebuffs) do
        if SpellCastBuffs.SV.GroupTrackedDebuffs[debuffId] == nil then
            SpellCastBuffs.SV.GroupTrackedDebuffs[debuffId] = true
        end
    end

    -- Register event handlers
    eventManager:RegisterForEvent("LuiExtendedSpellCastBuffsGroupBuffs", EVENT_EFFECT_CHANGED, SpellCastBuffs.OnGroupEffectChanged)
    eventManager:AddFilterForEvent("LuiExtendedSpellCastBuffsGroupBuffs", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
    eventManager:RegisterForUpdate("LuiExtendedSpellCastBuffsGroupBuffsUpdate", 1000, SpellCastBuffs.UpdateGroupBuffs)

    -- Force an initial update of all group members
    for i = 1, GetGroupSize() do
        local unitTag = GetGroupUnitTagByIndex(i)
        if DoesUnitExist(unitTag) then
            SpellCastBuffs.OnGroupEffectChanged(EVENT_EFFECT_CHANGED, EFFECT_RESULT_GAINED, 0, "", unitTag, 0, 0, 0, "", "", 0, 0, 0, "", 0, 0, 0)
        end
    end
end
