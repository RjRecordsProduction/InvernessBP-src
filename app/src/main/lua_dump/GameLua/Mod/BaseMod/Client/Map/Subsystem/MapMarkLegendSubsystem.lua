local MapMarkLegendSubsystem = {}
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local STExtraBlueprintFunctionLibrary = import("/Script/ShadowTrackerExtra.STExtraBlueprintFunctionLibrary")
function MapMarkLegendSubsystem:ctor()
  print(bWriteLog and "MapMarkLegendSubsystem:ctor")
  self.LegendTextID2TypeID = {}
end
function MapMarkLegendSubsystem:_PostConstruct()
  print(bWriteLog and "MapMarkLegendSubsystem:_PostConstruct")
end
function MapMarkLegendSubsystem:OnInit()
  print(bWriteLog and "MapMarkLegendSubsystem:OnInit")
  self.LegenMarkNum = {}
  self.LegenMarks = {}
  self.ExistInstanceIDs = {}
end
function MapMarkLegendSubsystem:OnMarkShowOrHide(bIsShow, instanceID, typeID)
  local NewMapMarkConfig = GamePlayTools.GetCurrentConfig("NewMapMarkConfig")
  if not self.ExistInstanceIDs then
    self.ExistInstanceIDs = {}
  end
  if not self.LegenMarkNum then
    self.LegenMarkNum = {}
  end
  if not self.LegenMarks then
    self.LegenMarks = {}
  end
  if not bIsShow and self.ExistInstanceIDs[instanceID] then
    typeID = self.ExistInstanceIDs[instanceID]
  end
  if not NewMapMarkConfig or not NewMapMarkConfig[typeID] then
    return
  end
  local config = NewMapMarkConfig[typeID]
  if not (config.bIsControlByLegend and config.LegendIconPath) or not config.LegendTextID then
    return
  end
  if bIsShow then
    if not self.ExistInstanceIDs[instanceID] then
      if not self.LegenMarkNum[config.LegendTextID] then
        self.LegendTextID2TypeID[config.LegendTextID] = {
          [1] = typeID
        }
        self.LegenMarkNum[config.LegendTextID] = 1
        self.LegenMarks[config.LegendTextID] = {
          Path = config.LegendIconPath,
          Tag = config.LegendTags
        }
        self:UpdateLegendUI(config.LegendTextID, true, config.LegendIconPath, config.LegendTags, typeID)
      else
        local LegendTextID = config.LegendTextID
        self.LegenMarkNum[config.LegendTextID] = self.LegenMarkNum[LegendTextID] + 1
        local bFound = false
        for _, TypeID in ipairs(self.LegendTextID2TypeID[LegendTextID]) do
          if TypeID == typeID then
            bFound = true
            break
          end
        end
        if not bFound then
          local Index = #self.LegendTextID2TypeID[LegendTextID] + 1
          self.LegendTextID2TypeID[LegendTextID][Index] = typeID
        end
      end
      self.ExistInstanceIDs[instanceID] = typeID
    end
  elseif self.ExistInstanceIDs[instanceID] then
    self.LegenMarkNum[config.LegendTextID] = self.LegenMarkNum[config.LegendTextID] - 1
    if self.LegenMarkNum[config.LegendTextID] <= 0 then
      self.LegenMarkNum[config.LegendTextID] = nil
      self.LegenMarks[config.LegendTextID] = nil
      self:UpdateLegendUI(config.LegendTextID, false, config.LegendIconPath, config.LegendTags)
    end
    self.ExistInstanceIDs[instanceID] = nil
  end
end
function MapMarkLegendSubsystem:UpdateLegendUI(TextID, bIsShow, iconPath, tags, typeID)
  local LegendUI = UIManager.GetUI(UIManager.UI_Config_InGame.EntireMapLegend)
  if not LegendUI then
    local EntireMapWindow = UIManager.GetUI(UIManager.UI_Config_InGame.EntireMapWindow)
    if EntireMapWindow then
      EntireMapWindow:ShowMapLegend()
    end
  else
    LegendUI:UpdateLegendUI(TextID, bIsShow, iconPath, tags, typeID)
  end
end
function MapMarkLegendSubsystem:ShowOrHideLegendWithTextID(TextID, bShow)
  local World = slua_GameFrontendHUD:GetWorld()
  local MapMarkUIManager = STExtraBlueprintFunctionLibrary.GetMapUIMarkComponent(World)
  if not MapMarkUIManager then
    print(bWriteLog and "MapMarkLegendSubsystem:ShowOrHideLegendWithTextID - MapMarkUIManager is nil")
    return
  end
  local LegendMark = self.LegendTextID2TypeID[TextID]
  if not LegendMark then
    print(bWriteLog and string.format("MapMarkLegendSubsystem:ShowOrHideLegendWithTextID - self.LegendTextID2TypeID[%s] is nil", tostring(TextID)))
    return
  end
  for _, TypeID in ipairs(LegendMark) do
    MapMarkUIManager:OnShowOrHideLegendMarkWidgetByType(TypeID, bShow)
  end
end
function MapMarkLegendSubsystem:HighLightLegendWithTextID(TextID)
  local World = slua_GameFrontendHUD:GetWorld()
  local MapMarkUIManager = STExtraBlueprintFunctionLibrary.GetMapUIMarkComponent(World)
  local LegendMark = self.LegendTextID2TypeID[TextID]
  if not LegendMark then
    print(bWriteLog and string.format("MapMarkLegendSubsystem:HighLightLegendWithTextID - self.LegendTextID2TypeID[%s] is nil", tostring(TextID)))
    return
  end
  for _, TypeID in ipairs(LegendMark) do
    MapMarkUIManager:ShowHighLightEntireMapMarkInfoByType(TypeID, 86)
  end
end
function MapMarkLegendSubsystem:OnRelease()
  print(bWriteLog and "MapMarkLegendSubsystem:OnRelease")
  MapMarkLegendSubsystem.__super.OnRelease(self)
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, MapMarkLegendSubsystem)