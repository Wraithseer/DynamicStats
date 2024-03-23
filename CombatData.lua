local BASE_CRITICAL_DAMAGE = 50
local BASE_MOVEMENT_SPEED = 100
local BASE_MOUNTED_SPEED = 115

Gear = {}
Gear.__index = Gear

function Gear:new(slot,name, trait, quality, is_crusher_enchant)

  Gear.SLOTS = {
    Head = 0,
    Neck = 1,
    Chest = 2,
    Shoulders = 3,
    MainHand = 4,
    OffHand = 5,
    Waist = 6,
    Legs = 7,
    Feet = 8,
    RingLeft = 9,
    RingRight = 10,
    Hand = 11,
    Costume = 12,
    CostumeHead = 13,
    Backpack = 14,
    CostumeUpperBody = 15,
    CostumeLowerBody = 16,
    CostumeHand = 17,
    CostumeFeet = 18
}
    local instance = {
        slot = slot,
        trait = trait,
        quality = quality,
        is_crusher_enchant = is_crusher_enchant or false
    }
    setmetatable(instance, Gear)
    return instance
end

function Gear:getSwiftTraitBonus()
    
  
  
  local swiftTraitBonuses = {
        Normal = 0.03,
        Fine = 0.04,
        Superior = 0.05,
        Epic = 0.06,
        Legendary = 0.07
    }
    return swiftTraitBonuses[self.quality] or 0
end

-- Mundus Stone Class
MundusStone = 
{
  BASE_MUNDUS_VALUES = {
    ["Apprentice"] = 238,    -- Increases Spell Damage
    ["Atronach"] = 310,      -- Increases Magicka Recovery
    ["Lady"] = 2744,         -- Increases Physical and Spell Resistance
    ["Lord"] = 2225,         -- Increases Maximum Health
    ["Lover"] = 2744,        -- Increases Physical and Spell Penetration
    ["Mage"] = 2023,         -- Increases Maximum Magicka
    ["Ritual"] = 0.08,       -- Increases Healing Effectiveness
    ["Serpent"] = 310,       -- Increases Stamina Recovery
    ["Shadow"] = 0.11,       -- Increases Critical Damage and Healing
    ["Steed"] = 10,          -- Increases Movement Speed and Health Recovery
    ["Thief"] = 1333,        -- Increases Critical Strike Rating
    ["Tower"] = 2023,        -- Increases Maximum Stamina
    ["Warrior"] = 238        -- Increases Weapon Damage
},

DIVINES_GEAR_QUAL_BONUS = {
    Normal = 0.051,
    Fine = 0.061,
    Superior = 0.071,
    Epic = 0.081,
    Legendary = 0.091
}
}
MundusStone.__index = MundusStone
MundusStone.__tostring = function(self)
    return self.name
end


function MundusStone:new(name, effect, divinesBonus)
    local instance = {
        name = name,
        effect = effect,
        divinesBonus = divinesBonus or 0
    }
    setmetatable(instance, MundusStone)
    return instance

end

function MundusStone:getTotalEffectWithDivines(gearQuality)
  local baseEffect = MundusStone.BASE_MUNDUS_VALUES[self.name] or 0
  local gearQualityBonus = MundusStone.DIVINES_GEAR_QUAL_BONUS[gearQuality] or 0
  local totalEffect = (baseEffect * (1 + gearQualityBonus)) + self.divinesBonus
  return totalEffect
end
-- Player Class
Player = {
  Stats = {
    Health = 0,
    Magicka = 0,
    Stamina = 0,
    WeaponDamage = 0,
    SpellDamage = 0,
    WeaponCritical = 0,
    SpellCritical = 0,
    WeaponPenetration = 0,
    SpellPenetration = 0,
    WeaponCriticalDamage = 0,
    SpellCriticalDamage = 0,
    MovementSpeed = 0,
    MountedSpeed = 0
  },
  MundusStones = {},
  ChampionPoints = nil
}

function Player:resetStats()
    self.Stats.Health = 0
    self.Stats.Magicka = 0
    self.Stats.Stamina = 0
    self.Stats.WeaponDamage = 0
    self.Stats.SpellDamage = 0
    self.Stats.WeaponCritical = 0
    self.Stats.SpellCritical = 0
    self.Stats.WeaponPenetration = 0
    self.Stats.SpellPenetration = 0
    self.Stats.WeaponCriticalDamage = 0
    self.Stats.SpellCriticalDamage = 0
    self.Stats.MovementSpeed = 0
    self.Stats.MountedSpeed = 0
end

function Player:equipGear(gear)

    if gear.trait == "swift" then
        self.movementSpeed = self.movementSpeed + gear:getSwiftTraitBonus()
    elseif gear.trait == "divines" then
      for _, mundusStone in ipairs(self.MundusStones) do
        self.total_divines_multiplier = self.total_divines_multiplier + mundusStone:getTotalEffectWithDivines(gear.quality)
      end
    end

    if gear.name == "Ring of the Wild Hunt" then
        
    end
end

function Player:calculateMovementSpeed()
    local movementSpeed = BASE_MOVEMENT_SPEED
    if self.wearing.rotw then
      if InCombat() then
        movementSpeed = movementSpeed + 15
      else
        movementSpeed = movementSpeed + 40
      end
    end
    return movementSpeed
end


function Player:getBagSize(id)
local bagId = id or BAG_WORN
local bagSize = GetBagSize(bagId)
return bagSize
end


local debuffs = {
    crit = {
      [142610] = 5, -- Flame Weakness
      [142652] = 5, -- Frost Weakness
      [142653] = 5, -- Shock Weakness
      [145975] = 10, -- Minor Brittle
      [145977] = 20 -- Major Brittle
    },
  
    pen = {
      [61743] = 5948, -- Major Breach
      [61742] = 2974, -- Minor Breach
      [76667] = 4000, -- Alkosh
      [120018] = 6000, -- Alkosh dummy
      [143808] = 1000, -- Crystal Weapon
      [187742] = 2200, -- Runic Sunder
      [120007] = 2108, -- Crusher dummy
      [17906] = 2108, -- Crusher gold
      [159288] = 3541, -- Crimson oath
      [80866] = 2640 -- Tremorscale
    },
  
    force_of_nature = {
      [178118] = 660, -- Magic (Overcharged) not working
      [18084] = 660, -- Fire (Burning)
      [95136] = 660, -- Frost (Chill)
      [95134] = 660, -- Lightning (Concussion)
      [178123] = 660, -- Physical (Sundered) not working
      [21929] = 660, -- Poison (Burning)
      [178127] = 660, -- Foulness (Diseased) not working
      [148801] = 660 -- Bleeding (Hemorrhaging)
    }
  }
local FORCE_OF_NATURE = false


Target = {}
Target.__index = Target

function Target:new(name)
    local instance = {
        name = name,
        oldest_buff_time = 0,
        newest_buff_time = 0,
        added_crit = 0,
        added_penetration = 0
    }
    setmetatable(instance, Target)
    return instance
end

function Target:update()
    local currentTime = GetGameTimeMilliseconds() / 1000
    local buffCount = GetNumBuffs("reticleover")

    self.added_crit = 0
    self.added_penetration = 0
    if buffCount == 0 then return end
    -- Check if the target has new or continuing buffs and update accordingly
    for i = 1, buffCount do
        local buffName, timeStarted, timeEnding, buffSlot, stackCount, icon, _, _, _, _, abilityId, _, castByPlayer =
            GetUnitBuffInfo("reticleover", i)
        self.oldest_buff_time = math.min(self.oldest_buff_time, timeStarted)
        self.newest_buff_time = math.max(self.newest_buff_time, timeEnding)

        if debuffs.crit[abilityId] then
            self.added_crit = self.added_crit + (debuffs.crit[abilityId])
        end
        if debuffs.pen[abilityId] then
            self.added_penetration = self.added_penetration + (debuffs.pen[abilityId])
        end
        if debuffs.pen[abilityId] and FORCE_OF_NATURE then
            self.added_crit = self.added_crit + (debuffs.force_of_nature[abilityId])
        end
    end
end










