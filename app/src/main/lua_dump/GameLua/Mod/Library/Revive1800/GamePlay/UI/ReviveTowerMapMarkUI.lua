local ReviveTowerMapMarkUI = {}
function ReviveTowerMapMarkUI:Initialize()
  print(bWriteLog and "ReviveTowerMapMarkUI:Initialize")
  self.PropertyArray = {
    [1] = {
      UpdateWidget = self.Image_5,
      IconColorArray = {
        FLinearColor(0.002428, 0.456411, 0.181164, 1),
        FLinearColor(0.545725, 0.545725, 0.545725, 1)
      }
    }
  }
end
function ReviveTowerMapMarkUI:LuaOnUIBPCreate(CustomState, CustomString, CreateTime, InWhichMap, ParentState)
  local EMarkParentWidget = import("EMarkParentWidget")
  if ParentState == EMarkParentWidget.EMPW_EntireMap then
    self.bIsEntireMap = true
    self:InitChangeIconScale()
  end
  self:SetUpdatePropertyArray(self.PropertyArray, CustomState)
end
function ReviveTowerMapMarkUI:InitChangeIconScale()
  local CurGameModeID = Client.GetGameModeID(GameFrontendHUD)
  local ModeTableData = CDataTable.GetTableData("BTMode", CurGameModeID)
  if ModeTableData == nil or ModeTableData.MapID == nil then
    return
  end
  local mapId = ModeTableData.MapID
  local MapData = CDataTable.GetTableData("Map", mapId)
  if MapData == nil or MapData.MapPath == nil then
    return
  end
  local MapPath = MapData.MapPath
  local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
  local ReviveTowerConfig = GamePlayTools.GetCurrentConfig("ReviveTowerConfig")
  if ReviveTowerConfig and ReviveTowerConfig.MapMarkIconChangeScale then
    if ReviveTowerConfig.MapMarkIconChangeScale[MapPath] then
      self.ChangeScale = ReviveTowerConfig.MapMarkIconChangeScale[MapPath]
    elseif ReviveTowerConfig.MapMarkIconChangeScale[0] then
      self.ChangeScale = ReviveTowerConfig.MapMarkIconChangeScale[0]
    else
      self.ChangeScale = 4
    end
  end
end
function ReviveTowerMapMarkUI:LuaUpdateMarkSize(size)
  if self.bIsEntireMap then
    if not self.ChangeScale then
      self:InitChangeIconScale()
      if not self.ChangeScale then
        return
      end
    end
    if not self.EntireMapUI then
      self.EntireMapUI = UIManager.GetUI(UIManager.UI_Config_InGame.EntireMapWindow)
      if not self.EntireMapUI then
        return
      end
    end
    local IsBigIcon = self.EntireMapUI:GetEntireMapUI().MapScalingRadio > self.ChangeScale
    if self.LastIsBigIcon ~= nil and self.LastIsBigIcon == IsBigIcon then
      return
    end
    if IsBigIcon then
      self.Image_5:SetBrush(self.IconBrush:Get(0))
    else
      self.Image_5:SetBrush(self.IconBrush:Get(1))
    end
    self.Last  end
end
function ReviveTowerMapMarkUI:OnDestroy()
  print(bWriteLog and "ReviveTowerMapMarkUI:OnDestroy")
  self:Dispose()
end
function ReviveTowerMapMarkUI:ReceivedInitWidget()
  print(bWriteLog and "ReviveTowerMapMarkUI:ReceivedInitWidget")
end
local class = require("class")
local object = require("common.delegate_container")
return class(object, nil, ReviveTowerMapMarkUI)