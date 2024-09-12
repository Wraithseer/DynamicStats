Gear = {}
Gear.__index = Gear
Gear.SLOTS = {
    HEAD = 0,
    NECK = 1,
    CHEST = 2,
    SHOULDERS = 3,
    MAIN_HAND = 4,
    OFF_HAND = 5,
    WAIST = 6,
    LEGS = 7,
    FEET = 8,
    RING_LEFT = 9,
    RING_RIGHT = 10,
    HAND = 11,
    COSTUME = 12,
    COSTUME_HEAD = 13,
    BACKPACK = 14,
    COSTUME_UPPER_BODY = 15,
    COSTUME_LOWER_BODY = 16,
    COSTUME_HAND = 17,
    COSTUME_FEET = 18
}

Gear.__eq = function(left, right)
    return left.Slot == right.Slot and left.Name == right.Name and left.Trait == right.Trait and left.Quality == right.Quality
end

function Gear:New(slot, name, trait, quality)
    local instance = {
        Slot = slot,
        Name = name,
        Trait = trait,
        Quality = quality,
    }
    setmetatable(instance, Gear)
    return instance
end

function Gear:GetSwiftTraitBonus()
    local swift_trait_bonuses = {
        [1] = 3,
        [2] = 4,
        [3] = 5,
        [4] = 6,
        [5] = 7
    }
    return swift_trait_bonuses[self.Quality] or 0
end

function Gear:GetDivinesBonus()
    local divines_bonus = {
        [1] = 0.051,
        [2] = 0.061,
        [3] = 0.071,
        [4] = 0.081,
        [5] = 0.091
    }
    return divines_bonus[self.Quality] or 0
end

PlayerGear = {
    Cache = {},
    CACHE_SIZE = 6,
    IsWearingRotw = false,
    DivinesBonus = 0,
    SwiftBonus = 0
}

function PlayerGear:New()
    local instance = {}
    setmetatable(instance, self)
    self.__index = self
    return instance
end

function PlayerGear:Update()
    self.IsWearingRotw = false
    for slot_index = 0, GetBagSize(BAG_WORN) - 1 do
        local item_name = GetItemName(BAG_WORN, slot_index)
        local item_trait = GetItemTrait(BAG_WORN, slot_index)
        local item_quality = GetItemQuality(BAG_WORN, slot_index)
        local item_key = item_name .. item_trait .. item_quality

        if not self.Cache[item_key] then
            self.Cache[item_key] = Gear:New(slot_index, item_name, item_trait, item_quality)
        end
        self:OnEquip(self.Cache[item_key])
    end

    if #self.Cache > self.CACHE_SIZE then
        table.remove(self.Cache, 1)
    end
end

function PlayerGear:OnEquip(gear)
    if gear.trait == ITEM_TRAIT_TYPE_ARMOR_DIVINES then
        self.DivinesBonus = self.DivinesBonus + gear:GetDivinesBonus()
    end

    if gear.name == "Ring of the Wild Hunt" then
        self.IsWearingRotw = true
    end

    if gear.trait == ITEM_TRAIT_TYPE_JEWELRY_SWIFT then
        self.SwiftBonus = self.SwiftBonus + gear:GetSwiftTraitBonus()
    end
end