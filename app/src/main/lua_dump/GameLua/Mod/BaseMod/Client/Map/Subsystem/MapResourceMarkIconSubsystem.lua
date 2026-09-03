local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")
local MapResourceMarkIconSubsystem = {}
function MapResourceMarkIconSubsystem:ctor()
  self.ShowTime = 10
  self.PremiumResourceMarkTimer = nil
  self.StandardResourceMarkTimer = nil
  self.FixedVehicleResourceMarkTimer = nil
  self.NearVehicleResourceMarkTimer = nil
  self.PremiumResourceMarkIDTable = nil
  self.StandardResourceMarkIDTable = nil
  self.FixedVehicleResourceMarkIDTable = nil
  self.NearVehicleResourceMarkIDTable = nil
  self.ShowResourceFunctionName = {
    [1] = "ShowPremiumResource",
    [2] = "ShowStandardResource",
    [3] = "ShowFixedVehicleResource",
    [4] = "ShowNearVehicleResource"
  }
  self.HideResourceFunctionName = {
    [1] = "HidePremiumResource",
    [2] = "HideStandardResource",
    [3] = "HideFixedVehicleResource",
    [4] = "HideNearVehicleResource"
  }
  self.AllResourceTag = {
    PremiumResourceTag = true,
    StandardResourceTag = true,
    FixedVehicleResourceTag = true,
    NearVehicleResourceTag = true
  }
  self.MapMarkUIManagerTemp = nil
end
function MapResourceMarkIconSubsystem:_DataDefine()
  return {CurrentShowTag = nil}
end
function MapResourceMarkIconSubsystem:OnInit()
  local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  local World = slua_GameFrontendHUD:GetWorld()
  if not slua.isValid(World) or not STExtraBlueprintFunctionLibrary then
    return
  end
  local MapMarkUIManager = STExtraBlueprintFunctionLibrary.GetMapUIMarkComponent(World)
  self.MapMarkUIManagerTemp = MapMarkUIManager
  if MapMarkUIManager then
    for Tag, _ in pairs(self.AllResourceTag) do
      MapMarkUIManager:OnShowOrHideLegendMarkWidget(Tag, false)
    end
  end
  local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
  local ResourceMapMarkConfig = GamePlayTools.GetCurrentConfig("ResourceMapMarkConfig")
  if not ResourceMapMarkConfig then
    return
  end
  for _, ResourceConfig in pairs(ResourceMapMarkConfig.PremiumResource) do
    InGameMarkTools.ClientAddMapMark(ResourceConfig.MapMarkID, ResourceConfig.MapMarkPosition, 0, nil, 2, nil, ResourceConfig.Radius)
  end
  for _, ResourceConfig in pairs(ResourceMapMarkConfig.StandardResource) do
    InGameMarkTools.ClientAddMapMark(ResourceConfig.MapMarkID, ResourceConfig.MapMarkPosition, 0, nil, 2, nil, ResourceConfig.Radius)
  end
  for _, ResourceConfig in pairs(ResourceMapMarkConfig.FixedVehicleResource) do
    InGameMarkTools.ClientAddMapMark(ResourceConfig.MapMarkID, ResourceConfig.MapMarkPosition, 0, nil, 2, nil, ResourceConfig.Size)
  end
end
function MapResourceMarkIconSubsystem:ShowPremiumResource()
  if not slua.isValid(self.MapMarkUIManagerTemp) then
    return
  end
  self:HideAllResourceMark()
  self.MapMarkUIManagerTemp:OnShowOrHideLegendMarkWidget("PremiumResourceTag", true)
  self.PremiumResourceMarkTimer = self:AddGameTimer(self.ShowTime, false, function()
    self.PremiumResourceMarkTimer = nil
    self:HidePremiumResource()
  end)
  local SuperData = self:GetSuperData()
  SuperData.CurrentShowTag = "PremiumResourceTag"
end
function MapResourceMarkIconSubsystem:HidePremiumResource()
  if self.PremiumResourceMarkTimer then
    self:RemoveGameTimer(self.PremiumResourceMarkTimer)
    self.PremiumResourceMarkTimer = nil
  end
  self:HideAllResourceMark()
end
function MapResourceMarkIconSubsystem:ShowStandardResource()
  if not slua.isValid(self.MapMarkUIManagerTemp) then
    return
  end
  self:HideAllResourceMark()
  self.MapMarkUIManagerTemp:OnShowOrHideLegendMarkWidget("StandardResourceTag", true)
  self.StandardResourceMarkTimer = self:AddGameTimer(self.ShowTime, false, function()
    self.StandardResourceMarkTimer = nil
    self:HideStandardResource()
  end)
  local SuperData = self:GetSuperData()
  SuperData.CurrentShowTag = "StandardResourceTag"
end
function MapResourceMarkIconSubsystem:HideStandardResource()
  if self.StandardResourceMarkTimer then
    self:RemoveGameTimer(self.StandardResourceMarkTimer)
    self.StandardResourceMarkTimer = nil
  end
  self:HideAllResourceMark()
end
function MapResourceMarkIconSubsystem:ShowFixedVehicleResource()
  if not slua.isValid(self.MapMarkUIManagerTemp) then
    return
  end
  self:HideAllResourceMark()
  self.MapMarkUIManagerTemp:OnShowOrHideLegendMarkWidget("FixedVehicleResourceTag", true)
  self.FixedVehicleResourceMarkTimer = self:AddGameTimer(self.ShowTime, false, function()
    self.FixedVehicleResourceMarkTimer = nil
    self:HideFixedVehicleResource()
  end)
  local SuperData = self:GetSuperData()
  SuperData.CurrentShowTag = "FixedVehicleResourceTag"
end
function MapResourceMarkIconSubsystem:HideFixedVehicleResource()
  if self.FixedVehicleResourceMarkTimer then
    self:RemoveGameTimer(self.FixedVehicleResourceMarkTimer)
    self.FixedVehicleResourceMarkTimer = nil
  end
  self:HideAllResourceMark()
end
function MapResourceMarkIconSubsystem:HideAllResourceMark()
  if self.PremiumResourceMarkTimer then
    self:RemoveGameTimer(self.PremiumResourceMarkTimer)
    self.PremiumResourceMarkTimer = nil
  end
  if self.StandardResourceMarkTimer then
    self:RemoveGameTimer(self.StandardResourceMarkTimer)
    self.StandardResourceMarkTimer = nil
  end
  if self.FixedVehicleResourceMarkTimer then
    self:RemoveGameTimer(self.FixedVehicleResourceMarkTimer)
    self.FixedVehicleResourceMarkTimer = nil
  end
  if self.MapMarkUIManagerTemp then
    for Tag, _ in pairs(self.AllResourceTag) do
      self.MapMarkUIManagerTemp:OnShowOrHideLegendMarkWidget(Tag, false)
    end
  end
  local SuperData = self:GetSuperData()
  SuperData.CurrentShowTag = ""
end
function MapResourceMarkIconSubsystem:ShowNearVehicleResource()
  local SuperData = self:GetSuperData()
  SuperData.CurrentShowTag = "NearVehicleResourceTag"
end
function MapResourceMarkIconSubsystem:HideNearVehicleResource()
end
function MapResourceMarkIconSubsystem:OnResourceCheckBoxChanged(Index, bChecked)
  local FunctionName
  if bChecked then
    FunctionName = self.ShowResourceFunctionName[Index]
  else
    FunctionName = self.HideResourceFunctionName[Index]
  end
  if self[FunctionName] then
    self[FunctionName](self)
  end
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, MapResourceMarkIconSubsystem)