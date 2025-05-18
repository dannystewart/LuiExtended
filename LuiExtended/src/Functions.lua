-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

-- -----------------------------------------------------------------------------
-- Lua Locals.
-- -----------------------------------------------------------------------------

local pairs = pairs
local ipairs = ipairs
local select = select
local tonumber = tonumber
local unpack = unpack
local type = type
local string = string
local string_find = string.find
local string_gmatch = string.gmatch
local string_gsub = string.gsub
local string_match = string.match
local string_rep = string.rep
local string_format = string.format
local table = table
local table_concat = table.concat
local table_insert = table.insert
local table_remove = table.remove
local table_sort = table.sort

-- -----------------------------------------------------------------------------
-- ESO API Locals.
-- -----------------------------------------------------------------------------

local animationManager = GetAnimationManager()
local eventManager = GetEventManager()
local windowManager = GetWindowManager()

local GetString = GetString
local zo_strformat = zo_strformat

-- -----------------------------------------------------------------------------
-- LFG Role --
do
    local KEYBOARD_ROLE_ICONS =
    {
        [LFG_ROLE_INVALID] = "LuiExtended/media/unitframes/unitframes_class_none.dds",
        [LFG_ROLE_DPS] = "EsoUI/Art/LFG/LFG_icon_dps.dds",
        [LFG_ROLE_TANK] = "EsoUI/Art/LFG/LFG_icon_tank.dds",
        [LFG_ROLE_HEAL] = "EsoUI/Art/LFG/LFG_icon_healer.dds",
    }
    ---
    --- @param role LFGRole
    --- @return string
    local function GetKeyboardRoleIcon(role)
        return KEYBOARD_ROLE_ICONS[role]
    end

    local GAMEPAD_ROLE_ICONS =
    {
        [LFG_ROLE_INVALID] = "LuiExtended/media/unitframes/unitframes_class_none.dds",
        [LFG_ROLE_DPS] = "EsoUI/Art/LFG/Gamepad/LFG_roleIcon_dps.dds",
        [LFG_ROLE_TANK] = "EsoUI/Art/LFG/Gamepad/LFG_roleIcon_tank.dds",
        [LFG_ROLE_HEAL] = "EsoUI/Art/LFG/Gamepad/LFG_roleIcon_healer.dds",
    }
    ---
    --- @param role LFGRole
    --- @return string
    local function GetGamepadRoleIcon(role)
        return GAMEPAD_ROLE_ICONS[role]
    end
    ---
    --- @param role LFGRole
    --- @return string
    local function GetRoleIcon(role)
        if IsInGamepadPreferredMode() then
            return GetGamepadRoleIcon(role)
        else
            return GetKeyboardRoleIcon(role)
        end
    end

    LUIE.GetRoleIcon = GetRoleIcon
end

-- -----------------------------------------------------------------------------

do
    local addonManager = GetAddOnManager()
    local numAddOns = addonManager:GetNumAddOns()

    --- @param addOnName string
    --- @return boolean
    local function is_it_enabled(addOnName)
        if not addonManager:WasAddOnDetected(addOnName) then
            return false
        end
        for i = 1, numAddOns do
            local name, _, _, _, _, state, _, _ = addonManager:GetAddOnInfo(i)

            if name == addOnName and state == ADDON_STATE_ENABLED then
                return true
            end
        end

        return false
    end

    LUIE.IsItEnabled = is_it_enabled
end

-- -----------------------------------------------------------------------------
--- Called from the menu and on initialization to update the timestamp color when changed.
LUIE.TimeStampColorize = nil

-- -----------------------------------------------------------------------------
--- Updates the timestamp color based on the value in LUIE.ChatAnnouncements.SV.TimeStampColor.
function LUIE.UpdateTimeStampColor()
    local color = LUIE.ChatAnnouncements.SV.TimeStampColor or { 0.5607843137, 0.5607843137, 0.5607843137 }
    LUIE.TimeStampColorize = ZO_ColorDef:New(unpack(color)):ToHex()
end

-- -----------------------------------------------------------------------------
--- Toggle the display of the Alert Frame.
--- Sets the visibility of the ZO_AlertTextNotification based on the value of LUIE.SV.HideAlertFrame.
function LUIE.SetupAlertFrameVisibility()
    ZO_AlertTextNotification:SetHidden(LUIE.SV.HideAlertFrame)
end

-- -----------------------------------------------------------------------------
do
    -- Get milliseconds from game time
    local function getCurrentMillisecondsFormatted()
        local currentTimeMs = GetFrameTimeMilliseconds()
        local formattedTime = string_format("%03d", currentTimeMs % 1000)
        return formattedTime
    end

    --- Returns a formatted timestamp based on the provided time string and format string.
    --- @param timeStr string: The time string in the format "HH:MM:SS".
    --- @param formatStr string|nil (optional): The format string for the timestamp. If not provided, the default format from LUIE.ChatAnnouncements.SV.TimeStampFormat will be used.
    --- @param milliseconds string|nil
    --- @return string @ The formatted timestamp.
    local function CreateTimestamp(timeStr, formatStr, milliseconds)
        local showTimestamp = LUIE.ChatAnnouncements.SV.TimeStamp
        if showTimestamp then
            milliseconds = milliseconds or getCurrentMillisecondsFormatted()
        end
        if milliseconds == nil then milliseconds = "" end
        formatStr = formatStr or LUIE.ChatAnnouncements.SV.TimeStampFormat

        -- split up default timestamp
        local hours, minutes, seconds = string_match(timeStr, "([^%:]+):([^%:]+):([^%:]+)")
        local hoursNoLead = tonumber(hours) -- hours without leading zero
        local hours12NoLead = (hoursNoLead - 1) % 12 + 1
        local hours12
        if (hours12NoLead < 10) then
            hours12 = "0" .. hours12NoLead
        else
            hours12 = hours12NoLead
        end
        local pUp = "AM"
        local pLow = "am"
        if (hoursNoLead >= 12) then
            pUp = "PM"
            pLow = "pm"
        end

        -- create new one
        -- >If you add new formats make sure to update the tooltip at LUIE_STRING_LAM_CA_TIMESTAMPFORMAT_TP too
        local timestamp = formatStr
        timestamp = string_gsub(timestamp, "HH", hours)
        timestamp = string_gsub(timestamp, "H", hoursNoLead)
        timestamp = string_gsub(timestamp, "hh", hours12)
        timestamp = string_gsub(timestamp, "h", hours12NoLead)
        timestamp = string_gsub(timestamp, "m", minutes)
        timestamp = string_gsub(timestamp, "s", seconds)
        timestamp = string_gsub(timestamp, "A", pUp)
        timestamp = string_gsub(timestamp, "a", pLow)
        timestamp = string_gsub(timestamp, "xy", milliseconds)
        return timestamp
    end

    LUIE.CreateTimestamp = CreateTimestamp
end

-- -----------------------------------------------------------------------------
do
    --- Helper function to format a message with an optional timestamp.
    --- @param msg string: The message to be formatted.
    --- @param doTimestamp boolean: If true, a timestamp will be added to the formatted message.
    --- @param lineNumber? number: The current line number for the chat message.
    --- @param chanCode? number: The chat channel code.
    --- @return string: The formatted message.
    local function FormatMessage(msg, doTimestamp, lineNumber, chanCode)
        local formattedMsg = msg or ""
        if doTimestamp then
            local timestring = GetTimeString()
            local timestamp = LUIE.CreateTimestamp(timestring, nil, nil)

            -- Make timestamp clickable if lineNumber and chanCode are provided
            local timestampText
            if lineNumber and chanCode then
                timestampText = ZO_LinkHandler_CreateLink(timestamp, nil, "LUIE", lineNumber .. ":" .. chanCode)
            else
                timestampText = timestamp
            end

            -- Format with color and brackets
            local timestampFormatted = string_format("|c%s[%s]|r ", LUIE.TimeStampColorize, timestampText)

            -- Combine timestamp with message
            formattedMsg = timestampFormatted .. formattedMsg
        end
        return formattedMsg
    end

    LUIE.FormatMessage = FormatMessage
end
-- -----------------------------------------------------------------------------
--- Hides or shows all LUIE components.
--- @param hidden boolean: If true, all components will be hidden. If false, all components will be shown.
function LUIE.ToggleVisibility(hidden)
    for _, control in pairs(LUIE.Components) do
        control:SetHidden(hidden)
    end
end

-- -----------------------------------------------------------------------------
do
    --- Adds a system message to the chat.
    --- @param messageOrFormatter string: The message to be printed.
    --- @param ... string: Variable number of arguments to be formatted into the message.
    local function AddSystemMessage(messageOrFormatter, ...)
        -- Format the message if there are arguments
        local formattedMessage
        if select("#", ...) > 0 then
            -- Escape '%' characters to prevent illegal format specifiers
            local safeFormat = (string_gsub(messageOrFormatter, "%%", "%%%%"))
            formattedMessage = string_format(safeFormat, ...)
        else
            formattedMessage = messageOrFormatter
        end

        CHAT_ROUTER:AddSystemMessage(formattedMessage)

        if LibDebugLogger and LUIE.IsDevDebugEnabled() then
            LUIE.Debug(formattedMessage, ...)
        end
    end

    LUIE.AddSystemMessage = AddSystemMessage
end
-- -----------------------------------------------------------------------------
do
    local FormatMessage = LUIE.FormatMessage
    local SystemMessage = LUIE.AddSystemMessage

    --- Prints a message to specific chat windows based on user settings
    --- @param formattedMsg string: The message to print
    --- @param isSystem boolean: Whether this is a system message
    local function PrintToChatWindows(formattedMsg, isSystem)
        -- If system messages should go to all windows and this is a system message, use SystemMessage
        if isSystem and LUIE.ChatAnnouncements.SV.ChatSystemAll then
            SystemMessage(formattedMsg)
            return
        end

        -- Otherwise, print to individual tabs based on settings
        for _, cc in ipairs(ZO_GetChatSystem().containers) do
            for i = 1, #cc.windows do
                if LUIE.ChatAnnouncements.SV.ChatTab[i] == true then
                    local chatContainer = cc
                    local chatWindow = cc.windows[i]

                    -- Skip Combat Metrics Log window if CMX is enabled
                    local skipWindow = false
                    if CMX and CMX.db and CMX.db.chatLog then
                        if chatContainer:GetTabName(i) == CMX.db.chatLog.name then
                            skipWindow = true
                        end
                    end

                    if not skipWindow then
                        chatContainer:AddEventMessageToWindow(chatWindow, formattedMsg, CHAT_CATEGORY_SYSTEM)
                    end
                end
            end
        end
    end

    --- Easy Print to Chat.
    --- Prints a message to the chat.
    --- @param msg string: The message to be printed.
    --- @param isSystem? boolean: If true, the message is considered a system message.
    local function PrintToChat(msg, isSystem)
        -- Guard clause: exit early if chat system not ready
        if not ZO_GetChatSystem().primaryContainer then
            return
        end

        -- Default message if none provided
        if msg == "" then
            msg = "[Empty String]"
        end

        -- Determine if we should format the message with a timestamp
        local shouldFormat = not LUIE.ChatAnnouncements.SV.ChatBypassFormat
        local doTimestamp = LUIE.ChatAnnouncements.SV.TimeStamp
        local formattedMsg = shouldFormat
            and FormatMessage(msg, doTimestamp)
            or msg

        -- Method 1: Print to all tabs (uses SystemMessage)
        if LUIE.ChatAnnouncements.SV.ChatMethod == "Print to All Tabs" then
            SystemMessage(formattedMsg)
            return
        end

        -- Method 2: Print to specific tabs
        PrintToChatWindows(formattedMsg, isSystem)
    end

    LUIE.PrintToChat = PrintToChat
end
-- -----------------------------------------------------------------------------
--- Formats a number with optional shortening and localized separators.
--- @param number number The number to format
--- @param shorten? boolean Whether to abbreviate large numbers (e.g. 1.5M)
--- @param comma? boolean Whether to add localized digit separators
--- @return string|number @The formatted number
function LUIE.AbbreviateNumber(number, shorten, comma)
    if number > 0 and shorten then
        local value
        local suffix
        if number >= 1000000000 then
            value = number / 1000000000
            suffix = "G"
        elseif number >= 1000000 then
            value = number / 1000000
            suffix = "M"
        elseif number >= 1000 then
            value = number / 1000
            suffix = "k"
        else
            value = number
        end
        -- If we could not convert even to "G", return full number
        if value >= 1000 then
            if comma then
                value = ZO_CommaDelimitDecimalNumber(number)
                return value
            else
                return number
            end
        elseif value >= 100 or suffix == nil then
            value = string_format("%d", value)
        else
            value = string_format("%.1f", value)
        end
        if suffix ~= nil then
            value = value .. suffix
        end
        return value
    end
    -- Add commas if needed
    if comma then
        local value = ZO_CommaDelimitDecimalNumber(number)
        return value
    end
    return number
end

-- -----------------------------------------------------------------------------
--- Takes an input with a name identifier, title, text, and callback function to create a dialogue button.
--- @param identifier string: The identifier for the dialogue button.
--- @param title string: The title text for the dialogue button.
--- @param text string: The main text for the dialogue button.
--- @param callback function: The callback function to be executed when the button is clicked.
--- @return table identifier: The created dialogue button table.
function LUIE.RegisterDialogueButton(identifier, title, text, callback)
    ESO_Dialogs[identifier] =
    {
        gamepadInfo =
        {
            dialogType = GAMEPAD_DIALOGS.BASIC,
        },
        canQueue = true,
        title =
        {
            text = title,
        },
        mainText =
        {
            text = text,
        },
        buttons =
        {
            {
                text = SI_DIALOG_CONFIRM,
                callback = callback,
            },
            {
                text = SI_DIALOG_CANCEL,
            },
        },
    }
    return ESO_Dialogs[identifier]
end

-- -----------------------------------------------------------------------------
-- Initialize empty table if it doesn't exist
if not LUIE.GuildIndexData then
    --- @class LUIE_GuildIndexData
    --- @field [integer] {
    --- id : integer,
    --- name : string,
    --- guildAlliance : integer|Alliance,
    --- }
    LUIE.GuildIndexData = {}
end

--- Function to update guild data.
--- Retrieves information about each guild the player is a member of and stores it in LUIE.GuildIndexData table.
---
--- @param eventId integer
--- @param guildServerId integer
--- @param characterName string
--- @param guildId integer
function LUIE.UpdateGuildData(eventId, guildServerId, characterName, guildId)
    -- if LUIE.IsDevDebugEnabled() then
    --     local Debug = LUIE.Debug
    --     local traceback = "Update Guild Data:\n" ..
    --         "--> eventId: " .. tostring(eventId) .. "\n" ..
    --         "--> guildServerId: " .. tostring(guildServerId) .. "\n" ..
    --         "--> characterName: " .. zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, characterName) .. "\n" ..
    --         "--> guildId: " .. tostring(guildId)
    --     Debug(traceback)
    -- end
    local GuildsIndex = GetNumGuilds()
    for i = 1, GuildsIndex do
        local id = GetGuildId(i)
        local name = GetGuildName(id)
        local guildAlliance = GetGuildAlliance(id)
        if not LUIE.GuildIndexData[i] then
            LUIE.GuildIndexData[i] =
            {
                id = id,
                name = name,
                guildAlliance = guildAlliance
            }
        else
            -- Update existing guild entry
            LUIE.GuildIndexData[i].id = id
            LUIE.GuildIndexData[i].name = name
            LUIE.GuildIndexData[i].guildAlliance = guildAlliance
        end
    end
end

-- -----------------------------------------------------------------------------
--- Simple function to check the veteran difficulty.
--- @return boolean: Returns true if the player is in a veteran dungeon or using veteran difficulty, false otherwise.
function LUIE.ResolveVeteranDifficulty()
    if GetGroupSize() <= 1 and IsUnitUsingVeteranDifficulty("player") then
        return true
    elseif GetCurrentZoneDungeonDifficulty() == 2 or IsGroupUsingVeteranDifficulty() == true then
        return true
    else
        return false
    end
end

-- -----------------------------------------------------------------------------
--- Simple function that checks if the player is in a PVP zone.
--- @return boolean: Returns true if the player is PvP flagged, false otherwise.
function LUIE.ResolvePVPZone()
    if IsUnitPvPFlagged("player") then
        return true
    else
        return false
    end
end

-- -----------------------------------------------------------------------------
--- Pulls the name for the current morph of a skill.
--- @param abilityId number: The AbilityId of the skill.
--- @return string abilityName: The name of the current morph of the skill.
function LUIE.GetSkillMorphName(abilityId)
    local skillType, skillIndex, abilityIndex, morphChoice, rankIndex = GetSpecificSkillAbilityKeysByAbilityId(abilityId)
    local abilityName = GetSkillAbilityInfo(skillType, skillIndex, abilityIndex)
    return abilityName
end

-- -----------------------------------------------------------------------------
--- Pulls the icon for the current morph of a skill.
--- @param abilityId number: The AbilityId of the skill.
--- @return string abilityIcon: The icon path of the current morph of the skill.
function LUIE.GetSkillMorphIcon(abilityId)
    local skillType, skillIndex, abilityIndex, morphChoice, rankIndex = GetSpecificSkillAbilityKeysByAbilityId(abilityId)
    local abilityIcon = select(2, GetSkillAbilityInfo(skillType, skillIndex, abilityIndex))
    return abilityIcon
end

-- -----------------------------------------------------------------------------
--- Pulls the AbilityId for the current morph of a skill.
--- @param abilityId number: The AbilityId of the skill.
--- @return number morphAbilityId: The AbilityId of the current morph of the skill.
function LUIE.GetSkillMorphAbilityId(abilityId)
    local skillType, skillIndex, abilityIndex, morphChoice, rankIndex = GetSpecificSkillAbilityKeysByAbilityId(abilityId)
    local morphAbilityId = GetSkillAbilityId(skillType, skillIndex, abilityIndex, false)
    return morphAbilityId -- renamed local (abilityId) to avoid naming conflicts with the parameter
end

-- -----------------------------------------------------------------------------
--- Function to update the syntax for default Mundus Stone tooltips we pull (in order to retain scaling).
--- @param abilityId number: The ID of the ability.
--- @param tooltipText string: The original tooltip text.
--- @return string tooltipText: The updated tooltip text.
function LUIE.UpdateMundusTooltipSyntax(abilityId, tooltipText)
    -- Update syntax for The Lady, The Lover, and the Thief Mundus stones since they aren't consistent with other buffs.
    if abilityId == 13976 or abilityId == 13981 then -- The Lady / The Lover
        tooltipText = string_gsub(tooltipText, GetString(LUIE_STRING_SKILL_MUNDUS_SUB_RES_PEN), GetString(LUIE_STRING_SKILL_MUNDUS_SUB_RES_PEN_REPLACE))
    elseif abilityId == 13975 then                   -- The Thief
        tooltipText = string_gsub(tooltipText, GetString(LUIE_STRING_SKILL_MUNDUS_SUB_THIEF), GetString(LUIE_STRING_SKILL_MUNDUS_SUB_THIEF_REPLACE))
    end
    -- Replace "Increases your" with "Increase"
    tooltipText = string_gsub(tooltipText, GetString(LUIE_STRING_SKILL_MUNDUS_STRING), GetString(LUIE_STRING_SKILL_DRINK_INCREASE))
    return tooltipText
end

-- -----------------------------------------------------------------------------
do
    --- @param actionSlotIndex integer
    --- @param hotbarCategory HotBarCategory?
    --- @return integer actionId
    local function GetSlotTrueBoundId(actionSlotIndex, hotbarCategory)
        hotbarCategory = hotbarCategory or GetActiveHotbarCategory()
        local actionId = GetSlotBoundId(actionSlotIndex, hotbarCategory)
        local actionType = GetSlotType(actionSlotIndex, hotbarCategory)
        if actionType == ACTION_TYPE_CRAFTED_ABILITY then
            actionId = GetAbilityIdForCraftedAbilityId(actionId)
        end
        return actionId
    end
    LUIE.GetSlotTrueBoundId = GetSlotTrueBoundId
end
-- -----------------------------------------------------------------------------

do
    -- Add this if not already.
    if not SLASH_COMMANDS["/rl"] then
        SLASH_COMMANDS["/rl"] = ReloadUI("ingame")
    end
end

-- -----------------------------------------------------------------------------
do
    --- Valid item types for deconstruction
    local DECONSTRUCTIBLE_ITEM_TYPES =
    {
        [ITEMTYPE_ADDITIVE] = true,
        [ITEMTYPE_ARMOR_BOOSTER] = true,
        [ITEMTYPE_ARMOR_TRAIT] = true,
        [ITEMTYPE_BLACKSMITHING_BOOSTER] = true,
        [ITEMTYPE_BLACKSMITHING_MATERIAL] = true,
        [ITEMTYPE_BLACKSMITHING_RAW_MATERIAL] = true,
        [ITEMTYPE_CLOTHIER_BOOSTER] = true,
        [ITEMTYPE_CLOTHIER_MATERIAL] = true,
        [ITEMTYPE_CLOTHIER_RAW_MATERIAL] = true,
        [ITEMTYPE_ENCHANTING_RUNE_ASPECT] = true,
        [ITEMTYPE_ENCHANTING_RUNE_ESSENCE] = true,
        [ITEMTYPE_ENCHANTING_RUNE_POTENCY] = true,
        [ITEMTYPE_ENCHANTMENT_BOOSTER] = true,
        [ITEMTYPE_FISH] = true,
        [ITEMTYPE_GLYPH_ARMOR] = true,
        [ITEMTYPE_GLYPH_JEWELRY] = true,
        [ITEMTYPE_GLYPH_WEAPON] = true,
        [ITEMTYPE_GROUP_REPAIR] = true,
        [ITEMTYPE_INGREDIENT] = true,
        [ITEMTYPE_JEWELRYCRAFTING_BOOSTER] = true,
        [ITEMTYPE_JEWELRYCRAFTING_MATERIAL] = true,
        [ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER] = true,
        [ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL] = true,
        [ITEMTYPE_JEWELRY_RAW_TRAIT] = true,
        [ITEMTYPE_JEWELRY_TRAIT] = true,
        [ITEMTYPE_POISON_BASE] = true,
        [ITEMTYPE_POTION_BASE] = true,
        [ITEMTYPE_RAW_MATERIAL] = true,
        [ITEMTYPE_REAGENT] = true,
        [ITEMTYPE_STYLE_MATERIAL] = true,
        [ITEMTYPE_WEAPON] = true,
        [ITEMTYPE_WEAPON_BOOSTER] = true,
        [ITEMTYPE_WEAPON_TRAIT] = true,
        [ITEMTYPE_WOODWORKING_BOOSTER] = true,
        [ITEMTYPE_WOODWORKING_MATERIAL] = true,
        [ITEMTYPE_WOODWORKING_RAW_MATERIAL] = true,
    }

    -- -----------------------------------------------------------------------------
    --- Valid crafting types for deconstruction
    local DECONSTRUCTIBLE_CRAFTING_TYPES =
    {
        [CRAFTING_TYPE_BLACKSMITHING] = true,
        [CRAFTING_TYPE_CLOTHIER] = true,
        [CRAFTING_TYPE_WOODWORKING] = true,
        [CRAFTING_TYPE_JEWELRYCRAFTING] = true,
    }

    --- @alias SmithingMode integer
    --- | `SMITHING_MODE_ROOT` # 0
    --- | `SMITHING_MODE_REFINEMENT` # 1
    --- | `SMITHING_MODE_CREATION` # 2
    --- | `SMITHING_MODE_DECONSTRUCTION` # 3
    --- | `SMITHING_MODE_IMPROVEMENT` # 4
    --- | `SMITHING_MODE_RESEARCH` # 5
    --- | `SMITHING_MODE_RECIPES` # 6
    --- | `SMITHING_MODE_CONSOLIDATED_SET_SELECTION` # 7

    --- @alias EnchantingMode integer
    --- | `ENCHANTING_MODE_NONE` # 0
    --- | `ENCHANTING_MODE_CREATION` # 1
    --- | `ENCHANTING_MODE_EXTRACTION` # 2
    --- | `ENCHANTING_MODE_RECIPES` # 3

    -- -----------------------------------------------------------------------------
    --- Get the current crafting mode, accounting for both keyboard and gamepad UI
    --- @return integer|SmithingMode mode The current crafting mode
    local function GetSmithingMode()
        local mode
        if IsInGamepadPreferredMode() == true then
            -- In Gamepad UI, use SMITHING_GAMEPAD.mode
            mode = SMITHING_GAMEPAD and SMITHING_GAMEPAD.mode
        else
            -- For Keyboard UI, use SMITHING.mode
            mode = SMITHING and SMITHING.mode
        end
        --- @cast mode SmithingMode
        -- At this point, mode should already be one of:
        -- SMITHING_MODE_ROOT                       = 0
        -- SMITHING_MODE_REFINEMENT                 = 1
        -- SMITHING_MODE_CREATION                   = 2
        -- SMITHING_MODE_DECONSTRUCTION             = 3
        -- SMITHING_MODE_IMPROVEMENT                = 4
        -- SMITHING_MODE_RESEARCH                   = 5
        -- SMITHING_MODE_RECIPES                    = 6
        -- SMITHING_MODE_CONSOLIDATED_SET_SELECTION = 7
        --
        -- Return mode (defaulting to SMITHING_MODE_ROOT if for some reason mode is nil)
        return mode or SMITHING_MODE_ROOT
    end
    LUIE.GetSmithingMode = GetSmithingMode
    local function GetEnchantingMode()
        local enchantingMode
        if IsInGamepadPreferredMode() == true then
            enchantingMode = GAMEPAD_ENCHANTING
        else
            enchantingMode = ENCHANTING
        end
        local mode = enchantingMode:GetEnchantingMode()
        --- @cast mode EnchantingMode
        return mode or ENCHANTING_MODE_NONE
    end
    LUIE.GetEnchantingMode = GetEnchantingMode
    -- -----------------------------------------------------------------------------
    --- Checks if an item type is valid for deconstruction in the current crafting context
    --- @param itemType number The item type to check
    --- @return boolean @Returns true if the item can be deconstructed in current context
    local function ResolveCraftingUsed(itemType)
        local craftingType = GetCraftingInteractionType()
        local DECONSTRUCTION_MODE = 3

        -- Check if current crafting type allows deconstruction and we're in deconstruction mode
        return DECONSTRUCTIBLE_CRAFTING_TYPES[craftingType]
            and GetSmithingMode() == DECONSTRUCTION_MODE
            and DECONSTRUCTIBLE_ITEM_TYPES[itemType] or false
    end
    LUIE.ResolveCraftingUsed = ResolveCraftingUsed
end

-- -----------------------------------------------------------------------------

do
    --- @type table<integer,string>
    local CLASS_ICONS = {}

    for i = 1, GetNumClasses() do
        local ClassInfo = { GetClassInfo(i) }
        CLASS_ICONS[ClassInfo[1]] = ClassInfo[8]
    end

    ---
    --- @param classId integer
    --- @return string
    local function GetClassIcon(classId)
        return CLASS_ICONS[classId]
    end

    LUIE.GetClassIcon = GetClassIcon
end
-- -----------------------------------------------------------------------------

do
    --- @param armorType ArmorType
    --- @return integer counter
    local function GetEquippedArmorPieces(armorType)
        local counter = 0
        for i = 0, 16 do
            local itemLink = GetItemLink(BAG_WORN, i, LINK_STYLE_DEFAULT)
            if GetItemLinkArmorType(itemLink) == armorType then
                counter = counter + 1
            end
        end
        return counter
    end

    -- Tooltip handler definitions
    local TooltipHandlers =
    {
        -- Brace
        [974] = function ()
            local _, _, mitigation = GetAdvancedStatValue(ADVANCED_STAT_DISPLAY_TYPE_BLOCK_MITIGATION)
            local _, _, speed = GetAdvancedStatValue(ADVANCED_STAT_DISPLAY_TYPE_BLOCK_SPEED)
            local _, cost = GetAdvancedStatValue(ADVANCED_STAT_DISPLAY_TYPE_BLOCK_COST)

            -- Get weapon type for resource determination
            local function getActiveWeaponType()
                local weaponPair = GetActiveWeaponPairInfo()
                if weaponPair == ACTIVE_WEAPON_PAIR_MAIN then
                    return GetItemWeaponType(BAG_WORN, EQUIP_SLOT_MAIN_HAND)
                elseif weaponPair == ACTIVE_WEAPON_PAIR_BACKUP then
                    return GetItemWeaponType(BAG_WORN, EQUIP_SLOT_BACKUP_MAIN)
                end
                return WEAPONTYPE_NONE
            end

            -- Determine resource type based on weapon and skills
            local function getResourceType()
                local weaponType = getActiveWeaponType()
                if weaponType == WEAPONTYPE_FROST_STAFF then
                    local skillType, skillIndex, abilityIndex = GetSpecificSkillAbilityKeysByAbilityId(30948)
                    local purchased = select(6, GetSkillAbilityInfo(skillType, skillIndex, abilityIndex))
                    if purchased then
                        return GetString(SI_ATTRIBUTES2) -- Magicka
                    end
                end
                return GetString(SI_ATTRIBUTES3) -- Stamina
            end

            local finalSpeed = 100 - speed
            local roundedMitigation = zo_floor(mitigation * 100 + 0.5) / 100
            return zo_strformat(GetString(LUIE_STRING_SKILL_BRACE_TP), roundedMitigation, finalSpeed, cost, getResourceType())
        end,

        -- Crouch
        [20299] = function ()
            local _, _, speed = GetAdvancedStatValue(ADVANCED_STAT_DISPLAY_TYPE_SNEAK_SPEED_REDUCTION)
            local _, cost = GetAdvancedStatValue(ADVANCED_STAT_DISPLAY_TYPE_SNEAK_COST)

            if speed <= 0 or speed >= 100 then
                return zo_strformat(GetString(LUIE_STRING_SKILL_HIDDEN_NO_SPEED_TP), cost)
            end
            return zo_strformat(GetString(LUIE_STRING_SKILL_HIDDEN_TP), 100 - speed, cost)
        end,

        -- Unchained
        [98316] = function ()
            local duration = (GetAbilityDuration(98316) or 0) / 1000
            local pointsSpent = GetNumPointsSpentOnChampionSkill(64) * 1.1
            local adjustPoints = pointsSpent == 0 and 55 or zo_floor(pointsSpent * 100 + 0.5) / 100
            return zo_strformat(GetString(LUIE_STRING_SKILL_UNCHAINED_TP), duration, adjustPoints)
        end,

        -- Medium Armor Evasion
        [150057] = function ()
            local counter = GetEquippedArmorPieces(ARMORTYPE_MEDIUM) * 2
            return zo_strformat(GetString(LUIE_STRING_SKILL_MEDIUM_ARMOR_EVASION), counter)
        end,

        -- Unstoppable Brute
        [126582] = function ()
            local counter = GetEquippedArmorPieces(ARMORTYPE_HEAVY) * 5
            local duration = (GetAbilityDuration(126582) or 0) / 1000
            return zo_strformat(GetString(LUIE_STRING_SKILL_UNSTOPPABLE_BRUTE), duration, counter)
        end,

        -- Immovable
        [126583] = function ()
            local counter = GetEquippedArmorPieces(ARMORTYPE_HEAVY) * 5
            local duration = (GetAbilityDuration(126583) or 0) / 1000
            return zo_strformat(GetString(LUIE_STRING_SKILL_IMMOVABLE), duration, counter, 65 + counter)
        end,
    }

    -- Returns dynamic tooltips when called by Tooltip function
    ---
    --- @param abilityId integer
    --- @return string
    local function DynamicTooltip(abilityId)
        local handler = TooltipHandlers[abilityId]
        return handler and handler()
    end

    LUIE.DynamicTooltip = DynamicTooltip
end
-- -----------------------------------------------------------------------------
