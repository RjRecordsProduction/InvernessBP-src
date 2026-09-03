local ReviveBattleUIComponent = {}
local UGameplayStatics = import("GameplayStatics")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")
local LiveState = import("ExtraPlayerLiveState")
local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
function ReviveBattleUIComponent:ctor()
  self.NeedAddTeamateReviveUI = true
  self.bHasAddReviveTeamItemMark = false
  self.AddReviveTeamItemMarkTimer = nil
end
function ReviveBattleUIComponent:ReceiveBeginPlay()
  print(bWriteLog and "ReviveBattleUIComponent:ReceiveBeginPlay", Client)
  self.ReviveTowerMapmarkCache = {}
  self.ReviveTowerScreenMarkID = 1001
  self.ReviveTowerMapMarkID = 62
  self.TeammatePlayerStateList = nil
  self.HasRequestedNames = {}
  self.PlayRequestAnimCD = 3
  self.bIsInCD = false
  self.ShowTipsName = {}
  self.InsistTipsID = 10240
  if not Client then
    self:AddCommonEvent(EVENTTYPE_LIBRARY, EVENTID_LIBRARY_CHANGE_REVIVETOWER_STATE, self.HandleTowerStateChange, self)
  else
    self:AddCommonEvent(EVENTTYPE_INGAME_TEAMMATE_PANEL, EVENTID_TEAMMATE_LIVE_STATE_CHANGE, self.CheckIsShowTowerScreenMark, self)
    self:AddCommonEvent(EVENTTYPE_LIBRARY, EVENTID_LIBRARY_SHOW_REPLY_REVIVE_BTN, self.ShowReplyReviveBtn, self)
    self:AddCommonEvent(EVENTTYPE_LIBRARY, EVENTID_LIBRARY_ONCLICK_REQUEST_REVIVE_BTN, self.OnClickRequestReviveBtn, self)
    self:AddCommonEvent(EVENTTYPE_LIBRARY, EVENTID_LIBRARY_CHECK_SHOW_INSIST_TIPS, self.CheckShowInsistTips, self)
    self:AddCommonEvent(EVENTTYPE_LIBRARY, EVENTID_LIBRARY_CUSTOM_CHECK_REVIVETOWER_MARK, self.OnCustomCheckReviveTowerMark, self)
    self.MyPlayerController = slua_GameFrontendHUD:GetPlayerController()
    if slua.isValid(self.MyPlayerController) then
      if self.MyPlayerController.OnSpectatorChange and self.MyPlayerController.OnPlayerQuitSpectatingForClient then
        self:AddControlEvent(self.MyPlayerController, "OnSpectatorChange", self.OnChangeSpectator, self)
        self:AddControlEvent(self.MyPlayerController, "OnPlayerQuitSpectatingForClient", self.OnPlayerQuitSpectating, self)
      end
      if self.MyPlayerController.OnRepTeammateChange then
        self:AddControlEvent(self.MyPlayerController, "OnRepTeammateChange", self.OnTeammateListChanged, self)
      end
    end
    GameplayData.AddSelfPlayerControllerEvent(self, "OnReconnectResetUIByPlayerControllerStateDelegate", self.OnReconnectResetUI, self)
    local GameState = GameplayData.GetGameState()
    if slua.isValid(GameState) and GameState.GetSuperData then
      self:AddDataListener(GameState:GetSuperData(), "bHaveRevive", function()
        self:CheckIsAddReviveTeamItemMark()
      end)
    end
  end
end
function ReviveBattleUIComponent:SetInsistTipsID(TipsID)
  self.Insist  print(bWriteLog and "ReviveBattleUIComponent:SetInsistTipsID, TipsID = " .. tostring(TipsID))
end
function ReviveBattleUIComponent:CheckShowInsistTips()
  if self.HasShowedTips then
    return
  end
  if slua.isValid(self.MyPlayerController) then
    local uPlayerCharacter = self.MyPlayerController:GetPlayerCharacterSafety()
    if slua.isValid(uPlayerCharacter) and uPlayerCharacter.GetAreaID and uPlayerCharacter:GetAreaID() > 0 then
      return
    end
    local PlayerState = self.MyPlayerController.PlayerState
    if slua.isValid(PlayerState) then
      local CanRevive = (not PlayerState.GetHaveSinglePlayerReviveItem or not PlayerState:GetHaveSinglePlayerReviveItem()) and PlayerState.CanSelfReviveForFree and PlayerState:CanSelfReviveForFree()
      CanRevive = CanRevive and PlayerState.GetRevivalCount and 0 < PlayerState:GetRevivalCount()
      if CanRevive then
        return
      end
    end
    IngameTipsTools.BattleGeneralTip(self.InsistTipsID)
    self.HasShowedTips = true
  end
end
function ReviveBattleUIComponent:OnClickRequestReviveBtn()
  print(bWriteLog and "ReviveBattleUIComponent:OnClickRequestReviveBtn")
  local uGameState = UGameplayStatics.GetGameState(self)
  if uGameState and slua.isValid(uGameState) and uGameState.GetMainTownDestroyTimeStamp and uGameState:GetMainTownDestroyTimeStamp() > 0 then
    local CurrentTime = uGameState:GetServerWorldTimeSeconds()
    local LeftTime = math.ceil(uGameState:GetMainTownDestroyTimeStamp() - CurrentTime)
    if 0 < LeftTime then
      BattleGeneralSAPTip(10265, LeftTime)
      return
    end
  end
  local PlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(PlayerController) then
    PlayerController:SendStringMsg("", 29992, 0, "", 0, 0, true)
  end
end
function ReviveBattleUIComponent:OnChangeSpectator()
  if not Client then
    return
  end
  self.bIsOnSpectator = true
  self.uPlayerState = self.MyPlayerController.PlayerState
  if not slua.isValid(self.uPlayerState) or self.ReviveTowerLocation:Num() <= 0 then
    return
  end
  if not self.uPlayerState.GetTeamMatePlayerStateList then
    return
  end
  self.TeammatePlayerStateList = self.uPlayerState:GetTeamMatePlayerStateList({}, false)
  if not self.ShowNearestTowerTimer then
    self.ShowNearestTowerTimer = self:AddGameTimer(1, true, function()
      self:ShowNearestReviveTower()
    end)
  end
end
function ReviveBattleUIComponent:OnCustomCheckReviveTowerMark()
  print(bWriteLog and "ReviveBattleUIComponent:OnCustomCheckReviveTowerMark")
  self:CheckNeedAddSearchTowerTimer()
end
function ReviveBattleUIComponent:OnReconnectResetUI()
  print(bWriteLog and "ReviveBattleUIComponent:OnReconnectResetUI")
  self:CheckIsAddReviveTeamItemMark()
  self:CheckNeedAddSearchTowerTimer()
end
function ReviveBattleUIComponent:CheckNeedAddSearchTowerTimer()
  if self.TeammatePlayerStateList == nil or self.ReviveTowerLocation:Num() <= 0 then
    return
  end
  print(bWriteLog and "ReviveBattleUIComponent:CheckNeedAddSearchTowerTimer")
  for index, uTeamPlayerState in pairs(self.TeammatePlayerStateList) do
    if slua.isValid(uTeamPlayerState) and uTeamPlayerState.LiveState == LiveState.InDied and uTeamPlayerState.GetRevivalCount and 0 < uTeamPlayerState:GetRevivalCount() then
      self.ShowNearestTowerTimer = self:AddGameTimer(1, true, function()
        self:ShowNearestReviveTower()
      end)
      break
    end
  end
end
function ReviveBattleUIComponent:OnPlayerQuitSpectating()
  self.HasShowedTips = false
  self.bIsOnSpectator = false
  self.uPlayerState = self.MyPlayerController.PlayerState
  if not slua.isValid(self.uPlayerState) or self.ReviveTowerLocation:Num() <= 0 or not self.uPlayerState.GetTeamMatePlayerStateList then
    if self.CurrentScreenMarkInstID then
      InGameMarkTools.HideMapMark(self.CurrentScreenMarkInstID)
      self.CurrentScreenMarkInstID = nil
    end
    if self.ShowNearestTowerTimer then
      self:RemoveGameTimer(self.ShowNearestTowerTimer)
      self.ShowNearestTowerTimer = nil
    end
    self.CurrentLocation = nil
    return
  end
  self.TeammatePlayerStateList = self.uPlayerState:GetTeamMatePlayerStateList({}, false)
  if not self.ShowNearestTowerTimer then
    self.ShowNearestTowerTimer = self:AddGameTimer(1, true, function()
      self:ShowNearestReviveTower()
    end)
  end
end
function ReviveBattleUIComponent:ShowReplyReviveBtn(_, __, PlayerName)
  local IngameLikeClientSubSystem = SubsystemMgr:Get("IngameLikeClientSubSystem")
  if not IngameLikeClientSubSystem then
    return
  end
  if self.HasRequestedNames[PlayerName] == nil then
    if not self.bIsInCD then
      EventSystem:postEvent(EVENTTYPE_LIBRARY, EVENTID_LIBRARY_SHOW_REVIVE_TOWER_ANIM)
      self.bIsInCD = true
      self:AddGameTimer(self.PlayRequestAnimCD, false, function()
        self.bIsInCD = false
      end)
    end
    self.HasRequestedNames[PlayerName] = true
  end
  local IngameLikeUtilClient = require("GameLua.Mod.BaseMod.Client.Like.IngameLikeUtilClient")
  local PlayerState = IngameLikeUtilClient.GetMyPlayerState()
  if not slua.isValid(PlayerState) or PlayerState.LiveState == LiveState.InDied or PlayerState.LiveState == LiveState.InDying then
    return
  end
  local IngameLikeConfig = require("GameLua.Mod.BaseMod.GamePlay.Config.IngameLikeConfig")
  local Message = {}
  Message.PlayerKey = PlayerState.PlayerKey
  Message.OtherPlayerUID = 0
  Message.ConditionID = IngameLikeConfig.Reply
  Message.ItemID = 0
  IngameLikeClientSubSystem:ReceiveTirggerLike(Message)
end
function ReviveBattleUIComponent:CheckIsAddReviveTeamItemMark()
  if not Client then
    return
  end
  local uGameState = GameplayData.GetGameState()
  if not uGameState.bHaveRevive then
    print(bWriteLog and "ReviveBattleUIComponent:CheckIsAddReviveTeamItemMark FAILED Case No Tower")
  end
  if self.bHasAddReviveTeamItemMark then
    return
  end
  self.bHasAddReviveTeamItemMark = true
  local uGameState = GameplayData.GetGameState()
  if slua.isValid(uGameState) and uGameState.PlayerNumPerTeam then
    if uGameState.PlayerNumPerTeam > 1 then
      self:AddReviveTeamItemMark()
    else
      self:ShowSingleReviveUI()
    end
  end
end
function ReviveBattleUIComponent:AddReviveTeamItemMark()
  print(bWriteLog and "ReviveBattleUIComponent:AddReviveTeamItemMark")
  if self.TeammatePlayerStateList == nil or self.TeammatePlayerStateList:Num() == 0 then
    self:InitTeammateList()
  end
  self:RemoveAddReviveTeamItemMarkTimer()
  local uGameState = GameplayData.GetGameState()
  if slua.isValid(uGameState) and uGameState.PlayerNumPerTeam and uGameState.PlayerNumPerTeam > 1 then
    self.AddReviveTeamItemMarkTimer = self:AddGameTimer(1, true, function()
      if not self.NeedAddTeamateReviveUI then
        self:RemoveAddReviveTeamItemMarkTimer()
        return
      end
      self:_TryAddReviveTeamItemMark()
    end)
  end
end
function ReviveBattleUIComponent:_TryAddReviveTeamItemMark()
  if UIManager.UI_Config_InGame.TeamPanel then
    local TeamPanel = UIManager.GetUI(UIManager.UI_Config_InGame.TeamPanel)
    if TeamPanel then
      local TeammateReviveStateIconConfig = {
        UIConfig = UIManager.UI_Config_InGame.TeammateReviveStateIcon,
        Position = "HorizontalBox_Revive",
        Tag = "TeammateReviveStateIcon"
      }
      TeamPanel:AddTeammateStatusIconRegisteConfig(TeammateReviveStateIconConfig)
      self.NeedAddTeamateReviveUI = false
    end
  end
end
function ReviveBattleUIComponent:RemoveAddReviveTeamItemMarkTimer()
  if self.AddReviveTeamItemMarkTimer then
    self:RemoveGameTimer(self.AddReviveTeamItemMarkTimer)
    self.AddReviveTeamItemMarkTimer = nil
  end
end
function ReviveBattleUIComponent:ShowSingleReviveUI()
  local uGameState = GameplayData.GetGameState()
  if slua.isValid(uGameState) and uGameState.PlayerNumPerTeam and uGameState.PlayerNumPerTeam <= 1 and UIManager.UI_Config_InGame.SingleReviveCountUI and not UIManager.GetUI(UIManager.UI_Config_InGame.SingleReviveCountUI) then
    self.NeedAddTeamateReviveUI = false
  end
end
function ReviveBattleUIComponent:GetReviveDisableTime()
  return self.nReviveDisableTime
end
function ReviveBattleUIComponent:CheckIsShowTowerScreenMark(_, __, index)
  if self.TeammatePlayerStateList == nil or index >= self.TeammatePlayerStateList:Num() then
    self:InitTeammateList()
  end
  if self.TeammatePlayerStateList == nil or index >= self.TeammatePlayerStateList:Num() then
    return
  end
  local playerState = self.TeammatePlayerStateList:Get(index)
  if not slua.isValid(playerState) then
    return
  end
  local TeammateName = playerState.playerName or ""
  if playerState.LiveState == LiveState.InDied and playerState.GetRevivalCount and playerState:GetRevivalCount() > 0 and playerState.bCanSelfRevival ~= true and (not playerState.CheckCanShowTip or playerState:CheckCanShowTip()) then
    if 0 < self.ReviveTowerLocation:Num() and not self.ShowNearestTowerTimer and slua.isValid(self.uPlayerState) and self.uPlayerState.LiveState ~= LiveState.InDied then
      if not self:CanShowTowerScreenMark() and not self.ShowTipsName[TeammateName] then
        IngameTipsTools.BattleGeneralTip(10241)
        self.ShowTipsName[TeammateName] = true
      end
      self.ShowNearestTowerTimer = self:AddGameTimer(1, true, function()
        self:ShowNearestReviveTower()
      end)
    end
  else
    self.ShowTipsName[TeammateName] = false
  end
end
function ReviveBattleUIComponent:OnTeammateListChanged()
  print(bWriteLog and "ReviveBattleUIComponent:OnTeammateListChanged")
  self:InitTeammateList()
  self:CheckNeedAddSearchTowerTimer()
end
function ReviveBattleUIComponent:InitTeammateList()
  if not slua.isValid(self.MyPlayerController) then
    self.MyPlayerController = slua_GameFrontendHUD:GetPlayerController()
  end
  if not slua.isValid(self.MyPlayerController) then
    return
  end
  self.uPlayerState = self.MyPlayerController.PlayerState
  if not slua.isValid(self.uPlayerState) or not self.uPlayerState.GetTeamMatePlayerStateList then
    return
  end
  self.TeammatePlayerStateList = self.uPlayerState:GetTeamMatePlayerStateList({}, false)
end
function ReviveBattleUIComponent:HandleTowerStateChange(_, __, location, state, MapMarkID)
  location = FVector(location.X, location.Y, location.Z + 400)
  print(bWriteLog and "ReviveBattleUIComponent:HandleTowerStateChange", MapMarkID, state, location.X, location.Y)
  if state == 1 then
    self:AddReviveTowerMark(location, MapMarkID)
  else
    self:RemoveReviveTowerMark(location, MapMarkID)
  end
end
function ReviveBattleUIComponent:OnRep_ReviveTowerLocation()
  print(bWriteLog and "ReviveBattleUIComponent:OnRep_ReviveTowerLocation")
  self:AddReviveTeamItemMark()
  if not self.ShowNearestTowerTimer then
    if self.TeammatePlayerStateList == nil or self.TeammatePlayerStateList:Num() == 0 then
      self:InitTeammateList()
    end
    self:CheckNeedAddSearchTowerTimer()
  end
end
function ReviveBattleUIComponent:AddReviveTowerMark(Location, MapMarkID)
  if Client then
    print(bWriteLog and "ReviveBattleUIComponent Return")
    return
  end
  if not self.bHasReviveTower then
    self.bHasReviveTower = true
  end
  if MapMarkID then
    self.ReviveTower  else
    self.ReviveTowerLocation:Add(Location)
  end
  local TowerMapMarkInstID = self:CheckHasSameMapMark(Location)
  if not TowerMapMarkInstID then
    local CanvasTag = 0
    local markInstID = InGameMarkTools.ServerAddMapMark(self.ReviveTowerMapMarkID, Location, 0)
    table.insert(self.ReviveTowerMapmarkCache, {markInstID = markInstID, Location = Location})
    print(bWriteLog and "ReviveBattleUIComponent:AddReviveTowerMark-", markInstID, Location.X, Location.Y)
  else
    InGameMarkTools.UpdateMapMarkCustomState(TowerMapMarkInstID, 0)
  end
end
function ReviveBattleUIComponent:RemoveReviveTowerMark(Location, MapMarkID)
  if Client then
    return
  end
  for index = 0, self.ReviveTowerLocation:Num() - 1 do
    local value = self.ReviveTowerLocation:Get(index)
    if value == Location then
      self.ReviveTowerLocation:Remove(index)
      break
    end
  end
  local mapMarkInstID = self:CheckHasSameMapMark(Location)
  print(bWriteLog and "ReviveBattleUIComponent:RemoveReviveTowerMark", MapMarkID, mapMarkInstID, Location.X, Location.Y)
  if mapMarkInstID then
    InGameMarkTools.UpdateMapMarkCustomState(mapMarkInstID, 1)
  elseif MapMarkID then
    self.ReviveTower    local markInstID = InGameMarkTools.ServerAddMapMark(self.ReviveTowerMapMarkID, Location, 1)
    table.insert(self.ReviveTowerMapmarkCache, {markInstID = markInstID, Location = Location})
    print(bWriteLog and "ReviveBattleUIComponent:AddReviveTowerMark-", markInstID, Location.X, Location.Y)
  end
end
function ReviveBattleUIComponent:CheckHasSameMapMark(Location)
  for key, value in pairs(self.ReviveTowerMapmarkCache) do
    if value and value.Location then
      local markLocation = value.Location
      if markLocation.X == Location.X and markLocation.Y == Location.Y and markLocation.Z == Location.Z then
        return value.markInstID
      end
    end
  end
  return nil
end
function ReviveBattleUIComponent:GetNearestReviveTowerLoc()
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return nil
  end
  local uPawnLoc = uPlayerController:GetCurPawnLocation()
  local DistanceNumber = 0
  local minDistance = -1
  local minLocation
  for index = 0, self.ReviveTowerLocation:Num() - 1 do
    local value = self.ReviveTowerLocation:Get(index)
    DistanceNumber = FVector.DistSquaredXY(uPawnLoc, value)
    if minDistance == -1 or minDistance > DistanceNumber then
      minDistance = DistanceNumber
      minLocation = value
    end
  end
  return minLocation
end
function ReviveBattleUIComponent:ShowNearestReviveTower()
  if not Client then
    return
  end
  local diedNum = 0
  local liveNum = 0
  for index, uTeamPlayerState in pairs(self.TeammatePlayerStateList) do
    if slua.isValid(uTeamPlayerState) then
      if uTeamPlayerState.LiveState == LiveState.InDied and uTeamPlayerState.GetRevivalCount and 0 < uTeamPlayerState:GetRevivalCount() then
        diedNum = diedNum + 1
      elseif uTeamPlayerState.LiveState ~= LiveState.InDied then
        liveNum = liveNum + 1
      end
    end
  end
  if not (diedNum ~= 0 and slua.isValid(self.uPlayerState)) or 4 <= liveNum then
    if self.CurrentScreenMarkInstID then
      InGameMarkTools.HideMapMark(self.CurrentScreenMarkInstID)
      self.CurrentScreenMarkInstID = nil
    end
    if self.ShowNearestTowerTimer and not self:CanShowTowerScreenMark() then
      self:RemoveGameTimer(self.ShowNearestTowerTimer)
      self.ShowNearestTowerTimer = nil
    end
    self.CurrentLocation = nil
    return
  end
  if (self.uPlayerState.LiveState == LiveState.InDying or self.uPlayerState.LiveState == LiveState.InDied) and not self:CanShowTowerScreenMark() then
    if self.CurrentScreenMarkInstID then
      InGameMarkTools.HideMapMark(self.CurrentScreenMarkInstID)
      self.CurrentScreenMarkInstID = nil
    end
    self.CurrentLocation = nil
    return
  end
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return
  end
  local uPawnLoc = uPlayerController:GetCurPawnLocation()
  local DistanceNumber = 0
  local minDistance = -1
  local minLocation
  for index = 0, self.ReviveTowerLocation:Num() - 1 do
    value = self.ReviveTowerLocation:Get(index)
    DistanceNumber = FVector.DistSquaredXY(uPawnLoc, value)
    if minDistance == -1 or minDistance > DistanceNumber then
      minDistance = DistanceNumber
      minLocation = value
    end
  end
  if (self.CurrentLocation == nil or self.CurrentLocation ~= minLocation) and minLocation ~= nil then
    if self.CurrentScreenMarkInstID then
      InGameMarkTools.HideMapMark(self.CurrentScreenMarkInstID)
      self.CurrentScreenMarkInstID = nil
    end
    self.CurrentScreenMarkInstID = InGameMarkTools.ClientAddMapMark(self.ReviveTowerScreenMarkID, minLocation, 0, nil, 4)
    self.CurrentLocation = minLocation
  end
end
function ReviveBattleUIComponent:CanShowTowerScreenMark()
  return self.bIsOnSpectator
end
function ReviveBattleUIComponent:ReceiveEndPlay()
  print(bWriteLog and "ReviveBattleUIComponent:ReceiveEndPlay")
  self.TeammatePlayerStateList = {}
  self.ReviveTowerMapmarkCache = {}
  self:Dispose()
end
local class = require("class")
local SubsystemBase = require("common.delegate_container")
return class(SubsystemBase, nil, ReviveBattleUIComponent)