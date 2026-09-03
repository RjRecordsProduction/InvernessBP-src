local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local ExtraPlayerLiveState = import("ExtraPlayerLiveState")
local HandleStateCanvasUtils = require("GameLua.Mod.BaseMod.Common.UICanvas.HandleStateCanvasUtils")
local AudioConfig = {
  HonorGain = "/Game/Mod/GodTrial/WwiseEvent/GodTrial_HonorPoints_UI_440/Play_GodTrial_HonorPoints_UI_Gain.Play_GodTrial_HonorPoints_UI_Gain",
  HonorFull = "/Game/Mod/GodTrial/WwiseEvent/GodTrial_HonorPoints_UI_440/Play_GodTrial_HonorPoints_UI_No5.Play_GodTrial_HonorPoints_UI_No5",
  RankUp = "/Game/Mod/GodTrial/WwiseEvent/GodTrial_HonorPoints_UI_440/Play_GodTrial_HonorPoints_UI_RankUp.Play_GodTrial_HonorPoints_UI_RankUp",
  RankDown = "/Game/Mod/GodTrial/WwiseEvent/GodTrial_HonorPoints_UI_440/Play_GodTrial_HonorPoints_UI_RankDown.Play_GodTrial_HonorPoints_UI_RankDown",
  NumberChange = "/Game/Mod/GodTrial/WwiseEvent/GodTrial_HonorPoints_UI_440/Play_GodTrial_HonorPoints_UI_NumberChange.Play_GodTrial_HonorPoints_UI_NumberChange",
  SelectionFail = "/Game/Mod/GodTrial/WwiseEvent/GodTrial_HonorPoints_UI_440/Play_GodTrial_HonorPoints_UI_Fail.Play_GodTrial_HonorPoints_UI_Fail",
  SelectionPass = "/Game/Mod/GodTrial/WwiseEvent/GodTrial_HonorPoints_UI_440/Play_GodTrial_HonorPoints_UI_Pass.Play_GodTrial_HonorPoints_UI_Pass"
}
local AnimConfig = {
  ProgressUpdateInterval = 0.1,
  ProgressAnimDuration = 1.0,
  EaseOutPower = 1.7,
  HonorFullAnimDuration = 1.0,
  RankScrollAnimDuration = 0.5,
  SelectionResultAnimDuration = 0.5,
  TipFadeInDuration = 0.5,
  TipFadeOutDuration = 0.5,
  TipAutoHideDelay = 3.0,
  RankUpdateThrottle = 3.0,
  SelectionCompletedCloseDelay = 60.0,
  CloseAnimDuration = 0.5
}
local EAnimType = {
  HonorFull = 1,
  RankUp = 2,
  RankDown = 3,
  SelectionFail = 4
}
local GodTrialHonorPanel = {}
function GodTrialHonorPanel:ctor()
  self.ProgressAnimTimer = nil
  self.AnimStartTime = 0
  self.StartProgressPercent = 0
  self.CurrentProgressPercent = 0
  self.TargetProgressPercent = 0
  self.bHonorGainAudioPlayed = false
  self.bHonorScoreQualified = false
  self.bArenaItemFirstShown = false
  self.bSelectionCompleted = false
  self.bRankQualified = false
  self.LastRank = nil
  self.RankThrottleTimer = nil
  self.PendingRankUpdate = nil
  self.AnimQueue = {}
  self.bIsPlayingAnim = false
  self.AnimTimeoutTimer = nil
  self.bArenaItemVisible = false
  self.ArenaItemFadeTimer = nil
  self.CurrentRank = 0
  self.SelectionCloseTimer = nil
  self.bIsClosingAnim = false
  self.bIsLongPress = false
  self.LongPressThreshold = 0.15
  self.DetailAutoCloseTimer = nil
  self.bIsOnLeft = true
  self.TipCanvasPanel = nil
end
function GodTrialHonorPanel:OnInitialize()
  print(bWriteLog and "GodTrialHonorPanel:OnInitialize")
  GodTrialHonorPanel.__super.OnInitialize(self)
  self:Collapsed()
  local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
  local MapType = GameMainConfig.GetMapType()
  if MapType == "Neon" then
    print(bWriteLog and "GodTrialHonorPanel:OnInitialize - MapType=Neon")
    return
  end
  local uPlayerController = GameplayData.GetPlayerController()
  if not Game:IsValid(uPlayerController) then
    print(bWriteLog and "GodTrialHonorPanel:OnInitialize - uPlayerController is nil")
    return
  end
  if uPlayerController:IsFriendObserver() then
    self:AddGameTimer(0.1, false, function()
      self:CloseSelf()
    end)
    print(bWriteLog and "GodTrialHonorPanel:OnInitialize - uPlayerController is friend observer, return")
    return
  end
  self:AddGameTimer(0.1, false, function()
    self:InitArenaTrialsItemByPosition()
  end)
  self:AddControlEventByControl(self.UIRoot.CustomPanel_HonorPanel, "OnCustomLayoutChangeEvent", self.OnCustomLayoutApplied, self)
  if self.UIRoot.Border_Ranks then
    self.UIRoot.Border_Ranks:SetContentColorAndOpacity(FLinearColor(1.0, 1.0, 1.0, 0))
  end
  self:SetProgressBarPercent(0)
end
function GodTrialHonorPanel:InitArenaTrialsItemByPosition()
  print(bWriteLog and "GodTrialHonorPanel:InitArenaTrialsItemByPosition")
  local bIsOnLeft = self:CalcIsOnLeft()
  self:MountArenaTrialsItem(bIsOnLeft)
end
function GodTrialHonorPanel:CalcIsOnLeft()
  local Slot = self.UIRoot.CustomPanel_HonorPanel.Slot
  if not Slot then
    print(bWriteLog and "GodTrialHonorPanel:CalcIsOnLeft - Slot is nil, fallback to false")
    return false
  end
  local UIUtil = require("client.common.ui_util")
  local ViewportSize = UIUtil.GetViewportSizebyScale()
  local AnchorX = Slot.LayoutData.Anchors.Minimum.X
  local Position = Slot:GetPosition()
  local AbsX = AnchorX * ViewportSize.X + Position.X
  local bIsOnLeft = AbsX < ViewportSize.X * 0.5
  print(bWriteLog and string.format("GodTrialHonorPanel:CalcIsOnLeft - AnchorX=%.2f, PosX=%.1f, AbsX=%.1f, HalfW=%.1f, bIsOnLeft=%s", AnchorX, Position.X, AbsX, ViewportSize.X * 0.5, tostring(bIsOnLeft)))
  return bIsOnLeft
end
function GodTrialHonorPanel:MountArenaTrialsItem(bIsOnLeft)
  local TipCanvasPanel
  if bIsOnLeft then
    TipCanvasPanel = self.UIRoot and self.UIRoot.CanvasPanel_HonorGetTip_Right
  else
    TipCanvasPanel = self.UIRoot and self.UIRoot.CanvasPanel_HonorGetTip
  end
  if not TipCanvasPanel then
    print(bWriteLog and string.format("GodTrialHonorPanel:MountArenaTrialsItem - TipCanvasPanel is nil, bIsOnLeft=%s", tostring(bIsOnLeft)))
    return
  end
  self.  self.  if self.ArenaTrialsItemUI then
    self:AttachChildWindowByControl(self.TipCanvasPanel, self.ArenaTrialsItemUI)
    print(bWriteLog and string.format("GodTrialHonorPanel:MountArenaTrialsItem - remount existing ArenaTrialsItemUI, bIsOnLeft=%s", tostring(bIsOnLeft)))
  else
    self.ArenaTrialsItemUI = self:CreateChildWindow(self.TipCanvasPanel, UIManager.UI_Config_InGame.ArenaTrials_Item, bIsOnLeft)
    print(bWriteLog and string.format("GodTrialHonorPanel:MountArenaTrialsItem - create new ArenaTrialsItemUI, bIsOnLeft=%s", tostring(bIsOnLeft)))
  end
  self.ArenaTrialsItemUI:SetIsOnLeft(bIsOnLeft)
  self.ArenaTrialsItemUI:SetAutoSize(true)
  self.TipCanvasPanel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function GodTrialHonorPanel:OnCustomLayoutApplied()
  print(bWriteLog and "GodTrialHonorPanel:OnCustomLayoutApplied")
  local bNewIsOnLeft = self:CalcIsOnLeft()
  print(bWriteLog and string.format("GodTrialHonorPanel:OnCustomLayoutApplied - bIsOnLeft: %s -> %s", tostring(self.bIsOnLeft), tostring(bNewIsOnLeft)))
  if self.TipCanvasPanel then
    self.TipCanvasPanel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  self.bArenaItemVisible = false
  self:MountArenaTrialsItem(bNewIsOnLeft)
end
function GodTrialHonorPanel:RegistEvents()
  print(bWriteLog and "GodTrialHonorPanel:RegistEvents")
  GodTrialHonorPanel.__super.RegistEvents(self)
  local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
  local MapType = GameMainConfig.GetMapType()
  if MapType == "Neon" then
    print(bWriteLog and "GodTrialHonorPanel:OnInitialize - MapType=Neon")
    return
  end
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, self.OnGameModeStateChange, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_SPECTATING, EVENTID_ENTER_SPECTATING, self.OnEnterSpectating, self)
  self:AddCommonEvent(EVENTTYPE_ACCOUNT, EVENTID_BATTLE_RESULT_ENTER_PROTECT, self.ReceiveBattleResults, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnLiveStateChanged", self.OnLiveStateChanged, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnPlayerQuitSpectatingForClient", self.OnPlayerQuitSpectating, self)
  self:AddControlEventByControl(self.UIRoot.Border_Icon, "OnMouseButtonDownEvent", self.OnMouseButtonDownOnBorder, self)
  self:AddControlEventByControl(self.UIRoot.Border_Icon, "OnMouseButtonUpEvent", self.OnMouseButtonUpOnBorder, self)
  self:AddDataListener(GameplayData.GetSuperData(), "GameDataReady", self.OnGameDataReady, self)
  if self.UIRoot.Anim_Tips_in then
    self:AddControlEventByControl(self.UIRoot.Anim_Tips_in, "OnAnimationFinished", self.OnTipFadeInFinished, self)
  end
  if self.UIRoot.Anim_Tips_out then
    self:AddControlEventByControl(self.UIRoot.Anim_Tips_out, "OnAnimationFinished", self.OnTipFadeOutFinished, self)
  end
  if self.UIRoot.Anim_Rank then
    self:AddControlEventByControl(self.UIRoot.Anim_Rank, "OnAnimationFinished", self.OnHonorFullAnimFinished, self)
  end
  if self.UIRoot.Fadeout then
    self:AddControlEventByControl(self.UIRoot.Fadeout, "OnAnimationFinished", self.OnCloseAnimFinished, self)
  end
  if self.UIRoot.Anim_TextScroll_1 then
    self:AddControlEventByControl(self.UIRoot.Anim_TextScroll_1, "OnAnimationFinished", self.OnRankScrollAnimFinished, self)
  end
  if self.UIRoot.Anim_TextScroll_2 then
    self:AddControlEventByControl(self.UIRoot.Anim_TextScroll_2, "OnAnimationFinished", self.OnRankScrollAnimFinished, self)
  end
  if self.UIRoot.Anim_Gray then
    self:AddControlEventByControl(self.UIRoot.Anim_Gray, "OnAnimationFinished", self.OnSelectionAnimFinished, self)
  end
  HandleStateCanvasUtils.RegisterCanvasVisibleEvent(self.UIRoot.CanvasPanel_Root, self, "GodTrialHonorPanel_CanvasPanel_Root")
  EventSystem:postEvent(EVENTTYPE_INGAME_UI, EVENTID_ADD_TO_FORCE_HIDE_UI_ARRAY, self.UIRoot.CanvasPanel_Root)
end
function GodTrialHonorPanel:OnEnterSpectating()
  print(bWriteLog and "GodTrialHonorPanel:OnEnterSpectating")
  self:Collapsed()
end
function GodTrialHonorPanel:OnLiveStateChanged(State)
  print(bWriteLog and string.format("GodTrialHonorPanel:OnLiveStateChanged - State=%s", tostring(State)))
  if State == ExtraPlayerLiveState.InDied then
    self:Collapsed()
  end
end
function GodTrialHonorPanel:ReceiveBattleResults()
  print(bWriteLog and "GodTrialHonorPanel:ReceiveBattleResults")
  self:PlayCloseAnimAndClose()
end
function GodTrialHonorPanel:OnPlayerQuitSpectating()
  print(bWriteLog and "GodTrialHonorPanel:OnPlayerQuitSpectating")
  self:SelfHitTestInvisible()
  self:UpdateHonorScore()
  self:UpdateHonorRank()
end
function GodTrialHonorPanel:OnGameModeStateChange(_, _, State)
  print(bWriteLog and "GodTrialHonorPanel:OnGameModeStateChange, State = ", State)
  if State == "FightingState" then
    self:SelfHitTestInvisible()
    self:UpdateHonorScore()
    self:UpdateHonorRank()
  end
end
function GodTrialHonorPanel:OnGameDataReady()
  print(bWriteLog and "GodTrialHonorPanel:OnGameDataReady")
  self:ReconnectResetUIData()
  local PlayerState = GameplayData.GetPlayerState()
  if slua.isValid(PlayerState) then
    self:AddDataListener(PlayerState:GetSuperData(), "TeamTotalScore", self.OnTeamTotalScoreChanged, self)
    self:AddDataListener(PlayerState:GetSuperData(), "PlayerHonorState", self.OnPlayerHonorStateChanged, self)
  else
    print(bWriteLog and "GodTrialHonorPanel:OnGameDataReady - PlayerState not found")
  end
  local GameState = GameplayData.GetGameState()
  if slua.isValid(GameState) and GameState.GameStateTeamHonorFeature then
    self:BindLuaObjEvent(GameState.GameStateTeamHonorFeature, "OnRep_TeamTotalScoreList", self.OnTeamTotalScoreListChanged, self)
  else
    print(bWriteLog and "GodTrialHonorPanel:OnGameDataReady - GameStateTeamHonorFeature not found")
  end
  self:UpdateHonorScore()
  self:UpdateHonorRank()
end
function GodTrialHonorPanel:ReconnectResetUIData()
  self:StopProgressAnimation()
  self:ClearAnimTimeoutTimer()
  self.AnimQueue = {}
  self.bIsPlayingAnim = false
  self.bHonorScoreQualified = false
  self.bArenaItemFirstShown = false
  self.bSelectionCompleted = false
  self.bRankQualified = false
  self.LastRank = nil
  self.CurrentRank = 0
  self.CurrentProgressPercent = 0
  self.TargetProgressPercent = 0
  self.StartProgressPercent = 0
  self.AnimStartTime = 0
  if self.RankThrottleTimer then
    self:RemoveGameTimer(self.RankThrottleTimer)
    self.RankThrottleTimer = nil
  end
  self.PendingRankUpdate = nil
  local Enum = require("GameLua.Mod.GodTrial.Gameplay.Config.EnumDefine")
  local PlayerState = GameplayData.GetPlayerState()
  if slua.isValid(PlayerState) then
    local HonorFeature = PlayerState.PlayerStateHonorFeature
    if HonorFeature then
      local PlayerHonorState = HonorFeature.PlayerHonorState
      if PlayerHonorState ~= Enum.EHonorArenaState.HonorCollecting and PlayerHonorState ~= Enum.EHonorArenaState.None then
        print(bWriteLog and "GodTrialHonorPanel:ReconnectResetUIData - selection already completed on reconnect, close UI")
        self:AddGameTimer(0.1, false, function()
          self:CloseSelf()
        end)
        return
      elseif PlayerHonorState == Enum.EHonorArenaState.HonorCollecting then
        self:SelfHitTestInvisible()
      end
    end
  end
end
function GodTrialHonorPanel:OnPlayerHonorStateChanged(_, PlayerHonorState)
  local Enum = require("GameLua.Mod.GodTrial.Gameplay.Config.EnumDefine")
  print(bWriteLog and string.format("GodTrialHonorPanel:OnPlayerHonorStateChanged - PlayerHonorState=%s", tostring(PlayerHonorState)))
  if PlayerHonorState == Enum.EHonorArenaState.HonorCollecting or PlayerHonorState == Enum.EHonorArenaState.WaitEnterArena then
    self:SelfHitTestInvisible()
    self:UpdateHonorScore()
    self:UpdateHonorRank()
    if PlayerHonorState == Enum.EHonorArenaState.WaitEnterArena then
      self:OnSelectionCompleted()
    end
  elseif PlayerHonorState ~= Enum.EHonorArenaState.None then
    if self.SelectionCloseTimer then
      self:RemoveGameTimer(self.SelectionCloseTimer)
      self.SelectionCloseTimer = nil
    end
    self:PlayCloseAnimAndClose()
  end
end
function GodTrialHonorPanel:OnTeamTotalScoreChanged(_, TeamTotalScore)
  print(bWriteLog and string.format("GodTrialHonorPanel:OnTeamTotalScoreChanged - TeamTotalScore=%s", tostring(TeamTotalScore)))
  self:UpdateProgressBarAnimation(TeamTotalScore)
end
function GodTrialHonorPanel:OnTeamTotalScoreListChanged(TeamTotalScoreList)
  print(bWriteLog and "GodTrialHonorPanel:OnTeamTotalScoreListChanged")
  if not self.bHonorScoreQualified then
    print(bWriteLog and "GodTrialHonorPanel:OnTeamTotalScoreListChanged - honor not qualified, return")
    return
  end
  if self.bSelectionCompleted then
    print(bWriteLog and "GodTrialHonorPanel:OnTeamTotalScoreListChanged - selection completed, return")
    return
  end
  local NewRank = self:GetCurrentRank()
  if NewRank == self.LastRank then
    print(bWriteLog and string.format("GodTrialHonorPanel:OnTeamTotalScoreListChanged - rank not changed(%s), return", tostring(NewRank)))
    return
  end
  self:ThrottleRankUpdate()
end
function GodTrialHonorPanel:ThrottleRankUpdate()
  print(bWriteLog and "GodTrialHonorPanel:ThrottleRankUpdate")
  if not self.bHonorScoreQualified then
    print(bWriteLog and "GodTrialHonorPanel:ThrottleRankUpdate - honor not qualified, return")
    return
  end
  if self.bSelectionCompleted then
    self:UpdateHonorRank()
    print(bWriteLog and "GodTrialHonorPanel:ThrottleRankUpdate - selection completed, return")
    return
  end
  self.PendingRankUpdate = true
  if self.RankThrottleTimer then
    return
  end
  self:ProcessRankUpdate()
  self.RankThrottleTimer = self:AddGameTimer(AnimConfig.RankUpdateThrottle, false, function()
    self.RankThrottleTimer = nil
    if self.PendingRankUpdate then
      self.PendingRankUpdate = false
      self:ProcessRankUpdate()
    end
  end)
end
function GodTrialHonorPanel:ProcessRankUpdate()
  print(bWriteLog and "GodTrialHonorPanel:ProcessRankUpdate")
  local NewRank = self:GetCurrentRank()
  local OldRank = self.LastRank
  self:UpdateHonorRank()
  if self.ArenaTrialsItemUI then
    self.ArenaTrialsItemUI:RefreshRankGoal()
  end
  if not OldRank or not NewRank then
    self.LastRank = NewRank
    print(bWriteLog and string.format("GodTrialHonorPanel:ProcessRankUpdate - OldRank=%s or NewRank=%s is nil, return", tostring(OldRank), tostring(NewRank)))
    return
  end
  local RankThreshold = self:GetRankQualifyThreshold()
  local bNewRankQualified = NewRank <= RankThreshold
  local bOldRankQualified = self.bRankQualified
  local AnimType
  if NewRank < OldRank then
    AnimType = EAnimType.RankUp
  elseif NewRank > OldRank then
    AnimType = EAnimType.RankDown
  end
  local bRankQualifiedChanged = bOldRankQualified ~= bNewRankQualified
  self.bRankQualified = bNewRankQualified
  self.LastRank = NewRank
  if AnimType then
    self:EnqueueAnim(AnimType, OldRank, bRankQualifiedChanged)
  end
  if bRankQualifiedChanged and self.bArenaItemFirstShown and not self.bSelectionCompleted then
    self:PlayTipFadeInAnim()
  end
end
function GodTrialHonorPanel:OnSelectionCompleted()
  if self.bSelectionCompleted then
    print(bWriteLog and "GodTrialHonorPanel:OnSelectionCompleted - already completed, return")
    return
  end
  self.bSelectionCompleted = true
  print(bWriteLog and "GodTrialHonorPanel:OnSelectionCompleted")
  local NewRank = self:GetCurrentRank()
  local RankThreshold = self:GetRankQualifyThreshold()
  local bPassSelection = self.bHonorScoreQualified and NewRank and NewRank <= RankThreshold or false
  if bPassSelection then
    self:PlayAudio(AudioConfig.SelectionPass)
  end
  if not self.SelectionCloseTimer then
    self.SelectionCloseTimer = self:AddGameTimer(AnimConfig.SelectionCompletedCloseDelay, false, function()
      self.SelectionCloseTimer = nil
      self:PlayCloseAnimAndClose()
    end)
  end
  self:StopProgressAnimation()
  self:PlayTipFadeInAnim()
  local NewRank = self:GetCurrentRank()
  local OldRank = self.LastRank
  local RankThreshold = self:GetRankQualifyThreshold()
  local bNewRankQualified = NewRank and NewRank <= RankThreshold or false
  local bOldRankQualified = self.bRankQualified
  local bRankQualifiedChanged = bOldRankQualified ~= bNewRankQualified
  local RankAnimType
  if OldRank and NewRank then
    if NewRank < OldRank then
      RankAnimType = EAnimType.RankUp
    elseif NewRank > OldRank then
      RankAnimType = EAnimType.RankDown
    end
  end
  if RankAnimType then
    self:EnqueueAnim(RankAnimType, OldRank, bRankQualifiedChanged)
  else
    self:PlayGlowAnim(bNewRankQualified and self.bHonorScoreQualified)
  end
  if not bNewRankQualified or not self.bHonorScoreQualified then
    self:EnqueueAnim(EAnimType.SelectionFail)
  end
end
function GodTrialHonorPanel:EnqueueAnim(AnimType, OldRank, bRankQualifiedChanged)
  table.insert(self.AnimQueue, {
    AnimType = AnimType,
    OldRank = OldRank,
      })
  print(bWriteLog and string.format("GodTrialHonorPanel:EnqueueAnim - AnimType=%s, QueueSize=%d", tostring(AnimType), #self.AnimQueue))
  if not self.bIsPlayingAnim then
    self:ProcessNextAnim()
  end
end
function GodTrialHonorPanel:ProcessNextAnim()
  if #self.AnimQueue == 0 then
    self.bIsPlayingAnim = false
    return
  end
  self.bIsPlayingAnim = true
  local Item = table.remove(self.AnimQueue, 1)
  local AnimType = Item.AnimType
  print(bWriteLog and string.format("GodTrialHonorPanel:ProcessNextAnim - AnimType=%s", tostring(AnimType)))
  if AnimType == EAnimType.RankUp or AnimType == EAnimType.RankDown then
    self:PlayRankAnim(AnimType, Item.OldRank, Item.bRankQualifiedChanged)
  elseif AnimType == EAnimType.HonorFull then
    self:PlayHonorFullAnim()
  else
    if self.bHonorScoreQualified then
      self:HideIconPanel()
    elseif self.UIRoot and self.UIRoot.Border_Ranks then
      self.UIRoot.Border_Ranks:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
    if AnimType == EAnimType.SelectionFail then
      self:PlayAudio(AudioConfig.SelectionFail)
    end
    local AnimName, Duration = self:GetSingleAnimNameAndDuration(AnimType)
    if AnimName and self.UIRoot[AnimName] then
      self:PlayUserWidgetAnimation(self.UIRoot[AnimName], 0, 1, 0, 1)
      self:StartAnimTimeoutTimer(Duration)
    else
      print(bWriteLog and string.format("GodTrialHonorPanel:ProcessNextAnim - No animation for type %s, skipping", tostring(AnimType)))
      self:OnCurrentAnimFinished()
    end
  end
end
function GodTrialHonorPanel:PlayHonorFullAnim()
  local RankThreshold = self:GetRankQualifyThreshold()
  local CurrentRank = self:GetCurrentRank()
  local bRankQualified = CurrentRank and RankThreshold >= CurrentRank or false
  print(bWriteLog and string.format("GodTrialHonorPanel:PlayHonorFullAnim - bRankQualified=%s", tostring(bRankQualified)))
  if not self.UIRoot.Anim_Rank then
    print(bWriteLog and "GodTrialHonorPanel:PlayHonorFullAnim - no Anim_Rank available, skip")
    self:OnCurrentAnimFinished()
    return
  end
  self:PlayAudio(AudioConfig.HonorFull)
  self:StartAnimTimeoutTimer(AnimConfig.HonorFullAnimDuration)
  self:PlayUserWidgetAnimation(self.UIRoot.Anim_Rank, 0, 1, 0, 1)
  if bRankQualified then
    self:PlayGlowAnim(true)
  end
end
function GodTrialHonorPanel:PlayRankAnim(AnimType, OldRank, bRankQualifiedChanged)
  print(bWriteLog and string.format("GodTrialHonorPanel:PlayRankAnim - AnimType=%s, OldRank=%s, bRankQualifiedChanged=%s", tostring(AnimType), tostring(OldRank), tostring(bRankQualifiedChanged)))
  local OldRankText = OldRank and tostring(OldRank) or "--"
  local NewRank = self:GetCurrentRank()
  local NewRankText = NewRank and tostring(NewRank) or "--"
  if AnimType == EAnimType.RankUp and bRankQualifiedChanged then
    self:PlayAudio(AudioConfig.RankUp, true)
  elseif AnimType == EAnimType.RankDown and bRankQualifiedChanged then
    self:PlayAudio(AudioConfig.RankDown, true)
  else
    self:PlayAudio(AudioConfig.NumberChange, true)
  end
  if bRankQualifiedChanged then
    local RankThreshold = self:GetRankQualifyThreshold()
    local bNewRankQualified = NewRank and NewRank <= RankThreshold or false
    self:PlayGlowAnim(bNewRankQualified)
  end
  if AnimType == EAnimType.RankUp then
    if self.UIRoot.TextBlock_Rank then
      self.UIRoot.TextBlock_Rank:SetText(OldRankText)
    end
    if self.UIRoot.TextBlock_Rank_1 then
      self.UIRoot.TextBlock_Rank_1:SetText(NewRankText)
    end
  else
    if self.UIRoot.TextBlock_Rank_1 then
      self.UIRoot.TextBlock_Rank_1:SetText(OldRankText)
    end
    if self.UIRoot.TextBlock_Rank then
      self.UIRoot.TextBlock_Rank:SetText(NewRankText)
    end
  end
  local ScrollAnimName = AnimType == EAnimType.RankUp and "Anim_TextScroll_1" or "Anim_TextScroll_2"
  if not self.UIRoot[ScrollAnimName] then
    print(bWriteLog and "GodTrialHonorPanel:PlayRankAnim - no scroll animation available, skip")
    self:OnCurrentAnimFinished()
    return
  end
  self:StartAnimTimeoutTimer(AnimConfig.RankScrollAnimDuration)
  self:PlayUserWidgetAnimation(self.UIRoot[ScrollAnimName], 0, 1, 0, 1)
end
function GodTrialHonorPanel:PlayGlowAnim(bGlowIn)
  local GlowAnimName = bGlowIn and "Anim_Glow_in" or "Anim_Glow_out"
  print(bWriteLog and string.format("GodTrialHonorPanel:PlayGlowAnim - %s", GlowAnimName))
  if self.UIRoot and self.UIRoot[GlowAnimName] then
    self:PlayUserWidgetAnimation(self.UIRoot[GlowAnimName], 0, 1, 0, 1)
  end
end
function GodTrialHonorPanel:GetSingleAnimNameAndDuration(AnimType)
  if AnimType == EAnimType.HonorFull then
    return "Anim_Rank", AnimConfig.HonorFullAnimDuration
  elseif AnimType == EAnimType.SelectionFail then
    return "Anim_Gray", AnimConfig.SelectionResultAnimDuration
  end
  return nil, 1.0
end
function GodTrialHonorPanel:StartAnimTimeoutTimer(Duration)
  if self.AnimTimeoutTimer then
    self:RemoveGameTimer(self.AnimTimeoutTimer)
    self.AnimTimeoutTimer = nil
  end
  self.AnimTimeoutTimer = self:AddGameTimer(Duration + 0.2, false, function()
    self.AnimTimeoutTimer = nil
    print(bWriteLog and "GodTrialHonorPanel:StartAnimTimeoutTimer - Timeout, forcing next anim")
    self:OnCurrentAnimFinished()
  end)
end
function GodTrialHonorPanel:ClearAnimTimeoutTimer()
  if self.AnimTimeoutTimer then
    self:RemoveGameTimer(self.AnimTimeoutTimer)
    self.AnimTimeoutTimer = nil
  end
end
function GodTrialHonorPanel:OnCurrentAnimFinished()
  self:ClearAnimTimeoutTimer()
  self:ProcessNextAnim()
end
function GodTrialHonorPanel:OnHonorFullAnimFinished()
  print(bWriteLog and "GodTrialHonorPanel:OnHonorFullAnimFinished")
  if self.UIRoot.Border_Ranks then
    self.UIRoot.Border_Ranks:SetContentColorAndOpacity(FLinearColor(1, 1, 1, 1))
  end
  self.LastRank = self:GetCurrentRank()
  local RankThreshold = self:GetRankQualifyThreshold()
  self.bRankQualified = self.LastRank ~= nil and RankThreshold >= self.LastRank
  self:HideIconPanel()
  if not self.bArenaItemFirstShown then
    self.bArenaItemFirstShown = true
    self:PlayTipFadeInAnim()
  end
  self:OnCurrentAnimFinished()
end
function GodTrialHonorPanel:OnRankScrollAnimFinished()
  print(bWriteLog and "GodTrialHonorPanel:OnRankScrollAnimFinished")
  self:ResetRankBorderState()
  self:OnCurrentAnimFinished()
end
function GodTrialHonorPanel:ResetRankBorderState()
  local CurrentRank = self:GetCurrentRank()
  local RankText = CurrentRank and tostring(CurrentRank) or "--"
  if self.UIRoot.TextBlock_Rank then
    self.UIRoot.TextBlock_Rank:SetText(RankText)
  end
  if self.UIRoot.TextBlock_Rank_1 then
    self.UIRoot.TextBlock_Rank_1:SetText(RankText)
  end
end
function GodTrialHonorPanel:OnSelectionAnimFinished()
  print(bWriteLog and "GodTrialHonorPanel:OnSelectionAnimFinished")
  self:OnCurrentAnimFinished()
end
function GodTrialHonorPanel:ShowNormalIcon()
  if not self.UIRoot or not self.UIRoot.CanvasPanel_Icon then
    print(bWriteLog and "GodTrialHonorPanel:ShowNormalIcon - UIRoot or CanvasPanel_Icon is nil, return")
    return
  end
  self.UIRoot.CanvasPanel_Icon:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  if self.UIRoot.Image_NormalIcon then
    self.UIRoot.Image_NormalIcon:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
  if self.UIRoot.Image_GrayIcon then
    self.UIRoot.Image_GrayIcon:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function GodTrialHonorPanel:ShowGrayIcon()
  print(bWriteLog and "GodTrialHonorPanel:ShowGrayIcon")
  if not self.UIRoot or not self.UIRoot.CanvasPanel_Icon then
    print(bWriteLog and "GodTrialHonorPanel:ShowGrayIcon - UIRoot or CanvasPanel_Icon is nil, return")
    return
  end
  self.UIRoot.CanvasPanel_Icon:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  if self.UIRoot.Image_NormalIcon then
    self.UIRoot.Image_NormalIcon:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if self.UIRoot.Image_GrayIcon then
    self.UIRoot.Image_GrayIcon:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
end
function GodTrialHonorPanel:HideIconPanel()
  print(bWriteLog and "GodTrialHonorPanel:HideIconPanel")
  if not self.UIRoot or not self.UIRoot.CanvasPanel_Icon then
    print(bWriteLog and "GodTrialHonorPanel:HideIconPanel - UIRoot or CanvasPanel_Icon is nil, return")
    return
  end
  self.UIRoot.CanvasPanel_Icon:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function GodTrialHonorPanel:PlayTipFadeInAnim()
  print(bWriteLog and "GodTrialHonorPanel:PlayTipFadeInAnim")
  if not self.TipCanvasPanel then
    print(bWriteLog and "GodTrialHonorPanel:PlayTipFadeInAnim - TipCanvasPanel is nil, skip")
    return
  end
  if self.ArenaItemFadeTimer then
    self:RemoveGameTimer(self.ArenaItemFadeTimer)
    self.ArenaItemFadeTimer = nil
  end
  self.bArenaItemVisible = true
  self.TipCanvasPanel:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  if self.UIRoot.Anim_Tips_in then
    self:PlayUserWidgetAnimation(self.UIRoot.Anim_Tips_in, 0, 1, 0, 1)
  else
    self:OnTipFadeInFinished()
  end
  if self.ArenaTrialsItemUI then
    self.ArenaTrialsItemUI:RefreshAll()
  end
end
function GodTrialHonorPanel:HideArenaItemWithFadeOut()
  print(bWriteLog and "GodTrialHonorPanel:HideArenaItemWithFadeOut")
  if not self.bArenaItemVisible then
    print(bWriteLog and "GodTrialHonorPanel:HideArenaItemWithFadeOut - not visible, return")
    return
  end
  if not self.TipCanvasPanel then
    print(bWriteLog and "GodTrialHonorPanel:HideArenaItemWithFadeOut - TipCanvasPanel is nil, return")
    return
  end
  self.bArenaItemVisible = false
  if self.UIRoot.Anim_Tips_out then
    self:PlayUserWidgetAnimation(self.UIRoot.Anim_Tips_out, 0, 1, 0, 1)
    if self.ArenaItemFadeTimer then
      self:RemoveGameTimer(self.ArenaItemFadeTimer)
    end
    self.ArenaItemFadeTimer = self:AddGameTimer(AnimConfig.TipFadeOutDuration + 0.2, false, function()
      self.ArenaItemFadeTimer = nil
      self:OnTipFadeOutFinished()
    end)
  else
    self:OnTipFadeOutFinished()
  end
end
function GodTrialHonorPanel:OnTipFadeInFinished()
  print(bWriteLog and "GodTrialHonorPanel:OnTipFadeInFinished")
  if self.ArenaItemFadeTimer then
    self:RemoveGameTimer(self.ArenaItemFadeTimer)
    self.ArenaItemFadeTimer = nil
  end
  self.ArenaItemFadeTimer = self:AddGameTimer(AnimConfig.TipAutoHideDelay, false, function()
    self.ArenaItemFadeTimer = nil
    self:HideArenaItemWithFadeOut()
  end)
end
function GodTrialHonorPanel:OnTipFadeOutFinished()
  print(bWriteLog and "GodTrialHonorPanel:OnTipFadeOutFinished")
  if self.ArenaItemFadeTimer then
    self:RemoveGameTimer(self.ArenaItemFadeTimer)
    self.ArenaItemFadeTimer = nil
  end
  if self.TipCanvasPanel then
    self.TipCanvasPanel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function GodTrialHonorPanel:OnMouseButtonDownOnBorder()
  print(bWriteLog and "GodTrialHonorPanel:OnMouseButtonDownOnBorder")
  if self.DelayShowDetailTimer then
    self:RemoveGameTimer(self.DelayShowDetailTimer)
    self.DelayShowDetailTimer = nil
  end
  self.bIsLongPress = false
  self.DelayShowDetailTimer = self:AddGameTimer(self.LongPressThreshold, false, function()
    self.DelayShowDetailTimer = nil
    self.bIsLongPress = true
    self.bDetailVisible = true
    UIManager.ShowUI(UIManager.UI_Config_InGame.ArenaTrials_Detail_Item)
    if self.DetailAutoCloseTimer then
      self:RemoveGameTimer(self.DetailAutoCloseTimer)
      self.DetailAutoCloseTimer = nil
    end
  end)
  local WidgetBlueprintLibrary = import("WidgetBlueprintLibrary")
  local Handled = WidgetBlueprintLibrary.Handled()
  local Handled = WidgetBlueprintLibrary.CaptureMouse(Handled, self.UIRoot.Border_Icon)
  return Handled
end
function GodTrialHonorPanel:OnMouseButtonUpOnBorder()
  print(bWriteLog and "GodTrialHonorPanel:OnMouseButtonUpOnBorder")
  if self.bIsLongPress then
    self.bIsLongPress = false
    self.bDetailVisible = false
    UIManager.CloseUI(UIManager.UI_Config_InGame.ArenaTrials_Detail_Item)
    print(bWriteLog and "GodTrialHonorPanel:OnMouseButtonUpOnBorder - long press release, close detail")
  else
    if self.DelayShowDetailTimer then
      self:RemoveGameTimer(self.DelayShowDetailTimer)
      self.DelayShowDetailTimer = nil
    end
    if self.bDetailVisible then
      self.bDetailVisible = false
      UIManager.CloseUI(UIManager.UI_Config_InGame.ArenaTrials_Detail_Item)
      print(bWriteLog and "GodTrialHonorPanel:OnMouseButtonUpOnBorder - click, close detail")
      if self.DetailAutoCloseTimer then
        self:RemoveGameTimer(self.DetailAutoCloseTimer)
        self.DetailAutoCloseTimer = nil
      end
    else
      self.bDetailVisible = true
      UIManager.ShowUI(UIManager.UI_Config_InGame.ArenaTrials_Detail_Item)
      if self.DetailAutoCloseTimer then
        self:RemoveGameTimer(self.DetailAutoCloseTimer)
        self.DetailAutoCloseTimer = nil
      end
      self.DetailAutoCloseTimer = self:AddGameTimer(3.0, false, function()
        self.DetailAutoCloseTimer = nil
        if self.bDetailVisible then
          self.bDetailVisible = false
          UIManager.CloseUI(UIManager.UI_Config_InGame.ArenaTrials_Detail_Item)
        end
      end)
    end
  end
  local WidgetBlueprintLibrary = import("WidgetBlueprintLibrary")
  local Handled = WidgetBlueprintLibrary.Handled()
  local Handled = WidgetBlueprintLibrary.ReleaseMouseCapture(Handled, self.UIRoot.Border_Icon)
  return Handled
end
function GodTrialHonorPanel:RefreshUI()
end
function GodTrialHonorPanel:OnShow()
  print(bWriteLog and "GodTrialHonorPanel:OnShow")
  self:UpdateHonorScore()
  self:UpdateHonorRank()
  if self.ArenaTrialsItemUI then
    self.ArenaTrialsItemUI:RefreshAll()
  end
end
function GodTrialHonorPanel:OnHide()
  print(bWriteLog and "GodTrialHonorPanel:OnHide")
end
function GodTrialHonorPanel:OnClose()
  print(bWriteLog and "GodTrialHonorPanel:OnClose")
  if self.DelayShowDetailTimer then
    self:RemoveGameTimer(self.DelayShowDetailTimer)
    self.DelayShowDetailTimer = nil
  end
  if self.DetailAutoCloseTimer then
    self:RemoveGameTimer(self.DetailAutoCloseTimer)
    self.DetailAutoCloseTimer = nil
  end
  if self.RankThrottleTimer then
    self:RemoveGameTimer(self.RankThrottleTimer)
    self.RankThrottleTimer = nil
  end
  if self.ArenaItemFadeTimer then
    self:RemoveGameTimer(self.ArenaItemFadeTimer)
    self.ArenaItemFadeTimer = nil
  end
  if self.SelectionCloseTimer then
    self:RemoveGameTimer(self.SelectionCloseTimer)
    self.SelectionCloseTimer = nil
  end
  self.bIsClosingAnim = false
  self.bDetailVisible = false
  self.bIsLongPress = false
  HandleStateCanvasUtils.UnRegisterCanvasVisibleEvent(self.UIRoot.CanvasPanel_Root)
  EventSystem:postEvent(EVENTTYPE_INGAME_UI, EVENTID_REMOVE_FROM_FORCE_HIDE_UI_ARRAY, self.UIRoot.CanvasPanel_Root)
  self:StopProgressAnimation()
  self:ClearAnimTimeoutTimer()
  self.AnimQueue = {}
  self.bIsPlayingAnim = false
  self.ArenaTrialsItemUI = nil
  self.TipCanvasPanel = nil
  UIManager.CloseUI(UIManager.UI_Config_InGame.ArenaTrials_Detail_Item)
  GodTrialHonorPanel.__super.OnClose(self)
end
function GodTrialHonorPanel:EaseOutLerp(startValue, endValue, elapsed, duration)
  if duration <= elapsed then
    return endValue
  end
  local t = elapsed / duration
  local easedT = 1 - (1 - t) ^ AnimConfig.EaseOutPower
  return startValue + (endValue - startValue) * easedT
end
function GodTrialHonorPanel:StartProgressAnimation()
  if self.ProgressAnimTimer then
    self:RemoveGameTimer(self.ProgressAnimTimer)
    self.ProgressAnimTimer = nil
  end
  self.AnimStartTime = 0
  self.StartProgressPercent = self.CurrentProgressPercent
  self.bHonorGainAudioPlayed = false
  self.ProgressAnimTimer = self:AddGameTimer(AnimConfig.ProgressUpdateInterval, true, function()
    self:UpdateProgressBar()
  end)
end
function GodTrialHonorPanel:StopProgressAnimation()
  if self.ProgressAnimTimer then
    self:RemoveGameTimer(self.ProgressAnimTimer)
    self.ProgressAnimTimer = nil
  end
end
function GodTrialHonorPanel:UpdateProgressBar()
  self.AnimStartTime = self.AnimStartTime + AnimConfig.ProgressUpdateInterval
  if self.AnimStartTime < AnimConfig.ProgressAnimDuration then
    self.CurrentProgressPercent = self:EaseOutLerp(self.StartProgressPercent, self.TargetProgressPercent, self.AnimStartTime, AnimConfig.ProgressAnimDuration)
  else
    self.CurrentProgressPercent = self.TargetProgressPercent
    self:StopProgressAnimation()
    if self.TargetProgressPercent >= 1 and not self.bHonorScoreQualified then
      self.bHonorScoreQualified = true
      local CurrentRank = self:GetCurrentRank()
      local RankText = CurrentRank and tostring(CurrentRank) or "--"
      if self.UIRoot and self.UIRoot.TextBlock_Rank then
        self.UIRoot.TextBlock_Rank:SetText(RankText)
      end
      if self.UIRoot and self.UIRoot.TextBlock_Rank_1 then
        self.UIRoot.TextBlock_Rank_1:SetText(RankText)
      end
      self:EnqueueAnim(EAnimType.HonorFull)
    end
  end
  local MappedPercent = 0.12 + self.CurrentProgressPercent * 0.8
  self:SetProgressBarPercent(MappedPercent)
end
function GodTrialHonorPanel:UpdateProgressBarAnimation(TeamTotalScore)
  if self.TargetProgressPercent == TeamTotalScore then
    print(bWriteLog and "GodTrialHonorPanel:UpdateProgressBarAnimation - TargetProgressPercent not changed, return")
    return
  end
  if self.bHonorScoreQualified then
    print(bWriteLog and "GodTrialHonorPanel:UpdateProgressBarAnimation - honor already qualified, return")
    return
  end
  if self.bSelectionCompleted then
    print(bWriteLog and "GodTrialHonorPanel:UpdateProgressBarAnimation - selection already completed, return")
    return
  end
  print(bWriteLog and string.format("GodTrialHonorPanel:UpdateProgressBarAnimation - TeamTotalScore=%s", tostring(TeamTotalScore)))
  local MinimumScore = 0
  local GameState = GameplayData.GetGameState()
  if slua.isValid(GameState) and GameState.GameStateTeamHonorFeature then
    MinimumScore = GameState.GameStateTeamHonorFeature.ArenaMinimumScore or 0
  end
  local Percent = 0
  if 0 < MinimumScore then
    Percent = math.min((TeamTotalScore or 0) / MinimumScore, 1)
  end
  self.TargetProgress  self:StartProgressAnimation()
  if self.TargetProgressPercent > 0 and not self.bHonorGainAudioPlayed then
    self.bHonorGainAudioPlayed = true
    self:PlayAudio(AudioConfig.HonorGain, true)
  end
  if self.ArenaTrialsItemUI then
    self.ArenaTrialsItemUI:RefreshHonorGoal()
  end
end
function GodTrialHonorPanel:SetProgressBarPercent(Percent)
  if not self.UIRoot or not self.UIRoot.ProgressBar_HonorValue then
    print(bWriteLog and "GodTrialHonorPanel:SetProgressBarPercent - UIRoot or ProgressBar_HonorValue is nil, return")
    return
  end
  self.UIRoot.ProgressBar_HonorValue:SetPercent(Percent)
  if not self.bHonorScoreQualified and not self.bSelectionCompleted then
    self:ShowNormalIcon()
  end
end
function GodTrialHonorPanel:UpdateHonorScore()
  print(bWriteLog and "GodTrialHonorPanel:UpdateHonorScore")
  local MyPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(MyPlayerController) then
    print(bWriteLog and "GodTrialHonorPanel:UpdateHonorScore - PlayerController is invalid, return")
    return
  end
  local MyPlayerState = MyPlayerController.PlayerState
  if not slua.isValid(MyPlayerState) then
    print(bWriteLog and "GodTrialHonorPanel:UpdateHonorScore - PlayerState is invalid, return")
    return
  end
  local HonorFeature = MyPlayerState.PlayerStateHonorFeature
  local CurrentScore = HonorFeature and HonorFeature.TeamTotalScore or nil
  self:UpdateProgressBarAnimation(CurrentScore or 0)
end
function GodTrialHonorPanel:GetRankQualifyThreshold()
  local GameState = GameplayData.GetGameState()
  if slua.isValid(GameState) and GameState.GameStateTeamHonorFeature then
    local Threshold = GameState.GameStateTeamHonorFeature.ArenaChoosenTeamNum
    if Threshold and 0 < Threshold then
      return Threshold
    end
  end
  return 4
end
function GodTrialHonorPanel:GetCurrentRank()
  if self.CurrentRank and self.CurrentRank > 0 then
    return self.CurrentRank
  end
  local MyPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(MyPlayerController) then
    return nil
  end
  local MyPlayerState = MyPlayerController.PlayerState
  if not slua.isValid(MyPlayerState) then
    return nil
  end
  local TeamID = MyPlayerState.TeamID
  if not TeamID then
    return nil
  end
  local GameState = GameplayData.GetGameState()
  if not slua.isValid(GameState) or not GameState.GameStateTeamHonorFeature then
    return nil
  end
  local _, Rank = GameState.GameStateTeamHonorFeature:ClientGetTeamTotalScore(TeamID)
  return Rank
end
function GodTrialHonorPanel:UpdateHonorRank()
  print(bWriteLog and "GodTrialHonorPanel:UpdateHonorRank")
  local Rank = self:GetCurrentRank()
  if not Rank then
    print(bWriteLog and "GodTrialHonorPanel:UpdateHonorRank - Rank is nil, set to --, return")
    if self.UIRoot.TextBlock_Rank then
      self.UIRoot.TextBlock_Rank:SetText("--")
    end
    if self.UIRoot.TextBlock_Ranking then
      self.UIRoot.TextBlock_Ranking:SetText("--")
    end
    return
  end
  if self.UIRoot.TextBlock_Rank then
    self.UIRoot.TextBlock_Rank:SetText(Rank)
  end
  if self.UIRoot.TextBlock_Ranking then
    self.UIRoot.TextBlock_Ranking:SetText(Rank)
  end
end
function GodTrialHonorPanel:PlayCloseAnimAndClose()
  print(bWriteLog and "GodTrialHonorPanel:PlayCloseAnimAndClose")
  if self.bIsClosingAnim then
    print(bWriteLog and "GodTrialHonorPanel:PlayCloseAnimAndClose - already closing, return")
    return
  end
  self.bIsClosingAnim = true
  if self.UIRoot and self.UIRoot.Fadeout then
    self:PlayUserWidgetAnimation(self.UIRoot.Fadeout, 0, 1, 0, 1)
    self:AddGameTimer(AnimConfig.CloseAnimDuration + 0.2, false, function()
      self:OnCloseAnimFinished()
    end)
  else
    self:OnCloseAnimFinished()
  end
end
function GodTrialHonorPanel:OnCloseAnimFinished()
  print(bWriteLog and "GodTrialHonorPanel:OnCloseAnimFinished")
  if not self.bIsClosingAnim then
    return
  end
  self.bIsClosingAnim = false
  self:CloseSelf()
end
local class = require("class")
local UIBase = require("client.slua_ui_framework.base")
return class(UIBase, nil, GodTrialHonorPanel)