local BallisticTargetDamageMainUI = {}
local SingleTrainingConfig = require("GameLua.Mod.SingleTraining.Gameplay.Config.SingleTrainingConfig")
local UWidgetLayoutLibrary = import("WidgetLayoutLibrary")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
function BallisticTargetDamageMainUI:ctor(selfType, Damage, X, Y, Z)
  self.FlyNumItemPool = nil
  self.  self.  self.  self.end
function BallisticTargetDamageMainUI:OnConstruct(Damage, X, Y, Z, uFSlateColor, nFontSize)
  self.  self.  self.  self.  self:ShowDamage(Damage, X, Y, Z, uFSlateColor, nFontSize)
end
function BallisticTargetDamageMainUI:OnInitialize()
  print(bWriteLog and "BallisticTargetDamageMainUI:OnInitialize")
  BallisticTargetDamageMainUI.__super.OnInitialize(self)
  local UUIDuplicatedItemPool = import("UIDuplicatedItemPool")
  self.FlyNumItemPool = UUIDuplicatedItemPool(self.UIRoot)
  self.FlyNumItemPool.bActiveItemListHold = true
  self.FlyNumItemPool:InitItemPool("/Game/Mod/SingleTraining/BluePrints/UI/SingleTrain_BulletDamage_UIBP.SingleTrain_BulletDamage_UIBP_C", 8, false)
  self:ShowDamage(self.Damage, self.X, self.Y, self.Z)
end
function BallisticTargetDamageMainUI:RegistEvents()
  print(bWriteLog and "BallisticTargetDamageMainUI:RegistEvents")
  BallisticTargetDamageMainUI.__super.RegistEvents(self)
end
function BallisticTargetDamageMainUI:OnClose()
  if slua.isValid(self.FlyNumItemPool) then
    self.FlyNumItemPool:RecycleAllItems()
    self.FlyNumItemPool = nil
  end
end
function BallisticTargetDamageMainUI:ShowDamage(Damage, X, Y, Z, uFSlateColor, nFontSize)
  local Item = self.FlyNumItemPool:GetOneItem()
  self.UIRoot.CanvasPanel_28:AddChild(Item)
  local uPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(uPlayerController) then
    local Pos = UWidgetLayoutLibrary.ProjectWorldLocationToWidgetPositionReturnValue(uPlayerController, FVector(X, Y, Z))
    local UIUtil = require("client.common.ui_util")
    local ViewportSize = UIUtil.GetViewportSize() / UIUtil.GetViewportScale()
    Pos = FVector2D(ViewportSize.X / 2, Pos.Y)
    Item:SetRenderTranslation(Pos)
  end
  Item.DamageText:SetText(tostring(Damage))
  if slua.isValid(uFSlateColor) then
    Item.DamageText:SetColorAndOpacity(uFSlateColor)
  else
    Item.DamageText:SetColorAndOpacity(FSlateColor(FLinearColor(1, 1, 1, 1)))
  end
  local Font = Item.DamageText.Font
  if nFontSize and type(nFontSize) == "number" then
    Font.Size = nFontSize
    Item.DamageText:SetFont(Font)
  else
    Font.Size = 18
    Item.DamageText:SetFont(Font)
  end
  Item:PlayUserWidgetAnimation(Item.Fadein, 0, 1, 0, 1)
  self:AddGameTimer(Item.Fadein:GetEndTime(), false, function()
    self.FlyNumItemPool:FreeOneItem(Item)
  end)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CBallisticTargetDamageMainUI = class(ui_base, nil, BallisticTargetDamageMainUI)
return CBallisticTargetDamageMainUI