local addoncodename = 'DynamicStats'
local sv
local player = Player:new()

local target_cache = {}
local TARGET_CACHE_MAX_SIZE = 15

local function OnStatsUpdated(...)
  player:Update()
  DynamicStats_UpdateUI()
end

local function ClearCacheOldest()
  local currentTime = GetGameTimeMilliseconds() / 1000
  for i = #target_cache, 1, -1 do
    if target_cache[i].newest_buff_time < currentTime then
      table.remove(target_cache, i)
      if #target_cache < TARGET_CACHE_MAX_SIZE then break end
    end
  end
end

local function OnReticleChange(...)
  local should_update = false
  if DoesUnitExist('reticleover') and not IsUnitPlayer('reticleover') and IsUnitAttackable('reticleover') then
    local unitName = zo_strformat("<<t:1>>", GetUnitName('reticleover'))
    if not target_cache[unitName] then
      player.Target = Target:new(unitName)
      table.insert(target_cache, player.Target)
    end
    should_update = true
  end

  if TARGET_CACHE_MAX_SIZE <= #target_cache then
    ClearCacheOldest()
  end

  if should_update then
    DynamicStats_UpdateUI()
  end
end

local function OnCombatEvent(_, result, isError, abilityName, _, _, sourceName, _, targetName, targetType, hitValue,
                             powerType, damageType, _, sourceUnitId, targetUnitId, abilityId)
  if not player.Target then return end
  if targetName ~= player.Target.name then return end
  if not DoesUnitExist('reticleover') or IsUnitPlayer('reticleover') then return end
  if not ACTION_RESULT_EFFECT_GAINED == result or ACTION_RESULT_EFFECT_DURATION == result then return end
  player.Target:update()
  DynamicStats_UpdateUI()
end

local function OnCPChanged(eventCode, result)
  if result ~= CHAMPION_PURCHASE_SUCCESS then return end
  player:updateChampionPoints()
  DynamicStats_UpdateUI()
end

local function OnCombatStateChanged(eventCode, inCombat)
  DynamicStats_UpdateUI()
  player.Flags.IN_COMBAT = inCombat
end

local function OnPlayerActivated(eventCode, initial)
  player:Update()
  player:updateChampionPoints()
  DynamicStats_UpdateUI()
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

  EVENT_MANAGER:RegisterForEvent(addoncodename .. 'Reticle', EVENT_RETICLE_TARGET_CHANGED, OnReticleChange)

  EVENT_MANAGER:RegisterForEvent(addoncodename .. 'Health', EVENT_POWER_UPDATE, OnStatsUpdated)
  EVENT_MANAGER:RegisterForEvent(addoncodename .. 'Gear', EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnStatsUpdated)
  EVENT_MANAGER:RegisterForEvent(addoncodename .. 'Skill', EVENT_ACTION_SLOT_UPDATED, OnStatsUpdated)
  EVENT_MANAGER:RegisterForEvent(addoncodename .. 'AllSkills', EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED, OnStatsUpdated)
  EVENT_MANAGER:RegisterForEvent(addoncodename .. 'Hotbar', EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED, OnStatsUpdated)

  EVENT_MANAGER:RegisterForEvent(addoncodename .. 'Combat', EVENT_COMBAT_EVENT, OnCombatEvent)
  EVENT_MANAGER:RegisterForEvent(addoncodename .. 'CPChanged', EVENT_CHAMPION_PURCHASE_RESULT, OnCPChanged)
  EVENT_MANAGER:RegisterForEvent(addoncodename .. 'CombatState', EVENT_PLAYER_COMBAT_STATE, OnCombatStateChanged)
  EVENT_MANAGER:RegisterForEvent(addoncodename .. 'PlayerActivated', EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
end

local function OnAddonLoaded(eventCode, addonName)
  if addonName == addoncodename then
    DynamicStatsInitialize()
  end
end

function DynamicStats_UpdateUI()
  DynamicStats_UI_DMG:SetText(string.format("%d \| |c%s%d", player.Stats["Damage"], DynamicStats_UI_Colors.WHITE,
    player.Stats["ArmorPenetration"]))


  DynamicStats_UI_CRIT:SetText(string.format("%d%% \| %d%% \| |c%s%d%%", player.Stats["CriticalChanceWep"],
    player.Stats["CriticalChanceSpell"], DynamicStats_UI_Colors.WHITE,
    player.Stats["CriticalDamage"]))

  DynamicStats_UI_RES:SetText(string.format("|c%s%d \| |c%s%d", DynamicStats_UI_Colors.WHITE,
    player.Stats["PhysicalResistance"], DynamicStats_UI_Colors.WHITE, player.Stats["SpellResistance"]))

  if IsMounted() then
    DynamicStats_UI_SPEED:SetText(string.format("%d%%", player.Stats["MountedSpeed"]))
  else
    DynamicStats_UI_SPEED:SetText(string.format("|c%s%d%%", DynamicStats_UI_Colors.WHITE, player.Stats["MovementSpeed"]))
  end
end

EVENT_MANAGER:RegisterForEvent(addoncodename, EVENT_ADD_ON_LOADED, OnAddonLoaded)
