local logic_weapon_enter_anim = {}
local NeedShowWeaponEnterAnimModuleCfgToNameMaps = {
  item_upgrade = true,
  ItemPreview_UIBP = true,
  NewStoreSystem = true,
  NewSupplySystem = true
}
local IsSystemNeedShowWeaponAnim = function(keyName)
  if type(keyName) ~= "string" then
    return false
  end
  if NeedShowWeaponEnterAnimModuleCfgToNameMaps[keyName] then
    return true
  end
  return false
end
function logic_weapon_enter_anim:ctor()
  self.ShowingModules = {}
end
function logic_weapon_enter_anim:RegistEvents()
  logic_weapon_enter_anim.__super.RegistEvents(self)
  log(bWriteLog and "logic_weapon_enter_anim RegistEvents")
  self:AddCommonEvent(EVENTTYPE_OLD_WIDGET, EVENTID_ON_ALL_WIDGET_HIDE, self.OnUIHide, self)
  self:AddCommonEvent(EVENTID_UI, BP_ENUM_UI_SHOW, self.OnUIShow, self)
end
function logic_weapon_enter_anim:OnUIHide(_, _, keyName)
  self:OnUIShowOrHide(keyName, false)
end
function logic_weapon_enter_anim:OnUIShow(_, _, uiCfg)
  self:OnUIShowOrHide(uiCfg.keyName, true)
end
function logic_weapon_enter_anim:OnUIShowOrHide(keyName, bShow)
  if keyName == nil then
    return
  end
  if not IsSystemNeedShowWeaponAnim(keyName) then
    return
  end
  if bShow then
    self.ShowingModules[keyName] = 1
  else
    self.ShowingModules[keyName] = 0
  end
end
function logic_weapon_enter_anim:NeedShowEnterAnimThisTime()
  local showUICfgKeyName
  for _keyName, _ in pairs(NeedShowWeaponEnterAnimModuleCfgToNameMaps) do
    if UIManager.IsUIShow(UIManager.UI_Config[_keyName]) then
      showUICfgKeyName = _keyName
      break
    end
  end
  if showUICfgKeyName == nil then
    return false
  end
  if self.ShowingModules[showUICfgKeyName] and self.ShowingModules[showUICfgKeyName] == 1 then
    self.ShowingModules[showUICfgKeyName] = 0
    return true
  end
  return false
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_weapon_enter_anim = class(CModuleBase, nil, logic_weapon_enter_anim)
return Clogic_weapon_enter_anim