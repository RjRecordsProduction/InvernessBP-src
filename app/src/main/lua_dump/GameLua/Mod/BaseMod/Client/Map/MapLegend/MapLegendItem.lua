local MapLegendItem = {
  LuaEventContainer = {
    "OnFadeOut",
    "OnShowHide",
    "OnMapLegendItemHighlight"
  },
  HideImgPath = "/Game/Arts/UI/Atlas/BattleUI/General_RGBA/Frames/ZD_icon_Routes01_png.ZD_icon_Routes01_png"
}
local BUTTON_LEGEND_LONG_PRESS_TIME = 0.25
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local STExtraBlueprintFunctionLibrary = import("/Script/ShadowTrackerExtra.STExtraBlueprintFunctionLibrary")
local ShowState = {
  None = 1,
  Hide = 2,
  Fade = 3,
  Highlight = 4
}
function MapLegendItem:ctor()
  self.ButtonHighlightTimer = nil
  self.AreaIDTypeIDMap = {}
  self.AreaIDTextIDMap = {}
  self.AreaIDTShowStateMap = {}
end
function MapLegendItem:RegistEvents()
  print(bWriteLog and "MapLegendItem:RegistEvents")
  self:AddControlEventByControl(self.UIRoot.Button_Legend, "OnPressed", self.OnPressedButton_Legend, self)
  self:AddControlEventByControl(self.UIRoot.Button_Legend, "OnReleased", self.OnReleasedButton_Legend, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_MAP, EVENTID_ENTIREMAP_SHOWORHIDE_MAPLEGEND, self.OnShowHideAllLegends, self)
end
function MapLegendItem:OnPostInitialize()
  if slua.isValid(self.UIRoot.Image_Select) then
    self.UIRoot.Image_Select:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function MapLegendItem:OnClose()
  print(bWriteLog and "MapLegendItem:OnClose")
end
function MapLegendItem:GetCurAreaID()
  local CurAreaID = ""
  local MapIconSubsystem = SubsystemMgr:Get("MapIconSubsystem")
  if MapIconSubsystem then
    CurAreaID = MapIconSubsystem:GetAreaID()
  end
  return CurAreaID
end
function MapLegendItem:OnRefresh(Data, SelectIndex)
  print(bWriteLog and "MapLegendItem:OnRefresh - Data.TypeID is nil")
  if not Data or not Data.TypeID then
    return
  end
  self.IconPath = Data.IconPath
  local CurAreaID = self:GetCurAreaID()
  self.AreaIDTypeIDMap[CurAreaID] = Data.TypeID
  self.AreaIDTextIDMap[CurAreaID] = Data.TextID
  if not self.AreaIDTShowStateMap[CurAreaID] then
    self.AreaIDTShowStateMap[CurAreaID] = ShowState.None
  end
  if not Data or not Data.IconPath then
    return
  end
  self.UIRoot.Image_Legend:SetBrushFromPathAsync(Data.IconPath, false)
  if Data.Text then
    self.UIRoot.TextBlock_Legend:SetText(Data.Text)
  else
    local Text = LocUtil.GetLocalizeResStr(Data.TextID)
    self.UIRoot.TextBlock_Legend:SetText(Text)
  end
  local MapLegendBase = self:GetLoopScrollBoxParentUI()
  MapLegendBase:BindLuaObjEvent(self, "OnFadeOut", MapLegendBase.OnAllItemsFadeOut, MapLegendBase)
  MapLegendBase:BindLuaObjEvent(self, "OnShowHide", MapLegendBase.OnItemShowHide, MapLegendBase)
  MapLegendBase:BindLuaObjEvent(self, "OnMapLegendItemHighlight", MapLegendBase.OnMapLegendItemHighlight, MapLegendBase)
  if MapLegendBase.MapLegendItemMap and type(MapLegendBase.MapLegendItemMap) == "table" then
    MapLegendBase.MapLegendItemMap[Data.TypeID] = self
  end
end
function MapLegendItem:OnPressedButton_Legend()
  print(bWriteLog and "MapLegendItem:OnPressedButton_Legend")
  local CurAreaID = self:GetCurAreaID()
  if not self.AreaIDTypeIDMap[CurAreaID] then
    return
  end
  if self.ButtonHighlightTimer ~= nil then
    self:RemoveGameTimer(self.ButtonHighlightTimer)
    self.ButtonHighlightTimer = nil
  end
  local CurShowState = self.AreaIDTShowStateMap[CurAreaID]
  if CurShowState == ShowState.None then
    self.ButtonHighlightTimer = self:AddGameTimer(BUTTON_LEGEND_LONG_PRESS_TIME, false, function()
      self:HighlightLegend(true)
      self:RemoveGameTimer(self.ButtonHighlightTimer)
      self.ButtonHighlightTimer = nil
    end)
    return
  end
  if CurShowState == ShowState.Fade then
    self:LuaBroadcast("OnFadeOut")
  else
    self:ShowOrHideLegend(CurShowState == ShowState.Hide)
  end
end
function MapLegendItem:OnHoveredButton_Legend()
  local CurAreaID = self:GetCurAreaID()
  local CurShowState = self.AreaIDTShowStateMap[CurAreaID]
  if CurShowState ~= ShowState.Fade then
    return
  end
  self:HighlightLegend(true)
end
function MapLegendItem:OnReleasedButton_Legend()
  print(bWriteLog and "MapLegendItem:OnReleasedButton_Legend")
  local CurAreaID = self:GetCurAreaID()
  local CurShowState = self.AreaIDTShowStateMap[CurAreaID]
  if self.ButtonHighlightTimer ~= nil then
    self:RemoveGameTimer(self.ButtonHighlightTimer)
    self.ButtonHighlightTimer = nil
    self:ShowOrHideLegend(CurShowState == ShowState.Hide)
  elseif CurShowState == ShowState.Highlight or CurShowState == ShowState.Fade then
    self:LuaBroadcast("OnFadeOut")
  end
end
function MapLegendItem:ShowOrHideLegend(bShow)
  print(bWriteLog and string.format("MapLegendItem:ShowOrHideLegend - bShow %s", tostring(bShow)))
  self.UIRoot.Image_Select:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  local CurAreaID = self:GetCurAreaID()
  if bShow then
    self.AreaIDTShowStateMap[CurAreaID] = ShowState.None
    self.UIRoot.Image_Legend:SetBrushFromPathAsync(self.IconPath, false)
    self.UIRoot.Image_Legend:SetColorAndOpacity(FLinearColor(1, 1, 1, 1))
    self:LuaBroadcast("OnShowHide", true)
  else
    self.AreaIDTShowStateMap[CurAreaID] = ShowState.Hide
    self.UIRoot.Image_Legend:SetBrushFromPathAsync(self.HideImgPath, false)
    self:LuaBroadcast("OnShowHide", false)
    local uPlayerState = GameplayData.GetPlayerState()
    if slua.isValid(uPlayerState) then
      uPlayerState:RPC_ServerAddGeneralCount(11543, 1, false)
    end
  end
  local TextID = self.AreaIDTextIDMap[CurAreaID]
  if not TextID then
    return
  end
  local MapMarkLegendSubsystem = SubsystemMgr:Get("MapMarkLegendSubsystem")
  if MapMarkLegendSubsystem and MapMarkLegendSubsystem.ShowOrHideLegendWithTextID then
    MapMarkLegendSubsystem:ShowOrHideLegendWithTextID(TextID, bShow)
  end
end
function MapLegendItem:OnShowHideAllLegends(_, __, bShow)
  self.UIRoot.Image_Select:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  local CurAreaID = self:GetCurAreaID()
  if bShow then
    self.AreaIDTShowStateMap[CurAreaID] = ShowState.None
    self.UIRoot.Image_Legend:SetBrushFromPathAsync(self.IconPath, false)
    self.UIRoot.Image_Legend:SetColorAndOpacity(FLinearColor(1, 1, 1, 1))
  else
    self.AreaIDTShowStateMap[CurAreaID] = ShowState.Hide
    self.UIRoot.Image_Legend:SetBrushFromPathAsync(self.HideImgPath, false)
  end
end
function MapLegendItem:HighlightLegend(bHighlight)
  print(bWriteLog and "MapLegendItem:HighlightLegend")
  local World = slua_GameFrontendHUD:GetWorld()
  local MapMarkUIManager = STExtraBlueprintFunctionLibrary.GetMapUIMarkComponent(World)
  if not MapMarkUIManager then
    return
  end
  local CurAreaID = self:GetCurAreaID()
  if not self.AreaIDTypeIDMap[CurAreaID] then
    return
  end
  local TypeID = self.AreaIDTypeIDMap[CurAreaID]
  local TextID = self.AreaIDTextIDMap[CurAreaID]
  if bHighlight then
    self:ShowOrHideLegend(true)
    self.AreaIDTShowStateMap[CurAreaID] = ShowState.Highlight
    self:LuaBroadcast("OnMapLegendItemHighlight", TypeID)
    self.UIRoot:SetColorAndOpacity(FLinearColor(1, 1, 1, 1))
    self.UIRoot.Image_Select:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    local MapMarkLegendSubsystem = SubsystemMgr:Get("MapMarkLegendSubsystem")
    if MapMarkLegendSubsystem and MapMarkLegendSubsystem.HighLightLegendWithTextID then
      MapMarkLegendSubsystem:HighLightLegendWithTextID(TextID)
    end
    local uPlayerState = GameplayData.GetPlayerState()
    if slua.isValid(uPlayerState) then
      uPlayerState:RPC_ServerAddGeneralCount(11544, 1, false)
    end
  else
    self.AreaIDTShowStateMap[CurAreaID] = ShowState.None
    MapMarkUIManager:HideHighLightEntireMapMarkInfoByType()
    self.UIRoot.Image_Select:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function MapLegendItem:FadeLegend(bFadeIn)
  print(bWriteLog and "MapLegendItem:FadeLegend")
  local CurAreaID = self:GetCurAreaID()
  if self.AreaIDTShowStateMap[CurAreaID] == ShowState.Highlight then
    self:HighlightLegend(false)
  end
  if bFadeIn then
    self.AreaIDTShowStateMap[CurAreaID] = ShowState.Fade
    self.UIRoot:SetColorAndOpacity(FLinearColor(1, 1, 1, 0.5))
  else
    self.UIRoot:SetColorAndOpacity(FLinearColor(1, 1, 1, 1))
    self:ShowOrHideLegend(true)
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.component.scroll_box_child_base")
local CMapLegendItem = class(ui_base, nil, MapLegendItem)
return CMapLegendItem