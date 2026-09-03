local HolographySubSystem = {
  handleMap = {}
}
function HolographySubSystem:OnInit()
  print(bWriteLog and "[HolographySubSystem] OnInit")
  self.handleMap = {}
end
function HolographySubSystem:OnRelease()
  print(bWriteLog and "[HolographySubSystem] OnRelease")
  self.handleMap = {}
  HolographySubSystem.__super.OnRelease(self)
end
function HolographySubSystem:GetHolographyHandle(itemID)
  print(bWriteLog and "[HolographySubSystem] GetHolographyHandle itemID = " .. tostring(itemID))
  if not itemID then
    return nil
  end
  if self.handleMap[itemID] and slua.isValid(self.handleMap[itemID]) then
    return self.handleMap[itemID]
  end
  if self.handleMap[itemID] == false then
    return nil
  end
  local UAELoadedClassManager = import("UAELoadedClassManager").Get()
  local handleClass = UAELoadedClassManager:GetClass("Avatar", itemID, false, false)
  if not handleClass then
    print(bWriteLog and "[HolographySubSystem] GetHolographyHandle handleClass is nil. itemID = " .. tostring(itemID))
    self.handleMap[itemID] = false
    return nil
  end
  local handle = handleClass()
  local handleBase = slua.loadClass("/Game/Arts_PlayerBluePrints/Holography/HolographyHandle_Base.HolographyHandle_Base")
  if not Game:IsClassOf(handle, handleBase) then
    print(bWriteLog and "[HolographySubSystem] GetHolographyHandle  Cast to BackpackEmoteHandle failed. itemID = " .. tostring(itemID))
    self.handleMap[itemID] = false
    return nil
  end
  self.handleMap[itemID] = handle
  return handle
end
function HolographySubSystem:AddBuff(character, buffID)
  print(bWriteLog and "[HolographySubSystem] AddBuff" .. tostring(buffID))
  if slua.isValid(character) then
    character:AddBuffBySkill(buffID, 1, nil, 1)
    self:AddControlEvent(character, "OnAttachedToVehicle", self.RemoveBuff, self, character, buffID)
    EventSystem:registEventWithConditions(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, {
      [1] = "FightingState"
    }, function()
      self:RemoveBuff(character, buffID)
    end)
  else
    print(bWriteLog and "[HolographySubSystem] AddBuff not character")
  end
end
function HolographySubSystem:RemoveBuff(character, buffID)
  print(bWriteLog and "[HolographySubSystem] RemoveBuff" .. tostring(buffID))
  if slua.isValid(character) then
    character:RemoveBuffBySkill(buffID, 1, nil)
    if self:HasControlEventByControl(character, "OnAttachedToVehicle") then
      self:RemoveControlEvent(character, "OnAttachedToVehicle")
    end
  else
    print(bWriteLog and "[HolographySubSystem] RemoveBuff not character")
  end
end
local class = require("class")
local SubSystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubSystemBase, nil, HolographySubSystem)