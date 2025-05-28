-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

-- Unit Frames namespace
--- @class (partial) UnitFrames
local UnitFrames = LUIE.UnitFrames

function UnitFrames.MenuUpdatePlayerFrameOptions(option)
    if UnitFrames.CustomFrames["reticleover"] then
        local reticleover = UnitFrames.CustomFrames["reticleover"]
        if option == 1 then
            reticleover.buffs:ClearAnchors()
            reticleover.debuffs:ClearAnchors()
            reticleover.buffs:SetAnchor(TOP, reticleover.buffAnchor, BOTTOM, 0, 2)
            reticleover.debuffs:SetAnchor(BOTTOM, reticleover.topInfo, TOP, 0, -2)
        else
            reticleover.buffs:ClearAnchors()
            reticleover.debuffs:ClearAnchors()
            reticleover.buffs:SetAnchor(BOTTOM, reticleover.topInfo, TOP, 0, -2)
            reticleover.debuffs:SetAnchor(TOP, reticleover.buffAnchor, BOTTOM, 0, 2)
        end
    end
    UnitFrames.CustomFramesResetPosition(true)
    UnitFrames.CustomFramesSetupAlternative()
    UnitFrames.CustomFramesApplyLayoutPlayer()
end

function UnitFrames.ResetCompassBarMenu()
    if UnitFrames.SV.DefaultFramesNewBoss == 2 then
        for i = 1, 7 do
            local unitTag = "boss" .. i
            if DoesUnitExist(unitTag) then
                COMPASS_FRAME:SetBossBarActive(true)
            end
        end
    else
        COMPASS_FRAME:SetBossBarActive(false)
    end
end

-- Unlock CustomFrames for moving. Called from Settings Menu.
function UnitFrames.CustomFramesSetMovingState(state)
    UnitFrames.CustomFramesMovingState = state

    -- Unlock individual frames
    for _, unitTag in pairs(
        {
            "player",
            "reticleover",
            "companion",
            "SmallGroup1",
            "RaidGroup1",
            "boss1",
            "AvaPlayerTarget",
            "PetGroup1",
        }) do
        if UnitFrames.CustomFrames[unitTag] and UnitFrames.CustomFrames[unitTag].tlw then
            local tlw = UnitFrames.CustomFrames[unitTag].tlw
            if tlw.preview then
                tlw.preview:SetHidden(not state) -- player frame does not have 'preview' control
            end
            tlw:SetMouseEnabled(state)
            tlw:SetMovable(state)
            tlw:SetHidden(false)

            --- @param self TopLevelWindow
            local function OnMoveStop(self)
                local left, top = self:GetLeft(), self:GetTop()
                left, top = LUIE.ApplyGridSnap(left, top, "unitFrames")
                self:ClearAnchors()
                self:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
                UnitFrames.SV[self.customPositionAttr] = { left, top }
            end
            -- Add grid snapping handler
            tlw:SetHandler("OnMoveStop", OnMoveStop)
        end
    end

    -- Unlock buffs for Player (preview control is created in SpellCastBuffs module)
    if UnitFrames.CustomFrames["player"] and UnitFrames.CustomFrames["player"].tlw then
        if UnitFrames.CustomFrames["player"].buffs.preview then
            UnitFrames.CustomFrames["player"].buffs.preview:SetHidden(not state)
        end
        if UnitFrames.CustomFrames["player"].debuffs.preview then
            UnitFrames.CustomFrames["player"].debuffs.preview:SetHidden(not state)
        end
    end

    -- Unlock buffs and debuffs for Target (preview controls are created in LTE and SpellCastBuffs modules)
    if UnitFrames.CustomFrames["reticleover"] and UnitFrames.CustomFrames["reticleover"].tlw then
        if UnitFrames.CustomFrames["reticleover"].buffs.preview then
            UnitFrames.CustomFrames["reticleover"].buffs.preview:SetHidden(not state)
        end
        if UnitFrames.CustomFrames["reticleover"].debuffs.preview then
            UnitFrames.CustomFrames["reticleover"].debuffs.preview:SetHidden(not state)
        end
        -- Make this hack so target window is not going to be hidden:
        -- Target Frame will now always display old information
        UnitFrames.CustomFrames["reticleover"].canHide = not state
    end
end

-- Apply selected colors for all known bars on custom unit frames
function UnitFrames.CustomFramesApplyColors(isMenu)
    local health =
    {
        UnitFrames.SV.CustomColourHealth[1],
        UnitFrames.SV.CustomColourHealth[2],
        UnitFrames.SV.CustomColourHealth[3],
        0.9,
    }
    local shield =
    {
        UnitFrames.SV.CustomColourShield[1],
        UnitFrames.SV.CustomColourShield[2],
        UnitFrames.SV.CustomColourShield[3],
        0,
    }
    local trauma =
    {
        UnitFrames.SV.CustomColourTrauma[1],
        UnitFrames.SV.CustomColourTrauma[2],
        UnitFrames.SV.CustomColourTrauma[3],
        0.9,
    } -- .a value will be fixed in the loop
    local magicka =
    {
        UnitFrames.SV.CustomColourMagicka[1],
        UnitFrames.SV.CustomColourMagicka[2],
        UnitFrames.SV.CustomColourMagicka[3],
        0.9,
    }
    local stamina =
    {
        UnitFrames.SV.CustomColourStamina[1],
        UnitFrames.SV.CustomColourStamina[2],
        UnitFrames.SV.CustomColourStamina[3],
        0.9,
    }

    local dps =
    {
        UnitFrames.SV.CustomColourDPS[1],
        UnitFrames.SV.CustomColourDPS[2],
        UnitFrames.SV.CustomColourDPS[3],
        0.9,
    }
    local healer =
    {
        UnitFrames.SV.CustomColourHealer[1],
        UnitFrames.SV.CustomColourHealer[2],
        UnitFrames.SV.CustomColourHealer[3],
        0.9,
    }
    local tank =
    {
        UnitFrames.SV.CustomColourTank[1],
        UnitFrames.SV.CustomColourTank[2],
        UnitFrames.SV.CustomColourTank[3],
        0.9,
    }
    local invalid = { 75 / 255, 75 / 255, 75 / 255, 0.9 }

    local class1 =
    {
        UnitFrames.SV.CustomColourDragonknight[1],
        UnitFrames.SV.CustomColourDragonknight[2],
        UnitFrames.SV.CustomColourDragonknight[3],
        0.9,
    } -- Dragonkight
    local class2 =
    {
        UnitFrames.SV.CustomColourSorcerer[1],
        UnitFrames.SV.CustomColourSorcerer[2],
        UnitFrames.SV.CustomColourSorcerer[3],
        0.9,
    } -- Sorcerer
    local class3 =
    {
        UnitFrames.SV.CustomColourNightblade[1],
        UnitFrames.SV.CustomColourNightblade[2],
        UnitFrames.SV.CustomColourNightblade[3],
        0.9,
    } -- Nightblade
    local class4 =
    {
        UnitFrames.SV.CustomColourWarden[1],
        UnitFrames.SV.CustomColourWarden[2],
        UnitFrames.SV.CustomColourWarden[3],
        0.9,
    } -- Warden
    local class5 =
    {
        UnitFrames.SV.CustomColourNecromancer[1],
        UnitFrames.SV.CustomColourNecromancer[2],
        UnitFrames.SV.CustomColourNecromancer[3],
        0.9,
    } -- Necromancer
    local class6 =
    {
        UnitFrames.SV.CustomColourTemplar[1],
        UnitFrames.SV.CustomColourTemplar[2],
        UnitFrames.SV.CustomColourTemplar[3],
        0.9,
    } -- Templar
    local class117 =
    {
        UnitFrames.SV.CustomColourArcanist[1],
        UnitFrames.SV.CustomColourArcanist[2],
        UnitFrames.SV.CustomColourArcanist[3],
        0.9,
    }                                                                                                                              -- Arcanist

    local petcolor = { UnitFrames.SV.CustomColourPet[1], UnitFrames.SV.CustomColourPet[2], UnitFrames.SV.CustomColourPet[3], 0.9 } -- Player Pet
    local companioncolor =
    {
        UnitFrames.SV.CustomColourCompanionFrame[1],
        UnitFrames.SV.CustomColourCompanionFrame[2],
        UnitFrames.SV.CustomColourCompanionFrame[3],
        0.9,
    } -- Companion

    local health_bg =
    {
        0.1 * UnitFrames.SV.CustomColourHealth[1],
        0.1 * UnitFrames.SV.CustomColourHealth[2],
        0.1 * UnitFrames.SV.CustomColourHealth[3],
        0.9,
    }
    local shield_bg =
    {
        0.1 * UnitFrames.SV.CustomColourShield[1],
        0.1 * UnitFrames.SV.CustomColourShield[2],
        0.1 * UnitFrames.SV.CustomColourShield[3],
        0.9,
    }
    local magicka_bg =
    {
        0.1 * UnitFrames.SV.CustomColourMagicka[1],
        0.1 * UnitFrames.SV.CustomColourMagicka[2],
        0.1 * UnitFrames.SV.CustomColourMagicka[3],
        0.9,
    }
    local stamina_bg =
    {
        0.1 * UnitFrames.SV.CustomColourStamina[1],
        0.1 * UnitFrames.SV.CustomColourStamina[2],
        0.1 * UnitFrames.SV.CustomColourStamina[3],
        0.9,
    }

    local dps_bg =
    {
        0.1 * UnitFrames.SV.CustomColourDPS[1],
        0.1 * UnitFrames.SV.CustomColourDPS[2],
        0.1 * UnitFrames.SV.CustomColourDPS[3],
        0.9,
    }
    local healer_bg =
    {
        0.1 * UnitFrames.SV.CustomColourHealer[1],
        0.1 * UnitFrames.SV.CustomColourHealer[2],
        0.1 * UnitFrames.SV.CustomColourHealer[3],
        0.9,
    }
    local tank_bg =
    {
        0.1 * UnitFrames.SV.CustomColourTank[1],
        0.1 * UnitFrames.SV.CustomColourTank[2],
        0.1 * UnitFrames.SV.CustomColourTank[3],
        0.9,
    }
    local invalid_bg = { 0.1 * invalid[1], 0.1 * invalid[2], 0.1 * invalid[3], 0.9 }

    local class1_bg =
    {
        0.1 * UnitFrames.SV.CustomColourDragonknight[1],
        0.1 * UnitFrames.SV.CustomColourDragonknight[2],
        0.1 * UnitFrames.SV.CustomColourDragonknight[3],
        0.9,
    } -- Dragonkight
    local class2_bg =
    {
        0.1 * UnitFrames.SV.CustomColourSorcerer[1],
        0.1 * UnitFrames.SV.CustomColourSorcerer[2],
        0.1 * UnitFrames.SV.CustomColourSorcerer[3],
        0.9,
    } -- Sorcerer
    local class3_bg =
    {
        0.1 * UnitFrames.SV.CustomColourNightblade[1],
        0.1 * UnitFrames.SV.CustomColourNightblade[2],
        0.1 * UnitFrames.SV.CustomColourNightblade[3],
        0.9,
    } -- Nightblade
    local class4_bg =
    {
        0.1 * UnitFrames.SV.CustomColourWarden[1],
        0.1 * UnitFrames.SV.CustomColourWarden[2],
        0.1 * UnitFrames.SV.CustomColourWarden[3],
        0.9,
    } -- Warden
    local class5_bg =
    {
        0.1 * UnitFrames.SV.CustomColourNecromancer[1],
        0.1 * UnitFrames.SV.CustomColourNecromancer[2],
        0.1 * UnitFrames.SV.CustomColourNecromancer[3],
        0.9,
    } -- Necromancer
    local class6_bg =
    {
        0.1 * UnitFrames.SV.CustomColourTemplar[1],
        0.1 * UnitFrames.SV.CustomColourTemplar[2],
        0.1 * UnitFrames.SV.CustomColourTemplar[3],
        0.9,
    } -- Templar
    local class117_bg =
    {
        0.1 * UnitFrames.SV.CustomColourArcanist[1],
        0.1 * UnitFrames.SV.CustomColourArcanist[2],
        0.1 * UnitFrames.SV.CustomColourArcanist[3],
        0.9,
    } -- Arcanist

    local petcolor_bg =
    {
        0.1 * UnitFrames.SV.CustomColourPet[1],
        0.1 * UnitFrames.SV.CustomColourPet[2],
        0.1 * UnitFrames.SV.CustomColourPet[3],
        0.9,
    } -- Player Pet
    local companioncolor_bg =
    {
        0.1 * UnitFrames.SV.CustomColourCompanionFrame[1],
        0.1 * UnitFrames.SV.CustomColourCompanionFrame[2],
        0.1 * UnitFrames.SV.CustomColourCompanionFrame[3],
        0.9,
    } -- Companion
    local invulnerablecolor =
    {
        UnitFrames.SV.CustomColourInvulnerable[1],
        UnitFrames.SV.CustomColourInvulnerable[2],
        UnitFrames.SV.CustomColourInvulnerable[3],
        0.9,
    } -- Invulnerable
    local invulnerablecolor_inlay =
    {
        UnitFrames.SV.CustomColourInvulnerable[1],
        UnitFrames.SV.CustomColourInvulnerable[2],
        UnitFrames.SV.CustomColourInvulnerable[3],
        0.9,
    }

    local isBattleground = IsActiveWorldBattleground()

    -- After color is applied unhide frames, so player can see changes even from menu
    for _, baseName in pairs({ "player", "reticleover", "boss", "AvaPlayerTarget" }) do
        shield[4] = (UnitFrames.SV.CustomShieldBarSeparate and not (baseName == "boss")) and 0.9 or (UnitFrames.SV.ShieldAlpha / 100)
        for i = 0, 7 do
            local unitTag = (i == 0) and baseName or (baseName .. i)
            if UnitFrames.CustomFrames[unitTag] and UnitFrames.CustomFrames[unitTag].tlw then
                local unitFrame = UnitFrames.CustomFrames[unitTag]
                local thb = unitFrame[COMBAT_MECHANIC_FLAGS_HEALTH] -- not a backdrop
                thb.bar:SetColor(unpack(health))
                thb.backdrop:SetCenterColor(unpack(health_bg))
                thb.shield:SetColor(unpack(shield))
                thb.trauma:SetColor(unpack(trauma))
                if thb.invulnerable then
                    thb.invulnerable:SetColor(unpack(invulnerablecolor))
                end
                if thb.invulnerableInlay then
                    thb.invulnerableInlay:SetColor(unpack(invulnerablecolor_inlay))
                end
                if thb.shieldbackdrop then
                    thb.shieldbackdrop:SetCenterColor(unpack(shield_bg))
                end
                if isMenu then
                    unitFrame.tlw:SetHidden(false)
                end
            end
        end
    end

    local petClass = GetUnitClassId("player")

    -- Player Companion Frame Color
    if UnitFrames.CustomFrames["companion"] and UnitFrames.CustomFrames["companion"].tlw then
        local unitFrame = UnitFrames.CustomFrames["companion"]
        local shb = unitFrame[COMBAT_MECHANIC_FLAGS_HEALTH] -- not a backdrop
        if UnitFrames.SV.CompanionUseClassColor then
            local class_color
            local class_bg
            if petClass == 1 then
                class_color = class1
                class_bg = class1_bg
            elseif petClass == 2 then
                class_color = class2
                class_bg = class2_bg
            elseif petClass == 3 then
                class_color = class3
                class_bg = class3_bg
            elseif petClass == 4 then
                class_color = class4
                class_bg = class4_bg
            elseif petClass == 5 then
                class_color = class5
                class_bg = class5_bg
            elseif petClass == 6 then
                class_color = class6
                class_bg = class6_bg
            elseif petClass == 117 then
                class_color = class117
                class_bg = class117_bg
            else -- Fallback option just in case
                class_color = petcolor
                class_bg = petcolor_bg
            end
            shb.bar:SetColor(unpack(class_color))
            shb.backdrop:SetCenterColor(unpack(class_bg))
        else
            shb.bar:SetColor(unpack(petcolor))
            shb.backdrop:SetCenterColor(unpack(petcolor_bg))
        end
        shb.shield:SetColor(unpack(shield))
        shb.trauma:SetColor(unpack(trauma))
        if shb.shieldbackdrop then
            shb.shieldbackdrop:SetCenterColor(unpack(shield_bg))
        end
        if isMenu then
            unitFrame.tlw:SetHidden(false)
        end
    end

    -- Player Pet Frame Color
    for i = 1, 7 do
        local unitTag = "PetGroup" .. i
        if UnitFrames.CustomFrames[unitTag] and UnitFrames.CustomFrames[unitTag].tlw then
            local unitFrame = UnitFrames.CustomFrames[unitTag]
            local shb = unitFrame[COMBAT_MECHANIC_FLAGS_HEALTH] -- not a backdrop
            if UnitFrames.SV.PetUseClassColor then
                local class_color
                local class_bg
                if petClass == 1 then
                    class_color = class1
                    class_bg = class1_bg
                elseif petClass == 2 then
                    class_color = class2
                    class_bg = class2_bg
                elseif petClass == 3 then
                    class_color = class3
                    class_bg = class3_bg
                elseif petClass == 4 then
                    class_color = class4
                    class_bg = class4_bg
                elseif petClass == 5 then
                    class_color = class5
                    class_bg = class5_bg
                elseif petClass == 6 then
                    class_color = class6
                    class_bg = class6_bg
                elseif petClass == 117 then
                    class_color = class117
                    class_bg = class117_bg
                else -- Fallback option just in case
                    class_color = petcolor
                    class_bg = petcolor_bg
                end
                shb.bar:SetColor(unpack(class_color))
                shb.backdrop:SetCenterColor(unpack(class_bg))
            else
                shb.bar:SetColor(unpack(companioncolor))
                shb.backdrop:SetCenterColor(unpack(companioncolor_bg))
            end
            shb.shield:SetColor(unpack(shield))
            shb.trauma:SetColor(unpack(trauma))
            if shb.shieldbackdrop then
                shb.shieldbackdrop:SetCenterColor(unpack(shield_bg))
            end
            if isMenu then
                unitFrame.tlw:SetHidden(false)
            end
        end
    end

    local groupSize = GetGroupSize()

    -- Variables to adjust frame when player frame is hidden in group
    local increment = false   -- Once we reach a value set by Increment Marker (group tag of the player), we need to increment all further tags by +1 in order to get the correct color for them.
    local incrementMarker = 0 -- Marker -- Once we reach this value in iteration, we have to add +1 to default unitTag index for all other units.
    for _, baseName in pairs({ "SmallGroup", "RaidGroup" }) do
        shield[4] = (UnitFrames.SV.CustomShieldBarSeparate and not (baseName == "RaidGroup")) and 0.9 or (UnitFrames.SV.ShieldAlpha / 100)

        -- Extra loop if player is excluded in Small Group Frames
        if UnitFrames.SV.GroupExcludePlayer and not (baseName == "RaidGroup") then
            -- Force increment groupTag by +1 for determining class/role if player frame is removed from display
            for i = 1, groupSize do
                if i > 4 then
                    break
                end
                local defaultUnitTag = GetGroupUnitTagByIndex(i)
                if AreUnitsEqual(defaultUnitTag, "player") then
                    incrementMarker = i
                end
            end
        end

        for i = 1, groupSize do
            local unitTag = baseName .. i
            if UnitFrames.CustomFrames[unitTag] and UnitFrames.CustomFrames[unitTag].tlw then
                if i == incrementMarker then
                    increment = true
                end
                local defaultUnitTag
                -- Set default frame reference to +1 if Player Frame is hidden and we reach that index, otherwise, proceed as normal
                if increment then
                    defaultUnitTag = GetGroupUnitTagByIndex(i + 1)
                    if i + 1 > 4 and baseName == "SmallGroup" then
                        break
                    end -- Bail out if we're at the end of the small group list
                else
                    defaultUnitTag = GetGroupUnitTagByIndex(i)
                end

                -- Also update control for Right Click Menu
                UnitFrames.CustomFrames[unitTag].control.defaultUnitTag = defaultUnitTag
                if UnitFrames.CustomFrames[unitTag].topInfo then
                    UnitFrames.CustomFrames[unitTag].topInfo.defaultUnitTag = defaultUnitTag
                end

                local class = GetUnitClassId(defaultUnitTag)
                local role = isBattleground and LFG_ROLE_DPS or GetGroupMemberSelectedRole(defaultUnitTag)

                local unitFrame = UnitFrames.CustomFrames[unitTag]
                local thb = unitFrame[COMBAT_MECHANIC_FLAGS_HEALTH] -- not a backdrop

                local group = groupSize <= 4
                local raid = groupSize > 4
                if not UnitFrames.SV.CustomFramesGroup then
                    raid = true
                    group = false
                end

                if (group and UnitFrames.SV.ColorRoleGroup) or (raid and UnitFrames.SV.ColorRoleRaid) then
                    if role == LFG_ROLE_DPS then
                        thb.bar:SetColor(unpack(dps))
                        thb.backdrop:SetCenterColor(unpack(dps_bg))
                    elseif role == LFG_ROLE_HEAL then
                        thb.bar:SetColor(unpack(healer))
                        thb.backdrop:SetCenterColor(unpack(healer_bg))
                    elseif role == LFG_ROLE_TANK then
                        thb.bar:SetColor(unpack(tank))
                        thb.backdrop:SetCenterColor(unpack(tank_bg))
                    else
                        thb.bar:SetColor(unpack(invalid)) -- do not use health as fallback because it might look like tank
                        thb.backdrop:SetCenterColor(unpack(invalid_bg))
                    end
                elseif (group and UnitFrames.SV.ColorClassGroup) or (raid and UnitFrames.SV.ColorClassRaid) and class ~= 0 then
                    local class_color
                    local class_bg
                    if class == 1 then
                        class_color = class1
                        class_bg = class1_bg
                    elseif class == 2 then
                        class_color = class2
                        class_bg = class2_bg
                    elseif class == 3 then
                        class_color = class3
                        class_bg = class3_bg
                    elseif class == 4 then
                        class_color = class4
                        class_bg = class4_bg
                    elseif class == 5 then
                        class_color = class5
                        class_bg = class5_bg
                    elseif class == 6 then
                        class_color = class6
                        class_bg = class6_bg
                    elseif class == 117 then
                        class_color = class117
                        class_bg = class117_bg
                    else -- Fallback option just in case
                        class_color = invalid
                        class_bg = invalid_bg
                    end
                    thb.bar:SetColor(unpack(class_color))
                    thb.backdrop:SetCenterColor(unpack(class_bg))
                else
                    thb.bar:SetColor(unpack(health))
                    thb.backdrop:SetCenterColor(unpack(health_bg))
                end
                thb.shield:SetColor(unpack(shield))
                thb.trauma:SetColor(unpack(trauma))
                if thb.shieldbackdrop then
                    thb.shieldbackdrop:SetCenterColor(unpack(shield_bg))
                end
                if isMenu then
                    unitFrame.tlw:SetHidden(false)
                end
            end
        end
    end

    -- Player frame also requires setting of magicka and stamina bars
    if UnitFrames.CustomFrames["player"] and UnitFrames.CustomFrames["player"].tlw then
        UnitFrames.CustomFrames["player"][COMBAT_MECHANIC_FLAGS_MAGICKA].bar:SetColor(unpack(magicka))
        UnitFrames.CustomFrames["player"][COMBAT_MECHANIC_FLAGS_MAGICKA].backdrop:SetCenterColor(unpack(magicka_bg))
        UnitFrames.CustomFrames["player"][COMBAT_MECHANIC_FLAGS_STAMINA].bar:SetColor(unpack(stamina))
        UnitFrames.CustomFrames["player"][COMBAT_MECHANIC_FLAGS_STAMINA].backdrop:SetCenterColor(unpack(stamina_bg))
    end
end

-- Reload Names from Menu function call
function UnitFrames.CustomFramesReloadControlsMenu(player, group, raid)
    UnitFrames.UpdateStaticControls(UnitFrames.DefaultFrames["player"])
    UnitFrames.UpdateStaticControls(UnitFrames.CustomFrames["player"])
    UnitFrames.UpdateStaticControls(UnitFrames.AvaCustFrames["player"])

    UnitFrames.UpdateStaticControls(UnitFrames.DefaultFrames["reticleover"])
    UnitFrames.UpdateStaticControls(UnitFrames.CustomFrames["reticleover"])
    UnitFrames.UpdateStaticControls(UnitFrames.AvaCustFrames["reticleover"])

    for i = 1, 12 do
        local unitTag = "group" .. i
        UnitFrames.UpdateStaticControls(UnitFrames.DefaultFrames[unitTag])
        UnitFrames.UpdateStaticControls(UnitFrames.CustomFrames[unitTag])
        UnitFrames.UpdateStaticControls(UnitFrames.AvaCustFrames[unitTag])
    end

    UnitFrames.CustomFramesApplyLayoutPlayer(player)
    UnitFrames.CustomFramesApplyLayoutGroup(group)
    UnitFrames.CustomFramesApplyLayoutRaid(raid)
end

function UnitFrames.CustomFramesReloadExecuteMenu()
    UnitFrames.targetThreshold = UnitFrames.SV.ExecutePercentage

    if UnitFrames.DefaultFrames.reticleover[COMBAT_MECHANIC_FLAGS_HEALTH] then
        UnitFrames.DefaultFrames.reticleover[COMBAT_MECHANIC_FLAGS_HEALTH].threshold = UnitFrames.targetThreshold
    end
    if UnitFrames.CustomFrames["reticleover"] and UnitFrames.CustomFrames["reticleover"][COMBAT_MECHANIC_FLAGS_HEALTH] then
        UnitFrames.CustomFrames["reticleover"][COMBAT_MECHANIC_FLAGS_HEALTH].threshold = UnitFrames.targetThreshold
    end
    if UnitFrames.AvaCustFrames["reticleover"] and UnitFrames.AvaCustFrames["reticleover"][COMBAT_MECHANIC_FLAGS_HEALTH] then
        UnitFrames.AvaCustFrames["reticleover"][COMBAT_MECHANIC_FLAGS_HEALTH].threshold = UnitFrames.targetThreshold
    end

    for i = 1, 7 do
        local unitTag = "boss" .. i
        if UnitFrames.CustomFrames[unitTag] and UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH] then
            UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].threshold = UnitFrames.targetThreshold
        end
    end
end
