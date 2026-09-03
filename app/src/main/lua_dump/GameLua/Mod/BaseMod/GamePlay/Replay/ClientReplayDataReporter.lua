local ClientReplayDataReporter = {}
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
function ClientReplayDataReporter:ctor()
  print("ClientReplayDataReporter:ctor")
end
function ClientReplayDataReporter:ReceiveBeginPlay()
  ClientReplayDataReporter.__super.ReceiveBeginPlay(self)
  self:InitWithConfig()
  local GameReportSubsystem = SubsystemMgr:Get("GameReportSubsystem")
  print("ClientReplayDataReporter:ReceiveBeginPlay", self.Owner, GameReportSubsystem)
  if Client and GameReportSubsystem then
    GameReportSubsystem.Reporter = self
  end
end
function ClientReplayDataReporter:InitWithConfig()
  local ReplayReportConfig = GamePlayTools.GetCurrentConfig("ReplayReportConfig")
  if type(ReplayReportConfig) ~= "table" then
    print("ClientReplayDataReporter:InitWithConfig", "ReplayReportConfig is not table", ReplayReportConfig)
    ReplayReportConfig = require("GameLua.Mod.BaseMod.GamePlay.Config.ReplayReportConfig")
  end
  if type(ReplayReportConfig) ~= "table" then
    print("ClientReplayDataReporter:InitWithConfig", "ReplayReportConfig is not table2", ReplayReportConfig)
    return
  end
  for ID, Config in pairs(ReplayReportConfig) do
    local ReplayReportConfig = {
      Type = Config.Type,
      ReportInterval = Config.ReportInterval,
      bOnlyReportLatest = Config.bOnlyReportLatest
    }
    self.ReplayReportConfigMap:Add(ID, ReplayReportConfig)
    print(bWriteLog and "ClientReplayDataReporter:InitWithConfig", ID, Config.Type)
  end
end
local class = require("class")
local CActorBase = require("GameLua.Mod.BaseMod.Common.Core.ActorBase")
return class(CActorBase, nil, ClientReplayDataReporter)