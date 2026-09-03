local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local FProgressBarStyle = import("/Script/SlateCore.ProgressBarStyle")
local FSlateBrush = import("SlateBrush")
local TeammateReviveStateIcon = {}
function TeammateReviveStateIcon:ctor(_, uPlayerState)
  self.uPlayerState = uPlayerState or nil
  self.lastCount = nil
  self.nReviveCount = 0
  self.ProgressBarStyleList = {}
  self.nCurrentReviveStyleID = 0
  self.ProgressFillSlateBrush = nil
  self.ProgressBGSlateBrush = nil
  self.bHaveRevive = false
end
function TeammateReviveStateIcon:OnInitialize()
  TeammateReviveStateIcon.__super.OnInitialize(self)
  print(bWriteLog and "TeammateReviveStateIcon_Debug_Msg: OnInitialize")
  self.IconBGColor = FSlateColor(FLinearColor(0.3, 0.3, 0.3, 0.6))
  self.IconNormalColor = FSlateColor(FLinearColor(1, 1, 1, 1))
  self.ReviveIconConfig = GamePlayTools.GetCurrentConfig("ReviveIconConfig")
end
function TeammateReviveStateIcon:RegistEvents()
  TeammateReviveStateIcon.__super.RegistEvents(self)
  print(bWriteLog and "TeammateReviveStateIcon_Debug_Msg: RegistEvents")
  self:AddCommonEvent(EVENTTYPE_LIBRARY, EVENTID_LIBRARY_ON_REVIVE_COUNT_REP, self.UpdateReviveCount, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, self.RefreshUI, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_REVIVAL_TIME_END_UPDATE, self.RefreshUI, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_REVIVAL_TIME_END, self.OnRevivalTimeEnd, self)
  if Game:IsValid(self.UIRoot.Anim_Num) then
    self:AddControlEventByControl(self.UIRoot.Anim_Num, "OnAnimationFinished", self.UpdateIconState, self)
  end
  local uPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(uPlayerController) then
    self:AddControlEventByControl(uPlayerController, "OnReconnectResetUIByPlayerControllerStateDelegate", self.RefreshUI, self)
  end
  if self.UIRoot.CanvasPanel_0 then
    local GameState = GameplayData.GetGameState()
    if slua.isValid(GameState) and GameState.GetSuperData then
      self:AddDataListener(GameState:GetSuperData(), "bHaveRevive", function(_, bHaveRevive)
        if not self.UIRoot or not self.UIRoot.CanvasPanel_0 then
          return
        end
        self.        if bHaveRevive then
          self.UIRoot.CanvasPanel_0:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
        else
          self.UIRoot.CanvasPanel_0:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
        end
      end)
    end
  end
end
function TeammateReviveStateIcon:OnShow()
  print(bWriteLog and "TeammateReviveStateIcon_Debug_Msg:OnShow")
  self:SetReviveIconStyle()
  self:UpdateReviveCount()
  self:UpdateIconState()
  self:CheckReviveTimeEnd()
end
function TeammateReviveStateIcon:OnClose()
  print(bWriteLog and "TeammateReviveStateIcon_Debug_Msg: OnClose")
  self.uPlayerState = nil
  if self.HideIconTimer then
    self:RemoveGameTimer(self.HideIconTimer)
    self.HideIconTimer = nil
  end
  self:RemoveReviveIconCountingTimer()
  self.ProgressBarStyleList = {}
  self.ProgressFillSlateBrush = nil
  self.ProgressBGSlateBrush = nil
  self.IconBGColor = nil
  self.IconNormalColor = nil
end
function TeammateReviveStateIcon:InitTeamItemPlayerStateWidget(uPlayerState)
  if slua.isValid(uPlayerState) and uPlayerState ~= self.uPlayerState then
    self.  end
  self.lastCount = 0
  self:RefreshUI()
end
function TeammateReviveStateIcon:RefreshUI()
  if not slua.isValid(self.uPlayerState) then
    print(bWriteLog and "TeammateReviveStateIcon_Debug_Msg:RefreshUI FAILED CASE uPlayerState IS NIl")
    return
  end
  print(bWriteLog and "TeammateReviveStateIcon_Debug_Msg:RefreshUI")
  self:UpdateReviveCount()
  self:UpdateIconState()
  self:SetReviveIconStyle()
  self:CheckReviveTimeEnd()
end
function TeammateReviveStateIcon:UpdateReviveCount()
  if not slua.isValid(self.uPlayerState) then
    print(bWriteLog and "TeammateReviveStateIcon_Debug_Msg: FAILED CASE uPlayerState IS NIl")
    return
  end
  if self.UIRoot == nil then
    return
  end
  local UIRoot = self.UIRoot
  self.nReviveCount = self.uPlayerState.GetRevivalCount and self.uPlayerState:GetRevivalCount() or 0
  local nReviveCount = self.nReviveCount
  print(bWriteLog and "TeammateReviveStateIcon_Debug_Msg: GetRevivalCount \239\188\154 ", nReviveCount, self.uPlayerState.PlayerName)
  self.lastCount = nReviveCount
  if Game:IsValid(UIRoot.TextBlock_Num) then
    UIRoot.TextBlock_Num:SetText(tostring(nReviveCount))
    if nReviveCount <= 0 then
      UIRoot.TextBlock_Num:SetColorAndOpacity(self.IconBGColor)
    else
      UIRoot.TextBlock_Num:SetColorAndOpacity(self.IconNormalColor)
    end
  end
  self:SetReviveIconState()
end
function TeammateReviveStateIcon:UpdateIconState()
  local uGameState = GameplayData.GetGameState()
  if slua.isValid(uGameState) then
    local GameModeState = uGameState:GetGameModeState()
    if GameModeState == "FightingState" then
      local RestTime = self:GetReviveRestTime()
      local UIRoot = self.UIRoot
      if 0 < RestTime then
        self:ReviveUpdateTimer()
        self:RemoveReviveIconCountingTimer()
        self.ReviveIconCountingTimer = self:AddGameTimer(self.ReviveIconConfig.UpdateFrequency, true, function()
          self:ReviveUpdateTimer()
        end)
      else
        print(bWriteLog and "TeammateReviveStateIcon_Debug_Msg: Revive Close", RestTime)
        UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(3)
        self:CheckReviveTimeEnd()
      end
    else
      self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(0)
    end
  end
end
function TeammateReviveStateIcon:OnRevivalTimeEnd()
  print(bWriteLog and "TeammateReviveStateIcon_Debug_Msg: OnRevivalTimeEnd")
  if Game:IsValid(self.UIRoot.Anim_Num) then
    self:PlayUserWidgetAnimation(self.UIRoot.Anim_Num, 0, 1, 0, 1)
  end
  if Game:IsValid(self.UIRoot.TextBlock_Num) then
    self.UIRoot.TextBlock_Num:SetText(0)
    self.UIRoot.TextBlock_Num:SetColorAndOpacity(self.IconBGColor)
  end
  self:RemoveReviveIconCountingTimer()
  self.HideIconTimer = self:AddGameTimer(self.ReviveIconConfig.IconHideTime, false, function()
    if slua.isValid(self.UIRoot) then
      self:CheckReviveTimeEnd()
    end
  end)
end
function TeammateReviveStateIcon:CheckReviveTimeEnd()
  local RestTime = self:GetReviveRestTime()
  local uGameState = GameplayData.GetGameState()
  if slua.isValid(uGameState) then
    local GameModeState = uGameState:GetGameModeState() or ""
    if RestTime <= 0 and GameModeState == "FightingState" then
      self:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      print(bWriteLog and "TeammateReviveStateIcon_Debug_Msg: CheckReviveTimeEnd Collapsed")
    end
  end
end
function TeammateReviveStateIcon:SetReviveIconState()
  local RestTime = self:GetReviveRestTime()
  local UIRoot = self.UIRoot
  if self.nReviveCount <= 0 then
    UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(3)
    print(bWriteLog and "TeammateReviveStateIcon_Debug_Msg: SetReviveIconState 3")
  elseif RestTime >= self.ReviveIconConfig.BeginCountingTime then
    UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(0)
    print(bWriteLog and "TeammateReviveStateIcon_Debug_Msg: SetReviveIconState 0")
  else
    if RestTime >= self.ReviveIconConfig.RedWarningTime then
      UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(1)
      print(bWriteLog and "TeammateReviveStateIcon_Debug_Msg: SetReviveIconState 1")
    end
    local nPercent = RestTime / self.ReviveIconConfig.BeginCountingTime
    print(bWriteLog and "TeammateReviveStateIcon_Debug_Msg: nPercent = ", nPercent)
    UIRoot.ProgressBar_1:SetPercent(nPercent)
    UIRoot.ProgressBar_2:SetPercent(nPercent)
  end
end
function TeammateReviveStateIcon:ReviveUpdateTimer()
  local RestTime = self:GetReviveRestTime()
  if RestTime < 0 then
    self:RemoveReviveIconCountingTimer()
    self:CheckReviveTimeEnd()
  else
    self:SetReviveIconState()
  end
end
function TeammateReviveStateIcon:GetReviveRestTime()
  local GameState = GameplayData.GetGameState()
  if not slua.isValid(GameState) then
    return 0
  end
  local ReviveEndTime = 0
  local uGameState = GameplayData.GetGameState()
  if not slua.isValid(uGameState) or not uGameState.ReviveState then
    print(bWriteLog and "TeammateReviveStateIcon_Debug_Msg:GetReviveRestTime GameState = nil")
    return 0
  end
  if GameState.GetReviveEndTime then
    ReviveEndTime = GameState:GetReviveEndTime() or 0
  end
  local CurServerTime = GamePlayTools.GetServerWorldTimeSeconds() or 0
  if ReviveEndTime <= 0 then
    print(bWriteLog and "TeammateReviveStateIcon_Debug_Msg: !!!!!!!!!!Ops ReviveEndTime = ", ReviveEndTime)
  end
  return ReviveEndTime - CurServerTime
end
function TeammateReviveStateIcon:RemoveReviveIconCountingTimer()
  if self.ReviveIconCountingTimer then
    self:RemoveGameTimer(self.ReviveIconCountingTimer)
    self.ReviveIconCountingTimer = nil
    print(bWriteLog and "TeammateReviveStateIcon_Debug_Msg: RemoveReviveIconCountingTimer")
  end
end
function TeammateReviveStateIcon:SetReviveIconStyle()
  if not slua.isValid(self.uPlayerState) or not self.uPlayerState.GetCurrentReviveType then
    print(bWriteLog and "TeammateReviveStateIcon_Debug_Msg: SetReviveIconStyle self.uPlayerState = nil")
    return
  end
  self.nCurrentReviveStyleID = self.uPlayerState:GetCurrentReviveType() or 0
  print(bWriteLog and "TeammateReviveStateIcon_Debug_Msg: SetReviveIconStyle nCurrentReviveStyleID = ", self.uPlayerState:GetCurrentReviveType())
  local ReviveIconStyleConfig = self.ReviveIconConfig.ReviveIconStyleConfig
  if not ReviveIconStyleConfig then
    print(bWriteLog and "TeammateReviveStateIcon_Debug_Msg: SetReviveIconStyle ReviveIconStyleConfig is nil")
    return
  end
  local CurReviveIconStyleConfig = ReviveIconStyleConfig[self.nCurrentReviveStyleID]
  if not CurReviveIconStyleConfig then
    print(bWriteLog and "TeammateReviveStateIcon_Debug_Msg: SetReviveIconStyle CurReviveIconStyleConfig is nil")
    return
  end
  self.UIRoot.Image_Fill:SetBrushfromPathAsync(CurReviveIconStyleConfig.FillIconPath, false)
  self.UIRoot.Image_Blank:SetBrushfromPathAsync(CurReviveIconStyleConfig.BlankIconPath, false)
  self.ProgressFillSlateBrush = nil
  if not self.ProgressBarStyleList[self.nCurrentReviveStyleID] then
    if CurReviveIconStyleConfig.ProgressFillIconPath then
      self:GetAssetAsync(CurReviveIconStyleConfig.ProgressFillIconPath, self.OnSlateBrushLoaded, self, "ProgressFillSlateBrush")
    else
      print(bWriteLog and "TeammateReviveStateIcon_Debug_Msg:ProgressFillIconPath is nil")
    end
    self.ProgressBGSlateBrush = nil
    if CurReviveIconStyleConfig.ProgressBGIconPath then
      self:GetAssetAsync(CurReviveIconStyleConfig.ProgressBGIconPath, self.OnSlateBrushLoaded, self, "ProgressBGSlateBrush")
    else
      print(bWriteLog and "TeammateReviveStateIcon_Debug_Msg:ProgressBGIconPath is nil")
    end
  else
    self:SetReviveIconStyleAsyComplete()
  end
end
function TeammateReviveStateIcon:OnSlateBrushLoaded(sSlateBrushKey, uLoadObject)
  if not slua.isValid(uLoadObject) then
    return
  end
  local SlateBrush = FSlateBrush()
  SlateBrush.ImageSize = FVector2D(30, 30)
  SlateBrush.ResourceObject = uLoadObject
  if sSlateBrushKey == "ProgressBGSlateBrush" then
    SlateBrush.TintColor = self.IconBGColor
  end
  self[sSlateBrushKey] = SlateBrush
  self:SetReviveIconStyleAsyComplete()
end
function TeammateReviveStateIcon:SetReviveIconStyleAsyComplete()
  local nCurrentReviveStyleID = self.nCurrentReviveStyleID or 0
  if self.ProgressFillSlateBrush and self.ProgressBGSlateBrush then
    self.ProgressBarStyleList[nCurrentReviveStyleID] = FProgressBarStyle()
    self.ProgressBarStyleList[nCurrentReviveStyleID].FillImage = self.ProgressFillSlateBrush
    self.ProgressBarStyleList[nCurrentReviveStyleID].BackgroundImage = self.ProgressBGSlateBrush
  end
  if self.ProgressBarStyleList[nCurrentReviveStyleID] then
    self.UIRoot.ProgressBar_1.WidgetStyle = self.ProgressBarStyleList[nCurrentReviveStyleID]
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CTeamPanelWeaponLevel = class(ui_base, nil, TeammateReviveStateIcon)
return CTeamPanelWeaponLevel