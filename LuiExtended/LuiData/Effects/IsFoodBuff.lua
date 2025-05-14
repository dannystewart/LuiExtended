-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData

local Data = LuiData.Data
--- @class (partial) Effects
local Effects = Data.Effects

-- Food & Drink Buffs
Effects.IsFoodBuff =
{
    -- Food Buff
    [17407]  = true, -- Increase Max Health
    [17577]  = true, -- Increase Max Magicka & Stamina
    [17581]  = true, -- Increase All Primary Stats
    [17608]  = true, -- Magicka & Stamina Recovery
    [17614]  = true, -- All Primary Stat Recovery
    [61218]  = true, -- Increase All Primary Stats
    [61255]  = true, -- Increase Max Health & Stamina
    [61257]  = true, -- Increase Max Health & Magicka
    [61259]  = true, -- Increase Max Health
    [61260]  = true, -- Increase Max Magicka
    [61261]  = true, -- Increase Max Stamina
    [61294]  = true, -- Increase Max Magicka & Stamina
    [66128]  = true, -- Increase Max Magicka
    [66130]  = true, -- Increase Max Stamina
    [66551]  = true, -- Garlic and Pepper Venison Steak
    [66568]  = true, -- Increase Max Magicka
    [66576]  = true, -- Increase Max Stamina
    [68411]  = true, -- Crown store
    [72819]  = true, -- Tripe Trifle Pocket
    [72822]  = true, -- Blood Price Pie
    [72824]  = true, -- Smoked Bear Haunch
    [72956]  = true, -- Max Health and Stamina (Cyrodilic Field Tack)
    [72959]  = true, -- Max Health and Magicka (Cyrodilic Field Treat)
    [72961]  = true, -- Max Stamina and Magicka (Cyrodilic Field Bar)
    [84678]  = true, -- Increase Max Magicka
    [84681]  = true, -- Pumpkin Snack Skewer
    [84709]  = true, -- Crunchy Spider Skewer
    [84725]  = true, -- The Brains!
    [84736]  = true, -- Increase Max Health
    [85484]  = true, -- Increase All Primary Stats
    [86749]  = true, -- Mud Ball
    [86787]  = true, -- Rajhin's Sugar Claws
    [86789]  = true, -- Alcaire Festival Sword-Pie
    [89955]  = true, -- Candied Jester's Coins
    [89971]  = true, -- Jewels of Misrule
    [92435]  = true, -- Increase Health & Magicka
    [92437]  = true, -- Increase Health (but descriptions says max magicka)
    [92474]  = true, -- Increase Health & Stamina
    [92477]  = true, -- Increase Health (but descriptions says max magicka)
    [100498] = true, -- Clockwork Citrus Filet
    [100502] = true, -- Deregulated Mushroom Stew
    [107748] = true, -- Lure Allure
    [107789] = true, -- Artaeum Takeaway Broth
    [127537] = true, -- Increase Health (but descriptions says max magicka)
    [127578] = true, -- Increase Health (but descriptions says max magicka)
    [127596] = true, -- Bewitched Sugar Skulls
    [127619] = true, -- Increase Health (but descriptions says max magicka)
    [127736] = true, -- Increase Health (but descriptions says max magicka)
    -- Drink Buff
    [61322]  = true, -- Health Recovery
    [61325]  = true, -- Magicka Recovery
    [61328]  = true, -- Health & Magicka Recovery
    [61335]  = true, -- Health & Magicka Recovery
    [61340]  = true, -- Health & Stamina Recovery
    [61345]  = true, -- Magicka & Stamina Recovery
    [61350]  = true, -- All Primary Stat Recovery
    [66125]  = true, -- Increase Max Health
    [66132]  = true, -- Health Recovery (Alcoholic Drinks)
    [66137]  = true, -- Magicka Recovery (Tea)
    [66141]  = true, -- Stamina Recovery (Tonics)
    [66586]  = true, -- Health Recovery
    [66590]  = true, -- Magicka Recovery
    [66594]  = true, -- Stamina Recovery
    [68416]  = true, -- All Primary Stat Recovery (Crown Refreshing Drink)
    [72816]  = true, -- Red Frothgar
    [72965]  = true, -- Health and Stamina Recovery (Cyrodilic Field Brew)
    [72968]  = true, -- Health and Magicka Recovery (Cyrodilic Field Tea)
    [72971]  = true, -- Magicka and Stamina Recovery (Cyrodilic Field Tonic)
    [84700]  = true, -- 2h Witches event: Eyeballs
    [84704]  = true, -- 2h Witches event: Witchmother's Party Punch
    [84720]  = true, -- 2h Witches event: Eye Scream
    [84731]  = true, -- 2h Witches event: Witchmother's Potent Brew
    [84732]  = true, -- Increase Health Regen
    [84733]  = true, -- Increase Health Regen
    [84735]  = true, -- 2h Witches event: Double Bloody Mara
    [85497]  = true, -- All Primary Stat Recovery
    [86559]  = true, -- Hissmir Fish Eye Rye
    [86560]  = true, -- Stamina Recovery
    [86673]  = true, -- Lava Foot Soup & Saltrice
    [86674]  = true, -- Stamina Recovery
    [86677]  = true, -- Warning Fire (Bergama Warning Fire)
    [86678]  = true, -- Health Recovery
    [86746]  = true, -- Betnikh Spiked Ale (Betnikh Twice-Spiked Ale)
    [86747]  = true, -- Health Recovery
    [86791]  = true, -- Increase Stamina Recovery (Ice Bear Glow-Wine)
    [89957]  = true, -- Dubious Camoran Throne
    [92433]  = true, -- Health & Magicka Recovery
    [92476]  = true, -- Health & Stamina Recovery
    [100488] = true, -- Spring-Loaded Infusion
    [127531] = true, -- Disastrously Bloody Mara
    [127572] = true, -- Pack Leader's Bone Broth
    [148633] = true, -- Sparkling Mudcrab Apple Cider
}
