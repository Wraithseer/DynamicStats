Stats = {
    BASE_CRITICAL_DAMAGE = 50,
    BASE_MOVEMENT_SPEED = 100,
    BASE_MOUNTED_SPEED = 115,
    ARMOR_CAP = 33000,
    MOVEMENT_CAP = 200,
    CRIT_COEFFICIENT = 219.1,
    MOUNT_SPRINT_SPEED = 30,
    Current = {
        ["Damage"] = 0,
        ["CriticalChanceWep"] = 0,
        ["CriticalChanceSpell"] = 0,
        ["PhysicalResistance"] = 0,
        ["SpellResistance"] = 0,
        ["ArmorPenetration"] = 0,
        ["CriticalDamage"] = 0,
        ["MovementSpeed"] = 0,
        ["MountedSpeed"] = 0,
    }
}

function Stats:New()
    local instance = {}
    setmetatable(instance, self)
    self.__index = self
    return instance
end

function Stats:Update()
    self.Current["MovementSpeed"] = self.BASE_MOVEMENT_SPEED
    self.Current["MountedSpeed"] = self.BASE_MOUNTED_SPEED
    self.Current["CriticalDamage"] = self.BASE_CRITICAL_DAMAGE
    self.Current["ArmorPenetration"] = GetPlayerStat(STAT_PHYSICAL_PENETRATION)
    self.Current["Damage"] = zo_max(GetPlayerStat(STAT_POWER, STAT_BONUS_OPTION_APPLY_BONUS), GetPlayerStat(STAT_SPELL_POWER, STAT_BONUS_OPTION_APPLY_BONUS))
    self.Current["CriticalChanceWep"] = GetPlayerStat(STAT_CRITICAL_STRIKE, STAT_BONUS_OPTION_APPLY_BONUS) / self.CRIT_COEFFICIENT
    self.Current["CriticalChanceSpell"] = GetPlayerStat(STAT_SPELL_CRITICAL, STAT_BONUS_OPTION_APPLY_BONUS) / self.CRIT_COEFFICIENT
    self.Current["PhysicalResistance"] = GetPlayerStat(STAT_PHYSICAL_RESIST, STAT_BONUS_OPTION_APPLY_BONUS)
    self.Current["SpellResistance"] = GetPlayerStat(STAT_SPELL_RESIST, STAT_BONUS_OPTION_APPLY_BONUS)
end