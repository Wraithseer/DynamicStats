local addoncodename = 'DynamicStats'

local isPlayerInCombat = false
local SteedCP = false
local WildHuntOn = false
local sv
local critDamage = 0
local cpCritMod = 0
local cpSpeedMod = 0
local buffSpeedMod = 0
local sprintSpeedMod = 0
local mountsprintSpeedMod = 0
local mountTraining = 0
local mountMultiplier = 1
local mountMultiplierCP = 0
local wildhuntSpeed = 0
local swiftSpeed = 0
local steedSpeed = 0
local debuffCritMod = 0
local ccoef = 219.1
local lastCallTime = 0
local cooldown = 300
local debuffPenMod = 0
local CRITCAP = "FFFFFF"
local PRCAP = "FFFFFF"
local SRCAP = "FFFFFF"
local PENCAP = "FFFFFF"
local MSCAP = "FFFFFF"

local defaults = {
  x = 300,
  y = 300
}

local playerBuffs = {
  61746,  -- Minor Force
  61747,  -- Major Force
  61735,  -- Minor Expedition
  61736,  -- Major Expedition
  79909,  -- Minor Enervation
  127192, -- Senche's Bite
  154737, -- Sul-Xan Soulbound
  155150, -- Harpooner's Wading Kilt
  194875  -- Fated Fortune
}
local playerBuffsSpeed = {
  [61735] = 15, -- Minor Expedition
  [61736] = 30  -- Major Expedition
}
local current_target = nil
local target_cache = {}

local function DynamicStats_UpdateUI()
  local added_crit = 0
  local added_pen = 0
  if current_target then 
      added_crit = current_target.added_crit
      added_pen = current_target.added_penetration
  end

  local totalCritDamage = 50 + critDamage + cpCritMod + added_crit
  local weaponPower = GetPlayerStat(STAT_POWER, STAT_BONUS_OPTION_APPLY_BONUS)
  local spellPower = GetPlayerStat(STAT_SPELL_POWER, STAT_BONUS_OPTION_APPLY_BONUS)
  local weaponDamage = zo_max(weaponPower, spellPower)
  local critChance = GetPlayerStat(STAT_CRITICAL_STRIKE, STAT_BONUS_OPTION_APPLY_BONUS) / ccoef
  local critChanceS = GetPlayerStat(STAT_SPELL_CRITICAL, STAT_BONUS_OPTION_APPLY_BONUS) / ccoef
  local physicalResistance = GetPlayerStat(STAT_PHYSICAL_RESIST, STAT_BONUS_OPTION_APPLY_BONUS)
  local spellResistance = GetPlayerStat(STAT_SPELL_RESIST, STAT_BONUS_OPTION_APPLY_BONUS)
  local armorPenetration = GetPlayerStat(STAT_PHYSICAL_PENETRATION) + added_pen
  local movementSpeed = 100 + cpSpeedMod + buffSpeedMod + sprintSpeedMod + wildhuntSpeed + swiftSpeed + steedSpeed
  local mountedSpeed = (115 + mountTraining + mountsprintSpeedMod) * (mountMultiplier + mountMultiplierCP)
  local playerMounted = IsMounted()
  if isPlayerInCombat == true and SteedCP == true then
    movementSpeed = movementSpeed - 20
  end
  if isPlayerInCombat == true and WildHuntOn == true then
    movementSpeed = movementSpeed - 30
  end
  if armorPenetration > 18200 then
    PENCAP = "FFDC00"
  else
    PENCAP = "FFFFFF"
  end
  if totalCritDamage > 125 then
    CRITCAP = "FF0000"
  else
    CRITCAP = "FFFFFF"
  end
  if physicalResistance > 30000 then
    PRCAP = "FFDC00"
  else
    PRCAP = "FFFFFF"
  end
  if spellResistance > 3000 then
    SRCAP = "FFDC00"
  else
    SRCAP = "FFFFFF"
  end
  if movementSpeed > 200 then
    MSCAP = "FF0000"
  else
    MSCAP = "FFFFFF"
  end
  DynamicStats_UI_DMG:SetText(string.format("%d \| |c%s%d", weaponDamage, PENCAP, armorPenetration))
  DynamicStats_UI_CRIT:SetText(string.format("%d%% \| %d%% \| |c%s%d%%", critChance, critChanceS, CRITCAP,
    totalCritDamage))
  DynamicStats_UI_RES:SetText(string.format("|c%s%d \| |c%s%d", PRCAP, physicalResistance, SRCAP, spellResistance))
  if playerMounted then
    DynamicStats_UI_SPEED:SetText(string.format("%d%%", mountedSpeed))
  else
    DynamicStats_UI_SPEED:SetText(string.format("|c%s%d%%", MSCAP, movementSpeed))
  end
end

local function OnStatsUpdated(eventCode, ...)
  local currentTimecrit = GetGameTimeMilliseconds()
  if currentTimecrit - lastCallTime >= cooldown then
    _, _, critDamage = GetAdvancedStatValue(ADVANCED_STAT_DISPLAY_TYPE_CRITICAL_DAMAGE)
    buffSpeedMod = 0
    mountMultiplier = 1
    for i = 1, GetNumBuffs('player') do
      local _, _, _, _, _, _, _, _, _, _, abilityIdS = GetUnitBuffInfo('player', i)
      if playerBuffsSpeed[abilityIdS] then
        buffSpeedMod = buffSpeedMod + playerBuffsSpeed[abilityIdS]
      end
      if abilityIdS == 63569 then
        mountMultiplier = mountMultiplier + 0.3
      end
      for j = 2, 14 do       -- munduesStones length
        if abilityIdS == 13977 then
          steedSpeed = 10 + divinesSteed
        end
      end
    end
    if IsShiftKeyDown() then
      _, _, sprintSpeedMod = GetAdvancedStatValue(ADVANCED_STAT_DISPLAY_TYPE_SPRINT_SPEED)
      sprintSpeedMod = sprintSpeedMod - 100
      mountsprintSpeedMod = 30
    end
    local shiftNotPressed = not IsShiftKeyDown()
    if shiftNotPressed then
      sprintSpeedMod = 0
      mountsprintSpeedMod = 0
    end
    local wildHuntName = 'Ring of the Wild Hunt'
    local divines = 0
    local divinesSteed = 0
    swiftSpeed = 0
    WildHuntOn = false
    wildhuntSpeed = 0
    local bagId = BAG_WORN                 -- Bag ID for equipped gear
    local numSlots = GetBagSize(bagId)     -- Get the number of slots in the equipped gear bag
    for slotIndex = 0, numSlots - 1 do
      local itemName = GetItemName(bagId, slotIndex)
      local itemTrait = GetItemTrait(bagId, slotIndex)
      if itemName == wildHuntName then
        WildHuntOn = true
        wildhuntSpeed = 45
      end
      if itemTrait == 28 then
        swiftSpeed = swiftSpeed + 7
      end
      if itemTrait == 18 then
        divines = divines + 1
      end
    end
    if divines > 0 then
      divinesSteed = divines - 1
    end
    steedSpeed = 0
    DynamicStats_UpdateUI()
    lastCallTime = currentTimecrit
  end
end


local function OnReticleChange(...)

  if DoesUnitExist('reticleover') and not IsUnitPlayer('reticleover') then
    local unitName = zo_strformat("<<t:1>>",GetUnitName('reticleover'))
    if not target_cache[unitName] then
      current_target = Target:new(unitName)
    end
    target_cache[unitName] = current_target
  end

  DynamicStats_UpdateUI()
end


local function OnCombatEvent(_, result, isError, abilityName, _, _, sourceName, _, targetName, targetType, hitValue,
                             powerType, damageType, _, sourceUnitId, targetUnitId, abilityId)                  
  if not current_target then return end
  if targetName ~= current_target.name then return end
  if not DoesUnitExist('reticleover') or IsUnitPlayer('reticleover') then return end
  if not ACTION_RESULT_EFFECT_GAINED == result or ACTION_RESULT_EFFECT_DURATION == result then return end
  current_target:update()
  DynamicStats_UpdateUI()

end

local function OnCPChanged(eventCode, result)
  if result == CHAMPION_PURCHASE_SUCCESS then
    local playerRace = GetUnitRace("player")
    cpCritMod = 0
    cpSpeedMod = 0
    SteedCP = false
    mountMultiplierCP = 0
    FORCE_OF_NATURE = false
    for disciplineIndex = 0, 12 do
      local championSkillId = GetSlotBoundId(disciplineIndex, HOTBAR_CATEGORY_CHAMPION)
      -- Backstabber
      if championSkillId == 31 then
        cpCritMod = cpCritMod + 10
      end
      -- Steed's Blessing
      if championSkillId == 66 then
        cpSpeedMod = cpSpeedMod + 20
        SteedCP = true
      end
      -- Gifted Raider
      if championSkillId == 92 then
        mountMultiplierCP = 0.1
      end
      -- Celerity
      if championSkillId == 270 then
        cpSpeedMod = cpSpeedMod + 10
      end
      if championSkillId == 276 then
        FORCE_OF_NATURE = true
      end
    end
    if playerRace == 'Wood Elf' then
      cpSpeedMod = cpSpeedMod + 5
    end
    _, _, _, _, mountTraining, _ = GetRidingStats()
    DynamicStats_UpdateUI()
  end
end

local function OnCombatStateChanged(eventCode, inCombat)
  DynamicStats_UpdateUI()
 -- DynamicStats_UI:SetHidden(not inCombat)
end

local function OnPlayerActivated(eventCode, initial)
  DynamicStats_UpdateUI()
  --DynamicStats_UI:SetHidden(true)
end

function DynamicStatsOnMoveStop()
  local left = DynamicStats_UI:GetLeft();
  local top = DynamicStats_UI:GetTop();

  sv.x = left;
  sv.y = top;
end

local function DynamicStatsInitialize()
  sv = ZO_SavedVars:NewAccountWide('DynamicStatsSV', 1, "namespace", defaults)
  DynamicStats_UI:ClearAnchors()
  DynamicStats_UI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sv.x, sv.y)

  local fragment = ZO_HUDFadeSceneFragment:New(DynamicStats_UI);
  HUD_SCENE:AddFragment(fragment);
  HUD_UI_SCENE:AddFragment(fragment);

  for _, abilityId in ipairs(playerBuffs) do
    local id = addoncodename .. abilityId
    EVENT_MANAGER:RegisterForEvent(id, EVENT_EFFECT_CHANGED, OnStatsUpdated)
    EVENT_MANAGER:AddFilterForEvent(id, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, abilityId,
      REGISTER_FILTER_UNIT_TAG, 'player')
  end

  -- Hidden (Archer's Mind)
  EVENT_MANAGER:RegisterForEvent(addoncodename .. 'Hidden', EVENT_COMBAT_EVENT, OnStatsUpdated)
  EVENT_MANAGER:AddFilterForEvent(addoncodename .. 'Hidden', EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 20309,
    REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

  EVENT_MANAGER:RegisterForEvent(addoncodename .. 'Reticle', EVENT_RETICLE_TARGET_CHANGED, OnReticleChange)
  -- True-Sworn Fury
  EVENT_MANAGER:RegisterForEvent(addoncodename .. 'Health', EVENT_POWER_UPDATE, OnStatsUpdated)
  EVENT_MANAGER:RegisterForEvent(addoncodename, EVENT_COMBAT_EVENT, OnCombatEvent)
  EVENT_MANAGER:AddFilterForEvent(addoncodename .. 'Health', EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE,
    POWERTPYE_HEALTH)
  EVENT_MANAGER:RegisterForEvent(addoncodename .. 'Gear', EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnStatsUpdated)
  EVENT_MANAGER:AddFilterForEvent(addoncodename .. 'Gear', EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID,
    BAG_WORN, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)
  -- Nightblade's Hemorrhage, Templar's Piercing Spear and Warden's Advanced Species passives require skill slotted
  EVENT_MANAGER:RegisterForEvent(addoncodename .. 'Skill', EVENT_ACTION_SLOT_UPDATED, OnStatsUpdated)
  EVENT_MANAGER:RegisterForEvent(addoncodename .. 'AllSkills', EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED, OnStatsUpdated)
  EVENT_MANAGER:RegisterForEvent(addoncodename .. 'Hotbar', EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED, OnStatsUpdated)
  EVENT_MANAGER:RegisterForEvent(addoncodename .. 'CPChanged', EVENT_CHAMPION_PURCHASE_RESULT, OnCPChanged)
  EVENT_MANAGER:RegisterForEvent(addoncodename .. 'CombatState', EVENT_PLAYER_COMBAT_STATE, OnCombatStateChanged)
  EVENT_MANAGER:RegisterForEvent(addoncodename .. 'PlayerActivated', EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
end

local function OnAddonLoaded(eventCode, addonName)
  if addonName == addoncodename then
    DynamicStatsInitialize()
  end
end

EVENT_MANAGER:RegisterForEvent(addoncodename, EVENT_ADD_ON_LOADED, OnAddonLoaded)
