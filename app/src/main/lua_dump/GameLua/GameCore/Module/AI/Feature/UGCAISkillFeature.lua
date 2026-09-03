local UGCAISkillFeature = {}
function UGCAISkillFeature:ctor()
  self.AITargetLocation = FVector.ZeroVector
end
function UGCAISkillFeature:_PostConstruct()
  UGCAISkillFeature.__super._PostConstruct(self)
end
function UGCAISkillFeature:ReceiveBeginPlay()
  print(bWriteLog and "UGCAISkillFeature:ReceiveBeginPlay")
  UGCAISkillFeature.__super.ReceiveBeginPlay(self)
end
function UGCAISkillFeature:ReceiveEndPlay()
  print(bWriteLog and "UGCAISkillFeature:ReceiveEndPlay")
  UGCAISkillFeature.__super.ReceiveEndPlay(self)
end
function UGCAISkillFeature:GetLifetimeReplicatedProps()
  local ELifetimeCondition = import("ELifetimeCondition")
  local RepTable = {
    {
      "AITargetLocation",
      ELifetimeCondition.COND_None,
      import("/Script/CoreUObject.Vector")
    }
  }
  if UGCAISkillFeature.__super.GetLifetimeReplicatedProps then
    local BaseRepTable = UGCAISkillFeature.__super.GetLifetimeReplicatedProps(self)
    table.move(BaseRepTable, 1, #BaseRepTable, #RepTable + 1, RepTable)
  end
  return RepTable
end
function UGCAISkillFeature:OnRep_AITargetLocation(oldValue)
  print(bWriteLog and "UGCAISkillFeature:OnRep_AITargetLocation", tostring(self.AITargetLocation))
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
return class(CFeatureBase, nil, UGCAISkillFeature)