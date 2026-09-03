local IngameTeamItemUI = {}
local TeamPanelConfig = require("GameLua.Mod.BaseMod.Client.IngameTeamPanel.IngameTeamPanelConfig")
local uSTExtraUIUtils = import("STExtraUIUtils")
local uAkGameplayStatics = import("AkGameplayStatics")
local uBusinessHelper = import("BusinessHelper")
local uSTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local uEPlayerLiveState = import("ExtraPlayerLiveState")
local ESTExtraVehicleType = import("ESTExtraVehicleType")
local uEGameModeType = import("EGameModeType")
local uEFollowState = import("EFollowState")
local uEUAVUseType = import("EUAVUseType")
local uEUAVCharacterMsgType = import("/Script/ShadowTrackerExtra.EUAVCharacterMsgType")
local uEMentorPlayerType = import("EMentorPlayerType")
function IngameTeamItemUI:ctor(_, nIndex, TeamMatePlayerState)
  self.CustomStatusMapRight = {}
  self.CustomStatusMapLeft = {}
  self.CustomStatusMapRightLoading = {}
  self.CustomStatusMapLeftLoading = {}
  self.CustomHPBuffIcon = {}
  self.DynamicIconList = {}
  self.StatusIconList = {}
  self.KingEliminationStateIconUI = nil
  self:Reset(nIndex, TeamMatePlayerState)
end
function IngameTeamItemUI:OnInitialize()
  self.TextAlphaColor = {
    [1] = FSlateColor(FLinearColor(1, 1, 1, 0.3)),
    [2] = FSlateColor(FLinearColor(1, 1, 1, 1))
  }
  self:InitTeamItem()
  self.KingEliminationStateIconUI = self:CreateChildWindow("HorizontalBox_RightSlot", UIManager.UI_Config.KingEliminationStateIcon, self.uPlayerState)
  if self.UIRoot.TextBlock_Follow then
    self.UIRoot.TextBlock_Follow:SetText(LocUtil.GetLocalizeResStr(99009927))
  end
  self:UpdateVoice()
end
function IngameTeamItemUI:RegistEvents()
  self:AddControlEventByControl(self.UIRoot.DX_Injure, "OnAnimationFinished", self.OnDamageEffectFinish, self)
  self:AddControlEventByControl(self.UIRoot.DX_qipao, "OnAnimationFinished", self.OnQipaoEffectFinish, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Follow, self.OnClickedFollowBtn, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_TEAMMATE_PANEL, EVENTID_TEAMMATE_ON_OPERATE_UAV, self.DisplayCharStateWhenOperateUAV, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, self.OnGameStateChange, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_ENTER_SPECTATING, self.OnEnterSpectating, self)
  self:AddDataListener(GameplayData.GetSuperData(), "GameDataReady", self.OnGameDataReady, self)
  self:BindLuaObjEvent(self.uPlayerState, "OnbVoiceChangedChange", self.EnableVoiceChanger, self)
end
function IngameTeamItemUI:OnClose()
  self.UIRoot.CanvasPanelResurrection:ClearChildren()
  self.CustomStatusMapRight = {}
  self.CustomStatusMapRightLoading = {}
  self.CustomStatusMapLeft = {}
  self.CustomStatusMapLeftLoading = {}
  self.CustomHPBuffIcon = {}
  self.AddonWidgetList = {}
  self.uPlayerState = nil
  self.uPlayerState_Previous = nil
  self.Resurrection_TeamtimeWidget = nil
  self.TextAlphaColor = {}
  self.KingEliminationStateIconUI = nil
  self:ClearDynamicIconList()
end
function IngameTeamItemUI:Reset(nIndex, TeamMatePlayerState)
  self.  self:UnBindPlayerUnderAttack()
  self:ResetPlayerStateDataListener(self.uPlayerState)
  self.uPlayerState = TeamMatePlayerState
  self:AddPlayerStateDataListener(self.uPlayerState)
  self:BindPlayerUnderAttack()
  self.uPlayerState_Previous = nil
  self.Resurrection_TeamtimeWidget = nil
  self.AddonWidgetList = {}
  self.bLastIsDying = false
  self.bIsRevivalNeedSet = false
  self.bisLostOrExit = false
  self.bCanShowVehicleTip = true
  self.bCanPlayVehicleSound = true
  self.bCanShowfootTips = true
  self.bCanPlayerMoveSound = true
  self.bCanShowShotTips = true
  self.bCanPlayShotSound = true
  self.bCanShowHurtTips = true
  self.bCanPlayHurtSound = true
  self.bCalledInfectMode = false
  self.bInfectMode = false
  self.nLastPercent = 0
  self.nStatus = 0
  self.nPlayerID = 0
  self.nCurentStatus = 0
  self.UpdateShootTimer = nil
  self.sTeammatePlayerName = ""
  self.eCurFollowState = uEFollowState.None
  self.ParachuteFollowState = nil
  self.ePlayerLiveState = nil
  self.bAITakeOver = false
  if self.UIRoot then
    if slua.isValid(self.uPlayerState) then
      self:EnableVoiceChanger(self.uPlayerState.bVoiceChanged == true)
    else
      self:EnableVoiceChanger(false)
    end
  end
  if self.KingEliminationStateIconUI then
    self.KingEliminationStateIconUI:InitTeamItemPlayerStateWidget(self.uPlayerState)
  end
end
function IngameTeamItemUI:GetPlayerState()
  return self.uPlayerState
end
function IngameTeamItemUI:ResetPlayerStateDataListener(PlayerState)
  if not slua.isValid(PlayerState) or PlayerState.GetSuperData == nil then
    return
  end
  local SuperData = PlayerState:GetSuperData()
  self:RemoveDataListener(SuperData, "bIsLostConnection")
end
function IngameTeamItemUI:AddPlayerStateDataListener(PlayerState)
  if not slua.isValid(PlayerState) or PlayerState.GetSuperData == nil then
    return
  end
  local SuperData = PlayerState:GetSuperData()
  self:AddDataListener(SuperData, "bIsLostConnection", self.OnLostConnectionStateChange, self)
end
function IngameTeamItemUI:OnLostConnectionStateChange()
  local PlayerState = self.uPlayerState
  if not slua.isValid(PlayerState) then
    return
  end
  if not self.UIRoot then
    return
  end
  self.bisLostOrExit = PlayerState.isLostConnection
  self:SetState(PlayerState.LiveState, true)
end
function IngameTeamItemUI:OnShow()
  self:ShowSelf()
end
function IngameTeamItemUI:HideSelf()
  print(bWriteLog and "IngameTeamItemUI Hide")
  self.UIRoot.CanvasPanel_0:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function IngameTeamItemUI:ShowSelf()
  print(bWriteLog and "IngameTeamItemUI Show")
  self.UIRoot.CanvasPanel_0:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
end
function IngameTeamItemUI:InitTeamItem()
  local uPlayerState = self.uPlayerState
  local nIndex = self.nIndex
  if slua.isValid(uPlayerState) then
    self:SetItemHP()
    self:SetState(uPlayerState.LiveState)
    self:InitAllDynamicStatusItem()
    self:SetNation(uPlayerState.Nation)
    self:SetPlayerName(uPlayerState.PlayerName, nIndex)
    self:UpdateTeamMateMapMark()
    self.nPlayerID = uPlayerState.PlayerId
    self:EnableVoiceChanger(uPlayerState.bVoiceChanged == true)
    self:SetGenderIcon(uPlayerState.PlatformGender)
    local bOpen = self:CheckFollowPanelOpen()
    self:SetPlayerMatchStragetyLabel(uPlayerState.MatchStrategyLabel, bOpen)
    self:SetItemColor()
    EventSystem:postEvent(EVENTTYPE_INGAME_TEAMMATE_PANEL, EVENTID_TEAMMATE_ON_TEAMMATE_ITEM_INIT, self, uPlayerState)
  end
  self.UIRoot.Button_Follow:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function IngameTeamItemUI:SetItemHP()
  local uPlayerState = self.uPlayerState
  if not slua.isValid(uPlayerState) then
    return
  end
  local nCurHP = uPlayerState:GetPlayerHealth()
  local nMaxHP = uPlayerState:GetPlayerMaxHealth()
  print(bWriteLog and "TeamPanel_Debug_Msg: PlayerName = " .. uPlayerState.PlayerName .. " HP = " .. tostring(nCurHP) .. " nMaxHP = " .. tostring(nMaxHP))
  local nPercentage = nCurHP / nMaxHP
  if nMaxHP <= 0 then
    nPercentage = 1
  end
  print(bWriteLog and "IngameTeamItemUI SetHP: " .. self.uPlayerState.PlayerName .. " " .. tostring(nPercentage))
  self:SetHP(nPercentage, false)
end
function IngameTeamItemUI:CheckFollowPanelOpen()
  local TeamPanelUIConfig = UIManager.UI_Config_InGame.TeamPanel
  if TeamPanelUIConfig then
    local TeamPanel = UIManager.GetUI(TeamPanelUIConfig)
    if TeamPanel then
      local eVisibility = TeamPanel.UIRoot.CanvasPanel_FollowPanel:GetVisibility()
      return eVisibility == UEnums.ESlateVisibility.Collapsed
    end
  end
  return false
end
function IngameTeamItemUI:SetGenderIcon(eGender)
  print(bWriteLog and "TeamPanel_Debug_Msg: PlayerGender = " .. eGender)
  if eGender == 1 then
    self:SwitchGenderIcon(true)
  elseif eGender == 2 then
    self:SwitchGenderIcon(false)
  end
end
function IngameTeamItemUI:UpdateTeamMateMapMark()
  local bIsInfectGameMode = self:IsInfectMode()
  if bIsInfectGameMode then
    return
  end
  local uPlayerState = self.uPlayerState
  if slua.isValid(uPlayerState) then
    local MapMarkZ = slua.IndexReference(uPlayerState, "MapMark").Z or 0
    if 0 < MapMarkZ then
      self.UIRoot.Image_PlayerMark01:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
    else
      self.UIRoot.Image_PlayerMark01:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end
end
function IngameTeamItemUI:ShowFollowButton(bShow)
  if self.bExitBornIsland then
    print(bWriteLog and "IngameTeamItemUI:ShowFollowButton - ExitBornIsland")
    self.UIRoot.Button_Follow:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.CanvasPanel_LandFollowBtnGroup:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(PlayerCharacter) then
    local TeammateParachuteFollowStateList = PlayerCharacter.TeammateParachuteFollowState
    if TeammateParachuteFollowStateList then
      local Index = self.nIndex - 1
      if Index < TeammateParachuteFollowStateList:Num() then
        local TeammateFPS = TeammateParachuteFollowStateList:Get(Index)
        if TeammateFPS.FollowState == uEFollowState.Follower then
          bShow = false
        end
      end
      local SelfPlayerIndex = PlayerCharacter:GetPlayerTeamIndex()
      if SelfPlayerIndex < TeammateParachuteFollowStateList:Num() then
        local SelfPlayerFPS = TeammateParachuteFollowStateList:Get(SelfPlayerIndex)
        if SelfPlayerFPS.FollowState == uEFollowState.Follower and SelfPlayerFPS.LeaderIdx == Index then
          bShow = false
        end
      end
    end
  end
  if bShow then
    if not self.bPlayAnim then
      self.bPlayAnim = true
      self:PlayUserWidgetAnimation(self.UIRoot.Anim_TIpsGlow, 0, 1, 0, 1)
    end
    self.UIRoot.Button_Follow:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    self.UIRoot.CanvasPanel_LandFollowBtnGroup:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self.UIRoot.Button_Follow:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.CanvasPanel_LandFollowBtnGroup:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function IngameTeamItemUI:ShowCaptainImage(bShow)
  local Image_Captain = self.UIRoot.Image_Captain
  if not Image_Captain then
    print(bWriteLog and "IngameTeamItemUI:ShowCaptainImage - Image_Captain1 is nil")
    return
  end
  if bShow then
    Image_Captain:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    Image_Captain:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function IngameTeamItemUI:IsMapMarkVisible()
  local uPlayerState = self.uPlayerState
  if slua.isValid(uPlayerState) then
    local MapMarkZ = slua.IndexReference(uPlayerState, "MapMark").Z or 0
    if 0 < MapMarkZ then
      return true
    else
      return false
    end
  end
  return false
end
function IngameTeamItemUI:IsInfectMode()
  if self.bCalledInfectMode then
    return self.bInfectMode
  else
    local uGameState = slua_GameFrontendHUD:GetGameState()
    if slua.isValid(uGameState) then
      local bIsInfectGameMode = uGameState.GameModeType == uEGameModeType.EPVEInfectionGameMode
      self.bInfectMode = bIsInfectGameMode
      self.bCalledInfectMode = true
      if bIsInfectGameMode then
        return true
      end
    end
  end
  return false
end
function IngameTeamItemUI:SetHP(nPercent, bIsDying)
  if self.nLastPercent == nPercent and self.bLastIsDying == bIsDying then
    return
  end
  print(bWriteLog and "IngameTeamItemUI:SetHP PlayerName=" .. self.sTeammatePlayerName .. " nPercent =" .. nPercent .. " bIsDying: " .. tostring(bIsDying))
  self.nLastPercent = nPercent
  self.bLastIsDying = bIsDying
  if nPercent ~= 0 then
    nPercent = FuncUtil.Clamp(nPercent, 0.005, 1)
  end
  local HPbar = self.UIRoot.ProgressBar_PlayerHP
  HPbar:SetPercent(nPercent)
  local HPBarColor = InGameUITools.GetPlayerHPColor(nPercent, bIsDying)
  if HPBarColor then
    HPbar:SetFillColorAndOpacity(HPBarColor)
  end
end
function IngameTeamItemUI:SetState(ePlayerLiveState, bForceUpdate)
  self:HideAllStateImagesAndHPbar(ePlayerLiveState, bForceUpdate)
  local uPlayerState = self.uPlayerState
  if slua.isValid(uPlayerState) then
    print(bWriteLog and string.format("IngameTeamItemUI:SetState, PlayerName = %s, ePlayerLiveState = %s, CacheLiveState = %s, isLostConnection = %s", self.uPlayerState.PlayerName, tostring(ePlayerLiveState), tostring(self.ePlayerLiveState), tostring(uPlayerState.isLostConnection)))
    if not uPlayerState.isLostConnection or uPlayerState.TeammateTakeOverFeature and uPlayerState.TeammateTakeOverFeature.bAITakeOver then
      self:ChangeStateImageByState(ePlayerLiveState, bForceUpdate)
    else
      self:ChangeStateImageByState(uEPlayerLiveState.Offline, true)
    end
  else
    self:ChangeStateImageByState(ePlayerLiveState, bForceUpdate)
  end
end
function IngameTeamItemUI:InitAllDynamicStatusItem()
  local HorizontalBox_DynamicStatus = self.UIRoot.HorizontalBox_DynamicStatus
  local DynamicStatusList = HorizontalBox_DynamicStatus:GetChildrenCount() - 1
  local HorizontalBox_PreStatusList = self.UIRoot.HorizontalBox_PreStatusList
  local PreStatusList = HorizontalBox_PreStatusList:GetChildrenCount() - 1
  for idx = 0, DynamicStatusList do
    local child = HorizontalBox_DynamicStatus:GetChildAt(idx)
    child:InitTeamItemPlayerStateWidget(self.uPlayerState)
  end
  for idx = 0, PreStatusList do
    local child = HorizontalBox_PreStatusList:GetChildAt(idx)
    child:InitTeamItemPlayerStateWidget(self.uPlayerState)
  end
end
function IngameTeamItemUI:ChangeStateImageByState(ePlayerLiveState, bForceUpdate)
  if not bForceUpdate and self.ePlayerLiveState and self.ePlayerLiveState == ePlayerLiveState then
    return
  end
  if ePlayerLiveState == uEPlayerLiveState.InDefault then
    self:SetInDefaultState()
  elseif ePlayerLiveState == uEPlayerLiveState.InPlane then
    self:SetInPlaneState()
  elseif ePlayerLiveState == uEPlayerLiveState.InParachute then
    self:SetInParachuteState()
  elseif ePlayerLiveState == uEPlayerLiveState.InVehicle then
    self:SetInVehicleState()
  elseif ePlayerLiveState == uEPlayerLiveState.InDying then
    self:SetInRevivalingState()
  elseif ePlayerLiveState == uEPlayerLiveState.InDied then
    self:SetInDiedState()
  elseif self.bAITakeOver == true then
    self:SetTakeOverState()
  elseif ePlayerLiveState == uEPlayerLiveState.Offline then
    self:SetOfflineState()
  end
  self.  self:UpdateAircraftIconShowState()
end
function IngameTeamItemUI:ProcessDrivingIcon()
  local uPlayerState = self.uPlayerState
  if slua.isValid(uPlayerState) and uPlayerState.CurUAVUseType == uEUAVUseType.UAV_Using then
    if uPlayerState.eCurVehicleType == ESTExtraVehicleType.VT_UAVDeer then
      self.UIRoot.Image_PlayerDriving:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
    local sPath = "/Game/Mod/SuperCold/Atlas/UAV_UI/Frames/UAV_Image_wurenji_png.UAV_Image_wurenji_png"
    uSTExtraUIUtils.SetImageTextureAsync(sPath, self.UIRoot.Image_PlayerDriving)
  else
    self.UIRoot.Image_PlayerDriving:SetBrush(self.UIRoot.commonvehicleIcon)
  end
end
function IngameTeamItemUI:SetInDefaultState()
  local WidgetSwitcher_BG = self.UIRoot.WidgetSwitcher_BG
  if self.bisLostOrExit then
    self.UIRoot.Image_PlayerOffOnline:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
    WidgetSwitcher_BG:SetActiveWidgetIndex(1)
    self:SetTextAlpha(true)
  else
    WidgetSwitcher_BG:SetActiveWidgetIndex(0)
    self:SetTextAlpha(false)
  end
  self.UIRoot.HorizontalBox_HPBar:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
end
function IngameTeamItemUI:SetInPlaneState()
  self.UIRoot.Image_PlayerDriving:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
  self:ProcessDrivingIcon()
  self.UIRoot.WidgetSwitcher_BG:SetActiveWidgetIndex(0)
  self:SetTextAlpha(false)
  self.UIRoot.HorizontalBox_HPBar:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
end
function IngameTeamItemUI:SetInParachuteState()
  self.UIRoot.WidgetSwitcher_BG:SetActiveWidgetIndex(0)
  self:SetTextAlpha(false)
  self.UIRoot.HorizontalBox_HPBar:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
  if self.eCurFollowState == uEFollowState.Follower then
    self.UIRoot.CanvasPanel_ParachuteGroup:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
  else
    self.UIRoot.Image_Parachute:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
  end
end
function IngameTeamItemUI:SetInVehicleState()
  if self.bisLostOrExit then
    self.UIRoot.Image_PlayerOffOnline:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
    self.UIRoot.WidgetSwitcher_BG:SetActiveWidgetIndex(1)
    self:SetTextAlpha(true)
    self.UIRoot.HorizontalBox_HPBar:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
  else
    self:SetInPlaneState()
  end
end
function IngameTeamItemUI:SetInRevivalingState()
  self.UIRoot.Image_PlayerFallToTheGround:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
  self.UIRoot.WidgetSwitcher_BG:SetActiveWidgetIndex(0)
  self:SetTextAlpha(false)
  self.UIRoot.HorizontalBox_HPBar:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
end
function IngameTeamItemUI:SetInDiedState()
  self.UIRoot.Image_PlayerDead:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
  self.UIRoot.WidgetSwitcher_BG:SetActiveWidgetIndex(1)
  self:SetTextAlpha(true)
  self.UIRoot.HorizontalBox_HPBar:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.Overlay_Voice:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function IngameTeamItemUI:SetOfflineState()
  self.UIRoot.Image_PlayerOffOnline:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
  if self.UIRoot.CanvasPanel_AITakeOver then
    self.UIRoot.CanvasPanel_AITakeOver:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  self.UIRoot.WidgetSwitcher_BG:SetActiveWidgetIndex(1)
  self:SetTextAlpha(true)
  self.UIRoot.HorizontalBox_HPBar:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
  self.UIRoot.Overlay_Voice:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function IngameTeamItemUI:SetTakeOverState()
  self.UIRoot.Image_PlayerOffOnline:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.CanvasPanel_AITakeOver:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
  self.UIRoot.WidgetSwitcher_BG:SetActiveWidgetIndex(0)
  self:SetTextAlpha(false)
  self.UIRoot.HorizontalBox_HPBar:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
  self.UIRoot.Overlay_Voice:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function IngameTeamItemUI:HideAllStateImagesAndHPbar(ePlayerLiveState, bForceUpdate)
  if not bForceUpdate and self.ePlayerLiveState and self.ePlayerLiveState == ePlayerLiveState then
    return
  end
  self.UIRoot.Image_PlayerDriving:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.Image_PlayerOffOnline:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.Image_Parachute:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.Image_PlayerFallToTheGround:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.Image_PlayerDead:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.HorizontalBox_HPBar:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function IngameTeamItemUI:SetTextAlpha(bIsDead)
  if bIsDead then
    self.UIRoot.TextBlock_PlayerName:SetColorAndOpacity(self.TextAlphaColor[1])
    self.UIRoot.TextBlock_TeamIdx:SetColorAndOpacity(self.TextAlphaColor[1])
  else
    self.UIRoot.TextBlock_PlayerName:SetColorAndOpacity(self.TextAlphaColor[2])
    self.UIRoot.TextBlock_TeamIdx:SetColorAndOpacity(self.TextAlphaColor[2])
  end
end
function IngameTeamItemUI:SetPlayerName(sName, nIndex)
  self.sTeammatePlayerName = sName
  self.UIRoot.TextBlock_PlayerName:SetText(sName)
  if slua.isValid(self.uPlayerState) then
    self.UIRoot.TextBlock_TeamIdx:SetText(nIndex)
  end
end
function IngameTeamItemUI:SetBreathHP(nHP)
  self.UIRoot.ProgressBar_PlayerHP:SetPercent(nHP)
  self.UIRoot.ProgressBar_PlayerHP:SetColorAndOpacity(self.UIRoot.HpColor_Phase3)
end
function IngameTeamItemUI:UpdateVoice(nStatus)
  self.  print(bWriteLog and "TeamPanel_Debug_Msg: Ingame_TeamItem_BP:UpdateVoice  PlayerId = " .. self.nPlayerID .. " Status = " .. tostring(nStatus))
  if nStatus ~= nil and 0 ~= nStatus then
    self.UIRoot.Overlay_Voice:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot.WidgetSwitcher_StateTips:SetActiveWidgetIndex(0)
  else
    self.UIRoot.Overlay_Voice:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function IngameTeamItemUI:EnableVoiceChanger(bVoiceChanged)
  self:SetWidgetVisible(self.UIRoot.VoiceMask, bVoiceChanged)
end
function IngameTeamItemUI:SetParachuteFollowState(ParachuteFollowState)
  local eFollowState = ParachuteFollowState.FollowState
  local nLeaderIdx = ParachuteFollowState.LeaderIdx
  self.eCurFollowState = eFollowState
  self.  if eFollowState == uEFollowState.Follower then
    self.UIRoot.CanvasPanel_ParachuteGroup:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
    self.UIRoot.TextBlock_ParachuteFollowID:SetText(tostring(nLeaderIdx + 1))
    self.UIRoot.Image_Parachute:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    self.UIRoot.CanvasPanel_ParachuteGroup:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    if slua.isValid(self.uPlayerState) and self.uPlayerState.LiveState and self.uPlayerState.LiveState == uEPlayerLiveState.InParachute then
      self.UIRoot.Image_Parachute:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
    end
  end
  self:UpdateAircraftIconShowState()
end
function IngameTeamItemUI:UpdateAircraftIconShowState()
  if not self.UIRoot.CanvasPanel_Aircraft then
    print(bWriteLog and "IngameTeamItemUI:UpdateAircraftIconShowState not self.UIRoot.CanvasPanel_Aircraft")
    return
  end
  local uGameState = GameplayData.GetGameState()
  if not slua.isValid(uGameState) then
    self.UIRoot.CanvasPanel_Aircraft:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    print(bWriteLog and "IngameTeamItemUI:UpdateAircraftIconShowState not uGameState")
    return
  end
  local eGameModeType = uGameState.GameModeType
  local GameModeState = uGameState:GetGameModeState()
  local bIsInReadyState = GameModeState == "ReadyState" or GameModeState == "ActiveState"
  if not bIsInReadyState and self.ePlayerLiveState ~= uEPlayerLiveState.InPlane and self.ePlayerLiveState ~= uEPlayerLiveState.InParachute then
    self.UIRoot.CanvasPanel_Aircraft:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    print(bWriteLog and "IngameTeamItemUI:UpdateAircraftIconShowState not State bIsInReadyState:" .. tostring(bIsInReadyState) .. "LiveState" .. tostring(self.ePlayerLiveState))
    return
  end
  if not self.ParachuteFollowState then
    print(bWriteLog and "IngameTeamItemUI:UpdateAircraftIconShowState not self.ParachuteFollowState")
    self.UIRoot.CanvasPanel_Aircraft:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  if self.ParachuteFollowState.AircraftLeaderIdx > -1 then
    self.UIRoot.CanvasPanel_Aircraft:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
    self.UIRoot.TextBlock_AircraftFollowID:SetText(tostring(self.ParachuteFollowState.AircraftLeaderIdx + 1))
    self.UIRoot.Image_AircraftBG:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
    self.UIRoot.TextBlock_AircraftFollowID:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
  elseif self.ParachuteFollowState.EquipTwoPersonAircraftID > 0 then
    self.UIRoot.CanvasPanel_Aircraft:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
    self.UIRoot.Image_AircraftBG:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.TextBlock_AircraftFollowID:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    self.UIRoot.CanvasPanel_Aircraft:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function IngameTeamItemUI:SwitchGenderIcon(bIsMan)
  if bIsMan then
    self.UIRoot.Image_gender:SetBrush(self.UIRoot.ManIcon)
  else
    self.UIRoot.Image_gender:SetBrush(self.UIRoot.WomenIcon)
  end
end
function IngameTeamItemUI:SetNation(sNation)
  local NationSwitch = import("/Game/UMG/UI_Utility/GlobalBattleUIFunctionLibrary.GlobalBattleUIFunctionLibrary_C")
  local bIsBattle = NationSwitch.GetNationSwitch("Battle")
  local bIsAll = NationSwitch.GetNationSwitch("All")
  local uPlayerController = require("GameLua.GameCore.Data.GameplayData").GetPlayerController()
  local IsHawkEyeSpectator = false
  if uPlayerController and Game:IsClassOf(uPlayerController, import("UAEPlayerController")) then
    IsHawkEyeSpectator = uPlayerController:IsHawkEyeSpectator()
  end
  print(bWriteLog and "TeamPanel_Debug_Msg IngameTeamItemUI:SetNation = " .. sNation)
  if bIsBattle and bIsAll and not IsHawkEyeSpectator then
    self.UIRoot.Image_2:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
    local NationInfo = NationSwitch.GetNationInfoInBattle(sNation)
    local ResourcePath = NationInfo.res_path
    self.UIRoot.Image_2:SetBrushResourceFromPathSync(ResourcePath, false)
  else
    self.UIRoot.Image_2:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
  end
end
function IngameTeamItemUI:DisplayCharStateWhenOperateUAV()
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) and slua.isValid(uPlayerController.PlayerState) and uPlayerController.PlayerState == self.uPlayerState then
    local eUAVCharacterMsgType = uPlayerController.PlayerState.eUAVCharacterMsgType
    print(bWriteLog and "TeamPanel_Debug_Msg: Display CharState When Operator UAV eUAVCharacterMsgType = " .. eUAVCharacterMsgType)
    local UAV = self:GetVehicleUAV()
    self:HideAllUAVTips()
    if eUAVCharacterMsgType == uEUAVCharacterMsgType.UAV_None then
    elseif eUAVCharacterMsgType == uEUAVCharacterMsgType.UAV_VehicleSound then
      self.UIRoot.CarTips:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      if self.bCanShowVehicleTip then
        self:AddGameTimer(5, false, function()
          self.bCanShowVehicleTip = true
        end)
        uPlayerController:DisplayGameTipWithMsgID(50015)
        self.bCanShowVehicleTip = false
      end
      self:PlayUserWidgetAnimation(self.UIRoot.DX_EarlyWarning, 0, 1, 0, 1)
      if slua.isValid(UAV) and self.bCanPlayVehicleSound then
        self:AddGameTimer(20, false, function()
          self.bCanPlayVehicleSound = true
        end)
        local AkEvent = uBusinessHelper.LoadAssetFromPath(TeamPanelConfig.UAV_AkEventPath.UAVVheicleSoundPath)
        uAkGameplayStatics.PostEvent(AkEvent, UAV, false, "")
        self.bCanPlayVehicleSound = false
      end
    elseif eUAVCharacterMsgType == uEUAVCharacterMsgType.UAV_CharacterMoveSound then
      self.UIRoot.footTips:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      if self.bCanShowfootTips then
        self:AddGameTimer(5, false, function()
          self.bCanShowfootTips = true
        end)
        uPlayerController:DisplayGameTipWithMsgID(50016)
        self.bCanShowfootTips = false
      end
      self:PlayUserWidgetAnimation(self.UIRoot.DX_EarlyWarning, 0, 1, 0, 1)
      if slua.isValid(UAV) and self.bCanPlayerMoveSound then
        self:AddGameTimer(20, false, function()
          self.bCanPlayerMoveSound = true
        end)
        local AkEvent = uBusinessHelper.LoadAssetFromPath(TeamPanelConfig.UAV_AkEventPath.UAVMoveSoundPath)
        uAkGameplayStatics.PostEvent(AkEvent, UAV, false, "")
        self.bCanPlayerMoveSound = false
      end
    elseif eUAVCharacterMsgType == uEUAVCharacterMsgType.UAV_BulletSound then
      self.UIRoot.shotTips:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      if self.bCanShowShotTips then
        self:AddGameTimer(5, false, function()
          self.bCanShowShotTips = true
        end)
        uPlayerController:DisplayGameTipWithMsgID(50029)
        self.bCanShowShotTips = false
      end
      self:PlayUserWidgetAnimation(self.UIRoot.DX_EarlyWarning, 0, 1, 0, 1)
      if slua.isValid(UAV) and self.bCanPlayShotSound then
        self:AddGameTimer(20, false, function()
          self.bCanPlayShotSound = true
        end)
        local AkEvent = uBusinessHelper.LoadAssetFromPath(TeamPanelConfig.UAV_AkEventPath.UAVShotSoundPath)
        uAkGameplayStatics.PostEvent(AkEvent, UAV, false, "")
        self.bCanPlayShotSound = false
      end
    elseif eUAVCharacterMsgType == uEUAVCharacterMsgType.UAV_HurtSoud or eUAVCharacterMsgType == uEUAVCharacterMsgType.UAV_PoisonHurtSoud then
      self.UIRoot.hurtTips:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      if self.bCanShowHurtTips then
        self:AddGameTimer(5, false, function()
          self.bCanShowHurtTips = true
        end)
        uPlayerController:DisplayGameTipWithMsgID(50017)
        self.bCanShowHurtTips = false
      end
      self:PlayUserWidgetAnimation(self.UIRoot.DX_EarlyWarning, 0, 1, 0, 1)
      if slua.isValid(UAV) and self.bCanPlayHurtSound then
        self:AddGameTimer(20, false, function()
          self.bCanPlayHurtSound = true
        end)
        local AkEvent = uBusinessHelper.LoadAssetFromPath(TeamPanelConfig.UAV_AkEventPath.UAVHurtSoundPath)
        uAkGameplayStatics.PostEvent(AkEvent, UAV, false, "")
        self.bCanPlayHurtSound = false
      end
    end
  end
end
function IngameTeamItemUI:GetVehicleUAV()
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) then
    local BP_VehicleUser_C = import("/Game/BluePrints/Core/BP_VehicleUser.BP_VehicleUser_C")
    local BP_VehicleUser = uPlayerController:GetComponentByClass(BP_VehicleUser_C)
    if slua.isValid(BP_VehicleUser) and slua.isValid(BP_VehicleUser.UnmannedVehicle) then
      return BP_VehicleUser.UnmannedVehicle
    end
  end
end
function IngameTeamItemUI:HideAllUAVTips()
  self.UIRoot.CarTips:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.footTips:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.hurtTips:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.shotTips:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function IngameTeamItemUI:VehicleIsUAV()
  return slua.isValid(self.uPlayerState) and self.uPlayerState.CurUAVUseType == uEUAVUseType.UAV_Using
end
function IngameTeamItemUI:SetPlayerMatchStragetyLabel(nMatchStrategyLabel, bFollowPanelOpen)
  if 1 ~= nMatchStrategyLabel then
    local OutRow = CDataTable.GetTableData("MatchStrategyConfig", nMatchStrategyLabel)
    if OutRow then
      self.UIRoot.MatchStragetyRoot:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
      self.UIRoot.MatchStragetyText:SetText(OutRow.Name)
      self.UIRoot.MatchStragetyImage:SetBrushFromPathAsync(OutRow.IngameIconPath, false)
      if bFollowPanelOpen then
        self:SetMatchStragetyLabelRootState(false)
      else
        self:SetMatchStragetyLabelRootState(true)
        self:PlayUserWidgetAnimation(self.UIRoot.DX_qipao, 0, 1, 0, 1)
      end
    else
      self.UIRoot.MatchStragetyRoot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end
end
function IngameTeamItemUI:SetMatchStragetyLabelRootState(bShow)
  if bShow then
    self.UIRoot.MatchStragetyTextRoot:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
  else
    self.UIRoot.MatchStragetyTextRoot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function IngameTeamItemUI:HideMatchStragetyRoot()
  self.UIRoot.MatchStragetyTextRoot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function IngameTeamItemUI:UpdateShoot(bShow)
  if bShow then
    self.UIRoot.Image_Shoot:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot.WidgetSwitcher_StateTips:SetActiveWidgetIndex(1)
    if self.UpdateShootTimer then
      self:RemoveGameTimer(self.UpdateShootTimer)
    end
    self.UpdateShootTimer = self:AddGameTimer(0.6, false, function()
      self.UIRoot.Image_Shoot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      self.UpdateShootTimer = nil
    end)
  else
    self.UIRoot.Image_Shoot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function IngameTeamItemUI:InitPlayerColor(LinearColor)
  self.UIRoot.Image_PlayerMark01:SetColorAndOpacity(LinearColor)
  self.UIRoot.Image_IDBG:SetColorAndOpacity(LinearColor)
end
function IngameTeamItemUI:InitPlayerVeteran(bIsShow, bNeedShowVeteran)
  local uPlayerState = self.uPlayerState
  if bNeedShowVeteran and bIsShow and slua.isValid(uPlayerState) then
    local eMentorPlayerType = uPlayerState:GetMentorPlayerType()
    if eMentorPlayerType == uEMentorPlayerType.MPT_NormalPlayer then
      self.UIRoot.WidgetSwitcher_Vetergen:SetActiveWidgetIndex(0)
    elseif eMentorPlayerType == uEMentorPlayerType.MPT_Veteran then
      self.UIRoot.WidgetSwitcher_Vetergen:SetActiveWidgetIndex(1)
      local bIsDead = uPlayerState.LiveState == uEPlayerLiveState.InDied or self.bisLostOrExit
      self:SetTextAlpha(bIsDead)
      local sPath = InGameUITools.GetPlayerVeteranIconPath(uPlayerState)
      uSTExtraUIUtils.SetImageTextureAsync(sPath, self.UIRoot.veteran_normal)
    elseif eMentorPlayerType == uEMentorPlayerType.MPT_Recruit then
      self.UIRoot.WidgetSwitcher_Vetergen:SetActiveWidgetIndex(2)
      local bIsDead = uPlayerState.LiveState == uEPlayerLiveState.InDied or self.bisLostOrExit
      self:SetTextAlpha(bIsDead)
    end
  else
    self.UIRoot.WidgetSwitcher_Vetergen:SetActiveWidgetIndex(0)
  end
end
function IngameTeamItemUI:AddCustomStatusMarkByUIPath(sUIPath, sTag)
  print(bWriteLog and "TeamPanel_Debug_Msg: Try AddCustomStatusMarkByUIPath sTag = " .. sTag .. self.uPlayerState.PlayerName)
  local kismet_string_library = require("common.kismet_string_library")
  local nLen = kismet_string_library.Len(sTag)
  if not (0 < nLen) then
    return
  end
  if self.CustomStatusMapRight[sTag] then
    print(bWriteLog and "TeamPanel_Debug_Msg: AddCustomStatusMarkByUIPath sTag Exist -> return" .. sTag)
    return
  end
  if not self.CustomStatusMapRightLoading[sTag] then
    self.CustomStatusMapRightLoading[sTag] = true
    uSTExtraUIUtils.AsyncCreateWidgetWithCallBack(sUIPath, self.UIRoot, slua.createDelegate(function(widget, InstID)
      if slua.isValid(widget) and slua.isValid(self.UIRoot) then
        self.UIRoot.HorizontalBox_DynamicStatus:AddChildToHorizontalBox(widget)
        widget:InitTeamItemPlayerStateWidget(self.uPlayerState)
        self.CustomStatusMapRightLoading[sTag] = false
        self.CustomStatusMapRight[sTag] = sUIPath
        print(bWriteLog and "TeamPanel_Debug_Msg: AddCustomStatusMark Complete sTag = " .. sTag .. self.uPlayerState.PlayerName)
      end
    end), 0)
  end
end
function IngameTeamItemUI:AddPreCustomStatusMarkByUIPath(sUIPath, sTag)
  print(bWriteLog and "TeamPanel_Debug_Msg: Try AddPreCustomStatusMark sTag = " .. sTag .. self.uPlayerState.PlayerName)
  local kismet_string_library = require("common.kismet_string_library")
  local nLen = kismet_string_library.Len(sTag)
  if not (0 < nLen) then
    return
  end
  if self.CustomStatusMapLeft[sTag] then
    print(bWriteLog and "TeamPanel_Debug_Msg: AddPreCustomStatusMark sTag Exist -> return" .. sTag)
    return
  end
  if not self.CustomStatusMapLeftLoading[sTag] then
    self.CustomStatusMapLeftLoading[sTag] = true
    uSTExtraUIUtils.AsyncCreateWidgetWithCallBack(sUIPath, self.UIRoot, slua.createDelegate(function(widget, InstID)
      if slua.isValid(widget) and slua.isValid(self.UIRoot) and self.UIRoot then
        self.UIRoot.HorizontalBox_PreStatusList:AddChildToHorizontalBox(widget)
        widget:InitTeamItemPlayerStateWidget(self.uPlayerState)
        self.CustomStatusMapLeftLoading[sTag] = false
        self.CustomStatusMapLeft[sTag] = sUIPath
        print(bWriteLog and "TeamPanel_Debug_Msg: AddPreCustomStatusMark Complete sTag = " .. sTag, self.uPlayerState.PlayerName)
      end
    end), 0)
  end
end
function IngameTeamItemUI:AddCustomStatusIconByUIConfig(Config)
  print(bWriteLog and "TeamPanel_Debug_Msg: Try AddCustomStatusIconByUIConfig" .. tostring(Config.Tag))
  if not Config.UIConfig then
    print(bWriteLog and "TeamPanel_Debug_Msg: AddCustomStatusIconByUIConfig Config is nil!")
    return
  end
  local UIConfig = Config.UIConfig
  if type(UIConfig) == "string" then
    UIConfig = UIManager.UI_Config_InGame[UIConfig]
  end
  if not UIConfig then
    print(bWriteLog and "TeamPanel_Debug_Msg: AddCustomStatusIconByUIConfig UIConfig is nil!")
    return
  end
  if slua.isValid(self.UIRoot[Config.Position]) then
    local StateIconUI = self:FindCurrentDynamicIcon(Config)
    if StateIconUI then
      StateIconUI:InitTeamItemPlayerStateWidget(self.uPlayerState)
    else
      StateIconUI = UIManager.ShowUI(UIConfig, self.uPlayerState)
      if StateIconUI then
        table.insert(self.DynamicIconList, {UI = StateIconUI, DynamicConfig = Config})
        self:AttachChildWindow(Config.Position, StateIconUI)
        print(bWriteLog and "TeamPanel_Debug_Msg: AddCustomStatusIconByUIConfig ShowUI!" .. tostring(Config.Tag))
      end
    end
  else
    print(bWriteLog and "TeamPanel_Debug_Msg: AddCustomStatusIconByUIConfig Position widget not valid!" .. tostring(Config.Tag))
  end
end
function IngameTeamItemUI:FindCurrentDynamicIcon(Config)
  local DynamicIconList = self.DynamicIconList
  for _, DynamicIcon in pairs(DynamicIconList) do
    if Config.Tag == DynamicIcon.DynamicConfig.Tag and Config.Position == DynamicIcon.DynamicConfig.Position and DynamicIcon.UI and DynamicIcon.UI.UIRoot then
      return DynamicIcon.UI
    end
  end
end
function IngameTeamItemUI:ClearDynamicIconList()
  for _, DynamicIcon in pairs(self.DynamicIconList) do
    if DynamicIcon.UI then
      DynamicIcon.UI:Close()
    end
    DynamicIcon = nil
  end
  self.DynamicIconList = {}
end
function IngameTeamItemUI:OnAddonSetPlayerState(InPlayerState)
  self:SetAddonPlayerState(InPlayerState, self.UIRoot.CanvasPanel_BountyRevive_Solt)
  self:SetAddonPlayerState(InPlayerState, self.UIRoot.Bounty_TeamGold_Solt)
end
function IngameTeamItemUI:SetAddonPlayerState(InPlayerState, AddonPanel)
  local AddonWidget = AddonPanel:GetAddonWidget(0)
  if slua.isValid(AddonWidget) then
    AddonWidget:OnSetPlayerState(InPlayerState)
  end
end
function IngameTeamItemUI:InitAddonWidget(AddonMap)
  local insert = table.insert
  local AddonWidgetList = self.AddonWidgetList
  for AddonItemName, AddonItemPath in pairs(AddonMap) do
    local uPanel = uBusinessHelper.GetChildByName(self.UIRoot, AddonItemName)
    if slua.isValid(uPanel) then
      local bHasChild = uPanel:HasAnyChild()
      if not bHasChild then
        local uWidget = uSTExtraBlueprintFunctionLibrary.CreateWidgetByPathName(AddonItemPath, self.UIRoot)
        if slua.isValid(uWidget) then
          local uPanelSlot = uPanel:AddChild(uWidget)
          uPanelSlot:SetAutoSize(true)
          insert(AddonWidgetList, uWidget)
        end
      end
    end
  end
  self.end
function IngameTeamItemUI:OnGeneralDataReceived(sDataKey, nDataValue)
  local AddonWidgetList = self.AddonWidgetList
  for _, AddonWidget in pairs(AddonWidgetList) do
    if slua.isValid(AddonWidget) then
      AddonWidget:OnGeneralDataReceived(sDataKey, nDataValue)
    end
  end
end
function IngameTeamItemUI:DelayInitHP()
  local uPlayerState = self.uPlayerState
  if slua.isValid(uPlayerState) then
    local nPercent = uPlayerState:GetPlayerHealthPercent()
    local bIsDying = uPlayerState.LiveState == uEPlayerLiveState.InDied
    self:SetHP(nPercent, bIsDying)
  end
end
function IngameTeamItemUI:ShowDamageEffect(sPUID)
  self.UIRoot.InjurePanel:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
  self:PlayUserWidgetAnimation(self.UIRoot.DX_Injure, 0, 1, 0, 1)
end
function IngameTeamItemUI:OnDamageEffectFinish()
  self.UIRoot.InjurePanel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function IngameTeamItemUI:OnQipaoEffectFinish()
  self:SetMatchStragetyLabelRootState(false)
end
function IngameTeamItemUI:BindPlayerUnderAttack()
  if slua.isValid(self.uPlayerState) then
    local uOwner = self.uPlayerState:GetOwner()
    if slua.isValid(uOwner) then
      local eRole = uOwner:GetRole()
      local uERole = import("ENetRole")
      if eRole == uERole.ROLE_AutonomousProxy then
        return
      end
    end
    self:AddControlEventByControl(self.uPlayerState, "OnPlayerUnderAttack", self.ShowDamageEffect, self)
  end
end
function IngameTeamItemUI:UnBindPlayerUnderAttack()
  if slua.isValid(self.uPlayerState) then
    self:RemoveControlEventByControl(self.uPlayerState, "OnPlayerUnderAttack")
  end
end
function IngameTeamItemUI:OnClickedFollowBtn()
  local uPawn = uSTExtraUIUtils.GetOwningPlayerPawnOrVehicleDriver(self.UIRoot)
  if slua.isValid(uPawn) then
    uPawn:FollowTeammate(self.uPlayerState.PlayerName)
    self:ShowFollowButton(false)
  end
end
function IngameTeamItemUI:SetItemColor()
  if slua.isValid(self.uPlayerState) then
    local nPlayerTeamIndex = self.nIndex
    if 0 < nPlayerTeamIndex and nPlayerTeamIndex < 9 then
      local Color = TeamPanelConfig.TeamPlayerColorTable[nPlayerTeamIndex]
      self:InitPlayerColor(Color)
    end
  end
end
function IngameTeamItemUI:OnEnterSpectating()
  local PlayerController = GameplayData.GetPlayerController()
  if not Game:IsValid(PlayerController) then
    return
  end
  if PlayerController:IsInSpectatingEnemy() then
    self:UpdateVoice()
  end
end
function IngameTeamItemUI:OnGameDataReady()
  local GameState = GameplayData.GetGameState()
  if slua.isValid(GameState) then
    local EGameModeType = import("EGameModeType")
    local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
    local ModType, _ = GameMainConfig.GetModType()
    if GameState.GetGameModeState and GameState:GetGameModeState() == "ReadyState" then
      self.bExitBornIsland = false
    else
      self.bExitBornIsland = true
    end
    local GameModeType = GameState.GameModeType
    if GameModeType ~= EGameModeType.ETypicalGameMode or ModType == "TDM" then
      self.bExitBornIsland = true
    end
  end
end
function IngameTeamItemUI:OnGameStateChange(_, __, State)
  if State == "FightingState" or State == "FinishedState" then
    self.bExitBornIsland = true
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
return class(ui_base, nil, IngameTeamItemUI)