local BattleResultSpecialShowCountDownLogic = {}
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
function BattleResultSpecialShowCountDownLogic:CheckEnterSpecialShow(result)
  print(bWriteLog and "BattleResultSpecialShowCountDownLogic:CheckEnterSpecialShow")
  local BaseConfig = GamePlayTools.GetCurrentConfig("BattleResultSpecialShowConfig")
  if not BaseConfig then
    print(bWriteLog and "BattleResultSpecialShowCountDownLogic:CheckEnterSpecialShow Error Config!!!")
    return false
  end
  local MapType = GameMainConfig.GetMapType()
  if not MapType or not BaseConfig[MapType] then
    print(bWriteLog and "BattleResultSpecialShowCountDownLogic:CheckEnterSpecialShow invalid MapConfig")
    return false
  end
  return true
end
function BattleResultSpecialShowCountDownLogic:OnBattleResult(result)
  BattleResultSpecialShowCountDownLogic.__super.OnBattleResult(self, result)
  print(bWriteLog and "BattleResultSpecialShowCountDownLogic:OnBattleResult")
  if result and result.special_result_team then
    self.bSpecialShow = self:CheckEnterSpecialShow(result)
  end
  print(bWriteLog and "BattleResultSpecialShowCountDownLogic:OnBattleResult Enter SpeicialShow: " .. tostring(self.bSpecialShow))
end
function BattleResultSpecialShowCountDownLogic:OnSwitchCheck()
  local bSwitchToCountDownLogic = BattleResultSpecialShowCountDownLogic.__super.OnSwitchCheck(self)
  if self.bSpecialShow then
    bSwitchToCountDownLogic = false
  end
  print(bWriteLog and "BattleResultSpecialShowCountDownLogic:OnSwitchCheck SwitchToCountDownLogic: " .. tostring(bSwitchToCountDownLogic))
  return bSwitchToCountDownLogic
end
local class = require("class")
local BattleResultProcessBaseLogic = require("GameLua.Mod.BaseMod.Client.BattleResult.GameOverTips.BattleResultCountDownLogic")
local CBattleResultSpecialShowCountDownLogic = class(BattleResultProcessBaseLogic, nil, BattleResultSpecialShowCountDownLogic)
return CBattleResultSpecialShowCountDownLogic