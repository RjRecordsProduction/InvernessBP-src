local SettingSubsystem = {}
local SubSettings = {
  Basic = "GameLua.Mod.BaseMod.Client.Setting.SubSetting_Basic",
  Pickup = "GameLua.Mod.BaseMod.Client.Setting.SubSetting_Pickup"
}
local CustomLayoutProxy = require("GameLua.Mod.BaseMod.Client.Setting.CustomLayoutProxy")
SettingSubsystem.CustomLayoutSaveType = CustomLayoutProxy.SaveType
function SettingSubsystem:_Initialize()
  print(bWriteLog and "SettingSubsystem:_Initialize")
  if self.Inited then
    return
  end
  if not self.SubSettingMap then
    self.SubSettingMap = {}
  end
  if not self.Delegates then
    self.Delegates = {}
  end
  if not self.SettingSubsystem_CPP then
    self.SettingSubsystem_CPP = slua_GameFrontendHUD:GetSettingSubsystem()
  end
  self.Inited = true
  for Name, Path in pairs(SubSettings) do
    if not self.SubSettingMap[Name] then
      local SubSettingClass = require(Path)
      local SubSetting = SubSettingClass()
      if SubSetting and SubSetting.OnInit then
        SubSetting:OnInit()
      end
      self.SubSettingMap[Name] = SubSetting
      print(bWriteLog and "SettingSubsystem:_Initialize Name = %s Path = %s", Name, Path)
    else
      print(bWriteLog and "SettingSubsystem:_Initialize Fail Exist Name = %s Path = %s", Name, Path)
    end
  end
end
function SettingSubsystem:OnInit()
  print(bWriteLog and "SettingSubsystem:OnInit")
  self:EnsureInit()
  if self.SettingSubsystem_CPP then
    local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
    local SettingReportConfig = GamePlayTools.GetCurrentConfig("SettingReportConfig")
    if Client and SettingReportConfig and SettingReportConfig.ReportItemConfig then
      local ReportSettingItems = SettingReportConfig.ReportItemConfig
      for idx, SettingName in pairs(ReportSettingItems) do
        self.SettingSubsystem_CPP.ReportSettingConfig:Add(idx, SettingName)
      end
      self.SettingSubsystem_CPP:OnRefreshReportSettingConfig()
    end
    if self.SettingSubsystem_CPP.CustomLayoutProxy then
      self.SettingSubsystem_CPP.CustomLayoutProxy:OnInitInGame()
    else
      print(bWriteLog and "SettingSubsystem:OnInit cannot get CustomLayoutProxy" .. tostring(self.SettingSubsystem_CPP.CustomLayoutProxy))
    end
  else
    print(bWriteLog and "SettingSubsystem:OnInit cannot get SettingSubsystem_CPP" .. tostring(self.SettingSubsystem_CPP))
  end
end
function SettingSubsystem:OnRelease()
  print(bWriteLog and "SettingSubsystem:OnRelease")
  if self.SettingSubsystem_CPP and self.SettingSubsystem_CPP.CustomLayoutProxy then
    self.SettingSubsystem_CPP.CustomLayoutProxy:OnReleaseInGame()
  end
  if self.SubSettingMap then
    for _, SubSetting in pairs(self.SubSettingMap) do
      if SubSetting then
        if SubSetting.OnRelease then
          SubSetting:OnRelease()
        end
        if SubSetting.Dispose then
          SubSetting:Dispose()
        end
      end
    end
  end
  if self.Delegates then
    for Handle, _ in pairs(self.Delegates) do
      self:UnregisterUserSettingDelegate(Handle)
    end
  end
  self.SubSettingMap = nil
  self.SettingSubsystem_CPP = nil
  self.Delegates = nil
  self.Inited = false
  SettingSubsystem.__super.OnRelease(self)
end
function SettingSubsystem:EnsureInit()
  if not self.Inited then
    self:_Initialize()
  end
end
function SettingSubsystem:RegisterUserSettingsDelegate_Bool(PropertyName, CallBack)
  print(bWriteLog and "SettingSubsystem:RegisterUserSettingsDelegate_Bool " .. PropertyName)
  self:EnsureInit()
  local Delegate = slua.createDelegate(CallBack)
  local Handle = self.SettingSubsystem_CPP:RegisterUserSettingsDelegate_Bool(PropertyName, Delegate)
  self.Delegates[Handle] = Delegate
  return Handle
end
function SettingSubsystem:RegisterUserSettingsDelegate_Int(PropertyName, CallBack)
  print(bWriteLog and "SettingSubsystem:RegisterUserSettingsDelegate_Int " .. PropertyName)
  self:EnsureInit()
  local Delegate = slua.createDelegate(CallBack)
  local Handle = self.SettingSubsystem_CPP:RegisterUserSettingsDelegate_Int(PropertyName, Delegate)
  self.Delegates[Handle] = Delegate
  return Handle
end
function SettingSubsystem:RegisterUserSettingsDelegate_Float(PropertyName, CallBack)
  print(bWriteLog and "SettingSubsystem:RegisterUserSettingsDelegate_Float " .. PropertyName)
  self:EnsureInit()
  local Delegate = slua.createDelegate(CallBack)
  local Handle = self.SettingSubsystem_CPP:RegisterUserSettingsDelegate_Float(PropertyName, Delegate)
  self.Delegates[Handle] = Delegate
  return Handle
end
function SettingSubsystem:UnregisterUserSettingDelegate(Handle)
  if Handle and self.Delegates and self.Delegates[Handle] then
    self.SettingSubsystem_CPP:UnregisterUserSettingDelegate(Handle)
    self.Delegates[Handle] = nil
  end
end
function SettingSubsystem:GetUserSettings_Bool(PropertyName)
  self:EnsureInit()
  return self.SettingSubsystem_CPP:GetUserSettings_Bool(PropertyName)
end
function SettingSubsystem:GetUserSettings_Int(PropertyName)
  self:EnsureInit()
  return self.SettingSubsystem_CPP:GetUserSettings_Int(PropertyName)
end
function SettingSubsystem:GetUserSettings_Float(PropertyName)
  self:EnsureInit()
  return self.SettingSubsystem_CPP:GetUserSettings_Float(PropertyName)
end
function SettingSubsystem:GetUserSettings_String(PropertyName)
  self:EnsureInit()
  return self.SettingSubsystem_CPP:GetUserSettings_String(PropertyName)
end
function SettingSubsystem:SetUserSettings_Bool(PropertyName, Value)
  self:EnsureInit()
  self.SettingSubsystem_CPP:SetUserSettings_Bool(PropertyName, Value, false)
end
function SettingSubsystem:SetUserSettings_Int(PropertyName, Value)
  self:EnsureInit()
  self.SettingSubsystem_CPP:SetUserSettings_Int(PropertyName, Value)
end
function SettingSubsystem:SetUserSettings_Float(PropertyName, Value)
  self:EnsureInit()
  self.SettingSubsystem_CPP:SetUserSettings_Float(PropertyName, Value)
end
function SettingSubsystem:SetUserSettings_String(PropertyName, Value)
  self:EnsureInit()
  self.SettingSubsystem_CPP:SetUserSettings_String(PropertyName, Value)
end
function SettingSubsystem:BroadcastCustomLayoutChangeByCustomType(InCustomType)
  self:EnsureInit()
  local CustomLayoutProxy = self.SettingSubsystem_CPP.CustomLayoutProxy
  if CustomLayoutProxy then
    CustomLayoutProxy:BroadcastCustomLayoutChangeByCustomType(InCustomType, true)
  end
end
function SettingSubsystem:BroadcastCustomLayoutChangeBySaveType(InSaveType)
  self:EnsureInit()
  local CustomLayoutProxy = self.SettingSubsystem_CPP.CustomLayoutProxy
  if CustomLayoutProxy then
    CustomLayoutProxy:BroadcastCustomLayoutChangeBySaveType(InSaveType)
  end
end
function SettingSubsystem:BroadcastCustomLayoutChangeByCustomTypeList(InList)
  self:EnsureInit()
  local CustomLayoutProxy = self.SettingSubsystem_CPP.CustomLayoutProxy
  if CustomLayoutProxy then
    CustomLayoutProxy:BroadcastCustomLayoutChangeByCustomTypeList(InList)
  end
end
function SettingSubsystem:GetLayoutDetailByType(InCustomType)
  self:EnsureInit()
  local CustomLayoutProxy = self.SettingSubsystem_CPP.CustomLayoutProxy
  if CustomLayoutProxy and CustomLayoutProxy.GetLayoutDetailByType then
    return CustomLayoutProxy:GetLayoutDetailByType(InCustomType)
  elseif not CustomLayoutProxy then
    print(bWriteLog and "SettingSubsystem:GetLayoutDetailByType CustomLayoutProxy == nil")
  elseif not CustomLayoutProxy.GetLayoutDetailByType then
    print(bWriteLog and "SettingSubsystem:GetLayoutDetailByType CustomLayoutProxy.GetLayoutDetailByType == nil")
  end
end
local class = require("class")
local SubSystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubSystemBase, nil, SettingSubsystem)