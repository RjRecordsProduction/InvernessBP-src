local IngameMapSys = {
  ModImpl = {}
}
local EMapType = import("EMapType")
function IngameMapSys:ctor(selfType)
  self.sDefaultMapDataPath = "/Game/BluePrints/UI/Map/MapDataBase_BP.MapDataBase_BP_C"
  print(bWriteLog and "IngameTeamItemSys:ctor 111")
end
function IngameMapSys:IsNoRenderClient()
  local frontendUtils
  if slua_GameFrontendHUD then
    frontendUtils = slua_GameFrontendHUD:GetUtils()
  end
  if frontendUtils and frontendUtils:GetGlobalUIContainer("Default") == nil then
    return true
  end
  return false
end
function IngameMapSys:GetMapDataPath(uGameState, MapType)
  local ClientGameMain = require("GameLua.GameCore.Main.ClientGameMain")
  if self:IsNoRenderClient() then
    print(bWriteLog and "IngameMapSys:GetMapDataPath no Default GlobalUIContainer")
    return ""
  end
  local Path = ClientGameMain.GetUIOtherSetting("MapDataPath")
  if MapType == EMapType.ENTIREMAP then
    local EntireMapDataPath = ClientGameMain.GetUIOtherSetting("EntireMapDataPath")
    if EntireMapDataPath then
      Path = EntireMapDataPath
    end
  else
    local MiniMapDataPath = ClientGameMain.GetUIOtherSetting("MiniMapDataPath")
    if MiniMapDataPath then
      Path = MiniMapDataPath
    end
  end
  if Path then
    log(bWriteLog and "map data path:" .. Path)
    return Path
  else
    return self.sDefaultMapDataPath
  end
end
function IngameMapSys:CheckNeedMiniMap()
  if self:IsNoRenderClient() then
    print(bWriteLog and "IngameMapSys:CheckNeedMiniMap IsNoRenderClient")
    return false
  end
  local UGameplayStatics = import("GameplayStatics")
  local UIUtil = require("client.common.ui_util")
  local uGameState = UGameplayStatics.GetGameState(UIUtil.GetGameInstance())
  if not slua.isValid(uGameState) then
    print(bWriteLog and "IngameMapSys:CheckNeedMiniMap no GameState")
    return false
  end
  if uGameState.GameModeID ~= "" and tonumber(uGameState.GameModeID) > 0 then
    return true
  else
    print(bWriteLog and "IngameMapSys:CheckNeedMiniMap False")
    return false
  end
end
function IngameMapSys:GetPlayerColorByIndexC(Index)
  if IngameMapSys.ModImpl.GetPlayerColorByIndexC then
    return IngameMapSys.ModImpl.GetPlayerColorByIndexC(Index)
  end
  local GetIndex = 0
  if Index == -1 then
    GetIndex = 0
  else
    GetIndex = Index + 1
  end
  local TeamPanelConfig = require("GameLua.Mod.BaseMod.Client.IngameTeamPanel.IngameTeamPanelConfig")
  local Color = TeamPanelConfig.TeamPlayerColorTable[GetIndex]
  Color = Color or FLinearColor(1, 1, 1, 1)
  return Color
end
function IngameMapSys:SetShowMakerLocation()
  self.bShowMarkerLocation = true
end
function IngameMapSys:GetShowMakerLocation()
  return self.bShowMarkerLocation
end
function IngameMapSys:OpenOrHideEntireMap()
  local EntireMapUIConfig = UIManager.UI_Config_InGame.EntireMapWindow
  local EntireMapUI = UIManager.GetUI(EntireMapUIConfig)
  if EntireMapUI then
    if UIManager.IsUIShow(EntireMapUIConfig) then
      UIManager.HideUI(EntireMapUIConfig)
    else
      UIManager.ShowUI(EntireMapUIConfig)
    end
  else
    UIManager.ShowUI(EntireMapUIConfig)
  end
end
function IngameMapSys:CheckCloseMiniMap()
  local EntireMapUIConfig = UIManager.UI_Config_InGame.EntireMapWindow
  local EntireMapUI = UIManager.GetUI(EntireMapUIConfig)
  if EntireMapUI and UIManager.IsUIShow(EntireMapUIConfig) then
    UIManager.HideUI(EntireMapUIConfig)
    return true
  end
  return false
end
function IngameMapSys:CheckUseNewMap()
  return true
end
local class = require("class")
local object = require("object")
local CIngameMapSys = class(object, nil, IngameMapSys)
return CIngameMapSys