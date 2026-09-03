local ExpressionPop_New_UIBP = {}
function ExpressionPop_New_UIBP:ctor(_, actionID)
  self.HasStanbyAction = false
  self.ErrorTipID = 0
  self.bTransform = false
  self.nCurPetID = 0
  self.nCurPetInsID = 0
  self.nCurPetActionID = 0
  self.actionID = actionID or 0
end
function ExpressionPop_New_UIBP:OnInitialize()
  self.LoopScrollGrid_Action = self:InitScrollBox(self.UIRoot.LoopScrollGrid_Action)
  self.FollowLeaderCheckBox = self.UIRoot.CheckBox_FollowLeader
  self.LoopScrollGrid_Pet = self:InitScrollBox(self.UIRoot.LoopScrollGrid_Pet)
  self.LoopScrollGrid_Souvenirs = self:InitScrollBox(self.UIRoot.LoopScrollGrid_Souvenirs)
  self.LoopScrollGrid_Flaunt = self:InitChildClassScrollBox(self.UIRoot.LoopScrollGrid_Flaunt, "client.slua.umg.Souvenirs.Pet_LobbyControl_Item_01_UIBP")
  local LobbyEmoteManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyEmoteManager)
  LobbyEmoteManager:ReqSelfMileStoneData()
  local PetHandler = require("client.network.Protocol.PetHandler")
  PetHandler.send_get_pet_switch_effect_req()
  local logic_wardrobe_avatar = require("client.slua.logic.wardrobe.logic_wardrobe_avatar")
  logic_wardrobe_avatar:InitCurrentWearPreviewMap()
end
function ExpressionPop_New_UIBP:RegistEvents()
  self:AddOnClickedEventByControl(self.UIRoot.Button_Close, self.OnButton_CloseClick, self)
  self:ResgistActionEvent()
  self:RegistPetEvent()
  self:RegistSouvenirsEvent()
  self:RegistShowOffEvent()
end
function ExpressionPop_New_UIBP:ResgistActionEvent()
  self.LoopScrollGrid_Action:SetRefreshItemCallback(self.OnRefreshLoopScrollGrid_ActionItem, self)
  self.LoopScrollGrid_Action:AddItemWidgetChildEvent("Button_SubTab", "OnClicked", self.OnClickLoopScrollGrid_ActionItem, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_EXclose, self.OnButton_EXcloseClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_StandbyAction, self.OnButton_StandbyActionClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Transfiguration, self.OnClickChangeFormButton, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_0, self.OnClickCartoonStyle, self)
  self:AddOnCheckStateChangedEventByControl(self.UIRoot.CheckBox_FollowLeader, self.OnCheckBoxChanged, self)
  self:AddOnCheckStateChangedEventByControl(self.UIRoot.CheckBox_ShowEffect, self.OnCheckBoxShowEffectChanged, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN, self.OnLobbyHide, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE, self.OnLobbyShow, self)
  self:AddCommonEvent(EVENTTYPE_MOTION, EVENTID_MOTION_UPDATE_SLOT_LIST, self.OnActionEquipStateChange, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTIP_TEAMUP_FOLLOW_LEADER_EMOTE_UPDATE, self.OnFollowLeaderEmoteUpdate, self)
  self:AddCommonEvent(EVENTTYPE_MOTION, EVENTID_MOTION_ON_SHOWEFFECT_UPDATE, self.OnShowEffectUpdate, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_ACTION_PALY_END, self.OnEndActionHandle, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_DRAGON_LOCK_SUCCESS, self.OnRefreshImageLock, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_DRAGON_REQ_TRANSFROM_SUCCESS, self.OnPlayTransformAnim, self)
end
function ExpressionPop_New_UIBP:RegistPetEvent()
  self.LoopScrollGrid_Pet:SetRefreshItemCallback(self.OnRefreshPetListItem, self)
  self.LoopScrollGrid_Pet:AddItemWidgetChildEvent("Btn_PlayAction", "OnClicked", self.OnClickedPetItem, self)
end
function ExpressionPop_New_UIBP:RegistSouvenirsEvent()
  self.LoopScrollGrid_Souvenirs:SetRefreshItemCallback(self.OnRefreshSouvenirsList, self)
  self.LoopScrollGrid_Souvenirs:AddItemWidgetChildEvent("Btn_PlayAction", "OnClicked", self.OnClickedSouvenirsActionItem, self)
end
function ExpressionPop_New_UIBP:RegistShowOffEvent()
  self:AddCommonEvent(EVENTTYPE_MOTION, EVENTID_MOTION_MILELIST_DATA_CHANGE, self.OnMileListDataChange, self)
end
function ExpressionPop_New_UIBP:OnPostInitialize()
  self:RefreshAllUI()
  self:PlayUserWidgetAnimation(self.UIRoot.open, 0, 1, 0, 1)
  self:ClearReddot()
  if self.actionID then
    self:OnClickPetButtonByItemId(self.actionID)
  end
end
function ExpressionPop_New_UIBP:OnClose()
  EventSystem:postEvent(EVENTTYPE_MOTION, EVENTID_MOTION_CLOSE_EXPERSSION_UI)
end
function ExpressionPop_New_UIBP:OnClickedSouvenirsActionItem(widget, index)
  self:PlayAudio(sound_config.click_v1)
  local data = self.LoopScrollGrid_Souvenirs:GetItemData(index)
  if not data then
    log(bWriteLog and "ExpressionPop_New_UIBP:OnClickedSouvenirsActionItem No Data")
    return
  end
  local motionId = data.emotionId
  local realMotionID = 0
  local itemCfg = CDataTable.GetTableData("Item", motionId)
  if itemCfg == nil then
    return
  end
  if GlobalData.IsJapanOrKorea() and 0 < itemCfg.JKBPID then
    realMotionID = itemCfg.JKBPID
  else
    realMotionID = itemCfg.BPID
  end
  local XMissionSystem = require("client.slua.logic.TxMission.logic_xmission_main")
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local isInXMission = XMissionSystem.IsInXMission()
  local showingAvatar
  if isInXMission then
    local XMissionAvatarMgr = require("client.slua.logic.TxMission.logic_xmission_avatar_mgr")
    showingAvatar = XMissionAvatarMgr.GetMainAvatar()
  else
    showingAvatar = TeamAvatarManager.GetMainAvatar()
  end
  local pet = showingAvatar and showingAvatar:GetPet()
  if pet ~= nil and pet:IsPlayingAction() then
    pet:StopAction()
  end
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.SOUVENIRS_ACTION_DISPLAY, motionId)
  local LogicParticleEmote = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicParticleEmote)
  if DataMgr.show_effect and LogicParticleEmote:HasUnlockParticle(realMotionID) then
    realMotionID = LogicParticleEmote:GetParticleEmoteID(realMotionID)
    log(bWriteLog and "[ParticleEmote]  ExpressionPopUIBP:OnClickLoopScrollGrid_0Item realMotionID:" .. tostring(realMotionID))
  end
  local myUid = DataMgr.roleData.uid
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local sex = logic_profile:GetRoleSexByUid(myUid, true)
  local LogicLobbyExpression = require("client.slua.logic.lobby.logic_lobby_expression")
  local randSoundId = LogicLobbyExpression.GetTauntRandSoundID(realMotionID, sex)
  local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
  local XMissionAvatarMgr = require("client.slua.logic.TxMission.logic_xmission_avatar_mgr")
  local bCanPlay = true
  if isInXMission then
    bCanPlay = XMissionAvatarMgr.PlayAction(DataMgr.roleData.uid, realMotionID)
    LobbyAvatarManager.PlayEmotionSound(realMotionID, sex, randSoundId, DataMgr.roleData.uid)
  else
    bCanPlay = LobbyAvatarManager.PlayEmoteAction(DataMgr.roleData.uid, realMotionID, sex, randSoundId)
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if TeamUpNewSystem.GetTeamNum() > 1 and bCanPlay then
    TeamUpNewSystem.team_player_action(motionId, randSoundId)
  end
end
function ExpressionPop_New_UIBP:OnRefreshLoopScrollGrid_ActionItem(widget, index)
  local data = self.expressList[index]
  if data == nil then
    return
  end
  widget:SetData(data.itemId, false)
  local UIUtil = require("client.common.ui_util")
  local LogicParticleEmote = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicParticleEmote)
  if LogicParticleEmote:HasUnlockParticle(data.itemId) then
    local ParticleEmote = LogicParticleEmote:GetParticleEmoteID(data.itemId)
    local iconPath, bHasAddKnownMissing = UIUtil.GetItemSmallIcon(ParticleEmote, widget.Image_Icon)
    self:SetTexture(widget.Image_Icon, iconPath, {bHasAddKnownMissing = bHasAddKnownMissing})
    widget.WidgetSwitcher_ParticleEmote:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    if DataMgr.show_effect then
      widget.WidgetSwitcher_ParticleEmote:SetActiveWidgetIndex(1)
    else
      widget.WidgetSwitcher_ParticleEmote:SetActiveWidgetIndex(0)
    end
  elseif data.bGloveBindEmote then
    widget.WidgetSwitcher_ParticleEmote:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    local iconPath = "/Game/Arts/UI/TableIcons/Emote/Icon_Emote_BoxingGloves_128.Icon_Emote_BoxingGloves_128"
    local bHasAddKnownMissing = UIUtil.CheckSmallIconMissing(iconPath, widget.Image_icon)
    self:SetTexture(widget.Image_Icon, iconPath, {bHasAddKnownMissing = bHasAddKnownMissing})
  else
    widget.WidgetSwitcher_ParticleEmote:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    local iconPath, bHasAddKnownMissing = UIUtil.GetItemSmallIcon(data.itemId, widget.Image_Icon)
    self:SetTexture(widget.Image_Icon, iconPath, {bHasAddKnownMissing = bHasAddKnownMissing})
  end
  if data.bWeaponBindEmote then
    widget.Image_3:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    widget.Image_3:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if data.bGloveBindEmote then
    widget.CanvasPanel_BoxingGloves:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    widget.CanvasPanel_BoxingGloves:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local common_download_handler = require("client.slua.common.common_download_handler")
  common_download_handler.CreateDownloadUI(PufferConst.ENUM_DownloadType.ODPAK, {
    data.itemId
  }, widget.Panel_Download)
end
function ExpressionPop_New_UIBP:OnClickLoopScrollGrid_ActionItem(widget, index)
  self:PlayAudio(sound_config.click_v1)
  local data = self.expressList[index]
  if data == nil or data.itemId == 0 then
    return
  end
  local expression_util = require("client.slua.umg.Souvenirs.Expression_Util")
  expression_util.PlayExpression(data.itemId)
  ClientSendTLogReport(TLogEventDefine.LobbyExpressionItemClick)
end
function ExpressionPop_New_UIBP:OnButton_EXcloseClick()
  self:PlayAudio(sound_config.click_v1)
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  WardrobeLogicManager:Enter(wardrobe_macro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Parachute, wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_emoj)
  ClientSendTLogReport(TLogEventDefine.LobbyExpressionCloseJump)
end
function ExpressionPop_New_UIBP:OnClickCartoonStyle()
  self:PlayAudio(sound_config.click_v1)
  local logic_wardrobe_avatar = require("client.slua.logic.wardrobe.logic_wardrobe_avatar")
  logic_wardrobe_avatar:InitCurrentWearPreviewMap()
  local wearInfo = logic_wardrobe_avatar:GetCurrentWearPreview(BP_ENUM_AVATAR_CLOTH)
  if not wearInfo then
    return
  end
  local LogicMultiItemModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicMultiItemModule)
  local Cfg = LogicMultiItemModule:GetCartoonStyleCfg(wearInfo.resID)
  if not Cfg then
    return
  end
  local AfterClothID = Cfg.CartoonStyleID
  if wearInfo.resID == Cfg.CartoonStyleID then
    AfterClothID = Cfg.BaseID
  end
  log(bWriteLog and "ExpressionPop_New_UIBP:OnClickCartoonStyle AfterClothID = " .. tostring(AfterClothID))
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local itemData = wardrobe_data:GetHallDepotItemDataByResID(AfterClothID, wardrobe_data:GetItemSource(wearInfo.insID))
  if not itemData then
    log(bWriteLog and "ExpressionPop_New_UIBP:OnClickCartoonStyle not item")
    return
  end
  local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
  WardRobeHandler.send_depot_put_on_req(itemData.insID)
  local XMissionSystem = require("client.slua.logic.TxMission.logic_xmission_main")
  local isInXMission = XMissionSystem.IsInXMission()
  if isInXMission then
    local XMissionAvatarMgr = require("client.slua.logic.TxMission.logic_xmission_avatar_mgr")
    XMissionAvatarMgr.PutOnEquipment(DataMgr.roleData.uid, {skinID = AfterClothID})
  end
end
function ExpressionPop_New_UIBP:OnClickChangeFormButton()
  self:PlayAudio(sound_config.click_v1)
  if GlobalData.IsJapanOrKorea() then
    self:ReqPlayChangeFromAnim()
  else
    self:PlayChangeFromAnim()
  end
end
function ExpressionPop_New_UIBP:ReqPlayChangeFromAnim()
  local bGet = DataMgr.roleData.dragon_ball_unlock_state
  local DragonChangeForm = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.DragonChangeForm)
  local config, source = DragonChangeForm:GetSelfConfigByCurWear()
  if source == EWardrobeDataSource.InheritWardrobe then
    if not config then
      log(bWriteLog and "ExpressionPop_New_UIBP:ReqPlayChangeFromAnim not config")
      return
    else
      bGet = true
    end
  end
  if not bGet then
    local title = LocUtil.GetLocalizeResStr(150075)
    local unlockNum = 50
    local msg = LocUtil.LocalizeResFormat(150076, unlockNum)
    local btnOK = LocUtil.GetLocalizeResStr(150077)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(2, title, msg, function()
      local diamond = DataMgr.diamond
      log(bWriteLog and "ExpressionPopUIBP:OnClickChangeFormButton diamond = " .. tostring(diamond))
      if diamond < unlockNum then
        ShowNotice(4457)
        return
      end
      local DragonHandler = require("client.network.Protocol.DragonHandler")
      DragonHandler.send_unlock_dragon_ball_items_req()
    end, nil, btnOK, nil, {
      showUIKey = "com_msg_small_box_slua"
    })
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_LookbackGuide, false, false)
    DragonChangeForm:UpdateGuideState(2)
    return
  end
  local DragonHandler = require("client.network.Protocol.DragonHandler")
  DragonHandler.send_dragon_ball_animation_req(source)
end
function ExpressionPop_New_UIBP:PlayChangeFromAnim()
  local DragonChangeForm = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.DragonChangeForm)
  if self.bTransform then
    return
  end
  local config = DragonChangeForm:GetSelfConfigByCurWear()
  if not config or config.ActionID == nil then
    return
  end
  local bDownload = DragonChangeForm:CheckDownloadState(config)
  if not bDownload then
    DragonChangeForm:DownloadAllItems(config)
    ShowNotice(7421)
    return
  end
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local sex = logic_profile:GetRoleSexByUid(DataMgr.roleData.uid, true)
  local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
  local XMissionSystem = require("client.slua.logic.TxMission.logic_xmission_main")
  local isInXMission = XMissionSystem.IsInXMission()
  local bCanPlay = true
  if isInXMission then
    local XMissionAvatarMgr = require("client.slua.logic.TxMission.logic_xmission_avatar_mgr")
    bCanPlay = XMissionAvatarMgr.PlayAction(DataMgr.roleData.uid, config.ActionID)
  else
    bCanPlay = LobbyAvatarManager.PlayEmoteAction(DataMgr.roleData.uid, config.ActionID, sex, 0)
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if TeamUpNewSystem.GetTeamNum() > 1 and bCanPlay then
    TeamUpNewSystem.team_player_action(config.ActionID, 0)
  end
  self.bTransform = true
  self:SetWidgetVisible(self.UIRoot.Button_Transfiguration, true, false)
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_LookbackGuide, false, false)
  DragonChangeForm:UpdateGuideState(2)
end
function ExpressionPop_New_UIBP:OnButton_StandbyActionClick()
  self:PlayAudio(sound_config.click_v1)
  if not self.HasStanbyAction then
    if self.ErrorTipID ~= 0 then
      ShowNotice(self.ErrorTipID)
    end
    return
  end
  local XMissionSystem = require("client.slua.logic.TxMission.logic_xmission_main")
  local XMissionAvatarMgr = require("client.slua.logic.TxMission.logic_xmission_avatar_mgr")
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local isInXMission = XMissionSystem.IsInXMission()
  local showingAvatar
  if isInXMission then
    showingAvatar = XMissionAvatarMgr.GetMainAvatar()
  else
    showingAvatar = TeamAvatarManager.GetMainAvatar()
  end
  local pet = showingAvatar and showingAvatar:GetPet()
  if pet ~= nil and pet:IsPlayingAction() then
    pet:StopAction()
  end
  local standbyActionID = 12219414
  local bCanPlay = true
  if isInXMission then
    bCanPlay = XMissionAvatarMgr.PlayAction(DataMgr.roleData.uid, standbyActionID)
  else
    local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
    bCanPlay = LobbyAvatarManager.PlayEmoteAction(DataMgr.roleData.uid, standbyActionID)
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if TeamUpNewSystem.GetTeamNum() > 1 and bCanPlay then
    TeamUpNewSystem.team_player_action(standbyActionID)
    if TeamUpNewSystem.IsTeamLeader() and TeamUpNewSystem.CheckEmoteCanFollow(standbyActionID) then
      local FollowerUIDS = TeamUpNewSystem.GetEmoteFollowersUID()
      local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
      for _, uid in pairs(FollowerUIDS) do
        if not isInXMission then
          local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
          local standbyActionID = TeamUpNewSystem.GetFollowPlayEmoteID(uid, standbyActionID)
          LobbyAvatarManager.PlayEmoteAction(uid, standbyActionID, logic_profile:GetRoleSexByUid(uid, true), nil)
        end
      end
    end
  end
end
function ExpressionPop_New_UIBP:OnButton_CloseClick()
  self:PlayAudio(sound_config.click)
  self:CloseSelf()
end
function ExpressionPop_New_UIBP:OnCheckBoxChanged(check)
  self:PlayAudio(sound_config.toggle_v1)
  if check ~= DataMgr.is_follow_leader then
    self.FollowLeaderCheckBox:SetIsChecked(DataMgr.is_follow_leader or false)
    if self:AllowCheckBoxChanged() then
      local TeamupHandler = require("client.network.Protocol.TeamupHandler")
      TeamupHandler.send_follow_leader_motion_setting_req(check)
    end
  end
end
function ExpressionPop_New_UIBP:AllowCheckBoxChanged()
  local UIUtil = require("client.common.ui_util")
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.ExpressionPopUIBP) then
    return false
  end
  return true
end
function ExpressionPop_New_UIBP:OnClickPetButtonByItemId(itemId)
  local count = self.LoopScrollGrid_Flaunt:GetItemCount()
  for i = 1, count do
    local itemData = self.LoopScrollGrid_Flaunt:GetItemData(i)
    if itemData.itemId == itemId then
      local widget = self.LoopScrollGrid_Flaunt:GetIndexOfWidget(i)
      if widget then
        widget:OnClickedFlauntItem()
        break
      end
    end
  end
end
function ExpressionPop_New_UIBP:OnClickedPetItem(widget, index)
  local itemData = self.LoopScrollGrid_Pet:GetItemData(index)
  if not itemData then
    return
  end
  self.nCurPetActionID = itemData.PetActionID
  self.LoopScrollGrid_Pet:RefreshAllItems()
  local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
  if logic_pet:IsActionUnLock(self.nCurPetInsID, self.nCurPetActionID) == true then
    logic_pet:pet_action_req(itemData.PetActionID)
  else
    ShowNotice(530002)
  end
  self:PlayAudio(sound_config.click_v1)
  ClientSendBAReport(TLogEventDefine.PetPlayAction, 0)
end
function ExpressionPop_New_UIBP:OnLobbyHide()
  log(bWriteLog and "ExpressionPopUIBP:OnLobbyHide")
  self:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function ExpressionPop_New_UIBP:OnLobbyShow()
  self:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
end
function ExpressionPop_New_UIBP:UpdateFollowCheckBox()
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if LobbySystem.CheckOpen(BP_ENUM_DANCE_FOLLOW_SWITCH) then
    self.FollowLeaderCheckBox:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  else
    self.FollowLeaderCheckBox:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if self.FollowLeaderCheckBox:IsChecked() ~= DataMgr.is_follow_leader then
    self.FollowLeaderCheckBox:SetIsChecked(DataMgr.is_follow_leader or false)
  end
end
function ExpressionPop_New_UIBP:OnActionEquipStateChange()
  self:UpdateActionUI()
end
function ExpressionPop_New_UIBP:OnFollowLeaderEmoteUpdate()
  self:UpdateFollowCheckBox()
end
function ExpressionPop_New_UIBP:OnCheckBoxShowEffectChanged(Check)
  self:PlayAudio(sound_config.toggle_v1)
  if Check ~= DataMgr.show_effect then
    self.UIRoot.CheckBox_ShowEffect:SetIsChecked(DataMgr.show_effect or false)
    if self:AllowCheckBoxChanged() then
      local LogicParticleEmote = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicParticleEmote)
      LogicParticleEmote:send_effect_motion_setting_req(Check)
    end
  end
end
function ExpressionPop_New_UIBP:UpdateShowEffectCheckBox()
  local expression_util = require("client.slua.umg.Souvenirs.Expression_Util")
  self.expressList = expression_util.GetMotionDataList()
  local HaveEquipParticleEmote = false
  local LogicParticleEmote = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicParticleEmote)
  for key, value in pairs(self.expressList) do
    if LogicParticleEmote:IsParticleEmote(value.itemId) and LogicParticleEmote:HasUnlockParticle(value.itemId) then
      HaveEquipParticleEmote = true
      break
    end
  end
  if not HaveEquipParticleEmote then
    self.UIRoot.CheckBox_ShowEffect:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  self.UIRoot.CheckBox_ShowEffect:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  if self.UIRoot.CheckBox_ShowEffect:IsChecked() ~= DataMgr.show_effect then
    self.UIRoot.CheckBox_ShowEffect:SetIsChecked(DataMgr.show_effect)
  end
end
function ExpressionPop_New_UIBP:OnShowEffectUpdate()
  self:UpdateShowEffectCheckBox()
  self.LoopScrollGrid_Action:RefreshAllItems()
end
function ExpressionPop_New_UIBP:OnEndActionHandle()
  self:RefreshChangeFormButton()
end
function ExpressionPop_New_UIBP:OnRefreshImageLock()
  log(bWriteLog and "ExpressionPop_New_UIBP:OnRefreshImageLock")
  self.UIRoot.WidgetSwitcher_Transfiguration:SetActiveWidgetIndex(1)
end
function ExpressionPop_New_UIBP:OnPlayTransformAnim()
  log(bWriteLog and "ExpressionPop_New_UIBP:OnPlayTransformAnim")
  self:PlayChangeFromAnim()
end
function ExpressionPop_New_UIBP:OnMileListDataChange()
  self:UpdateFlauntUI()
end
function ExpressionPop_New_UIBP:RefreshAllUI()
  self:UpdateActionUI()
  self:UpdatePetUI()
  self:UpdateSouvenirsUI()
  self:SetWidgetVisible(self.UIRoot.Button_StandbyAction, false, true)
  self:UpdateFlauntUI()
end
function ExpressionPop_New_UIBP:UpdateActionUI()
  local expression_util = require("client.slua.umg.Souvenirs.Expression_Util")
  self.expressList = expression_util.GetMotionDataList()
  self.LoopScrollGrid_Action:SetData(self.expressList)
  self:RefreshChangeFormButton()
  self:RefreshCartoonStyleButton()
  self:ShowChangeFormGuide()
  self:UpdateFollowCheckBox()
  self:UpdateShowEffectCheckBox()
  local XMissionSystem = require("client.slua.logic.TxMission.logic_xmission_main")
  if XMissionSystem.IsInXMission() then
    self.UIRoot.Button_EXclose:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    self.UIRoot.Button_EXclose:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  end
  self.UIRoot.TextBlock_StandbyAction:SetText(LocUtil.LocalizeResFormat(43770))
  local XMissionAvatarMgr = require("client.slua.logic.TxMission.logic_xmission_avatar_mgr")
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local isInXMission = XMissionSystem.IsInXMission()
  local showingAvatar
  if isInXMission then
    showingAvatar = XMissionAvatarMgr.GetMainAvatar()
  else
    showingAvatar = TeamAvatarManager.GetMainAvatar()
  end
  self.HasStanbyAction = false
  self.ErrorTipID = 0
  if showingAvatar then
    local HasStanby, StanbyID, ErrorTipID = showingAvatar:HasWeaponStandbyAction()
    if HasStanby then
      self.UIRoot.TextBlock_StandbyAction:SetColorAndOpacity(FSlateColor(FLinearColor(1, 1, 1, 1)))
      self.UIRoot.Image_StanbyIcon:SetColorAndOpacity(FLinearColor(1, 1, 1, 1))
      self.HasStanbyAction = true
    else
      self.UIRoot.TextBlock_StandbyAction:SetColorAndOpacity(FSlateColor(FLinearColor(1, 1, 1, 0.5)))
      self.UIRoot.Image_StanbyIcon:SetColorAndOpacity(FLinearColor(1, 1, 1, 0.5))
      self.    end
  end
end
function ExpressionPop_New_UIBP:UpdatePetUI()
  local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
  if logic_pet.MyPetInfo == nil or logic_pet.MyPetInfo.equip_pet_ins_id == nil or logic_pet.MyPetInfo.equip_pet_ins_id == 0 then
    log(bWriteLog and "ExpressionPop_New_UIBP:UpdatePetUI logic_pet.MyPetInfo == nil")
    return
  else
    self.nCurPetInsID = logic_pet.MyPetInfo.equip_pet_ins_id
    self.nCurPetID = logic_pet:ConvertToPetID(self.nCurPetInsID)
    local expression_util = require("client.slua.umg.Souvenirs.Expression_Util")
    local petDatas = expression_util.GetPetActionList()
    self.LoopScrollGrid_Pet:SetData(petDatas)
  end
end
function ExpressionPop_New_UIBP:UpdateSouvenirsUI()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local BlueHole = Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE
  if BlueHole then
    self:SetWidgetVisible(self.UIRoot.VerticalBox_Souvenirs, false)
    return
  end
  local expression_util = require("client.slua.umg.Souvenirs.Expression_Util")
  local souvenirsExpress = expression_util.GetSouvenirsData()
  self.LoopScrollGrid_Souvenirs:SetData(souvenirsExpress)
end
function ExpressionPop_New_UIBP:UpdateFlauntUI()
  local Expression_Util = require("client.slua.umg.Souvenirs.Expression_Util")
  local FlauntData = Expression_Util.GetFlauntData()
  self.LoopScrollGrid_Flaunt:SetData(FlauntData)
end
function ExpressionPop_New_UIBP:RefreshChangeFormButton()
  log(bWriteLog and "ExpressionPop_New_UIBP:RefreshChangeFormButton")
  local DragonChangeForm = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.DragonChangeForm)
  local config, source = DragonChangeForm:GetSelfConfigByCurWear()
  local bShow = config ~= nil
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_Button, bShow, false)
  self.UIRoot.TextBlock_Transform1:SetText(LocUtil.GetLocalizeResStr(20230622))
  self.UIRoot.TextBlock_Transform2:SetText(LocUtil.GetLocalizeResStr(20230622))
  self:SetWidgetVisible(self.UIRoot.Button_Transfiguration, bShow, true)
  if bShow and config.IconPath then
    self:SetTexture(self.UIRoot.Image_188, config.IconPath)
  end
  if GlobalData.IsJapanOrKorea() and source ~= EWardrobeDataSource.InheritWardrobe then
    local bGet = DataMgr.roleData.dragon_ball_unlock_state
    if bGet then
      self.UIRoot.WidgetSwitcher_Transfiguration:SetActiveWidgetIndex(1)
    else
      self.UIRoot.WidgetSwitcher_Transfiguration:SetActiveWidgetIndex(0)
    end
  else
    self.UIRoot.WidgetSwitcher_Transfiguration:SetActiveWidgetIndex(1)
  end
  self.bTransform = false
end
function ExpressionPop_New_UIBP:RefreshCartoonStyleButton()
  local bShow = false
  local logic_wardrobe_avatar = require("client.slua.logic.wardrobe.logic_wardrobe_avatar")
  logic_wardrobe_avatar:InitCurrentWearPreviewMap()
  local wearInfo = logic_wardrobe_avatar:GetCurrentWearPreview(BP_ENUM_AVATAR_CLOTH)
  if wearInfo then
    local myAvatar
    local XMissionSystem = require("client.slua.logic.TxMission.logic_xmission_main")
    local isInXMission = XMissionSystem.IsInXMission()
    if isInXMission then
      local XMissionAvatarMgr = require("client.slua.logic.TxMission.logic_xmission_avatar_mgr")
      myAvatar = XMissionAvatarMgr.GetMainAvatar()
    else
      local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
      myAvatar = TeamAvatarManager.GetMainAvatar()
    end
    if myAvatar == nil then
      log(bWriteLog and "ExpressionPop_New_UIBP:RefreshCartoonStyleButton main avatar is nil")
    elseif not myAvatar:HasEquiped(wearInfo.resID) then
      log(bWriteLog and "ExpressionPop_New_UIBP:RefreshCartoonStyleButton not equip")
    else
      local LogicMultiItemModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicMultiItemModule)
      bShow = LogicMultiItemModule:GetCartoonStyleCfg(wearInfo.resID) ~= nil
    end
  end
  self.UIRoot.TextBlock_3:SetText(LocUtil.GetLocalizeResStr(81120))
  self.UIRoot.TextBlock_6:SetText(LocUtil.GetLocalizeResStr(81120))
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_8, bShow, false)
  self:SetWidgetVisible(self.UIRoot.Button_0, bShow, true)
  self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(1)
end
function ExpressionPop_New_UIBP:ShowChangeFormGuide()
  local DragonChangeForm = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.DragonChangeForm)
  local bShow = DragonChangeForm:GetGuideState()
  log(bWriteLog and "lobby_bottom_right_uibp:ShowChangeFormGuide bShow = " .. tostring(bShow))
  if GlobalData.IsJapanOrKorea() then
    self.UIRoot.TextBlock_LookbackTips:SetText(LocUtil.GetLocalizeResStr(150074))
  else
    self.UIRoot.TextBlock_LookbackTips:SetText(LocUtil.GetLocalizeResStr(49721))
  end
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_LookbackGuide, bShow, false)
end
function ExpressionPop_New_UIBP:OnRefreshPetListItem(widget, index)
  local itemData = self.LoopScrollGrid_Pet:GetItemData(index)
  local strLevel = LocUtil.LocalizeResFormat("6417", itemData.NeedLevel)
  widget.Text_NeedLevel:SetText(strLevel)
  local UIUtil = require("client.common.ui_util")
  local iconPath, bHasAddKnownMissing = UIUtil.GetItemSmallIcon(itemData.PetActionID, widget.Image_Icon)
  self:SetTexture(widget.ImgActionIcon, iconPath, {bHasAddKnownMissing = bHasAddKnownMissing})
  local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
  if logic_pet:IsActionUnLock(self.nCurPetInsID, itemData.PetActionID) then
    widget.CP_PetActionLock:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    local white = FSlateColor(FLinearColor(0.2, 0.2, 0.2, 1))
    widget.Text_NeedLevel:SetColorAndOpacity(white)
    widget.ImgActionIcon:SetColorAndOpacity(FLinearColor(1, 1, 1, 1))
  else
    widget.CP_PetActionLock:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    local red = FSlateColor(FLinearColor(1, 0, 0, 1))
    widget.Text_NeedLevel:SetColorAndOpacity(red)
    widget.ImgActionIcon:SetColorAndOpacity(FLinearColor(1, 1, 1, 0.3))
  end
  widget.ImgSelected:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local common_download_handler = require("client.slua.common.common_download_handler")
  common_download_handler.CreateDownloadUI(PufferConst.ENUM_DownloadType.ODPAK, {
    self.nCurPetID
  }, widget.Panel_Download)
end
function ExpressionPop_New_UIBP:OnRefreshSouvenirsList(widget, index)
  local data = self.LoopScrollGrid_Souvenirs:GetItemData(index)
  if not data.emotionId then
    return
  end
  self:SetWidgetVisible(widget.Text_NeedLevel, false)
  self:SetWidgetVisible(widget.ImgSelected, false)
  local UIUtil = require("client.common.ui_util")
  local iconPath, bHasAddKnownMissing = UIUtil.GetItemSmallIcon(data.emotionId, widget.ImgActionIcon)
  self:SetTexture(widget.ImgActionIcon, iconPath, {bHasAddKnownMissing = bHasAddKnownMissing})
  self:SetWidgetVisible(widget.CP_PetActionLock, false)
  local white = FSlateColor(FLinearColor(0.2, 0.2, 0.2, 1))
  widget.ImgActionIcon:SetColorAndOpacity(FLinearColor(1, 1, 1, 1))
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local common_download_handler = require("client.slua.common.common_download_handler")
  common_download_handler.CreateDownloadUI(PufferConst.ENUM_DownloadType.ODPAK, {
    data.emotionId
  }, widget.Panel_Download)
end
function ExpressionPop_New_UIBP:ClearReddot()
  log(bWriteLog and "ExpressionPop_New_UIBP:ClearReddot")
  local logic_lobby_souvenirs = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_lobby_souvenirs)
  if logic_lobby_souvenirs:GetExpressionReddotShow() then
    logic_lobby_souvenirs:SetExpressionReddot(false)
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CExpressionPop_New_UIBP = class(ui_base, nil, ExpressionPop_New_UIBP)
return CExpressionPop_New_UIBP