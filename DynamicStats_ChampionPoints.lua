ChampionPoints = {
    Modifiers = {
        [31] = {Name = "CriticalDamage", Value = 10, Active = false},
        [66] = {Name = "MovementSpeed", Value = 20, Active = false},
        [92] = {Name = "MountedSpeed", Value = 1.1, Active = false},
        [270] = {Name = "MovementSpeed", Value = 10, Active = false},
    },
    FORCE_OF_NATURE = 276,
    RaceModifiers = {
        ["Wood Elf"] = {Name = "MovementSpeed", Value = 5, Active = false},
    }
}

function ChampionPoints:New()
    local instance = {}
    setmetatable(instance, self)
    self.__index = self
    return instance
end

function ChampionPoints:Update()
    for _, cp in pairs(self.Modifiers) do
        cp.Active = false
    end

    for discipline_index = 0, 12 do
        local champion_skill_id = GetSlotBoundId(discipline_index, HOTBAR_CATEGORY_CHAMPION)
        local modifier = self.Modifiers[champion_skill_id]
        if modifier then
            modifier.Active = true
        end
    end

    local race = GetUnitRace("player")
    if self.RaceModifiers[race] then
        self.RaceModifiers[race].Active = true
    end
end