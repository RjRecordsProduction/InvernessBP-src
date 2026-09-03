local WatchGameInGamePlayerInfoItem = {}
local EAvatarSlotType = import("EAvatarSlotType")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local FEventReply = import("EventReply")
local UIUtil = require("client.common.ui_util")
function WatchGameInGamePlayerInfoItem:OnInitialize()
  WatchGameInGamePlayerInfoItem.__super.OnInitialize(self)
end
function WatchGameInGamePlayerInfoItem:RegistEvents()
  WatchGameInGamePlayerInfoItem.__super.RegistEvents(self)
  local but = self.UIRoot.Button_2
  if slua.isValid(but) and but.OnMouseButtonDownEvent then
    self:AddControlEventByControl(self.UIRoot.Button_2, "OnMouseButtonDownEvent", self.On_Button_2_MouseButtonDown_0, self)
  end
end
function WatchGameInGamePlayerInfoItem:SetItemInfo(ItemSpecificID, ItemSlotType)
  self.SlotType = ItemSlotType
  local ItemRecord = CDataTable.GetTableData("Item", ItemSpecificID)
  if ItemRecord and ItemRecord.ItemID ~= 0 then
    local uPlayerController = GameplayData.GetPlayerController()
    if Game:IsValid(uPlayerController) then
      local CurPlayerCharacter = uPlayerController:GetCurPlayerCharacter()
      if Game:IsValid(CurPlayerCharacter) then
        local IsHiddenByOtherSlot = STExtraBlueprintFunctionLibrary.IsHiddenByOtherSlot(CurPlayerCharacter, ItemSpecificID)
        if not IsHiddenByOtherSlot then
          self.ItemInfo = ItemRecord
          self:ShowInfoItem()
          self:RefreshItemInfo()
          return true
        else
          self:HideInfoItem()
          return false
        end
      else
        self:HideInfoItem()
        return false
      end
    end
  else
    print(bWriteLog and "IngamePlayerInfoItem_UIBP Invalid Item:" .. tostring(ItemSpecificID))
    self:HideInfoItem()
    return false
  end
end
function WatchGameInGamePlayerInfoItem:ShowInfoItem()
  self.UIRoot:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
end
function WatchGameInGamePlayerInfoItem:HideInfoItem()
  self.UIRoot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.SlotType = EAvatarSlotType.EAvatarSlotType_NONE
end
function WatchGameInGamePlayerInfoItem:ToggleItemSelected(InSelectedItem)
  if self.ItemInfo and InSelectedItem == self.ItemInfo.ItemID then
    self.UIRoot.Image_Select:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self.UIRoot.Image_Select:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function WatchGameInGamePlayerInfoItem:SetEquipQuality(InQuality)
  local UIRoot = self.UIRoot
  UIRoot.Image_colour:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  local GlobalBattleUIFunctionLibrary = import("/Game/UMG/UI_Utility/GlobalBattleUIFunctionLibrary.GlobalBattleUIFunctionLibrary_C")
  local Path = GlobalBattleUIFunctionLibrary.GetButtomQualityPath(InQuality, self.UIRoot)
  UIRoot.Image_colour:SetBrushFromPathAsync(Path, false)
end
function WatchGameInGamePlayerInfoItem:On_Button_2_MouseButtonDown_0(MyGeometry, MouseEvent)
  if not self.ItemInfo then
    return
  end
  self.UIRoot.OnPlayerInfoItemClicked:BroadCast(true, self.ItemInfo.ItemID, self.ItemInfo.ItemName, self.ItemInfo.ItemDesc, self.UIRoot.Image_icon.Brush, self.ItemInfo.ItemQuality, self.SlotType)
  local EventReply = FEventReply()
  return EventReply
end
function WatchGameInGamePlayerInfoItem:RefreshItemInfo()
  local ItemPathExist = false
  local IconPath = self.ItemInfo.ItemSmallIcon
  if Client.IsJaguar() then
    local PufferConst = require("client.slua.logic.download.puffer_const")
    local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
    local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {
      self.ItemInfo.ItemID
    })
    if state == PufferConst.ENUM_DownloadState.Done then
      ItemPathExist = true
    end
  else
    ItemPathExist = true
  end
  local UIRoot = self.UIRoot
  if ItemPathExist then
    UIRoot.Image_icon:SetBrushFromPathAsync(IconPath, false)
    UIRoot.Image_UnDownload:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    print(bWriteLog and "WatchGameInGamePlayerInfoItem:RefreshItemInfo ItemSmallIcon:" .. tostring(IconPath))
  else
    local DefaultIconPath = UIUtil.GetDefaultIcon(self.ItemInfo.ItemID)
    if DefaultIconPath then
      UIRoot.Image_icon:SetBrushFromPathAsync(DefaultIconPath, false)
    end
    UIRoot.Image_UnDownload:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
    print(bWriteLog and "WatchGameInGamePlayerInfoItem:RefreshItemInfo BattleItemHandlePathNotExist:" .. tostring(IconPath))
  end
  self:SetEquipQuality(self.ItemInfo.ItemQuality)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
return class(ui_base, nil, WatchGameInGamePlayerInfoItem)