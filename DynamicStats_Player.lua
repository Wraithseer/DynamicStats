local STEED_MUNDUS_ID = 13977
local STEED_MUNDUS_BASE_EFFECT = 10
local MUNDUS_DIVINES_BONUS = {
    [1] = 0.051,
    [2] = 0.061,
    [3] = 0.071,
    [4] = 0.081,
    [5] = 0.091
}
Player = {}
Player.__index = Player
function Player:new()
    local instance = {
        BASE_CRITICAL_DAMAGE = 50,
        BASE_MOVEMENT_SPEED = 100,
        BASE_MOUNTED_SPEED = 115,
        ARMOR_CAP = 33000,
        MOVEMENT_CAP = 200,
        CRIT_COEFFICIENT = 219.1,
        MOUNT_SPRINT_SPEED = 30,
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
        ChampionPoints = {
            modifiers = {
                [31] = { name = "CriticalDamage", value = 10, additive = true, slotted = false },
                [66] = { name = "MovementSpeed", value = 20, additive = true, slotted = false },
                [92] = { name = "MountedSpeed", value = 0.1, additive = false, slotted = false },
                [270] = { name = "MovementSpeed", value = 10, additive = true, slotted = false },
            },
            FORCE_OF_NATURE = 276,
            raceModifiers = {
                ["Wood Elf"] = { name = "MovementSpeed", value = 5, additive = true, slotted = false }
            }
        },
        SteedMundus = false,
        Modifiers = {
            added_crit = 0,
            added_penetration = 0,
            divines_multiplier = 0
        },
        GearCache = {},
        GEAR_CACHE_SIZE = 6,
        Target
    }
    return setmetatable(instance, Player)
end

function Player:PopulateStats()
    self.Flags.IS_SPRINTING = IsShiftKeyDown()
    self.Stats["MovementSpeed"] = self.BASE_MOVEMENT_SPEED
    self.Stats["MountedSpeed"] = self.BASE_MOUNTED_SPEED
    self.Stats["CriticalDamage"] = self.BASE_CRITICAL_DAMAGE
    self.Stats["ArmorPenetration"] = GetPlayerStat(STAT_PHYSICAL_PENETRATION)
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
    if self.Stats["MovementSpeed"] == 0 then self.Stats["MovementSpeed"] = self.BASE_MOVEMENT_SPEED end
    if self.Flags.IS_WEARING_ROTW then
        if self.Flags.IN_COMBAT then
            self.Stats["MovementSpeed"] =  self.Stats["MovementSpeed"] + 15
        else
            self.Stats["MovementSpeed"] =  self.Stats["MovementSpeed"] + 45
        end
    end
    if self.Flags.IS_SPRINTING then
        local sprintMultiplier = select(3,GetAdvancedStatValue(ADVANCED_STAT_DISPLAY_TYPE_SPRINT_SPEED)) 
        self.Stats["MovementSpeed"] =  self.Stats["MovementSpeed"] + sprintMultiplier - 100
        self.Stats["MountedSpeed"] = self.Stats["MountedSpeed"] + self.MOUNT_SPRINT_SPEED
    end

   --TODO: implement if self.Flags.IS_CROUCHED then
end

function Player:calculateCritDmg()
    if self.Stats["CriticalDamage"] == 0 then self.Stats["CriticalDamage"] = self.BASE_CRITICAL_DAMAGE end
    self.Stats["CriticalDamage"] = self.BASE_CRITICAL_DAMAGE + select(-1, GetAdvancedStatValue(ADVANCED_STAT_DISPLAY_TYPE_CRITICAL_DAMAGE)) +
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

function Player:ApplyBuffsToStats()
    for i = 1, GetNumBuffs('player') do
        local _, _, _, _, _, _, _, _, _, _, abilityIdS = GetUnitBuffInfo('player', i) -- TODO: select
        if self.Buffs.Speed[abilityIdS] then
            self.Stats["MovementSpeed"] = self.Stats["MovementSpeed"] + self.Buffs.Speed[abilityIdS]
        end
        if self.Buffs.MountSpeed[abilityIdS] then
            self.Stats["MountedSpeed"] = self.Stats["MountedSpeed"] * (1 + self.Buffs.MountSpeed[abilityIdS])
        end
        if abilityIdS == STEED_MUNDUS_ID then
            self.SteedMundus = true
        end
    end
end
function Player:UpdateStats()
    if self.Target then
        self.Stats["CriticalDamage"] = self.Stats["CriticalDamage"] + self.Target.added_crit
        self.Stats["ArmorPenetration"] = self.Stats["ArmorPenetration"] + self.Target.added_penetration
    end
    local ridingLessonBonus= select(5,GetRidingStats("player"))
    self.Stats["MountedSpeed"] = self.Stats["MountedSpeed"] + ridingLessonBonus
    self:calculateMovementSpeed()
    self:calculateCritDmg()
    if self.SteedMundus then
        local effect = STEED_MUNDUS_BASE_EFFECT * (1 + self.Modifiers.divines_multiplier)
        self.Stats["MovementSpeed"] = self.Stats["MovementSpeed"] + effect
    end
end

function Player:Update()
    self:PopulateStats()
    self:ApplyBuffsToStats()
    self:UpdateGear()
    self:ApplyChampionPointBonuses() 
    self:UpdateStats()
end

function Player:equipGear(gear)
    if gear.trait == ITEM_TRAIT_TYPE_JEWELRY_SWIFT then
        self.Stats["MovementSpeed"] = self.Stats["MovementSpeed"] + gear:getSwiftTraitBonus()
    elseif gear.trait == ITEM_TRAIT_TYPE_ARMOR_DIVINES then
        self.Modifiers.divines_multiplier = self.Modifiers.divines_multiplier +
            MUNDUS_DIVINES_BONUS[gear.quality]
    end
    if gear.name == "Ring of the Wild Hunt" then
        self.Flags.IS_WEARING_ROTW = true
    end
end

function Player:ApplyChampionPointBonuses()
    for k, championPoint in pairs(self.ChampionPoints.modifiers) do
        if championPoint.slotted then
            self:UpdateStatFromModifier(championPoint)
        end
    end
    if self.ChampionPoints.raceModifiers.slotted then
        self:UpdateStatFromModifier(self.ChampionPoints.raceModifiers[GetUnitRace("player")])
    end
end

function Player:UpdateStatFromModifier(modifier)
    if not modifier then return end
    if modifier.additive then
        self.Stats[modifier.name] = self.Stats[modifier.name] + modifier.value
    else
        self.Stats[modifier.name] = self.Stats[modifier.name] * modifier.value
    end
end

function Player:updateChampionPoints()
    for _, cp in pairs(self.ChampionPoints.modifiers) do
        cp.slotted = false
    end

    for disciplineIndex = 0, 12 do
        local championSkillId = GetSlotBoundId(disciplineIndex, HOTBAR_CATEGORY_CHAMPION)
        local modifier = self.ChampionPoints.modifiers[championSkillId]
        local race_modifier = self.ChampionPoints.raceModifiers[GetUnitRace("player")]
        if modifier then
            modifier.slotted = true
        end
        if race_modifier then
            race_modifier.slotted = true
        end
    end
end

function Player:getBagSize(id)
    local bagId = id or BAG_WORN
    local bagSize = GetBagSize(bagId)
    return bagSize
end
