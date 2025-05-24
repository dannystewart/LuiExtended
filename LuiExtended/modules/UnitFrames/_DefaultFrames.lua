-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
local UI = LUIE.UI

-- Unit Frames namespace
--- @class (partial) UnitFrames
local UnitFrames = LUIE.UnitFrames

local pairs = pairs
local eventManager = GetEventManager()


local defaultPos = {}



-- Following settings will be used in options menu to define DefaultFrames behaviour
-- TODO: localization
local g_DefaultFramesOptions =
{
    [1] = "Disable",                             -- false
    [2] = "Do nothing (keep default)",           -- nil
    [3] = "Use Extender (display text overlay)", -- true
}

-- A function to extract the anchor information
--- @param frame Control
--- @return {point:AnchorPosition,relativeTo:object,relativePoint:AnchorPosition,offsetX:number,offsetY:number }|nil
local function GetAnchorInfo(frame)
    local anchorIndex = 1
    local isValidAnchor, point, relativeTo, relativePoint, offsetX, offsetY = frame:GetAnchor(anchorIndex)
    if not isValidAnchor then
        return
    end
    return { point, relativeTo, relativePoint, offsetX, offsetY }
end

-- Save default frame positions
function UnitFrames.SaveDefaultFramePositions()
    -- Get Default Positions
    defaultPos.health = GetAnchorInfo(ZO_PlayerAttributeHealth)
    defaultPos.magicka = GetAnchorInfo(ZO_PlayerAttributeMagicka)
    defaultPos.stamina = GetAnchorInfo(ZO_PlayerAttributeStamina)
    defaultPos.siege = GetAnchorInfo(ZO_PlayerAttributeSiegeHealth)
    defaultPos.ram = GetAnchorInfo(ZO_RAM.control)
    defaultPos.smallGroup = GetAnchorInfo(ZO_SmallGroupAnchorFrame)
end

-- Adjust default frame position.
function UnitFrames.RepositionDefaultFrames()
    if not UnitFrames.SV.RepositionFrames then
        if defaultPos.health then
            ZO_PlayerAttributeHealth:ClearAnchors()
            ZO_PlayerAttributeHealth:SetAnchor(defaultPos.health[1], defaultPos.health[2], defaultPos.health[3], defaultPos.health[4], defaultPos.health[5] - UnitFrames.SV.RepositionFramesAdjust)
            ZO_PlayerAttributeMagicka:ClearAnchors()
            ZO_PlayerAttributeMagicka:SetAnchor(defaultPos.magicka[1], defaultPos.magicka[2], defaultPos.magicka[3], defaultPos.magicka[4], defaultPos.magicka[5] - UnitFrames.SV.RepositionFramesAdjust)
            ZO_PlayerAttributeStamina:ClearAnchors()
            ZO_PlayerAttributeStamina:SetAnchor(defaultPos.stamina[1], defaultPos.stamina[2], defaultPos.stamina[3], defaultPos.stamina[4], defaultPos.stamina[5] - UnitFrames.SV.RepositionFramesAdjust)
            ZO_PlayerAttributeSiegeHealth:ClearAnchors()
            ZO_PlayerAttributeSiegeHealth:SetAnchor(defaultPos.siege[1], defaultPos.siege[2], defaultPos.siege[3], defaultPos.siege[4], defaultPos.siege[5] - UnitFrames.SV.RepositionFramesAdjust)
            ZO_RAM.control:ClearAnchors()
            ZO_RAM.control:SetAnchor(defaultPos.ram[1], defaultPos.ram[2], defaultPos.ram[3], defaultPos.ram[4], defaultPos.ram[5] - UnitFrames.SV.RepositionFramesAdjust)
            ZO_SmallGroupAnchorFrame:ClearAnchors()
            ZO_SmallGroupAnchorFrame:SetAnchor(defaultPos.smallGroup[1], defaultPos.smallGroup[2], defaultPos.smallGroup[3], defaultPos.smallGroup[4], defaultPos.smallGroup[5] - UnitFrames.SV.RepositionFramesAdjust)
        end
    end

    -- Reposition frames
    if UnitFrames.SV.RepositionFrames then
        -- Shift to center magicka and stamina bars
        ZO_PlayerAttributeHealth:ClearAnchors()
        ZO_PlayerAttributeHealth:SetAnchor(BOTTOM, ActionButton5, TOP, 0, -47 - UnitFrames.SV.RepositionFramesAdjust)
        ZO_PlayerAttributeMagicka:ClearAnchors()
        ZO_PlayerAttributeMagicka:SetAnchor(TOPRIGHT, ZO_PlayerAttributeHealth, BOTTOM, -1, 2)
        ZO_PlayerAttributeStamina:ClearAnchors()
        ZO_PlayerAttributeStamina:SetAnchor(TOPLEFT, ZO_PlayerAttributeHealth, BOTTOM, 1, 2)
        -- Shift to the right siege weapon health and ram control
        ZO_PlayerAttributeSiegeHealth:ClearAnchors()
        ZO_PlayerAttributeSiegeHealth:SetAnchor(CENTER, ZO_PlayerAttributeHealth, CENTER, 300, 0)
        ZO_RAM.control:ClearAnchors()
        ZO_RAM.control:SetAnchor(BOTTOM, ZO_PlayerAttributeHealth, TOP, 300, 0)
        -- Shift a little upwards small group unit frames
        ZO_SmallGroupAnchorFrame:ClearAnchors()
        ZO_SmallGroupAnchorFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 20, 80) -- default is 28,100
    end
end

function UnitFrames.GetDefaultFramesOptions(frame)
    local retval = {}
    for k, v in pairs(g_DefaultFramesOptions) do
        if not (frame == "Boss" and k == 3) then
            table.insert(retval, v)
        end
    end
    return retval
end

function UnitFrames.SetDefaultFramesSetting(frame, value)
    local key = "DefaultFramesNew" .. tostring(frame)
    if value == g_DefaultFramesOptions[3] then
        SetSetting(SETTING_TYPE_UI, UI_SETTING_RESOURCE_NUMBERS, 0, SETTINGS_SET_OPTION_SAVE_TO_PERSISTED_DATA)
        UnitFrames.SV[key] = 3
    elseif value == g_DefaultFramesOptions[2] then
        UnitFrames.SV[key] = 2
    else
        UnitFrames.SV[key] = 1
    end
end

function UnitFrames.GetDefaultFramesSetting(frame, default)
    local key = "DefaultFramesNew" .. tostring(frame)
    local from = default and UnitFrames.Defaults or UnitFrames.SV
    local value = from[key]
    return g_DefaultFramesOptions[value]
end

-- Used to create default frames extender controls for player and target.
-- Called from UnitFrames.Initialize
function UnitFrames.CreateDefaultFrames()
    -- Create text overlay for default unit frames for player and reticleover.
    local default_controls = {}

    if UnitFrames.SV.DefaultFramesNewPlayer == 3 then
        default_controls.player =
        {
            [COMBAT_MECHANIC_FLAGS_HEALTH] = ZO_PlayerAttributeHealth,
            [COMBAT_MECHANIC_FLAGS_MAGICKA] = ZO_PlayerAttributeMagicka,
            [COMBAT_MECHANIC_FLAGS_STAMINA] = ZO_PlayerAttributeStamina,
        }
    end
    if UnitFrames.SV.DefaultFramesNewTarget == 3 then
        default_controls.reticleover = { [COMBAT_MECHANIC_FLAGS_HEALTH] = ZO_TargetUnitFramereticleover }
        -- UnitFrames.DefaultFrames.reticleover should be always present to hold target classIcon and friendIcon
    else
        UnitFrames.DefaultFrames.reticleover = { ["unitTag"] = "reticleover" }
    end
    -- Now loop through `default_controls` table and create actual labels (if any)
    for unitTag, fields in pairs(default_controls) do
        UnitFrames.DefaultFrames[unitTag] = { ["unitTag"] = unitTag }
        for powerType, parent in pairs(fields) do
            UnitFrames.DefaultFrames[unitTag][powerType] =
            {
                ["label"] = UI:Label(parent, { CENTER, CENTER }, nil, nil, nil, nil, false),
                ["color"] = UnitFrames.SV.DefaultTextColour,
            }
        end
    end

    -- Reference to target unit frame. this is not an UI control! Used to add custom controls to existing fade-out components table
    UnitFrames.targetUnitFrame = ZO_UnitFrames_GetUnitFrame("reticleover")

    -- When default Target frame is enabled set the threshold value to change color of label and add label to default fade list
    if UnitFrames.DefaultFrames.reticleover[COMBAT_MECHANIC_FLAGS_HEALTH] then
        UnitFrames.DefaultFrames.reticleover[COMBAT_MECHANIC_FLAGS_HEALTH].threshold = UnitFrames.targetThreshold
        table.insert(UnitFrames.targetUnitFrame.fadeComponents, UnitFrames.DefaultFrames.reticleover[COMBAT_MECHANIC_FLAGS_HEALTH].label)
    end

    -- Create classIcon and friendIcon: they should work even when default unit frames extender is disabled
    UnitFrames.DefaultFrames.reticleover.classIcon = UI:Texture(UnitFrames.targetUnitFrame.frame, nil, { 32, 32 }, nil, nil, true)
    UnitFrames.DefaultFrames.reticleover.friendIcon = UI:Texture(UnitFrames.targetUnitFrame.frame, nil, { 32, 32 }, nil, nil, true)
    UnitFrames.DefaultFrames.reticleover.friendIcon:SetAnchor(TOPLEFT, ZO_TargetUnitFramereticleoverTextArea, TOPRIGHT, 30, -4)
    -- add those 2 icons to automatic fade list, so fading will be done automatically by game
    table.insert(UnitFrames.targetUnitFrame.fadeComponents, UnitFrames.DefaultFrames.reticleover.classIcon)
    table.insert(UnitFrames.targetUnitFrame.fadeComponents, UnitFrames.DefaultFrames.reticleover.friendIcon)

    -- When default Group frame in use, then create dummy boolean field, so this setting remain constant between /reloadui calls
    if UnitFrames.SV.DefaultFramesNewGroup == 3 then
        UnitFrames.DefaultFrames.SmallGroup = true
    end

    -- Apply fonts
    UnitFrames.DefaultFramesApplyFont()

    -- Instead of using Default Unit Frames Extender, the player could wish simply to disable and hide default UI frames
    if UnitFrames.SV.DefaultFramesNewPlayer == 1 then
        local frames = { "Health", "Stamina", "Magicka", "MountStamina", "Werewolf", "SiegeHealth" }
        for i = 1, #frames do
            local frame = _G["ZO_PlayerAttribute" .. frames[i]]
            frame:UnregisterForEvent(EVENT_POWER_UPDATE)
            frame:UnregisterForEvent(EVENT_INTERFACE_SETTING_CHANGED)
            frame:UnregisterForEvent(EVENT_PLAYER_ACTIVATED)
            eventManager:UnregisterForUpdate("ZO_PlayerAttribute" .. frames[i] .. "FadeUpdate")
            frame:SetHidden(true)
        end
    end
end

-- Sets out-of-combat transparency values for default user-frames
function UnitFrames.SetDefaultFramesTransparency(min_pct_value, max_pct_value)
    if min_pct_value ~= nil then
        UnitFrames.SV.DefaultOocTransparency = min_pct_value
    end

    if max_pct_value ~= nil then
        UnitFrames.SV.DefaultIncTransparency = max_pct_value
    end

    local min_value = UnitFrames.SV.DefaultOocTransparency / 100
    local max_value = UnitFrames.SV.DefaultIncTransparency / 100

    local animationIndex = 1
    ZO_PlayerAttributeHealth.playerAttributeBarObject.timeline:GetAnimation(animationIndex):SetAlphaValues(min_value, max_value)
    ZO_PlayerAttributeMagicka.playerAttributeBarObject.timeline:GetAnimation(animationIndex):SetAlphaValues(min_value, max_value)
    ZO_PlayerAttributeStamina.playerAttributeBarObject.timeline:GetAnimation(animationIndex):SetAlphaValues(min_value, max_value)

    local inCombat = IsUnitInCombat("player")
    ZO_PlayerAttributeHealth:SetAlpha(inCombat and max_value or min_value)
    ZO_PlayerAttributeStamina:SetAlpha(inCombat and max_value or min_value)
    ZO_PlayerAttributeMagicka:SetAlpha(inCombat and max_value or min_value)
end

-- Creates default group unit UI controls on-fly
---
--- @param unitTag string
function UnitFrames.DefaultFramesCreateUnitGroupControls(unitTag)
    -- First make preparation for "groupN" unitTag labels
    if UnitFrames.DefaultFrames[unitTag] == nil then -- If unitTag is already in our list, then skip this
        if "group" == zo_strsub(unitTag, 0, 5) then  -- If it is really a group member unitTag
            local i = zo_strsub(unitTag, 6)
            if _G["ZO_GroupUnitFramegroup" .. i] then
                local parentBar = _G["ZO_GroupUnitFramegroup" .. i .. "Hp"]
                --- @cast parentBar Control
                local parentName = _G["ZO_GroupUnitFramegroup" .. i .. "Name"]
                -- Prepare dimension of regen bar
                local width, height = parentBar:GetDimensions()
                -- Populate UI elements
                UnitFrames.DefaultFrames[unitTag] =
                {
                    ["unitTag"] = unitTag,
                    [COMBAT_MECHANIC_FLAGS_HEALTH] =
                    {
                        label = UI:Label(parentBar, { TOP, BOTTOM }, nil, nil, nil, nil, false),
                        color = UnitFrames.SV.DefaultTextColour,
                        shield = UI:StatusBar(parentBar, { BOTTOM, BOTTOM, 0, 0 }, { width - height, height }, { 1, 0.75, 0, 0.5 }, true),
                    },
                    ["classIcon"] = UI:Texture(parentName, { RIGHT, LEFT, -4, 2 }, { 24, 24 }, nil, nil, true),
                    ["friendIcon"] = UI:Texture(parentName, { RIGHT, LEFT, -4, 24 }, { 24, 24 }, nil, nil, true),
                }
                -- Apply selected font
                UnitFrames.DefaultFramesApplyFont(unitTag)
            end
        end
    end
end

function UnitFrames.UpdateDefaultLevelTarget()
    local targetLevel = ZO_TargetUnitFramereticleoverLevel
    local targetChamp = ZO_TargetUnitFramereticleoverChampionIcon
    local targetName = ZO_TargetUnitFramereticleoverName
    local unitLevel
    local isChampion = IsUnitChampion("reticleover")
    if isChampion then
        unitLevel = GetUnitEffectiveChampionPoints("reticleover")
    else
        unitLevel = GetUnitLevel("reticleover")
    end

    if unitLevel > 0 then
        targetLevel:SetHidden(false)
        targetLevel:SetText(tostring(unitLevel))
        targetName:SetAnchor(TOPLEFT, targetLevel, TOPRIGHT, 10, 0)
    else
        targetLevel:SetHidden(true)
        targetName:SetAnchor(TOPLEFT)
    end

    if isChampion then
        targetChamp:SetHidden(false)
    else
        targetChamp:SetHidden(true)
    end
end

return UnitFrames
