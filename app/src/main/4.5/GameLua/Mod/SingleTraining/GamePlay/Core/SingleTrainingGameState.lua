local SingleTrainingGameState = {
  ServerRPC = {},
  ClientRPC = {},
  MulticastRPC = {}
}
function SingleTrainingGameState:ctor()
end
function SingleTrainingGameState:_PostConstruct()
  SingleTrainingGameState.__super._PostConstruct(self)
end
function SingleTrainingGameState:ReceiveBeginPlay()
  print(bWriteLog and "SingleTrainingGameState:ReceiveBeginPlay")
  SingleTrainingGameState.__super.ReceiveBeginPlay(self)
end
function SingleTrainingGameState:ReceiveEndPlay(EndPlayReason)
  SingleTrainingGameState.__super.ReceiveEndPlay(self, EndPlayReason)
end
local class = require("class")
local CGameStateBase = require("GameLua.Mod.BRMod.Gameplay.Core.BRGameStateBase")
local CSingleTrainingGameState = class(CGameStateBase, nil, SingleTrainingGameState)
return require("combine_class").DeclareFeature(CSingleTrainingGameState, {
  {
    STDeadBoxClientShowFeature = "GameLua.Mod.SingleTraining.GamePlay.Feature.STDeadBoxClientShowFeature"
  }
}, "SingleTrainingGameState")