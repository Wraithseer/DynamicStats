ChampionPoints = {
    modifiers = {
        [31] = { name = "CriticalDamage", value = 10, additive = true },
        [66] = { name = "MovementSpeed", value = 20, additive = true },
        [92] = { name = "MountedSpeed", value = 0.1, additive = false },
        [270] = { name = "MovementSpeed", value = 10, additive = true },
    },
    FORCE_OF_NATURE = 276,
    raceModifiers = {
        ["Wood Elf"] = { name = "MovementSpeed", value = 5, additive = true }
    }
}


MundusStones =
{
    [13940] = { name = "The Warrior", value = 238 },    -- Increases Weapon Damage
    [13943] = { name = "The Mage", value = 2023 },      -- Increases Maximum Magicka
    [13974] = { name = "The Serpent", value = 310 },    -- Increases Stamina Recovery
    [13975] = { name = "The Thief", value = 1333 },     -- Increases Critical Strike Rating
    [13976] = { name = "The Lady", value = 2744 },      -- Increases Physical and Spell Resistance
    [13977] = { name = "The Steed", value = 10 },       -- Increases Movement Speed and Health Recovery
    [13978] = { name = "The Lord", value = 2225 },      -- Increases Maximum Health
    [13979] = { name = "The Apprentice", value = 238 }, -- Increases Spell Damage
    [13981] = { name = "The Lover", value = 2744 },     -- Increases Physical and Spell Penetration
    [13982] = { name = "The Atronach", value = 310 },   -- Increases Magicka Recovery
    [13985] = { name = "The Tower", value = 2023 },     -- Increases Maximum Stamina

    DIVINES_GEAR_QUAL_BONUS = {
        [1] = 0.051,
        [2] = 0.061,
        [3] = 0.071,
        [4] = 0.081,
        [5] = 0.091
    },
}


Player = {}
Player.__index = Player
function Player:new()
    local instance = {
        BASE_CRITICAL_DAMAGE = 50,
        BASE_MOVEMENT_SPEED = 100,
        BASE_MOUNTED_SPEED = 115,
        CRIT_COEFFICIENT = 219.1,
        Stats = {
            ["Damage"] = 0,
            ["CriticalChanceWep"] = 0,
            ["CriticalChanceSpell"] = 0,
            ["PhysicalResistance"] = 0,
            ["SpellResistance"] = 0,
            ["ArmorPenetration"] = 0,
            ["CriticalDamage"] = 0,
            ["MovementSpeed"] = 0,
            ["MountedSpeed"] = 0,
        },
        Flags = {
            IN_COMBAT = false,
            IS_SPRINTING = false,
            IS_WEARING_ROTW = false
        },
        Buffs = {
            Speed = {
                [61735] = 15,               -- Minor Expedition
                [61736] = 30,               -- Major Expedition
            },
            MountSpeed = { [63569] = 0.3 }, --Major Gallop (multiplicative)
        },
        ChampionPoints = {},
        ActiveMundus = 0,
        Modifiers = {
            added_crit = 0,
            added_penetration = 0,
            divines_multiplier = 0
        },
        GearCache = {},
        GEAR_CACHE_SIZE = 54,
        Target
    }
    return setmetatable(instance, Player)
end

function Player:PopulateStats()
    self.Flags.IS_SPRINTING = IsShiftKeyDown()
    self.Stats["MovementSpeed"] = self:calculateMovementSpeed()
    self.Stats["MountedSpeed"] = self:calculateMountedSpeed()
    self.Stats["CriticalDamage"] = self:calculateCritDmg()
    self.Stats["ArmorPenetration"] = GetPlayerStat(STAT_PHYSICAL_PENETRATION) + self.Modifiers.added_penetration
    self.Stats["Damage"] = zo_max(GetPlayerStat(STAT_POWER, STAT_BONUS_OPTION_APPLY_BONUS),
        GetPlayerStat(STAT_SPELL_POWER, STAT_BONUS_OPTION_APPLY_BONUS))
    self.Stats["CriticalChanceWep"] = GetPlayerStat(STAT_CRITICAL_STRIKE, STAT_BONUS_OPTION_APPLY_BONUS) /
        self.CRIT_COEFFICIENT
    self.Stats["CriticalChanceSpell"] = GetPlayerStat(STAT_SPELL_CRITICAL, STAT_BONUS_OPTION_APPLY_BONUS) /
        self.CRIT_COEFFICIENT
    self.Stats["PhysicalResistance"] = GetPlayerStat(STAT_PHYSICAL_RESIST, STAT_BONUS_OPTION_APPLY_BONUS)
    self.Stats["SpellResistance"] = GetPlayerStat(STAT_SPELL_RESIST, STAT_BONUS_OPTION_APPLY_BONUS)
    self.Modifiers.added_penetration = 0
    self.Modifiers.added_crit = 0
    self.Modifiers.divines_multiplier = 0
end

function Player:calculateMovementSpeed()
    local movementSpeed = self.BASE_MOVEMENT_SPEED or 0

    if self.Flags.IS_WEARING_ROTW then
        if self.Flags.IN_COMBAT then
            movementSpeed = movementSpeed + 15
        else
            movementSpeed = movementSpeed + 45
        end
    end
    if self.Flags.IS_SPRINTING then
        movementSpeed = movementSpeed + 30
    end
    for id, CP in pairs(self.ChampionPoints) do
        if CP.name == "Celerity" then
            movementSpeed = movementSpeed + CP.value
        end
    end
    return movementSpeed
end

function Player:calculateMountedSpeed()
    local movementSpeed = self.BASE_MOUNTED_SPEED
    return movementSpeed
end

function Player:calculateCritDmg()
    return self.BASE_CRITICAL_DAMAGE + select(-1, GetAdvancedStatValue(ADVANCED_STAT_DISPLAY_TYPE_CRITICAL_DAMAGE)) +
        (self.Modifiers.added_crit)
end

function Player:UpdateGear()
    self.Flags.IS_WEARING_ROTW = false
    for slotIndex = 0, Player:getBagSize() - 1 do
        local itemName = GetItemName(bagId, slotIndex)
        local itemTrait = GetItemTrait(bagId, slotIndex)
        local itemQuality = GetItemQuality(bagId, slotIndex)
        local itemKey = itemName .. itemTrait .. itemQuality

        if not self.GearCache[itemKey] then
            self.GearCache[itemKey] = Gear:new(slotIndex, itemName, itemTrait, itemQuality)
        end
        self:equipGear(self.GearCache[itemKey])
    end

    if #self.GearCache > self.GEAR_CACHE_SIZE then
        table.remove(self.GearCache, 1)
    end
end

function Player:UpdateBuffs()
    for i = 1, GetNumBuffs('player') do
        local _, _, _, _, _, _, _, _, _, _, abilityIdS = GetUnitBuffInfo('player', i)
        if self.Buffs.Speed[abilityIdS] then
            self.Stats["MovementSpeed"] = self.Stats["MovementSpeed"] + self.Buffs.Speed[abilityIdS]
        end
        if self.Buffs.MountSpeed[abilityIdS] then
            self.Stats["MountedSpeed"] = self.Stats["MountedSpeed"] * self.Buffs.MountSpeed[abilityIdS]
        end
        if MundusStones[abilityIdS] then
            self.ActiveMundus = abilityIdS
        end
    end
end

function Player:UpdateStats()
    self:PopulateStats()
    if self.Target then
        self.Stats["CriticalDamage"] = self.Stats["CriticalDamage"] + self.Target.added_crit
        self.Stats["ArmorPenetration"] = self.Stats["ArmorPenetration"] + self.Target.added_penetration
    end
    self:UpdateBuffs()
    self:UpdateGear()

    local effect = MundusStones[self.ActiveMundus].value
    effect = effect * (1 + self.Modifiers.divines_multiplier)
    if MundusStones[self.ActiveMundus].name == "The Steed" then
        self.Stats["MovementSpeed"] = self.Stats["MovementSpeed"] + effect
    end
end

function Player:equipGear(gear)
    if gear.trait == ITEM_TRAIT_TYPE_JEWELRY_SWIFT then
        self.Stats["MovementSpeed"] = self.Stats["MovementSpeed"] + gear:getSwiftTraitBonus()
    elseif gear.trait == ITEM_TRAIT_TYPE_ARMOR_DIVINES then
        self.Modifiers.divines_multiplier = self.Modifiers.divines_multiplier +
        MundusStones.DIVINES_GEAR_QUAL_BONUS[gear.quality]
    end
    if gear.name == "Ring of the Wild Hunt" then
        self.Flags.IS_WEARING_ROTW = true
    end
end

function Player:UpdateStatFromModifier(modifier)
    if modifier.additive then
        self.Stats[modifier.name] = self.Stats[modifier.name] + modifier.value
    else
        self.Stats[modifier.name] = self.Stats[modifier.name] * modifier.value
    end
end

function Player:updateChampionPoints()
    for disciplineIndex = 0, 12 do
        local championSkillId = GetSlotBoundId(disciplineIndex, HOTBAR_CATEGORY_CHAMPION)
        local modifier = ChampionPoints.modifiers[championSkillId]
        if modifier then
            self.UpdateStatFromModifier(modifier)
        else
            local race = ChampionPoints.raceModifiers[GetUnitRace("player")]
        end
    end
end

function Player:getBagSize(id)
    local bagId = id or BAG_WORN
    local bagSize = GetBagSize(bagId)
    return bagSize
end
