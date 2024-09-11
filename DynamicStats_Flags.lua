Flags = {
    InCombat = false,
    IsSprinting = false,
    IsWearingRotw = false
}

function Flags:New()
    local instance = {}
    setmetatable(instance, self)
    self.__index = self
    return instance
end

function Flags:Update()
    self.IsSprinting = IsShiftKeyDown()
    self.InCombat = IsUnitInCombat("player")
end