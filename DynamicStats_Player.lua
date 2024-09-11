Player = {
    Stats = nil,
    Flags = nil,
    Buffs = nil,
    ChampionPoints = nil,
    Gear = nil,
    SteedMundus = false,
    Modifiers = {
        AddedCrit = 0,
        AddedPenetration = 0,
        DivinesMultiplier = 0
    },
    Target = nil,
}

function Player:New()
    local instance = {
        Stats = Stats:New(),
        Flags = Flags:New(),
        Buffs = Buffs:New(),
        ChampionPoints = ChampionPoints:New(),
        Gear = PlayerGear:New()
    }
    setmetatable(instance, self)
    self.__index = self
    return instance
end

function Player:Update()
    self.Stats:Update()
    self.Flags:Update()
    self.Buffs:Update()
    self.ChampionPoints:Update()
    self.Gear:Update()

    self.Flags.IsWearingRotw = self.Gear.IsWearingRotw

    self:CalculateMovementSpeed()
    self:CalculateMountedSpeed()
    self:CalculateCriticalDamage()
    self:CalculateAddedPenetration()
end

function Player:CalculateMovementSpeed()
    local speed = self.Stats.Current["MovementSpeed"]
    
    if self.Flags.IsWearingRotw then
        speed = speed + (self.Flags.InCombat and 15 or 45)
    end
    
    if self.Flags.IsSprinting then
        local sprint_multiplier = select(3, GetAdvancedStatValue(ADVANCED_STAT_DISPLAY_TYPE_SPRINT_SPEED))
        speed = speed + sprint_multiplier - 100
    end

    for buff_id, buff_data in pairs(self.Buffs.Speed) do
        if buff_data.Active then
            speed = speed + buff_data.Value
        end
    end

    for _, cp in pairs(self.ChampionPoints.Modifiers) do
        if cp.Active and cp.Name == "MovementSpeed" then
            speed = speed + cp.Value
        end
    end

    if self.SteedMundus then
        local effect = 10 * (1 + self.Modifiers.DivinesMultiplier)
        speed = speed + effect
    end

    self.Stats.Current["MovementSpeed"] = speed
end

function Player:CalculateMountedSpeed()
    local speed = self.Stats.Current["MountedSpeed"]
    local riding_lesson_bonus = select(5, GetRidingStats("player"))
    local sprint_bonus = self.Flags.IsSprinting and self.Stats.MOUNT_SPRINT_SPEED or 0
    
    speed = speed + riding_lesson_bonus + sprint_bonus
    
    if self.Buffs.MountSpeed[63569].Active then
        speed = speed * self.Buffs.MountSpeed[63569].Value
    end
    
    if self.ChampionPoints.Modifiers[92].Active then
        speed = speed * self.ChampionPoints.Modifiers[92].Value
    end
    
    self.Stats.Current["MountedSpeed"] = zo_round(speed)
end

function Player:CalculateCriticalDamage()
    local crit_damage = self.Stats.Current["CriticalDamage"]
    crit_damage = crit_damage + select(-1, GetAdvancedStatValue(ADVANCED_STAT_DISPLAY_TYPE_CRITICAL_DAMAGE)) + self.Modifiers.AddedCrit

    if self.Target then
        crit_damage = crit_damage + self.Target.AddedCrit
    end

    self.Stats.Current["CriticalDamage"] = crit_damage
end

function Player:CalculateAddedPenetration()
    if not self.Target then return end
    self.Stats.Current["ArmorPenetration"] = self.Stats.Current["ArmorPenetration"] + self.Target.AddedPenetration
end