local Logic_SmallRPRedMgr = {}
local Enum_SmallRPRedType = {
  FirstIn = 1,
  LevelReward = 2,
  TaskReceive = 3,
  ExchangeItemFirstOpen = 5
}
Logic_SmallRPRedMgr.
function Logic_SmallRPRedMgr:DefineAndResetData()
  Logic_SmallRPRedMgr.__super.DefineAndResetData(self)
  self._tRedData = nil
  self._bIsInited = false
end
function Logic_SmallRPRedMgr:OnInitialize()
  Logic_SmallRPRedMgr.__super.OnInitialize(self)
  self:InitData()
end
function Logic_SmallRPRedMgr:RegistEvents()
  Logic_SmallRPRedMgr.__super.RegistEvents(self)
end
local GenerateData = function()
  local data = {
    newCount = 0,
    pages = {newCount = 0}
  }
  return data
end
local GenDefaultSubData = function(redType, subId)
  local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
  local data = {
    newCount = 0,
    category = redType or reddot_macro.Category.Other,
    subID = subId
  }
  return data
end
local CreateRedData = function()
  local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
  local data = GenerateData()
  for _, v in pairs(Enum_SmallRPRedType) do
    if v == Enum_SmallRPRedType.LevelReward or v == Enum_SmallRPRedType.TaskReceive then
      data.pages[v] = GenDefaultSubData(reddot_macro.Category.Receive, v)
    else
      data.pages[v] = GenDefaultSubData(reddot_macro.Category.Other, v)
    end
  end
  return data
end
function Logic_SmallRPRedMgr:InitData()
  if self._bIsInited then
    return
  end
  local tRedData = CreateRedData()
  local super_data = require("common.super_data")
  tRedData = super_data.CreateSuperData(tRedData)
  self._  self._bIsInited = true
  self:UpdateOpenRedData()
end
function Logic_SmallRPRedMgr:ResetData()
  self._bIsInited = false
  self._tRedData = nil
end
function Logic_SmallRPRedMgr:GetIsOpenedAct()
  local tLocalCache = self:GetLocalCache()
  local Logic_SmallRP = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SmallRP)
  local nRoundId = Logic_SmallRP:GetActRoundId()
  if not nRoundId then
    return true
  end
  return nRoundId == tLocalCache.nOpenedRoundId
end
function Logic_SmallRPRedMgr:SaveFirstOpen()
  local Logic_SmallRP = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SmallRP)
  local nRoundId = Logic_SmallRP:GetActRoundId()
  if not nRoundId then
    return
  end
  local tLocalCache = self:GetLocalCache()
  tLocalCache.nOpenedRoundId = nRoundId
  self:SaveLocalSave(tLocalCache)
  self:UpdateOpenRedData(tLocalCache)
  local special_offer_cfg = require("client.slua.logic.specialoffer.special_offer_cfg")
  EventSystem:postEvent(EVENTTYPE_SPECIAL_OFFER, EVENTID_SPECIAL_RED_CHANGE, special_offer_cfg.SmallRP)
end
function Logic_SmallRPRedMgr:GetTaskIsRed()
  if not self._tRedData then
    return false
  end
  local TableUtil = require("common.table_util")
  local tTaskRed = TableUtil.GetTableValue(self._tRedData, "pages", Enum_SmallRPRedType.TaskReceive)
  if not tTaskRed then
    return false
  end
  return tTaskRed.newCount > 0
end
function Logic_SmallRPRedMgr:GetRedDataByType(nRedType)
  if not self._tRedData then
    return
  end
  local TableUtil = require("common.table_util")
  local tRedData = TableUtil.GetTableValue(self._tRedData, "pages", nRedType)
  return tRedData
end
function Logic_SmallRPRedMgr:GetLevelRewardIsRed()
  if not self._tRedData then
    return false
  end
  local TableUtil = require("common.table_util")
  local tLevelReward = TableUtil.GetTableValue(self._tRedData, "pages", Enum_SmallRPRedType.LevelReward)
  if not tLevelReward then
    return false
  end
  return tLevelReward.newCount > 0
end
function Logic_SmallRPRedMgr:UpdateOpenRedData(tLocalCache)
  if not self._tRedData then
    return
  end
  local Logic_SmallRP = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SmallRP)
  local nRoundId = Logic_SmallRP:GetActRoundId()
  if not nRoundId then
    return
  end
  tLocalCache = tLocalCache or self:GetLocalCache()
  local TableUtil = require("common.table_util")
  local tRedData = TableUtil.GetTableValue(self._tRedData, "pages", Enum_SmallRPRedType.FirstIn)
  if tRedData then
    if tLocalCache.nOpenedRoundId == nRoundId then
      tRedData.newCount = 0
    else
      tRedData.newCount = 1
    end
  end
  LobbySystem.LobbyRedPointUpdate(BP_ENUM_MODULE_IP_ACT_PAGE, self:GetIsShowRedDot())
end
function Logic_SmallRPRedMgr:GetIsShowRedDot()
  return self:GetTaskIsRed() or self:GetLevelRewardIsRed()
end
function Logic_SmallRPRedMgr:UpdateTaskRed()
  if not self._tRedData then
    return
  end
  local TableUtil = require("common.table_util")
  local tTaskRed = TableUtil.GetTableValue(self._tRedData, "pages", Enum_SmallRPRedType.TaskReceive)
  if not tTaskRed then
    return
  end
  local Logic_SmallRP = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SmallRP)
  local bHasCompleted = Logic_SmallRP:GetHasTaskCompletedStatus()
  if bHasCompleted then
    tTaskRed.newCount = 1
  else
    local bIsUnlock = Logic_SmallRP:GetIsUnlock()
    local nCanReceiveCount = Logic_SmallRP:GetCanReceiveTaskProRewardCount()
    if bIsUnlock and 0 < nCanReceiveCount then
      tTaskRed.newCount = 1
    else
      tTaskRed.newCount = 0
    end
  end
  LobbySystem.LobbyRedPointUpdate(BP_ENUM_MODULE_IP_ACT_PAGE, self:GetIsShowRedDot())
  local special_offer_cfg = require("client.slua.logic.specialoffer.special_offer_cfg")
  EventSystem:postEvent(EVENTTYPE_SPECIAL_OFFER, EVENTID_SPECIAL_RED_CHANGE, special_offer_cfg.SmallRP)
  EventSystem:postEvent(EVENTTYPE_SMALL_RP, EVENTID_SMALL_RP_RED_DOT_REFRESH)
end
function Logic_SmallRPRedMgr:UpdateLevelRewardRed()
  if not self._tRedData then
    return
  end
  local TableUtil = require("common.table_util")
  local tLevelRewardRed = TableUtil.GetTableValue(self._tRedData, "pages", Enum_SmallRPRedType.LevelReward)
  if not tLevelRewardRed then
    return
  end
  local Logic_SmallRP = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SmallRP)
  local bIsUnlock = Logic_SmallRP:GetIsUnlock()
  local bHaveReceive = Logic_SmallRP:GetHaveRewardCanReceive()
  if bIsUnlock and bHaveReceive then
    tLevelRewardRed.newCount = 1
  else
    tLevelRewardRed.newCount = 0
  end
  LobbySystem.LobbyRedPointUpdate(BP_ENUM_MODULE_IP_ACT_PAGE, self:GetIsShowRedDot())
  local special_offer_cfg = require("client.slua.logic.specialoffer.special_offer_cfg")
  EventSystem:postEvent(EVENTTYPE_SPECIAL_OFFER, EVENTID_SPECIAL_RED_CHANGE, special_offer_cfg.SmallRP)
end
function Logic_SmallRPRedMgr:GetLocalCache()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local tLocalCache = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eSmallRP) or {}
  return tLocalCache
end
function Logic_SmallRPRedMgr:SaveLocalSave(tLocalCache)
  if not tLocalCache then
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(tLocalCache, PlayerPrefsSystem.ePlayerPrefsType.eSmallRP)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogic_SmallRPRedMgr = class(CModuleBase, nil, Logic_SmallRPRedMgr)
return CLogic_SmallRPRedMgr