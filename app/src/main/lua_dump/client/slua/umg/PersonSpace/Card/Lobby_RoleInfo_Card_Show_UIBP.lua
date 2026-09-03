local Lobby_RoleInfo_Card_Show_UIBP = {}
function Lobby_RoleInfo_Card_Show_UIBP:ctor(_, uid)
  self.SocialCard = {}
  self.uid = uid or DataMgr.roleData.uid
  self.isSelf = tonumber(self.uid) == tonumber(DataMgr.roleData.uid)
  self.animPlayFlag = false
end
function Lobby_RoleInfo_Card_Show_UIBP:OnInitialize()
  log(bWriteLog and "Lobby_RoleInfo_Card_Show_UIBP:OnInitialize")
  Lobby_RoleInfo_Card_Show_UIBP.__super.OnInitialize(self)
  self.LoopScrollGrid_Label = self:InitScrollBox(self.UIRoot.LoopScrollGrid_0)
  self:SetWidgetVisible(self.UIRoot.Button_0, false)
end
function Lobby_RoleInfo_Card_Show_UIBP:RegistEvents()
  Lobby_RoleInfo_Card_Show_UIBP.__super.RegistEvents(self)
  self.LoopScrollGrid_Label:SetRefreshItemCallback(self.OnRefreshItem, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_10, self.OnClickPlayButton, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Editor, self.OnClickButton_Editor, self)
  self:AddControlEventByControl(self.UIRoot.Button_SPHelp, "OnClicked", self.OnClickCustomPresentationHelpButton, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY_SOCIAL, EVENTID_LOBBY_SOCIAL_CARD_UPDATE, self.OnRefershCardInfo, self)
  self:AddCommonEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_SIGNINFO_REFRESH, self.OnRefreshSign, self)
  self:AddCommonEvent(EVENTTYPE_CHAT, EVENTID_CHAT_START_PLAY_RECORD_FILE, self.StartPlayRecordFile, self)
  self:AddCommonEvent(EVENTTYPE_CHAT, EVENTID_CHAT_STOP_PLAY_RECORD_FILE, self.StopPlayRecordFile, self)
  self:AddCommonEvent(EVENTTYPE_ANTSVOICE, EVENTID_ANTSVOICE_ON_DOWNLOAD_FILEID_NOT_EXIST, self.OnDownloadNotExist, self)
  self:AddCommonEvent(EVENTTYPE_ANTSVOICE, EVENTID_ANTSVOICE_ON_DOWNLOAD_FILEID_FAILED, self.OnDownloadFailed, self)
  self:AddCommonEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_CUSTOM_PRESENTATION_CHANGE, self.UpdateCustomPresentation, self)
end
function Lobby_RoleInfo_Card_Show_UIBP:OnClickPlayButton()
  log(bWriteLog and "Lobby_RoleInfo_Card_Show_UIBP:OnClickVoiceButton")
  log(bWriteLog and "Lobby_RoleInfo_Card_Show_UIBP.OnClickPlayButton length = " .. tostring(self.length) .. " fileid = " .. tostring(self.fileid))
  local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
  local logic_chat_voice_const = require("client.slua.logic.chat_voice.logic_chat_voice_const")
  local extraPara = {
    source = logic_chat_voice_const.SocialCard,
    permanent = true
  }
  self.animPlayFlag = false
  logic_chat_voice:AddDownloadFile(self.fileid, self.length, extraPara)
  self:PlayUserWidgetAnimation(self.UIRoot.loop, 0, 0, 0, 1)
end
function Lobby_RoleInfo_Card_Show_UIBP:OnClickButton_Editor()
  log(bWriteLog and "Lobby_RoleInfo_Card_Show_UIBP:OnClickButton_Editor")
  local logic_roleinfo_title = require("client.slua.logic.roleInfo.logic_roleinfo_title")
  logic_roleinfo_title.get_alias_list()
  UIManager.ShowUI(UIManager.UI_Config.Lobby_RoleInfo_CustomInformation_Popup_UIBP)
end
function Lobby_RoleInfo_Card_Show_UIBP:OnClickCustomPresentationHelpButton()
  log(bWriteLog and "Lobby_RoleInfo_Card_Show_UIBP:OnClickCustomPresentationHelpButton")
  self:PlayAudio(sound_config.close_v1)
  ShowHelp(LocUtil.GetLocalizeResStr(656037))
end
function Lobby_RoleInfo_Card_Show_UIBP:OnPostInitialize()
  log(bWriteLog and "Lobby_RoleInfo_Card_Show_UIBP:OnPostInitialize")
  Lobby_RoleInfo_Card_Show_UIBP.__super.OnPostInitialize(self)
  self:UpdateUI()
end
function Lobby_RoleInfo_Card_Show_UIBP:OnClose()
  log(bWriteLog and "Lobby_RoleInfo_Card_Show_UIBP:OnClose")
  local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
  logic_chat_voice:TryStopPlayRecordVoice()
  Lobby_RoleInfo_Card_Show_UIBP.__super.OnClose(self)
end
function Lobby_RoleInfo_Card_Show_UIBP:OnRefreshItem(widget, index)
  local data = self.LoopScrollGrid_Label:GetItemData(index)
  widget.TextBlock_Tag:SetText(data)
end
function Lobby_RoleInfo_Card_Show_UIBP:OnRefershCardInfo()
  log(bWriteLog and "Lobby_RoleInfo_Card_Show_UIBP:OnRefershCardInfo")
  self:UpdateCard()
end
function Lobby_RoleInfo_Card_Show_UIBP:OnRefreshSign()
  log(bWriteLog and "Lobby_RoleInfo_Card_Show_UIBP:OnRefreshSign")
  self:UpdateCard()
end
function Lobby_RoleInfo_Card_Show_UIBP:StartPlayRecordFile()
  log(bWriteLog and "Lobby_RoleInfo_Card_Show_UIBP:StartPlayRecordFile")
  self.animPlayFlag = true
end
function Lobby_RoleInfo_Card_Show_UIBP:StopPlayRecordFile()
  log(bWriteLog and "Lobby_RoleInfo_Card_Show_UIBP:StopPlayRecordFile")
  if self.animPlayFlag then
    self.UIRoot:StopAnimation(self.UIRoot.loop)
    self.animPlayFlag = false
  end
end
function Lobby_RoleInfo_Card_Show_UIBP:OnDownloadNotExist(_, __, extraParam)
  log(bWriteLog and "Lobby_RoleInfo_Card_Show_UIBP:OnDownloadNotExist")
  log_tree("Lobby_RoleInfo_Card_Show_UIBP:OnDownloadNotExist extraParam", extraParam)
  local logic_chat_voice_const = require("client.slua.logic.chat_voice.logic_chat_voice_const")
  if extraParam and next(extraParam) and extraParam.source and extraParam.source == logic_chat_voice_const.SocialCard then
    log(bWriteLog and "Lobby_RoleInfo_Card_Show_UIBP:OnDownloadNotExist extraParam match")
    self.animPlayFlag = true
    if not self.isSelf then
      log(bWriteLog and "Lobby_RoleInfo_Card_Show_UIBP:OnDownloadNotExist not self")
      ShowNotice(46037)
      return
    end
    log(bWriteLog and "Lobby_RoleInfo_Card_Show_UIBP:OnDownloadNotExist is self")
    local SocialCardSystem = require("client.slua.logic.lobby.Left.logic_social_card")
    SocialCardSystem.SocialCard.voice_card = nil
    local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
    RoleInfoSystem.modify_social_card()
  end
end
function Lobby_RoleInfo_Card_Show_UIBP:OnDownloadFailed(_, __, extraParam)
  log(bWriteLog and "Lobby_RoleInfo_Card_Show_UIBP:OnDownloadFailed")
  log_tree("Lobby_RoleInfo_Card_Show_UIBP:OnDownloadFailed extraParam", extraParam)
  local logic_chat_voice_const = require("client.slua.logic.chat_voice.logic_chat_voice_const")
  if extraParam and next(extraParam) and extraParam.source and extraParam.source == logic_chat_voice_const.SocialCard then
    log(bWriteLog and "Lobby_RoleInfo_Card_Show_UIBP:OnDownloadFailed extraParam match")
    self.animPlayFlag = true
  end
end
function Lobby_RoleInfo_Card_Show_UIBP:UpdateUI()
  self:InitTextContent()
  self:InitWidgetState()
  self:UpdateCard()
  self:UpdateCustomPresentation()
  self.UIRoot:StopAnimation(self.UIRoot.loop)
end
function Lobby_RoleInfo_Card_Show_UIBP:InitTextContent()
  self.UIRoot.TextBlock_Record_Title:SetText(LocUtil.LocalizeResFormat(45878))
  self.UIRoot.TextBlock_Label:SetText(LocUtil.LocalizeResFormat(45879))
  self.UIRoot.TextBlock_Birthday_Title:SetText(LocUtil.LocalizeResFormat(45880))
  self.UIRoot.TextBlock_Partner_Title:SetText(LocUtil.LocalizeResFormat(45881))
  self.UIRoot.TextBlock_Voice_Title:SetText(LocUtil.LocalizeResFormat(45882))
  self.UIRoot.TextBlock_Position_Title:SetText(LocUtil.LocalizeResFormat(45883))
  self.UIRoot.TextBlock_Time_Title:SetText(LocUtil.LocalizeResFormat(45887))
  self.UIRoot.TextBlock_Server_Title:SetText(LocUtil.LocalizeResFormat(45888))
  self.UIRoot.TextBlock_Weapon_Title:SetText(LocUtil.LocalizeResFormat(45889))
  self.UIRoot.TextBlock_Mode_Title:SetText(LocUtil.LocalizeResFormat(45890))
  self.UIRoot.TextBlock_Sign:SetText(LocUtil.LocalizeResFormat(45891))
  self.UIRoot.TextBlock_LBS_Title:SetText(LocUtil.LocalizeResFormat(39032))
end
function Lobby_RoleInfo_Card_Show_UIBP:InitWidgetState()
  local SocialCardSystem = require("client.slua.logic.lobby.Left.logic_social_card")
  local bBlock = SocialCardSystem.CheckBlockNewData()
  log(bWriteLog and "Lobby_RoleInfo_Card_Show_UIBP:InitWidgetState bBlock = " .. tostring(bBlock))
  self:SetWidgetVisible(self.UIRoot.HorizontalBox_Mode, not bBlock)
  self:SetWidgetVisible(self.UIRoot.VerticalBox_Voice, not bBlock)
  local mainSwitch = SocialCardSystem.GetSocialCardMainSwitch()
  local graySwitch = SocialCardSystem.GetSocialCardGraySwitch()
  self.bShowRecord = mainSwitch and graySwitch and not bBlock
  log(bWriteLog and "Lobby_RoleInfo_Card_Show_UIBP:InitWidgetState bShowRecord = " .. tostring(self.bShowRecord))
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_Record, self.bShowRecord)
end
function Lobby_RoleInfo_Card_Show_UIBP:UpdateCard()
  local LobbySocialSystem = require("client.slua.logic.lobby.Left.logic_lobby_social")
  local profile = LobbySocialSystem.GetProfileByUID(self.uid)
  if not profile then
    return
  end
  self.SocialCard = profile.social_card or {}
  local SocialCardSystem = require("client.slua.logic.lobby.Left.logic_social_card")
  local CardTagList = SocialCardSystem.UnifyCardData(self.SocialCard)
  self.LoopScrollGrid_Label:SetData(CardTagList)
  self.UIRoot.WidgetSwitcher_3:SetActiveWidgetIndex(#CardTagList == 0 and 1 or 0)
  local displayName = "--"
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE then
    if self.SocialCard.pre_server then
      displayName = SocialCardSystem.GetPreServerValue(1).displayName or "--"
    end
  elseif self.SocialCard.pre_server then
    displayName = SocialCardSystem.GetPreServerValue(self.SocialCard.pre_server).displayName or "--"
  end
  self.UIRoot.TextBlock_Server:SetText(displayName)
  local partner = "--"
  if self.SocialCard.tendency and type(self.SocialCard.tendency) == "number" then
    partner = SocialCardSystem.GetTendencyValue(self.SocialCard.tendency)
  end
  self.UIRoot.TextBlock_Partner:SetText(partner)
  local date = ""
  local time = ""
  if self.SocialCard.play_date and type(self.SocialCard.play_date) == "number" then
    date = SocialCardSystem.GetDataValue(self.SocialCard.play_date)
  end
  if self.SocialCard.play_time and type(self.SocialCard.play_time) == "number" then
    time = SocialCardSystem.GetTimeValue(self.SocialCard.play_time)
  end
  local timeValue = ""
  if date ~= "" and time ~= "" then
    timeValue = LocUtil.LocalizeResFormat(45903, tostring(date), tostring(time))
  elseif date == "" and time == "" then
    timeValue = "--"
  else
    timeValue = tostring(date) .. tostring(time)
  end
  self.UIRoot.TextBlock_Time:SetText(timeValue)
  local StringUtil = require("common.string_util")
  local birthYMD = "--"
  local SettingUtil = require("client.slua.logic.setting.setting_util")
  if LobbySystem.CheckOpen(BP_ENUM_ONLY_FRIENFRIEND_PRIVACY) then
    if (SettingUtil.OnlyFriend(self.uid, profile.birthday_privacy_value, 1) or profile.birthday_privacy_value == 1 or self.isSelf) and self.SocialCard.birthday and self.SocialCard.birthday ~= "" then
      local TimeUtil = require("client.common.time_util")
      local ymd = StringUtil.Split(self.SocialCard.birthday, "-")
      local strRegion = Client.GetPublishRegion()
      local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
      if self.isSelf and (PublishRegionMacros.IsJapanOrKorea() or strRegion == PublishRegionMacros.BLUEHOLE) then
        birthYMD = TimeUtil.GetBirthdayTimeFormat(tostring(ymd[1]), tonumber(ymd[2]), tonumber(ymd[3]))
      else
        birthYMD = TimeUtil.GetBirthdayTimeFormat_MD(tonumber(ymd[2]), tonumber(ymd[3]))
      end
    end
  elseif self.SocialCard.birthday and self.SocialCard.birthday ~= "" then
    local TimeUtil = require("client.common.time_util")
    local ymd = StringUtil.Split(self.SocialCard.birthday, "-")
    local strRegion = Client.GetPublishRegion()
    local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
    if self.isSelf and (PublishRegionMacros.IsJapanOrKorea() or strRegion == PublishRegionMacros.BLUEHOLE) then
      birthYMD = TimeUtil.GetBirthdayTimeFormat(tostring(ymd[1]), tonumber(ymd[2]), tonumber(ymd[3]))
    else
      birthYMD = TimeUtil.GetBirthdayTimeFormat_MD(tonumber(ymd[2]), tonumber(ymd[3]))
    end
  end
  self.UIRoot.TextBlock_Birthday:SetText(birthYMD)
  local showSignature = StringUtil.CheckNameRetrunName(profile.signature or "", nil, 60, true)
  if showSignature == "" then
    showSignature = LocUtil.LocalizeResFormat(45906)
  end
  if tonumber(self.uid) ~= tonumber(DataMgr.roleData.uid) then
    local PlayerNation = DataMgr.roleData.ip_region or "CN"
    if profile.signature_is_dirty_cn and PlayerNation == "CN" then
      showSignature = ""
    else
    end
  end
  self.UIRoot.TextBlock_Signature:SetText(showSignature)
  local voiceName = "--"
  if self.SocialCard.voice_state then
    voiceName = SocialCardSystem.GetVoiceValue(self.SocialCard.voice_state)
  end
  self.UIRoot.TextBlock_Voice:SetText(voiceName)
  local area = SocialCardSystem.GetFormatData(self.SocialCard.expert_area, SocialCardSystem.GetExpertAreaValue)
  self.UIRoot.TextBlock_Position:SetText(area)
  local mode = SocialCardSystem.GetFormatData(self.SocialCard.expert_mode, SocialCardSystem.GetModeValue)
  self.UIRoot.TextBlock_Mode:SetText(mode)
  local weapon = ""
  local weaponType = ""
  if self.SocialCard.expert_weapon and type(self.SocialCard.expert_weapon) == "table" then
    if self.SocialCard.expert_weapon[1] then
      weaponType = SocialCardSystem.GetWeaponTypeValue(self.SocialCard.expert_weapon[1])
    end
    if self.SocialCard.expert_weapon[2] then
      weapon = SocialCardSystem.GetWeaponValue(self.SocialCard.expert_weapon[2]).Weapon or ""
    end
  end
  if weapon ~= "" then
    self.UIRoot.TextBlock_Weapon:SetText(weapon)
  elseif weaponType ~= "" then
    self.UIRoot.TextBlock_Weapon:SetText(weaponType)
  else
    self.UIRoot.TextBlock_Weapon:SetText("--")
  end
  local LbsMgr = require("client.slua.logic.lbs.logic_lbs")
  if self.isSelf and not LbsMgr.IsLbsAllSwitchOpen() then
    self.UIRoot.TextBlock_LBS_Title:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self:SetWidgetVisible(self.UIRoot.TextBlock_LBS_Title, false)
    self:SetWidgetVisible(self.UIRoot.TextBlock_LBS, false)
  else
    self:SetWidgetVisible(self.UIRoot.TextBlock_LBS_Title, true)
    self:SetWidgetVisible(self.UIRoot.TextBlock_LBS, true)
    if self.SocialCard.lbs and string.find(self.SocialCard.lbs, "-") then
      if self.SocialCard.lbs and self.SocialCard.lbs ~= "" then
        self.UIRoot.TextBlock_LBS:SetText(self.SocialCard.lbs)
      else
        self.UIRoot.TextBlock_LBS:SetText("--")
      end
    else
      self.UIRoot.TextBlock_LBS:SetText("--")
    end
  end
  if self.bShowRecord then
    if self.SocialCard.voice_card and type(self.SocialCard.voice_card) == "table" then
      self.fileid = self.SocialCard.voice_card.fileid
      self.length = self.SocialCard.voice_card.length
      if self.fileid and self.length then
        log(bWriteLog and "Lobby_RoleInfo_Card_Show_UIBP:UpdateCard length = " .. tostring(self.length) .. " fileid = " .. tostring(self.fileid))
        self.UIRoot.TextBlock_17:SetText(tostring(self.length))
        self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(0)
      else
        self.UIRoot:StopAnimation(self.UIRoot.loop)
        self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(1)
      end
    else
      self.fileid = nil
      self.length = nil
      self.UIRoot:StopAnimation(self.UIRoot.loop)
      self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(1)
    end
  end
  self.UIRoot.Button_Editor:SetWidgetVisibility(self.isSelf and UEnums.ESlateVisibility.Visible or UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.TextBlock_3:SetText(LocUtil.LocalizeResFormat(46032))
end
function Lobby_RoleInfo_Card_Show_UIBP:UpdateCustomPresentation()
  if self.CustomPresentationItem then
    self.CustomPresentationItem:CloseSelf()
    self.CustomPresentationItem = nil
  end
  local custom_presentation_util = require("client.slua.logic.person_space.custom_presentation_util")
  local cpData = custom_presentation_util.GetDataByUID(self.uid)
  if not cpData then
    log(bWriteLog and "Lobby_RoleInfo_Card_Show_UIBP:UpdateCustomPresentation. cpData is nil for uid:" .. tostring(self.uid))
    return
  end
  self.CustomPresentationItem = self:CreateChildWindow(self.UIRoot.Overlay_CustomPresentation, UIManager.UI_Config.LobbyChat_InformationCustomDetail_UIBP)
  self.CustomPresentationItem:SetDataByUid(self.uid)
  self.CustomPresentationItem:SetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CLobby_RoleInfo_Card_Show_UIBP = class(ui_base, nil, Lobby_RoleInfo_Card_Show_UIBP)
return CLobby_RoleInfo_Card_Show_UIBP