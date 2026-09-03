local SettingModule = {}
local OptionValueChangeListeners = {}
local _OldValueTable = {}
local Vec2DStr = function(vector2d)
  return string.format("[X:%f Y:%f]", vector2d.X, vector2d.Y)
end
local HasLogin = function()
  if LobbySystem and LobbySystem.roleData and next(LobbySystem.roleData) then
    return true
  end
end
function SettingModule:DefineAndResetData()
end
function SettingModule:OnInitialize()
  local Utility = require("common.utility")
  self.Subsystem = Utility.GetGameInstanceSubsystemByName("SettingSubsystem")
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
  self.UserSettingDelegate = slua.createDelegate(function()
    self:_OnCppUserSettingDelegate()
  end)
  self.Subsystem:RegisterUserSettingsDelegate(self.UserSettingDelegate)
end
function SettingModule:OnLogin(bReLogin)
  local SettingRedManager = require("client.slua.logic.setting.setting_redpoint_manager")
  local LobbySettingCatalog = require("client.logic.NewSetting.SettingCatalog")
  SettingRedManager.Init(LobbySettingCatalog)
  SettingRedManager.RequestServerData()
end
function SettingModule:OnLogOut()
end
function SettingModule:OnPostSwitchGameStatus(preState, nextState)
  print(bWriteLog and string.format("SettingModule:OnPostSwitchGameStatus %s %s", preState or "nil", nextState or "nil"))
  if preState ~= GameStatus.Fighting and nextState == GameStatus.Fighting then
    local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
    self._ModName = GameMainConfig.GetModType()
    self:PullSettingInMod(self._ModName)
    local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
    local SettingRedManager = require("client.slua.logic.setting.setting_redpoint_manager")
    SettingRedManager.Init(GamePlayTools.GetCurrentConfig("SettingCatalog"))
    if HasLogin() then
      SettingRedManager.RequestServerData()
    else
      SettingRedManager.OnGetRedPointCfg(nil)
    end
  elseif preState == GameStatus.Fighting and nextState ~= GameStatus.Fighting then
    self:PushSettingInMod(self._ModName)
    self.CurrentModSetting = nil
    self._ModName = nil
  end
end
function SettingModule:OnViewportChanged(vViewportOld, vViewportNew)
  print(bWriteLog and string.format("SettingModule:OnViewportChanged old:%s new:%s", Vec2DStr(vViewportOld), Vec2DStr(vViewportNew)))
  EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_VIEWPORT_SIZE_CHANGED, vViewportOld, vViewportNew)
end
local _GetEditorModSettingPath = function(ModName)
  return "SaveGames/UserSetting_" .. ModName .. ".dat"
end
function SettingModule:PullSettingInMod(ModName)
  if not ModName then
    return
  end
  local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
  local DefaultModSetting = GamePlayTools.GetCurrentConfig("UserSettingInMod")
  if DefaultModSetting and next(DefaultModSetting) then
    self.CurrentModSetting = {}
    for k, v in pairs(DefaultModSetting) do
      self.CurrentModSetting[k] = v
    end
  else
    return
  end
  if Client.IsEditor() and not HasLogin() then
    local TableArchiver = require("client.logic.NewSetting.TableArchiver")
    local FilePath = _GetEditorModSettingPath(ModName)
    local SavedSetting = TableArchiver.LoadFile(FilePath)
    if SavedSetting then
      for k, v in pairs(SavedSetting) do
        if self.CurrentModSetting[k] ~= nil then
          self.CurrentModSetting[k] = v
        end
      end
    end
    print(bWriteLog and "SettingModule:PullSettingInMod - Editor local load", ModName)
    return
  end
  print(bWriteLog and "SettingModule:PullSettingInMod - Pulling for mod:" .. tostring(ModName))
  local logic_battle_data_transmission = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_battle_data_transmission)
  logic_battle_data_transmission:GetOrReqPlayerGeneralData(ModName, function(bSuccess, DataCopy)
    if bSuccess and DataCopy.UserSetting and self.CurrentModSetting then
      for k, v in pairs(DataCopy.UserSetting) do
        if self.CurrentModSetting[k] ~= nil then
          self.CurrentModSetting[k] = v
        end
      end
      print(bWriteLog and "SettingModule:PullSettingInMod - Loaded", ModName)
      log_tree("SettingModule:PullSettingInMod", self.CurrentModSetting)
    else
      print(bWriteLog and "SettingModule:PullSettingInMod - Failed", ModName)
    end
  end)
end
function SettingModule:PushSettingInMod(ModName)
  ModName = ModName or self._ModName
  if not ModName or not self.CurrentModSetting then
    return
  end
  local DefaultModSetting = self._DefaultModSetting
  local DiffSetting = {}
  if DefaultModSetting then
    local TableUtil = require("common.table_util")
    for k, v in pairs(self.CurrentModSetting) do
      if DefaultModSetting[k] ~= nil then
        if type(v) == "table" and type(DefaultModSetting[k]) == "table" then
          if not TableUtil.IsSameTable(v, DefaultModSetting[k]) then
            DiffSetting[k] = v
          end
        elseif v ~= DefaultModSetting[k] then
          DiffSetting[k] = v
        end
      end
    end
  else
    DiffSetting = self.CurrentModSetting
  end
  if Client.IsEditor() then
    local TableArchiver = require("client.logic.NewSetting.TableArchiver")
    local FilePath = _GetEditorModSettingPath(ModName)
    TableArchiver.SaveFile(FilePath, DiffSetting)
    print(bWriteLog and "SettingModule:PushSettingInMod - Editor local save", ModName)
  end
  local logic_battle_data_transmission = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_battle_data_transmission)
  print(bWriteLog and "SettingModule:PushSettingInMod - Pushing for mod:" .. tostring(ModName))
  logic_battle_data_transmission:GetOrReqPlayerGeneralData(ModName, function(bSuccess, DataCopy)
    if bSuccess then
      DataCopy.UserSetting = DiffSetting
      logic_battle_data_transmission:SetPlayerGeneralData(ModName, DataCopy)
      print(bWriteLog and "SettingModule:PushSettingInMod - Successfully", ModName)
      log_tree("SettingModule:PushSettingInMod", DiffSetting)
    else
      print(bWriteLog and "SettingModule:PushSettingInMod - Failed", ModName)
    end
  end)
end
function SettingModule:GetOptionValue(OptionName)
  local SettingConfig = self.Subsystem:GetUserSettings()
  if self.CurrentModSetting and self.CurrentModSetting[OptionName] ~= nil then
    return self.CurrentModSetting[OptionName]
  end
  return SettingConfig[OptionName]
end
function SettingModule:SetOptionValue(OptionName, Value)
  local SettingConfig = self.Subsystem:GetUserSettings()
  if self.CurrentModSetting and self.CurrentModSetting[OptionName] ~= nil then
    self:_UpdateValue(OptionName, Value, self.CurrentModSetting)
    return true
  elseif SettingConfig[OptionName] ~= nil then
    self:_UpdateValue(OptionName, Value, SettingConfig)
    return true
  else
    return false
  end
end
function SettingModule:_UpdateValue(OptionName, Value, PropertyContainer)
  local OldValue = PropertyContainer[OptionName]
  if OldValue ~= Value then
    PropertyContainer[OptionName] = Value
    self:NotifyOptionValueChange(OptionName, Value, OldValue)
  end
  if OptionValueChangeListeners[OptionName] then
    _OldValueTable[OptionName] = Value
  end
end
function SettingModule:AddOptionValueChangeEvent(OptionName, Func, bInitialCall)
  if not assert(OptionName and type(Func) == "function", "SettingModule:AddOptionValueChangeEvent wrong param") then
    return false
  end
  local OptionValue = self:GetOptionValue(OptionName)
  if type(OptionValue) ~= "boolean" and type(OptionValue) ~= "number" and type(OptionValue) ~= "string" then
    return false
  end
  if bInitialCall then
    Func(OptionValue)
  end
  if _OldValueTable[OptionName] == nil then
    _OldValueTable[OptionName] = OptionValue
  end
  local listeners = OptionValueChangeListeners[OptionName]
  if not listeners then
    listeners = {}
    OptionValueChangeListeners[OptionName] = listeners
  end
  listeners[#listeners + 1] = Func
  return true
end
function SettingModule:RemoveOptionValueChangeEvent(OptionName, Func)
  if not OptionName or not Func then
    return
  end
  local listeners = OptionValueChangeListeners[OptionName]
  if listeners then
    local count = #listeners
    for i = count, 1, -1 do
      if listeners[i] == Func then
        table.remove(listeners, i)
        break
      end
    end
    if #listeners == 0 then
      _OldValueTable[OptionName] = nil
    end
  end
end
function SettingModule:NotifyOptionValueChange(OptionName, NewValue, OldValue)
  local listeners = OptionValueChangeListeners[OptionName]
  if not listeners then
    return
  end
  for i = 1, #listeners do
    local success, err = pcall(listeners[i], NewValue, OldValue)
    if success then
      print(bWriteLog and "SettingModule:NotifyOptionValueChange", OptionName, NewValue, OldValue)
    else
      print(bWriteLog and "SettingModule:NotifyOptionValueChange Error", OptionName, tostring(err))
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
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
return class(CModuleBase, nil, SettingModule)