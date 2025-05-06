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
{ -- Version Header
    "|cFFA500LuiExtended Version 6.9.4|r",
    "",
    -- Revert
    "|cFFFF00Reverted:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Removed timer code. To many issues with other action bar addons enabled.\nYes that means timers for sorc pets dont show again.",
    "",
    -- Bug Fixes
    "|cFFFF00Bug Fixes:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Chat announcement fixes. Looking at you guards... if you know you know.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Combat Text resources now warn again if you are low.",
    "",
    -- Miscellaneous
    "|cFFFF00Miscellaneous:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Some other things, it's been a long weekend",
    "",
    -- Notes
    "|cFFFF00Note:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t As a reminder, the combat text module can be intensive with the amount of animations that go on.",
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
