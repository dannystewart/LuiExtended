-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

-- Unit Frames namespace
--- @class (partial) UnitFrames
local UnitFrames = LUIE.UnitFrames
local moduleName = UnitFrames.moduleName

local eventManager = GetEventManager()
local sceneManager = SCENE_MANAGER

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

-- Right Click function for group frames - updated to match ZOS implementation
function UnitFrames.GroupFrames_OnMouseUp(self, button, upInside)
    local unitTag = self.defaultUnitTag
    if button == MOUSE_BUTTON_INDEX_RIGHT and upInside then
        ClearMenu()
        local isPlayer = AreUnitsEqual(unitTag, "player")
        local isLFG = DoesGroupModificationRequireVote()
        local displayName = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, GetUnitDisplayName(unitTag))
        local characterName = GetUnitName(unitTag)
        local isOnline = IsUnitOnline(unitTag)
        local playerIsLeader = IsUnitGroupLeader("player")

        if isPlayer then
            AddMenuItem(GetString(SI_GROUP_LIST_MENU_LEAVE_GROUP), function ()
                ZO_Dialogs_ShowDialog("GROUP_LEAVE_DIALOG")
            end)
        elseif isOnline then
            if IsChatSystemAvailableForCurrentPlatform() then
                AddMenuItem(GetString(SI_SOCIAL_LIST_PANEL_WHISPER), function ()
                    StartChatInput("", CHAT_CHANNEL_WHISPER, characterName)
                end)
            end
            AddMenuItem(GetString(SI_SOCIAL_MENU_VISIT_HOUSE), function ()
                JumpToHouse(displayName)
            end)
            if not ZO_IsTributeLocked() then
                AddMenuItem(GetString(SI_SOCIAL_MENU_TRIBUTE_INVITE), function ()
                    InviteToTributeByDisplayName(displayName)
                end)
            end
            AddMenuItem(GetString(SI_SOCIAL_MENU_JUMP_TO_PLAYER), function ()
                JumpToGroupMember(characterName)
            end)
        end

        if not isPlayer and not IsFriend(displayName) and not IsIgnored(displayName) then
            AddMenuItem(GetString(SI_SOCIAL_MENU_ADD_FRIEND), function ()
                ZO_Dialogs_ShowDialog("REQUEST_FRIEND", { name = displayName })
            end)
        end

        if IsGroupModificationAvailable() then
            if playerIsLeader then
                if isPlayer then
                    if not isLFG then
                        AddMenuItem(GetString(SI_GROUP_LIST_MENU_DISBAND_GROUP), function ()
                            ZO_Dialogs_ShowDialog("GROUP_DISBAND_DIALOG")
                        end)
                    end
                else
                    if not isLFG then
                        AddMenuItem(GetString(SI_GROUP_LIST_MENU_KICK_FROM_GROUP), function ()
                            GroupKick(unitTag)
                        end)
                    end
                end
            end

            -- Cannot vote for yourself
            if isLFG and not isPlayer then
                AddMenuItem(GetString(SI_GROUP_LIST_MENU_VOTE_KICK_FROM_GROUP), function ()
                    local flags = GROUP_ELECTION_FLAGS_REQUIRE_ALL_VOTES + GROUP_ELECTION_FLAGS_IGNORE_OFFLINE_MEMBERS
                    BeginGroupElection(GROUP_ELECTION_TYPE_KICK_MEMBER, ZO_GROUP_ELECTION_DESCRIPTORS.NONE, unitTag, flags)
                end)
            end
        end

        -- Per design, promoting doesn't expressly fall under the mantle of "group modification"
        if playerIsLeader and not isPlayer and isOnline then
            AddMenuItem(GetString(SI_GROUP_LIST_MENU_PROMOTE_TO_LEADER), function ()
                GroupPromote(unitTag)
            end)
        end

        ShowMenu(self)
    end
end

function UnitFrames.AltBar_OnMouseEnterXP(control)
    local isChampion = IsUnitChampion("player")
    local level
    local current
    local levelSize
    local label
    local isMax = false -- If player reaches Champion Point cap
    if isChampion then
        level = GetPlayerChampionPointsEarned()
        current = GetPlayerChampionXP()
        levelSize = GetNumChampionXPInChampionPoint(level)
        if levelSize == nil then
            levelSize = current
            isMax = true
        end
        label = GetString(SI_EXPERIENCE_CHAMPION_LABEL)
    else
        level = GetUnitLevel("player")
        current = GetUnitXP("player")
        levelSize = GetUnitXPMax("player")
        label = GetString(SI_EXPERIENCE_LEVEL_LABEL)
    end
    local percentageXP = zo_floor(current / levelSize * 100)
    local enlightenedPool = GetEnlightenedPool()
    local enlightenedValue = enlightenedPool > 0 and ZO_CommaDelimitNumber(4 * enlightenedPool)

    InitializeTooltip(InformationTooltip, control, BOTTOM, 0, -10)

    SetTooltipText(InformationTooltip, zo_strformat(SI_LEVEL_DISPLAY, label, level))
    if isMax then
        InformationTooltip:AddLine(GetString(SI_EXPERIENCE_LIMIT_REACHED))
    else
        InformationTooltip:AddLine(zo_strformat(SI_EXPERIENCE_CURRENT_MAX_PERCENT, ZO_CommaDelimitNumber(current), ZO_CommaDelimitNumber(levelSize), percentageXP))
        if enlightenedPool > 0 then
            InformationTooltip:AddLine(zo_strformat(SI_EXPERIENCE_CHAMPION_ENLIGHTENED_TOOLTIP, enlightenedValue), nil, ZO_SUCCEEDED_TEXT:UnpackRGB())
        end
    end
end

function UnitFrames.AltBar_OnMouseEnterWerewolf(control)
    local function UpdateWerewolfPower()
        local currentPower, maxPower = GetUnitPower("player", COMBAT_MECHANIC_FLAGS_WEREWOLF)
        local percentagePower = zo_floor(currentPower / maxPower * 100)

        InitializeTooltip(InformationTooltip, control, BOTTOM, 0, -10)
        SetTooltipText(InformationTooltip, zo_strformat(SI_MONSTERSOCIALCLASS45))
        InformationTooltip:AddLine(zo_strformat(LUIE_STRING_UF_WEREWOLF_POWER, currentPower, maxPower, percentagePower))
    end
    UpdateWerewolfPower()

    -- Register Tooltip Update while active
    eventManager:RegisterForEvent(moduleName .. "TooltipPower", EVENT_POWER_UPDATE, UpdateWerewolfPower)
    eventManager:AddFilterForEvent(moduleName .. "TooltipPower", EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, COMBAT_MECHANIC_FLAGS_WEREWOLF, REGISTER_FILTER_UNIT_TAG, "player")
end

function UnitFrames.AltBar_OnMouseEnterMounted(control)
    local function UpdateMountPower()
        local currentPower, maxPower = GetUnitPower("player", COMBAT_MECHANIC_FLAGS_MOUNT_STAMINA)
        local percentagePower = zo_floor(currentPower / maxPower * 100)
        InitializeTooltip(InformationTooltip, control, BOTTOM, 0, -10)

        SetTooltipText(InformationTooltip, zo_strformat(LUIE_STRING_SKILL_MOUNTED))
        InformationTooltip:AddLine(zo_strformat(LUIE_STRING_UF_MOUNT_POWER, currentPower, maxPower, percentagePower))
    end
    UpdateMountPower()

    -- Register Tooltip Update while active
    eventManager:RegisterForEvent(moduleName .. "TooltipPower", EVENT_POWER_UPDATE, UpdateMountPower)
    eventManager:AddFilterForEvent(moduleName .. "TooltipPower", EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, COMBAT_MECHANIC_FLAGS_MOUNT_STAMINA, REGISTER_FILTER_UNIT_TAG, "player")
end

function UnitFrames.AltBar_OnMouseEnterSiege(control)
    local function UpdateSiegePower()
        local currentPower, maxPower = GetUnitPower("controlledsiege", COMBAT_MECHANIC_FLAGS_HEALTH)
        local percentagePower = zo_floor(currentPower / maxPower * 100)
        local siegeName = GetUnitName("controlledsiege")
        InitializeTooltip(InformationTooltip, control, BOTTOM, 0, -10)

        SetTooltipText(InformationTooltip, zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, siegeName))
        InformationTooltip:AddLine(zo_strformat(LUIE_STRING_UF_SIEGE_POWER, ZO_CommaDelimitNumber(currentPower), ZO_CommaDelimitNumber(maxPower), percentagePower))
    end
    UpdateSiegePower()

    -- Register Tooltip Update while active
    eventManager:RegisterForEvent(moduleName .. "TooltipPower", EVENT_POWER_UPDATE, UpdateSiegePower)
    eventManager:AddFilterForEvent(moduleName .. "TooltipPower", EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, COMBAT_MECHANIC_FLAGS_HEALTH, REGISTER_FILTER_UNIT_TAG, "controlledsiege")
end

function UnitFrames.AltBar_OnMouseExit(control)
    ClearTooltip(InformationTooltip)
    eventManager:UnregisterForEvent(moduleName .. "TooltipPower", EVENT_POWER_UPDATE)
end

return UnitFrames
