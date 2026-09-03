local RoleInfo_Relationship_Net = {
  circleHeadScaleList = {
    FVector2D(1.3, 1.3),
    FVector2D(1.2, 1.2),
    FVector2D(1.1, 1.1),
    FVector2D(1, 1)
  }
}
local friend_intimacy_net_config = require("client.slua.logic.friend.Intimacy.friend_intimacy_net_config")
function RoleInfo_Relationship_Net:ctor(_, uid)
  log(bWriteLog and "RoleInfo_Relationship_Net:ctor uid = " .. uid)
  self.uid = tonumber(uid)
  self.cpUid = nil
  self.bIsShowCP = false
  self.cpIndex = nil
  self.bIsBondingOpen = false
end
function RoleInfo_Relationship_Net:OnInitialize()
  RoleInfo_Relationship_Net.__super.OnInitialize(self)
end
function RoleInfo_Relationship_Net:RegistEvents()
  RoleInfo_Relationship_Net.__super.RegistEvents(self)
  for i = 1, friend_intimacy_net_config.HeadNumMax do
    local item = self.UIRoot["Lobby_RoleInfo_" .. i]
    self:AddControlEventByControl(item.Common_Avatar_Intimate_friend, "OnClickItemCallback", self.OnClickAvatar, self, i)
  end
  self:AddCommonEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_INTIMACY_CHANGE, self.UpdateUI, self)
  if self.uid ~= tonumber(DataMgr.roleData.uid) then
    self:AddControlEventByControl(self.UIRoot.Common_Avatar_Intimate_FC1, "OnClickItemCallback", self.OnClickCPAvatar, self, self.uid)
  end
  self:AddControlEventByControl(self.UIRoot.Common_Avatar_Intimate_FC2, "OnClickItemCallback", self.OnClickCPAvatar, self)
end
function RoleInfo_Relationship_Net:OnPostInitialize()
  RoleInfo_Relationship_Net.__super.OnPostInitialize(self)
  self:UpdateUI()
end
function RoleInfo_Relationship_Net:UpdateUI()
  log(bWriteLog and "RoleInfo_Relationship_Net:UpdateUI")
  self:UpdateUI_CenterAvatar()
  local friend_intimacy_net_tool = require("client.slua.logic.friend.Intimacy.friend_intimacy_net_tool")
  self.uidInfoList = friend_intimacy_net_tool.GetUidList(self.uid)
  log_tree("self.uidInfoList = ", self.uidInfoList)
  for i = 1, friend_intimacy_net_config.HeadNumMax do
    self:UpdateUI_CircleAvatar(i)
  end
end
function RoleInfo_Relationship_Net:UpdateUI_CenterAvatar()
  log(bWriteLog and "RoleInfo_Relationship_Net:UpdateUI_CenterAvatar")
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(self.uid)
  if not profile then
    log(bWriteLog and "RoleInfo_Relationship_Net:UpdateUI_CenterAvatar no profile")
    return
  end
  local IntimacyUtils = require("client.slua.logic.friend.Intimacy.IntimacyUtils")
  self.bIsBondingOpen = IntimacyUtils.IsBondingSystemOpen()
  if not self.bIsBondingOpen then
    self:RefreshBigAvatar(profile)
  else
    local logic_friend_intimacy = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_intimacy)
    local intimacy_visible_switchs_tool = require("client.slua.logic.friend.Intimacy.intimacy_visible_switchs_tool")
    local bMySelf = tonumber(DataMgr.roleData.uid) == self.uid
    local bIntimacyVisible = intimacy_visible_switchs_tool.GetRelationVisibleSwitchs(self.uid, logic_friend_intimacy.EIntimacyRelationType.Bonding)
    local intimacyList = logic_friend_intimacy:GetTargetIntimacyList(self.uid, logic_friend_intimacy.EIntimacyRelationType.Bonding)
    if bMySelf then
      log(bWriteLog and "RoleInfo_Relationship_Net:UpdateUI_CenterAvatar - self")
      if intimacyList and next(intimacyList) then
        self:RefreshDoubleAvatar(profile, intimacyList)
      else
        self:RefreshBigAvatar(profile)
      end
    else
      log(bWriteLog and "RoleInfo_Relationship_Net:UpdateUI_CenterAvatar - not self")
      if bIntimacyVisible and intimacyList and next(intimacyList) then
        self:RefreshDoubleAvatar(profile, intimacyList)
      else
        self:RefreshBigAvatar(profile)
      end
    end
  end
end
function RoleInfo_Relationship_Net:UpdateUI_CircleAvatar(index)
  log(bWriteLog and "RoleInfo_Relationship_Net:UpdateUI_CircleAvatar index = " .. index)
  local item = self.UIRoot["Lobby_RoleInfo_" .. index]
  if index > #self.uidInfoList then
    item.CanvasPanel_7:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  item.CanvasPanel_7:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  local uidInfo = self.uidInfoList[index]
  if self.bIsBondingOpen and self.bIsShowCP and uidInfo.uid == self.cpUid then
    log(bWriteLog and "RoleInfo_Relationship_Net:UpdateUI_CircleAvatar cp cancel")
    item.CanvasPanel_7:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(uidInfo.uid)
  if not profile then
    log(bWriteLog and "RoleInfo_Relationship_Net:UpdateUI_CircleAvatar no profile")
    return
  end
  item.Common_Avatar_Intimate_friend:InitView(uidInfo.uid, profile.picUrl, profile.sex, 0, profile.level, false, "")
  item.Text_Name:SetText(profile.nickName)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local bIsPlayerBanned = logic_profile:IsPlayerBannedOver30day(uidInfo.uid)
  if bIsPlayerBanned then
    self:SetWidgetVisible(item.CanvasPanel_Ban, true)
  else
    self:SetWidgetVisible(item.CanvasPanel_Ban, false)
  end
  local friend_intimacy_net_tool = require("client.slua.logic.friend.Intimacy.friend_intimacy_net_tool")
  local iconPath = friend_intimacy_net_tool.GetIconPath(self.uid, uidInfo.uid)
  if iconPath == "" then
    item.Image_Icon:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    self:SetTexture(item.Image_Icon, iconPath)
    item.Image_Icon:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
  local bMySelf = tonumber(DataMgr.roleData.uid) == self.uid
  if bMySelf then
    if uidInfo.uidLevel == 1 then
      item.CanvasPanel_7:SetRenderScale(RoleInfo_Relationship_Net.circleHeadScaleList[1])
    elseif uidInfo.uidLevel == 2 then
      item.CanvasPanel_7:SetRenderScale(RoleInfo_Relationship_Net.circleHeadScaleList[2])
    elseif uidInfo.uidLevel == 3 then
      item.CanvasPanel_7:SetRenderScale(RoleInfo_Relationship_Net.circleHeadScaleList[3])
    elseif uidInfo.uidLevel == nil then
      item.CanvasPanel_7:SetRenderScale(RoleInfo_Relationship_Net.circleHeadScaleList[4])
    end
  elseif #self.uidInfoList <= 5 then
    item.CanvasPanel_7:SetRenderScale(RoleInfo_Relationship_Net.circleHeadScaleList[2])
  else
    item.CanvasPanel_7:SetRenderScale(RoleInfo_Relationship_Net.circleHeadScaleList[4])
  end
end
function RoleInfo_Relationship_Net:RefreshDoubleAvatar(profile, intimacyList)
  log(bWriteLog and "RoleInfo_Relationship_Net:RefreshDoubleAvatar")
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_FatefulConnection, true)
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_Myself, false)
  self.UIRoot.Common_Avatar_Intimate_FC1:InitView(self.uid, profile.picUrl, profile.sex, profile.cur_avatar_box_id, profile.level, false, "")
  self.UIRoot.Text_FCName1:SetText(profile.nickName)
  if intimacyList and next(intimacyList) then
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    self.cpUid = next(intimacyList)
    local cpProfile = logic_profile:GetLocalProfile(tonumber(self.cpUid))
    if cpProfile then
      self.UIRoot.Common_Avatar_Intimate_FC2:InitView(self.cpUid, cpProfile.picUrl, cpProfile.sex, cpProfile.cur_avatar_box_id, cpProfile.level, false, "")
      self.UIRoot.Text_FCName2:SetText(cpProfile.nickName)
      self.bIsShowCP = true
    else
      log(bWriteLog and "RoleInfo_Relationship_Net:RefreshDoubleAvatar cpProfile is nil")
    end
  else
    log(bWriteLog and "RoleInfo_Relationship_Net:RefreshDoubleAvatar no intimacyList")
  end
end
function RoleInfo_Relationship_Net:RefreshBigAvatar(profile)
  log(bWriteLog and "RoleInfo_Relationship_Net:RefreshBigAvatar")
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_FatefulConnection, false)
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_Myself, true)
  if not profile then
    log(bWriteLog and "RoleInfo_Relationship_Net:RefreshBigAvatar no profile")
    self.UIRoot.Common_Avatar_Intimate_friend:InitView(self.uid, "", 0, 0, 1, false, "")
    self.UIRoot.Text_Name:SetText("")
    return
  end
  local logic_roleInfo_BigAvatar = require("client.slua.logic.roleInfo.logic_roleInfo_BigAvatar")
  local bigPicUrl = logic_roleInfo_BigAvatar.ModifyURLToBig(profile.picUrl)
  self.UIRoot.Common_Avatar_Intimate_friend:InitView(self.uid, bigPicUrl, profile.sex, profile.cur_avatar_box_id, profile.level, false, "")
  self.UIRoot.Text_Name:SetText(profile.nickName)
end
function RoleInfo_Relationship_Net:OnClickAvatar(index, uid)
  self:PlayAudio(sound_config.click_v1)
  log(bWriteLog and "RoleInfo_Relationship_Net:OnClickAvatar index = " .. index)
  local info = self.uidInfoList[index]
  if not info then
    return
  end
  if info.uidLevel then
    UIManager.ShowUI(UIManager.UI_Config.Lobby_RoleInfo_Intimacy_Apply_Small_UIBP, info.uid, self.UIRoot["Lobby_RoleInfo_" .. index].Common_Avatar_Intimate_friend, index)
  elseif self.uid == tonumber(DataMgr.roleData.uid) then
    UIManager.ShowUI(UIManager.UI_Config.Lobby_RoleInfo_IntimateRelationship_RecordMain_UIBP, info.uid, 1, 3)
  else
    local SocialPersonSpaceSystem = require("client.slua.logic.lobby.Left.logic_social_person_space")
    SocialPersonSpaceSystem.EnterPersonSpace(uid, true)
  end
end
function RoleInfo_Relationship_Net:OnClickCPAvatar(uid)
  self:PlayAudio(sound_config.click_v1)
  log(bWriteLog and "RoleInfo_Relationship_Net:OnClickCPAvatar")
  local jumpUid
  local reg = 0
  if not uid then
    jumpUid = self.cpUid
    reg = 1
  else
    jumpUid = uid
    reg = 2
  end
  log(bWriteLog and "RoleInfo_Relationship_Net:OnClickCPAvatar jumpUid = " .. tostring(jumpUid) .. "reg = " .. tostring(reg))
  if not jumpUid then
    log(bWriteLog and "RoleInfo_Relationship_Net:OnClickCPAvatar no jumpUid")
    return
  end
  if self.uid == tonumber(DataMgr.roleData.uid) then
    UIManager.ShowUI(UIManager.UI_Config.Lobby_RoleInfo_IntimateRelationship_RecordMain_UIBP, jumpUid, 1, 3)
  else
    local SocialPersonSpaceSystem = require("client.slua.logic.lobby.Left.logic_social_person_space")
    SocialPersonSpaceSystem.EnterPersonSpace(jumpUid, true)
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CUITemplate = class(ui_base, nil, RoleInfo_Relationship_Net)
return CUITemplate