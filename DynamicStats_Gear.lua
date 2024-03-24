Gear = {}
Gear.__index = Gear
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
Gear.__eq = function(left, right)
    return left.slot == right.slot and left.name == right.name and left.trait == right.trait and
    left.quality == right.quality
end
function Gear:new(slot, name, trait, quality)
    local instance = {
        slot    = slot,
        name    = name,
        trait   = trait,
        quality = quality,
    }
    setmetatable(instance, Gear)
    return instance
end

function Gear:getSwiftTraitBonus(quality)
    local swiftTraitBonuses = {
        [1] = 0.03,
        [2] = 0.04,
        [3] = 0.05,
        [4] = 0.06,
        [5] = 0.07
    }
    return swiftTraitBonuses[self.quality] or 0
end
