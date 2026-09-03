local POIGeneralAreaSubsystem = {}
function POIGeneralAreaSubsystem:OnInit()
  print(bWriteLog and string.format("POIGeneralAreaSubsystem:OnInit"))
  self.POIGeneralAreas = {}
end
function POIGeneralAreaSubsystem:OnRelease()
  self.POIGeneralAreas = {}
end
function POIGeneralAreaSubsystem:Register(POIGeneralArea)
  local AreaId = POIGeneralArea.AreaID
  if not self.POIGeneralAreas then
    self.POIGeneralAreas = {}
  end
  if AreaId and not self.POIGeneralAreas[AreaId] then
    self.POIGeneralAreas[AreaId] = POIGeneralArea
    print(bWriteLog and string.format("POIGeneralAreaSubsystem:Register AreaId = %s (%s)", AreaId, POIGeneralArea.Object))
  else
    print(bWriteLog and string.format("POIGeneralAreaSubsystem:Register failed, AreaId = %s (%s)", AreaId, POIGeneralArea.Object))
  end
end
function POIGeneralAreaSubsystem:Get(AreaId)
  if not self.POIGeneralAreas then
    return
  end
  if self.POIGeneralAreas[AreaId] then
    return self.POIGeneralAreas[AreaId]
  end
  print(bWriteLog and string.format("POIGeneralAreaSubsystem:Get AreaId = %s not found, try to GetAllActors", AreaId))
  local ActorTools = require("GameLua.Mod.BaseMod.Common.ActorTools")
  local POIGeneralAreas = ActorTools.GetAllActors(CGameWorld, "/Game/Mod/EvoBase/BluePrints/Actor/POIGeneralArea.POIGeneralArea_C")
  for _, POIGeneralArea in pairs(POIGeneralAreas) do
    if POIGeneralArea.AreaID == AreaId then
      return POIGeneralArea
    end
  end
  POIGeneralAreas = ActorTools.GetAllActors(CGameWorld, "/Game/Mod/EvoBase/BluePrints/Actor/POIGeneralCustomArea.POIGeneralCustomArea_C")
  for _, POIGeneralArea in pairs(POIGeneralAreas) do
    if POIGeneralArea.AreaID == AreaId then
      return POIGeneralArea
    end
  end
end
local class = require("class")
local SubSystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubSystemBase, nil, POIGeneralAreaSubsystem)