local BirthIslandTips = {}
local FSlateBrush = import("SlateBrush")
local EGameModeType = import("EGameModeType")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local EsportGameModeIDList = require("GameLua.Mod.BaseMod.GamePlay.Config.EsportGameModeConfig")
function BirthIslandTips:ctor()
end
function BirthIslandTips:SetNewbieGameTip(InText)
  self.UIRoot.NewbieGameTip:SetText(InText)
end
function BirthIslandTips:BeginShowTips()
  BirthIslandTips.__super.BeginShowTips(self)
  if self.UIRoot.VeteranRecruitPanel and self.UIRoot.VeteranRecruitPanel then
    self.UIRoot.VeteranRecruitPanel:BeginShowTips()
  end
end
function BirthIslandTips:OnInitialize()
  BirthIslandTips.__super.OnInitialize(self)
  self.AutoFollowTipsDelayShowWaitingTime = 1.5
  self.AutoFollowTipsLastTime = 5
  self.IsShowingCountDown = false
  self.bHasPostCountDownEvent = false
  self.bHasPlayBattleSound = false
  self.DelayToShowLeaderMarkMapTipsTime = 5
  self:Collapsed()
end
function BirthIslandTips:RegistEvents()
  BirthIslandTips.__super.RegistEvents(self)
  self:AddUIMessageEvent("UIMsg_ShowVeteranRecruitParachuteTeamTip", self.UIMsg_ShowVeteranRecruitParachuteTeamTip, self)
  self:AddUIMessageEvent("UIMsg_ShowAutoGroupParachuteTeamTip", self.UIMsg_ShowAutoGroupParachuteTeamTip, self)
  self:AddUIMessageEvent("ShowEscapeNotice", self.ShowEscapeNotice, self)
  self:AddUIMessageEvent("ED_GameReplayReint", self.BindGameStartCountDown, self)
  self:BindGameStartCountDown()
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, self.CheckGameState, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_PARACHUTING, EVENTID_PARACHUTING_LEAVE_PLANE, self.CheckGameState, self)
end
function BirthIslandTips:OnPostInitialize()
  BirthIslandTips.__super.OnPostInitialize(self)
  self:CheckGameState()
end
function BirthIslandTips:CheckGameState()
  local uGameState = GameplayData.GetGameState()
  if slua.isValid(uGameState) then
    local ShouldCloseUI = false
    if uGameState:GetGameModeState() ~= "ReadyState" then
      ShouldCloseUI = true
    end
    local GameModeType = uGameState.GameModeType or 0
    if GameModeType == EGameModeType.ETypicalGameMode or uGameState.GameModeType == EGameModeType.EFourInOneGameMode then
      local PlayerController = GameplayData.GetPlayerController()
      if slua.isValid(PlayerController) and (ShouldCloseUI == false or PlayerController:IsInNormalPlane()) and PlayerController:IsTeammateExitTeamBeforeBoarding() then
        ShouldCloseUI = false
        self:ShowEscapeNotice()
        if self.UIRoot and self.UIRoot.TextBlock_WaitingTips then
          self.UIRoot.TextBlock_WaitingTips:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
        end
        print(bWriteLog and "BirthIslandTips:CheckGameState _bIsTeammateExitTeamBeforeBoarding ShowEscapeNotice")
      end
    end
    if ShouldCloseUI then
      self:CloseSelf()
    end
  end
end
function BirthIslandTips:DelayShowAutoParachuteTip(inputType)
  local UIRoot = self.UIRoot
  self:AddTimer(self.AutoFollowTipsDelayShowWaitingTime, function()
    UIRoot.CanvasPanel_AutoFollowSystemTipsSlot:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    UIRoot.Overlay_Teammate:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    if inputType == 0 or inputType == 2 then
      UIRoot.UTRichTextBlock_AutoFollow:SetText(LocUtil.LocalizeResFormat(30177))
    else
      UIRoot.UTRichTextBlock_AutoFollow:SetText(LocUtil.LocalizeResFormat(30176))
    end
    self:HideAutoFollowTips(inputType)
  end)
end
function BirthIslandTips:HideAutoFollowTips(inputType)
  self:AddTimer(self.AutoFollowTipsLastTime, function()
    self.UIRoot.CanvasPanel_AutoFollowSystemTipsSlot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self:ShowSettingTips(inputType)
  end)
end
function BirthIslandTips:ShowSettingTips(inputType)
  self:AddTimer(1.0, function()
    local AsGameFrontendHUD = self.UIRoot:GetOwningFrontendHUD()
    local UserSettings = AsGameFrontendHUD:GetUserSettings()
    local UIRoot = self.UIRoot
    if UserSettings.FirstTime_ShowAutoGroupParachute then
      UserSettings.FirstTime_ShowAutoGroupParachute = false
      AsGameFrontendHUD:FinishModifyUserSettings()
      UIRoot.CanvasPanel_AutoFollowSystemTipsSlot:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      UIRoot.Overlay_Teammate:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      UIRoot.UTRichTextBlock_AutoFollow:SetText(LocUtil.LocalizeResFormat(30200))
      self:AddTimer(5.0, function()
        UIRoot.CanvasPanel_AutoFollowSystemTipsSlot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
        self:AutoFollowTips(inputType)
      end)
    end
  end)
end
function BirthIslandTips:AutoFollowTips(inputType)
  if inputType == 2 then
    local uPlayerController = GameplayData.GetPlayerController()
    if Game:IsValid(uPlayerController) then
      local uPlayerState = uPlayerController.PlayerState
      if Game:IsValid(uPlayerState) and uPlayerState.MapMark.X <= 0.0 and 0.0 >= uPlayerState.MapMark.Y then
        self:AddTimer(self.DelayToShowLeaderMarkMapTipsTime, function()
          local UIRoot = self.UIRoot
          UIRoot.CanvasPanel_AutoFollowSystemTipsSlot:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
          UIRoot.Overlay_Teammate:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
          UIRoot.UTRichTextBlock_AutoFollow:SetText(LocUtil.LocalizeResFormat(34332))
          self:AddTimer(5.0, function()
            UIRoot.CanvasPanel_AutoFollowSystemTipsSlot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
          end)
        end)
      end
    end
  end
end
function BirthIslandTips:DelayShowVeteranRecruitParachuteTeamTips(TipsID, param1, param2)
  self:AddTimer(self.AutoFollowTipsDelayShowWaitingTime, function()
    local UIRoot = self.UIRoot
    UIRoot.Overlay_Teammate:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    UIRoot.CanvasPanel_AutoFollowSystemTipsSlot:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    UIRoot.UTRichTextBlock_AutoFollow:SetText(LocUtil.LocalizeResFormat(TipsID, param1, param2))
    self:AddTimer(self.AutoFollowTipsLastTime, function()
      UIRoot.CanvasPanel_AutoFollowSystemTipsSlot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end)
  end)
end
function BirthIslandTips:BindGameStartCountDown()
  GameplayData.AddSelfPlayerControllerEvent(self, "OnGameStartCountDownDelegate", self.GameStartCountDown, self)
  self.bHasPostCountDownEvent = false
  self.bHasPlayBattleSound = false
end
function BirthIslandTips:UIMsg_ShowAutoGroupParachuteTeamTip(inputType)
  self:DelayShowAutoParachuteTip(inputType)
end
function BirthIslandTips:UIMsg_ShowVeteranRecruitParachuteTeamTip(TipsID, param1, param2)
  self:DelayShowVeteranRecruitParachuteTeamTips(TipsID, param1, param2)
end
function BirthIslandTips:GameStartCountDown(CountDownTime)
  local uGameState = GameplayData.GetGameState()
  local uPlayerController = GameplayData.GetPlayerController()
  print(bWriteLog and "BirthIslandTips:GameStartCountDown CountDownTime", CountDownTime)
  if not Game:IsValid(uPlayerController) then
    return
  end
  if uPlayerController:IsFriendObserver() and uPlayerController.bIsWatchEnd then
    self:ShowCountDown(false)
    print(bWriteLog and "BirthIslandTips:GameStartCountDown IsFriendObserver")
    return
  end
  if uPlayerController.IsDemoPlaySpectator and uPlayerController:IsDemoPlaySpectator() then
    self:ShowCountDown(false)
    print(bWriteLog and "BirthIslandTips:GameStartCountDown IsDemoPlaySpectator")
    return
  end
  if CountDownTime < 0 then
    self:ShowCountDown(false)
    return
  end
  self:ShowCountDown(true)
  if Game:IsValid(uGameState) then
    local UIRoot = self.UIRoot
    if uGameState.GameModeType == EGameModeType.EVehicleWar or uGameState.GameModeType == EGameModeType.EVehicleWar_CAMP then
      UIRoot.UTRichTextMatchStartTime:SetText(LocUtil.LocalizeResFormat(930037, ToInt(CountDownTime)))
      UIRoot.UTRichTextMatchStartTime:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
    elseif uPlayerController:IsRoomMode() and self:IsLeagueMode(uGameState.GameModeID) and RoomSystem.CurrentRoomInfo.room_type == "match" and not uGameState.MatchReadyConfirmed then
      UIRoot.UTRichTextMatchStartTime:SetText(LocUtil.LocalizeResFormat(48969, ToInt(CountDownTime)))
      UIRoot.UTRichTextMatchStartTime:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
    else
      UIRoot.UTRichTextMatchStartTime:SetText(LocUtil.LocalizeResFormat(6409, ToInt(CountDownTime)))
      UIRoot.UTRichTextMatchStartTime:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
    end
    if uGameState.GameModeType ~= EGameModeType.EDeathMatchGameMode then
      if not self.bHasPlayBattleSound and CountDownTime <= 9.0 and 5.0 < CountDownTime then
        self.bHasPlayBattleSound = true
        uPlayerController:PlayBattleSoundInBP(1002)
      end
      if not self.bHasPostCountDownEvent and CountDownTime <= 5.0 and 0.0 < CountDownTime then
        self.bHasPostCountDownEvent = true
        local audio_util = require("client.common.audio_util")
        audio_util.PlayAudioAsync("/Game/WwiseEvent/UI_hall/Play_UI_hall_CountDown.Play_UI_hall_CountDown")
      end
    end
  end
end
function BirthIslandTips:ShowCountDown(Show)
  if Show ~= self.IsShowingCountDown then
    self.IsShowingCountDown = Show
    if self.IsShowingCountDown then
      self.UIRoot.Root:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      self.UIRoot.TextBlock_WaitingTips:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      local uGameState = GameplayData.GetGameState()
      if Game:IsValid(uGameState) and uGameState.GameModeType == EGameModeType.EDeathMatchGameMode then
        self:Collapsed()
      end
    else
      self.UIRoot.CountdownPanel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end
end
function BirthIslandTips:ShowEscapeNotice()
  local UIRoot = self.UIRoot
  local uGameState = GameplayData.GetGameState()
  local PlayerController = GameplayData.GetPlayerController()
  if not Game:IsValid(uGameState) or not Game:IsValid(PlayerController) then
    return
  end
  if (uGameState.GameModeType == EGameModeType.ETypicalGameMode or uGameState.GameModeType == EGameModeType.EFourInOneGameMode) and (uGameState:GetGameModeState() == "ReadyState" or PlayerController:IsInNormalPlane()) then
    local uPlayerController = GameplayData.GetPlayerController()
    if not Game:IsValid(uPlayerController) then
      if not self:IsLeagueMode(uGameState.GameModeID) then
        UIRoot.CanvasPanelEscapeNotice:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        UIRoot.UTRichTextBlock_0:SetText(LocUtil.LocalizeResFormat(46095))
        UIRoot:ForceLayoutPrepass()
        UIRoot:InvalidateLayoutAndVolatility()
      end
      return
    end
    if not uPlayerController:IsRoomMode() and not self:IsLeagueMode(uGameState.GameModeID) then
      UIRoot.CanvasPanelEscapeNotice:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      UIRoot.UTRichTextBlock_0:SetText(LocUtil.LocalizeResFormat(46095))
      UIRoot:ForceLayoutPrepass()
      UIRoot:InvalidateLayoutAndVolatility()
    end
  end
end
function BirthIslandTips:IsLeagueMode(sGameModeID)
  if EsportGameModeIDList and EsportGameModeIDList[sGameModeID] then
    return true
  else
    return false
  end
end
function BirthIslandTips:HideEscapeNotice()
end
function BirthIslandTips:SetCaptainText(Text, Number, Color)
  local UIRoot = self.UIRoot
  if not slua.isValid(UIRoot) then
    return
  end
  local Brush = FSlateBrush()
  if Text and Number and Color then
    UIRoot.Overlay_Teammate:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
    UIRoot.CanvasPanel_AutoFollowSystemTipsSlot:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    UIRoot.UTRichTextBlock_AutoFollow:SetText(Text)
    UIRoot.TextBlock_TeamIdx:SetText(tostring(Number))
    UIRoot.Image_TeammateBG:SetColorAndOpacity(Color)
    Brush.ImageSize = FVector2D(20, 20)
    self:AddGameTimer(5, false, function()
      UIRoot.Overlay_Teammate:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      UIRoot.CanvasPanel_AutoFollowSystemTipsSlot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      UIRoot.TextBlock_TeamIdx:SetText("")
      UIRoot.UTRichTextBlock_AutoFollow:SetText("")
      UIRoot.Image_TeammateBG:SetColorAndOpacity(FLinearColor(0, 0, 0, 0))
      Brush.ImageSize = FVector2D(0, 0)
    end)
  else
    UIRoot.CanvasPanel_AutoFollowSystemTipsSlot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    UIRoot.Overlay_Teammate:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    UIRoot.TextBlock_TeamIdx:SetText("")
    UIRoot.UTRichTextBlock_AutoFollow:SetText("")
    UIRoot.Image_TeammateBG:SetColorAndOpacity(FLinearColor(0, 0, 0, 0))
    Brush.ImageSize = FVector2D(0, 0)
  end
  UIRoot.Image_TeammateBG:SetBrush(Brush)
end
local class = require("class")
local UIBase = require("GameLua.Mod.BaseMod.Client.DynamicMountUIBase")
return class(UIBase, nil, BirthIslandTips)