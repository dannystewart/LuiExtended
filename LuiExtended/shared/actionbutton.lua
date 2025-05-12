---@diagnostic disable: duplicate-set-field
-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

local Data = LuiData.Data
local Effects = Data.Effects

LUIE.HookActionButton = function ()
    -- Hook Action Slots
    local ACTION_BUTTON_BGS = { ability = "EsoUI/Art/ActionBar/abilityInset.dds", item = "EsoUI/Art/ActionBar/quickslotBG.dds" }
    local ACTION_BUTTON_BORDERS = { normal = "EsoUI/Art/ActionBar/abilityFrame64_up.dds", mouseDown = "EsoUI/Art/ActionBar/abilityFrame64_down.dds" }

    local function SetupActionSlot(slotObject, slotId)
        local slotIcon = GetSlotTexture(slotId, slotObject:GetHotbarCategory())
        local abilityId = LUIE.GetSlotTrueBoundId(slotId, slotObject:GetHotbarCategory())
        if Effects.BarIdOverride[abilityId] then
            slotIcon = Effects.BarIdOverride[abilityId]
        end
        slotObject:SetEnabled(true)
        local isGamepad = IsInGamepadPreferredMode()
        ZO_ActionSlot_SetupSlot(slotObject.icon, slotObject.button, slotIcon, isGamepad and "" or ACTION_BUTTON_BORDERS.normal, isGamepad and "" or ACTION_BUTTON_BORDERS.mouseDown, slotObject.cooldownIcon)
        slotObject:UpdateState()
    end

    local function SetupActionSlotWithBg(slotObject, slotId)
        SetupActionSlot(slotObject, slotId)
        slotObject.bg:SetTexture(ACTION_BUTTON_BGS.ability)
    end

    local function SetupAbilitySlot(slotObject, slotId)
        SetupActionSlotWithBg(slotObject, slotId)

        if ZO_ActionBar_IsUltimateSlot(slotId, slotObject:GetHotbarCategory()) then
            slotObject:RefreshUltimateNumberVisibility()
        else
            slotObject:ClearCount()
        end
    end

    local function SetupItemSlot(slotObject, slotId)
        SetupActionSlotWithBg(slotObject, slotId)
        slotObject:SetupCount()
    end

    local function SetupCollectibleActionSlot(slotObject, slotId)
        SetupActionSlotWithBg(slotObject, slotId)
        slotObject:ClearCount()
    end

    local function SetupQuestItemActionSlot(slotObject, slotId)
        SetupActionSlotWithBg(slotObject, slotId)
        slotObject:SetupCount()
    end

    local function SetupEmoteActionSlot(slotObject, slotId)
        SetupActionSlotWithBg(slotObject, slotId)
        slotObject:ClearCount()
    end

    local function SetupQuickChatActionSlot(slotObject, slotId)
        SetupActionSlotWithBg(slotObject, slotId)
        slotObject:ClearCount()
    end

    local function SetupEmptyActionSlot(slotObject, slotId)
        slotObject:Clear()
    end

    SetupSlotHandlers =
    {
        [ACTION_TYPE_ABILITY]         = SetupAbilitySlot,
        [ACTION_TYPE_ITEM]            = SetupItemSlot,
        [ACTION_TYPE_CRAFTED_ABILITY] = SetupAbilitySlot,
        [ACTION_TYPE_COLLECTIBLE]     = SetupCollectibleActionSlot,
        [ACTION_TYPE_QUEST_ITEM]      = SetupQuestItemActionSlot,
        [ACTION_TYPE_EMOTE]           = SetupEmoteActionSlot,
        [ACTION_TYPE_QUICK_CHAT]      = SetupQuickChatActionSlot,
        [ACTION_TYPE_NOTHING]         = SetupEmptyActionSlot,
    }

    -- Hook to make Activation Highlight Effect play indefinitely instead of animation only once
    function ActionButton:UpdateActivationHighlight()
        local slotnum = self:GetSlot()
        local hotbarCategory = self.slot.slotNum == 1 and HOTBAR_CATEGORY_QUICKSLOT_WHEEL or self.slot.hotbarCategory
        local slotType = GetSlotType(slotnum, hotbarCategory)
        local slotIsEmpty = (slotType == ACTION_TYPE_NOTHING)

        local abilityId = LUIE.GetSlotTrueBoundId(slotnum, hotbarCategory) -- Check AbilityId for if this should be a fake activation highlight

        local showHighlight = not slotIsEmpty and (ActionSlotHasActivationHighlight(slotnum, hotbarCategory) or Effects.IsAbilityActiveGlow[abilityId] == true) and not self.useFailure and not self.showingCooldown
        local isShowingHighlight = self.activationHighlight:IsHidden() == false

        if showHighlight ~= isShowingHighlight then
            self.activationHighlight:SetHidden(not showHighlight)

            if showHighlight then
                local _, _, activationAnimationTexture = GetSlotTexture(slotnum, hotbarCategory)
                self.activationHighlight:SetTexture(activationAnimationTexture)

                local anim = self.activationHighlight.animation
                if not anim then
                    anim = CreateSimpleAnimation(ANIMATION_TEXTURE, self.activationHighlight)
                    anim:SetImageData(64, 1)
                    anim:SetFramerate(30)
                    anim:GetTimeline():SetPlaybackType(ANIMATION_PLAYBACK_LOOP, LOOP_INDEFINITELY)

                    self.activationHighlight.animation = anim
                end

                anim:GetTimeline():PlayFromStart()
            else
                local anim = self.activationHighlight.animation
                if anim then
                    anim:GetTimeline():Stop()
                end
            end
        end
    end

    -- Hook to add AVA Guard Ability + Morphs into Toggle Highlights
    function ActionButton:UpdateState()
        local slotnum = self:GetSlot()
        local hotbarCategory = self.slot.slotNum == 1 and HOTBAR_CATEGORY_QUICKSLOT_WHEEL or self.slot.hotbarCategory
        local slotType = GetSlotType(slotnum, hotbarCategory)
        local slotIsEmpty = (slotType == ACTION_TYPE_NOTHING)
        local abilityId = LUIE.GetSlotTrueBoundId(slotnum, hotbarCategory) -- Check AbilityId for if this should be a fake activation highlight

        self.button.actionId = LUIE.GetSlotTrueBoundId(slotnum, hotbarCategory)

        self:UpdateUseFailure()

        local hidden = true

        -- Add toggle highlight for abilities that need it (Guard + morphs)
        if IsSlotToggled(slotnum, hotbarCategory) == true or Effects.IsAbilityActiveHighlight[abilityId] then
            hidden = false
        end

        -- If LUIE Bar Highlight is enabled, hide certain "Toggle effects" (aka Blood Frenzy + morphs)
        if IsSlotToggled(slotnum, hotbarCategory) == true and Effects.RemoveAbilityActiveHighlight[abilityId] and LUIE.CombatInfo.SV.ShowToggled then
            hidden = true
        end

        self.status:SetHidden(hidden)

        self:UpdateActivationHighlight()
        self:UpdateCooldown(true)
    end

    function ActionButton:HandleSlotChanged(hotbarCategory)
        -- We no longer use self.button.hotbarCategory, but are keeping it around for addon compatibility
        self.slot.hotbarCategory = hotbarCategory
        self.button.hotbarCategory = hotbarCategory

        local slotId = self:GetSlot()
        local slotType = GetSlotType(slotId, hotbarCategory)

        local setupSlotHandler = SetupSlotHandlers[slotType]
        if assert(setupSlotHandler, "update slot handlers") then
            setupSlotHandler(self, slotId)
        end

        self:SetShowCooldown(false)
        self:UpdateState()

        local mouseOverControl = WINDOW_MANAGER:GetMouseOverControl()
        if mouseOverControl == self.button then
            ZO_AbilitySlot_OnMouseEnter(self.button)
        end
    end
end
