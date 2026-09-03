local AirAttackComponent = {}
function AirAttackComponent:ctor()
  self.IslandReviseDis = 84000
  self.AreaCenterPosi = nil
end
function AirAttackComponent:ReviseAirAttackLocation(AirAttackLocation)
  print(bWriteLog and "AirAttackComponent:ReviseAirAttackLocation")
  if not AirAttackLocation then
    return false
  end
  if self.AreaCenterPosi then
    local Dis = FVector.DistXY(AirAttackLocation, self.AreaCenterPosi)
    print(bWriteLog and "AirAttackComponent:ReviseAirAttackLocation " .. tostring(Dis) .. " IslandReviseDis:" .. tostring(self.IslandReviseDis))
    if Dis < self.IslandReviseDis then
      print(bWriteLog and "AirAttackComponent:ReviseAirAttackLocation false:" .. tostring(Dis) .. " IslandReviseDis:" .. tostring(self.IslandReviseDis))
      return false
    end
  end
  return true
end
local Class = require("class")
local Object = require("GameLua.Mod.Library.GamePlay.Component.AirAttackBaseComponent")
local CAirAttackComponent = Class(Object, nil, AirAttackComponent)
return CAirAttackComponent