local TeamMapMarkSubsystem = {}
local MapMarkConfig = require("GameLua.Mod.BaseMod.Gameplay.Config.MapMarkConfig")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
function TeamMapMarkSubsystem:OnInit()
  print(bWriteLog and "TeamMapMarkSubsystem:OnInit")
  self.uSelfPlayerController = slua_GameFrontendHUD:GetPlayerController()
  self.uSelfPawn = nil
  if slua.isValid(self.uSelfPlayerController) then
    self.uSelfPawn = self.uSelfPlayerController:GetCurPawn()
  end
  if UIManager.UI_Config_InGame.TeamPanel then
    self.uTeamPanel = UIManager.GetUI(UIManager.UI_Config_InGame.TeamPanel)
  else
    local UIUtil = require("client.common.ui_util")
    self.uTeamPanel = UIUtil.GetWidgetByName("ingamesub", "Ingame_TeamPanel_BP")
  end
  self.MiniMapUI = UIManager.GetUI(UIManager.UI_Config_InGame.MiniMapWindow)
  self.MiniMapData = nil
  self.EntireMapData = nil
  self.MapMarkCache = self.MapMarkCache or {}
  self.LocalPlayerIndex = nil
  self.PlayerStateIndexMap = nil
  self.TeammateMultiMarkCache = self.TeammateMultiMarkCache or {}
  self.TeammateMarkCache = self.TeammateMarkCache or {}
  self.TeammateDiedMarkAction = {}
  self.TeammateRealExitGame = {}
  self:InitMapData()
  self:InitPlayerStateIndexMap()
  self:RegistEventsOnInit()
  self:GetLocalPlayerIndex()
  self:InitModData()
  self.bInit = true
end
function TeamMapMarkSubsystem:OnRelease()
  print(bWriteLog and "TeamMapMarkSubsystem:OnRelease")
  self.uSelfPlayerController = nil
  self.uSelfPawn = nil
  self.uTeamPanel = nil
  self.bInit = false
  self.MiniMapUI = nil
  self.MapMarkCache = nil
  self.EntireMapWidget = nil
  self.MiniMapData = nil
  self.EntireMapData = nil
  self.LocalPlayerIndex = nil
  self.PlayerStateIndexMap = nil
  self.TeammateMultiMarkCache = nil
  self.TeammateMarkCache = nil
  self.TeammateDiedMarkAction = {}
  self.TeammateRealExitGame = {}
  TeamMapMarkSubsystem.__super.OnRelease(self)
end
function TeamMapMarkSubsystem:_PostConstruct()
end
function TeamMapMarkSubsystem:InitModData()
end
function TeamMapMarkSubsystem:RegistEventsOnInit()
  if slua.isValid(self.uSelfPlayerController) then
    self:AddControlEvent(self.uSelfPlayerController, "OnMapMarkChangeDelegate", self.HandleMapMarkChange, self, true)
  end
  self:AddCommonEvent(EVENTTYPE_INGAME_TEAMMATE_PANEL, EVENTID_TEAMMATE_LIVE_STATE_CHANGE, self.OnTeammateLiveStateChanged, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_TEAMMATE_PANEL, EVENTID_TEAMMATE_REAL_EXIT_GAME, self.OnTeammateRealExitGame, self)
  self:AddCommonEventWithConditions(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, {
    [1] = "FightingState"
  }, self.OnEnterBattle, self)
end
function TeamMapMarkSubsystem:CheckCanShowTeammateInfo(uPlayerState)
  return true
end
function TeamMapMarkSubsystem:CheckCanShowTeammateMapMark(uPlayerState)
  if self.TeammateRealExitGame[uPlayerState] then
    return false
  end
  return true
end
function TeamMapMarkSubsystem:ProcessTeammateMarkMod(bCanShow, uPlayerState, PlayerIndex)
end
function TeamMapMarkSubsystem:InitMapData()
  print(bWriteLog and "TeamMapMarkSubsystem:InitMapData")
  if not slua.isValid(self.MiniMapData) then
    if not self.MiniMapUI then
      return
    end
    local MapUIBP = self.MiniMapUI.UIRoot.CurrentMapUIBP
    if slua.isValid(MapUIBP) then
      self.MiniMapData = MapUIBP.CurrentMapData_BP
      if not slua.isValid(self.MiniMapData) then
        print(bWriteLog and "MiniMapData inValid")
        return
      end
    end
  end
  if not slua.isValid(self.EntireMapData) then
    if not UIManager.IsUIShow(UIManager.UI_Config_InGame.EntireMapWindow) then
      self.EntireMapWidget = UIManager.ShowUI(UIManager.UI_Config_InGame.EntireMapWindow)
      UIManager.HideUI(UIManager.UI_Config_InGame.EntireMapWindow)
    else
      self.EntireMapWidget = UIManager.GetUI(UIManager.UI_Config_InGame.EntireMapWindow)
    end
    if self.EntireMapWidget then
      local MapUIBP = self.EntireMapWidget.UIRoot.CurrentMapUIBP
      if slua.isValid(MapUIBP) then
        self.EntireMapData = MapUIBP.CurrentMapData_BP
        if not slua.isValid(self.MiniMapData) then
          print(bWriteLog and "EntireMapData inValid")
          return
        end
      end
    end
  end
end
function TeamMapMarkSubsystem:InitPlayerStateIndexMap()
  self.PlayerStateIndexMap = {}
  if not slua.isValid(self.uSelfPlayerController) then
    self.uSelfPlayerController = slua_GameFrontendHUD:GetPlayerController()
    if not slua.isValid(self.uSelfPlayerController) then
      return
    end
  end
  if not slua.isValid(self.uSelfPawn) then
    self.uSelfPawn = self.uSelfPlayerController:GetPlayerCharacterSafety()
    if not slua.isValid(self.uSelfPawn) then
      return
    end
  end
  local uPlayerState = self.uSelfPlayerController:GetCurPlayerState()
  if not slua.isValid(uPlayerState) then
    return
  end
  local TeammatePlayerStateList = uPlayerState:GetTeamMatePlayerStateList({}, false)
  if TeammatePlayerStateList == nil then
    return
  end
  for k, PlayState in pairs(TeammatePlayerStateList) do
    if slua.isValid(PlayState) then
      self.PlayerStateIndexMap[PlayState] = k
    end
  end
end
function TeamMapMarkSubsystem:GetLocalPlayerIndex()
  print(bWriteLog and "TeamMapMarkSubsystem:GetLocalPlayerIndex")
  if not self.LocalPlayerIndex then
    self.LocalPlayerIndex = 0
    local uGameState = slua_GameFrontendHUD:GetGameState()
    if not slua.isValid(uGameState) then
      return
    end
    if uGameState.IsMapUseTeamPattern and uGameState:IsMapUseTeamPattern() then
      if not slua.isValid(self.uSelfPlayerController) then
        return
      end
      local uPlayerState = self.uSelfPlayerController:GetCurPlayerState()
      if not slua.isValid(uPlayerState) then
        return
      end
      if self.PlayerStateIndexMap and self.PlayerStateIndexMap[uPlayerState] then
        self.LocalPlayerIndex = self.PlayerStateIndexMap[uPlayerState]
      end
    end
  end
end
function TeamMapMarkSubsystem:ProcessOneTeammateMark(uPlayerState)
  if not self.bInit then
    print(bWriteLog and "Not Init")
    return
  end
  if not slua.isValid(uPlayerState) then
    return
  end
  if self:IsSelfPlayerState(uPlayerState) then
    return
  end
  self:InitPlayerStateIndexMap()
  if self.PlayerStateIndexMap and self.PlayerStateIndexMap[uPlayerState] ~= nil then
    local PlayerIndex = self.PlayerStateIndexMap[uPlayerState]
    self:ProcessTeammateMarkMod(uPlayerState, PlayerIndex)
  end
end
function TeamMapMarkSubsystem:ProcessAllTeammateMarkEnterOrLeave()
  if not slua.isValid(self.uSelfPlayerController) then
    self.uSelfPlayerController = slua_GameFrontendHUD:GetPlayerController()
    if not slua.isValid(self.uSelfPlayerController) then
      return
    end
  end
  if not slua.isValid(self.uSelfPawn) then
    self.uSelfPawn = self.uSelfPlayerController:GetPlayerCharacterSafety()
    if not slua.isValid(self.uSelfPawn) then
      return
    end
  end
  local uPlayerState = self.uSelfPlayerController:GetCurPlayerState()
  if not slua.isValid(uPlayerState) then
    return
  end
  local TeammatePlayerStateList = uPlayerState:GetTeamMatePlayerStateList({}, false)
  if TeammatePlayerStateList == nil then
    return
  end
  for k, PlayState in pairs(TeammatePlayerStateList) do
    if slua.isValid(PlayState) then
      self:ProcessOneTeammateMark(PlayState)
    end
  end
end
function TeamMapMarkSubsystem:HandleMapMarkChange(bPlayerChangeMark, MapMarkIndex)
  print(bWriteLog and "TeamMapMarkSubsystem:HandleMapMarkChange", bPlayerChangeMark, MapMarkIndex)
  if not slua.isValid(self.uSelfPawn) then
    return
  end
  if not self.LocalPlayerIndex then
    self:GetLocalPlayerIndex()
  end
  if self.LocalPlayerIndex == MapMarkIndex then
    return
  end
  if slua.isValid(self.uSelfPlayerController) then
    local uPlayerState = self.uSelfPlayerController:GetCurPlayerState()
    if slua.isValid(uPlayerState) then
      local TeammatePlayerStateList = uPlayerState:GetTeamMatePlayerStateList({}, false)
      if TeammatePlayerStateList then
        local Num = TeammatePlayerStateList:Num()
        if 0 < Num and 0 <= MapMarkIndex and MapMarkIndex < Num then
          local uTeammatePlayerState = TeammatePlayerStateList:Get(MapMarkIndex)
          if not slua.isValid(uTeammatePlayerState) then
            return
          end
          local uEPlayerLiveState = import("ExtraPlayerLiveState")
          if bPlayerChangeMark then
            self.TeammateMarkCache[uTeammatePlayerState] = FVector(uTeammatePlayerState.MapMark.X, uTeammatePlayerState.MapMark.Y, uTeammatePlayerState.MapMark.Z)
            local MultiMarkArray = {}
            if uTeammatePlayerState.MapMultiMark then
              local Num = uTeammatePlayerState.MapMultiMark:Num()
              if 0 < Num then
                for i = 0, Num - 1 do
                  table.insert(MultiMarkArray, #MultiMarkArray + 1, uTeammatePlayerState.MapMultiMark:Get(i))
                end
              end
            end
            self.TeammateMultiMarkCache[uTeammatePlayerState] = MultiMarkArray
          end
          local bCanShow = self:CheckCanShowTeammateMapMark(uTeammatePlayerState)
          self:ShowOrHidePlayerMark(bCanShow, uTeammatePlayerState, true)
          self:ShowOrHidePlayerMark(bCanShow, uTeammatePlayerState, false)
          self:ShowOrHidePlayerMultiMark(bCanShow, uTeammatePlayerState, true)
          self:ShowOrHidePlayerMultiMark(bCanShow, uTeammatePlayerState, false)
          self:RedrawAllMapMark(true)
          self:RedrawAllMapMark(false)
        end
      end
    end
  end
end
function TeamMapMarkSubsystem:ShowOrHidePlayerMark(bShow, uPlayerState, bEntireMap)
  print(bWriteLog and "TeamMapMarkSubsystem:ShowOrHidePlayerMark", bShow, bEntireMap)
  if not slua.isValid(uPlayerState) then
    return
  end
  if not bShow then
    local MapMarkHide = FVector(uPlayerState.MapMark.X, uPlayerState.MapMark.Y, -1)
    uPlayerState.MapMark = MapMarkHide
  else
    local MapMarkCache = self.TeammateMarkCache[uPlayerState]
    if MapMarkCache then
      uPlayerState.MapMark = MapMarkCache
    end
  end
end
function TeamMapMarkSubsystem:ShowOrHidePlayerMultiMark(bShow, uPlayerState, bEntireMap)
  if not slua.isValid(uPlayerState) then
    return
  end
  if bShow == false then
    if self.EntireMapWidget then
      local CurrentMapUIBP = self:GetEntireMapUIBP()
      if CurrentMapUIBP then
        CurrentMapUIBP:HandleClickClearMultiMark()
      end
    end
  else
    local MapMultiMarkCache = self.TeammateMultiMarkCache[uPlayerState]
    if MapMultiMarkCache and 0 < #MapMultiMarkCache then
      uPlayerState.MapMultiMark:Clear()
      for i = 1, #MapMultiMarkCache do
        uPlayerState.MapMultiMark:Add(MapMultiMarkCache[i])
      end
    end
  end
end
function TeamMapMarkSubsystem:ShowOrHidePlayerInfoIcon(bShow, MapData, PlayerIndex, bEntireMap)
  print(bWriteLog and "TeamMapMarkSubsystem:ShowOrHidePlayerInfoIcon", bShow, PlayerIndex)
  if not slua.isValid(MapData) then
    return
  end
  if PlayerIndex < 0 or 3 < PlayerIndex then
    return
  end
  local PlayerInfoBPArray = MapData:GetPlayerInfoBPArray()
  if not PlayerInfoBPArray then
    return
  end
  local PlayerInfoNum = PlayerInfoBPArray:Num()
  if PlayerInfoNum == 0 or PlayerIndex >= PlayerInfoNum then
    return
  end
  local PlayerInfoBP = PlayerInfoBPArray:Get(PlayerIndex)
  if slua.isValid(PlayerInfoBP) then
    if bEntireMap then
      if bShow then
        PlayerInfoBP.PlayerInfo:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        PlayerInfoBP.LastRootVisible = true
      else
        PlayerInfoBP.PlayerInfo:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
        PlayerInfoBP.LastRootVisible = false
      end
    elseif bShow then
      PlayerInfoBP.CanvasPanel_SelfPosition:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      PlayerInfoBP.LastRootVisible = true
    else
      PlayerInfoBP.CanvasPanel_SelfPosition:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      PlayerInfoBP.LastRootVisible = false
    end
  end
end
function TeamMapMarkSubsystem:ShowOrHideTeammateSceneMark(PlayerState, bShow)
  if not slua.isValid(PlayerState) then
    return
  end
  if not slua.isValid(self.uTeamPanel) then
    if UIManager.UI_Config_InGame.TeamPanel then
      self.uTeamPanel = UIManager.GetUI(UIManager.UI_Config_InGame.TeamPanel)
    else
      local UIUtil = require("client.common.ui_util")
      self.uTeamPanel = UIUtil.GetWidgetByName("ingamesub", "Ingame_TeamPanel_BP")
    end
    if not slua.isValid(self.uTeamPanel) then
      return
    end
  end
  if UIManager.UI_Config_InGame.TeamPanel then
    for nIndex, TeammatePosItem in pairs(self.uTeamPanel.TeammatePosItemList) do
      if TeammatePosItem and slua.isValid(TeammatePosItem.SavedPlayerState) and TeammatePosItem.SavedPlayerState == PlayerState then
        if bShow then
          TeammatePosItem:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
          break
        end
        TeammatePosItem:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
        break
      end
    end
  else
    for index = 0, self.uTeamPanel.TeammatePosList:Num() - 1 do
      local PosTeammateItem = self.uTeamPanel.TeammatePosList:Get(index)
      if slua.isValid(PosTeammateItem) and slua.isValid(PosTeammateItem.SavedPlayerState) and PosTeammateItem.SavedPlayerState == PlayerState then
        if bShow then
          PosTeammateItem:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
          break
        end
        PosTeammateItem:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
        break
      end
    end
  end
end
function TeamMapMarkSubsystem:RedrawAllMapMark(bEntireMap)
  local MapCurSize, MapUIBase
  if bEntireMap then
    if self.EntireMapData and self.EntireMapData.CurrentMapUI_BP then
      MapCurSize = self.EntireMapData.CurrentMapUI_BP.MapCurSize
    end
    if self.EntireMapData and self.EntireMapData.CurrentMapUI_BP and self.EntireMapData.CurrentMapUI_BP.CurrentMapUI then
      MapUIBase = self.EntireMapData.CurrentMapUI_BP
    end
  else
    if self.MiniMapData and self.MiniMapData.CurrentMapUI_BP then
      MapCurSize = self.MiniMapData.CurrentMapUI_BP.MapCurSize
    end
    if self.MiniMapData and self.MiniMapData.CurrentMapUI_BP and self.MiniMapData.CurrentMapUI_BP.CurrentMapUI then
      MapUIBase = self.MiniMapData.CurrentMapUI_BP
    end
  end
  if MapCurSize and slua.isValid(MapUIBase) and MapUIBase.RedrawAllMapMark then
    MapUIBase:RedrawAllMapMark()
  end
end
function TeamMapMarkSubsystem:IsSelfPlayerState(uPlayerState)
  if not slua.isValid(uPlayerState) then
    return false
  end
  if not slua.isValid(self.uSelfPlayerController) then
    self.uSelfPlayerController = slua_GameFrontendHUD:GetPlayerController()
    if not slua.isValid(self.uSelfPlayerController) then
      return false
    end
  end
  local uSelfPlayerState = self.uSelfPlayerController:GetCurPlayerState()
  if not slua.isValid(uSelfPlayerState) then
    return false
  end
  if uPlayerState == uSelfPlayerState then
    return true
  else
    return false
  end
end
function TeamMapMarkSubsystem:OnTeammateLiveStateChanged(EventType, EventID, TeammateIndex, LiveState)
  local uPlayerController = GameplayData.GetPlayerController()
  if not Game:IsValid(uPlayerController) then
    return
  end
  local uPlayerState = uPlayerController.PlayerState
  if not Game:IsValid(uPlayerState) then
    return
  end
  local ExtraPlayerLiveState = import("ExtraPlayerLiveState")
  if LiveState == ExtraPlayerLiveState.InDied then
    if self.TeammateDiedMarkAction[TeammateIndex] then
      return
    end
    local TeammatePlayerStateList = uPlayerState:GetTeamMatePlayerStateList({}, false)
    if not TeammatePlayerStateList or TeammateIndex >= TeammatePlayerStateList:Num() then
      return
    end
    local TeammatePlayerState = TeammatePlayerStateList:Get(TeammateIndex)
    if TeammatePlayerState and TeammatePlayerState.GetRevivalCount and TeammatePlayerState:GetRevivalCount() > 0 then
      local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")
      self.TeammateDiedMarkAction[TeammateIndex] = InGameMarkTools.ClientAddMapMark(65, TeammatePlayerState:GetPlayerCurLoc(), TeammateIndex)
    end
  elseif LiveState ~= ExtraPlayerLiveState.Offline and self.TeammateDiedMarkAction[TeammateIndex] then
    local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
    local ReviveConfig = GamePlayTools.GetCurrentConfig("ReviveConfig")
    self:AddGameTimer(ReviveConfig.RemovePlayerDiedMarkTime, false, function()
      if self.TeammateDiedMarkAction[TeammateIndex] then
        local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")
        InGameMarkTools.HideMapMark(self.TeammateDiedMarkAction[TeammateIndex])
        self.TeammateDiedMarkAction[TeammateIndex] = nil
      end
    end)
  end
end
function TeamMapMarkSubsystem:OnTeammateRealExitGame(EventType, EventID, TeammateIndex, LiveState)
  print(bWriteLog and "TeamMapMarkSubsystem:OnTeammateRealExitGame TeammateIndex: " .. tostring(TeammateIndex) or "")
  local uPlayerController = GameplayData.GetPlayerController()
  if not Game:IsValid(uPlayerController) then
    return
  end
  local uPlayerState = uPlayerController.PlayerState
  if not Game:IsValid(uPlayerState) then
    return
  end
  local uGameState = GameplayData.GetGameState()
  if not Game:IsValid(uGameState) then
    return
  end
  self:AddGameTimer(MapMarkConfig.RemoveTeammateMarkAfterExitTime, false, function()
    self:HideMarkByIndex(TeammateIndex)
    print(bWriteLog and "TeamMapMarkSubsystem:OnTeammateRealExitGame anfter RemoveTeammateMarkAfterExitTime")
  end)
  print(bWriteLog and "TeamMapMarkSubsystem:OnTeammateRealExitGame")
  local TeammatePlayerStateList = uPlayerState:GetTeamMatePlayerStateList({}, false)
  if not TeammatePlayerStateList then
    print(bWriteLog and "TeamMapMarkSubsystem:OnTeammateRealExitGame TeammatePlayerStateList is empty")
    return
  end
  if TeammateIndex >= TeammatePlayerStateList:Num() then
    self:HideMarkByIndex(TeammateIndex)
    print(bWriteLog and "TeamMapMarkSubsystem:OnTeammateRealExitGame TeammateIndex >= TeammatePlayerStateList:Num")
  end
  local TeammateNum = TeammatePlayerStateList:Num()
  for i = 0, TeammateNum - 1 do
    local PlayerState = TeammatePlayerStateList:Get(i)
    if not slua.isValid(PlayerState) then
      self:HideMarkByIndex(i)
      print(bWriteLog and "TeamMapMarkSubsystem:OnTeammateRealExitGame HideMarkByIndex i=" .. i)
    end
  end
  local PlayerNumPerTeam = uGameState.PlayerNumPerTeam
  for j = TeammateNum, PlayerNumPerTeam - 1 do
    self:HideMarkByIndex(j)
    print(bWriteLog and "TeamMapMarkSubsystem:OnTeammateRealExitGame HideMarkByIndex j=" .. j)
  end
end
function TeamMapMarkSubsystem:HideMarkByIndex(TeammateIndex)
  local FVectorA = import("Vector2D")
  local LocationList = slua.Array(UEnums.EPropertyClass.Struct, FVectorA)
  if self.MiniMapData then
    self.MiniMapData:UpdateMark(TeammateIndex, FVector2D(0, 0), false, 1)
    self.MiniMapData:UpdateMultiMark(TeammateIndex, LocationList, false, 1)
  end
  if self.EntireMapData then
    self.EntireMapData:UpdateMark(TeammateIndex, FVector2D(0, 0), false, 1)
    self.EntireMapData:UpdateMultiMark(TeammateIndex, LocationList, false, 1)
  end
end
function TeamMapMarkSubsystem:OnEnterBattle()
  print(bWriteLog and "TeamMapMarkSubsystem:OnEnterBattle")
  local uGameState = GameplayData.GetGameState()
  if not Game:IsValid(uGameState) then
    return
  end
  local uPlayerController = GameplayData.GetPlayerController()
  if not Game:IsValid(uPlayerController) then
    return
  end
  local uPlayerState = uPlayerController.PlayerState
  if not Game:IsValid(uPlayerState) or not Game:IsValid(uPlayerState.GetTeamMatePlayerStateList) then
    return
  end
  local TeammatePlayerStateList = uPlayerState:GetTeamMatePlayerStateList({}, false)
  if not TeammatePlayerStateList then
    print(bWriteLog and "TeamMapMarkSubsystem:OnEnterBattle TeammatePlayerStateList is empty")
    return
  end
  local TeammateNum = TeammatePlayerStateList:Num()
  local True  for i = 0, TeammateNum - 1 do
    local PlayerState = TeammatePlayerStateList:Get(i)
    if not slua.isValid(PlayerState) then
      TrueTeammateNum = TrueTeammateNum - 1
    end
  end
  local PlayerNumPerTeam = uGameState.PlayerNumPerTeam
  for j = TrueTeammateNum, PlayerNumPerTeam - 1 do
    self:HideMarkByIndex(j)
    print(bWriteLog and "TeamMapMarkSubsystem:OnEnterBattle HideMarkByIndex j=" .. j)
  end
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, TeamMapMarkSubsystem)