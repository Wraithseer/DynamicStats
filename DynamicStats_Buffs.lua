Buffs = {
    Speed = {
        [61735] = {Active = false, Value = 15}, -- Minor Expedition
        [61736] = {Active = false, Value = 30}, -- Major Expedition
    },
    MountSpeed = {
        [63569] = {Active = false, Value = 1.3}, -- Major Gallop
    }
}

function Buffs:New()
    local instance = {}
    setmetatable(instance, self)
    self.__index = self
    return instance
end

function Buffs:Update()
    for buff_id in pairs(self.Speed) do
        self.Speed[buff_id].Active = false
    end
    for buff_id in pairs(self.MountSpeed) do
        self.MountSpeed[buff_id].Active = false
    end

    for i = 1, GetNumBuffs('player') do
        local buff_name, _, _, _, _, _, _, _, _, _, ability_id = GetUnitBuffInfo('player', i)
        if self.Speed[ability_id] then
            self.Speed[ability_id].Active = true
        end
        if self.MountSpeed[ability_id] then
            self.MountSpeed[ability_id].Active = true
        end
    end
end