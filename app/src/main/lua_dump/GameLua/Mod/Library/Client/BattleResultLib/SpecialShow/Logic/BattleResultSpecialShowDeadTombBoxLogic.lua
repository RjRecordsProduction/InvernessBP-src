local BattleResultSpecialShowDeadTombBoxLogic = {}
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
function BattleResultSpecialShowDeadTombBoxLogic:CheckEnterSpecialShow(result)
  print(bWriteLog and "BattleResultSpecialShowDeadTombBoxLogic:CheckEnterSpecialShow")
  local BaseConfig = GamePlayTools.GetCurrentConfig("BattleResultSpecialShowConfig")
  if not BaseConfig then
    print(bWriteLog and "BattleResultSpecialShowDeadTombBoxLogic:CheckEnterSpecialShow Error Config!!!")
    return false
  end
  local MapType = GameMainConfig.GetMapType()
  if not MapType or not BaseConfig[MapType] then
    print(bWriteLog and "BattleResultSpecialShowDeadTombBoxLogic:CheckEnterSpecialShow invalid MapConfig")
    return false
  end
  return true
end
function BattleResultSpecialShowDeadTombBoxLogic:OnBattleResult(result)
  BattleResultSpecialShowDeadTombBoxLogic.__super.OnBattleResult(self, result)
  print(bWriteLog and "BattleResultSpecialShowDeadTombBoxLogic:OnBattleResult ")
  if result and result.special_result_team then
    self.bSpecialShow = self:CheckEnterSpecialShow(result)
  end
  print(bWriteLog and "BattleResultSpecialShowDeadTombBoxLogic:OnBattleResult Enter SpeicialShow: " .. tostring(self.bSpecialShow))
end
function BattleResultSpecialShowDeadTombBoxLogic:OnSwitchCheck()
  local bSwitchToTombBoxLogic = BattleResultSpecialShowDeadTombBoxLogic.__super.OnSwitchCheck(self)
  if self.bSpecialShow then
    bSwitchToTombBoxLogic = false
  end
  print(bWriteLog and "BattleResultSpecialShowDeadTombBoxLogic:OnSwitchCheck SwitchToTombBoxLogic: " .. tostring(bSwitchToTombBoxLogic))
  return bSwitchToTombBoxLogic
end
local class = require("class")
local BattleResultProcessBaseLogic = require("GameLua.Mod.BaseMod.Client.BattleResult.BattleResultDeadTombBox.BattleResultDeadTombBoxLogic")
local CBattleResultSpecialShowDeadTombBoxLogic = class(BattleResultProcessBaseLogic, nil, BattleResultSpecialShowDeadTombBoxLogic)
return CBattleResultSpecialShowDeadTombBoxLogic