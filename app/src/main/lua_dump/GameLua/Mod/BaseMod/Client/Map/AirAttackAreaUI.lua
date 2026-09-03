local AirAttackAreaUI = {}
local STExtraMapFunctionLibrary = import("STExtraMapFunctionLibrary")
function AirAttackAreaUI:ctor(selfType, MapUI)
  printf("AirAttackAreaUI:ctor")
  self.LastAirAttackArea = FVector(0, 0, 0)
  self.  self.bLastCanShow = true
  self.bIsCanShow = true
end
function AirAttackAreaUI:OnInitialize()
  printf("AirAttackAreaUI:OnInitialize")
  self:BindMapUIBase(self.MapUI)
  self:InitUI(self.MapUI.MapWidgetLua)
  self.InitSuccess = true
  if self.LastAirAttackArea then
    self:Redraw(self.LastAirAttackArea)
  end
  if self.IsNeedShow ~= nil then
    self:OnShowOrHideAirAttack(self.IsNeedShow)
  end
end
function AirAttackAreaUI:OnPostInitialize()
  printf("AirAttackAreaUI:OnPostInitialize")
  AirAttackAreaUI.__super.OnPostInitialize(self)
end
function AirAttackAreaUI:RegistEvents()
  print(bWriteLog and "AirAttackAreaUI:RegistEvents")
  AirAttackAreaUI.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_DEATH_MATCH_UI_SETTING, self.OnDeathMatchUISetting, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_GAMEPLAY_SYNC_PLAYERSTATE, self.RedrawInMiniMap, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_MAP, EVENTID_ENTIRE_MAP_SHOW_RESIZE_MINIMAP, self.RedrawInMiniMap, self)
  local GameInstance = slua_GameFrontendHUD:GetGameInstance()
  if slua.isValid(GameInstance) then
    local GameReplay = GameInstance:GetCompletePlayback()
    if slua.isValid(GameReplay) then
      self:AddControlEventByControl(GameReplay, "OnReplayReadyInitUIDelegate", function()
        print(bWriteLog and "AirAttackAreaUI:RegistEvents OnReplayReadyInitUIDelegate HideAirAttack")
        self:OnShowOrHideAirAttack(false)
      end, self)
    end
  end
end
function AirAttackAreaUI:OnDeathMatchUISetting()
  self.bIgnoreRedraw = false
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) then
    local nReplayType = uPlayerController.GameReplayType
    local EGameReplayType = import("EGameReplayType")
    if nReplayType and (nReplayType == EGameReplayType.EGameReplayType_DeathPlayback or nReplayType == EGameReplayType.EGameReplayType_WonderfulPlayback) then
      self.bIgnoreRedraw = true
    end
  end
  self:RedrawInMiniMap()
end
function AirAttackAreaUI:RedrawWithLast()
  self:Redraw(self.LastAirAttackArea, true)
end
function AirAttackAreaUI:OnUnRegistEvents()
  print(bWriteLog and "AirAttackAreaUI:OnUnRegistEvents")
  if self.RepositionItemOnMapDel then
    if self.MapUIBase then
      self.MapUIBase.OnRepositionItemOnMap:Remove(self.RepositionItemOnMapDel)
    end
    self.RepositionItemOnMapDel = nil
  end
  if self.OnRepTeammateChangeDel then
    if self.MapUIBase and self.MapUIBase.STExtraPlayerController then
      self.MapUIBase.STExtraPlayerController:Remove(self.OnRepTeammateChangeDel)
    end
    self.OnRepTeammateChangeDel = nil
  end
end
function AirAttackAreaUI:OnCloseUI()
  printf("AirAttackAreaUI:Close")
  self:Close()
end
function AirAttackAreaUI:BindMapUIBase(MapUI)
  self.MapUIBase = MapUI.CurrentMapUI
  self.end
function AirAttackAreaUI:BindDelegates()
  if self.MapUI.bIsMiniMap then
    self.RepositionItemOnMapDel = self.MapUIBase.OnRepositionItemOnMap:Add(function()
      self:RedrawInMiniMap()
    end)
  elseif self.MapUIBase.STExtraPlayerController then
    self.OnRepTeammateChangeDel = self.MapUIBase.STExtraPlayerController:Add(function()
      self:Redraw(self.LastAirAttackArea)
    end)
  end
end
function AirAttackAreaUI:InitUI(ParentUI)
  if ParentUI and ParentUI.UIRoot.CommonFunctionAddPanel then
    ParentUI:AttachChildWindow("CommonFunctionAddPanel", self)
    self.UIRoot.Slot:SetAnchors(FAnchors(0, 0, 1, 1))
    self.UIRoot.Slot:SetOffsets(FMargin(0, 0, 0, 0))
  else
    self:ReFreshVisible()
  end
end
function AirAttackAreaUI:RedrawInMiniMap()
  if self.MapUI.bIsMiniMap then
    self:Redraw(self.LastAirAttackArea)
  end
end
function AirAttackAreaUI:RedrawInEntireMap()
  if not self.MapUI.bIsMiniMap then
    self:Redraw(self.LastAirAttackArea)
  end
end
function AirAttackAreaUI:Redraw(Area, bNotReCalMapInfo)
  if self.bIgnoreRedraw then
    print(bWriteLog and "AirAttackAreaUI:Redraw bIgnoreRedraw return")
    return
  end
  if not self.InitSuccess then
    self.LastAirAttackArea = Area:clone()
    return
  end
  if not bNotReCalMapInfo then
    self.MapUIBase:ReCalMapInfoC()
  end
  print(bWriteLog and "AirAttackAreaUI:Redraw Area:" .. tostring(Area.X) .. "," .. tostring(Area.Y) .. "," .. tostring(Area.Z))
  local PointLocationInLevel = Area
  local LevelLandScapeCenter = self.MapUIBase.LevelLandScapeCenterC
  local LevelToMapScale = self.MapUIBase:GetLevelToMapScale()
  local NewTranslation = STExtraMapFunctionLibrary.MapCenterToPointVector2D(PointLocationInLevel, LevelLandScapeCenter, LevelToMapScale)
  self.UIRoot.AirAttackArea:SetRenderTranslation(NewTranslation)
  local NewSize = PointLocationInLevel.Z * 2 * LevelToMapScale
  self.UIRoot.AirAttackArea.Slot:SetSize(FVector2D(NewSize, NewSize))
  self.LastAirAttackArea = Area:clone()
end
function AirAttackAreaUI:ReFreshVisible()
  if self.IsNeedShow and self:CheckIsCanShow() then
    self.UIRoot:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self.UIRoot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function AirAttackAreaUI:InitAirAttackAreaVisibility()
end
function AirAttackAreaUI:CheckIsCanShow()
  return self.bIsCanShow or self.bIsCanShow == nil
end
function AirAttackAreaUI:OnShowOrHideAirAttack(IsShow)
  print(bWriteLog and "AirAttackAreaUI:OnShowOrHideAirAttack IsShow:" .. tostring(IsShow))
  if not self.InitSuccess then
    self.IsNeedShow = IsShow
    return
  end
  self.IsNeedShow = IsShow
  self:ReFreshVisible()
  local GameBackendHUD = import("GameBackendHUD")
  local UIUtil = require("client.common.ui_util")
  local uGameFrontendHUD = UIUtil.GetGameFrontendHUD()
  local ColorBlindnessMgr = uGameFrontendHUD:GetColorBlindnessMgr()
  if not slua.isValid(ColorBlindnessMgr) then
    print(bWriteLog and "AirAttackAreaUI:OnShowOrHideAirAttack FAILED Case ColorBlindnessMgr is Not Valid")
    return
  end
  if IsShow then
    ColorBlindnessMgr:AddImage(self.UIRoot.AirAttackArea, FLinearColor(1, 1, 1, 1), 2)
  else
    ColorBlindnessMgr:RemoveImage(self.UIRoot.AirAttackArea)
  end
end
local class = require("class")
local UIBase = require("client.slua_ui_framework.base")
local CAirAttackAreaUI = class(UIBase, nil, AirAttackAreaUI)
return CAirAttackAreaUI