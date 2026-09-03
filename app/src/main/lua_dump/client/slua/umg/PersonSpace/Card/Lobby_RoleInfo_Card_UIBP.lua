local CoupleAvatarConfig = require("client.slua.logic.lobby.Left.CoupleAvatarConfig")
local Lobby_RoleInfo_Card_UIBP = {}
local C_DefaultSegment = 101
function Lobby_RoleInfo_Card_UIBP:ctor(_, extra)
  log(bWriteLog and "Lobby_RoleInfo_Card_UIBP:ctor")
  self.uid = extra.uid or DataMgr.roleData.uid
  self.isSelf = tonumber(self.uid) == tonumber(DataMgr.roleData.uid)
  self.bInit = extra.bInit
  self.bNeedClose = true
  self._cObj_coupleAvatarUI = nil
  self.isShowSkin = false
  self._tAvatarShowCfg = {
    UseCacheData = true,
    bCheckIsShow = true,
    bIsShowCar = true,
    bCustomerView = true,
    nSourceType = Enum_AvatarShowSource.Lobby_RoleInfo_Card_UIBP
  }
  self._tCoupleUIShowCfg = {bIsCheckHideRoleTip = true, bIsShowDownloadUI = true}
  self.bUIShow = true
  self.bButtonClick = false
  self.bParentEnterAnimFinished = false
end
function Lobby_RoleInfo_Card_UIBP:RegistEvents()
  log(bWriteLog and "Lobby_RoleInfo_Card_UIBP:RegistEvents")
  Lobby_RoleInfo_Card_UIBP.__super.RegistEvents(self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Editor, self.OnClickEditorButton, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Share, self.OnClickShareButton, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_QRCode, self.OnClickShareButton, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Enter, self.OnClickEnterButton, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_CopyPlayerID, self.OnClickCopyPlayerIDButton, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_add_friend, self.OnClickedAddButton, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_EditCard, self.OnClickedButton_EditCard, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Copy, self.OnClickCopyNameButton, self)
  self:AddCommonEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_GET_POPULARITY_SIMPLE_RSP, self.GetPopularitySimpleRsp, self)
  self:AddCommonEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_ROLEINFO, self.OnRefreshSegment, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY_SOCIAL, EVENTID_LOBBY_SOCIAL_CARD_UPDATE, self.OnRefershInfo, self)
  self:AddControlEventByControl(self.UIRoot.ScrollBox_0, "OnUserScrolled", self.OnBeginScroll, self)
  self:AddControlEventByControl(self.UIRoot.ScrollBox_0, "OnEndScroll", self.OnEndScroll, self)
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  local spData = RoleInfoMainSystem.GetSuperData()
  self:AddDataListener(spData, "newCardRed", self.OnRefreshCardReddot, self)
  local roleinfo_main = UIManager.GetUI(UIManager.UI_Config.roleinfo_main)
  if roleinfo_main then
    self:AddOnClickedEventByControl(roleinfo_main.UIRoot.Button_1, self.OnButtonHideClick, self)
    self:AddOnClickedEventByControl(roleinfo_main.UIRoot.Button_2, self.OnButtonReplayClick, self)
  end
  local ScreenInput = import("ScreenInput")
  local UIUtil = require("client.common.ui_util")
  local worldContextObject = UIUtil.GetGameInstance()
  self.screenInput = ScreenInput(worldContextObject)
  self.screenInput:Init()
  self:AddControlEventByControl(self.screenInput, "OnMouseButtonUp", self.OnMouseButtonUp, self)
end
function Lobby_RoleInfo_Card_UIBP:OnPostInitialize()
  log(bWriteLog and "Lobby_RoleInfo_Card_UIBP:OnPostInitialize")
  Lobby_RoleInfo_Card_UIBP.__super.OnPostInitialize(self)
  self:UpdateUI()
  self:LoadAvatarScene()
  self:ShowPlayerAvatar()
  local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
  PersonSpaceSystem.get_intimacy_relation_req()
end
function Lobby_RoleInfo_Card_UIBP:OnShow()
  if self.UIRoot.fadein then
    self:PlayUserWidgetAnimation(self.UIRoot.fadein, 0, 1, 0, 1)
  end
  local roleinfo_main = UIManager.GetUI(UIManager.UI_Config.roleinfo_main)
  if roleinfo_main then
    roleinfo_main:SetWidgetVisible(roleinfo_main.UIRoot.Button_1, true, true)
    local logic_roleInfo_background = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_background)
    if logic_roleInfo_background:HasHighLevelEffect() then
      roleinfo_main:SetWidgetVisible(roleinfo_main.UIRoot.Button_2, true, true)
    end
    if roleinfo_main.UIRoot.Anim_Select then
      roleinfo_main:PlayUserWidgetAnimation(roleinfo_main.UIRoot.Anim_Select, 0, 1, 0, 1)
    end
  end
  self:PlayEffect()
end
function Lobby_RoleInfo_Card_UIBP:OnHide()
  Lobby_RoleInfo_Card_UIBP.__super.OnHide(self)
  log(bWriteLog and "Lobby_RoleInfo_Card_UIBP:OnHide")
  local roleinfo_main = UIManager.GetUI(UIManager.UI_Config.roleinfo_main)
  if roleinfo_main then
    roleinfo_main:SetWidgetVisible(roleinfo_main.UIRoot.Button_1, false)
    roleinfo_main:SetWidgetVisible(roleinfo_main.UIRoot.Button_2, false)
  end
  local logic_roleInfo_background = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_background)
  logic_roleInfo_background:ClearHighLevelEffect()
  self:ShowUIExceptHideAndReplay(true)
end
function Lobby_RoleInfo_Card_UIBP:OnClose()
  self:UnloadAvatarScene()
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_CLOSE)
end
function Lobby_RoleInfo_Card_UIBP:OnClickEditorButton()
  log(bWriteLog and "Lobby_RoleInfo_Card_UIBP:OnClickEditorButton")
  self:PlayAudio(sound_config.click_v1)
  self:AttachCardEditorUIBP()
  self:SetWidgetVisible(self.UIRoot.Button_Editor, false, true)
  self.UIRoot.WidgetSwitcher_Button:SetActiveWidgetIndex(1)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.RoleInfoSocialCardEditor)
end
function Lobby_RoleInfo_Card_UIBP:OnClickShareButton()
  log(bWriteLog and "Lobby_RoleInfo_Card_UIBP:OnClickShareButton")
  self:PlayAudio(sound_config.click_v1)
  self:TryStopRecord()
  local Util = require("client.slua_ui_framework.util")
  local shareCfg = {
    sceneType = ShareSceneType.RoleInfoCard,
    campaign = "roleinfoCard",
    reasonStr = json.encode({
      uid = DataMgr.roleData.uid,
      buttonStr = "Button_QRCode"
    }),
    showFace = false,
    PrivacySettings = true,
    ShowSettingRankData = true,
    share_type = ShareBtnTLogShareTypeDefine.SocialBusinessCard
  }
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.RoleInfoSocialCardShare)
  Util.ShowShare(shareCfg, UIManager.UI_Config.Lobby_RoleInfo_Card_Share_UIBP, self.uid)
  local ShareMgr = require("client.logic.share.share_logic")
  ShareMgr.ShareBtnReq(1, ShareBtnTLogShareTypeDefine.SocialBusinessCard, nil, nil)
end
function Lobby_RoleInfo_Card_UIBP:OnClickEnterButton()
  log(bWriteLog and "Lobby_RoleInfo_Card_UIBP:OnClickEnterButton")
  self:PlayAudio(sound_config.click_v1)
  self:InitButtonState()
  self:AttachCardShowUIBP()
end
function Lobby_RoleInfo_Card_UIBP:OnClickCopyPlayerIDButton()
  log(bWriteLog and "Lobby_RoleInfo_Card_UIBP:OnClickCopyPlayerIDButton")
  self:PlayAudio(sound_config.click_v1)
  local LobbySocialSystem = require("client.slua.logic.lobby.Left.logic_lobby_social")
  local profile = LobbySocialSystem.GetProfileByUID(self.uid)
  if profile then
    Client.ClipBoardCopy(self.uid)
    ShowNotice(105001)
  end
end
function Lobby_RoleInfo_Card_UIBP:OnClickedAddButton()
  self:PlayAudio(sound_config.click_v1)
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckSocialRestrict() then
    return
  end
  self:TryStopRecord()
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local msgId = 60
  if DataMgr.roleData.gender == 1 then
    msgId = 59
  end
  log(bWriteLog and "Lobby_RoleInfo_Card_UIBP:OnClickedAddButton msgId = " .. tostring(msgId))
  UIManager.ShowUI(UIManager.UI_Config.friend_verify, {
    self.uid
  }, LogicFriend.TabType.RoleInfoCard, msgId)
end
function Lobby_RoleInfo_Card_UIBP:OnClickCopyNameButton()
  self:PlayAudio(sound_config.click_v1)
  local LobbySocialSystem = require("client.slua.logic.lobby.Left.logic_lobby_social")
  local profile = LobbySocialSystem.GetProfileByUID(self.uid)
  if profile then
    Client.ClipBoardCopy(profile.nickName)
    ShowNotice(105001)
  end
end
function Lobby_RoleInfo_Card_UIBP:OnButtonHideClick()
  log(bWriteLog and "Lobby_RoleInfo_Card_UIBP:OnButtonHideClick")
  self:PlayAudio(sound_config.click_v1)
  self.bUIShow = not self.bUIShow
  self:ShowUIExceptHideAndReplay(self.bUIShow)
  self.bButtonClick = true
end
function Lobby_RoleInfo_Card_UIBP:OnButtonReplayClick()
  log(bWriteLog and "Lobby_RoleInfo_Card_UIBP:OnButtonReplayClick")
  self:PlayAudio(sound_config.click_v1)
  self:PlayEffect()
  self.bButtonClick = true
end
function Lobby_RoleInfo_Card_UIBP:GetPopularitySimpleRsp(_, __, uid, data)
  log(bWriteLog and "Lobby_RoleInfo_Card_UIBP:GetPopularitySimpleRsp1")
  local RoleInfoPopularitySystem = require("client.slua.logic.person_space.logic_roleinfo_popularity")
  if tonumber(self.uid) ~= tonumber(DataMgr.roleData.uid) then
    local SettingUtil = require("client.slua.logic.setting.setting_util")
    local bShow = SettingUtil.OnlyFriend(RoleInfoPopularitySystem.CurrUid, RoleInfoPopularitySystem.IsShowDetail, 1)
    log_format(bWriteLog and "Lobby_RoleInfo_Card_UIBP:GetPopularitySimpleRsp self.uid = %s, RoleInfoPopularitySystem.CurrUid = %s, RoleInfoPopularitySystem.IsShowDetail = %s, bShow = %s", self.uid, RoleInfoPopularitySystem.CurrUid, RoleInfoPopularitySystem.IsShowDetail, bShow)
    if not bShow then
      self:SetWidgetVisible(self.UIRoot.Popularity_Level_Icon_UIBP, false)
      return
    end
  end
  if tostring(self.uid) == tostring(uid) then
    local popularityLevel = RoleInfoPopularitySystem.GetPopularityLevelByExp(data.total_devote)
    if self.UIRoot.Popularity_Level_Icon_UIBP and popularityLevel ~= 0 then
      self.UIRoot.Popularity_Level_Icon_UIBP:SetData(popularityLevel)
      self:SetWidgetVisible(self.UIRoot.Popularity_Level_Icon_UIBP, true)
    else
      self:SetWidgetVisible(self.UIRoot.Popularity_Level_Icon_UIBP, false)
    end
  end
end
function Lobby_RoleInfo_Card_UIBP:OnRefreshSegment()
  log(bWriteLog and "Lobby_RoleInfo_Card_UIBP:OnRefreshSegment")
  local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
  local zoneId = ZoneSystem.nChooseZoneID
  if zoneId == 0 then
    log(bWriteLog and "Lobby_RoleInfo_Card_UIBP:OnRefreshSegment zoneId is zero")
    zoneId = 1
  end
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  local curTppScore = RoleInfoSystem.CurrSeasonTPPTotalScore[zoneId] or 0
  local curTppRank = RoleInfoSystem.CurrSeasonTPPTotalRank[zoneId] or ""
  local curFppScore = RoleInfoSystem.CurrSeasonFPPTotalScore[zoneId] or 0
  local curFppRank = RoleInfoSystem.CurrSeasonFPPTotalRank[zoneId] or ""
  if curTppScore == 0 or curTppRank == "" or curFppScore == 0 or curFppRank == "" then
    log(bWriteLog and "Lobby_RoleInfo_Card_UIBP:OnRefreshSegment data is invalid")
    return
  end
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  local rankShowType = RoleInfoMainSystem.GetRankShowType()
  local _, segment = RoleInfoMainSystem.GetMaxSegmentInfo(rankShowType)
  self.UIRoot.Common_RankIntegralLevel_Style_Large_UIBP:SetRankInteral(segment or C_DefaultSegment, nil)
end
function Lobby_RoleInfo_Card_UIBP:OnRefershInfo()
  log(bWriteLog and "Lobby_RoleInfo_Card_UIBP:OnRefershCardInfo")
  self:UpdateBasicInfo()
end
function Lobby_RoleInfo_Card_UIBP:OnRefreshCardReddot()
  self:UpdateCardReddot()
end
function Lobby_RoleInfo_Card_UIBP:UpdateUI()
  self:InitButtonState()
  self:InitTextContent()
  self:UpdateBasicInfo()
  self:UpdateCardReddot()
  self:AttachCardShowUIBP()
  local RoleInfoPopularitySystem = require("client.slua.logic.person_space.logic_roleinfo_popularity")
  RoleInfoPopularitySystem.enter(self.uid)
  RoleInfoPopularitySystem.get_popularity_simple_req(self.uid)
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  RoleInfoMainSystem.UpdateRoleinfoSeasonListID(1)
  RoleInfoMainSystem.RequestBattleInfo()
  local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
  logic_profile_get_wrap.GetNormalProfiles({
    tonumber(self.uid)
  }, function(list)
    self:OnGetSelfRoleInfoCallBack(list)
  end, Enum_PROFILE_REPORT_CFG.ROLE_INFO, 100, true)
  self:UpdateCardSkin()
  self:SetWidgetVisible(self.UIRoot.Button_EditCard, false, true)
end
function Lobby_RoleInfo_Card_UIBP:InitButtonState()
  self.UIRoot.WidgetSwitcher_8:ClearChildren()
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_Share, false, false)
  if self.isSelf then
    self:SetWidgetVisible(self.UIRoot.Button_Editor, true, true)
    self.UIRoot.WidgetSwitcher_Button:SetActiveWidgetIndex(3)
    local strRegion = Client.GetPublishRegion()
    local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
    if strRegion == PublishRegionMacros.BLUEHOLE then
      self:SetWidgetVisible(self.UIRoot.CanvasPanel_Share, false, false)
    else
      self:SetWidgetVisible(self.UIRoot.CanvasPanel_Share, true, false)
    end
  elseif LogicFriend.IsMyFriend(self.uid) then
    self:SetWidgetVisible(self.UIRoot.Button_Editor, false, true)
    self.UIRoot.WidgetSwitcher_Button:SetActiveWidgetIndex(3)
  else
    self:SetWidgetVisible(self.UIRoot.Button_Editor, false, true)
    self.UIRoot.WidgetSwitcher_Button:SetActiveWidgetIndex(2)
  end
end
function Lobby_RoleInfo_Card_UIBP:InitTextContent()
  self.UIRoot.TextBlock_Editor:SetText(LocUtil.LocalizeResFormat(45904))
  self.UIRoot.TextBlock_Enter:SetText(LocUtil.LocalizeResFormat(45905))
  self.UIRoot.TextBlock_Season:SetText(LocUtil.LocalizeResFormat(45893))
  self.UIRoot.TextBlock_History:SetText(LocUtil.LocalizeResFormat(45894))
end
function Lobby_RoleInfo_Card_UIBP:UpdateBasicInfo()
  self.UIRoot.TextBlock_PlayerID:SetText(self.uid or "")
  local LobbySocialSystem = require("client.slua.logic.lobby.Left.logic_lobby_social")
  local uid = self.uid
  local profile = LobbySocialSystem.GetProfileByUID(uid)
  if not profile then
    log(bWriteLog and "Lobby_RoleInfo_Card_UIBP:UpdateBasicInfo profile info is invalid with uid " .. tostring(self.uid))
    return
  end
  self.UIRoot.Common_Avatar_BP:InitView(1, uid, profile.picUrl, profile.sex, profile.cur_avatar_box_id, profile.level, false, "")
  self.UIRoot.Common_Avatar_BP:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
  if self.UIRoot.Pround_Level_Icon_UIBP then
    self.UIRoot.Pround_Level_Icon_UIBP:SetData(self.uid)
  end
  local UIUtil = require("client.common.ui_util")
  UIUtil.UpdateNationImage(self.UIRoot.Image_Flag, profile.nation)
  if profile.social_card and type(profile.social_card) == "table" and self.UIRoot.Common_Gender_UIBP then
    self.UIRoot.Common_Gender_UIBP:LoadIcon(self.uid)
  else
    log(bWriteLog and "Lobby_RoleInfo_Card_UIBP:UpdateBasicInfo profile.social_card is invalid")
  end
  self.UIRoot.TextBlock_PlayerName:SetText(profile.nickName or "")
  if profile.corps_id == 0 or profile.corps_id == nil then
    self:SetWidgetVisible(self.UIRoot.Image_CropsLogo, false)
    self:SetWidgetVisible(self.UIRoot.TextBlock_CorpsName, false)
    self.UIRoot.WidgetSwitcher_Corps:SetActiveWidgetIndex(1)
  else
    self.UIRoot.WidgetSwitcher_Corps:SetActiveWidgetIndex(0)
    local corps_summary = LobbySocialSystem.CacheCorpsSummary[profile.corps_id] or {}
    self:SetWidgetVisible(self.UIRoot.Image_CropsLogo, true)
    self:SetWidgetVisible(self.UIRoot.TextBlock_CorpsName, true)
    self.UIRoot.TextBlock_CorpsName:SetText(corps_summary.name or "")
    local cfg = CDataTable.GetTableData("corps_alias_table", profile.corp_alias_id)
    if cfg then
      if cfg.Default == 1 then
        self.UIRoot.WidgetSwitcher_5:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
        self.UIRoot.WidgetSwitcher_21:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
        local pos = corps_summary.position or 0
        if pos == 0 then
          self.UIRoot.WidgetSwitcher_5:SetActiveWidgetIndex(3)
        elseif pos == 1 then
          self.UIRoot.WidgetSwitcher_5:SetActiveWidgetIndex(0)
        elseif pos == 2 then
          self.UIRoot.WidgetSwitcher_5:SetActiveWidgetIndex(1)
        elseif pos == 3 then
          self.UIRoot.WidgetSwitcher_5:SetActiveWidgetIndex(2)
        else
          self.UIRoot.WidgetSwitcher_5:SetActiveWidgetIndex(3)
        end
      else
        self.UIRoot.WidgetSwitcher_5:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
        self.UIRoot.WidgetSwitcher_21:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
        self.UIRoot["aliasName" .. cfg.background]:SetText(cfg.CorpAliasName)
        self.UIRoot.WidgetSwitcher_21:SetActiveWidgetIndex(cfg.background - 1)
      end
    else
      self.UIRoot.WidgetSwitcher_5:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      self.UIRoot.WidgetSwitcher_21:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
    local icon_path = "/Game/UMG/Texture/Atlas/LobbyPlayerInfoUI/Frames/Players_icon_xiangqing_png"
    if corps_summary.icon ~= nil and 0 < corps_summary.icon then
      local corpIDConf = CDataTable.GetTableData("CorpsBadge", tonumber(corps_summary.icon))
      if corpIDConf ~= nil then
        icon_path = corpIDConf.IconPath
      end
    end
    self:SetTexture(self.UIRoot.Image_CropsLogo, icon_path)
  end
end
function Lobby_RoleInfo_Card_UIBP:OnGetSelfRoleInfoCallBack(list)
  log(bWriteLog and "Lobby_RoleInfo_Card_UIBP.OnGetSelfRoleInfoCallBack")
  if not list or not list[1] then
    return
  end
  if tonumber(self.uid) ~= tonumber(list[1].uid) then
    return
  end
  local root = self.UIRoot
  if not root then
    return
  end
  local historyRanks = list[1].history_max_segment_level or {C_DefaultSegment}
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  local historyHigestRank, historySeasonId = RoleInfoMainSystem.GetHistotyMaxSegmentAndSeasonId(historyRanks, list[1].history_max_segment_season_id)
  root.Common_RankIntegralLevel_Style_Large_UIBP_C_0:SetRankInteralBySeason(historyHigestRank or C_DefaultSegment, nil, historySeasonId)
  self:UpdateBasicInfo()
  local Lobby_RoleInfo_Card_Show_UIBP = UIManager.GetUI(UIManager.UI_Config.Lobby_RoleInfo_Card_Show_UIBP)
  if Lobby_RoleInfo_Card_Show_UIBP then
    log(bWriteLog and "Lobby_RoleInfo_Card_UIBP:OnGetSelfRoleInfoCallBack Lobby_RoleInfo_Card_Show_UIBP UpdateCard")
    Lobby_RoleInfo_Card_Show_UIBP:UpdateCard()
  end
  self:UpdateCardSkin()
  local logic_roleInfo_background = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_background)
  logic_roleInfo_background:UpdatePlayerEquipBGLevel(self.uid)
end
function Lobby_RoleInfo_Card_UIBP:UpdateCardReddot()
  if not self.isSelf then
    if self.UIRoot and self.UIRoot.Image_Reddot_SocialCard then
      self.UIRoot.Image_Reddot_SocialCard:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
    return
  end
  if self.UIRoot and self.UIRoot.Image_Reddot_SocialCard then
    local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
    local spData = RoleInfoMainSystem.GetSuperData()
    self:SetWidgetVisible(self.UIRoot.Image_Reddot_SocialCard, spData.newCardRed)
  end
end
function Lobby_RoleInfo_Card_UIBP:AttachCardShowUIBP()
  self:CloseSubUI()
  self.Lobby_RoleInfo_Card_Show_UIBP = self:CreateChildWindow(self.UIRoot.WidgetSwitcher_8, UIManager.UI_Config.Lobby_RoleInfo_Card_Show_UIBP, self.uid)
  self.UIRoot.ScrollBox_0:ScrollToStart()
end
function Lobby_RoleInfo_Card_UIBP:UpdateCardSkin()
  local logic_social_card_bg = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_social_card_bg)
  self.UIRoot.WidgetSwitcher_Effect:SetActiveWidgetIndex(1)
  self.isShowSkin = true
  local StringUtil = require("common.string_util")
  local currentSkinID = logic_social_card_bg:GetCurrentSocialCardBGID()
  if not self.isSelf then
    local LobbySocialSystem = require("client.slua.logic.lobby.Left.logic_lobby_social")
    local profile = LobbySocialSystem.GetProfileByUID(self.uid)
    if profile and profile.social_card and profile.social_card.socialCardFloorID then
      currentSkinID = profile.social_card.socialCardFloorID
    else
      currentSkinID = logic_social_card_bg.GetDefaultSocialCardBGID()
    end
  end
  local effect_bp_path = logic_social_card_bg:GetSocialCardPersonBGPath(currentSkinID)
  if effect_bp_path and effect_bp_path ~= "" then
    self:ClearCardSkin()
    local uiConfig = UIManager.UI_Config.Lobby_RoleInfo_EffectSkin_Item_UIBP
    local aniName
    if logic_social_card_bg:CheckSocialCardCanLoop(currentSkinID) then
      aniName = "Auto_Loop"
    end
    local extraData = {}
    local item_data = logic_social_card_bg:GetSocialCardBG(currentSkinID)
    if item_data.Level == 3 then
      extraData.bEnableGyroscope = true
    end
    local callback = function()
      log(bWriteLog and "Lobby_RoleInfo_Card_UIBP:UpdateCardSkin callback")
      self.UIRoot.WidgetSwitcher_Effect:SetActiveWidgetIndex(1)
      self.isShowSkin = true
      self.card_skin_bp = self:CreateChildWindowWithBpPath("CanvasPanel_Effect", uiConfig, effect_bp_path, aniName, extraData)
      self:ChangeTextColorBySkin()
      return true
    end
    local pak_util = require("client.common.pak_util")
    if not pak_util.CheckAndDownloadWithCallback(effect_bp_path, callback) then
      log(bWriteLog and "Lobby_RoleInfo_Card_UIBP:UpdateCardSkin undownload")
      self.UIRoot.WidgetSwitcher_Effect:SetActiveWidgetIndex(0)
    end
  else
    self.UIRoot.WidgetSwitcher_Effect:SetActiveWidgetIndex(0)
    self.isShowSkin = false
  end
  self:ChangeTextColorBySkin()
end
function Lobby_RoleInfo_Card_UIBP:ClearCardSkin()
  if self.card_skin_bp then
    self.card_skin_bp:Close()
    self.card_skin_bp = nil
  end
end
function Lobby_RoleInfo_Card_UIBP:AttachCardEditorUIBP()
  self:CloseSubUI()
  self.Lobby_RoleInfo_Card_Editor_UIBP = self:CreateChildWindow(self.UIRoot.WidgetSwitcher_8, UIManager.UI_Config.Lobby_RoleInfo_Card_Editor_UIBP, self.uid)
  self.UIRoot.ScrollBox_0:ScrollToStart()
end
function Lobby_RoleInfo_Card_UIBP:CloseSubUI()
  if self.Lobby_RoleInfo_Card_Show_UIBP then
    self.Lobby_RoleInfo_Card_Show_UIBP:CloseSelf()
    self.Lobby_RoleInfo_Card_Show_UIBP = nil
  end
  if self.Lobby_RoleInfo_Card_Editor_UIBP then
    self.Lobby_RoleInfo_Card_Editor_UIBP:CloseSelf()
    self.Lobby_RoleInfo_Card_Editor_UIBP = nil
  end
end
function Lobby_RoleInfo_Card_UIBP:LoadAvatarScene()
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  Lobby_camera_manager_module:SwitchCamera(40035)
  local logic_roleInfo_background = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_background)
  local callback = function()
    EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_BACKGROUND_SCENE_LOADED)
  end
  logic_roleInfo_background:UpdatePlayerEquipBGLevel(self.uid, callback)
end
function Lobby_RoleInfo_Card_UIBP:ShowPlayerAvatar()
  if not self.bInit or self.bParentEnterAnimFinished then
    local nCurUId = self.uid
    if self._cObj_coupleAvatarUI then
      self._cObj_coupleAvatarUI:RefreshShow(nCurUId)
    else
      self._cObj_coupleAvatarUI = self:CreateChildWindow(self.UIRoot.CanvasPanel_CoupleAvatar, UIManager.UI_Config.CoupleAvatar_UIBP, nCurUId, CoupleAvatarConfig.ESceneType.RoleInfo, self._tAvatarShowCfg, self._tCoupleUIShowCfg)
    end
  end
end
function Lobby_RoleInfo_Card_UIBP:OnBeginScroll()
  local custom_presentation_config = require("client.slua.logic.person_space.custom_presentation_config")
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_CUSTOM_PRESENTATION_ON_SHOW_SMALL_TIPS, custom_presentation_config.EmptyModuleData)
  log(bWriteLog and "Lobby_RoleInfo_Card_UIBP:OnBeginScroll")
  local Lobby_RoleInfo_Card_Editor_UIBP = UIManager.GetUI(UIManager.UI_Config.Lobby_RoleInfo_Card_Editor_UIBP)
  if not Lobby_RoleInfo_Card_Editor_UIBP then
    log(bWriteLog and "Lobby_RoleInfo_Card_UIBP:OnBeginScroll Lobby_RoleInfo_Card_Editor_UIBP is not show")
    return
  end
  if self.bNeedClose then
    log(bWriteLog and "Lobby_RoleInfo_Card_UIBP:OnBeginScroll close all combobox")
    Lobby_RoleInfo_Card_Editor_UIBP:CloseAllCombobox()
    self.bNeedClose = false
  end
end
function Lobby_RoleInfo_Card_UIBP:OnEndScroll()
  log(bWriteLog and "Lobby_RoleInfo_Card_UIBP:OnEndScroll")
  self.bNeedClose = true
end
function Lobby_RoleInfo_Card_UIBP:OnMouseButtonUp()
  log(bWriteLog and "Lobby_RoleInfo_Card_UIBP:OnMouseButtonUp")
  self:AddTimerOnce(0, function()
    if self.bButtonClick == true then
      self.bButtonClick = false
      return
    end
    if self.bUIShow == false then
      self.bUIShow = true
      self:ShowUIExceptHideAndReplay(self.bUIShow)
    end
  end)
end
function Lobby_RoleInfo_Card_UIBP:UnloadAvatarScene()
  local logic_roleInfo_background = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_background)
  logic_roleInfo_background:UnloadCurrentRoleInfoBGLevel(true)
end
function Lobby_RoleInfo_Card_UIBP:ShowAvatarAfterEnterAnim()
  self.bParentEnterAnimFinished = true
  if self:IsAsyncLoading() then
    return
  end
  self:ShowPlayerAvatar()
end
function Lobby_RoleInfo_Card_UIBP:TryStopRecord()
  local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
  logic_chat_voice:TryStopPlayRecordVoice()
end
function Lobby_RoleInfo_Card_UIBP:ShowUIExceptHideAndReplay(bShow)
  if self.UIRoot.CanvasPanel_0 then
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_0, bShow)
  end
  local Personalization_UIBP = UIManager.GetUI(UIManager.UI_Config.Personalization_UIBP)
  if Personalization_UIBP then
    Personalization_UIBP:SetWidgetVisible(Personalization_UIBP.UIRoot.Common_Tab_Vertical_LevelTwo_Icon_UIBP, bShow)
  end
  local Lobby_NewRoleInfo_Mgr_UIBP = UIManager.GetUI(UIManager.UI_Config.roleinfo_main)
  if Lobby_NewRoleInfo_Mgr_UIBP then
    Lobby_NewRoleInfo_Mgr_UIBP:SetWidgetVisible(Lobby_NewRoleInfo_Mgr_UIBP.UIRoot.CanvasPanel_11, bShow)
    Lobby_NewRoleInfo_Mgr_UIBP:SetWidgetVisible(Lobby_NewRoleInfo_Mgr_UIBP.UIRoot.Common_Tab_Vertical_LevelOne_Text_UIBP, bShow)
    Lobby_NewRoleInfo_Mgr_UIBP:SetWidgetVisible(Lobby_NewRoleInfo_Mgr_UIBP.UIRoot.Image_SideMask, bShow)
  end
end
function Lobby_RoleInfo_Card_UIBP:PlayEffect(callback)
  log(bWriteLog and "Lobby_RoleInfo_Card_UIBP:PlayEffect")
  local logic_roleInfo_background = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_background)
  logic_roleInfo_background:PlayHighLevelEffect(function()
    if callback then
      callback()
    end
  end)
end
function Lobby_RoleInfo_Card_UIBP:DirectylyAttachCardEditorUIBP()
  log(bWriteLog and "Lobby_RoleInfo_Card_UIBP:DirectylyAttachCardEditorUIBP")
  self:AttachCardEditorUIBP()
  self:SetWidgetVisible(self.UIRoot.Button_Editor, false, true)
end
function Lobby_RoleInfo_Card_UIBP:OnClickedButton_EditCard()
  log(bWriteLog and "Lobby_RoleInfo_Card_UIBP:DirectylyAttachCardShowUIBP")
  self:PlayAudio(sound_config.click_v1)
  local logic_roleinfo_title = require("client.slua.logic.roleInfo.logic_roleinfo_title")
  logic_roleinfo_title.get_alias_list()
  UIManager.ShowUI(UIManager.UI_Config.Lobby_RoleInfo_CustomInformation_Popup_UIBP)
end
function Lobby_RoleInfo_Card_UIBP:ChangeTextColorBySkin()
  local color
  if self.isShowSkin then
    color = FSlateColor(FLinearColor(1, 1, 1, 1))
  else
    color = FSlateColor(FLinearColor(0, 0, 0, 1))
  end
  self.UIRoot.TextBlock_PlayerName:SetColorAndOpacity(color)
  self.UIRoot.TextBlock_Season:SetColorAndOpacity(color)
  self.UIRoot.TextBlock_History:SetColorAndOpacity(color)
  self.UIRoot.TextBlock_0:SetColorAndOpacity(color)
  self.UIRoot.TextBlock_CorpsName:SetColorAndOpacity(color)
  self.UIRoot.Text_Commander:SetColorAndOpacity(color)
  self.UIRoot.Text_DeputyCommander:SetColorAndOpacity(color)
  self.UIRoot.Text_Elite:SetColorAndOpacity(color)
  self.UIRoot.Text_Member:SetColorAndOpacity(color)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CLobby_RoleInfo_Card_UIBP = class(ui_base, nil, Lobby_RoleInfo_Card_UIBP)
return CLobby_RoleInfo_Card_UIBP