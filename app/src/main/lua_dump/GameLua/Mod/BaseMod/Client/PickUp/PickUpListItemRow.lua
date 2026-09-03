local PickUpListItemRow = {}
local KismetInputLibrary = import("KismetInputLibrary")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
function PickUpListItemRow:ctor()
  self.AllTombItemBaseList = {}
end
function PickUpListItemRow:OnInitUI()
  print(bWriteLog and "PickUpListItemRow:OnInitUI")
  local PickUpConfig = GamePlayTools.GetCurrentConfig("PickUpConfig")
  if PickUpConfig and PickUpConfig.PickUpBoxItemPath and PickUpConfig.PickUpBoxItemPath ~= "" then
    self.ItemPath = PickUpConfig.PickUpBoxItemPath
  else
    self.ItemPath = "/Game/BluePrints/ControlInput/MainBackPackUI/Item/PickUpItem_BP.PickUpItem_BP_C"
  end
  for i = 0, 2 do
    local newItem = UIManager.ShowUI(UIManager.UI_Config_InGame.TombBoxListItem)
    self:OnCreatedItemBP(newItem)
    self.LoadingItemNum = (self.LoadingItemNum or 0) + 1
  end
end
function PickUpListItemRow:UpdateTombBoxData(Box, BoxList)
  self.bNeedUpdate = false
  self.TextBox:SetWidgetVisibility(UEnums.GSlateVisibility.Hidden)
  local BoxTombName = Box.TombName
  self.TombName = BoxTombName
  local bIsBoxFixedName = self:IsFixedName(Box)
  if bIsBoxFixedName then
    local FixedName = self:GetFixedBoxName(Box)
    self.playerName:SetText(FixedName)
  else
    local bIsNeedTransLate = self:IsBoxNameNeedTranslate(Box)
    local FinalName = BoxTombName
    if bIsNeedTransLate then
      local UIUtil = require("client.common.ui_util")
      if tonumber(BoxTombName) then
        local TmpStr = LocUtil.GetLocalizeResStr(tonumber(BoxTombName))
        if TmpStr ~= "" then
          FinalName = TmpStr
        else
          FinalName = UIUtil.GetLocalizationString(BoxTombName)
        end
      else
        FinalName = UIUtil.GetLocalizationString(BoxTombName)
      end
    end
    self.playerName:SetText(LocUtil.LocalizeResFormat(4070, FinalName))
  end
  local uPlayerController = GameplayData.GetPlayerController()
  local TombBoxPlayerState
  if slua.isValid(uPlayerController) then
    local bForbidPick = false
    local TombBoxOwnerPlayerKey = Box.TargetPlayerKey
    local uPlayerState = uPlayerController.GetCurPlayerState and uPlayerController:GetCurPlayerState() or uPlayerController.PlayerState
    if slua.isValid(uPlayerState) and uPlayerState.IsForbidPick and TombBoxOwnerPlayerKey then
      bForbidPick = uPlayerState:IsForbidPick(TombBoxOwnerPlayerKey)
    end
    if bForbidPick then
      self.HorizontalBox_stop:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
      self:MakesureListEnough(0)
      return
    else
      self.HorizontalBox_stop:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    end
    TombBoxPlayerState = uPlayerController:GetTeammatePlayerStatefromPlayerTombBox(Box)
  end
  local BoxNum = 0
  if BoxList.Num then
    BoxNum = BoxList:Num()
  else
    BoxNum = #BoxList
  end
  self:MakesureListEnough(BoxNum)
  if 0 < BoxNum then
    self.HorizontalBox_EmptyBoxTips:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
  else
    self.HorizontalBox_EmptyBoxTips:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
  end
  if self.bCacheData then
    local CachedBoxNum = 0
    if self.CacheBoxList.Num then
      CachedBoxNum = self.CacheBoxList:Num()
    else
      CachedBoxNum = #self.CacheBoxList
    end
    for i = 1, CachedBoxNum do
      self:UpdateOneItem(true)
    end
  end
  self.bCacheData = true
  self.CacheBoxList:Clear()
  self.Cache  self.CacheLength = BoxNum
  self.CacheIndex = 0
  self.CachePlayerState = TombBoxPlayerState
  self.bCacheHadeRevivalCard = false
  EventSystem:postEvent(EVENTTYPE_DEADBOX_CLIENT, EVENTTYPE_DEADBOX_UpdateDataUI, Box)
end
function PickUpListItemRow:UpdateGroundItemData(sortInfoList)
  self.playerName:SetText(LocUtil.GetLocalizeResStr(67754))
  self.TextBox:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
  self.HorizontalBox_stop:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
  local BoxNum = sortInfoList:Num()
  self:MakesureListEnough(BoxNum)
  self.HorizontalBox_EmptyBoxTips:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
  for i = 0, BoxNum - 1 do
    local UIItem = self.AllTombItemBaseList[i]
    local ItemData = sortInfoList:Get(i)
    if UIItem and ItemData then
      UIItem:UpdateItemDataNew(ItemData, self.ParentUserWidget)
      UIItem:SelfHitTestInvisible()
    end
  end
end
function PickUpListItemRow:MakesureListEnough(count)
  print(bWriteLog and "PickUpListItemRow:MakesureListEnough" .. count)
  self.WrapBoxTargetCount = count
  local bNeedCreateNewItem = false
  local nDiffCount = 0
  local nWrapBoxListCount = self.WrapBox_List:GetChildrenCount()
  nDiffCount = self.WrapBoxTargetCount - nWrapBoxListCount - (self.LoadingItemNum or 0)
  if 0 < nDiffCount then
    bNeedCreateNewItem = true
  elseif nDiffCount < 0 then
    for i = nWrapBoxListCount + nDiffCount, nWrapBoxListCount do
      local UIItem = self.AllTombItemBaseList[i]
      if UIItem then
        UIItem:Collapsed()
      end
    end
  end
  if bNeedCreateNewItem then
    for i = 0, nDiffCount do
      local newItem = UIManager.ShowUI(UIManager.UI_Config_InGame.TombBoxListItem)
      self:OnCreatedItemBP(newItem)
      self.LoadingItemNum = (self.LoadingItemNum or 0) + 1
    end
  end
end
function PickUpListItemRow:OnCreatedItemBP(UIItem, InstanceID)
  local Object = UIItem.UIRoot
  if not slua.isValid(Object) then
    return
  end
  Object.ParentUserWidget = self.ParentUserWidget
  self.WrapBox_List:AddChild(Object)
  local CurCount = self.WrapBox_List:GetChildrenCount()
  print(bWriteLog and "PickUpListItemRow:OnCreatedItemBP", CurCount)
  self.AllTombItemBaseList[CurCount - 1] = UIItem
  self.LoadingItemNum = self.LoadingItemNum - 1
  Object:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
end
function PickUpListItemRow:UpdateOneItem(bIgnoreVisible)
  if not self.bCacheData then
    return
  end
  local CachedBoxNum = self.CacheBoxList:Num()
  if CachedBoxNum <= 0 then
    return
  end
  local Item = self.WrapBox_List:GetChildAt(self.CacheIndex)
  if slua.isValid(Item) then
    Item.ParentUserWidget = self.ParentUserWidget
    self.CacheTempListData = self.CacheBoxList:Get(self.CacheIndex)
    local UIItem = self.AllTombItemBaseList[self.CacheIndex]
    Item:UpdateItemDatabyWrap(self.CacheTempListData)
    if UIItem then
      local PickUpItemResult = self.CacheTempListData.pickUpItemResult
      local TypeSpecificID = PickUpItemResult.MainItemData.ID.TypeSpecificID
      UIItem:UpdateItemDataMod(CDataTable.GetTableData("Item", TypeSpecificID))
    end
    if not bIgnoreVisible then
      Item:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
    end
    self.CacheIndex = self.CacheIndex + 1
    local bIsReviveCard = self:IsRevivalCard(self.CacheTempListData)
    if bIsReviveCard then
      local BackpackUtils = import("BackpackUtils")
      local IsValidRevivalCard = BackpackUtils.IsValidRevivalCard(self.CachePlayerState)
      if not IsValidRevivalCard then
        self.bCacheHadeRevivalCard = true
        Item:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
      end
    else
      local bIsLimitShow = self:IsLimitShow(self.CacheTempListData)
      if bIsLimitShow then
        Item:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
      end
    end
  end
  if CachedBoxNum > self.CacheIndex then
    return
  end
  self.bCacheData = false
  if self.CacheLength == 0 or self.CacheLength == 1 and self.bCacheHadeRevivalCard then
    self.HorizontalBox_EmptyBoxTips:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
  else
    self.HorizontalBox_EmptyBoxTips:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
  end
  print(bWriteLog and "PickUpListItemRow:UpdateOneItem Finished")
end
function PickUpListItemRow:OnDestroy()
  log(bWriteLog and "PickUpListItemRow:OnDestroy")
  for i, UIItem in pairs(self.AllTombItemBaseList) do
    if UIItem then
      UIItem:CloseSelf()
    end
  end
  self:Dispose()
end
local class = require("class")
local CDelegateContainer = require("common.delegate_container")
return class(CDelegateContainer, nil, PickUpListItemRow)