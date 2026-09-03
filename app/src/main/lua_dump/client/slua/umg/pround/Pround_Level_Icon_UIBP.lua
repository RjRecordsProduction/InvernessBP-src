local Pround_Level_Icon_UIBP = {}
function Pround_Level_Icon_UIBP:OnClose()
  self.CurUID = nil
  self.isForceShow = nil
end
function Pround_Level_Icon_UIBP:SetData(uid, isForceShow)
  log(bWriteLog and string.format("Pround_Level_Icon_UIBP:SetData. uid=%s, isForceShow=%s", tostring(uid), tostring(isForceShow)))
  self:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  if not uid then
    log(bWriteLog and "Pround_Level_Icon_UIBP:UpdateUI return of not uid")
    return
  end
  self.CurUID = tonumber(uid)
  if self:IsSelf() then
    self.isForceShow = true
  else
    self.  end
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(self.CurUID)
  self:UpdateUI(profile)
end
function Pround_Level_Icon_UIBP:UpdateUI(profile)
  if not profile then
    log(bWriteLog and "Pround_Level_Icon_UIBP:UpdateUI return of not profile")
    return
  end
  local proundInfo = profile.pround_info or {level = 0, is_visable = true}
  if self:IsSelf() then
    proundInfo = DataMgr.roleData.pround_info or {level = 0, is_visable = true}
  end
  if proundInfo.level and proundInfo.level <= 0 then
    log(bWriteLog and "Pround_Level_Icon_UIBP:UpdateUI return of not level <= 0")
    return
  end
  if not self.isForceShow then
    local isVisable = proundInfo.is_visable
    if LobbySystem.CheckOpen(BP_ENUM_ONLY_FRIENFRIEND_PRIVACY) then
      local SettingUtil = require("client.slua.logic.setting.setting_util")
      isVisable = SettingUtil.OnlyFriend(profile.uid, proundInfo.is_visable, 1)
    end
    if not isVisable then
      log(bWriteLog and "Pround_Level_Icon_UIBP:UpdateUI return of not isVisable")
      return
    end
  end
  self:ShowPround(proundInfo.level)
end
function Pround_Level_Icon_UIBP:CustomUpdateUI(level)
  self:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  if level <= 0 then
    log(bWriteLog and "Pround_Level_Icon_UIBP:CustomUpdateUI return of not level <= 0")
    return
  end
  self:ShowPround(level)
end
function Pround_Level_Icon_UIBP:ShowPround(level)
  self:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self.TextBlock_0:SetText(LocUtil.LocalizeResFormat(6417, level))
  local RoleInfoPopularitySystem = require("client.slua.logic.person_space.logic_roleinfo_popularity")
  local iconPath, iconColor = RoleInfoPopularitySystem.GetProundIconPath(level)
  if iconPath then
    local util = require("client.slua_ui_framework.util")
    util.SetTexture(self.Image_0, iconPath)
  end
  if iconColor then
    self.Image_1:SetColorAndOpacity(FLinearColor.FromSRGBColor(FColor.FromHex(iconColor)))
  end
end
function Pround_Level_Icon_UIBP:IsSelf()
  return self.CurUID ~= nil and tonumber(self.CurUID) == tonumber(DataMgr.roleData.uid)
end
local class = require("class")
local OverrideUIBase = require("client.slua_ui_framework.OverrideUIBase")
return class(OverrideUIBase, nil, Pround_Level_Icon_UIBP)