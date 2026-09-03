local SettingModule = {}
local OptionValueChangeListeners = {}
local _OldValueTable = {}
local Vec2DStr = function(vector2d)
  return string.format("[X:%f Y:%f]", vector2d.X, vector2d.Y)
end
function SettingModule:DefineAndResetData()
end
function SettingModule:OnInitialize()
end
function SettingModule:OnDestroy()
  if self.ViewportChangeDelegate then
    local UGameViewportClient = import("/Script/Engine.GameViewportClient")
    if UGameViewportClient and UGameViewportClient.AddViewportChangeDelegate then
      UGameViewportClient.RemoveViewportChangeDelegate(self.ViewportChangeDelegate)
    end
    self.ViewportChangeDelegate = nil
  end
end
function SettingModule:RegistEvents()
  self.ViewportChangeDelegate = slua.createDelegate(function(vViewportOld, vViewportNew)
    self:OnViewportChanged(vViewportOld, vViewportNew)
  end)
  if self.ViewportChangeDelegate then
    local UGameViewportClient = import("/Script/Engine.GameViewportClient")
    if UGameViewportClient and UGameViewportClient.AddViewportChangeDelegate then
      UGameViewportClient.AddViewportChangeDelegate(self.ViewportChangeDelegate)
    end
  end
  local SettingSubsystem_CPP = slua_GameFrontendHUD:GetSettingSubsystem()
  self.UserSettingDelegate = slua.createDelegate(function()
    self:_OnCppUserSettingDelegate()
  end)
  SettingSubsystem_CPP:RegisterUserSettingsDelegate(self.UserSettingDelegate)
end
function SettingModule:OnLogin(bReLogin)
  local SettingRedManager = require("client.slua.logic.setting.setting_redpoint_manager")
  SettingRedManager.RequestServerData()
end
function SettingModule:OnLogOut()
end
function SettingModule:OnPreSwitchGameStatus(preState, nextState)
  print(bWriteLog and string.format("SettingModule:OnPreSwitchGameStatus %s %s", preState or "nil", next or "nil"))
end
function SettingModule:OnPostSwitchGameStatus(preState, nextState)
  print(bWriteLog and string.format("SettingModule:OnPostSwitchGameStatus %s %s", preState or "nil", next or "nil"))
end
function SettingModule:OnViewportChanged(vViewportOld, vViewportNew)
  print(bWriteLog and string.format("SettingModule:OnViewportChanged old:%s new:%s", Vec2DStr(vViewportOld), Vec2DStr(vViewportNew)))
  EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_VIEWPORT_SIZE_CHANGED, vViewportOld, vViewportNew)
end
function SettingModule:GetOptionValue(OptionName)
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  return SettingConfig[OptionName]
end
function SettingModule:SetOptionValue(OptionName, Value)
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  if SettingConfig[OptionName] ~= nil then
    local OldValue = SettingConfig[OptionName]
    if OldValue ~= Value then
      SettingConfig[OptionName] = Value
      self:NotifyOptionValueChange(OptionName, Value, OldValue)
    end
    if OptionValueChangeListeners[OptionName] then
      _OldValueTable[OptionName] = Value
    end
    return true
  else
    return false
  end
end
function SettingModule:AddOptionValueChangeEvent(OptionName, Func, bInitialCall)
  if not assert(OptionName and type(Func) == "function", "SettingModule:AddOptionValueChangeEvent wrong param") then
    return false
  end
  local OptionValue = self:GetOptionValue(OptionName)
  if not type(OptionValue) == "boolean" and not type(OptionValue) == "number" and not type(OptionValue) == "string" then
    return false
  end
  if bInitialCall then
    Func(OptionValue)
  end
  _OldValueTable[OptionName] = OptionValue
  local listeners = OptionValueChangeListeners[OptionName]
  if not listeners then
    listeners = {}
    OptionValueChangeListeners[OptionName] = listeners
  end
  listeners[#listeners + 1] = Func
  return true
end
function SettingModule:RemoveOptionValueChangeEvent(OptionName)
  if not OptionName then
    return
  end
  OptionValueChangeListeners[OptionName] = nil
  _OldValueTable[OptionName] = nil
end
function SettingModule:NotifyOptionValueChange(OptionName, NewValue, OldValue)
  local listeners = OptionValueChangeListeners[OptionName]
  if not listeners then
    return
  end
  for i = 1, #listeners do
    local success, err = pcall(listeners[i], NewValue, OldValue)
    if not success then
      print(bWriteLog and string.format("SettingModule:NotifyOptionValueChange - Error: %s", tostring(err)))
    end
  end
end
function SettingModule:_OnCppUserSettingDelegate()
  for OptionName, _ in pairs(OptionValueChangeListeners) do
    local NewValue = self:GetOptionValue(OptionName)
    local OldValue = _OldValueTable[OptionName]
    if _OldValueTable[OptionName] ~= NewValue then
      self:NotifyOptionValueChange(OptionName, NewValue, OldValue)
      _OldValueTable[OptionName] = NewValue
    end
  end
end
function SettingModule:GetTouchStatFilePath(SlotName, ViewportSize)
  if not ViewportSize then
    local UIUtil = require("client.common.ui_util")
    ViewportSize = UIUtil.GetViewportSize()
  end
  if not SlotName then
    local Setting_UIElemLayout_Interface = require("client.slua.umg.NewSetting.UIElemLayout.Setting_UIElemLayout_Interface")
    SlotName = Setting_UIElemLayout_Interface.GetSlotName_New(Setting_UIElemLayout_Interface.GetInGameCharacterLayoutInfo())
  end
  return string.format("Statistics/TouchStat/TouchStat_%s_%d_%d", SlotName, math.floor(ViewportSize.X), math.floor(ViewportSize.Y))
end
function SettingModule:GetTouchStatData()
  local Path = self:GetTouchStatFilePath()
  local TableArchiver = require("client.logic.NewSetting.TableArchiver")
  print(bWriteLog and "SettingModule:GetTouchStatData " .. Path)
  local TouchStatTable
  if GameStatus.IsInFightingStatus() then
    TouchStatTable = self:CollectTouchStat()
  else
    TouchStatTable = TableArchiver.LoadFile(Path) or {}
  end
  return TouchStatTable
end
function SettingModule:CollectTouchStat()
  local Path = self:GetTouchStatFilePath()
  print(bWriteLog and "SettingModule:CollectTouchStat " .. Path)
  local TableArchiver = require("client.logic.NewSetting.TableArchiver")
  local TouchStatTable = TableArchiver.LoadFile(Path) or {}
  local SettingSubsystem_CPP = slua_GameFrontendHUD:GetSettingSubsystem()
  if slua.isValid(SettingSubsystem_CPP) and slua.isValid(SettingSubsystem_CPP.CustomLayoutProxy) then
    local bSuccessful = SettingSubsystem_CPP.CustomLayoutProxy:CollectTouchStat(TouchStatTable)
    if bSuccessful then
      TableArchiver.SaveFile(Path, TouchStatTable)
    end
  end
  return TouchStatTable
end
function SettingModule:RemoveTouchStatData(InCustomType)
  local TableArchiver = require("client.logic.NewSetting.TableArchiver")
  local TouchStatTable = TableArchiver.LoadFile(self:GetTouchStatFilePath())
  if TouchStatTable and TouchStatTable[InCustomType] then
    TouchStatTable[InCustomType] = nil
    TableArchiver.SaveFile(self:GetTouchStatFilePath(), TouchStatTable)
    return true
  end
  return false
end
function SettingModule:RemoveAllTouchStatData()
  Client.DeleteFile(Client.ProjectSavedDir() .. self:GetTouchStatFilePath())
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
return class(CModuleBase, nil, SettingModule)