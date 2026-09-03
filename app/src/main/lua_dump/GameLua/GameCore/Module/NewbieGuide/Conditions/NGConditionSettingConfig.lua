local NGConditionSettingConfig = {}
function NGConditionSettingConfig:ctor(selfType, Params)
  self.KeyString = Params.KeyString
  self.ExpectValue = Params.ExpectValue
end
function NGConditionSettingConfig:CheckConditionOK(...)
  local sKeyString = self.KeyString
  local nExpectValue = self.ExpectValue
  if type(sKeyString) ~= "string" or type(nExpectValue) ~= "number" and type(nExpectValue) ~= "boolean" then
    return false
  end
  local uSettingConfig = slua_GameFrontendHUD:GetUserSettings()
  if not uSettingConfig or not slua.isValid(uSettingConfig) then
    return false
  end
  local nSettingValue = uSettingConfig[sKeyString]
  if nSettingValue ~= nil and nSettingValue == nExpectValue then
    return true
  end
  return false
end
local class = require("class")
local CObject = require("GameLua.GameCore.Module.NewbieGuide.Conditions.NewbieGuideConditionBase")
local CNGConditionSettingConfig = class(CObject, nil, NGConditionSettingConfig)
return CNGConditionSettingConfig