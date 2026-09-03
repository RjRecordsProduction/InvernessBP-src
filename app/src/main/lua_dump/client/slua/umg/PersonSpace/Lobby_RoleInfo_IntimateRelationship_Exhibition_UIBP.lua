local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
local Lobby_RoleInfo_IntimateRelationship_Exhibition_UIBP = {}
function Lobby_RoleInfo_IntimateRelationship_Exhibition_UIBP:ctor(_)
  self.system = require("client.logic.personspace.logic_person_space_relationship")
  self.currUID = tonumber(RoleInfoSystem.CurShowPlayerInfoUid)
  self.avatarInfos = nil
  self.tAvatarShowCfg = nil
  self.loopDataEffectList = {}
end
function Lobby_RoleInfo_IntimateRelationship_Exhibition_UIBP:OnInitialize()
  self.LoopScrollGrid = self:InitChildClassScrollBox(self.UIRoot.LoopScrollGrid)
  self.LoopScrollBox_2 = self:InitChildClassScrollBox(self.UIRoot.LoopScrollBox_2)
end
function Lobby_RoleInfo_IntimateRelationship_Exhibition_UIBP:RegistEvents()
  self:AddOnClickedEventByControl(self.UIRoot.Button_1, self.OnClickButton_1, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_0, self.OnClickButton_0, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_2, self.OnClickButton_OK, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Photo, self.OnButton_PhotoClick, self)
  self.LoopScrollGrid:SetRefreshItemCallback(self.OnRefreshLoopScrollGridItem, self)
  self.LoopScrollBox_2:SetRefreshItemCallback(self.OnRefreshHasBuildItem, self)
  self.LoopScrollBox_2:AddItemWidgetChildEvent("CheckBox_0", "OnCheckStateChanged", self.CheckBox_0, self)
  self.LoopScrollGrid:AddItemWidgetChildEvent("Button_Item", "OnClicked", self.OnClickedButtonSelect, self)
  self:AddCommonEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PARTNER_INTIMACY_AVATAR_RSP, self.RefreshDataAndAvate, self)
  self:AddCommonEvent(EVENTTYPE_PERSON_SPACE, EVENTID_SOULMATE_CERTIFICATION_SET_SHOW_RSP, self.OnSoulmateCertificationSetShowRsp, self)
  self:AddCommonEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_INTIMACY_DATA_UPDATE, self.UpdatePartner, self)
  self:AddCommonEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_OTHER_INTIMACY_DATA_UPDATE, self.UpdatePartner, self)
  self:AddCommonEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PARTNER_ALLFRD_INTIMACY, self.RefreshDataAndAvate, self)
  self:AddCommonEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PARTNER_FRD_INTIMACY, self.ShowLobby_Crystal_Tips_UIBP, self)
end
function Lobby_RoleInfo_IntimateRelationship_Exhibition_UIBP:OnPostInitialize()
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_2, false, false)
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_37, false, false)
  if self.system.IsMySelf(self.currUID) then
    self:SetWidgetVisible(self.UIRoot.Button_1, true, true)
    self:SetWidgetVisible(self.UIRoot.Button_0, true, true)
    local logic_person_relation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_person_relation)
    logic_person_relation:send_get_interact_avatar_req()
  else
    self:SetWidgetVisible(self.UIRoot.Button_1, false, false)
    self:SetWidgetVisible(self.UIRoot.Button_0, false, false)
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local profile = logic_profile:GetLocalProfile(self.currUID)
    local target_uid_list = {}
    local listNum = 0
    if profile.interact_avatar_data then
      for i = 1, 6 do
        if profile.interact_avatar_data[i] and profile.interact_avatar_data[i] ~= self.currUID then
          table.insert(target_uid_list, profile.interact_avatar_data[i])
        end
      end
    end
    if not next(target_uid_list) then
      self:RefreshDataAndAvate()
    else
      local logic_person_relation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_person_relation)
      logic_person_relation:send_batch_get_frd_interact_info_req(self.currUID, target_uid_list)
    end
  end
  local IntimacyAwardSystem = require("client.slua.logic.person_space.logic_intimacy_award")
  IntimacyAwardSystem.get_posture_info_req()
  self:UpdateUI()
end
function Lobby_RoleInfo_IntimateRelationship_Exhibition_UIBP:OnClose()
  local logic_person_relation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_person_relation)
  logic_person_relation:DestroyScene()
  logic_person_relation:DestroyPlayerAvatar()
end
function Lobby_RoleInfo_IntimateRelationship_Exhibition_UIBP:OnClickButton_0()
  self:PlayAudio(sound_config.click_v1)
  UIManager.ShowUI(UIManager.UI_Config.Lobby_RoleInfo_Relationship_UIBP, false, nil)
end
function Lobby_RoleInfo_IntimateRelationship_Exhibition_UIBP:OnClickButton_1()
  self:PlayAudio(sound_config.click_v1)
  UIManager.ShowUI(UIManager.UI_Config.Lobby_RoleInfo_IntimateRelationship_Exhibition_02_UIBP)
end
function Lobby_RoleInfo_IntimateRelationship_Exhibition_UIBP:OnClickButton_OK()
  self:PlayAudio(sound_config.click_v1)
  local logic_person_relation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_person_relation)
  logic_person_relation:SendPos()
end
function Lobby_RoleInfo_IntimateRelationship_Exhibition_UIBP:CheckBox_0(widget, index, bIsChecked)
  self:PlayAudio(sound_config.click)
  local logic_person_relation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_person_relation)
  local ChangeNum = logic_person_relation:GetNowPosChange()
  if ChangeNum >= logic_person_relation.MaxPosChange and bIsChecked then
    ShowNotice(689308)
    self.LoopScrollBox_2:RefreshAllItems()
    return
  end
  local data = self.LoopScrollBox_2:GetItemData(index)
  if logic_person_relation:FindRelaIndex(data.uid) then
    logic_person_relation:RemoveRelaIndexOfID(data.uid)
    self.UIRoot.TextBlock_3:SetText(LocUtil.LocalizeResFormat(77162, tostring(ChangeNum - 1), tostring(logic_person_relation.MaxPosChange)))
  else
    logic_person_relation:AddRela(data.uid)
    self.UIRoot.TextBlock_3:SetText(LocUtil.LocalizeResFormat(77162, tostring(ChangeNum + 1), tostring(logic_person_relation.MaxPosChange)))
  end
  self.LoopScrollBox_2:RefreshAllItems()
end
function Lobby_RoleInfo_IntimateRelationship_Exhibition_UIBP:OnClickedButtonSelect(widget, index)
  self:PlayAudio(sound_config.click_v1)
  local data = self.LoopScrollGrid:GetItemData(index)
  self.ShowTipsData = data
  self.ShowTipsWidget = widget
  if self.system.IsMySelf(self.currUID) then
    self:ShowLobby_Crystal_Tips_UIBP()
    if data.crystalType == 2 then
      local id = data.cfg.ID
      DataMgr.SetNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_INTIMACY_RELATION, id)
      self.LoopScrollGrid:RefreshItem(index)
    end
  else
    local logic_person_relation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_person_relation)
    logic_person_relation:send_get_frd_interact_info_req(tonumber(self.currUID), tonumber(self.ShowTipsData.frd_uid))
  end
end
function Lobby_RoleInfo_IntimateRelationship_Exhibition_UIBP:ShowLobby_Crystal_Tips_UIBP()
  log(bWriteLog and "Lobby_RoleInfo_IntimateRelationship_Exhibition_UIBP:ShowLobby_Crystal_Tips_UIBP")
  if self.ShowTipsData then
    local IntimacyUtils = require("client.slua.logic.friend.Intimacy.IntimacyUtils")
    IntimacyUtils.ShowCrystalTips(self.ShowTipsData, {
      widget = self.ShowTipsWidget.Button_Item,
      offsetX = 0,
      offsetY = -150,
      data = self.ShowTipsData,
      uid = self.currUID
    })
  end
end
function Lobby_RoleInfo_IntimateRelationship_Exhibition_UIBP:GetDataForJumpBack()
  return {
    ctorData = {
      [1] = 27
    }
  }
end
function Lobby_RoleInfo_IntimateRelationship_Exhibition_UIBP:UpdateUI()
  self.UIRoot.TextBlock_8:SetText(LocUtil.GetLocalizeResStr(73615))
  self.UIRoot.TextBlock_2:SetText(LocUtil.GetLocalizeResStr(73296))
  self.UIRoot.TextBlock_15:SetText(LocUtil.GetLocalizeResStr(73626))
end
function Lobby_RoleInfo_IntimateRelationship_Exhibition_UIBP:OnSoulmateCertificationSetShowRsp()
  log(bWriteLog and "Lobby_RoleInfo_IntimateRelationship_Exhibition_UIBP:OnSoulmateCertificationSetShowRsp")
  self:RefreshDataAndAvate()
end
function Lobby_RoleInfo_IntimateRelationship_Exhibition_UIBP:RefreshDataAndAvate()
  log(bWriteLog and "Lobby_RoleInfo_IntimateRelationship_Exhibition_UIBP:RefreshDataAndAvate()")
  local logic_person_relation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_person_relation)
  local PartnerData, PostId, LoopList
  if self.system.IsMySelf(self.currUID) then
    self:SetWidgetVisible(self.UIRoot.ScaleBox_3, true, true)
    self:SetWidgetVisible(self.UIRoot.ScaleBox_5, false, false)
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local myProfile = logic_profile:GetLocalProfile(self.currUID)
    local PostListNil = true
    LoopList = logic_person_relation:GetSet_rela_frd_list()
    local data = logic_person_relation:GetRelation_crystal_info()
    PartnerData = logic_person_relation:GetFriShowCrystal(data, myProfile)
    if not LoopList or not next(LoopList) then
      PostListNil = true
    else
      local logic_person_relation_tool = require("client.logic.personspace.logic_person_relation_tool")
      PostListNil = logic_person_relation_tool.CheckPoseFriendList()
    end
    self.    if PostListNil then
      self:SetWidgetVisible(self.UIRoot.CanvasPanel_37, false, false)
      self:SetWidgetVisible(self.UIRoot.CanvasPanel_2, true, true)
      self:AddFriendsPost()
      self.UIRoot.Button_Photo:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    else
      self.UIRoot.Button_Photo:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
      self:SetWidgetVisible(self.UIRoot.CanvasPanel_37, true, true)
      self:SetWidgetVisible(self.UIRoot.CanvasPanel_2, false, false)
      local logic_interaction = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_interaction)
      for k, uid in pairs(LoopList) do
        logic_interaction:send_get_interact_info_req(uid)
      end
      local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
      PersonSpaceSystem.get_other_intimacy_relation_req(self.currUID)
      local dataList = {}
      if not PartnerData or not next(PartnerData) then
        self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(1)
      else
        self.LoopScrollGrid:SetData(PartnerData)
        self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(0)
      end
    end
    PostId = logic_person_relation:Getetpos_mod_id()
  else
    self.UIRoot.Button_Photo:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local profile = logic_profile:GetLocalProfile(self.currUID)
    PostId = profile.cur_interact_avatar_posture or logic_person_relation.DefaultPosID
    LoopList = {}
    local listNum = 0
    if profile.interact_avatar_data then
      for i = 1, 6 do
        if not profile.interact_avatar_data[i] then
          LoopList[i] = 0
        else
          LoopList[i] = profile.interact_avatar_data[i]
          listNum = listNum + 1
        end
      end
      if listNum < 2 then
        LoopList = {}
      end
      local relation_crystal_info = {}
      if profile.interact_rela_crystal_data and next(profile.interact_rela_crystal_data) then
        for crystalk, crystalv in pairs(profile.interact_rela_crystal_data) do
          for relak, relav in pairs(LoopList) do
            if crystalv.frd_uid == relav then
              table.insert(relation_crystal_info, crystalv)
            end
          end
        end
      end
      PartnerData = logic_person_relation:GetFriShowCrystal(relation_crystal_info, profile)
      self.      self:SetWidgetVisible(self.UIRoot.ScaleBox_3, true, true)
      self:SetWidgetVisible(self.UIRoot.ScaleBox_5, false, false)
      self:SetWidgetVisible(self.UIRoot.CanvasPanel_37, true, true)
      self:SetWidgetVisible(self.UIRoot.CanvasPanel_2, false, false)
      self:SetWidgetVisible(self.UIRoot.CanvasPanel_8, false, false)
      self:SetWidgetVisible(self.UIRoot.WidgetSwitcher_0, true, true)
      if not PartnerData or not next(PartnerData) then
        self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(1)
      else
        self.LoopScrollGrid:SetData(PartnerData)
        self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(0)
      end
      local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
      PersonSpaceSystem.get_other_intimacy_relation_req(tonumber(self.currUID))
    else
      self:SetWidgetVisible(self.UIRoot.ScaleBox_3, false, false)
      self:SetWidgetVisible(self.UIRoot.ScaleBox_5, true, true)
      self:SetWidgetVisible(self.UIRoot.CanvasPanel_37, false, false)
      self:SetWidgetVisible(self.UIRoot.CanvasPanel_2, true, true)
      self:SetWidgetVisible(self.UIRoot.CanvasPanel_8, false, false)
    end
  end
  logic_person_relation:LoadScene(PostId)
end
function Lobby_RoleInfo_IntimateRelationship_Exhibition_UIBP:AddFriendsPost()
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  self.intimacyList = LogicFriend.GetIntimacyHasBuildList()
  local logic_person_relation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_person_relation)
  logic_person_relation:DestroyPlayerAvatar()
  if self.multiplayer_avatar_ui then
    self.multiplayer_avatar_ui:CloseSelf()
  end
  if not self.intimacyList or not next(self.intimacyList) then
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_8, false, false)
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_0, false, false)
    self:SetWidgetVisible(self.UIRoot.Button_2, false, false)
  else
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_8, false, false)
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_0, true, true)
    self:SetWidgetVisible(self.UIRoot.Button_2, true, true)
    self.LoopScrollBox_2:SetData(self.intimacyList)
    local ChangeNum = logic_person_relation:GetNowPosChange()
    self.UIRoot.TextBlock_3:SetText(LocUtil.LocalizeResFormat(77162, tostring(ChangeNum), tostring(logic_person_relation.MaxPosChange)))
  end
end
function Lobby_RoleInfo_IntimateRelationship_Exhibition_UIBP:OnRefreshHasBuildItem(widget, index)
  local data = self.LoopScrollBox_2:GetItemData(index)
  local logic_person_relation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_person_relation)
  local friList = logic_person_relation:GetSet_rela_frd_list()
  for k, v in pairs(friList) do
    if v == data.uid then
      widget.CheckBox_0:SetCheckedState(1)
      break
    else
      widget.CheckBox_0:SetCheckedState(0)
    end
  end
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(data.uid)
  if profile then
    widget.Common_Avatar_BP:InitView(1, data.uid, profile.picUrl, 0, profile.cur_avatar_box_id, profile.level, false, "")
    local solo, duo, squad = FuncUtil.GetMaxSegement(profile.segment_info)
    local maxRank = math.max(solo, duo, squad)
    widget.Common_RankIntegralLevel_Style_Small_UIBP_C_0:SetRankInteral(maxRank, nil)
    local UIUtil = require("client.common.ui_util")
    widget.TextBlock_Name:SetText(profile.nickName)
    UIUtil.UpdateNationImageByLua(widget.Image_Flag_Other, profile.nation)
    if widget.Common_Gender_UIBP and profile.social_card then
      widget.Common_Gender_UIBP:LoadIcon(profile.uid)
    end
    local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
    local intimacy = tonumber(LogicFriend.GetInnerFriendIntimacy(data.uid))
    widget.Text_Intimacy:SetText(tostring(intimacy))
    local IntimacyAwardSystem = require("client.slua.logic.person_space.logic_intimacy_award")
    local intimacyLvCfg = IntimacyAwardSystem.GetInitimacyLvCfg(intimacy)
    if intimacyLvCfg then
      widget.Lobby_RoleInfo_IntimacyItem_UIBP.TextBlock_Lv:SetText(intimacyLvCfg.Level)
      self:SetTexture(widget.Lobby_RoleInfo_IntimacyItem_UIBP.Image_Icon, IntimacyAwardSystem.GetInitimacyIcon_other(data.param))
    end
  end
end
function Lobby_RoleInfo_IntimateRelationship_Exhibition_UIBP:UpdatePartner()
  local logic_person_relation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_person_relation)
  local AvatarList
  local PostId = 0
  if self.system.IsMySelf(self.currUID) then
    PostId = logic_person_relation:Getetpos_mod_id()
    AvatarList = logic_person_relation:GetInteractionWithSet_rela_frd_list(self.LoopList, true)
  else
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local profile = logic_profile:GetLocalProfile(self.currUID)
    PostId = profile.cur_interact_avatar_posture or logic_person_relation.DefaultPosID
    AvatarList = logic_person_relation:GetInteractionWithSet_rela_frd_list(self.LoopList, false)
  end
  if not AvatarList or not next(AvatarList) then
    logic_person_relation:DestroyPlayerAvatar()
  else
    self.avatarInfos, self.tAvatarShowCfg = logic_person_relation:LoadPlayerAvatarAvatar(AvatarList, PostId)
  end
  if not self.avatarInfos then
    return
  end
  local ui_util = require("client.common.ui_util")
  if self.multiplayer_avatar_ui then
    self.multiplayer_avatar_ui:CloseSelf()
  end
  self.multiplayer_avatar_ui = self:CreateChildWindow(self.UIRoot.CanvasPanel_7, UIManager.UI_Config.MultiplayerAvatar_UIBP)
  self.multiplayer_avatar_ui:InitUI(self.avatarInfos, self.tAvatarShowCfg, self.currUID)
  self.multiplayer_avatar_ui:ShowIndex(false)
end
function Lobby_RoleInfo_IntimateRelationship_Exhibition_UIBP:OnRefreshLoopScrollGridItem(widget, index)
  local data = self.LoopScrollGrid:GetItemData(index)
  if data then
    local cfg = data.cfg
    if cfg and cfg.EffectPath and cfg.EffectPath ~= "" then
      if self.loopDataEffectList[index] then
        self.loopDataEffectList[index]:CloseSelf()
      end
      self:SetWidgetVisible(widget.Image_Icon, false, false)
      self:SetWidgetVisible(widget.CanvasPanel_Small, true, false)
      local effectUi = self:CreateChildWindowWithBpPath(widget.CanvasPanel_Small, nil, cfg.EffectPath)
      self:PlayUserWidgetAnimation(effectUi.loop, 0, 0, 0, 1)
      self.loopDataEffectList[index] = effectUi
    else
      self:SetWidgetVisible(widget.Image_Icon, true)
      self:SetWidgetVisible(widget.CanvasPanel_Small, false, false)
      self:SetTexture(widget.Image_Icon, cfg.CrystalPath)
    end
    self:SetTexture(widget.Image_quality, cfg.QualityPath)
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local myProfile = logic_profile:GetLocalProfile(self.currUID)
    if myProfile then
      self:SetWidgetVisible(widget.Common_Avatar_BP_C_0, true, true)
      widget.Common_Avatar_BP_C_0:InitView(1, self.currUID, myProfile.picUrl, 0, myProfile.cur_avatar_box_id, myProfile.level, false, "")
      widget.Common_Avatar_BP_C_0:SetButtonEnabled(false)
    else
      self:SetWidgetVisible(widget.Common_Avatar_BP_C_0, false, false)
    end
    local friProfile = logic_profile:GetLocalProfile(data.frd_uid)
    if friProfile then
      self:SetWidgetVisible(widget.Common_Avatar_BP_C_1, true, true)
      widget.Common_Avatar_BP_C_1:InitView(1, data.frd_uid, friProfile.picUrl, 0, friProfile.cur_avatar_box_id, friProfile.level, false, "")
      widget.Common_Avatar_BP_C_1:SetButtonEnabled(false)
    else
      self:SetWidgetVisible(widget.Common_Avatar_BP_C_1, false, false)
    end
    local bShowReddot = false
    if data.crystalType == 2 then
      local id = data.cfg.ID
      local bNewbieGuide = DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_INTIMACY_RELATION, id)
      if bNewbieGuide then
        bShowReddot = true
      end
    end
    self:SetWidgetVisible(widget.Reddot_Anchor_Item01, bShowReddot)
  end
end
function Lobby_RoleInfo_IntimateRelationship_Exhibition_UIBP:OnButton_PhotoClick()
  self:PlayAudio(sound_config.click_v1)
  local logic_person_relation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_person_relation)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.Lobby_Intimacy_Click_Photo_Share)
  local SlateBlueprintLibrary = import("SlateBlueprintLibrary")
  local Geometry = self.UIRoot:GetCachedGeometry()
  local LocalSize = SlateBlueprintLibrary.GetLocalSize(Geometry)
  logic_person_relation:SharePhoto(LocalSize)
  local ShareMgr = require("client.logic.share.share_logic")
  ShareMgr.ShareBtnReq(1, ShareBtnTLogShareTypeDefine.RoleInfo_Intimacy_Relationship_Share, nil, nil)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CLobby_RoleInfo_IntimateRelationship_Exhibition_UIBP = class(ui_base, nil, Lobby_RoleInfo_IntimateRelationship_Exhibition_UIBP)
return CLobby_RoleInfo_IntimateRelationship_Exhibition_UIBP