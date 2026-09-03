local MapLegendBase = {
  MapLegendItemPath = "GameLua.Mod.BaseMod.Client.Map.MapLegend.MapLegendItem"
}
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local STExtraBlueprintFunctionLibrary = import("/Script/ShadowTrackerExtra.STExtraBlueprintFunctionLibrary")
function MapLegendBase:ctor()
  self.ItemConfig = {}
  self.ItemConfigIndex = 0
  self.AutoLegendIconPath = {}
  self.TagCheckState = {}
  self.AreaCheckFinalState = {}
  self.bIsHide = false
  self.bChecked = true
  self.bResourceFilterOpen = false
  self.ResourceTag2Index = {
    PremiumResourceTag = 1,
    StandardResourceTag = 2,
    FixedVehicleResourceTag = 3,
    NearVehicleResourceTag = 4
  }
  self.MapLegendItemMap = {}
  self.ShowItemsCount = 0
end
function MapLegendBase:OnInitialize()
  MapLegendBase.__super.OnInitialize(self)
  self.LoopScrollResource = self:InitChildClassScrollBox(self.UIRoot.LoopScrollBox_Resource, "GameLua.Mod.BaseMod.Client.Map.ResourceFilterItem")
  local ItemCount = #self.ItemConfig
  self.LoopScroll = self:InitChildClassScrollBox(self.UIRoot.LoopScrollBox_Legend, self.MapLegendItemPath)
  self.LegendWidth = 150
  if ItemCount < 1 then
    log_error("MapLegend itemCount lower than 1")
    return
  end
  for i = 1, ItemCount do
    if self.ItemConfig[i] and self.ItemConfig[i].TextID and not self.ItemConfig[i].Text then
      local Text = LocUtil.GetLocalizeResStr(self.ItemConfig[i].TextID)
      self.ItemConfig[i].    end
  end
  self.LegendHeight = 50 * ItemCount
end
function MapLegendBase:RegistEvents()
  MapLegendBase.__super.RegistEvents(self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_UpDown, self.OnClickUpDown, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_ResourceFilter, self.OnClickResourceFilter, self)
  self:AddControlEventByControl(self.UIRoot.Button_ShowHideLegend, "OnClicked", self.OnClickShowHideLegend, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_MAP, EVENTID_REFRESHMAPLEGEND_WITHLAYER, self.HandleReceiveLayerID, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_MAP, EVENTID_SHOW_AIRPLANE_ROUTE, self.OnAirlineRouteShow, self)
  self.UIRoot.Button_ResourceFilter:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function MapLegendBase:OnCurrentShowTagChange(_, CurrentShowTag)
  local Index = self.ResourceTag2Index[CurrentShowTag]
  if Index then
    self.LoopScrollResource:Select(Index)
  else
    self.LoopScrollResource:Deselect()
  end
end
function MapLegendBase:OnClickResourceFilter()
  self:SwitchResourceFilterState()
end
function MapLegendBase:SwitchResourceFilterState()
  if self.bResourceFilterOpen then
    self:CloseResourceFilter()
  else
    self:OpenResourceFilter()
  end
end
function MapLegendBase:OnResourceCheckBoxChanged(Index, bChecked)
  local MapResourceMarkIconSubsystem = SubsystemMgr:Get("MapResourceMarkIconSubsystem")
  if MapResourceMarkIconSubsystem then
    MapResourceMarkIconSubsystem:OnResourceCheckBoxChanged(Index, bChecked)
  end
end
function MapLegendBase:OpenResourceFilter()
  self.bResourceFilterOpen = true
  self.LoopScrollResource:Deselect()
  self.UIRoot.Switcher_Resource:SetActiveWidgetIndex(1)
  self.UIRoot.CanvasPanel_Resource:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self:HideLegend()
end
function MapLegendBase:CloseResourceFilter()
  self.bResourceFilterOpen = false
  self.LoopScrollResource:Deselect()
  self.UIRoot.Switcher_Resource:SetActiveWidgetIndex(0)
  self.UIRoot.CanvasPanel_Resource:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function MapLegendBase:DeselectResource()
  self.LoopScrollResource:Deselect()
end
function MapLegendBase:InitUI()
  self.UIRoot.WidgetSwitcher_ShowHide:SetActiveWidgetIndex(0)
  self:ShowLegend()
  self.UIRoot.UTRichTextBlock_Desc:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self:CloseResourceFilter()
end
function MapLegendBase:OnPostInitialize()
  MapLegendBase.__super.OnPostInitialize(self)
  if not self.NewMapMarkConfig then
    self.NewMapMarkConfig = GamePlayTools.GetCurrentConfig("NewMapMarkConfig")
  end
  if self.UIRoot.TextBlock_MapLegend then
    self.UIRoot.TextBlock_MapLegend:SetText(LocUtil.GetLocalizeResStr(612401119))
  end
  self:HandleReceiveLayerID()
  self:InitUI()
end
function MapLegendBase:InitData()
end
function MapLegendBase:Close()
  MapLegendBase.__super.Close(self)
  self.ItemConfig = nil
  print(bWriteLog and "MapLegendBase closed success")
end
function MapLegendBase:OnClickUpDown()
  if self.UIRoot.CanvasPanel_Legend:IsVisible() then
    self:HideLegend()
    local PlayerState = GameplayData.GetPlayerState()
    if slua.isValid(PlayerState) and PlayerState.RPC_ServerAddGeneralCount then
      PlayerState:RPC_ServerAddGeneralCount(11531, 1, true)
    end
  else
    self:ShowLegend()
  end
  self:PlayAudio(sound_config.click_v1)
end
function MapLegendBase:HideLegend()
  self.UIRoot.Image_Arrow:SetRenderScale(FVector2D(1, -1))
  self.UIRoot.CanvasPanel_Legend:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function MapLegendBase:ShowLegend()
  self.UIRoot.Image_Arrow:SetRenderScale(FVector2D(1, 1))
  self.UIRoot.CanvasPanel_Legend:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self:CloseResourceFilter()
end
function MapLegendBase:OnClickShowHideLegend()
  self:PlayAudio(sound_config.click_v1)
  self:HandleShowHideLegend()
  if not self.bChecked then
    local PlayerState = GameplayData.GetPlayerState()
    if slua.isValid(PlayerState) and PlayerState.RPC_ServerAddGeneralCount then
      PlayerState:RPC_ServerAddGeneralCount(11530, 1, true)
    end
  end
end
function MapLegendBase:HandleShowHideLegend()
  self.bChecked = not self.bChecked
  local bChecked = self.bChecked
  local world = slua_GameFrontendHUD:GetWorld()
  if not self.CurAreaID then
    local MapIconSubsystem = SubsystemMgr:Get("MapIconSubsystem")
    if not MapIconSubsystem then
      print(bWriteLog and "MapLegendBase:HandleReceiveLayerID MapIconSubsystem nil")
      self.CurAreaID = ""
    else
      self.CurAreaID = MapIconSubsystem:GetAreaID()
    end
  end
  local MapMarkUIManager = STExtraBlueprintFunctionLibrary.GetMapUIMarkComponent(world)
  if self.NewMapMarkConfig.LegendTagMap and self.NewMapMarkConfig.LegendTagMap[self.CurAreaID] then
    local AreaMap = self.NewMapMarkConfig.LegendTagMap[self.CurAreaID]
    for key, value in pairs(AreaMap) do
      self.TagCheckState[value] = bChecked
      if MapMarkUIManager then
        MapMarkUIManager:OnShowOrHideLegendMarkWidget(value, bChecked)
      end
    end
  else
    self.TagCheckState[self.CurAreaID] = bChecked
    if MapMarkUIManager then
      MapMarkUIManager:OnShowOrHideLegendMarkWidget(self.CurAreaID, bChecked)
    end
  end
  self.TagCheckState.ALL = bChecked
  if MapMarkUIManager then
    MapMarkUIManager:OnShowOrHideLegendMarkWidget("ALL", bChecked)
  end
  self.AreaCheckFinalState[self.CurAreaID] = bChecked
  if bChecked then
    self.ShowItemsCount = 0
    self.UIRoot.WidgetSwitcher_ShowHide:SetActiveWidgetIndex(0)
    EventSystem:postEvent(EVENTTYPE_INGAME_MAP, EVENTID_ENTIREMAP_SHOWORHIDE_MAPLEGEND, true)
  else
    self.ShowItemsCount = -self.LoopScroll:GetItemCount()
    self.UIRoot.WidgetSwitcher_ShowHide:SetActiveWidgetIndex(1)
    EventSystem:postEvent(EVENTTYPE_INGAME_MAP, EVENTID_ENTIREMAP_SHOWORHIDE_MAPLEGEND, false)
  end
end
function MapLegendBase:SetCountDownTextTranslation(text)
  local TextBlock = self.UIRoot.UTRichTextBlock_Desc
  TextBlock:SetText(text)
  local Size = TextBlock:GetDesiredSize()
  if Size.X > 0 then
    TextBlock:SetRenderTranslation(FVector2D(-Size.X - 10, 10))
  end
  return Size
end
function MapLegendBase:HandleReceiveLayerID()
  local MapIconSubsystem = SubsystemMgr:Get("MapIconSubsystem")
  if not MapIconSubsystem then
    self.CurAreaID = ""
  else
    self.CurAreaID = MapIconSubsystem:GetAreaID()
  end
  local ItemConfig = {}
  local MapMarkLegendSubsystem = SubsystemMgr:Get("MapMarkLegendSubsystem")
  if MapMarkLegendSubsystem and self.NewMapMarkConfig and MapMarkLegendSubsystem.LegenMarks then
    for key, value in pairs(MapMarkLegendSubsystem.LegenMarks) do
      if value and not self.AutoLegendIconPath[key] then
        self:AddAutoLegendInfo(key, value.Path, value.Tag)
      end
    end
  end
  for index, value in ipairs(self.ItemConfig) do
    if self.AutoLegendIconPath[value.TextID] then
      local tag = self.AutoLegendIconPath[value.TextID].VisTag
      local defaultShow = self.AutoLegendIconPath[value.TextID].bIsShow or false
      if self:CheckCurAreaIsShow(tag) and defaultShow then
        table.insert(ItemConfig, #ItemConfig + 1, value)
      end
    else
      local LayerID = value.LayerID or -1
      if LayerID then
        local isLayerShowing = true
        if MapIconSubsystem then
          isLayerShowing = MapIconSubsystem:CheckLayerIsShowing(LayerID)
        end
        if isLayerShowing and self:CheckIsShowByAreaID(value.AreaID) then
          table.insert(ItemConfig, #ItemConfig + 1, value)
        end
      end
    end
  end
  self.LoopScroll:SetData(ItemConfig)
  self.LoopScroll:RefreshAllItems()
  self:RefreshScrollSize()
  self.bChecked = false
  self:HandleShowHideLegend()
end
function MapLegendBase:OnAirlineRouteShow(_, __, bShow)
  print(bWriteLog and "MapLegendBase:OnAirlineRouteShow")
  if self.UIRoot and self.UIRoot.Image_4 and self.UIRoot.Image_4.Slot then
    if bShow then
      self.UIRoot.Image_4.Slot:SetSize(FVector2D(30, 36))
    else
      self.UIRoot.Image_4.Slot:SetSize(FVector2D(60, 36))
    end
  end
end
function MapLegendBase:CheckIsShowByAreaID(AreaID)
  return true
end
function MapLegendBase:GetAddItemConfigIndex()
  self.ItemConfigIndex = self.ItemConfigIndex + 1
  return self.ItemConfigIndex
end
function MapLegendBase:UpdateLegendUI(textID, bIsShow, iconPath, tags, typeID)
  if bIsShow then
    if not self.AutoLegendIconPath[textID] then
      self:AddAutoLegendInfo(textID, iconPath, tags, typeID)
    else
      self.AutoLegendIconPath[textID].bIsShow = true
    end
  elseif self.AutoLegendIconPath[textID] then
    self.AutoLegendIconPath[textID].bIsShow = false
  end
  self:RefreshAutoLegendIsShow(textID)
end
function MapLegendBase:AddAutoLegendInfo(textID, iconPath, tags, typeID)
  if tags == nil then
    tags = ""
  end
  local LegendText = LocUtil.GetLocalizeResStr(textID)
  self.ItemConfig[self:GetAddItemConfigIndex()] = {
    TextID = textID,
    IconPath = iconPath,
    Text = LegendText,
    Tags = tags or "",
    TypeID = typeID
  }
  self.AutoLegendIconPath[textID] = {
    Index = self.ItemConfigIndex,
    IconPath = iconPath,
    bIsShow = true,
    VisTag = tags or "",
    TypeID = typeID
  }
  if self.TagCheckState and self.TagCheckState[tags] == nil then
    local isShow = self:CheckCurAreaIsShow(tags)
    local world = slua_GameFrontendHUD:GetWorld()
    local MapMarkUIManager = STExtraBlueprintFunctionLibrary.GetMapUIMarkComponent(world)
    if MapMarkUIManager then
      MapMarkUIManager:OnShowOrHideLegendMarkWidget(tags, isShow)
      self.TagCheckState[tags] = false
    end
  end
end
function MapLegendBase:RefreshAutoLegendIsShow(textID)
  if textID ~= -1 and self.AutoLegendIconPath[textID] then
    local IconTag = self.AutoLegendIconPath[textID].VisTag or ""
    local defaultShow = self.AutoLegendIconPath[textID].bIsShow or false
    local isShow = self:CheckCurAreaIsShow(IconTag) and defaultShow
    local scrollData = self.LoopScroll:GetSetData()
    local ItemIndex = -1
    for index, value in ipairs(scrollData) do
      if value.TextID == textID then
        ItemIndex = index
        break
      end
    end
    if isShow and ItemIndex == -1 then
      local itemConfigIndex = self.AutoLegendIconPath[textID].Index
      local itemConfig = self.ItemConfig[itemConfigIndex]
      if itemConfig then
        self.LoopScroll:AppendItem(itemConfig)
        self.LoopScroll:RefreshAllItems()
        self:RefreshScrollSize()
      end
    elseif -1 < ItemIndex then
      self.LoopScroll:RemoveItem(ItemIndex)
      self.LoopScroll:RefreshAllItems()
      self:RefreshScrollSize()
    end
  else
    self:HandleReceiveLayerID()
  end
end
function MapLegendBase:CheckCurAreaIsShow(Tags)
  local MapIconSubsystem = SubsystemMgr:Get("MapIconSubsystem")
  local AreaID
  if not MapIconSubsystem then
    AreaID = ""
  else
    AreaID = MapIconSubsystem:GetAreaID()
  end
  if not self.NewMapMarkConfig then
    return
  end
  if self.NewMapMarkConfig.LegendTagMap and self.NewMapMarkConfig.LegendTagMap[AreaID] then
    for key, value in pairs(self.NewMapMarkConfig.LegendTagMap[AreaID]) do
      if value == Tags then
        return true
      end
    end
    return false
  else
    return AreaID == Tags or Tags == "ALL"
  end
end
function MapLegendBase:RefreshScrollSize()
  local dataCount = self.LoopScroll:GetItemCount()
  if dataCount < 1 then
    self.UIRoot.CanvasPanel_Root:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    self.bIsHide = true
    return
  end
  self.LegendHeight = self.UIRoot.LoopScrollBox_Legend.ItemSize * dataCount + 1
  FuncUtil.Clamp(self.LegendHeight, 0, 570)
  self.UIRoot.LoopScrollBox_Legend.Slot:SetSize(FVector2D(self.LegendWidth, self.LegendHeight))
  self.UIRoot.Image_27.Slot:SetSize(FVector2D(self.LegendWidth, self.LegendHeight))
  if self.bIsHide then
    self.UIRoot.CanvasPanel_Root:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
    self.bIsHide = false
  end
end
function MapLegendBase:RefreshCheckBoxState()
  if not self.NewMapMarkConfig then
    return
  end
  if not self.CurAreaID then
    local MapIconSubsystem = SubsystemMgr:Get("MapIconSubsystem")
    if not MapIconSubsystem then
      self.CurAreaID = ""
    else
      self.CurAreaID = MapIconSubsystem:GetAreaID()
    end
  end
  local bIsVis = true
  local ActiveIndex = 0
  if self.AreaCheckFinalState[self.CurAreaID] ~= nil then
    bIsVis = self.AreaCheckFinalState[self.CurAreaID]
  else
    self.AreaCheckFinalState[self.CurAreaID] = true
  end
  if not bIsVis then
    ActiveIndex = 1
  end
  self.UIRoot.WidgetSwitcher_ShowHide:SetActiveWidgetIndex(ActiveIndex)
  if self.NewMapMarkConfig.LegendTagMap and self.NewMapMarkConfig.LegendTagMap[self.CurAreaID] then
    local AreaMap = self.NewMapMarkConfig.LegendTagMap[self.CurAreaID]
    local world = slua_GameFrontendHUD:GetWorld()
    local MapMarkUIManager = STExtraBlueprintFunctionLibrary.GetMapUIMarkComponent(world)
    if MapMarkUIManager then
      for key, value in pairs(AreaMap) do
        if not bIsVis then
          MapMarkUIManager:OnShowOrHideLegendMarkWidget(value, false)
          self.TagCheckState[value] = false
        else
          MapMarkUIManager:OnShowOrHideLegendMarkWidget(value, true)
          self.TagCheckState[value] = true
        end
      end
    end
  else
    if self.TagCheckState[self.CurAreaID] == nil then
      self.TagCheckState[self.CurAreaID] = true
    end
    local world = slua_GameFrontendHUD:GetWorld()
    local MapMarkUIManager = STExtraBlueprintFunctionLibrary.GetMapUIMarkComponent(world)
    if MapMarkUIManager then
      MapMarkUIManager:OnShowOrHideLegendMarkWidget(self.CurAreaID, bIsVis)
    end
  end
  if self.TagCheckState.ALL == nil then
    self.TagCheckState.ALL = true
  end
  local world = slua_GameFrontendHUD:GetWorld()
  local MapMarkUIManager = STExtraBlueprintFunctionLibrary.GetMapUIMarkComponent(world)
  if MapMarkUIManager then
    MapMarkUIManager:OnShowOrHideLegendMarkWidget("ALL", bIsVis)
  end
end
function MapLegendBase:OnAllItemsFadeOut()
  print(bWriteLog and "MapLegendBase:OnAllItemsFadeOut")
  for _, LegendItem in pairs(self.MapLegendItemMap) do
    if LegendItem.FadeLegend then
      LegendItem:FadeLegend(false)
    end
  end
  self.bChecked = false
  self:OnClickShowHideLegend()
end
function MapLegendBase:OnItemShowHide(bShow)
  if bShow then
    self.ShowItemsCount = self.ShowItemsCount + 1
  else
    self.ShowItemsCount = self.ShowItemsCount - 1
  end
  if self.ShowItemsCount == 0 then
    self.bChecked = false
    self:OnClickShowHideLegend()
  elseif self.ShowItemsCount == -self.LoopScroll:GetItemCount() then
    self.bChecked = true
    self:OnClickShowHideLegend()
  end
end
function MapLegendBase:OnMapLegendItemHighlight(TypeID)
  print(bWriteLog and string.format("MapLegendBase:OnMapLegendItemHighlight - TypeID %s", tostring(TypeID)))
  local MapLegendItem = self.MapLegendItemMap[TypeID]
  if not MapLegendItem then
    print(bWriteLog and string.format("MapLegendBase:BindMapLegendItemEvent - TypeID %s MapLegendItem is nil"), tostring(TypeID))
    return
  end
  for Type, LegendItem in pairs(self.MapLegendItemMap) do
    if Type ~= TypeID and LegendItem.FadeLegend and (not LegendItem.AreaIDTypeIDMap or LegendItem.AreaIDTypeIDMap[self.CurAreaID] ~= TypeID) then
      LegendItem:FadeLegend(true)
    end
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CMapLegendBase = class(ui_base, nil, MapLegendBase)
return CMapLegendBase