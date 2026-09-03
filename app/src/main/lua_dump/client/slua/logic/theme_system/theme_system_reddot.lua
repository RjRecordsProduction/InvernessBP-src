local theme_system_reddot = {}
local ThemeConfig = require("client.slua.logic.theme_system.theme_config")
local ThemeRedDotType = ThemeConfig.ThemeRedDotType
local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
local ThemeRedDotCategory = {
  [ThemeRedDotType.NewVersion] = reddot_macro.Category.NewArrivals,
  [ThemeRedDotType.OfflineBox] = reddot_macro.Category.Receive,
  [ThemeRedDotType.ExchangeNew] = reddot_macro.Category.NewArrivals,
  [ThemeRedDotType.NextVersionPreheat] = reddot_macro.Category.NewArrivals,
  [ThemeRedDotType.NewActivity] = reddot_macro.Category.NewArrivals,
  [ThemeRedDotType.TaskFinished] = reddot_macro.Category.Receive,
  [ThemeRedDotType.ThemeActOpen] = reddot_macro.Category.NewArrivals,
  [ThemeRedDotType.ThemeActReward] = reddot_macro.Category.Receive
}
local CategoryToSubID = {
  [reddot_macro.Category.Receive] = 2,
  [reddot_macro.Category.NewArrivals] = 1,
  [3] = 3
}
function theme_system_reddot:DefineAndResetData()
  self.redDotData = nil
end
function theme_system_reddot:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_THEME_SYSTEM, EVENTID_THEME_SYSTEM_TASK_REDDOT_UPDATE, self.UpdateThemeSystemTaskReddot, self)
end
function theme_system_reddot:OnLogOut()
  self.redDotData = nil
end
function theme_system_reddot:GetRedDotData()
  if self.redDotData == nil or not next(self.redDotData) then
    local defaultData = {
      newCount = 0,
      desc = reddot_macro.SystemName.ThemeSystem,
      isDynamic = true
    }
    local super_data = require("common.super_data")
    local reddot_manager = require("client.slua.logic.reddot.reddot_manager")
    self.redDotData = super_data.CreateSuperData(defaultData)
    reddot_manager:Regist(self.redDotData)
  end
  return self.redDotData
end
function theme_system_reddot:_GetSubRedDotData(type)
  local data = self:GetRedDotData()
  if not data[type] then
    local category = ThemeRedDotCategory[type]
    local newData = {
      newCount = 0,
      subID = CategoryToSubID[category],
          }
    data[type] = newData
  end
  return data[type]
end
function theme_system_reddot:_HasSubRedDot(type)
  local data = self:_GetSubRedDotData(type)
  local hasRedDot = data.newCount > 0
  log(bWriteLog and string.format("theme_system_reddot:_HasSubRedDot type=%d, result=%s", type, tostring(hasRedDot)))
  return hasRedDot
end
function theme_system_reddot:_SetSubRedDot(type, newCount)
  log(bWriteLog and string.format("theme_system_reddot:_SetSubRedDot type=%d, newCount=%d", type, newCount))
  local data = self:_GetSubRedDotData(type)
  data.end
function theme_system_reddot:HasNewRedDot()
  return self:_HasSubRedDot(ThemeRedDotType.NewVersion)
end
function theme_system_reddot:SetNewRedDot()
  log(bWriteLog and "theme_system_reddot:SetNewRedDot")
  if not self:_HasSubRedDot(ThemeRedDotType.NewVersion) then
    self:_SetSubRedDot(ThemeRedDotType.NewVersion, 1)
    EventSystem:postEvent(EVENTTYPE_THEME_SYSTEM, EVENTID_THEME_SYSTEM_REFRESH_NEW_MARK)
  end
end
function theme_system_reddot:CloseNewRedDot()
  log(bWriteLog and "theme_system_reddot:CloseNewRedDot")
  if self:_HasSubRedDot(ThemeRedDotType.NewVersion) then
    self:_SetSubRedDot(ThemeRedDotType.NewVersion, 0)
    EventSystem:postEvent(EVENTTYPE_THEME_SYSTEM, EVENTID_THEME_SYSTEM_REFRESH_NEW_MARK)
  end
end
function theme_system_reddot:GetAwardRedDotData()
  return self:_GetSubRedDotData(ThemeRedDotType.OfflineBox)
end
function theme_system_reddot:HasAwardReddot()
  return self:_HasSubRedDot(ThemeRedDotType.OfflineBox)
end
function theme_system_reddot:SetAwardRedDot()
  log(bWriteLog and "theme_system_reddot:SetAwardRedDot")
  self:_SetSubRedDot(ThemeRedDotType.OfflineBox, 1)
end
function theme_system_reddot:CloseAwardRedDot()
  log(bWriteLog and "theme_system_reddot:CloseAwardRedDot")
  self:_SetSubRedDot(ThemeRedDotType.OfflineBox, 0)
end
function theme_system_reddot:HasExchangeNewRedDot()
  return self:_HasSubRedDot(ThemeRedDotType.ExchangeNew)
end
function theme_system_reddot:SetExchangeNewReddot()
  log(bWriteLog and "theme_system_reddot:SetExchangeNewReddot")
  self:_SetSubRedDot(ThemeRedDotType.ExchangeNew, 1)
  EventSystem:postEvent(EVENTTYPE_THEME_SYSTEM, EVENTID_THEME_SYSTEM_REFRESH_NEW_MARK)
end
function theme_system_reddot:CloseExchangeNewReddot()
  log(bWriteLog and "theme_system_reddot:CloseExchangeNewReddot")
  self:_SetSubRedDot(ThemeRedDotType.ExchangeNew, 0)
  EventSystem:postEvent(EVENTTYPE_THEME_SYSTEM, EVENTID_THEME_SYSTEM_REFRESH_NEW_MARK)
end
function theme_system_reddot:HasNextVersionPreheatRedDot()
  return self:_HasSubRedDot(ThemeRedDotType.NextVersionPreheat)
end
function theme_system_reddot:SetNextVersionPreheatRedDot()
  log(bWriteLog and "theme_system_reddot:SetNextVersionPreheatRedDot")
  if not self:_HasSubRedDot(ThemeRedDotType.NextVersionPreheat) then
    self:_SetSubRedDot(ThemeRedDotType.NextVersionPreheat, 1)
    EventSystem:postEvent(EVENTTYPE_THEME_SYSTEM, EVENTID_THEME_SYSTEM_REFRESH_NEW_MARK)
  end
end
function theme_system_reddot:CloseNextVersionPreheatRedDot()
  log(bWriteLog and "theme_system_reddot:CloseNextVersionPreheatRedDot")
  if self:_HasSubRedDot(ThemeRedDotType.NextVersionPreheat) then
    self:_SetSubRedDot(ThemeRedDotType.NextVersionPreheat, 0)
    EventSystem:postEvent(EVENTTYPE_THEME_SYSTEM, EVENTID_THEME_SYSTEM_REFRESH_NEW_MARK)
  end
end
function theme_system_reddot:HasNewActivityRedDot()
  return self:_HasSubRedDot(ThemeRedDotType.NewActivity)
end
function theme_system_reddot:SetNewActivityRedDot()
  log(bWriteLog and "theme_system_reddot:SetNewActivityRedDot")
  if not self:_HasSubRedDot(ThemeRedDotType.NewActivity) then
    self:_SetSubRedDot(ThemeRedDotType.NewActivity, 1)
    EventSystem:postEvent(EVENTTYPE_THEME_SYSTEM, EVENTID_THEME_SYSTEM_REFRESH_NEW_MARK)
  end
end
function theme_system_reddot:CloseNewActivityRedDot()
  log(bWriteLog and "theme_system_reddot:CloseNewActivityRedDot")
  if self:_HasSubRedDot(ThemeRedDotType.NewActivity) then
    self:_SetSubRedDot(ThemeRedDotType.NewActivity, 0)
    EventSystem:postEvent(EVENTTYPE_THEME_SYSTEM, EVENTID_THEME_SYSTEM_REFRESH_NEW_MARK)
  end
end
function theme_system_reddot:GetTaskFinishedRedDotData()
  return self:_GetSubRedDotData(ThemeRedDotType.TaskFinished)
end
function theme_system_reddot:HasTaskFinishedRedDot()
  return self:_HasSubRedDot(ThemeRedDotType.TaskFinished)
end
function theme_system_reddot:HasThemeActOpenRedDot()
  return self:_HasSubRedDot(ThemeRedDotType.ThemeActOpen)
end
function theme_system_reddot:HasThemeActRewardRedDot()
  return self:_HasSubRedDot(ThemeRedDotType.ThemeActReward)
end
function theme_system_reddot:SetThemeActOpenRedDot()
  log(bWriteLog and "theme_system_reddot:SetThemeActOpenRedDot")
  self:_SetSubRedDot(ThemeRedDotType.ThemeActOpen, 1)
  EventSystem:postEvent(EVENTTYPE_THEME_SYSTEM, EVENTID_THEME_SYSTEM_REFRESH_NEW_MARK)
end
function theme_system_reddot:CloseThemeActOpenRedDot()
  log(bWriteLog and "theme_system_reddot:CloseThemeActOpenRedDot")
  self:_SetSubRedDot(ThemeRedDotType.ThemeActOpen, 0)
  EventSystem:postEvent(EVENTTYPE_THEME_SYSTEM, EVENTID_THEME_SYSTEM_REFRESH_NEW_MARK)
end
function theme_system_reddot:UpdateThemeActRewardRedDot()
  log(bWriteLog and "theme_system_reddot:UpdateThemeActRewardRedDot")
  local logic_theme_system = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_theme_system)
  if logic_theme_system:CheckCurThemeActRewardRedDot() then
    log(bWriteLog and "theme_system_reddot:UpdateThemeActRewardRedDot has red dot")
    self:_SetSubRedDot(ThemeRedDotType.ThemeActReward, 1)
  else
    log(bWriteLog and "theme_system_reddot:UpdateThemeActRewardRedDot hasn't red dot")
    self:_SetSubRedDot(ThemeRedDotType.ThemeActReward, 0)
  end
  EventSystem:postEvent(EVENTTYPE_THEME_SYSTEM, EVENTID_THEME_SYSTEM_REFRESH_NEW_MARK)
end
function theme_system_reddot:UpdateThemeSystemTaskReddot()
  local logic_theme_system = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_theme_system)
  local bHasFinishedTask = logic_theme_system:CheckTaskFinishedRedDot()
  log(bWriteLog and string.format("theme_system_reddot:UpdateThemeSystemTaskReddot bHasFinishedTask=%s", tostring(bHasFinishedTask)))
  if bHasFinishedTask then
    self:_SetSubRedDot(ThemeRedDotType.TaskFinished, 1)
  else
    self:_SetSubRedDot(ThemeRedDotType.TaskFinished, 0)
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
return class(CModuleBase, nil, theme_system_reddot)