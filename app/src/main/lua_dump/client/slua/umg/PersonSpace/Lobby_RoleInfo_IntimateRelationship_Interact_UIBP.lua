local CoupleAvatarConfig = require("client.slua.logic.lobby.Left.CoupleAvatarConfig")
local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
local Lobby_RoleInfo_IntimateRelationship_Interact_UIBP = {}
function Lobby_RoleInfo_IntimateRelationship_Interact_UIBP:ctor()
  self.system = require("client.logic.personspace.logic_person_space_relationship")
  self._tAvatarShowCfg = {
    bPlayCoupleAnim = true,
    UseCacheData = true,
    bCheckIsShow = true,
    bIsShowCar = true,
    bIsShowFriend = true,
    nSourceType = Enum_AvatarShowSource.RoleInfoSegmentUI
  }
  self._tCoupleUIShowCfg = {bIsCheckHideRoleTip = true, bIsShowDownloadUI = true}
  self.isShowPartner = false
  self.currUID = RoleInfoSystem.CurShowPlayerInfoUid
  self.coupleUI = nil
  self.loopDataEffectList = {}
  self.loopDataEffectAllList = {}
  self.isShowUnPartner = false
end
function Lobby_RoleInfo_IntimateRelationship_Interact_UIBP:OnInitialize()
  self.LoopScrollGrid_0 = self:InitScrollBox(self.UIRoot.LoopScrollGrid_0)
  self.LoopScrollGrid_AllCrystal = self:InitScrollBox(self.UIRoot.LoopScrollGrid_AllCrystal)
  self.LoopScrollBox_Progress = self:InitScrollBox(self.UIRoot.LoopScrollBox_Progress)
  self.LoopScrollBox_CanBePartner = self:InitScrollBox(self.UIRoot.LoopScrollBox_0)
  self:SetWidgetVisible(self.UIRoot.ScaleBox_3, false, false)
  self:SetWidgetVisible(self.UIRoot.ScaleBox_1, false, false)
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_16, false, false)
end
function Lobby_RoleInfo_IntimateRelationship_Interact_UIBP:RegistEvents()
  self.LoopScrollGrid_0:SetRefreshItemCallback(self.RefreshGotScrollGridItem, self)
  self.LoopScrollGrid_AllCrystal:SetRefreshItemCallback(self.RefreshAllCrystalItem, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_0, self.OnClickButton_0, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_1, self.OnClickButton_1, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_2, self.OnClickButton_2, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_3, self.OnClickButton_3, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Preview, self.OnClickParterPreview, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_4, self.OnClickParterPreview, self)
  self.LoopScrollBox_CanBePartner:SetRefreshItemCallback(self.OnRefreshCanBePartnerItem, self)
  self.LoopScrollBox_CanBePartner:AddItemWidgetChildEvent("Common_Avatar_BP", "OnClickItemCallback", self.OnClickedHead, self)
  self.LoopScrollBox_CanBePartner:AddItemWidgetChildEvent("Button_Build", "OnClicked", self.OnClickPartnerApply, self)
  self.LoopScrollBox_CanBePartner:AddItemWidgetChildEvent("Button_Cancel", "OnClicked", self.OnClickPartnerCancel, self)
  self.LoopScrollBox_CanBePartner:AddItemWidgetChildEvent("Button_Lock", "OnClicked", self.OnClickLock, self)
  self.LoopScrollGrid_0:AddItemWidgetChildEvent("Button_Select", "OnClicked", self.OnClickedButtonSelect, self)
  self.LoopScrollBox_Progress:SetRefreshItemCallback(self.OnRefreshProgress, self)
  self:AddCommonEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_INFO_UPDATE, self.RefreshUI, self)
  self:AddCommonEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PARTNER_INTIMACY_GET_INFO_RSP, self.RefreshIntimacyPartner, self)
  self:AddCommonEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_INTIMACY_DATA_UPDATE, self.UpdatePartner, self)
  self:AddCommonEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_PARTNER_CHANGE, self.UpdatePartner, self)
  self:AddCommonEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_OTHER_INTIMACY_DATA_UPDATE, self.UpdatePartner, self)
  self:AddCommonEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PARTNER_INTIMACY_AVATAR_RSP, self.RefreshGotScrollGrid, self)
  self:AddCommonEvent(EVENTTYPE_ROLEINFO, EVENTID_SEASON_ROLEINFO_INTERACT_RECORD, self.RefreshGotScrollGrid, self)
  self:AddCommonEvent(EVENTTYPE_PERSON_SPACE, EVENTID_SOULMATE_CERTIFICATION_SET_SHOW_RSP, self.OnSoulmateCertificationSetShowRsp, self)
  self:AddCommonEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PARTNER_FRD_INTIMACY, self.ShowLobby_Crystal_Tips_UIBP, self)
end
function Lobby_RoleInfo_IntimateRelationship_Interact_UIBP:OnPostInitialize()
  local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
  if self.system.IsMySelf(self.currUID) then
    log(bWriteLog and "Lobby_RoleInfo_IntimateRelationship_Interact_UIBP:IsMySelf")
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_21, true, true)
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_2, true, true)
    self:SetWidgetVisible(self.UIRoot.Button_1, true, true)
    self:SetWidgetVisible(self.UIRoot.Button_3, true, true)
    self:SetWidgetVisible(self.UIRoot.Button_2, true, true)
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_24, true, true)
    PersonSpaceSystem.get_intimacy_relation_req()
    local logic_friend_interact_record = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_interact_record)
    logic_friend_interact_record:RequestSeasonInteractDataForPlayer(PersonSpaceSystem.IntimacyPartnerData.partner_uid)
  else
    log(bWriteLog and "Lobby_RoleInfo_IntimateRelationship_Interact_UIBP:not IsMySelf")
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_2, false, false)
    self:SetWidgetVisible(self.UIRoot.Button_1, false, false)
    self:SetWidgetVisible(self.UIRoot.Button_3, false, false)
    self:SetWidgetVisible(self.UIRoot.Button_2, false, false)
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_24, false, false)
    self:RefreshGotScrollGrid()
    PersonSpaceSystem.get_other_intimacy_relation_req(self.currUID)
  end
  local IntimacyAwardSystem = require("client.slua.logic.person_space.logic_intimacy_award")
  IntimacyAwardSystem.get_intimacy_reward_info_req(true)
  self:UpdateUI()
end
function Lobby_RoleInfo_IntimateRelationship_Interact_UIBP:OnClose()
  self:UnloadAvatarScene()
end
function Lobby_RoleInfo_IntimateRelationship_Interact_UIBP:OnClickButton_0()
  log(bWriteLog and "Lobby_RoleInfo_IntimateRelationship_Interact_UIBP:OnClickButton_0")
  self:PlayAudio(sound_config.click_v1)
  if self.system.IsMySelf(self.currUID) then
    local ui_jump_manager = require("client.common.uibase.ui_jump_manager")
    ui_jump_manager.OpenJumpModule(BP_ENUM_MODULE_PARTNER_AWARD, {
      friuid = PersonSpaceSystem.IntimacyPartnerData.partner_uid,
      intimacy = self.intimacy
    })
  end
end
function Lobby_RoleInfo_IntimateRelationship_Interact_UIBP:OnClickButton_1()
  log(bWriteLog and "Lobby_RoleInfo_IntimateRelationship_Interact_UIBP:OnClickButton_1")
  self:PlayAudio(sound_config.click_v1)
  UIManager.ShowUI(UIManager.UI_Config.Lobby_RoleInfo_Relationship_UIBP, true, PersonSpaceSystem.IntimacyPartnerData.partner_uid)
end
function Lobby_RoleInfo_IntimateRelationship_Interact_UIBP:OnClickButton_2()
  log(bWriteLog and "Lobby_RoleInfo_IntimateRelationship_Interact_UIBP:OnClickButton_2 self.isShowUnPartner:" .. tostring(self.isShowUnPartner))
  self:PlayAudio(sound_config.click)
  if self.isShowUnPartner then
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_16, false, false)
    self.isShowUnPartner = false
  else
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_16, true, true)
    self.isShowUnPartner = true
  end
end
function Lobby_RoleInfo_IntimateRelationship_Interact_UIBP:OnClickButton_3()
  log(bWriteLog and "Lobby_RoleInfo_IntimateRelationship_Interact_UIBP:OnClickButton_3")
  self:PlayAudio(sound_config.click)
  if PersonSpaceSystem.IntimacyPartnerData and PersonSpaceSystem.IntimacyPartnerData.partner_uid > 0 then
    log(bWriteLog and "Lobby_RoleInfo_IntimateRelationship_Interact_UIBP:OnClickButton_3: true")
    local uid = PersonSpaceSystem.IntimacyPartnerData.partner_uid
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local profile = logic_profile:GetLocalProfile(uid)
    local nickname = profile and profile.nickName or ""
    local tip = LocUtil.LocalizeResFormat("6607", nickname)
    local promptTip = LocUtil.GetLocalizeResStr("101001")
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(2, promptTip, tip, function()
      PersonSpaceSystem.release_intimacy_partner_req(uid)
    end)
  end
end
function Lobby_RoleInfo_IntimateRelationship_Interact_UIBP:OnClickReward(widgetName, index)
  log(bWriteLog and "Lobby_RoleInfo_IntimateRelationship_Interact_UIBP:OnClickReward index:" .. tostring(index))
  self:PlayAudio(sound_config.click)
  local IntimacyAwardSystem = require("client.slua.logic.person_space.logic_intimacy_award")
  local awards, _ = IntimacyAwardSystem.GetAllAward()
  local rewardID = awards[index].Info.AwardID1
  log(bWriteLog and "Lobby_RoleInfo_IntimateRelationship_Interact_UIBP:OnClickReward rewardID:" .. tostring(rewardID))
  local requireID = awards[index].Info.ID
  log(bWriteLog and "Lobby_RoleInfo_IntimateRelationship_Interact_UIBP:OnClickReward requireID:" .. tostring(requireID))
  local itemData = CDataTable.GetTableData("Item", rewardID)
  log_tree(" Lobby_RoleInfo_IntimateRelationship_Interact_UIBP:OnClickReward itemData:", itemData)
  if itemData and itemData.ItemType == ENUM_ITEM_TYPE.Partner_Stance then
    UIManager.ShowUI(UIManager.UI_Config.Partner_Preview_UIBP, rewardID)
    return
  end
  local UIUtil = require("client.common.ui_util")
  UIUtil.OnClickItemShowDetail(widgetName, rewardID)
end
function Lobby_RoleInfo_IntimateRelationship_Interact_UIBP:OnClickParterPreview()
  log(bWriteLog and "Lobby_RoleInfo_IntimateRelationship_Interact_UIBP:OnClickParterPreview")
  self:PlayAudio(sound_config.click)
  local IntimacyAwardSystem = require("client.slua.logic.person_space.logic_intimacy_award")
  UIManager.ShowUI(UIManager.UI_Config.Partner_Preview_UIBP, IntimacyAwardSystem.GetPoseId(IntimacyAwardSystem.GetEquipPose()))
  self:CloseSelf()
end
function Lobby_RoleInfo_IntimateRelationship_Interact_UIBP:OnClickedHead(widget, index)
  self:PlayAudio(sound_config.click_v1)
  log(bWriteLog and "Lobby_RoleInfo_IntimateRelationship_Interact_UIBP:OnClickedHead index:" .. tostring(index))
  local uid = 0
  if PersonSpaceSystem.IntimacyPartnerData and 0 < PersonSpaceSystem.IntimacyPartnerData.partner_uid then
    uid = PersonSpaceSystem.IntimacyPartnerData.partner_uid
  else
    uid = self.LoopScrollBox_CanBePartner:GetItemData(index).uid
  end
  log(bWriteLog and "Lobby_RoleInfo_IntimateRelationship_Interact_UIBP:OnClickedHead uid:" .. tostring(uid))
  local SocialPersonSpaceSystem = require("client.slua.logic.lobby.Left.logic_social_person_space")
  SocialPersonSpaceSystem.EnterPersonSpace(uid, true)
  self:CloseSelf()
end
function Lobby_RoleInfo_IntimateRelationship_Interact_UIBP:OnClickPartnerApply(widget, index)
  self:PlayAudio(sound_config.click)
  local uid = self.LoopScrollBox_CanBePartner:GetItemData(index).uid
  PersonSpaceSystem.make_intimacy_partner_req(uid)
end
function Lobby_RoleInfo_IntimateRelationship_Interact_UIBP:OnClickPartnerCancel(widget, index)
  self:PlayAudio(sound_config.click)
  local uid = self.LoopScrollBox_CanBePartner:GetItemData(index).uid
  PersonSpaceSystem.cancle_make_intimacy_partner_req(uid)
end
function Lobby_RoleInfo_IntimateRelationship_Interact_UIBP:OnClickLock()
  self:PlayAudio(sound_config.click_v1)
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  QRcodeRestrictManager:ShowRestrictTips()
end
function Lobby_RoleInfo_IntimateRelationship_Interact_UIBP:OnClickedButtonSelect(widget, index)
  self:PlayAudio(sound_config.click_v1)
  self.ShowTipsData = self.LoopScrollGrid_0:GetItemData(index)
  self.ShowTipsWidget = widget
  if self.system.IsMySelf(self.currUID) then
    self:ShowLobby_Crystal_Tips_UIBP()
  else
    local logic_person_relation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_person_relation)
    logic_person_relation:send_get_frd_interact_info_req(tonumber(self.currUID), tonumber(self.ShowTipsData.frd_uid))
  end
end
function Lobby_RoleInfo_IntimateRelationship_Interact_UIBP:ShowLobby_Crystal_Tips_UIBP()
  log(bWriteLog and "Lobby_RoleInfo_IntimateRelationship_Exhibition_UIBP:ShowLobby_Crystal_Tips_UIBP")
  if self.ShowTipsData then
    local IntimacyUtils = require("client.slua.logic.friend.Intimacy.IntimacyUtils")
    IntimacyUtils.ShowCrystalTips(self.ShowTipsData, {
      widget = self.ShowTipsWidget.Button_Select,
      offsetX = 0,
      offsetY = 150,
      data = self.ShowTipsData,
      uid = self.currUID
    })
  end
end
function Lobby_RoleInfo_IntimateRelationship_Interact_UIBP:RefreshUI()
  self.LoopScrollBox_CanBePartner:RefreshAllItems()
end
function Lobby_RoleInfo_IntimateRelationship_Interact_UIBP:UpdateUI()
  log(bWriteLog and "Lobby_RoleInfo_IntimateRelationship_Interact_UIBP:UpdateUI")
  self.UIRoot.TextBlock_1:SetText(LocUtil.GetLocalizeResStr(73607))
  self.UIRoot.TextBlock_8:SetText(LocUtil.GetLocalizeResStr(73615))
  self.UIRoot.TextBlock_6:SetText(LocUtil.GetLocalizeResStr(84368))
  self.UIRoot.TextBlock_2:SetText(LocUtil.GetLocalizeResStr(77159))
  self.UIRoot.TextBlock_25:SetText(LocUtil.GetLocalizeResStr(77159))
  self.UIRoot.UTRichTextBlock_1:SetText(LocUtil.GetLocalizeResStr(77160))
  self.UIRoot.TextBlock_189:SetText(LocUtil.GetLocalizeResStr(45951))
  self.UIRoot.TextBlock_4:SetText(LocUtil.GetLocalizeResStr(73617))
  self.UIRoot.TextBlock_10:SetText(LocUtil.GetLocalizeResStr(73617))
  self.UIRoot.TextBlock_15:SetText(LocUtil.GetLocalizeResStr(73626))
  self.UIRoot.UTRichTextBlock_AllCrystal:SetText(LocUtil.GetLocalizeResStr(84352))
  self:PartnerRedDot()
  self:SetWidgetVisible(self.UIRoot.Image_Reddot, false)
end
function Lobby_RoleInfo_IntimateRelationship_Interact_UIBP:ShowPartner()
  if self.isShowPartner then
    self:SetWidgetVisible(self.UIRoot.ScaleBox_3, false, false)
    self:SetWidgetVisible(self.UIRoot.ScaleBox_1, true, true)
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_10, false, false)
    local IntimacyAwardSystem = require("client.slua.logic.person_space.logic_intimacy_award")
    local awards, _ = IntimacyAwardSystem.GetAllAward()
    self.LoopScrollBox_Progress:SetData(awards)
    self.isShowPartner = false
  end
end
function Lobby_RoleInfo_IntimateRelationship_Interact_UIBP:LoadAvatarScene()
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  local callback = function()
    EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_BACKGROUND_SCENE_LOADED)
  end
  LobbySceneManager.LoadStreamLevel(true, "Lobby_CP01", Lobby_camera_manager_module.Enum_CameraID.PartnerAvatarPose, nil, {bExclusive = true, Callback = callback})
end
function Lobby_RoleInfo_IntimateRelationship_Interact_UIBP:UpdateAvatarRsp(_, _, uid)
  local nCurUId = RoleInfoSystem.CurShowPlayerInfoUid
  if self._cObj_coupleAvatarUI then
    self._cObj_coupleAvatarUI:RefreshShow(nCurUId, true)
  else
    self._cObj_coupleAvatarUI = self:CreateChildWindow(self.UIRoot.CanvasPanel_CoupleAvatar, UIManager.UI_Config.CoupleAvatar_UIBP, nCurUId, CoupleAvatarConfig.ESceneType.Lobby_Partner, self._tAvatarShowCfg, self._tCoupleUIShowCfg)
  end
end
function Lobby_RoleInfo_IntimateRelationship_Interact_UIBP:UnloadAvatarScene()
  local logic_roleInfo_background = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_background)
  logic_roleInfo_background:UnloadCurrentRoleInfoBGLevel()
  LobbySceneManager.LoadStreamLevel(false, "Lobby_CP01")
end
function Lobby_RoleInfo_IntimateRelationship_Interact_UIBP:DestroyPlayerAvatar()
  local CoupleAvatarSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.CoupleAvatarSystem)
  CoupleAvatarSystem:DestoryCoupleAvatar(CoupleAvatarSystem.ESceneType.Lobby_Partner)
end
function Lobby_RoleInfo_IntimateRelationship_Interact_UIBP:RefreshIntimacyPartner()
  self:ShowPartner()
end
function Lobby_RoleInfo_IntimateRelationship_Interact_UIBP:OnSoulmateCertificationSetShowRsp()
  log(bWriteLog and "Lobby_RoleInfo_IntimateRelationship_Interact_UIBP:OnSoulmateCertificationSetShowRsp")
  self:RefreshGotScrollGrid()
end
function Lobby_RoleInfo_IntimateRelationship_Interact_UIBP:RefreshGotScrollGrid()
  log(bWriteLog and "Lobby_RoleInfo_IntimateRelationship_Interact_UIBP:RefreshGotScrollGrid()")
  local logic_person_relation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_person_relation)
  if self.system.IsMySelf(self.currUID) then
    local data = logic_person_relation:GetPartner_srystal_info()
    self:SetWidgetVisible(self.UIRoot.HorizontalBox_AllCrystal, true)
    local logic_friend_interact_record = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_interact_record)
    local allSeasonData = logic_friend_interact_record:GetAllSeasonInteractRecordData(PersonSpaceSystem.IntimacyPartnerData.partner_uid)
    allSeasonData = allSeasonData or {}
    local AllPartnerCrystal = logic_person_relation:GetPartnerDisplayCrystalList(allSeasonData, PersonSpaceSystem.IntimacyPartnerData.partner_uid)
    self:SetPartnerData(data, AllPartnerCrystal)
  else
    self:SetWidgetVisible(self.UIRoot.HorizontalBox_AllCrystal, false)
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles({
      self.currUID
    }, function(list)
      local profile = list[1]
      if profile then
        local partner_srystal_data = {}
        if profile.interact_partner_crystal_data and next(profile.interact_partner_crystal_data) then
          for k, v in pairs(profile.interact_partner_crystal_data) do
            if v.frd_uid == PersonSpaceSystem.IntimacyPartnerData.partner_uid then
              table.insert(partner_srystal_data, v)
            end
          end
        end
        self:SetPartnerData(partner_srystal_data, nil)
      end
    end, Enum_PROFILE_REPORT_CFG.FRIEND_INTERACTION)
  end
end
function Lobby_RoleInfo_IntimateRelationship_Interact_UIBP:SetPartnerData(data, AllPartnerCrystal)
  log(bWriteLog and "Lobby_RoleInfo_IntimateRelationship_Interact_UIBP:SetPartnerData")
  log_tree(bWriteLog and "Lobby_RoleInfo_IntimateRelationship_Interact_UIBP:SetPartnerData data", data)
  log_tree(bWriteLog and "Lobby_RoleInfo_IntimateRelationship_Interact_UIBP:SetPartnerData AllPartnerCrystal", AllPartnerCrystal)
  local PartnerData
  local logic_person_relation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_person_relation)
  PartnerData = logic_person_relation:GetPartnerShowCrystalData(data, PersonSpaceSystem.IntimacyPartnerData.partner_uid, self.currUID)
  if (PartnerData == nil or not next(PartnerData)) and (AllPartnerCrystal == nil or not next(AllPartnerCrystal)) then
    self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(1)
  else
    self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(0)
    if PartnerData then
      self:SetWidgetVisible(self.UIRoot.LoopScrollGrid_0, true)
      self.LoopScrollGrid_0:SetData(PartnerData)
    else
      self:SetWidgetVisible(self.UIRoot.LoopScrollGrid_0, false)
    end
    if AllPartnerCrystal then
      self:SetWidgetVisible(self.UIRoot.LoopScrollGrid_AllCrystal, true)
      self.LoopScrollGrid_AllCrystal:SetData(AllPartnerCrystal)
    else
      self:SetWidgetVisible(self.UIRoot.LoopScrollGrid_AllCrystal, false)
    end
  end
end
function Lobby_RoleInfo_IntimateRelationship_Interact_UIBP:UpdatePartner()
  local IntimacyAwardSystem = require("client.slua.logic.person_space.logic_intimacy_award")
  self:LoadAvatarScene()
  if PersonSpaceSystem.IntimacyPartnerData and PersonSpaceSystem.IntimacyPartnerData.partner_uid > 0 then
    local logic_person_relation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_person_relation)
    if self.system.IsMySelf(self.currUID) then
      logic_person_relation:send_get_interact_avatar_req()
    end
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_21, true, true)
    self:SetWidgetVisible(self.UIRoot.ScaleBox_5, false, false)
    self:SetWidgetVisible(self.UIRoot.ScaleBox_3, true, true)
    self:SetWidgetVisible(self.UIRoot.ScaleBox_1, false, false)
    self:SetWidgetVisible(self.UIRoot.Common_Avatar_BP, true, true)
    self:SetWidgetVisible(self.UIRoot.TextBlock_0, true, true)
    self:UpdateAvatarRsp(nil, nil, self.currUID)
    local uid = PersonSpaceSystem.IntimacyPartnerData.partner_uid
    self.intimacy = LogicFriend.GetInnerFriendIntimacy(uid)
    if self.coupleUI == nil then
      local ui_util = require("client.common.ui_util")
      self.coupleUI = self:CreateChildWindow(self.UIRoot.CanvasPanel_CoupleAvatar, UIManager.UI_Config.Lobby_Left_Couple_UIBP)
    end
    local CoupleAvatarSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.CoupleAvatarSystem)
    self.coupleUI:InitUI(self.currUID, CoupleAvatarSystem.ESceneType.Lobby_Partner)
    self.coupleUI.UIRoot.Common_Avatar_BP:SetButtonEnabled(false)
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local profile = logic_profile:GetLocalProfile(uid)
    if profile then
      self.UIRoot.Common_Avatar_BP:InitView(1, uid, profile.picUrl, 0, profile.cur_avatar_box_id, profile.level, false, "")
      self.UIRoot.Common_Avatar_BP:SetButtonEnabled(false)
    end
    profile = logic_profile:GetLocalProfile(tonumber(self.currUID))
    if profile then
      self.UIRoot.Common_Avatar_BP_C_2:InitView(1, tonumber(self.currUID), profile.picUrl, 0, profile.cur_avatar_box_id, profile.level, false, "")
      self.UIRoot.Common_Avatar_BP_C_2:SetButtonEnabled(false)
    end
    local intimacyData
    if self.system.IsMySelf(self.currUID) then
      intimacyData = LogicFriend.GetIntimacyData(uid)
    else
      local TableUtil = require("common.table_util")
      local HasBuildList = TableUtil.DeepCloneTable(PersonSpaceSystem.FriendDetailsDatas)
      for k, v in pairs(HasBuildList) do
        if v.gid == tostring(uid) then
          intimacyData = v
        end
      end
    end
    if intimacyData and intimacyData.intimacy then
      self.UIRoot.TextBlock_0:SetText(tostring(intimacyData.intimacy))
      local IntimacyAwardSystem = require("client.slua.logic.person_space.logic_intimacy_award")
      local intimacyLvCfg = IntimacyAwardSystem.GetInitimacyLvCfg(intimacyData.intimacy)
      if intimacyLvCfg then
        self.UIRoot.TextBlock_3:SetText(intimacyLvCfg.Level)
        self:SetTexture(self.UIRoot.Image_5, IntimacyAwardSystem.GetInitimacyIcon_Crystal(intimacyData.relation))
      end
    end
  else
    self.intimacy = 0
    if self.system.IsMySelf(self.currUID) then
      self:DestroyPlayerAvatar()
      self:SetWidgetVisible(self.UIRoot.ScaleBox_3, false, false)
      self:SetWidgetVisible(self.UIRoot.ScaleBox_1, true, true)
      self:SetWidgetVisible(self.UIRoot.CanvasPanel_10, true, true)
      local list = LogicFriend.GetIntimacyCanBePartnerList()
      if next(list) then
        self.LoopScrollBox_CanBePartner:SetData(list)
        self.UIRoot.WidgetSwitcher_1:SetActiveWidgetIndex(0)
        self:SetWidgetVisible(self.UIRoot.TextBlock_4, true, true)
      else
        self.UIRoot.WidgetSwitcher_1:SetActiveWidgetIndex(1)
        self:SetWidgetVisible(self.UIRoot.TextBlock_4, false, false)
      end
      local awards, _ = IntimacyAwardSystem.GetAllAward()
      self.LoopScrollBox_Progress:SetData(awards)
    else
      self:SetWidgetVisible(self.UIRoot.CanvasPanel_21, false, false)
      self:SetWidgetVisible(self.UIRoot.ScaleBox_5, true, true)
      self:SetWidgetVisible(self.UIRoot.ScaleBox_3, true, true)
      self:SetWidgetVisible(self.UIRoot.ScaleBox_1, false, false)
      self:SetWidgetVisible(self.UIRoot.Common_Avatar_BP, false, false)
      self:SetWidgetVisible(self.UIRoot.TextBlock_0, false, false)
      self:LoadAvatarScene()
      local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
      local profile = logic_profile:GetLocalProfile(tonumber(self.currUID))
      if profile then
        self.UIRoot.Common_Avatar_BP_C_2:InitView(1, self.currUID, profile.picUrl, 0, profile.cur_avatar_box_id, profile.level, false, "")
        self.UIRoot.Common_Avatar_BP:SetButtonEnabled(false)
      end
    end
  end
end
function Lobby_RoleInfo_IntimateRelationship_Interact_UIBP:RefreshGotScrollGridItem(widget, index)
  local data = self.LoopScrollGrid_0:GetItemData(index)
  local LogicRelationship = require("client.logic.personspace.logic_person_space_relationship")
  self:SetWidgetVisible(widget.Canvas_Panel_Select, false, false)
  local cfg = data.cfg
  if cfg and cfg.EffectPath and cfg.EffectPath ~= "" then
    if self.loopDataEffectList[index] then
      self.loopDataEffectList[index]:CloseSelf()
    end
    self:SetWidgetVisible(widget.Image_Item, false, false)
    self:SetWidgetVisible(widget.CanvasPanel_Small, true, true)
    local effectUi = self:CreateChildWindowWithBpPath(widget.CanvasPanel_Small, nil, cfg.EffectPath)
    self:PlayUserWidgetAnimation(effectUi.loop, 0, 0, 0, 1)
    self.loopDataEffectList[index] = effectUi
  else
    self:SetWidgetVisible(widget.Image_Item, true, true)
    self:SetWidgetVisible(widget.CanvasPanel_Small, false, false)
    self:SetTexture(widget.Image_Item, cfg.CrystalPath)
  end
  self:SetTexture(widget.Image_quality, cfg.QualityPath)
  self:SetWidgetVisible(widget.Image_0, false, false)
end
function Lobby_RoleInfo_IntimateRelationship_Interact_UIBP:RefreshAllCrystalItem(widget, index)
  local data = self.LoopScrollGrid_AllCrystal:GetItemData(index)
  local LogicRelationship = require("client.logic.personspace.logic_person_space_relationship")
  self:SetWidgetVisible(widget.Canvas_Panel_Select, false, false)
  local cfg = data.cfg
  if cfg and cfg.EffectPath and cfg.EffectPath ~= "" then
    if self.loopDataEffectAllList[index] then
      self.loopDataEffectAllList[index]:CloseSelf()
    end
    self:SetWidgetVisible(widget.Image_Item, false, false)
    self:SetWidgetVisible(widget.CanvasPanel_Small, true, true)
    local effectUi = self:CreateChildWindowWithBpPath(widget.CanvasPanel_Small, nil, cfg.EffectPath)
    self:PlayUserWidgetAnimation(effectUi.loop, 0, 0, 0, 1)
    self.loopDataEffectAllList[index] = effectUi
  else
    self:SetWidgetVisible(widget.Image_Item, true, true)
    self:SetWidgetVisible(widget.CanvasPanel_Small, false, false)
    self:SetTexture(widget.Image_Item, cfg.CrystalPath)
  end
  self:SetTexture(widget.Image_quality, cfg.QualityPath)
  self:SetWidgetVisible(widget.Image_0, false, false)
end
function Lobby_RoleInfo_IntimateRelationship_Interact_UIBP:OnRefreshProgress(widget, index)
  if index == 1 then
    widget.ProgressBar_1.Slot:SetOffsets(FMargin(0, 0, 0, 10))
  else
    widget.ProgressBar_1.Slot:SetOffsets(FMargin(-86.5, 0, 0, 10))
  end
  local data = self.LoopScrollBox_Progress:GetItemData(index)
  local IntimacyAwardSystem = require("client.slua.logic.person_space.logic_intimacy_award")
  local awards, _ = IntimacyAwardSystem.GetAllAward()
  if not PersonSpaceSystem.IntimacyPartnerData or not (0 < PersonSpaceSystem.IntimacyPartnerData.partner_uid) then
    data.status = 0
  end
  log_tree("[v_yunjxing] Lobby_RoleInfo_IntimateRelationship_Interact_UIBP:OnRefreshProgress", data)
  widget.Lua_CommonItems:InitView(data.Info.AwardID1, 1, 0)
  widget.Lua_CommonItems:SetAwardState(data.status)
  widget.Lua_CommonItems:SetLight(data.status == 1)
  widget.Lua_CommonItems:SetClickItemCallback(self.OnClickReward, self, widget.Lua_CommonItems, index)
  widget.TextBlock_26:SetText(LocUtil.LocalizeResFormat(7570, data.Info.RequireIntimacy))
  local beforeIntimacy = 0
  if index ~= 1 then
    beforeIntimacy = awards[index - 1].Info.RequireIntimacy
  end
  local Interval = data.Info.RequireIntimacy - beforeIntimacy
  local CurrentInterval = 0
  if beforeIntimacy < self.intimacy then
    CurrentInterval = self.intimacy - beforeIntimacy
  end
  local percent = 0
  percent = CurrentInterval / Interval
  widget.ProgressBar_1:SetPercent(percent)
end
function Lobby_RoleInfo_IntimateRelationship_Interact_UIBP:OnRefreshCanBePartnerItem(widget, index)
  local list = LogicFriend.GetIntimacyCanBePartnerList()
  local data = list[index]
  widget.TextBlock_0:SetText(LocUtil.GetLocalizeResStr(8779))
  widget.TextBlock_1:SetText(LocUtil.GetLocalizeResStr(34643))
  if not data then
    return
  end
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(data.uid)
  if profile then
    widget.Common_Avatar_BP:InitView(1, data.uid, profile.picUrl, 0, profile.cur_avatar_box_id, profile.level, false, "")
    widget.Common_Avatar_BP:SetButtonEnabled(false)
    local solo, duo, squad = FuncUtil.GetMaxSegement(profile.segment_info)
    local maxRank = math.max(solo, duo, squad)
    widget.Common_RankIntegralLevel_Style_Small_UIBP:SetRankInteral(maxRank, nil)
    local UnknowPassUtil = require("client.slua.logic.unknow_pass.logic_unknowpass_util")
    local upass_is_buy, upass_is_show, upass_keep_buy, upass_cur_value, pass_type = UnknowPassUtil.ParseUpassInfo(profile.upass)
    widget.UnknowPass_ContinuousBuy_BP:SetTypeData(0, upass_keep_buy, upass_is_buy == 1, 1, upass_cur_value, pass_type or 0)
    local UIUtil = require("client.common.ui_util")
    widget.UnknowPass_ContinuousBuy_BP:SetWidgetVisibility(UIUtil.BoolToVisible(upass_is_show ~= 0))
    widget.Text_Name:SetText(profile.nickName)
    UIUtil.UpdateNationImageByLua(widget.Image_Nation, profile.nation)
    if widget.Common_Gender_UIBP then
      widget.Common_Gender_UIBP:LoadIcon(profile.uid)
    end
  end
  local intimacy = tonumber(LogicFriend.GetInnerFriendIntimacy(data.uid))
  widget.Text_Intimacy:SetText(tostring(intimacy))
  local IntimacyAwardSystem = require("client.slua.logic.person_space.logic_intimacy_award")
  local intimacyLvCfg = IntimacyAwardSystem.GetInitimacyLvCfg(intimacy)
  if intimacyLvCfg then
    widget.Lobby_RoleInfo_IntimacyItem_UIBP.TextBlock_Lv:SetText(intimacyLvCfg.Level)
    self:SetTexture(widget.Lobby_RoleInfo_IntimacyItem_UIBP.Image_Icon, IntimacyAwardSystem.GetInitimacyIcon_other(data.param))
  end
  widget.WidgetSwitcher_State:SetActiveWidgetIndex(1)
  local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
  if PersonSpaceSystem.IntimacyPartnerData and PersonSpaceSystem.IntimacyPartnerData.sent_request_list then
    for i, v in pairs(PersonSpaceSystem.IntimacyPartnerData.sent_request_list) do
      if data.uid == i then
        widget.WidgetSwitcher_State:SetActiveWidgetIndex(0)
        break
      end
    end
  end
end
function Lobby_RoleInfo_IntimateRelationship_Interact_UIBP:PartnerRedDot()
  local IntimacyAwardSystem = require("client.slua.logic.person_space.logic_intimacy_award")
  local redBool = IntimacyAwardSystem.HasIntimacyRewardReddot()
  log(bWriteLog and "Lobby_RoleInfo_IntimateRelationship_Interact_UIBP:PartnerRedDot() redBool" .. tostring(redBool))
  self:SetWidgetVisible(self.UIRoot.Image_Reddot_01, redBool, redBool)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CLobby_RoleInfo_IntimateRelationship_Interact_UIBP = class(ui_base, nil, Lobby_RoleInfo_IntimateRelationship_Interact_UIBP)
return CLobby_RoleInfo_IntimateRelationship_Interact_UIBP