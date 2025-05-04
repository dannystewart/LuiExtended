---@diagnostic disable: duplicate-set-field
-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--[[ 
EsoUI/Ingame/UnitAttributeVisualizer/Modules/PowerShield.lua:368: attempt to index a nil value
|rstack traceback:
EsoUI/Ingame/UnitAttributeVisualizer/Modules/PowerShield.lua:368: in function 'ZO_UnitVisualizer_PowerShieldModule:ApplyPlatformStyle'
	<Locals> self = [table:1]{moduleId = 6}, attribute = 1, bar = ud </Locals>
EsoUI/Ingame/UnitAttributeVisualizer/UnitAttributeVisualizer.lua:160: in function 'ZO_UnitAttributeVisualizer:ApplyPlatformStyle'
	<Locals> self = [table:2]{unitTag = "player"}, _ = [table:1], module = [table:1] </Locals>
EsoUI/Ingame/PlayerAttributeBars/PlayerAttributeBars.lua:687: in function 'ZO_PlayerAttributeBars:OnGamepadPreferredModeChanged'
	<Locals> self = [table:3]{forceVisible = F, forceShow = F} </Locals>
EsoUI/Ingame/PlayerAttributeBars/PlayerAttributeBars.lua:607: in function '(anonymous)'
]]
-- This is to fix the above error.
LUIE.HookPowerShield = function ()
    local LEFT_BAR, RIGHT_BAR = 1, 2
    local function ApplyPlatformStyleToShield(left, right, leftOverlay, rightOverlay)
        ApplyTemplateToControl(left, ZO_GetPlatformTemplate(leftOverlay))
        if rightOverlay then
            ApplyTemplateToControl(right, ZO_GetPlatformTemplate(rightOverlay))
        end
    end
    function ZO_UnitVisualizer_PowerShieldModule:ApplyPlatformStyle()
        if IsPlayerActivated() then
            for attribute, bar in pairs(self.attributeBarControls) do
                local barInfo = self.attributeInfo and self.attributeInfo[attribute]
                if barInfo and barInfo.overlayControls then
                    ApplyPlatformStyleToShield(barInfo.overlayControls[LEFT_BAR], barInfo.overlayControls[RIGHT_BAR], self.layoutData.barLeftOverlayTemplate, self.layoutData.barRightOverlayTemplate)
                    for visualType in pairs(barInfo.visualInfo) do
                        self:OnValueChanged(bar, barInfo, visualType)
                    end
                end
            end
        end
    end
end
