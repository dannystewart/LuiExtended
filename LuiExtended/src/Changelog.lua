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
    "|cFFA500LuiExtended Version 6.9.6.0|r",
    "",
    -- New Features
    "|cFFFF00New Features:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unit Frames now display group election information, including current voting status.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Added a setting for custom frames to quickly hide dead enemy or neutral NPCs. This shouldn't be hiding dead players, let me know if it does.",
    "",
    -- Fixes
    "|cFFFF00Fixes:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Addressed an issue where target frames could display duplicate icons. (Note: This fix is still under evaluation and may not fully resolve the issue.)",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Fixed an issue where the chat announcement system could display incorrect information about restricted communication permissions.",
    "",
    -- Improvements
    "|cFFFF00Improvements:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Enhanced logic for more accurate identification of Destruction Staff spell icons.",
    "",
    -- Miscellaneous
    "|cFFFF00Miscellaneous:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Started refactoring the codebase to improve readability and maintainability. Started with the Unit Frames module. Report any issues/errors to me in the comments or on Github.",
    "",
    -- -- Bug Fixes
    -- "|cFFFF00Bug Fixes:|r",
    -- "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t .",
    -- "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t .",
    -- "",
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
