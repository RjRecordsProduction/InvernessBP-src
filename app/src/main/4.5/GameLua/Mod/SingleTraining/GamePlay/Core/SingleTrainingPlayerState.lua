local SingleTrainingPlayerState = {
  ServerRPC = {},
  ClientRPC = {},
  MulticastRPC = {}
}
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
function SingleTrainingPlayerState:ctor()
  self:ResetData()
end
function SingleTrainingPlayerState:ResetData()
  self.BattleTime = 0
  self.BattleScore = 0
  self.ChanllengeStartTime = 0
  self.CurLevel = 0
  self.TrainingStartTime = 0
end
function SingleTrainingPlayerState:_PostConstruct()
  SingleTrainingPlayerState.__super._PostConstruct(self)
end
function SingleTrainingPlayerState:ReceiveBeginPlay()
  SingleTrainingPlayerState.__super.ReceiveBeginPlay(self)
end
function SingleTrainingPlayerState:ReceiveEndPlay(EndPlayReason)
  SingleTrainingPlayerState.__super.ReceiveEndPlay(self, EndPlayReason)
end
function SingleTrainingPlayerState:GetLifetimeReplicatedProps()
  local BaseRepTable = SingleTrainingPlayerState.__super.GetLifetimeReplicatedProps(self) or {}
  local ELifetimeCondition = import("ELifetimeCondition")
  local RepTable = {
    {
      "CurLevel",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Int16
    },
    {
      "BattleTime",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Float
    },
    {
      "BattleScore",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Int
    },
    {
      "ChanllengeStartTime",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Float
    }
  }
  table.move(BaseRepTable, 1, #BaseRepTable, #RepTable + 1, RepTable)
  return RepTable
end
function SingleTrainingPlayerState:OnRep_BattleTime()
  print(bWriteLog and "SingleTrainingPlayerState:OnRep_BattleTime")
  local bIsEnter
  if self.ChanllengeStartTime > 0 then
    UIManager.ShowUI(UIManager.UI_Config_InGame.SingleTraining_Sound_Count, 1)
    bIsEnter = true
  else
    UIManager.ShowUI(UIManager.UI_Config_InGame.SingleTraining_Sound_Count, -1)
    bIsEnter = false
  end
  local SingleTrainEntranceUI = UIManager.GetUI(UIManager.UI_Config_InGame.SingleTrainEntranceUI)
  local SingleTraining_Sound_Btn = UIManager.GetUI(UIManager.UI_Config_InGame.SingleTraining_Sound_Btn)
  local SingleTraining_Sound_Footsteps = UIManager.GetUI(UIManager.UI_Config_InGame.SingleTraining_Sound_Footsteps)
  local SingleTraining_Sound_Gun = UIManager.GetUI(UIManager.UI_Config_InGame.SingleTraining_Sound_Gun)
  if SingleTrainEntranceUI then
    SingleTrainEntranceUI:SetEnterChanllenge(bIsEnter)
  end
  if SingleTraining_Sound_Btn then
    SingleTraining_Sound_Btn:SetEnterChanllenge(bIsEnter)
  end
  if SingleTraining_Sound_Footsteps then
    SingleTraining_Sound_Footsteps:SetEnterChanllenge(bIsEnter)
  end
  if SingleTraining_Sound_Gun then
    SingleTraining_Sound_Gun:SetEnterChanllenge(bIsEnter)
  end
end
function SingleTrainingPlayerState:OnRep_BattleScore()
  print(bWriteLog and "SingleTrainingPlayerState:OnRep_BattleScore")
end
function SingleTrainingPlayerState:OnRep_ChanllengeStartTime()
  print(bWriteLog and "SingleTrainingPlayerState:OnRep_ChanllengeStartTime")
end
function SingleTrainingPlayerState:OnRep_CurLevel()
  print(bWriteLog and "SingleTrainingPlayerState:OnRep_CurLevel")
  EventSystem:postEvent(EVENTTYPE_SINGLE_TRAIN, EVENTID_SINGLE_TRAIN_CURLEVEL)
end
function SingleTrainingPlayerState:AddFootStepScore(Score)
  print(bWriteLog and "SingleTrainingPlayerState:AddFootStepScore", Score)
  self.BattleScore = self.BattleScore + tonumber(Score)
end
function SingleTrainingPlayerState:AddFootStepBattleTime(RewardBattleTime)
  print(bWriteLog and "SingleTrainingPlayerState:AddFootStepBattleTime", RewardBattleTime)
  self.BattleTime = self.BattleTime + tonumber(RewardBattleTime)
end
function SingleTrainingPlayerState:AddGunScore(Score)
  self.BattleScore = self.BattleScore + tonumber(Score)
end
function SingleTrainingPlayerState:AddGunBattleTime(RewardBattleTime)
  self.BattleTime = self.BattleTime + tonumber(RewardBattleTime)
end
function SingleTrainingPlayerState:StartFootStepChanllenge(BattleTime)
  self.BattleTime = tonumber(BattleTime)
  self.BattleScore = 0
  self.ChanllengeStartTime = GamePlayTools.GetServerWorldTimeSeconds()
end
function SingleTrainingPlayerState:StartGunChanllenge(BattleTime)
  self.BattleTime = tonumber(BattleTime)
  self.BattleScore = 0
  self.ChanllengeStartTime = GamePlayTools.GetServerWorldTimeSeconds()
end
function SingleTrainingPlayerState:GetChanllengeStartTime()
  return self.ChanllengeStartTime
end
function SingleTrainingPlayerState:GetBattleTime()
  return self.BattleTime
end
function SingleTrainingPlayerState:GetScore()
  return self.BattleScore
end
function SingleTrainingPlayerState:StartTraining()
  self.TrainingStartTime = GamePlayTools.GetServerWorldTimeSeconds()
end
function SingleTrainingPlayerState:GetTrainingStartTime()
  return self.TrainingStartTime
end
local class = require("class")
local CPlayerStateBase = require("GameLua.Mod.BRMod.Gameplay.Core.BRPlayerStateBase")
local CSingleTrainingPlayerState = class(CPlayerStateBase, nil, SingleTrainingPlayerState)
return CSingleTrainingPlayerState