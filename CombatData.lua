
local FORCE_OF_NATURE = false


Target = {}
Target.__index = Target

function Target:new(name)
    local instance = {
        name = name,
        buffs = {},
        -- New attributes for tracking debuff modifiers
        added_crit = 0,
        added_penetration = 0
    }
    setmetatable(instance, Target)
    return instance
end

function Target:update()
  local currentTime = GetGameTimeMilliseconds() / 1000
  local buffCount = GetNumBuffs("reticleover") 
  if buffCount == 0 then return end
  (
  for i = 1, #self.buffs do
    if self.buffs[i].expireTime <= currentTime then
      table.remove(self.buffs, i)
    end
  end
  -- Check if the target has new or continuing buffs and update accordingly
  for i = 1, buffCount do

      local buffName, timeStarted, timeEnding, buffSlot, stackCount, icon, _, _, _, _, abilityId, _, castByPlayer = GetUnitBuffInfo("reticleover", i)
      if timeEnding > currentTime then  -- Buff is active
          local buffExists = false
          -- Check if this buff is already in our list
          for _, buff in ipairs(self.buffs) do
              if buff.abilityId == abilityId then
                  buffExists = true
                  -- Update expireTime in case it has been refreshed
                  buff.expireTime = timeEnding
                  break
              end
          end
          -- If the buff is new, add it to the list
          if not buffExists then
              table.insert(self.buffs, {name = buffName, expireTime = timeEnding, abilityId = abilityId})
          end
          -- Regardless of new or existing, update modifiers if necessary
          self:updateModifiers(abilityId, stackCount)
      end
  end

end

function Target:updateModifiers(abilityId, stackCount)
    -- Here you would check if the ability ID matches known debuffs and update the modifiers accordingly
    if debuffs.crit[abilityId] then
        self.added_crit = self.added_crit + (debuffs.crit[abilityId] * stackCount)
    end
    if debuffs.pen[abilityId] then
        self.added_penetration = self.added_penetration + (debuffs.pen[abilityId] * stackCount)
    end
    if debuffs.pen[abilityId] and FORCE_OF_NATURE then
        self.added_crit = self.added_crit + (debuffs.force_of_nature[abilityId] * stackCount)
    end
    -- Add more conditions as needed based on your debuffs tracking
end

-- Add methods to get total crit and pen modifiers
function Target:getCritMod()
    return self.added_crit
end

function Target:getPenMod()
    return self.added_penetration
end

function Target:getBuffs()
    return self.buffs
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