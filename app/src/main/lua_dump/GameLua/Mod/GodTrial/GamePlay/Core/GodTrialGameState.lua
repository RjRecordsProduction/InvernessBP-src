local GodTrialGameState = {
  ServerRPC = {},
  ClientRPC = {},
  MulticastRPC = {}
}
local CentaurConfig = require("GameLua.ExtraModule.MLAI.Mercenary.Centaur.CentaurConfig")
function GodTrialGameState:ctor()
  self.uCacheCentaur = nil
  self.tAllCentaurs = {}
end
function GodTrialGameState:_PostConstruct()
  GodTrialGameState.__super._PostConstruct(self)
end
function GodTrialGameState:ReceiveBeginPlay()
  GodTrialGameState.__super.ReceiveBeginPlay(self)
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_PAWN_DIED_ASSIST, self.HandleOnAssist, self)
end
function GodTrialGameState:ReceiveEndPlay(EndPlayReason)
  GodTrialGameState.__super.ReceiveEndPlay(self, EndPlayReason)
end
function GodTrialGameState:HandleOnAssist(_, __, uKilledPawn, uAssistPS, TypeID)
  if slua.isValid(uKilledPawn) and slua.isValid(uAssistPS) then
    local uAssistPawn = uAssistPS:GetPlayerCharacter()
    if slua.isValid(uAssistPawn) and uAssistPawn:ActorHasTag("Centaur") then
      print(bWriteLog and string.format("GodTrialGameState:HandleOnAssist: uKilledPawn:%s uAssistPawn:%s", Game:GetObjName(uKilledPawn), Game:GetObjName(uAssistPawn)))
      local DSCommonTLogSubsystem = SubsystemMgr:Get("DSCommonTLogSubsystem")
      if DSCommonTLogSubsystem then
        local nTlogID = CentaurConfig.TLogConfig.TotalGame_Assists
        DSCommonTLogSubsystem:AddCommonTLog(nTlogID, 1, false)
      end
    end
  end
end
function GodTrialGameState:IsFitBigBodyMLAI()
  return true
end
local class = require("class")
local CGameStateBase = require("GameLua.Mod.BRMod.Gameplay.Core.BRGameStateBase")
local CGodTrialGameState = class(CGameStateBase, nil, GodTrialGameState)
local combine_class = require("combine_class")
combine_class.DeclareFeature(CGodTrialGameState, {
  {
    GameStateTeamHonorFeature = "GameLua.Mod.GodTrial.Gameplay.Feature.GameStateTeamHonorFeature"
  },
  {
    GameStateFramePlatformFeature = "GameLua.Mod.GodTrial.Gameplay.Feature.GameStateFramePlatformFeature"
  },
  {
    GameStateTrialFeature = "GameLua.Mod.GodTrial.Gameplay.Feature.GameStateTrialFeature"
  },
  {
    ThemeSkillItemFeature = "GameLua.Mod.BaseMod.GamePlay.Feature.GameStateThemeSkillItemFeature"
  }
}, "GodTrialGameState")
return CGodTrialGameState