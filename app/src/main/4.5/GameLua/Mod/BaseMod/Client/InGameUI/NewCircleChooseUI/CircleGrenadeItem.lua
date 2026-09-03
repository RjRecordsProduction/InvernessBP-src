local CircleGrenadeItem = {}
local UIUtil = require("client.slua_ui_framework.util")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local CircleChooseUtil = require("GameLua.Mod.BaseMod.Client.InGameUI.NewCircleChooseUI.CircleChooseUtil")
function CircleGrenadeItem:ctor(selfType, tTable, tData)
  self.ItemID = tData.ItemID
  self.EmptyImagePath = tData.EmptyImage
  self.CacheNum = 0
  self.MedincineAsGrenade = false
  self.Image = tTable.Image
  self.ItemNumText = tTable.ItemNumText
  self.HighlightWidget = tTable.HighlightWidget
  self.OwningImage = tTable.OwningImage
  self.BGImage = tTable.BGImage
  self.SpecialWidget = tTable.SpecialWidget
  self.Colors = {
    Grey = FLinearColor(1, 1, 1, 0.3),
    White = FLinearColor(1, 1, 1, 1),
    Black = FLinearColor(0, 0, 0, 1)
  }
end
function CircleGrenadeItem:OnInit()
  if self.ItemID < 0 then
    self.MedincineAsGrenade = true
  end
  self:InitSpecialBG()
  self:EmptyUI()
end
function CircleGrenadeItem:EmptyUI()
  self.CacheNum = 0
  self.OwningImage:SetColorAndOpacity(self.Colors.Grey)
  if self.MedincineAsGrenade then
    self.ItemNumText:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.Image:SetBrushFromPathAsync(self.EmptyImagePath, false)
  else
    local MySubsystem = CircleChooseUtil.GetLogicMgrSubsystem()
    local ImagePath = MySubsystem and MySubsystem:GetPathFromCachedMap(self.ItemID, self.MedincineAsGrenade) or ""
    self.ItemNumText:SetText("0")
    self.Image:SetBrushFromPathAsync(ImagePath, false)
    self.Image:SetColorAndOpacity(self.Colors.Black)
  end
end
function CircleGrenadeItem:InitSpecialBG()
  if not self.BGImage then
    return
  end
  if self.MedincineAsGrenade then
    local CircleChooseCfg = GamePlayTools.GetCurrentConfig("CircleChooseCfg")
    local BGPath = CircleChooseCfg.BGPath.MedRing
    if BGPath then
      self.BGImage:SetBrushFromPathAsync(BGPath, false)
    end
  end
end
function CircleGrenadeItem:UpdateMedsThrowBan()
  if not self.SpecialWidget or not self.MedincineAsGrenade then
    return
  end
  local MySubsystem = CircleChooseUtil.GetLogicMgrSubsystem()
  local bShow = not MySubsystem.bEnableThrowMeds
  if bShow then
    self.SpecialWidget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self.SpecialWidget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function CircleGrenadeItem:UpdateOwningImage()
  local Num = 0
  if 0 < self.ItemID then
    local MySubsystem = CircleChooseUtil.GetLogicMgrSubsystem()
    if not MySubsystem then
      print(bWriteLog and "CircleGrenadeItem:UpdateOwningImage, MySubsystem is nil")
      return
    end
    local BattleItem = MySubsystem.RingListData[self.ItemID]
    if self.MedincineAsGrenade then
      BattleItem = MySubsystem.CurrentSelectedConsumableBattleItem
    end
    if BattleItem then
      Num = BattleItem.Count
    end
  end
  if self.CacheNum == nil then
    self.CacheNum = 0
  end
  if self.CacheNum ~= Num then
    if 0 < self.CacheNum and Num == 0 then
      self.OwningImage:SetColorAndOpacity(self.Colors.Grey)
    elseif self.CacheNum == 0 and 0 < Num then
      self.OwningImage:SetColorAndOpacity(self.Colors.White)
    end
    self.Cache  end
end
function CircleGrenadeItem:UpdateImage()
  if self.CacheNum > 0 then
    if self.MedincineAsGrenade then
      local MySubsystem = CircleChooseUtil.GetLogicMgrSubsystem()
      self.Image:SetBrushFromPathAsync(MySubsystem:GetPathFromCachedMap(self.ItemID, self.MedincineAsGrenade), false)
    end
    self.Image:SetColorAndOpacity(self.Colors.White)
  else
    if self.MedincineAsGrenade then
      self.Image:SetBrushFromPathAsync(self.EmptyImagePath, false)
    end
    self.Image:SetColorAndOpacity(self.Colors.Black)
  end
  self.ItemNumText:SetText(tostring(self.CacheNum))
  self:UpdateMedsThrowBan()
end
function CircleGrenadeItem:HandleSlotChosen()
  if self.ItemID <= 0 then
    return
  end
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  local EPawnState = import("EPawnState")
  if slua.isValid(PlayerCharacter) and (PlayerCharacter:HasState(EPawnState.HoldGrenade) or PlayerCharacter:HasState(EPawnState.PlayEmote)) then
    print(bWriteLog and "CircleGrenadeItem:HandleSlotChosen, is not allow pawnstate")
    return
  end
  local MySubsystem = CircleChooseUtil.GetLogicMgrSubsystem()
  local BattleItem = MySubsystem.RingListData[self.ItemID]
  if self.MedincineAsGrenade then
    BattleItem = MySubsystem.CurrentSelectedConsumableBattleItem
  end
  if not BattleItem then
    print(bWriteLog and "CircleGrenadeItem:HandleSlotChosen, NO Battle ItemID ", self.ItemID)
    return
  end
  print(bWriteLog and "CircleGrenadeItem:HandleSlotChosen, ItemID ", self.ItemID)
  local bMed = CircleChooseUtil.IsAMedicine(self.ItemID) or CircleChooseUtil.IsAIceDrink(self.ItemID)
  if bMed and not self.MedincineAsGrenade then
    MySubsystem:SetFirstMed(BattleItem)
    CircleChooseUtil.UseConsumableItem(BattleItem)
  else
    CircleChooseUtil.HandleItemChosen(BattleItem)
  end
  return true
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
return class(ui_base, nil, CircleGrenadeItem)