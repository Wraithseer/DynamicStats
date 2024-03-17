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










