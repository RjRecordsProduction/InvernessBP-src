local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local Enum = require("GameLua.Mod.GodTrial.Gameplay.Config.EnumDefine")
local GodTrialConfig = require("GameLua.Mod.GodTrial.Gameplay.Config.GodTrialConfig")
local PlayerStateHonorFeature = {
  ServerRPC = {},
  ClientRPC = {},
  MulticastRPC = {},
  LuaEventContainer = {
    "OnRep_TeamTotalScore"
  }
}
function PlayerStateHonorFeature:GetLifetimeReplicatedProps()
  local ELifetimeCondition = import("ELifetimeCondition")
  local RepTable = {
    {
      "TypeScoreList",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Array,
      UEnums.EPropertyClass.Float
    },
    {
      "TeamTotalScore",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Float
    },
    {
      "PlayerHonorState",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Int
    },
    {
      "TeamGoldenCoinCount",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Int
    }
  }
  return RepTable
end
function PlayerStateHonorFeature:_PostConstruct()
  PlayerStateHonorFeature.__super._PostConstruct(self)
  self.Value2Name = {}
  self.IsInBossArea = false
  self.IsInFlameChariot = false
  self.InviteValidTime = 0
  if self:HasAuthority() then
    for Name, Value in pairs(Enum.EHonorType) do
      self.TypeScoreList:Add(0)
    end
    self.TeamKillScore = 0
    self.TeamGodTrialScore = 0
    self.TeamFireAltarScore = 0
    self.TeamTotalScore = 0
    self.GoldenCoinCount = 0
    self.TeamGoldenCoinCount = 0
    self.PlayerHonorState = Enum.EHonorArenaState.None
  end
end
function PlayerStateHonorFeature:ReceiveBeginPlay()
  PlayerStateHonorFeature.__super.ReceiveBeginPlay(self)
  print(bWriteLog and "PlayerStateHonorFeature:ReceiveBeginPlay")
  self:InitConfig()
  if self:HasAuthority() and self.MapConfig then
    self:TriggerTeamHonorUpdate()
  end
  if Client then
    local SuperData = GameplayData.GetSuperData()
    self:AddDataListener(SuperData, "CharacterDataReady", function()
      self:OnRep_PlayerHonorState()
    end)
    print(bWriteLog and "PlayerStateHonorFeature:ReceiveBeginPlay - Client")
  end
end
function PlayerStateHonorFeature:InitConfig()
  local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
  local MapType = GameMainConfig.GetMapType()
  if MapType == "Neon" then
    print(bWriteLog and "PlayerStateHonorFeature:InitConfig - MapType=Neon")
    return
  end
  self.MapConfig = GodTrialConfig.GetMapConfig(MapType)
  if not self.MapConfig then
    print(bWriteLog and "PlayerStateHonorFeature:InitConfig - MapConfig not found")
    return
  end
end
function PlayerStateHonorFeature:GetScore(Type)
  return self.TypeScoreList:Get(Type)
end
function PlayerStateHonorFeature:GetTotalScore()
  local TotalScore = 0
  for _, Score in pairs(self.TypeScoreList) do
    TotalScore = TotalScore + Score
  end
  return TotalScore
end
function PlayerStateHonorFeature:AddScore(Type, Score)
  local CurrentScore = self:GetScore(Type)
  local FinalScore = CurrentScore + Score
  self.TypeScoreList:Set(Type, FinalScore)
  print(bWriteLog and string.format("PlayerStateHonorFeature:AddScore PlayerName = %s, Type = %s, Score = %s + %s = %s", self.Owner.PlayerName, Type, CurrentScore, Score, FinalScore))
  if self:HasAuthority() then
    self:TriggerTeamHonorUpdate(false)
  end
  self:ForceNetUpdate()
end
function PlayerStateHonorFeature:AddCoin(nCount)
  self.GoldenCoinCount = self.GoldenCoinCount + nCount
  print(bWriteLog and string.format("PlayerStateHonorFeature:AddCoin PlayerName = %s, FinalCoin = %s", self.Owner.PlayerName, self.GoldenCoinCount))
  if self:HasAuthority() then
    self:TriggerTeamHonorUpdate(true)
  end
end
function PlayerStateHonorFeature:DropGoldenCoins(uPlayerCharacter)
  if not self:HasAuthority() then
    return
  end
  local nCoinCount = self.GoldenCoinCount
  if nCoinCount <= 0 then
    return
  end
  if not slua.isValid(uPlayerCharacter) or not slua.isValid(CGameWorld) then
    print(bWriteLog and string.format("PlayerStateHonorFeature:DropGoldenCoins PlayerName = %s, invalid character or world", self.Owner.PlayerName))
    return
  end
  if self.PlayerHonorState > Enum.EHonorArenaState.FlameChariotWaiting then
    print(bWriteLog and string.format("PlayerStateHonorFeature:DropGoldenCoins PlayerName = %s, PlayerHonorState = %s, not in arena", self.Owner.PlayerName, self.PlayerHonorState))
    return
  end
  local CoinClass = slua.loadClass(GodTrialConfig.ArenaGoldenCoinClass)
  if not CoinClass then
    print(bWriteLog and string.format("PlayerStateHonorFeature:DropGoldenCoins failed to load CoinClass"))
    return
  end
  local BaseLocation = uPlayerCharacter:K2_GetActorLocation()
  local UKismetMathLibrary = import("KismetMathLibrary")
  for i = 1, nCoinCount do
    local OffsetX = UKismetMathLibrary.RandomFloatInRange(-80, 80)
    local OffsetY = UKismetMathLibrary.RandomFloatInRange(-80, 80)
    local SpawnLocation = FVector(BaseLocation.X + OffsetX, BaseLocation.Y + OffsetY, BaseLocation.Z)
    CGameWorld:SpawnActor(CoinClass, SpawnLocation, FRotator(0, 0, 0), nil)
  end
  self.GoldenCoinCount = 0
  self:TriggerTeamHonorUpdate(true)
  print(bWriteLog and string.format("PlayerStateHonorFeature:DropGoldenCoins PlayerName = %s, dropped %s coins at %s", self.Owner.PlayerName, nCoinCount, BaseLocation:ToString()))
  self:_NotifyTeammatesGoldenCoinDropped(uPlayerCharacter)
end
function PlayerStateHonorFeature:_NotifyTeammatesGoldenCoinDropped(uPlayerCharacter)
  if not self:HasAuthority() or not slua.isValid(uPlayerCharacter) then
    return
  end
  local TeammateList = Game:GetTeamMatePlayerStateList(uPlayerCharacter.PlayerKey, true)
  for _, Teammate in pairs(TeammateList) do
    if slua.isValid(Teammate) and Teammate.PlayerStateHonorFeature then
      local tCharacter = Teammate:GetPlayerCharacter()
      if slua.isValid(tCharacter) and Game:IsAlive(tCharacter) then
        local HonorState = Teammate.PlayerStateHonorFeature.PlayerHonorState
        if HonorState >= Enum.EHonorArenaState.GoldenCollecting and HonorState <= Enum.EHonorArenaState.FlameChariotRunning then
          print(bWriteLog and string.format("PlayerStateHonorFeature:_NotifyTeammatesGoldenCoinDropped notify %s", Teammate.PlayerName))
          Game:UIShowImageTips(Teammate.PlayerKey, 4401019)
        end
      end
    end
  end
end
function PlayerStateHonorFeature:GetGoldenCoin()
  return self.GoldenCoinCount
end
function PlayerStateHonorFeature:TriggerTeamHonorUpdate(bGoldenCoin)
  if not self:HasAuthority() then
    return
  end
  local GameState = GameplayData.GetGameState()
  if not slua.isValid(GameState) then
    return
  end
  local TeamHonorFeature = GameState.GameStateTeamHonorFeature
  if not TeamHonorFeature then
    return
  end
  local TeamID = self.Owner.TeamID
  if bGoldenCoin then
    TeamHonorFeature:UpdateTeamGoldenCoin(TeamID, self.GoldenCoinCount)
  else
    TeamHonorFeature:UpdateTeamHonorData(TeamID)
  end
end
PlayerStateHonorFeature.ClientRPC.RPC_Client_PromptCharacterTeleport = {
  Reliable = true,
  Params = {}
}
function PlayerStateHonorFeature:RPC_Client_PromptCharacterTeleport()
  local Config = self.MapConfig
  local PromptTextIds = Config.FlameChariotInviteTipID
  local CountdownTime = Config.FlameChariotActiveWaitTime
  local ConfirmInfo = {
    Style = "Simple",
    Content = LocUtil.GetLocalizeResStr(PromptTextIds.Content),
    LeftLable = LocUtil.GetLocalizeResStr(PromptTextIds.Reject),
    RightLable = LocUtil.GetLocalizeResStr(PromptTextIds.Accept),
    LeftCountDownTime = CountdownTime,
    RightCountDownTime = CountdownTime,
    CountDownEndTime = CountdownTime + CGameState:GetServerWorldTimeSeconds(),
    RightLableColorAndOpacity = FSlateColor(FLinearColor(1, 0.723055, 0.015209, 1))
  }
  function ConfirmInfo.RightCB()
    print(bWriteLog and "PlayerStateHonorFeature:RPC_Client_PromptCharacterTeleport, Confirm Teleport")
    self:RPC_Server_CharacterComfirmTeleport()
  end
  function ConfirmInfo.CloseCB()
    print(bWriteLog and "PlayerStateHonorFeature:RPC_Client_PromptCharacterTeleport, Close")
  end
  local CommonConfirm = require("GameLua.Mod.BaseMod.Common.Confirm.CommonConfirm")
  CommonConfirm.ShowConfirm(ConfirmInfo)
end
PlayerStateHonorFeature.ServerRPC.RPC_Server_CharacterComfirmTeleport = {
  Reliable = true,
  Params = {}
}
function PlayerStateHonorFeature:RPC_Server_CharacterComfirmTeleport()
  if self.InviteValidTime < 0 then
    print(bWriteLog and "PlayerStateHonorFeature:RPC_Server_CharacterComfirmTeleport self.InviteValidTime invalid")
    return
  end
  local nCurTime = CGameState:GetServerWorldTimeSeconds()
  if nCurTime > self.InviteValidTime then
    print(bWriteLog and string.format("PlayerStateHonorFeature:RPC_Server_CharacterComfirmTeleport nCurTime[%s] invalid self.InviteValidTime[%s]", tostring(nCurTime), tostring(self.InviteValidTime)))
    return
  end
  self.InviteValidTime = -1.0
  local PlayerCharacter = self.Owner:GetPlayerCharacter()
  if not (slua.isValid(CGameMode) and CGameMode.DungeonFeature) or not slua.isValid(PlayerCharacter) then
    return
  end
  CGameMode.DungeonFeature:PlayerEnterFlameChariot(PlayerCharacter)
  print(bWriteLog and "PlayerStateHonorFeature:RPC_Server_CharacterComfirmTeleport, Confirm Teleport")
end
function PlayerStateHonorFeature:SetPlayerHonorState(HonorState)
  self.Playerend
function PlayerStateHonorFeature:OnRep_TypeScoreList()
  local TypeScoreListTable = Game:ArrayToTable(self.TypeScoreList)
  print(bWriteLog and string.format("PlayerStateHonorFeature:OnRep_TypeScoreList {%s}", table.concat(TypeScoreListTable, ", ")))
end
function PlayerStateHonorFeature:OnRep_TeamTotalScore()
  print(bWriteLog and string.format("PlayerStateHonorFeature:OnRep_TeamTotalScore TeamTotalScore = %s", self.TeamTotalScore))
  self:LuaBroadcast("OnRep_TeamTotalScore", self.TeamTotalScore)
  local SuperData = self.Owner:GetSuperData()
  if SuperData then
    SuperData.TeamTotalScore = self.TeamTotalScore
  end
end
function PlayerStateHonorFeature:OnRep_PlayerHonorState(OldValue)
  print("PlayerStateHonorFeature:OnRep_PlayerHonorState NewValue = %s", self.PlayerHonorState)
  local SuperData = self.Owner:GetSuperData()
  if SuperData then
    SuperData.PlayerHonorState = self.PlayerHonorState
  end
  local Character = GameplayData.GetPlayerCharacter(self.Owner.PlayerKey)
  if not slua.isValid(Character) then
    return
  end
  print(bWriteLog and string.format("Player:OnRep_PlayerHonorState OldValue = %s, NewValue = %s Character:%s", OldValue, self.PlayerHonorState, Character:GetPlayerNameSafety()))
  if not Character:IsLocallyControlled() and not Character:IsLocalViewed() then
    return
  end
  print(bWriteLog and string.format("Player:OnRep_PlayerHonorState IsLocallyControlled "))
  local bOnArenaIsland = self.PlayerHonorState == Enum.EHonorArenaState.GoldenCollecting or self.PlayerHonorState == Enum.EHonorArenaState.GoldenFinished or self.PlayerHonorState == Enum.EHonorArenaState.FlameChariotWaiting
  if bOnArenaIsland then
    local AATrialUIPanel = UIManager.GetUI(UIManager.UI_Config_InGame.AATrialUIPanel)
    if AATrialUIPanel then
      AATrialUIPanel:UpdatePanelInfo()
    else
      AATrialUIPanel = UIManager.ShowUI(UIManager.UI_Config_InGame.AATrialUIPanel)
      AATrialUIPanel:UpdatePanelInfo()
    end
    local GodTrialMapUI = UIManager.GetUI(UIManager.UI_Config_InGame.GodTrialMapUI)
    GodTrialMapUI = GodTrialMapUI or UIManager.ShowUI(UIManager.UI_Config_InGame.GodTrialMapUI)
    if GodTrialMapUI then
      GodTrialMapUI:UpdatePanelInfo()
    end
  else
    local AATrialUIPanel = UIManager.GetUI(UIManager.UI_Config_InGame.AATrialUIPanel)
    if AATrialUIPanel then
      UIManager.HideUI(UIManager.UI_Config_InGame.AATrialUIPanel)
    end
    local GodTrialMapUI = UIManager.GetUI(UIManager.UI_Config_InGame.GodTrialMapUI)
    if GodTrialMapUI then
      UIManager.HideUI(UIManager.UI_Config_InGame.GodTrialMapUI)
    end
  end
  if self.PlayerHonorState == Enum.EHonorArenaState.BossAreaSuccess then
    self:AddGameTimer(5, false, function()
      local ClientGameMain = require("GameLua.GameCore.Main.ClientGameMain")
      local bReplay = ClientGameMain.IsReplayClient() or Game:IsInReplayBack()
      local BATrialLeaveUIPanel = UIManager.GetUI(UIManager.UI_Config_InGame.BATrialLeaveUIPanel)
      if not BATrialLeaveUIPanel and not bReplay then
        BATrialLeaveUIPanel = UIManager.ShowUI(UIManager.UI_Config_InGame.BATrialLeaveUIPanel)
      end
    end)
  else
    local BATrialLeaveUIPanel = UIManager.GetUI(UIManager.UI_Config_InGame.BATrialLeaveUIPanel)
    if BATrialLeaveUIPanel then
      UIManager.HideUI(UIManager.UI_Config_InGame.BATrialLeaveUIPanel)
    end
  end
  if self.PlayerHonorState > Enum.EHonorArenaState.BossAreaFighting then
    local IngameCentaurBossHPUI = UIManager.GetUI(UIManager.UI_Config_InGame.IngameCentaurBossHPUI)
    if IngameCentaurBossHPUI then
      UIManager.HideUI(UIManager.UI_Config_InGame.IngameCentaurBossHPUI)
      print(bWriteLog and "PlayerStateHonorFeature:OnRep_PlayerHonorState HideUI IngameCentaurBossHPUI")
    end
  end
end
function PlayerStateHonorFeature:OnRep_TeamGoldenCoinCount()
  local Character = self.Owner:GetPlayerCharacter()
  if not slua.isValid(Character) then
    return
  end
  if not Character:IsLocallyControlled() and not Character:IsLocalViewed() then
    return
  end
  if self.PlayerHonorState ~= Enum.EHonorArenaState.GoldenCollecting and self.PlayerHonorState ~= Enum.EHonorArenaState.GoldenFinished then
    print(bWriteLog and string.format("PlayerStateHonorFeature:OnRep_TeamGoldenCoinCount TeamGoldenCoinCount = %s self.PlayerHonorState = %s", self.TeamGoldenCoinCount, self.PlayerHonorState))
    return
  end
  print(bWriteLog and string.format("PlayerStateHonorFeature:OnRep_TeamGoldenCoinCount TeamGoldenCoinCount = %s", self.TeamGoldenCoinCount))
  local AATrialUIPanel = UIManager.GetUI(UIManager.UI_Config_InGame.AATrialUIPanel)
  if AATrialUIPanel then
    AATrialUIPanel:UpdatePanelInfo()
  end
  local GodTrialMapUI = UIManager.GetUI(UIManager.UI_Config_InGame.GodTrialMapUI)
  if GodTrialMapUI then
    GodTrialMapUI:UpdatePanelInfo()
  end
end
function PlayerStateHonorFeature:GetMaxGoldenCoinCount()
  return self.MapConfig.ArenaOpenNeedCoinNum
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
return class(CFeatureBase, nil, PlayerStateHonorFeature)