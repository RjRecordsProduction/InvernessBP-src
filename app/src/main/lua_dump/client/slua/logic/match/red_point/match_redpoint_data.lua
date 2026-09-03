local match_redpoint_data = {}
local redpoint
local isInited = false
local ReddotType = {
  Weapon = 1,
  Component = 2,
  WarmUp = 3,
  ArenaRank = 4,
  ArenaMatch = 5
}
local comp2weapon = {}
local GenerateData = function()
  local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
  local Category = reddot_macro.Category
  local data = {
    newCount = 0,
    desc = reddot_macro.SystemName.ModeSelect,
    types = {
      newCount = 0,
      [ReddotType.Weapon] = {
        newCount = 0,
        category = Category.Other,
        subID = 1,
        instanceId = {_isLeaf = true}
      },
      [ReddotType.Component] = {
        newCount = 0,
        category = Category.Other,
        subID = 2,
        instanceId = {_isLeaf = true}
      },
      [ReddotType.WarmUp] = {
        newCount = 0,
        category = Category.Receive,
        subID = 3
      },
      [ReddotType.ArenaRank] = {
        newCount = 0,
        category = Category.Receive,
        subID = 4
      },
      [ReddotType.ArenaMatch] = {
        newCount = 0,
        category = Category.Other,
        subID = 5,
        instanceId = {_isLeaf = true}
      }
    }
  }
  return data
end
function match_redpoint_data.InitData()
  if isInited then
    return
  end
  isInited = true
  local data = GenerateData()
  local super_data = require("common.super_data")
  if redpoint == nil then
    redpoint = super_data.CreateSuperData(data)
  end
  local reddot_manager = require("client.slua.logic.reddot.reddot_manager")
  reddot_manager:Regist(redpoint)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local save_data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.arenaRedDot)
  if save_data and save_data.weapon_info then
    for k, v in pairs(save_data.weapon_info) do
      if v.weapon_unlock then
        match_redpoint_data.AddWeaponRed(tonumber(k))
      end
      if v.comps and type(v.comps) == "table" then
        for kk, vv in pairs(v.comps) do
          if vv then
            match_redpoint_data.AddCompRed(tonumber(kk), tonumber(k))
          end
        end
      end
    end
  end
  match_redpoint_data.UpdateWarmUp()
end
function match_redpoint_data.OnLogin()
  match_redpoint_data.InitData()
end
function match_redpoint_data.OnLogout()
  match_redpoint_data.DestroyData()
end
function match_redpoint_data.DestroyData()
  redpoint = nil
  isInited = false
end
function match_redpoint_data.AddWeaponRed(ID)
  if redpoint then
    redpoint.types[ReddotType.Weapon].instanceId[ID] = true
  end
end
function match_redpoint_data.RemoveWeaponRed(ID)
  if redpoint then
    redpoint.types[ReddotType.Weapon].instanceId[ID] = nil
  end
end
function match_redpoint_data.Add140ArenaNewMap(ID)
  if redpoint then
    redpoint.types[ReddotType.ArenaMatch].instanceId[ID] = true
  end
end
function match_redpoint_data.Remove140ArenaNewMap(ID)
  if redpoint then
    redpoint.types[ReddotType.ArenaMatch].instanceId[ID] = nil
  end
end
function match_redpoint_data.AddCompRed(ID, weapon)
  if redpoint then
    redpoint.types[ReddotType.Component].instanceId[ID] = true
    comp2weapon[ID] = weapon
  end
end
function match_redpoint_data.RemoveCompRed(ID)
  if redpoint then
    redpoint.types[ReddotType.Component].instanceId[ID] = nil
  end
end
function match_redpoint_data.UpdateWarmUp()
  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  if MatchModeMgrSystem.HaveWarmUpRedDot() then
    if redpoint then
      redpoint.types[ReddotType.WarmUp].newCount = 1
    end
  elseif redpoint then
    redpoint.types[ReddotType.WarmUp].newCount = 0
  end
end
function match_redpoint_data.UpdateArena()
  local has_reward = false
  local ArenaSystem = require("client.slua.logic.arena.logic_arena")
  for k, v in pairs(ArenaSystem.awardData) do
    if v.status == 1 then
      has_reward = true
      break
    end
  end
  if has_reward then
    if redpoint then
      redpoint.types[ReddotType.ArenaRank].newCount = 1
    end
  elseif redpoint then
    redpoint.types[ReddotType.ArenaRank].newCount = 0
  end
end
function match_redpoint_data.GetWeaponIdByCompId(comp)
  return comp2weapon[comp]
end
return match_redpoint_data