local ADDON_NAME_INTERNAL = "DynamicStats"
local TARGET_CACHE_MAX_SIZE = 16

local PLAYER
local SavedVariables

local function OnStatsUpdated()
  PLAYER:Update()
  DynamicStats_UpdateUI()
end

local function OnReticleChange()
    if DoesUnitExist('reticleover') and not IsUnitPlayer('reticleover') and IsUnitAttackable('reticleover') then
        local unit_name = zo_strformat("<<t:1>>", GetUnitName('reticleover'))
        PLAYER.Target = Target:New(unit_name)
        DynamicStats_UpdateUI()
    end
end

local function OnCombatEvent(_, result, _, _, _, _, _, _, target_name, _, _, _, _, _, _, _, ability_id)
    if not PLAYER.Target then return end
    if target_name ~= PLAYER.Target.Name then return end
    if not DoesUnitExist('reticleover') or IsUnitPlayer('reticleover') then return end
    if result ~= ACTION_RESULT_EFFECT_GAINED and result ~= ACTION_RESULT_EFFECT_DURATION_UPDATED then return end
    PLAYER.Target:Update()
    DynamicStats_UpdateUI()
end

local function OnCPChanged(_, result)
    if result ~= CHAMPION_PURCHASE_SUCCESS then return end
    PLAYER.ChampionPoints:Update()
    DynamicStats_UpdateUI()
end

local function OnCombatStateChanged(_, in_combat)
  PLAYER.Flags.InCombat = in_combat
  DynamicStats_UpdateUI()
end

local function OnPlayerActivated()
    PLAYER:Update()
    PLAYER.ChampionPoints:Update()
    DynamicStats_UpdateUI()
end

function DynamicStatsOnMoveStop()
    local left = DynamicStats_UI:GetLeft()
    local top = DynamicStats_UI:GetTop()
    SavedVariables.X = left
    SavedVariables.Y = top
end

local function DynamicStatsInitialize()
    SavedVariables = ZO_SavedVars:NewAccountWide('DynamicStatsSV', 1, nil, {X = 300, Y = 300})

    DynamicStats_UI:ClearAnchors()
    DynamicStats_UI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, SavedVariables.X, SavedVariables.Y)

    local fragment = ZO_HUDFadeSceneFragment:New(DynamicStats_UI)
    HUD_SCENE:AddFragment(fragment)
    HUD_UI_SCENE:AddFragment(fragment)

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME_INTERNAL .. 'Reticle', EVENT_RETICLE_TARGET_CHANGED, OnReticleChange)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME_INTERNAL .. 'Health', EVENT_POWER_UPDATE, OnStatsUpdated)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME_INTERNAL .. 'Gear', EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnStatsUpdated)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME_INTERNAL .. 'Skill', EVENT_ACTION_SLOT_UPDATED, OnStatsUpdated)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME_INTERNAL .. 'AllSkills', EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED, OnStatsUpdated)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME_INTERNAL .. 'Hotbar', EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED, OnStatsUpdated)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME_INTERNAL .. 'Combat', EVENT_COMBAT_EVENT, OnCombatEvent)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME_INTERNAL .. 'CPChanged', EVENT_CHAMPION_PURCHASE_RESULT, OnCPChanged)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME_INTERNAL .. 'CombatState', EVENT_PLAYER_COMBAT_STATE, OnCombatStateChanged)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME_INTERNAL .. 'PlayerActivated', EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
end

local function OnAddonLoaded(_, addon_name)
    if addon_name == ADDON_NAME_INTERNAL then
      PLAYER = Player:New()
        DynamicStatsInitialize()
    end
end

function DynamicStats_UpdateUI()
  
    local function SetText(control, format, ...)
        control:SetText(string.format(format, ...))
    end

    SetText(DynamicStats_UI_DMG, "%d | |c%s%d", PLAYER.Stats.Current["Damage"], DynamicStats_UI_Colors.WHITE, PLAYER.Stats.Current["ArmorPenetration"])
    SetText(DynamicStats_UI_CRIT, "%d%% | %d%% | |c%s%d%%", PLAYER.Stats.Current["CriticalChanceWep"], PLAYER.Stats.Current["CriticalChanceSpell"], DynamicStats_UI_Colors.WHITE, PLAYER.Stats.Current["CriticalDamage"])
    SetText(DynamicStats_UI_RES, "|c%s%d | |c%s%d", DynamicStats_UI_Colors.WHITE, PLAYER.Stats.Current["PhysicalResistance"], DynamicStats_UI_Colors.WHITE, PLAYER.Stats.Current["SpellResistance"])

    if IsMounted() then
        SetText(DynamicStats_UI_SPEED, "%d%%", PLAYER.Stats.Current["MountedSpeed"])
    else
        SetText(DynamicStats_UI_SPEED, "|c%s%d%%", DynamicStats_UI_Colors.WHITE, PLAYER.Stats.Current["MovementSpeed"])
    end
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME_INTERNAL, EVENT_ADD_ON_LOADED, OnAddonLoaded)