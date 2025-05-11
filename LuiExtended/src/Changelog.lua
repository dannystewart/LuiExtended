-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
-- -----------------------------------------------------------------------------
local zo_strformat = zo_strformat
local zo_strgsub = zo_strgsub
local table_concat = table.concat
local GetDisplayName = GetDisplayName
-- -----------------------------------------------------------------------------
local changelogMessages =
{
    -- Version Header
    "|cFFA500LuiExtended Version 6.9.5.1|r",
    "",
    -- Fix
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Some timer fixes. Feedback needed!",
    "",
    -- Version Header
    "|cFFA500LuiExtended Version 6.9.5|r",
    "",
    -- New
    "|cFFFF00New:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Re-Enabled using the games api, if you have a conflict, turn off luie backbar and label timer.",
    "",
    -- Bug Fixes
    "|cFFFF00Bug Fixes:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Resolved an issue with Off-Balance tracking in the Prominent Debuff container.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Fixed missing icon chat message when purchasing items from vendors.",
    "",
    -- Miscellaneous
    "|cFFFF00Miscellaneous:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Added an option to hide the bracing buff (block). This setting can be found in Buffs & Debuffs -> Long & Short-Term Effect Options -> Short-Term Effect Filters -> Show Block - Player. Default is \"ON\".",
    "",
}
-- -----------------------------------------------------------------------------
-- Hide toggle called by the menu or xml button
function LUIE.ToggleChangelog(option)
    LUIE_Changelog:ClearAnchors()
    LUIE_Changelog:SetAnchor(CENTER, GuiRoot, CENTER, 0, -120)
    LUIE_Changelog:SetHidden(option)
end

-- -----------------------------------------------------------------------------
-- Called on initialize
function LUIE.ChangelogScreen()
    -- concat messages into one string
    local changelog = table_concat(changelogMessages, "\n")
    -- If text start with '*' replace it with bullet texture
    changelog = zo_strgsub(changelog, "%[%*%]", "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t")
    -- Set the window title
    LUIE_Changelog_Title:SetText(zo_strformat("<<1>> Changelog", LUIE.name))
    -- Set the about string
    LUIE_Changelog_About:SetText(zo_strformat("v<<1>> by <<2>>", LUIE.version, LUIE.author))
    -- Set the changelog text
    LUIE_Changelog_Text:SetText(changelog)

    -- Display the changelog if version number < current version
    if LUIESV["Default"][GetDisplayName()]["$AccountWide"].WelcomeVersion ~= LUIE.version then
        LUIE_Changelog:SetHidden(false)
    end

    -- Set version to current version
    LUIESV["Default"][GetDisplayName()]["$AccountWide"].WelcomeVersion = LUIE.version
end

-- -----------------------------------------------------------------------------
