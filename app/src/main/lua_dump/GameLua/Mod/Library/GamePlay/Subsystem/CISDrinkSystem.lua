local CISDrinkSystem = {}
local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local TableUtil = require("common.table_util")
local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")
local ECollisionEnabled = import("ECollisionEnabled")
local LocalConfig = {
  bDebugAllRegion = false,
  IconPath = "/Game/Arts/UI/TableIcons/ItemIcon/Health/Icon_Drink_Pickup.Icon_Drink_Pickup",
  OldIconPath = "/Game/Arts/UI/TableIcons/ItemIcon/Health/Icon_Boost_Drink.Icon_Boost_Drink",
  MeshPath = "/Game/Arts_Player/Weapon/Supplies/Boost_Drink_CIS.Boost_Drink_CIS"
}
function CISDrinkSystem:OnInit()
  print(bWriteLog and "CISDrinkSystem:OnInit")
  if Client then
    self:ResetTableData()
    if self:IsRegionValid() then
      self:SetTableData()
    end
  end
end
function CISDrinkSystem:OnRelease()
  print(bWriteLog and "CISDrinkSystem:OnRelease")
  self:ResetTableData()
  CISDrinkSystem.__super.OnRelease(self)
end
function CISDrinkSystem:SetTableData()
  if Client then
    local TableManagerSubsystem = import("TableManagerSubsystem")
    if TableManagerSubsystem.SetTableStringDataField("Item", "601001", "ItemSmallIcon", LocalConfig.IconPath) then
      print(bWriteLog and "CISDrinkSystem:SetTableData Replaced Drink Icon to " .. LocalConfig.IconPath)
    end
  end
end
function CISDrinkSystem:ResetTableData()
  if Client then
    local TableManagerSubsystem = import("TableManagerSubsystem")
    if TableManagerSubsystem.SetTableStringDataField("Item", "601001", "ItemSmallIcon", LocalConfig.OldIconPath) then
      print(bWriteLog and "CISDrinkSystem:OnRelease Replaced Drink Icon back to " .. LocalConfig.OldIconPath)
    end
  end
end
function CISDrinkSystem:ReplaceDrinkMesh(Actor)
  print(bWriteLog and "CISDrinkSystem:ReplaceDrinkMesh " .. tostring(Actor))
  if self:IsRegionValid() and (slua.isValid(Actor) or Actor ~= nil and slua.isValid(Actor.Object)) and slua.isValid(Actor.StaticMesh) then
    Actor.StaticMesh:SetCollisionEnabled(ECollisionEnabled.NoCollision)
    Actor:SetActorHiddenInGame(true)
    Actor.AsyncLoadID = Actor:AsyncLoadAsset(LocalConfig.MeshPath, function(Mesh)
      if (slua.isValid(Actor) or Actor ~= nil and slua.isValid(Actor.Object)) and slua.isValid(Mesh) then
        Actor.StaticMesh:SetStaticMesh(Mesh)
        Actor:SetActorHiddenInGame(false)
        print(bWriteLog and "CISDrinkSystem:ReplaceDrinkMesh to " .. LocalConfig.MeshPath)
        Actor.AsyncLoadID = nil
      end
    end)
    return true
  end
  return false
end
function CISDrinkSystem:IsRegionValid()
  if not FuncUtil then
    return false
  end
  local Region = FuncUtil.GetAccountRegionForBP()
  local AccountRegionForBPMacros = require("client.slua.config.ClientMacros.AccountRegionForBPMacros")
  print(bWriteLog and "CISDrinkSystem:IsRegionValid Region: " .. tostring(Region))
  if Region == AccountRegionForBPMacros.RU or Region == AccountRegionForBPMacros.KZ or Region == AccountRegionForBPMacros.TJ or Region == AccountRegionForBPMacros.KG then
    print(bWriteLog and "CISDrinkSystem:IsRegionValid true")
    return true
  end
  if LocalConfig.bDebugAllRegion then
    print(bWriteLog and "CISDrinkSystem:IsRegionValid bDebugAllRegion = true")
    return true
  end
  return false
end
local class = require("class")
local SubSystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubSystemBase, nil, CISDrinkSystem)