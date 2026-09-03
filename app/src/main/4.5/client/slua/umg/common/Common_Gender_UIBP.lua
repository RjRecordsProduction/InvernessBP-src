local Common_Gender_UIBP = {CurUID = nil}
function Common_Gender_UIBP:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_CARDINFO, self.OnRoleCardInfoChange, self)
end
function Common_Gender_UIBP:OnClose()
  self.CurUID = nil
end
function Common_Gender_UIBP:LoadIcon(uid, isOutline)
  log(bWriteLog and "[Common_Gender_UIBP] LoadIcon: uid:" .. tostring(uid))
  log(bWriteLog and "[Common_Gender_UIBP] LoadIcon: isOutline:" .. tostring(isOutline))
  if not uid then
    log(bWriteLog and "[Common_Gender_UIBP] invalid params")
    self:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  if tonumber(uid) <= 0 then
    self:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  self.CurUID = tonumber(uid)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local sex = logic_profile:GetRoleSexByUid(uid)
  self:UpdateSexIcon(sex, isOutline)
end
function Common_Gender_UIBP:UpdateSexIcon(sex, isOutline)
  if sex == 0 then
    self:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    self:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
  local uiUtil = require("client.slua_ui_framework.util")
  if isOutline then
    if sex == 1 then
      uiUtil.SetTexture(self.Image_0, "/Game/UMG/Texture_200/Atlas/Home/Frames/Home_Icon_Boy_png.Home_Icon_Boy_png")
    elseif sex == 2 then
      uiUtil.SetTexture(self.Image_0, "/Game/UMG/Texture_200/Atlas/Home/Frames/Home_Icon_Girl_png.Home_Icon_Girl_png")
    end
  elseif sex == 1 then
    uiUtil.SetTexture(self.Image_0, "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Boy_png.Common_Icon_Boy_png")
  elseif sex == 2 then
    uiUtil.SetTexture(self.Image_0, "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Girl_png.Common_Icon_Girl_png")
  end
end
function Common_Gender_UIBP:LoadIconByExternalData(new_sex)
  local gender = new_sex or 0
  self:UpdateSexIcon(gender)
end
function Common_Gender_UIBP:OnRoleCardInfoChange()
  log(bWriteLog and "[Common_Gender_UIBP] OnRoleCardInfoChange")
  if not self:IsSelf() then
    log(bWriteLog and "[Common_Gender_UIBP] not self showing")
    return
  end
  local gender = self:GetLocalPlayerGenderData()
  self:LoadIcon(tonumber(DataMgr.roleData.uid))
end
function Common_Gender_UIBP:GetLocalPlayerGenderData()
  local gender = 0
  local SocialCardSystem = require("client.slua.logic.lobby.Left.logic_social_card")
  if SocialCardSystem and SocialCardSystem.MySocialCard then
    gender = SocialCardSystem.MySocialCard.new_sex
  end
  return gender
end
function Common_Gender_UIBP:IsSelf()
  return self.CurUID ~= nil and tonumber(self.CurUID) == tonumber(DataMgr.roleData.uid)
end
local class = require("class")
local OverrideUIBase = require("client.slua_ui_framework.OverrideUIBase")
return class(OverrideUIBase, nil, Common_Gender_UIBP)