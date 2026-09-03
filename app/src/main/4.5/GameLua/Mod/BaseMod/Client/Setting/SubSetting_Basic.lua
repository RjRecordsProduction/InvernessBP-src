local SubSetting_Basic = {}
function SubSetting_Basic:OnInit()
  printf("SubSetting_Basic:OnInit")
  self.ModifySetting = nil
  self:CheckModDefaultSetting()
end
function SubSetting_Basic:OnRelease()
  printf("SubSetting_Basic:OnRelease")
  self:ResumeDefaultSetting()
end
function SubSetting_Basic:CheckModDefaultSetting()
  print(bWriteLog and "SubSetting_Basic:CheckModDefaultSetting")
  local DefaultSettingConfig = self:GetModDefaultSetting()
  if not DefaultSettingConfig then
    printf("SubSetting_Basic:CheckModDefaultSetting No Mod DefaultSettingConfig")
    return
  end
  if not self.ModifySetting then
    self.ModifySetting = {}
  end
  local SettingAccount = require("client.logic.setting.logic_setting_account")
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  for _, Config in pairs(DefaultSettingConfig) do
    if Config.RoleSetting == 0 then
      local CurValue = SettingConfig[Config.SettingKey]
      if Config.Type == "number" then
        if CurValue == tonumber(Config.ClassicDefaultValue) then
          SettingConfig[Config.SettingKey] = tonumber(Config.DefaultValue)
          self.ModifySetting[Config.SettingKey] = {}
          self.ModifySetting[Config.SettingKey][1] = tonumber(Config.DefaultValue)
          self.ModifySetting[Config.SettingKey][2] = tonumber(Config.ClassicDefaultValue)
        end
      elseif Config.Type == "bool" then
        if CurValue == (Config.ClassicDefaultValue == "1") then
          SettingConfig[Config.SettingKey] = Config.DefaultValue == "1"
          self.ModifySetting[Config.SettingKey] = {}
          self.ModifySetting[Config.SettingKey][1] = Config.DefaultValue == "1"
          self.ModifySetting[Config.SettingKey][2] = Config.ClassicDefaultValue == "1"
        end
      else
        print(bWriteLog and "SubSetting_Basic:CheckModDefaultSetting Not Add This Type Logic Config.Type = " .. Config.Type)
      end
    elseif SettingAccount.ForbidFollowJump and SettingAccount.ForbidFollowJump == (Config.ClassicDefaultValue == "1") then
      DataMgr.SendSettingReq_Bool(false, RoleSettingType[Config.SettingKey], DataMgr.GetRoleSetting(RoleSettingType[Config.SettingKey]) ~= 0)
      SettingAccount.ForbidFollowJump = not SettingAccount.ForbidFollowJump
      self.ModifySetting[Config.SettingKey] = {}
      self.ModifySetting[Config.SettingKey][1] = Config.DefaultValue == "1"
      self.ModifySetting[Config.SettingKey][2] = Config.ClassicDefaultValue == "1"
      self.ModifySetting[Config.SettingKey].RoleSetting = true
    end
  end
  slua_GameFrontendHUD:FinishModifyUserSettings()
end
function SubSetting_Basic:ResumeDefaultSetting()
  print(bWriteLog and "SubSetting_Basic:ResumeDefaultSetting")
  local SettingAccount = require("client.logic.setting.logic_setting_account")
  if self.ModifySetting then
    for SettingKey, Value in pairs(self.ModifySetting) do
      if not Value.RoleSetting then
        local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
        if SettingConfig[SettingKey] == Value[1] then
          SettingConfig[SettingKey] = Value[2]
        end
      elseif SettingAccount.ForbidFollowJump == Value[1] then
        DataMgr.SendSettingReq_Bool(false, RoleSettingType[SettingKey], DataMgr.GetRoleSetting(RoleSettingType[SettingKey]) ~= 0)
        SettingAccount.ForbidFollowJump = not SettingAccount.ForbidFollowJump
      end
    end
    slua_GameFrontendHUD:FinishModifyUserSettings()
  end
  self.ModifySetting = nil
end
function SubSetting_Basic:GetModDefaultSetting()
  print(bWriteLog and "SubSetting_Basic:GetModDefaultSetting")
  local ClientGameMain = require("GameLua.GameCore.Main.ClientGameMain")
  local DefaultSettingConfig = ClientGameMain.GetUIOtherSetting("DefaultSettingConfig")
  if not DefaultSettingConfig then
    printf("SubSetting_Basic:GetModDefaultSetting No Mod DefaultSettingConfig")
    return
  end
  local DefaultSetting = CDataTable.GetTable(DefaultSettingConfig)
  return DefaultSetting
end
local class = require("class")
local CDelegateContainer = require("common.delegate_container")
local CSubSetting_Basic = class(CDelegateContainer, nil, SubSetting_Basic)
return CSubSetting_Basic