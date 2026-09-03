local BattleFeedBackLogic = {}
local ResultUtil = require("GameLua.Mod.BaseMod.Client.BattleResult.BattleResultUtil")
function BattleFeedBackLogic:OnInit()
  print(bWriteLog and "BattleFeedBackLogic:OnInit")
  self.battle_id = 0
  self:AddCommonEvent(EVENTTYPE_ACCOUNT, EVENTID_BATTLE_RESULT_FEED_BACK_CLOSE, self.EndResultProcess, self)
end
function BattleFeedBackLogic:OnRelease()
  print(bWriteLog and "BattleFeedBackLogic:OnRelease")
end
function BattleFeedBackLogic:OnBattleResult(result)
  print(bWriteLog and "BattleFeedBackLogic:OnBattleResult sub_mode:" .. tostring(result.sub_mode) .. " battle_owner:" .. tostring(result.battle_owner))
  self.battle_id = result.battle_id
  if not result.is_team_result then
    LobbySystem.SetFeedBackFlag(result.need_game_evaluation == 1)
  end
end
function BattleFeedBackLogic:OnSwitchCheck()
  return false
end
function BattleFeedBackLogic:OnResultProcessStart()
  print(bWriteLog and "BattleFeedBackLogic:OnResultProcessStart")
  local BattleEvaluationLogic = require("GameLua.Mod.BaseMod.Client.BattleResult.BattleEvaluationLogic")
  BattleEvaluationLogic.Enter(self.battle_id)
  return true
end
local class = require("class")
local BattleResultProcessBaseLogic = require("GameLua.Mod.BaseMod.Client.BattleResult.ProcessBase.BattleResultProcessBaseLogic")
local CBattleFeedBackLogic = class(BattleResultProcessBaseLogic, nil, BattleFeedBackLogic)
return CBattleFeedBackLogic