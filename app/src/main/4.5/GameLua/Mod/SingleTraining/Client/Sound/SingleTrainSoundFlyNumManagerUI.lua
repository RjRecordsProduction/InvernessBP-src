local SingleTrainSoundFlyNumManagerUI = {
  _FlyNumItemPool = nil,
  _IsRegistEventsFinish = false,
  _ScoreNum = -1,
  _TimeNum = -1,
  _X = -1,
  _Y = -1,
  _Z = -1
}
local UWidgetLayoutLibrary = import("WidgetLayoutLibrary")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
function SingleTrainSoundFlyNumManagerUI:ctor(selfType, ScoreNum, AddTime, X, Y, Z)
  self._  self._TimeNum = AddTime
  self._  self._  self._end
function SingleTrainSoundFlyNumManagerUI:OnConstruct(ScoreNum, AddTime, X, Y, Z)
  self._  self._TimeNum = AddTime
  self._  self._  self._  if self._IsRegistEventsFinish then
    self:ShowScore(ScoreNum, AddTime, X, Y, Z)
  end
end
function SingleTrainSoundFlyNumManagerUI:RegistEvents()
  SingleTrainSoundFlyNumManagerUI.__super.RegistEvents(self)
  local UUIDuplicatedItemPool = import("UIDuplicatedItemPool")
  self._FlyNumItemPool = UUIDuplicatedItemPool(self.UIRoot)
  self._FlyNumItemPool.bActiveItemListHold = true
  self._FlyNumItemPool:InitItemPool("/Game/Mod/SingleTraining/BluePrints/UI/Sound/SingleTraining_Sound_FlyNum_UIBP.SingleTraining_Sound_FlyNum_UIBP_C", 8, false)
  self._IsRegistEventsFinish = true
  self:ShowScore(self._ScoreNum, self._TimeNum, self._X, self._Y, self._Z)
end
function SingleTrainSoundFlyNumManagerUI:OnClose()
  if slua.isValid(self._FlyNumItemPool) then
    self._FlyNumItemPool:RecycleAllItems()
    self._FlyNumItemPool = nil
  end
  self:RemoveAllGameTimer()
end
function SingleTrainSoundFlyNumManagerUI:ShowScore(ScoreNum, AddTime, X, Y, Z)
  local Item = self._FlyNumItemPool:GetOneItem()
  self.UIRoot.CanvasPanel_28:AddChild(Item)
  local uPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(uPlayerController) then
    local Pos = UWidgetLayoutLibrary.ProjectWorldLocationToWidgetPositionReturnValue(uPlayerController, FVector(X, Y, Z))
    Pos = FVector2D(Pos.X, Pos.Y)
    Item:SetRenderTranslation(Pos)
  end
  Item.TextBlock_0:SetText("+" .. tostring(ScoreNum))
  Item:PlayUserWidgetAnimation(Item.Title, 0, 1, 0, 1)
  self:AddGameTimer(Item.Title:GetEndTime(), false, function()
    self._FlyNumItemPool:FreeOneItem(Item)
  end)
  local uPlayerState = GameplayData.GetPlayerState()
  if slua.isValid(uPlayerState) and slua.isValid(uPlayerController) and uPlayerState.CurLevel == 4 then
    local Pos = UWidgetLayoutLibrary.ProjectWorldLocationToWidgetPositionReturnValue(uPlayerController, FVector(X, Y, Z))
    Pos = FVector2D(Pos.X, Pos.Y)
    self:AddGameTimer(0.8, false, function()
      local AddTimeItem = self._FlyNumItemPool:GetOneItem()
      self.UIRoot.CanvasPanel_28:AddChild(AddTimeItem)
      AddTimeItem:SetRenderTranslation(Pos)
      AddTimeItem.TextBlock_0:SetText("+" .. tostring(AddTime) .. "s")
      AddTimeItem:PlayUserWidgetAnimation(AddTimeItem.Title, 0, 1, 0, 1)
      self:AddGameTimer(AddTimeItem.Title:GetEndTime(), false, function()
        self._FlyNumItemPool:FreeOneItem(AddTimeItem)
      end)
    end)
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
return class(ui_base, nil, SingleTrainSoundFlyNumManagerUI)