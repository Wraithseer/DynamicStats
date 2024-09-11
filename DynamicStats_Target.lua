local FORCE_OF_NATURE = 276

local Debuffs = {
    Crit = {
        [142610] = 5,
        [142652] = 5,
        [142653] = 5,
        [145975] = 10,
        [145977] = 20
    },
    Pen = {
        [61743] = 5948,
        [61742] = 2974,
        [76667] = 4000,
        [120018] = 6000,
        [143808] = 1000,
        [187742] = 2200,
        [120007] = 2108,
        [17906] = 2108,
        [159288] = 3541,
        [80866] = 2640
    },
    ForceOfNature = {
        [178118] = 660,
        [18084] = 660,
        [95136] = 660,
        [95134] = 660,
        [178123] = 660,
        [21929] = 660,
        [178127] = 660,
        [148801] = 660
    }
}

Target = {}

function Target:New(name)
    local instance = {
        Name = name,
        OldestBuffTime = 0,
        NewestBuffTime = 0,
        AddedCrit = 0,
        AddedPenetration = 0
    }
 
    setmetatable(instance, self)
    self.__index = self
    return instance
end

function Target:Update()
    local buff_count = GetNumBuffs("reticleover")
    self.AddedCrit = 0
    self.AddedPenetration = 0
    if buff_count == 0 then return end

    for i = 1, buff_count do
        local buff_name, time_started, time_ending, buff_slot, stack_count, icon, _, _, _, _, ability_id, _, cast_by_player = GetUnitBuffInfo("reticleover", i)
        self.OldestBuffTime = math.min(self.OldestBuffTime, time_started)
        self.NewestBuffTime = math.max(self.NewestBuffTime, time_ending)

        if Debuffs.Crit[ability_id] then
            self.AddedCrit = self.AddedCrit + Debuffs.Crit[ability_id]
        end
        if Debuffs.Pen[ability_id] then
            self.AddedPenetration = self.AddedPenetration + Debuffs.Pen[ability_id]
        end
        if Debuffs.ForceOfNature[ability_id] and FORCE_OF_NATURE then
            self.AddedPenetration = self.AddedPenetration + Debuffs.ForceOfNature[ability_id]
        end
    end
end