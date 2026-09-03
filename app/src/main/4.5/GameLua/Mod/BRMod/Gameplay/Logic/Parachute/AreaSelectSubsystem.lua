local AreaSelectSubsystem = {}
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
local USTExtraMapFunctionLibrary = import("/Script/ShadowTrackerExtra.STExtraMapFunctionLibrary")
local QuickCommandIndex = 68
local TeamMateQuickSignCD = 30
local TeamPlayerFont = {
  [1] = "TeamIdxFont1",
  [2] = "TeamIdxFont2",
  [3] = "TeamIdxFont3",
  [4] = "TeamIdxFont4"
}
local TeamPlayerColor = {
  [1] = FLinearColor(0.645833, 0.550796, 0.029071, 0.9),
  [2] = FLinearColor(0.545724, 0.144128, 0.024158, 0.9),
  [3] = FLinearColor(0.022174, 0.258183, 0.462077, 0.9),
  [4] = FLinearColor(0.104616, 0.371238, 0.028426, 0.9)
}
function AreaSelectSubsystem:ctor()
  AreaSelectSubsystem.__super.ctor(self)
  self.bInitUI = false
end
function AreaSelectSubsystem:OnInit()
  AreaSelectSubsystem.__super.OnInit(self)
  print(bWriteLog and "AreaSelectSubsystem:OnInit")
  self:AddDataListener(GameplayData.GetSuperData(), "GameDataReady", self.OnGameDataReady, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnRepPlayerState", self.OnRepPlayerState, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, self.OnGameStateChange, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_RECEIVE_QUICK_MSG, self.OnReceiveQuickMsg, self)
end
function AreaSelectSubsystem:BindEntireMapUI()
  local EntireMapWindow = UIManager.GetUI(UIManager.UI_Config_InGame.EntireMapWindow)
  if EntireMapWindow then
    local EntireMapUI = EntireMapWindow:GetEntireMapUIBP()
    if EntireMapUI then
      self:AddDataListener(EntireMapUI:GetSuperData(), "MarkLocation", self.OnMarkLocationUpdate, self)
    end
  end
end
function AreaSelectSubsystem:UnBindEntireMapUI()
  if self.bUnBindEntireMapUI then
    return
  end
  local EntireMapWindow = UIManager.GetUI(UIManager.UI_Config_InGame.EntireMapWindow)
  if EntireMapWindow then
    local EntireMapUI = EntireMapWindow:GetEntireMapUIBP()
    if EntireMapUI then
      local SuperData = EntireMapUI:GetSuperData()
      if not self._dataListeners[SuperData] then
        print(bWriteLog and "AreaSelectSubsystem:UnBindEntireMapUI - DataListener SuperData is nil")
        self.bUnBindEntireMapUI = true
        return
      end
      self:RemoveDataListener(SuperData, "MarkLocation")
      self.bUnBindEntireMapUI = true
    end
  end
end
function AreaSelectSubsystem:OnGameDataReady()
  local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
  local ModType, _ = GameMainConfig.GetModType()
  local GameState = GameplayData.GetGameState()
  local EGameModeType = import("EGameModeType")
  if slua.isValid(GameState) then
    local GameModeType = GameState.GameModeType
    print(bWriteLog and "AreaSelectSubsystem:OnGameDataReady - GameModeType is " .. tostring(GameModeType))
    if GameModeType ~= EGameModeType.ETypicalGameMode or ModType == "TDM" then
      local MapType = GameMainConfig.GetMapType()
      if MapType == "Livik" and GameModeType == EGameModeType.EFourInOneGameMode then
        print(bWriteLog and "AreaSelectSubsystem:OnGameDataReady - MapType is Livik")
      else
        print(bWriteLog and "AreaSelectSubsystem:OnGameDataReady - Release Self")
        self:OnRelease()
        return
      end
    end
    local STExtraDelegateMgr = import("/Script/ShadowTrackerExtra.STExtraDelegateMgr")
    local DelegateMgr = STExtraDelegateMgr.STExtraDelegateMgrInstance(GameState)
    self:AddControlEvent(DelegateMgr, "OnCharacterStateChangeDelegate", self.OnCharacterStateChangeDelegate_Handle, self)
  end
end
function AreaSelectSubsystem:OnRepPlayerState()
  local SuperData = self:GetSuperData()
  local bRelease = SuperData.bRelease
  if not self.bInitUI and not bRelease then
    self:InitUI()
  end
end
function AreaSelectSubsystem:InitUI()
  print(bWriteLog and "AreaSelectSubsystem:InitUI")
  local SuperData = self:GetSuperData()
  local bRelease = SuperData.bRelease
  if not self.bIsValid or bRelease then
    print(bWriteLog and "AreaSelectSubsystem:InitUI - Already Release")
    return
  end
  local CurPlayerState = GameplayData.GetPlayerState()
  if not slua.isValid(CurPlayerState) then
    print(bWriteLog and "AreaSelectSubsystem:OnGameDataReady - PlayerState is nil")
    return
  end
  local bIsInPlane, bIsReadyState
  local uPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(uPlayerController) then
    bIsInPlane = uPlayerController:IsInPlane()
  end
  local GameState = GameplayData.GetGameState()
  if slua.isValid(GameState) and GameState.GetGameModeState then
    bIsReadyState = GameState:GetGameModeState() == "ReadyState"
  end
  if bIsInPlane or not bIsReadyState then
    self:OnPreRelease()
    return
  end
  local TeamMatePlayerStateList = CurPlayerState:GetTeamMatePlayerStateList({}, false)
  if TeamMatePlayerStateList:Num() <= 1 then
    return
  end
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if slua.isValid(MainControlBaseUI) and MainControlBaseUI.CanvasPanel_LeadATeam then
    MainControlBaseUI.TextBlock_LeadATeam:SetText(LocUtil.GetLocalizeResStr(817402))
    MainControlBaseUI.CanvasPanel_LeadATeam:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
    local UIUtil = require("client.common.ui_util")
    UIUtil.PlayWidgetAnimation(MainControlBaseUI, "Anim_TeamTips", 0, 0, 0, 1)
  end
  self.bInitUI = true
  self:BindEntireMapUI()
  GameplayData.AddSelfPlayerControllerEvent(self, "OnMapMarkChangeDelegate", self.OnMapMarkChangeDelegate, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnTeamFollowStageChangeDelegate", self.OnTeamFollowStageChangeDelegate, self)
end
function AreaSelectSubsystem:OnReceiveQuickMsg(_, __, bIsSelf, SignType)
  print(bWriteLog and "AreaSelectSubsystem:HandleTeamMapMark")
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  local QuickSignComponent = PlayerController:GetQuickSignComponent()
  if not slua.isValid(QuickSignComponent) or not QuickSignComponent.bCanShowMsg then
    return
  end
  if SignType == QuickCommandIndex then
    if self.bTeamMateQuickSign then
      QuickSignComponent.bCanShowMsg = false
      return
    end
    self.bTeamMateQuickSign = true
    self:AddGameTimer(TeamMateQuickSignCD, false, function()
      self.bTeamMateQuickSign = false
    end)
  end
end
function AreaSelectSubsystem:OnMarkLocationUpdate()
  local SuperData = self:GetSuperData()
  local bRelease = SuperData.bRelease
  if bRelease then
    print(bWriteLog and "AreaSelectSubsystem:OnMarkLocationUpdate - Already Release")
    return
  end
  print(bWriteLog and "AreaSelectSubsystem:OnMarkLocationUpdate")
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  local QuickSignComponent = PlayerController:GetQuickSignComponent()
  if not slua.isValid(QuickSignComponent) then
    return
  end
  if not self.bQuickSign then
    QuickSignComponent:MakeQuickCommand(QuickCommandIndex)
    self.bQuickSign = true
  end
end
function AreaSelectSubsystem:OnMapMarkChangeDelegate(PlayerIndex)
  print(bWriteLog and string.format("AreaSelectSubsystem:OnMapMarkChangeDelegate - PlayerIndex %s", tostring(PlayerIndex)))
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if slua.isValid(MainControlBaseUI) and MainControlBaseUI.CanvasPanel_LeadATeam then
    MainControlBaseUI.CanvasPanel_LeadATeam:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function AreaSelectSubsystem:OnTeamFollowStageChangeDelegate()
  local SuperData = self:GetSuperData()
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(PlayerCharacter) then
    local nPlayerIndex = PlayerCharacter:GetPlayerTeamIndex()
    local TeammateParachuteFollowStateList = PlayerCharacter.TeammateParachuteFollowState
    local LoopIndex = 0
    local CaptainIndex
    for Index, TeammateFPS in pairs(TeammateParachuteFollowStateList) do
      LoopIndex = LoopIndex + 1
      if TeammateFPS.FollowState == 2 then
        local LeaderIdx = TeammateFPS.LeaderIdx
        if CaptainIndex == nil then
          CaptainIndex = LeaderIdx
        elseif CaptainIndex ~= LeaderIdx then
          CaptainIndex = nil
          break
        end
      elseif TeammateFPS.FollowState == 0 then
        CaptainIndex = nil
        break
      end
    end
    local BirthIslandTips = UIManager.GetUI(UIManager.UI_Config_InGame.BirthIslandTips)
    if LoopIndex == TeammateParachuteFollowStateList:Num() and CaptainIndex ~= nil then
      SuperData.      local CurPlayerState = GameplayData.GetPlayerState()
      if not slua.isValid(CurPlayerState) then
        print(bWriteLog and "AreaSelectSubsystem:OnTeamFollowStageChangeDelegate - PlayerState is nil")
        return
      end
      local CaptainName = CurPlayerState.PlayerName
      if nPlayerIndex == CaptainIndex and BirthIslandTips then
        CaptainIndex = CaptainIndex + 1
        local CaptainColor = TeamPlayerColor[CaptainIndex]
        local Text = string.format("  <%s>%s</> <img src=\"Captain_Icon\"/> %s", TeamPlayerFont[CaptainIndex], CaptainName, LocUtil.GetLocalizeResStr(817404))
        BirthIslandTips:SetCaptainText(Text, CaptainIndex, CaptainColor)
        return
      end
    end
    if CaptainIndex ~= nil then
      SuperData.    else
      SuperData.CaptainIndex = -5
    end
    if BirthIslandTips then
      BirthIslandTips:SetCaptainText(nil, nil, nil)
    end
  end
end
function AreaSelectSubsystem:OnGameStateChange(_, __, sState)
  print(bWriteLog and "AreaSelectSubsystem:OnGameStateChange", sState)
  if sState == "FightingState" or sState == "FinishedState" then
    self:OnPreRelease()
  end
end
function AreaSelectSubsystem:OnCharacterStateChangeDelegate_Handle(LiveState, uTargetCharacter)
  local SuperData = self:GetSuperData()
  local bRelease = SuperData.bRelease
  if bRelease then
    print(bWriteLog and "AreaSelectSubsystem:OnCharacterStateChangeDelegate_Handle - Already Release")
    return
  end
  print(bWriteLog and "AreaSelectSubsystem:OnCharacterStateChangeDelegate_Handle")
  local bIsInPlane, bIsReadyState
  local uPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(uPlayerController) then
    bIsInPlane = uPlayerController:IsInPlane()
  end
  local GameState = GameplayData.GetGameState()
  if slua.isValid(GameState) and GameState.GetGameModeState then
    bIsReadyState = GameState:GetGameModeState() == "ReadyState"
  end
  if not bIsInPlane and not bIsReadyState then
    self:OnRelease()
  end
  if bIsInPlane then
    self:UnBindEntireMapUI()
  end
end
function AreaSelectSubsystem:OnPreRelease()
  print(bWriteLog and "AreaSelectSubsystem:OnPreRelease")
  self.bInitUI = true
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if slua.isValid(MainControlBaseUI) and MainControlBaseUI.CanvasPanel_LeadATeam then
    MainControlBaseUI.CanvasPanel_LeadATeam:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function AreaSelectSubsystem:UnRegistBPEvents()
  print(bWriteLog and "AreaSelectSubsystem:UnRegistBPEvents")
  if self._controlEvents then
    for control, controlEvents in pairs(self._controlEvents) do
      if controlEvents then
        for eventName, funcDelegate in pairs(controlEvents) do
          if funcDelegate then
            if type(control) == "table" or slua.isValid(control) then
              local eventDelegate = control[eventName]
              if slua.isValid(eventDelegate) then
                if eventDelegate.Remove then
                  eventDelegate:Remove(funcDelegate)
                else
                  eventDelegate:Clear()
                end
                controlEvents[eventName] = nil
              end
            end
            slua.removeDelegate(funcDelegate)
          end
        end
      end
    end
  end
  self._controlEvents = nil
end
function AreaSelectSubsystem:OnRelease()
  print(bWriteLog and "AreaSelectSubsystem:OnRelease")
  local SuperData = self:GetSuperData()
  SuperData.bRelease = true
  self:OnPreRelease()
  self:UnRegistBPEvents()
  AreaSelectSubsystem.__super.OnRelease(self)
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, AreaSelectSubsystem)