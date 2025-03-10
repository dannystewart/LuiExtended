-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
-- -----------------------------------------------------------------------------
local zo_strformat = zo_strformat
local table_concat = table.concat
-- -----------------------------------------------------------------------------
local changelogMessages =
{
    -- Version Header
    "|cFFA500LuiExtended Version 6.8.8|r",
    "",
    -- General Changes
    "|cFFFF00General:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Due to frequency of updates, I have disabled showing the changelog when there is a version increase.\nIf you still would like to see a popup there is a setting under Miscellaneous Settings to enable that.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Added some timer data for Arcanist.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Fixed an error if LibChatMessasge's history feature was enabled.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Fixed timestamps to properly disable if \"Allow Addons to Modify LUIE Messages\" was toggled in the settings.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Updated tooltip for Gallop to show as 15%. Custom Tooltips need to be enabled to see this...",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Updated stealth tooltip text for update 101045. Custom Tooltips need to be enabled to see this...",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Misc small changes.",
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
    if LUIESV.Default[GetDisplayName()]["$AccountWide"].WelcomeVersion ~= LUIE.version then
        LUIE_Changelog:SetHidden(false)
    end

    -- Set version to current version
    LUIESV.Default[GetDisplayName()]["$AccountWide"].WelcomeVersion = LUIE.version
end

-- -----------------------------------------------------------------------------
