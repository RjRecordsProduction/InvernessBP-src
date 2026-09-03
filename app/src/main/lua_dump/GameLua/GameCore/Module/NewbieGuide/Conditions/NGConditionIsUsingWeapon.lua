local NGConditionIsUsingWeapon = {}
function NGConditionIsUsingWeapon:ctor(selfType, Params)
  self.WeaponList = Params.WeaponList or {}
end
function NGConditionIsUsingWeapon:CheckConditionOK(...)
  local bSuperOk = NGConditionIsUsingWeapon.__super.CheckConditionOK(self, ...)
  if not bSuperOk then
    return false
  end
  local uWeapon = self:GetCurUsingWeapon()
  if uWeapon and slua.isValid(uWeapon) then
    local uItemDefineID = uWeapon:GetItemDefineID()
    if uItemDefineID and uItemDefineID.TypeSpecificID then
      local TableUtil = require("common.table_util")
      if TableUtil.Find(self.WeaponList, uItemDefineID.TypeSpecificID) ~= -1 then
        log(bWriteLog and "Debug NewbieGuide: NGConditionIsUsingWeapon CheckConditionOK: True")
        return true
      end
    end
  end
  log(bWriteLog and "Debug NewbieGuide: NGConditionIsUsingWeapon CheckConditionOK: False")
  return false
end
function NGConditionIsUsingWeapon:GetCurUsingWeapon()
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return nil
  end
  local uPlayerPawn = uPlayerController:GetPlayerCharacterSafety()
  if not slua.isValid(uPlayerPawn) then
    return nil
  end
  local uWeaponManager = uPlayerPawn:GetWeaponManager()
  if not slua.isValid(uWeaponManager) then
    return nil
  end
  return uWeaponManager:GetCurrentUsingWeapon()
end
local class = require("class")
local CObject = require("GameLua.GameCore.Module.NewbieGuide.Conditions.NewbieGuideConditionBase")
local CNGConditionIsUsingWeapon = class(CObject, nil, NGConditionIsUsingWeapon)
return CNGConditionIsUsingWeapon