local BackpackUtils = import("BackpackUtils")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local PickupScreenMarkUI = {
  IconOutScreenPath = "/Game/Arts/UI/Atlas/BattleUI/General_RGBA/Frames/ZD_image_KJZL_wuzhi_02_png.ZD_image_KJZL_wuzhi_02_png",
  IconInScreenPath = "/Game/Arts/UI/Atlas/BattleUI/Ingame_QuickSign/Frames/DJ_Bg_dibiaokuang_01_png.DJ_Bg_dibiaokuang_01_png",
  IconOutScreenSize = FVector2D(38, 49),
  IconInScreenSize = FVector2D(38, 38)
}
function PickupScreenMarkUI:OnDestroy()
  self:Dispose()
end
function PickupScreenMarkUI:OnLocationBindUI(Loc)
  self.bNotified = false
end
function PickupScreenMarkUI:PickupSearchNotify()
  if not self.bShowWidget then
    return
  end
  if self.bNotified == true then
    return
  end
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return
  end
  local uPlayerState = uPlayerController:GetCurPlayerState()
  if not slua.isValid(uPlayerState) or not uPlayerState.SkillPropFeature then
    return
  end
  uPlayerState.SkillPropFeature:TryDoPickupSearchNotify()
  self.bNotified = true
end
function PickupScreenMarkUI:SwitchIfOutOfScreen(bIsOutScreen)
  if bIsOutScreen then
    self.Image_Arrow:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Image_Arrow:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function PickupScreenMarkUI:OnUpdateState(CustomInt, CustomFloat, CustomString)
  local ItemID = math.floor(CustomInt)
  local ItemRecord = CDataTable.GetTableData("Item", ItemID)
  local UIUtil = require("client.common.ui_util")
  local ItemIconPath = UIUtil.GetItemSmallIcon(ItemID)
  if ItemRecord == nil or ItemIconPath == nil then
    self.bShowWidget = false
    print(bWriteLog and "PickupScreenMarkUI:OnUpdateState Invalid Record", ItemID)
    return
  end
  print(bWriteLog and "PickupScreenMarkUI:OnUpdateState", ItemID, ItemRecord.ItemType)
  if ItemRecord.ItemType ~= ENUM_ITEM_TYPE.Backpack and ItemRecord.ItemType ~= ENUM_ITEM_TYPE.Weapon and ItemRecord.ItemType ~= ENUM_ITEM_TYPE.Medicine then
    self.bShowWidget = true
    self.Icon:SetBrushfromPathAsync(ItemIconPath, false)
    self:PickupSearchNotify()
    return
  end
  print(bWriteLog and "PickupScreenMarkUI:OnUpdateState HasNoItem", ItemID, ItemRecord.ItemType)
  self.bShowWidget = true
  self.Icon:SetBrushfromPathAsync(ItemIconPath, false)
  self:PickupSearchNotify()
end
function PickupScreenMarkUI:OnCenterAlphaChanged(Alpha, CenterOffsetRatio)
  self:SetColorAndOpacity(FLinearColor(1, 1, 1, Alpha))
end
local class = require("class")
local object = require("common.delegate_container")
return class(object, nil, PickupScreenMarkUI)