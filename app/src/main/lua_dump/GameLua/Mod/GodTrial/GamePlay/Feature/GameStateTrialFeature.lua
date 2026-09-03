local CommonTrialConfig = require("GameLua.Mod.GodTrial.Gameplay.Config.CommonTrialConfig")
local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
local GameStateTrialFeature = {}
function GameStateTrialFeature:GetLifetimeReplicatedProps()
  local ELifetimeCondition = import("ELifetimeCondition")
  local RepTable = {
    {
      "bTrialDeadlineReached",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Bool
    }
  }
  return RepTable
end
function GameStateTrialFeature:_PostConstruct()
  GameStateTrialFeature.__super._PostConstruct(self)
  self.bTrialDeadlineReached = false
  self.RegisteredTrialObjects = {}
  self.RegisteredStartTrialActors = {}
  self.RegisteredPKEntries = {}
end
function GameStateTrialFeature:ReceiveBeginPlay()
  GameStateTrialFeature.__super.ReceiveBeginPlay(self)
  if self:HasAuthority() then
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, self.OnGameModeStateChange, self)
  end
end
function GameStateTrialFeature:OnGameModeStateChange(_, _, sState)
  if sState == "FightingState" then
    local DeadLine = GameMainConfig.GetTableMapValue(CommonTrialConfig.TrialDeadlineAfterFighting)
    self:StartTrialDeadlineTimer(DeadLine)
  end
end
function GameStateTrialFeature:StartTrialDeadlineTimer(Deadline)
  if not Deadline or Deadline <= 0 then
    return
  end
  print(bWriteLog and string.format("GameStateTrialFeature:StartTrialDeadlineTimer Deadline = %s", Deadline))
  self.bTrialDeadlineReached = false
  self:ForceNetUpdate()
  self.TrialDeadlineTimer = self:AddGameTimer(Deadline, false, function()
    self:OnTrialDeadlineReached()
  end)
end
function GameStateTrialFeature:OnTrialDeadlineReached()
  print(bWriteLog and string.format("GameStateTrialFeature:OnTrialDeadlineReached"))
  self.bTrialDeadlineReached = true
  self:ForceNetUpdate()
  for _, TrialObject in pairs(self.RegisteredTrialObjects) do
    if slua.isValid(TrialObject.Object) then
      TrialObject:OnTrialDeadlineReached()
    end
  end
end
function GameStateTrialFeature:IsTrialDeadlineReached()
  return self.bTrialDeadlineReached == true
end
function GameStateTrialFeature:GMRestartTrialDeadlineTimer(Seconds)
  print(bWriteLog and string.format("GameStateTrialFeature:GMRestartTrialDeadlineTimer Seconds = %s", Seconds))
  if self.bTrialDeadlineReached then
    print(bWriteLog and string.format("GameStateTrialFeature:GMRestartTrialDeadlineTimer bTrialDeadlineReached, return"))
    return
  end
  self:TryRemoveNamedGameTimer("TrialDeadlineTimer")
  self:StartTrialDeadlineTimer(Seconds)
end
function GameStateTrialFeature:RegisterTrialObject(TrialObject)
  print(bWriteLog and string.format("GameStateTrialFeature:RegisterTrialObject %s", TrialObject.Object))
  table.insert(self.RegisteredTrialObjects, TrialObject)
end
function GameStateTrialFeature:OnRep_bTrialDeadlineReached()
  print(bWriteLog and string.format("GameStateTrialFeature:OnRep_bTrialDeadlineReached %s", tostring(self.bTrialDeadlineReached)))
  if self.bTrialDeadlineReached then
    local CommonTipsId = CommonTrialConfig.TrialDeadlineCommonTipsId
    if CommonTipsId then
      IngameTipsTools.BattleGeneralTip(CommonTipsId)
    end
  end
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
return class(CFeatureBase, nil, GameStateTrialFeature)