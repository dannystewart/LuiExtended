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
    "|cFFA500LuiExtended Version 6.9.3|r",
    "",
    -- Bug Fixes
    "|cFFFF00Bug Fixes:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Timer fix.",
    "",
    "|cFFA500LuiExtended Version 6.9.2|r",
    "",
    -- Bug Fixes
    "|cFFFF00Bug Fixes:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t hotfix for bar icons with fancyactionbar.",
    "",
    -- Version Header
    "|cFFA500LuiExtended Version 6.9.1|r",
    "",
    -- Bug Fixes
    "|cFFFF00Bug Fixes:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t hotfix for unitframe layout.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t remove left over debug print.",
    "",
    -- Version Header
    "|cFFA500LuiExtended Version 6.9.0|r",
    "",
    -- General Changes
    "|cFFFF00General:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Bug fixes and stability improvements.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Performance optimizations for texture handling.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Major code refactoring and organization improvements.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Localized many global calls in LuiData for better performance.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Our backbar is now hidden if ActionDurationReminder, FancyActionBar, or FancyActionBar\43 is detected. Why have more that one bar?",
    "",
    -- Features
    "|cFFFF00Features:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Added support for rounded textures on unitframes. This would be the `Tube` and `Steel` textures in the texture list.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t New tracking system for abilities without existing data.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Added conditional checks for displaying the last item count.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Tweaked the fade animation for buff/debuff icons to fade out smoother.",
    "",
    -- Improvements
    "|cFFFF00Improvements:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Refactored CombatInfo.lua with new helper functions for code clarity.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Improved ability ID handling and UI element visibility.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Added SetHighDrawPriority, GetCorrectedAbilityId, and UpdateStackText functions.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Implemented changes suggested in issue #328.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Updated anchor logic and annotations.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Gamepad UI experience improvements.",
    "",
    -- Bug Fixes
    "|cFFFF00Bug Fixes:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Fixed ultimate event handling.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Added nil checks to prevent errors.",
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
