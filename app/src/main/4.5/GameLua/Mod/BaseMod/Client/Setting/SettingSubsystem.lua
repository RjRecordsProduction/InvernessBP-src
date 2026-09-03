local SettingSubsystem = {}
local SubSettings = {
  Basic = "GameLua.Mod.BaseMod.Client.Setting.SubSetting_Basic",
  Pickup = "GameLua.Mod.BaseMod.Client.Setting.SubSetting_Pickup"
}
function SettingSubsystem:_Initialize()
  print(bWriteLog and "SettingSubsystem:_Initialize")
  if self.Inited then
    return
  end
  if not self.SubSettingMap then
    self.SubSettingMap = {}
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
  else
    print(bWriteLog and "SettingSubsystem:OnInit cannot get SettingSubsystem_CPP " .. tostring(self.SettingSubsystem_CPP))
  end
end
function SettingSubsystem:OnRelease()
  print(bWriteLog and "SettingSubsystem:OnRelease")
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
  self.SubSettingMap = nil
  self.SettingSubsystem_CPP = nil
  self.Inited = false
  SettingSubsystem.__super.OnRelease(self)
end
function SettingSubsystem:EnsureInit()
  if not self.Inited then
    self:_Initialize()
  end
end
local class = require("class")
local SubSystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubSystemBase, nil, SettingSubsystem)