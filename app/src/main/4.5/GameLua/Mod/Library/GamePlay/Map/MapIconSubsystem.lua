local MapIconSubsystem = {}
local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")
local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local MarkDispatchManager_C = import("/Script/ShadowTrackerExtra.MarkDispatchManager")
local UGameplayStatics = import("GameplayStatics")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
function MapIconSubsystem:OnInit()
  print(bWriteLog and "MapIconSubsystem:OnInit")
  self.bClient = Client ~= nil
  self.MapMarkItem = {}
  self.CurShowingLayerIDs = {
    [-1] = 1
  }
  self.DefaultInstanceID = 1
  self.bMapLegendShow = true
  self.EntireMapScale = {}
  self.MapUICache = {}
  self.RefreshIconItemEachTime = 60
  self.BalticHideTags = {}
  self:InitMapIconData()
  self.ChangeMapArea = {}
  self.DefaultMapArea = {}
  if self.bClient then
    self:AddCommonEvent(EVENTTYPE_INGAME_MAP, EVENTID_CHANGE_MAP_TEXTURE, self.HandleMapChange, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_MAP, EVENTID_CHANGE_MAP_TEXTURE_WITHOUT_TAGS, self.HandleMapChange, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_MAP, EVENTID_AFTER_CHANGE_MAP_TEXTURE, self.RefreshMapIconAfterTexureInit, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_MAP, EVENTID_ENTIRE_MAP_SHOW_RESIZE_MINIMAP, self.ReCheckArea, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_MAP, EVENTID_ADD_CHANGE_MAP_AREA, self.AddChangeMapArea, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_MAP, EVENTID_SUB_CHANGE_MAP_AREA, self.SubChangeMapArea, self)
    self:AddCommonEvent(EVENTTYPE_PLAYEREVENT_CHARACTER, EVENTID_PLAYEREVENT_LOCAL_CHAR_MAP_ID_CHANGED, self.CharacterAttrChangeEvent, self)
    GameplayData.AddPlayerControllerEvent(self, nil, "OnSpectatorChange", function()
      print(bWriteLog and "MapIconSubsystem OnSpectatorChange")
      self:ReCheckArea()
    end, self)
    GameplayData.AddPlayerControllerEvent(self, nil, "OnPlayerQuitSpectatingForClient", function()
      print(bWriteLog and "MapIconSubsystem OnPlayerQuitSpectatingForClient")
      self:ReCheckArea()
    end, self)
    self:AddPOIPoint()
    local uGameInstance = slua_GameFrontendHUD:GetGameInstance()
    if slua.isValid(uGameInstance) then
      local uGameReplay = uGameInstance:GetCompletePlayback()
      if slua.isValid(uGameReplay) then
        self:AddControlEvent(uGameReplay, "OnReplayResetViewTargetDelegate", self.OnReplayResetViewTarget, self)
      end
    end
    self:AddChangeMapConfigArea()
    EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_REFRESH_POI_MAPPRAM)
    self:OnInitBalticHideTag()
    self:HandleMapChange(nil, nil, "", 0, "")
    self:ReCheckArea()
  else
    self:AddCommonEventWithConditions(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, {
      [1] = "ReadyState"
    }, self.HandleEnterGameModeReadyState, self)
    self:AddCommonEventWithConditions(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, {
      [1] = "FightingState"
    }, self.HandleEnterGameModeFightingState, self)
  end
end
function MapIconSubsystem:OnInitBalticHideTag()
  self.BalticHideTags = {}
  local NewMapMarkConfig = GamePlayTools.GetCurrentConfig("NewMapMarkConfig")
  if NewMapMarkConfig and NewMapMarkConfig.LegendTagMap then
    for Key, Tags in pairs(NewMapMarkConfig.LegendTagMap) do
      if Key == "" then
        for _, TagName in pairs(Tags) do
          self.BalticHideTags[TagName] = false
        end
      else
        for _, TagName in pairs(Tags) do
          if self.BalticHideTags[TagName] == nil then
            self.BalticHideTags[TagName] = true
          end
        end
      end
    end
  end
end
function MapIconSubsystem:OnReplayResetViewTarget()
  local uPlayerController = GameplayData.GetPlayerController()
  print(bWriteLog and "MapIconSubsystem:OnReplayResetViewTarget", uPlayerController)
  if not slua.isValid(uPlayerController) then
    return
  end
  local uCurPawn = uPlayerController:GetCurPawn()
  print(bWriteLog and "MapIconSubsystem:OnReplayResetViewTarget", uCurPawn, uPlayerController.bIsForReplay)
  if slua.isValid(uCurPawn) and uPlayerController.bIsForReplay then
    self:ReCheckArea()
  end
end
function MapIconSubsystem:AddPOIPoint()
  local NewMapMarkConfig = GamePlayTools.GetCurrentConfig("NewMapMarkConfig")
  if NewMapMarkConfig and NewMapMarkConfig.POILocation then
    for _, Location in ipairs(NewMapMarkConfig.POILocation) do
      InGameMarkTools.ClientAddMapMark(101, Location)
    end
  end
end
function MapIconSubsystem:OnRelease()
  if self.MapMarkItem then
    for Tag, Values in pairs(self.MapMarkItem) do
      if Values then
        for ID, MarkAction in pairs(Values) do
          self:ShowHideMapMark(Tag, ID, false)
        end
      end
    end
  end
  self.MapMarkItem = nil
  self.uMarkDispatchManager = nil
  self.CurShowingLayerIDs = nil
  self.MapUICache = {}
  MapIconSubsystem.__super.OnRelease(self)
end
function MapIconSubsystem:InitMapIconData()
end
function MapIconSubsystem:HandleMapChange(_, __, MapPath, Scale, ID)
  print(bWriteLog and "MapIconSubsystem:HandleMapChange", MapPath, Scale, ID)
  if MapPath == "" and Scale == 0 and ID == "" and self.AreaID then
    return
  end
  local world = slua_GameFrontendHUD:GetWorld()
  local MapMarkUIManager = STExtraBlueprintFunctionLibrary.GetMapUIMarkComponent(world)
  if self.AreaID ~= ID then
    self.HasChangeArea = true
    local AreaTag = self.AreaID
    if AreaTag == nil or AreaTag == "" then
      AreaTag = "Baltic"
    end
    self.ChangeArea = true
    self:ClearMapMark()
    local EntireMap = UIManager.GetUI(UIManager.UI_Config_InGame.EntireMapWindow)
    if EntireMap then
      local EntireMapUI = EntireMap:GetEntireMapUI()
      if EntireMapUI then
        self.EntireMapScale[AreaTag] = EntireMapUI.MapScalingRadio
      end
    end
    if self.AreaID then
      local MapMarkConfig = GamePlayTools.GetCurrentConfig("NewMapMarkConfig")
      if MapMarkUIManager and MapMarkConfig then
        if MapMarkConfig.LegendTagMap and MapMarkConfig.LegendTagMap[self.AreaID] then
          for key, value in pairs(MapMarkConfig.LegendTagMap[self.AreaID]) do
            MapMarkUIManager:OnShowOrHideLegendMarkWidget(value, false)
          end
        else
          MapMarkUIManager:OnShowOrHideLegendMarkWidget(self.AreaID, false)
        end
      end
    end
  end
  self.Area  self.bBaltic = ID == ""
  if ID == "" then
    self:UpdateCurShowingLayerIDs({-1})
    self:CheckGuideLine(true)
    if MapMarkUIManager and self.BalticHideTags then
      for TagName, bIsHide in pairs(self.BalticHideTags) do
        if bIsHide then
          MapMarkUIManager:OnShowOrHideLegendMarkWidget(TagName, false)
        end
      end
    end
  else
    self:UpdateCurShowingLayerIDs({})
    if MapMarkUIManager then
      MapMarkUIManager:OnShowOrHideLegendMarkWidget("", false)
    end
    self:CheckGuideLine(false)
  end
  self:CheckChangeMapBtn()
  EventSystem:postEvent(EVENTTYPE_INGAME_MAP, EVENTID_REFRESHMAPLEGEND_WITHLAYER)
  print(bWriteLog and "MapIconSubsystem:HandleMapChange" or "", "MapPath", MapPath, "Scale", Scale, "ID", ID, "self.AreaID", self.AreaID, "self.bBaltic", self.bBaltic)
end
function MapIconSubsystem:CheckChangeMapBtn()
  local EntireMap = UIManager.GetUI(UIManager.UI_Config_InGame.EntireMapWindow)
  if not EntireMap then
    return
  end
  local uController = GameplayData.GetPlayerController()
  if not slua.isValid(uController) or not uController.GetCurPlayerCharacterOrPetSpectator then
    return
  end
  local uCharacter = uController:GetCurPlayerCharacterOrPetSpectator()
  local TempAreaID
  if slua.isValid(uCharacter) then
    local Area = uCharacter:GetAttrValue("MapID") or 0
    self.LastAreaID = math.floor(Area + 0.5)
    TempAreaID = self.LastAreaID
  else
    return
  end
  local UI = UIManager.GetUI(UIManager.UI_Config_InGame.AreaPlayerNumPanel)
  if TempAreaID ~= nil and 0 < TempAreaID then
    if not UI then
      UIManager.ShowUI(UIManager.UI_Config_InGame.AreaPlayerNumPanel)
    else
      UI:SelfHitTestInvisible()
      UI:ResetMapID(TempAreaID, self.bBaltic)
    end
  elseif UI then
    UI:Collapsed()
  end
end
function MapIconSubsystem:CheckGuideLine(bIsShow)
  local MiniMap = UIManager.GetUI(UIManager.UI_Config_InGame.MiniMapWindow)
  local EntireMap = UIManager.GetUI(UIManager.UI_Config_InGame.EntireMapWindow)
  if not MiniMap or not EntireMap then
    return
  end
  local CurrentMapUI = MiniMap.UIRoot.CurrentMapUIBP.CurrentMapUI
  local CurrentEntireMap = EntireMap.UIRoot.CurrentMapUIBP.CurrentMapUI
  if bIsShow then
    CurrentMapUI.bNeedDrawCircleGuideLineC = true
    CurrentEntireMap.bNeedDrawCircleGuideLineC = true
  else
    CurrentMapUI.bNeedDrawCircleGuideLineC = false
    CurrentEntireMap.bNeedDrawCircleGuideLineC = false
  end
end
function MapIconSubsystem:HandleEnterGameModeReadyState()
end
function MapIconSubsystem:HandleEnterGameModeFightingState()
end
function MapIconSubsystem:UpdateMapMark(Tag, ID, Pos, CustomState, CustomString, CustomCanvasTag)
  if not Tag or not ID then
    return
  end
  local TrueCustomState = CustomState or 0
  local TrueCustomString = CustomString or ""
  if self.MapMarkItem then
    if not self.MapMarkItem[Tag] or not self.MapMarkItem[Tag][ID] then
      local MapMarkAction
      if self.bClient then
        MapMarkAction = InGameMarkTools.ClientAddMapMark(self.MapMarkTypeID[Tag], Pos, TrueCustomState, TrueCustomString)
      else
        MapMarkAction = InGameMarkTools.ServerAddMapMark(self.MapMarkTypeID[Tag], Pos, TrueCustomState)
      end
      if MapMarkAction then
        self.MapMarkItem[Tag] = self.MapMarkItem[Tag] or {}
        self.MapMarkItem[Tag][ID] = MapMarkAction
      end
    else
      self:UpdateMapMarkState(Tag, ID, TrueCustomState, Pos, TrueCustomString)
    end
  end
end
function MapIconSubsystem:ShowHideMapMark(Tag, ID, bShow)
  if not Tag then
    return
  end
  if not ID then
    if self.MapMarkItem and self.MapMarkItem[Tag] then
      for ID, MarkAction in pairs(self.MapMarkItem[Tag]) do
        local MarkAction = self.MapMarkItem[Tag][ID]
        if MarkAction then
          if self.bClient then
            if bShow then
              InGameMarkTools.ShowMapMark(MarkAction)
            else
              InGameMarkTools.HideMapMark(MarkAction)
            end
          elseif bShow then
            InGameMarkTools.ShowMapMark(MarkAction)
          else
            InGameMarkTools.HideMapMark(MarkAction)
          end
        end
      end
    end
  elseif self.MapMarkItem and self.MapMarkItem[Tag] and self.MapMarkItem[Tag][ID] then
    local MarkAction = self.MapMarkItem[Tag][ID]
    if MarkAction then
      if self.bClient then
        if bShow then
          InGameMarkTools.ShowMapMark(MarkAction)
        else
          InGameMarkTools.HideMapMark(MarkAction)
        end
      elseif bShow then
        InGameMarkTools.ShowMapMark(MarkAction)
      else
        InGameMarkTools.HideMapMark(MarkAction)
      end
    end
  end
end
function MapIconSubsystem:UpdateMapMarkState(Tag, ID, CustomState, Pos, CustomString)
  if not Tag or not ID then
    return
  end
  if self.MapMarkItem and self.MapMarkItem[Tag] and self.MapMarkItem[Tag][ID] then
    local uMarkInstID = self.MapMarkItem[Tag][ID]
    if uMarkInstID then
      local MarkCustomData = {
        Location = Pos,
        CustomState = CustomState or 0,
              }
      InGameMarkTools.UpdateMapMarkCustomData(uMarkInstID, MarkCustomData)
    end
  end
end
function MapIconSubsystem:GetCurShowingLayerIDs()
  return self.CurShowingLayerIDs
end
function MapIconSubsystem:CheckLayerIsShowing(LayerID)
  if not self.CurShowingLayerIDs then
    return true
  end
  return self.CurShowingLayerIDs[LayerID] ~= nil
end
function MapIconSubsystem:UpdateCurShowingLayerIDs(LayerIDs)
  self.CurShowingLayerIDs = {}
  for _, v in ipairs(LayerIDs) do
    self.CurShowingLayerIDs[v] = 1
  end
  print(bWriteLog and "MapIconSubsystem:UpdateCurShowingLayerIDs Timer")
  self.RefreshIndex = #self.MapUICache
  self:RefreshIconVisibility()
end
function MapIconSubsystem:RefreshIconVisibility()
  if not self.RefreshIndex then
    self.RefreshIndex = #self.MapUICache
  end
  if #self.MapUICache == 0 then
    self.RefreshIndex = 0
    return
  end
  local IsAllRefreshed = false
  for i = 0, self.RefreshIconItemEachTime do
    local Index = self.RefreshIndex - i
    if 0 < Index then
      local Item = self.MapUICache[Index]
      if Item and Item.RefreshVisibilityByLayerID then
        Item:RefreshVisibilityByLayerID()
      end
    else
      IsAllRefreshed = true
      break
    end
  end
  if IsAllRefreshed then
    self.RefreshIndex = #self.MapUICache
  else
    self.RefreshIndex = self.RefreshIndex - self.RefreshIconItemEachTime - 1
  end
end
function MapIconSubsystem:AddToMapIconCache(icon)
  table.insert(self.MapUICache, icon)
end
function MapIconSubsystem:RemoveFromMapIconCache(icon)
  if not self.MapUICache then
    return
  end
  local Index = -1
  for i = 1, #self.MapUICache do
    local IconItem = self.MapUICache[i]
    if IconItem == icon then
      Index = i
      break
    end
  end
  if Index <= 0 then
    return
  end
  table.remove(self.MapUICache, Index)
end
function MapIconSubsystem:RefreshMapIconAfterTexureInit()
  EventSystem:postEvent(EVENTTYPE_INGAME_MAP, EVENTID_REFRESHMAPICON_TRANSLATION, true)
  EventSystem:postEvent(EVENTTYPE_INGAME_MAP, EVENTID_REFRESHMAPICON_TRANSLATION, false)
  if not self.HasChangeArea then
    return
  end
  self.HasChangeArea = false
  local EntireMap = UIManager.GetUI(UIManager.UI_Config_InGame.EntireMapWindow)
  if not EntireMap then
    return
  end
  local EntireMapUI = EntireMap:GetEntireMapUI()
  local NewScale = 1
  local AreaTag = self.AreaID
  if AreaTag == nil or AreaTag == "" then
    AreaTag = "Baltic"
  end
  if self.EntireMapScale[AreaTag] then
    NewScale = self.EntireMapScale[AreaTag]
  end
  if NewScale == EntireMapUI.MapScalingRadio then
    return
  end
  local ChangeValue = NewScale - EntireMapUI.MapScalingRadio
  EntireMap:HandleScaleMap(ChangeValue)
  EntireMap.FocusCenter = true
end
function MapIconSubsystem:GetOneInstanceID()
  local ID = self.DefaultInstanceID
  self.DefaultInstanceID = self.DefaultInstanceID + 1
  return ID
end
function MapIconSubsystem:SetMapLegendShow(bShow)
  self.bMapLegendShow = bShow
end
function MapIconSubsystem:GetAreaID()
  if not self.AreaID then
    return ""
  end
  return self.AreaID
end
function MapIconSubsystem:ReCheckArea()
  local AreaID
  local uController = GameplayData.GetPlayerController()
  local bIsOB = slua.isValid(uController) and uController.IsObserver and uController:IsObserver()
  if bIsOB then
    return
  end
  if not slua.isValid(uController) or not uController.GetCurPlayerCharacterOrPetSpectator then
    print(bWriteLog and "MapIconSubsystem:ReCheckArea no valid Controller", AreaID)
    AreaID = self.AreaID
  else
    local uCharacter = uController:GetCurPlayerCharacterOrPetSpectator()
    if not slua.isValid(uCharacter) then
      print(bWriteLog and "MapIconSubsystem:ReCheckArea no valid character", AreaID)
      AreaID = self.AreaID
    else
      AreaID = uCharacter:GetAttrValue("MapID") or 0
      local TempAreaID = math.floor(AreaID + 0.5)
      if TempAreaID == 0 then
        AreaID = ""
      else
        AreaID = tostring(TempAreaID)
      end
    end
  end
  if AreaID == nil then
    return
  end
  local TableUtil = require("common.table_util")
  local nIndex = TableUtil.Find(self.ChangeMapArea, AreaID)
  local nSubIndex = TableUtil.Find(self.DefaultMapArea, AreaID)
  if nIndex == -1 and AreaID ~= "" and nSubIndex == -1 then
    return
  end
  if AreaID == "" or nSubIndex ~= -1 then
    EventSystem:postEvent(EVENTTYPE_INGAME_MAP, EVENTID_CHANGE_MAP_TEXTURE, "", 1, "")
  else
    local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
    local ChangeMapConfig = GamePlayTools.GetCurrentConfig("ChangeMapConfig")
    local Scale = 0.2
    if ChangeMapConfig then
      if ChangeMapConfig.MapAreaScale and ChangeMapConfig.MapAreaScale[AreaID] then
        Scale = ChangeMapConfig.MapAreaScale[AreaID]
      elseif ChangeMapConfig.DefauleScale then
        Scale = ChangeMapConfig.DefauleScale
      end
    end
    EventSystem:postEvent(EVENTTYPE_INGAME_MAP, EVENTID_CHANGE_MAP_TEXTURE, "AUTO", Scale, AreaID)
  end
end
function MapIconSubsystem:CharacterAttrChangeEvent(EventType, EventID, AttrVal)
  print(bWriteLog and "MapIconSubsystem:CharacterAttrChangeEvent AreaID", AttrVal)
  self:ReCheckArea()
end
function MapIconSubsystem:ClearMapMark()
  local uSelfPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(uSelfPlayerController) then
    uSelfPlayerController:SetPlayerMark(FVector(0, 0, 0))
    uSelfPlayerController:SetPlayerMapMultiMark(FVector(0, 0, 0), false, 0, true)
    local uPlayerState = uSelfPlayerController:GetCurPlayerState()
    if slua.isValid(uPlayerState) then
      uPlayerState:SetPlayerMapMultiMark(FVector(0, 0, 0), false, 0, true)
    end
  end
end
function MapIconSubsystem:AddChangeMapArea(_, _, AreaID)
  print(bWriteLog and "MapIconSubsystem:AddChangeMapArea :", AreaID)
  local TableUtil = require("common.table_util")
  local StrAreaID = tostring(AreaID)
  local nIndex = TableUtil.Find(self.ChangeMapArea, StrAreaID)
  local uController = GameplayData.GetPlayerController()
  local bIsOB = slua.isValid(uController) and uController.IsObserver and uController:IsObserver()
  if nIndex == -1 and not bIsOB then
    table.insert(self.ChangeMapArea, StrAreaID)
    local CurAreaID
    if not slua.isValid(uController) or not uController.GetCurPlayerCharacterOrPetSpectator then
      print(bWriteLog and "MapIconSubsystem:AddChangeMapArea no valid Controller", AreaID)
      CurAreaID = self.AreaID
    else
      local uCharacter = uController:GetCurPlayerCharacterOrPetSpectator()
      if not slua.isValid(uCharacter) then
        print(bWriteLog and "MapIconSubsystem:AddChangeMapArea no valid character", AreaID)
        CurAreaID = self.AreaID
      else
        local AreaID = uCharacter:GetAttrValue("MapID") or 0
        local TempAreaID = math.floor(AreaID + 0.5)
        if TempAreaID == 0 then
          CurAreaID = ""
        else
          CurAreaID = tostring(TempAreaID)
        end
      end
    end
    if CurAreaID == StrAreaID then
      local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
      local ChangeMapConfig = GamePlayTools.GetCurrentConfig("ChangeMapConfig")
      local Scale = 0.2
      if ChangeMapConfig then
        if ChangeMapConfig.MapAreaScale and ChangeMapConfig.MapAreaScale[CurAreaID] then
          Scale = ChangeMapConfig.MapAreaScale[CurAreaID]
        elseif ChangeMapConfig.DefauleScale then
          Scale = ChangeMapConfig.DefauleScale
        end
      end
      EventSystem:postEvent(EVENTTYPE_INGAME_MAP, EVENTID_CHANGE_MAP_TEXTURE, "AUTO", Scale, CurAreaID)
    end
  end
end
function MapIconSubsystem:SubChangeMapArea(_, _, AreaID)
  print(bWriteLog and "MapIconSubsystem:SubChangeMapArea :", AreaID)
  local TableUtil = require("common.table_util")
  local StrAreaID = tostring(AreaID)
  local nIndex = TableUtil.Find(self.DefaultMapArea, StrAreaID)
  if nIndex == -1 then
    table.insert(self.DefaultMapArea, StrAreaID)
    local CurAreaID
    local uController = GameplayData.GetPlayerController()
    if not slua.isValid(uController) or not uController.GetCurPlayerCharacterOrPetSpectator then
      print(bWriteLog and "MapIconSubsystem:AddChangeMapArea no valid Controller", AreaID)
      CurAreaID = self.AreaID
    else
      local uCharacter = uController:GetCurPlayerCharacterOrPetSpectator()
      if not slua.isValid(uCharacter) then
        print(bWriteLog and "MapIconSubsystem:AddChangeMapArea no valid character", AreaID)
        CurAreaID = self.AreaID
      else
        local AreaID = uCharacter:GetAttrValue("MapID") or 0
        local TempAreaID = math.floor(AreaID + 0.5)
        if TempAreaID == 0 then
          CurAreaID = ""
        else
          CurAreaID = tostring(TempAreaID)
        end
      end
    end
    if CurAreaID == StrAreaID then
      EventSystem:postEvent(EVENTTYPE_INGAME_MAP, EVENTID_CHANGE_MAP_TEXTURE, "", 1, "")
    end
  end
end
function MapIconSubsystem:AddChangeMapConfigArea()
  local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
  local MapType = GameMainConfig.GetMapType()
  MapType = MapType or "Default"
  local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
  local ChangeMapConfig = GamePlayTools.GetCurrentConfig("ChangeMapConfig")
  if not ChangeMapConfig or not ChangeMapConfig.POIParam then
    return
  end
  local ParamConfig = ChangeMapConfig.POIParam[MapType]
  local DefaultConfig = ChangeMapConfig.POIParam.Default
  if not ParamConfig then
    if DefaultConfig then
      ParamConfig = DefaultConfig
    else
      return
    end
  end
  local TableUtil = require("common.table_util")
  for AreaID, _ in pairs(ParamConfig) do
    local StrAreaID = tostring(AreaID)
    local nIndex = TableUtil.Find(self.ChangeMapArea, StrAreaID)
    if nIndex == -1 then
      table.insert(self.ChangeMapArea, StrAreaID)
    end
  end
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, MapIconSubsystem)