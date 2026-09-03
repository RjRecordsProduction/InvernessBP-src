local UtilSystem = {}
function UtilSystem:OnInit()
  print(bWriteLog and string.format("UtilSystem:OnInit"))
end
function UtilSystem:OnRelease()
  print(bWriteLog and string.format("UtilSystem:OnRelease"))
end
function UtilSystem:CreateTimer(TimerTag, Interval, bLoop, Callback)
  self.TimerTable = self.TimerTable or {}
  if TimerTag then
    self.TimerTable[TimerTag] = self:AddGameTimer(Interval, bLoop, Callback)
    print(bWriteLog and string.format("UtilSystem:CreateTimer TimerTag:%s [%s]", tostring(TimerTag), tostring(self.TimerTable[TimerTag])))
  end
  return self:GetTimer(TimerTag)
end
function UtilSystem:GetTimer(TimerTag)
  if TimerTag then
    return self.TimerTable and self.TimerTable[TimerTag]
  end
end
function UtilSystem:RemoveTimer(TimerTag)
  if TimerTag and self.TimerTable then
    local TimerID = self:GetTimer(TimerTag)
    if TimerID then
      print(bWriteLog and string.format("UtilSystem:RemoveTimer TimerTag:%s [%s]", tostring(TimerTag), tostring(self.TimerTable[TimerTag])))
      self:RemoveGameTimer(TimerID)
      self.TimerTable[TimerTag] = nil
    end
  end
end
function UtilSystem:GetOrCreateCustomTable(Tag)
  self.CustomTable = self.CustomTable or {}
  if Tag and not self.CustomTable[Tag] then
    self.CustomTable[Tag] = {}
  end
  return self.CustomTable[Tag]
end
function UtilSystem:RemoveCustomTable(Tag)
  if Tag and self.CustomTable then
    self.CustomTable[Tag] = nil
  end
end
local class = require("class")
local SubSystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubSystemBase, nil, UtilSystem)