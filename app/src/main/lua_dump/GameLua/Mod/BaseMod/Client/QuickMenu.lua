local STExtraUIUtils = import("STExtraUIUtils")
local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
local QuickMenu = {}
function QuickMenu:ctor()
  self.MsgMap = nil
end
function QuickMenu:OnInitialize()
  QuickMenu.__super.OnInitialize(self)
  print(bWriteLog and "QuickMenu:OnInitialize")
  local GameplayStatics = import("GameplayStatics")
  self.platformID = GameplayStatics.GetPlatformInt()
  self.bSendToGlobal = false
  self.bSendToCamp = false
  self.TeamText = LocUtil.GetLocalizeResStr(8500052)
  self.GlobalText = LocUtil.GetLocalizeResStr(8100002)
  self.CampText = LocUtil.GetLocalizeResStr(8205703)
  self.UIRoot.TextBlock_Lock:SetText(LocUtil.GetLocalizeResStr(200000091))
  self:InitSpeechToTextEntrance()
  self:OnRefreshForbidCustomChat()
  local SuperData = GameplayData.GetSuperData()
  self:AddDataListener(SuperData, "CharacterDataReady", function()
    self:CheckSupportCampChat()
    self:CheckGlobalChat()
  end)
  if self.platformID ~= 6 then
    self.UIRoot.Button_sendfriend:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.Button_Teamsend:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function QuickMenu:InitSpeechToTextEntrance()
  local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
  local bEURestricted = logic_chat_voice:CheckEUChatRestriction()
  if not bEURestricted then
    self.UIRoot.Button_SpeechToText:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  else
    self.UIRoot.Button_SpeechToText:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  self:SetDisturbCheck()
end
function QuickMenu:RegistEvents()
  QuickMenu.__super.RegistEvents(self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnRepPlayerState", self.OnRepPlayerState, self)
  self:AddUIMessageEvent("UIMsg_ReceiveFriendInvite", self.OnReceiveFriendInvite, self)
  self:AddUIMessageEvent("UIMsg_AddOneMsgtoUIInner", self.OnAddOneMsgtoUIInner, self)
  self:AddUIMessageEvent("UIMsg_AddFriendChat", self.OnAddFriendChat, self)
  self:AddUIMessageEvent("UIMsg_NotifyFriendInvite", self.OnNotifyFriendInvite, self)
  self:AddUIMessageEvent("UIMsg_NotifyFriendReply", self.OnNotifyFriendReply, self)
  self:AddUIMessageEvent("UIMsg_NotifyAppointmentChange", self.SetDisturbCheck, self)
  self:AddUIMessageEvent("UIMsg_NotifyAddFriendRequestIngame", self.OnAddFriendReq, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_SpeechToText, self.InitSpeechToText, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Watching, self.OnWatchingClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_sendfriend, self.OnSendFriendClicked, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_PetWatchting, self.SetPetSpectatingSetting, self)
  self:AddControlEventByControl(self.UIRoot.friendChatMsg, "OnTextCommitted", self.OnFrindChatMsgCommited, self)
  self:AddControlEventByControl(self.UIRoot.friendChatMsg, "OnTextChanged", self.OnFriendChatMsgChanged, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Teamsend, self.OnSendTeamClicked, self)
  self:AddControlEventByControl(self.UIRoot.inputText, "OnTextCommitted", self.OnInputTextCommited, self)
  self:AddControlEventByControl(self.UIRoot.inputText, "OnTextChanged", self.OnInputTextChanged, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_ChangeChannel, self.OnChangeChannelBtnClick, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_REFRESH_FORBID_CUSTOM_CHAT, self.OnRefreshForbidCustomChat, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_REFRESH_GLOBAL_CHAT, self.OnRefreshGlobalChat, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_ON_PAWN_CAMP_CHANGED, self.OnPlayerCampChanged, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_REFRESH_CAMP_CHAT, self.RefreshCampChat, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVNETID_INGAME_CLEAN_CHAT_MSG, self.ClearMsg, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_REFRESH_CHAT, self.HandleOnAddOneMark, self)
  self:RegistSetting()
end
function QuickMenu:OnShow()
  local UIUtil = require("client.common.ui_util")
  UIUtil.SetAdaptiveLayout(self.UIRoot, UEnums.EAdaptiveLayout.Outside, nil, -10)
  EventSystem:postEvent(EVENTTYPE_INGAME_UI, EVENTID_NEW_EXPANDPANEL_MUTEX)
  self:InitQuickMsg()
  self.UIRoot:PlayUserWidgetAnimation(self.UIRoot.Anim_open, 0, 1, 0, 1)
end
function QuickMenu:OnHide()
end
function QuickMenu:RegistSetting()
  local SettingSubsystem = SubsystemMgr:Get("SettingSubsystem")
  if not SettingSubsystem then
    return
  end
  local SpectatingPetVisible = SettingSubsystem:GetUserSettings_Bool("bSpectatingPetVisible")
  if SpectatingPetVisible then
    self.UIRoot.WidgetSwitcher_PetSpectating:SetActiveWidgetIndex(0)
  else
    self.UIRoot.WidgetSwitcher_PetSpectating:SetActiveWidgetIndex(1)
  end
  SettingSubsystem:RegisterUserSettingsDelegate_Bool("bSpectatingPetVisible", function(bSpectatingPetVisible)
    if bSpectatingPetVisible then
      self.UIRoot.WidgetSwitcher_PetSpectating:SetActiveWidgetIndex(0)
    else
      self.UIRoot.WidgetSwitcher_PetSpectating:SetActiveWidgetIndex(1)
    end
  end)
end
function QuickMenu:HideWithAnim()
  self.UIRoot:PlayUserWidgetAnimation(self.UIRoot.Anim_close, 0, 1, 0, 1)
  self:SelfHitTestInvisible()
  self:AddGameTimer(0.15, false, function()
    self:Collapsed()
  end)
end
function QuickMenu:OnRepPlayerState()
  self:SelectOpt(0)
  self.UIRoot.Reddot_Anchor_Item01:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot:ShowAllUnRead()
end
function QuickMenu:HandleOnAddOneMark()
  if slua.isValid(self.UIRoot) then
    self.UIRoot:HandleOnAddOneMark()
  end
end
function QuickMenu:SetPetSpectatingSetting()
  local SettingSubsystem = SubsystemMgr:Get("SettingSubsystem")
  if not SettingSubsystem then
    return
  end
  local SpectatingPetVisible = SettingSubsystem:GetUserSettings_Bool("bSpectatingPetVisible")
  local LogicSettingBasic = require("client.slua.logic.setting.logic_setting_basic")
  LogicSettingBasic.SetOneSettingValue("bSpectatingPetVisible", not SpectatingPetVisible)
  slua_GameFrontendHUD:FinishModifyUserSettings()
end
function QuickMenu:OnReceiveFriendInvite(_, GID, Name)
  self.UIRoot:ReceiveFriendInvite(GID, Name)
end
function QuickMenu:OnAddFriendReq(_, UID)
  local team_mates
  local uPlayerState = GameplayData.GetPlayerState()
  if slua.isValid(uPlayerState) then
    team_mates = uPlayerState:GetTeamMatePlayerStateList({}, true)
  end
  if not team_mates then
    return
  end
  local data
  for k, v in pairs(team_mates) do
    if v and v.UID == UID then
      data = v
      break
    end
  end
  if not data then
    return
  end
  self.UIRoot:AddFriendRequest(tostring(UID), data.PlayerName)
end
function QuickMenu:OnAddOneMsgtoUIInner()
  local PC = GameplayData.GetPlayerController()
  local ChatComponent = STExtraBlueprintFunctionLibrary.GetChatComponentFromController(PC)
  local QuickSignComponent = STExtraBlueprintFunctionLibrary.GetQuickSignComponentFromController(PC)
  if not slua.isValid(ChatComponent) or not slua.isValid(QuickSignComponent) then
    return
  end
  self.UIRoot:AddChatToHistory(ChatComponent.addToUIText, ChatComponent.IsMe, QuickSignComponent.currMsg, ChatComponent.CurrMsg)
end
function QuickMenu:OnAddFriendChat()
  local Character = GameplayData.GetPlayerCharacter()
  if not slua.isValid(Character) then
    return
  end
  local ChatComponent = STExtraBlueprintFunctionLibrary.GetChatComponentFromCharacter(Character)
  if not slua.isValid(ChatComponent) then
    return
  end
  self.UIRoot:AddFriendChat(ChatComponent.FriendChatStrGid, ChatComponent.FriendChatSenderName, ChatComponent.FriendChatContent, ChatComponent.FriendChatSelfMsg, 0, false)
end
local addChatTemp = 0
function QuickMenu:OnNotifyFriendInvite()
  local Character = GameplayData.GetPlayerCharacter()
  if not slua.isValid(Character) then
    return
  end
  local ChatComponent = STExtraBlueprintFunctionLibrary.GetChatComponentFromCharacter(Character)
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  if serverTime - addChatTemp < 30 then
    return
  end
  if not slua.isValid(ChatComponent) then
    return
  end
  self.UIRoot:AddFriendChat(ChatComponent.FriendInviteStrGid, ChatComponent.FriendInviteSenderName, ChatComponent.FriendInviteBattleTextValue, false, 2, false)
  addChatTemp = serverTime
end
function QuickMenu:OnNotifyFriendReply()
  local Character = GameplayData.GetPlayerCharacter()
  if not slua.isValid(Character) then
    return
  end
  local ChatComponent = STExtraBlueprintFunctionLibrary.GetChatComponentFromCharacter(Character)
  if not slua.isValid(ChatComponent) then
    return
  end
  local Content = LocUtil.GetLocalizeResStr(30060)
  self.UIRoot:AddFriendChat(ChatComponent.FriendReplyStrGid, ChatComponent.FriendReplySenderName, Content, false, 3, ChatComponent.FriendReplyReply)
end
function QuickMenu:InitQuickMsg()
  if not self.UIRoot then
    return
  end
  self:InitMsgCacheMap()
  self.UIRoot:InitSpectatorTabPage()
  self.UIRoot:RefreshSpectatorTabPage()
  if self.ScrollTimer then
    self:RemoveGameTimer(self.ScrollTimer)
  end
  self.ScrollTimer = self:AddGameTimer(0.03, false, function()
    self.UIRoot.ScrollBoxHistory:ScrolltoEnd()
    self.ScrollTimer = nil
  end)
  if self.UIRoot.bInit then
    return
  end
  self.UIRoot.bInit = true
  self:RefreshQuickChatScroll()
end
function QuickMenu:SelectOpt(InType)
  self.UIRoot:SelectOpt(InType)
end
function QuickMenu:EnableMsgToReset()
  if not self.UIRoot then
    return
  end
  self.UIRoot:EnableMsgToReset()
end
function QuickMenu:InitSpeechToText()
  local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
  logic_chat_voice:RequestPrivacy(function()
    EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_OPEN_HIDE_SPEECH_TO_TEXT, true)
  end)
  local ClientTLogUtil = require("GameLua.Mod.BaseMod.Client.ClientTLog.ClientTLogUtil")
  ClientTLogUtil.ReportGeneralCountByBRPhase(12018, 12018)
end
function QuickMenu:SetDisturbCheck()
  local logic_friend_reserve = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_reserve)
  if logic_friend_reserve and logic_friend_reserve.IsSingleGameReserveOpen then
    local ischeck = logic_friend_reserve:IsSingleGameReserveOpen()
    self.UIRoot.CheckBox_disturb:SetIsChecked(not ischeck)
  end
end
function QuickMenu:InitMsgCacheMap()
  if self.MsgMap ~= nil then
    return
  end
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return
  end
  local uChatComponent = STExtraBlueprintFunctionLibrary.GetChatComponentFromController(uPlayerController)
  if not slua.isValid(uChatComponent) then
    return
  end
  self.MsgMap = {}
  local ChatQuickList = uChatComponent.chatQuickList
  for _, ChatQuick in pairs(ChatQuickList) do
    if ChatQuick.ChatTextID ~= 0 then
      local TextID = ChatQuick.RealTextID
      local MsgID = ChatQuick.ChatTextID
      local EnglishMsgID = MsgID % 100000
      if self.MsgMap[EnglishMsgID] == nil then
        self.MsgMap[EnglishMsgID] = {ChatTextID = MsgID, RealTextID = TextID}
      end
    end
  end
end
function QuickMenu:RefreshQuickChatScroll()
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return
  end
  local uChatComponent = STExtraBlueprintFunctionLibrary.GetChatComponentFromController(uPlayerController)
  if not slua.isValid(uChatComponent) then
    return
  end
  local CurIndex = 0
  local SpecialChatMap = uChatComponent.SpecialChatMap
  local bHasSpChat = false
  for SpecialChatID, _ in pairs(SpecialChatMap) do
    if SpecialChatID ~= 0 then
      if self.MsgMap[SpecialChatID] == nil then
        self.MsgMap[SpecialChatID] = {ChatTextID = SpecialChatID, RealTextID = SpecialChatID}
      end
      local ExtraChat = self.MsgMap[SpecialChatID]
      self:SetChatScrollItem(CurIndex, ExtraChat, true)
      CurIndex = CurIndex + 1
      bHasSpChat = true
    end
  end
  local ChatQuickList = uChatComponent.chatQuickList
  for _, ChatQuick in pairs(ChatQuickList) do
    if ChatQuick.ChatTextID ~= 0 then
      local EnglishMsgID = ChatQuick.ChatTextID % 100000
      if not SpecialChatMap[EnglishMsgID] then
        self:SetChatScrollItem(CurIndex, ChatQuick, false)
        CurIndex = CurIndex + 1
      end
    end
  end
  if CurIndex < self.UIRoot.ScrollBox_Quick:GetChildrenCount() then
    for i = CurIndex, self.UIRoot.ScrollBox_Quick:GetChildrenCount() - 1 do
      self.UIRoot.ScrollBox_Quick:GetChildAt(i):SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    end
  end
  if bHasSpChat then
    self.UIRoot.ScrollBox_Quick:ScrollToStart()
  end
end
function QuickMenu:SetChatScrollItem(Index, ChatItem, bIsTopChat)
  local MsgID = ChatItem.ChatTextID
  local RealTextID = ChatItem.RealTextID
  local ActorId = math.floor(MsgID / 100000)
  local ActorName = self.UIRoot:GetActorNameByID(ActorId)
  local VoiceText = CDataTable.GetTableData("VoiceText", RealTextID)
  local Text
  if VoiceText then
    Text = VoiceText.VoiceTextValue
  else
    Text = LocUtil.GetLocalizeResStr(RealTextID)
  end
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local bIsBankExist = PufferManager.IsBankExistByActorID(ActorId)
  local ChatTextStr
  local RichTextTitle = "<ChatQuickMsg>"
  if bIsTopChat then
    RichTextTitle = "<QuickPhrases>"
  end
  if ActorId == 0 then
    ChatTextStr = RichTextTitle .. Text .. "</>"
  elseif not bIsBankExist then
    ChatTextStr = RichTextTitle .. Text .. LocUtil.GetLocalizeResStr(44695) .. "</>"
  elseif ActorId == 3900 then
    ChatTextStr = RichTextTitle .. Text .. "</>"
  else
    ChatTextStr = RichTextTitle .. "(" .. ActorName .. ")" .. Text .. "</>"
  end
  local QuickTextBP
  if Index < self.UIRoot.ScrollBox_Quick:GetChildrenCount() then
    QuickTextBP = self.UIRoot.ScrollBox_Quick:GetChildAt(Index)
  else
    QuickTextBP = slua.loadUI("/Game/BluePrints/ControlInput/IngameUI/QuickText_BP.QuickText_BP")
    self.UIRoot.ScrollBox_Quick:AddChild(QuickTextBP)
  end
  QuickTextBP.RichTextBlock:SetText(ChatTextStr)
  QuickTextBP.QuickSend = true
  QuickTextBP.  QuickTextBP.MsgType = 1
  QuickTextBP.  QuickTextBP:SetTopScale(bIsTopChat)
  QuickTextBP:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
end
function QuickMenu:OnWatchingClick()
  self:SelectOpt(3)
  self.UIRoot:RefreshSpectatorTabPage()
  local Player = GameplayData.GetPlayerController()
  local ASTExtraPlayerController = import("/Script/ShadowTrackerExtra.STExtraPlayerController")
end
function QuickMenu:OnRefreshForbidCustomChat()
  local Character = GameplayData.GetPlayerCharacter()
  if not slua.isValid(Character) then
    return
  end
  local ChatComponent = STExtraBlueprintFunctionLibrary.GetChatComponentFromCharacter(Character)
  if not slua.isValid(ChatComponent) then
    return
  end
  local bIsForbidCustomChat = ChatComponent:GetIsForbidCustomChat()
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  local bIsLockChat = QRcodeRestrictManager:IsRestrictChat()
  if bIsForbidCustomChat or bIsLockChat then
    self.UIRoot.WidgetSwitcher_Friends:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    self.UIRoot.ButtonFriends:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
  else
    self.UIRoot.WidgetSwitcher_Friends:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
    self.UIRoot.ButtonFriends:SetWidgetVisibility(UEnums.GSlateVisibility.Visible)
  end
  if bIsLockChat then
    self.UIRoot.CanvasPanel_Forbid:SetWidgetVisibility(UEnums.GSlateVisibility.HitTestInvisible)
  else
    self.UIRoot.CanvasPanel_Forbid:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
  end
  self.UIRoot.bForbidCustomChat = bIsForbidCustomChat or bIsLockChat
end
function QuickMenu:OnFriendChatMsgChanged(Text)
  local platformID = self:GetPlatform()
  if platformID ~= 5 then
    return
  end
  self:SendFriendChat(Text)
end
function QuickMenu:OnFrindChatMsgCommited(Text, CommitMethod)
  if CommitMethod ~= 1 then
    return
  end
  local platformID = self:GetPlatform()
  if platformID ~= 6 then
    return
  end
  self:SendFriendChat(Text)
end
function QuickMenu:OnSendFriendClicked()
  local ChatText = self.UIRoot.friendChatMsg:GetText()
  self:SendFriendChat(ChatText)
end
function QuickMenu:SendFriendChat(Text)
  local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
  local EUChatRestriction, status = logic_chat_voice:CheckEUChatRestriction()
  if EUChatRestriction then
    print(bWriteLog and "QuickMenu:SendFriendChat Failed Case EUChatRestriction")
    IngameTipsTools.BattleNormalTipsByTextID(46880037)
    return
  end
  local kismet_string_library = require("common.kismet_string_library")
  local TextLength = kismet_string_library.Len(Text)
  if TextLength <= 0 then
    return
  end
  local chatString = Text
  if 32 < TextLength then
    local StringUtil = require("common.string_util")
    chatString = StringUtil.SubString(Text, 1, 32)
    IngameTipsTools.BattleNormalTipsByTextID(30065)
  end
  print(bWriteLog and "QuickMenu:SendFriendChat " .. chatString .. "   GUID: " .. self.UIRoot.currFriendGid)
  EventSendFightChat(self.UIRoot.currFriendGid, chatString)
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if MainControlBaseUI then
    MainControlBaseUI:HideQuickChatMenu()
  end
  self.UIRoot.friendChatMsg:SetText("")
end
function QuickMenu:OnInputTextChanged(Text)
  local platformID = self:GetPlatform()
  if platformID ~= 5 then
    return
  end
  self:SendTeamChat(Text)
end
function QuickMenu:OnInputTextCommited(Text, CommitMethod)
  if CommitMethod == 3 then
    local WidgetBlueprintLibrary = import("WidgetBlueprintLibrary")
    WidgetBlueprintLibrary.SetFocusToGameViewport()
  end
  if CommitMethod ~= 1 then
    return
  end
  local platformID = self:GetPlatform()
  if platformID ~= 6 and platformID ~= 1 then
    return
  end
  self:SendTeamChat(Text)
end
function QuickMenu:OnSendTeamClicked()
  local ChatText = self.UIRoot.inputText:GetText()
  self:SendTeamChat(ChatText)
end
function QuickMenu:SendTeamChat(Text)
  local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
  local EUChatRestriction, status = logic_chat_voice:CheckEUChatRestriction()
  if EUChatRestriction then
    print(bWriteLog and "QuickMenu:SendTeamChat Failed Case EUChatRestriction")
    IngameTipsTools.BattleNormalTipsByTextID(46880037)
    return
  end
  local kismet_string_library = require("common.kismet_string_library")
  local TextLength = kismet_string_library.Len(Text)
  if TextLength <= 0 then
    return
  end
  local chatString = Text
  if 32 < TextLength then
    local StringUtil = require("common.string_util")
    chatString = StringUtil.SubString(Text, 1, 32)
    IngameTipsTools.BattleNormalTipsByTextID(30065)
  end
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return
  end
  local uChatComponent = STExtraBlueprintFunctionLibrary.GetChatComponentFromController(uPlayerController)
  if self.bSendToGlobal then
    if slua.isValid(uChatComponent) then
      uChatComponent:SendToAllPlayer(chatString)
    end
  elseif self.bSendToCamp then
    if slua.isValid(uChatComponent) then
      uChatComponent:SendToSameCamp(chatString)
    end
  else
    uPlayerController:SendStringMsg(chatString, 0, 0, "", 0, 0, true)
  end
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if not MainControlBaseUI then
    return
  end
  MainControlBaseUI:HideQuickChatMenu()
  self.UIRoot.inputText:SetText("")
  if not slua.isValid(uChatComponent) then
    return
  end
  MainControlBaseUI:StartChatBarAnima(uChatComponent.SendMsgCD)
end
function QuickMenu:GetPlatform()
  if self.platformID then
    return self.platformID
  end
  local GameplayStatics = import("GameplayStatics")
  self.platformID = GameplayStatics.GetPlatformInt()
  return self.platformID
end
function QuickMenu:OnChangeChannelBtnClick()
  local VoiceChatSubsystem = SubsystemMgr:Get("VoiceChatSubsystem")
  if not VoiceChatSubsystem then
    return
  end
  local bIsFuncOpen = VoiceChatSubsystem:CheckGlobalChatOpen()
  if not bIsFuncOpen then
    self.bSendToGlobal = false
    if self.bCanCampChat then
      if not self.bSendToCamp then
        self.bSendToCamp = true
        self.UIRoot.TextBlock_team:SetText(self.CampText)
      else
        self.bSendToCamp = false
        self.UIRoot.TextBlock_team:SetText(self.TeamText)
      end
      self.UIRoot.Button_ChangeChannel:SetWidgetVisibility(UEnums.GSlateVisibility.Visible)
    else
      self.bSendToCamp = false
      self.UIRoot.TextBlock_team:SetText(self.TeamText)
      self.UIRoot.Button_ChangeChannel:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    end
    return
  end
  if self.bSendToGlobal then
    self.bSendToGlobal = false
    if self.bCanCampChat then
      self.bSendToCamp = true
      self.UIRoot.TextBlock_team:SetText(self.CampText)
    else
      self.bSendToCamp = false
      self.UIRoot.TextBlock_team:SetText(self.TeamText)
    end
  elseif self.bSendToCamp then
    self.bSendToGlobal = false
    self.bSendToCamp = false
    self.UIRoot.TextBlock_team:SetText(self.TeamText)
  else
    self.bSendToGlobal = true
    self.bSendToCamp = false
    self.UIRoot.TextBlock_team:SetText(self.GlobalText)
  end
end
function QuickMenu:CheckGlobalChat()
  local VoiceChatSubsystem = SubsystemMgr:Get("VoiceChatSubsystem")
  if not VoiceChatSubsystem then
    return
  end
  local bIsFuncOpen = VoiceChatSubsystem:CheckGlobalChatOpen()
  if not bIsFuncOpen then
    self.bSendToGlobal = false
    if self.bCanCampChat then
      self.bSendToCamp = true
      self.UIRoot.TextBlock_team:SetText(self.CampText)
      self.UIRoot.Button_ChangeChannel:SetWidgetVisibility(UEnums.GSlateVisibility.Visible)
    else
      self.bSendToCamp = false
      self.UIRoot.TextBlock_team:SetText(self.TeamText)
      self.UIRoot.Button_ChangeChannel:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    end
  else
    self.bSendToGlobal = true
    self.bSendToCamp = false
    self.UIRoot.TextBlock_team:SetText(self.GlobalText)
    self.UIRoot.Button_ChangeChannel:SetWidgetVisibility(UEnums.GSlateVisibility.Visible)
  end
end
function QuickMenu:OnRefreshGlobalChat(_, __, bIsOpen)
  self:CheckSupportCampChat()
  if not bIsOpen then
    self.bSendToGlobal = false
    if self.bCanCampChat then
      self.bSendToCamp = true
      self.UIRoot.TextBlock_team:SetText(self.CampText)
      self.UIRoot.Button_ChangeChannel:SetWidgetVisibility(UEnums.GSlateVisibility.Visible)
    else
      self.bSendToCamp = false
      self.UIRoot.TextBlock_team:SetText(self.TeamText)
      self.UIRoot.Button_ChangeChannel:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    end
  else
    self.bSendToGlobal = true
    self.bSendToCamp = false
    self.UIRoot.TextBlock_team:SetText(self.GlobalText)
    self.UIRoot.Button_ChangeChannel:SetWidgetVisibility(UEnums.GSlateVisibility.Visible)
  end
end
function QuickMenu:CheckSupportCampChat()
  local uPlayerState = GameplayData.GetPlayerState()
  if not slua.isValid(uPlayerState) then
    return
  end
  local CampID = uPlayerState.CampID
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(uPlayerCharacter) or not uPlayerCharacter.CampFeature then
    return
  end
  local bIsEnable = uPlayerCharacter.CampFeature.IsEnabled
  if bIsEnable then
    self.bCanCampChat = CampID and 0 < CampID
  else
    self.bCanCampChat = false
  end
  print(bWriteLog and "QuickMenu:CheckSupportCampChat ", tostring(bIsEnable), "  CampID :  ", tostring(CampID))
end
function QuickMenu:OnPlayerCampChanged(_, _, uPlayerCharacter, newCampID)
  local uMyCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(uPlayerCharacter) and uMyCharacter == uPlayerCharacter then
    print(bWriteLog and "QuickMenu:OnPlayerCampChanged")
    self:CheckSupportCampChat()
    self:CheckGlobalChat()
  end
end
function QuickMenu:RefreshCampChat()
  self:CheckSupportCampChat()
  self:CheckGlobalChat()
end
function QuickMenu:HideShortcutButton()
  print(bWriteLog and "QuickMenu:HideShortcutButton")
  if self.UIRoot then
    self.UIRoot.ButtonShortcut:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function QuickMenu:ClearMsg()
  self.UIRoot.ScrollBoxHistory:ClearChildren()
  if self.UIRoot.QuickTextPool then
    self.UIRoot.QuickTextPool:RecycleAllItems()
    self.UIRoot:InitUIPool()
  end
end
local class = require("class")
local UIBase = require("client.slua_ui_framework.base")
return class(UIBase, nil, QuickMenu)