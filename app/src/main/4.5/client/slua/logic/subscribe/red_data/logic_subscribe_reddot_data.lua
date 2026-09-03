local logic_subscribe_reddot_data = {}
local Enum_RedDot = {
  FirstIn = 1,
  PrimeAward = 2,
  SubscribeNew = 3
}
local Enum_RedSubId = {
  FirstOpen = 1,
  RewardReceive = 2,
  SubscribeNew = 4
}
function logic_subscribe_reddot_data:OnInitialize()
  logic_subscribe_reddot_data.__super.OnInitialize(self)
  self.bIsOpened = false
  self.bFirstEnter = false
end
function logic_subscribe_reddot_data:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_REDDOT, EVENTID_REDDOT_SYSTEM_LOGIN, self.OnLogin, self)
end
function logic_subscribe_reddot_data:OnLogOut()
  self:ResetData()
end
local GenerateData = function()
  local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
  local data = {
    newCount = 0,
    pages = {newCount = 0},
    desc = reddot_macro.SystemName.Prime
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
local CreateInitialRedData = function()
  local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
  local data = GenerateData()
  for _, v in pairs(Enum_RedDot) do
    if v == Enum_RedDot.PrimeAward then
      data.pages[v] = GenDefaultSubData(reddot_macro.Category.Receive, Enum_RedSubId.RewardReceive)
    elseif v == Enum_RedDot.SubscribeNew then
      data.pages[v] = GenDefaultSubData(reddot_macro.Category.Other, Enum_RedSubId.SubscribeNew)
    else
      data.pages[v] = GenDefaultSubData(reddot_macro.Category.Other, Enum_RedSubId.FirstOpen)
    end
  end
  return data
end
local isInited = false
local redPoint
function logic_subscribe_reddot_data:InitData()
  if isInited then
    return
  end
  isInited = true
  local data = CreateInitialRedData()
  local reddot_manager = require("client.slua.logic.reddot.reddot_manager")
  local super_data = require("common.super_data")
  redPoint = super_data.CreateSuperData(data)
  reddot_manager:Regist(redPoint)
  self:GetLocalSavePrimeInfo()
end
function logic_subscribe_reddot_data:GetLocalSavePrimeInfo()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local tLocalCache = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eSubscribePanel) or {}
  self.bIsOpened = tLocalCache.bIsOpened
end
function logic_subscribe_reddot_data:SaveIsEnterPrime()
  self.bIsOpened = true
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local tLocalCache = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eSubscribePanel) or {}
  tLocalCache.bIsOpened = true
  PlayerPrefsSystem.SaveTableToFile_N(tLocalCache, PlayerPrefsSystem.ePlayerPrefsType.eSubscribePanel)
end
function logic_subscribe_reddot_data:SetFirstOpenRedData(bShow)
  local TableUtil = require("common.table_util")
  local red_data = TableUtil.GetTableValue(redPoint, "pages", Enum_RedDot.FirstIn)
  if red_data then
    if bShow and not self.bIsOpened then
      red_data.newCount = 1
    else
      red_data.newCount = 0
      self:SaveIsEnterPrime()
    end
  end
end
function logic_subscribe_reddot_data:GetData()
  if redPoint then
    log(bWriteLog and "[v_wllwu] logic_subscribe_reddot_data:GetData, newCount =  " .. tostring(redPoint.newCount) .. " realCount = " .. tostring(redPoint.realCount))
  end
  return redPoint
end
function logic_subscribe_reddot_data:ResetData()
  isInited = false
  redPoint = nil
end
function logic_subscribe_reddot_data:UpdateRewardRedDot()
  if not redPoint then
    self:InitData()
  end
  local TableUtil = require("common.table_util")
  local red_data = TableUtil.GetTableValue(redPoint, "pages", Enum_RedDot.PrimeAward)
  local logic_subscribe_handler = require("client.slua.logic.subscribe.logic_subscribe_handler")
  local subscribeModuleObj = logic_subscribe_handler.GetSubscribeModuleObj()
  local currentStatus = subscribeModuleObj:GetSubStatus()
  local SubscribeEnumConfig = require("client.slua.logic.subscribe.logic_subscribe_enum_config")
  if currentStatus == SubscribeEnumConfig.ENUM_SubStatus.NONE then
    red_data.newCount = 0
    return
  end
  local ENUM_SubId = SubscribeEnumConfig.ENUM_SubId
  local bIsCanReceive_N = 0 < subscribeModuleObj:Get_EveryDay_GetTimes(ENUM_SubId.Normal)
  local bIsCanReceive_S = 0 < subscribeModuleObj:Get_EveryDay_GetTimes(ENUM_SubId.Super)
  local bIsCanReceive = bIsCanReceive_N or bIsCanReceive_S
  if bIsCanReceive then
    red_data.newCount = 1
  else
    red_data.newCount = 0
  end
end
function logic_subscribe_reddot_data:UpdateSubscribeNewRedDot()
  if not redPoint then
    self:InitData()
  end
  local TableUtil = require("common.table_util")
  local red_data = TableUtil.GetTableValue(redPoint, "pages", Enum_RedDot.SubscribeNew)
  if not red_data then
    return
  end
  local special_offer_mark = require("client.slua.logic.specialoffer.special_offer_mark")
  local cfg = require("client.slua.logic.specialoffer.special_offer_cfg")
  local markType = special_offer_mark[cfg.subscribe] and special_offer_mark[cfg.subscribe]()
  if markType == special_offer_mark.markType.New then
    red_data.newCount = 1
  else
    red_data.newCount = 0
  end
end
function logic_subscribe_reddot_data:IsSubscribeNewRedDot()
  if not redPoint then
    self:InitData()
  end
  local TableUtil = require("common.table_util")
  local red_data = TableUtil.GetTableValue(redPoint, "pages", Enum_RedDot.SubscribeNew)
  return red_data and red_data.newCount > 0
end
function logic_subscribe_reddot_data:IsRewardRedDot()
  if not redPoint then
    self:InitData()
  end
  local logic_subscribe_handler = require("client.slua.logic.subscribe.logic_subscribe_handler")
  local subscribeModuleObj = logic_subscribe_handler.GetSubscribeModuleObj()
  local currentStatus = subscribeModuleObj:GetSubStatus()
  local SubscribeEnumConfig = require("client.slua.logic.subscribe.logic_subscribe_enum_config")
  if currentStatus == SubscribeEnumConfig.ENUM_SubStatus.NONE then
    return
  end
  local TableUtil = require("common.table_util")
  local red_data = TableUtil.GetTableValue(redPoint, "pages", Enum_RedDot.PrimeAward)
  return red_data.newCount > 0
end
function logic_subscribe_reddot_data:OutputLog()
  log(bWriteLog and "logic_subscribe_reddot_data:OutputLog")
  if redPoint then
    log_tree("logic_subscribe_reddot_data:redPoint = ", redPoint)
  end
end
function logic_subscribe_reddot_data:OnLogin()
  self:InitData()
end
function logic_subscribe_reddot_data:OnLogOut()
  self:ResetData()
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CSubscribeRedDotSystem = class(CModuleBase, nil, logic_subscribe_reddot_data)
return CSubscribeRedDotSystem