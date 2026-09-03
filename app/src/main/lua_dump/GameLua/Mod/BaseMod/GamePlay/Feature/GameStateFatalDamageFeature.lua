local EFatalDamageRelationShip = import("EFatalDamageRelationShip")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local GameStateFatalDamageFeature = {
  ServerRPC = {},
  ClientRPC = {},
  MulticastRPC = {}
}
GameStateFatalDamageFeature.MulticastRPC.MulticastRPC_BroadcastFatalDamageToClientForLua = {
  Reliable = true,
  Params = {
    import("FatalDamageParameterCompress"),
    {
      UEnums.EPropertyClass.Array,
      UEnums.EPropertyClass.Byte
    }
  }
}
function GameStateFatalDamageFeature:ctor()
  self.FatalDamageIDTable = {}
end
function GameStateFatalDamageFeature:ReceiveBeginPlay()
  GameStateFatalDamageFeature.__super.ReceiveBeginPlay(self)
end
function GameStateFatalDamageFeature:MulticastRPC_BroadcastFatalDamageToClientForLua(FatalDamageParameter, ExtraInfoByteArray)
  print(bWriteLog and "MulticastRPC_BroadcastFatalDamageToClientForLua 0 000")
  if not Client then
    print(bWriteLog and "MulticastRPC_BroadcastFatalDamageToClientForLua 1")
    return
  end
  if self:IsPlayingReplay() then
    print(bWriteLog and "MulticastRPC_BroadcastFatalDamageToClientForLua 2")
    return
  end
  local PlayerController = GameplayData.GetPlayerController()
  local PlayerState = GameplayData.GetPlayerState()
  local MyTeamID = -1
  if slua.isValid(PlayerState) and PlayerState.GetTeamId then
    MyTeamID = PlayerState:GetTeamId()
  end
  if not slua.isValid(PlayerController) or not PlayerController.PlayerControllerFatalDamageFeature then
    print(bWriteLog and "MulticastRPC_BroadcastFatalDamageToClientForLua 3")
    return
  end
  local ExtraInfo = slua.LuaArchiverDecode(LuaStateWrapper, ExtraInfoByteArray)
  if not ExtraInfo then
    print(bWriteLog and "MulticastRPC_BroadcastFatalDamageToClientForLua ExtraInfo nil")
    return
  end
  if self.FatalDamageIDTable[ExtraInfo.FatalDamageID or 0] then
    print(bWriteLog and "MulticastRPC_BroadcastFatalDamageToClientForLua 5")
    return
  end
  self.FatalDamageIDTable[ExtraInfo.FatalDamageID or 0] = true
  if not ExtraInfo.bVictimShouldSendFatalDamage then
    print(bWriteLog and "MulticastRPC_BroadcastFatalDamageToClientForLua 4")
    return
  end
  local SelfPlayerKey = PlayerController.PlayerKey
  local CauserExtraInfo = ExtraInfo.CauserExtraInfo
  local VictimExtraInfo = ExtraInfo.VictimExtraInfo
  FatalDamageParameter.AssistNum = 0
  FatalDamageParameter.Relationship = EFatalDamageRelationShip.NotRelated
  if CauserExtraInfo and MyTeamID == CauserExtraInfo.TeamID then
    FatalDamageParameter.Relationship = EFatalDamageRelationShip.MyTeamateIsCauser
    if CauserExtraInfo.AssistsInfo[SelfPlayerKey] then
      FatalDamageParameter.AssistNum = CauserExtraInfo.AssistsInfo[SelfPlayerKey]
    end
    if VictimExtraInfo and MyTeamID == VictimExtraInfo.TeamID then
      FatalDamageParameter.Relationship = EFatalDamageRelationShip.MyTeammateIsCauserAndVictim
    end
  elseif VictimExtraInfo and MyTeamID == VictimExtraInfo.TeamID then
    FatalDamageParameter.Relationship = EFatalDamageRelationShip.MyTeammateIsVictim
  end
  local CauserTeamID = CauserExtraInfo and CauserExtraInfo.TeamID or -1
  local VictimTeamID = VictimExtraInfo and VictimExtraInfo.TeamID or -1
  if not self:ShouldBroadcastFatalDamage(FatalDamageParameter, PlayerController.PlayerKey, MyTeamID, CauserTeamID, VictimTeamID) then
    print(bWriteLog and "MulticastRPC_BroadcastFatalDamageToClientForLua 6")
    return
  end
  PlayerController.PlayerControllerFatalDamageFeature:BroadcastFatalDamageToClientForLua(FatalDamageParameter)
end
function GameStateFatalDamageFeature:IsPlayingReplay()
  local uGameInstance = slua_GameFrontendHUD:GetGameInstance()
  if slua.isValid(uGameInstance) then
    local uWonderfulPlayback = uGameInstance:GetWonderfulPlayback()
    print(bWriteLog and "GameStateFatalDamageFeature:IsPlayingReplay uWonderfulPlayback", uWonderfulPlayback)
    if slua.isValid(uWonderfulPlayback) and uWonderfulPlayback:IsInPlayState() then
      print(bWriteLog and "GameStateFatalDamageFeature:IsPlayingReplay playing WonderfulPlayback")
      return true
    end
    local uDeathPlayback = uGameInstance:GetDeathPlayback()
    if slua.isValid(uDeathPlayback) and uDeathPlayback:IsInPlayState() then
      print(bWriteLog and "GameStateFatalDamageFeature:IsPlayingReplay playing DeathPlayback")
      return true
    end
  end
  return false
end
function GameStateFatalDamageFeature:ShouldBroadcastFatalDamage(FatalDamageParameter, SelfPlayerKey, MyTeamID, CauserTeamID, VictimTeamID)
  print(bWriteLog and "GameStateFatalDamageFeature:ShouldBroadcastFatalDamage 0", SelfPlayerKey, FatalDamageParameter.causerKey)
  local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
  local ModeType = GameMainConfig.GetModType()
  print(bWriteLog and "GameStateFatalDamageFeature:ShouldBroadcastFatalDamage 1", ModeType)
  if ModeType == "SingleTraining" then
    if SelfPlayerKey == FatalDamageParameter.causerKey then
      print(bWriteLog and "GameStateFatalDamageFeature:ShouldBroadcastFatalDamage 2", SelfPlayerKey, FatalDamageParameter.causerKey)
      return true
    end
    return false
  end
  if ModeType == "TPlan" then
    if MyTeamID == CauserTeamID or MyTeamID == VictimTeamID then
      print(bWriteLog and "GameStateFatalDamageFeature:ShouldBroadcastFatalDamage 3")
      return true
    end
    local PlayerController = GameplayData.GetPlayerController()
    if slua.isValid(PlayerController) and PlayerController.IsObserver and PlayerController:IsObserver() then
      return true
    end
    return false
  end
  return true
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
return class(CFeatureBase, nil, GameStateFatalDamageFeature)