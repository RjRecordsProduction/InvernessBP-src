local MiniMapPlayerIconItem = {}
local FVector = FVector2D
local ESlateVisibility = import("ESlateVisibility")
local KismetMathLibrary = import("KismetMathLibrary")
local OffsetVecs = {
  [45] = FVector(-3.5, -2.5),
  [135] = FVector(3.5, -2.5),
  [225] = FVector(3.5, 2.5),
  [315] = FVector(-3.5, 2.5),
  [0] = FVector(0.0, 0.0),
  [90] = FVector(0.0, 0.0),
  [180] = FVector(0.0, 0.0),
  [270] = FVector(0.0, 0.0)
}
function MiniMapPlayerIconItem:ctor()
  self.TeammateIndex = -1
end
function MiniMapPlayerIconItem:Initialize()
  if EVENTTYPE_TF and EVENTID_MEGATRON_TRANSFORMER_STATE_CHANGE then
    self:AddCommonEvent(EVENTTYPE_TF, EVENTID_MEGATRON_TRANSFORMER_STATE_CHANGE, self.OnTransformerStateChange, self)
  end
  if self["SwitchAlive/DeadIcon"] and type(self["SwitchAlive/DeadIcon"]) == "function" then
    self["SwitchAlive/DeadIcon"] = self.SwitchAliveDeadIcon
  end
  if self["SwitchIn/OutRange"] and type(self["SwitchIn/OutRange"]) == "function" then
    self["SwitchIn/OutRange"] = self.SwitchInOutRange
  end
end
function MiniMapPlayerIconItem:ShouldIgnoreOut(bIsInRange)
  if not self.IsLocalPlayer then
    return false
  end
  return not bIsInRange
end
function MiniMapPlayerIconItem:OnTransformerStateChange()
  local EWidgetVisible = import("EWidgetVisible")
  local Visible = EWidgetVisible.Default
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local CurPlayerState = GameplayData.GetPlayerState()
  if slua.isValid(CurPlayerState) and CurPlayerState.GetPlayerStateByInTeamIndex then
    local ThisPlayerState = CurPlayerState:GetPlayerStateByInTeamIndex(self.TeammateIndex - 1)
    if slua.isValid(ThisPlayerState) and ThisPlayerState.bEnterTransformer then
      Visible = EWidgetVisible.ForceNotVisible
    end
  end
  if self.CanvasPanel_Team then
    self.CanvasPanel_Team:SetWidgetRender(Visible)
  end
end
function MiniMapPlayerIconItem:SetTeammateInfo(TeammateIndex, TeammateColor)
  self.  return self.Super:SetTeammateInfo(TeammateIndex, TeammateColor)
end
function MiniMapPlayerIconItem:LoadTeamIndexIcon(NewParam)
  local DataInfo = CDataTable.GetTableData("IngameTeammateIndexIconPath", NewParam)
  if DataInfo ~= nil and self.CurIndexIconPath ~= DataInfo.IconPath then
    local IconPath = DataInfo.IconPath
    self.Image_SelfNumIcon:SetBrushFromPathAsync(IconPath, false)
    self.Image_NumIndex:SetBrushFromPathAsync(IconPath, false)
  end
end
function MiniMapPlayerIconItem:AddTeamIndicatorArrowOffset(Degree)
  local FVector = FVector2D
  local OffsetVec = OffsetVecs[Degree]
  OffsetVec = OffsetVec or FVector(0.0, 0.0)
  local Slot = self.OutRangeIndicator.Slot
  Slot:SetPosition(OffsetVec)
end
function MiniMapPlayerIconItem:ShouldIgnoreOut(bIsInRange)
  return false
end
function MiniMapPlayerIconItem:GetRotationDisplayWidget()
  return self.CanvasPanel_SelfArrow
end
function MiniMapPlayerIconItem:SwitchAliveDeadIcon(IsDead)
  if IsDead then
    self.Image_SelfArrow:SetWidgetVisibility(ESlateVisibility.Collapsed)
    self.Image_SelfBG:SetWidgetVisibility(ESlateVisibility.Collapsed)
    self.CanvasPanel_SelfBG:SetWidgetVisibility(ESlateVisibility.Collapsed)
    self.Image_SelfDead:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
  else
    self.Image_SelfArrow:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
    self.Image_SelfBG:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
    self.CanvasPanel_SelfBG:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
    self.Image_SelfDead:SetWidgetVisibility(ESlateVisibility.Collapsed)
  end
  return true
end
function MiniMapPlayerIconItem:SetSelfStyle(bIsSelf)
  self.IsLocalPlayer = bIsSelf
  if self.IsLocalPlayer then
    self.SelfPosiionIcon:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
  else
    self.SelfPosiionIcon:SetWidgetVisibility(ESlateVisibility.Collapsed)
  end
  return false
end
function MiniMapPlayerIconItem:SwitchInOutRange(IsInRange, Degree, EnableNewStyle)
  local bIgnore = self:ShouldIgnoreOut(IsInRange)
  if not bIgnore and IsInRange then
    self.CanvasPanel_SelfArrow:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
    if EnableNewStyle then
      self.OutRangeIndicator:SetWidgetVisibility(ESlateVisibility.Collapsed)
      if not self.UseExtraCanvasPanelTeam then
        self.CanvasPanel_Team:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
      end
    end
    self.Image_SelfBG:SetBrush(self.CirclePlayerIcon)
  else
    self.CanvasPanel_SelfArrow:SetWidgetVisibility(ESlateVisibility.Collapsed)
    if not EnableNewStyle or self.IsLocalPlayer then
      self.Image_SelfBG:SetBrush(self.SquarePlayerIcon)
    else
      self.OutRangeIndicator:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
      self.CanvasPanel_Team:SetWidgetVisibility(ESlateVisibility.Collapsed)
      self.OutRangeIndicator:SetRenderAngle(Degree)
      self.Image_NumIndex:SetRenderAngle((360.0 - Degree) % 360.0)
      local Angle = KismetMathLibrary.FTrunc(Degree)
      self:AddTeamIndicatorArrowOffset(Angle)
    end
  end
  return true
end
function MiniMapPlayerIconItem:SwitchVisibility(bIsShow)
  if bIsShow then
    self:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
  else
    self:SetWidgetVisibility(ESlateVisibility.Collapsed)
  end
  return true
end
function MiniMapPlayerIconItem:UpdateVeteranStatus(MentorType, VeteranLevel)
  local MergeExecutionPath = function()
    self.WidgetSwitcher_Veteran:SetActiveWidgetIndex(0)
    self.WidgetSwitcher_VetergenOut:SetActiveWidgetIndex(0)
    self.Image_SelfNumIcon:SetColorAndOpacity(FLinearColor(1.0, 1.0, 1.0, 1.0))
  end
  local EMentorPlayerType = import("EMentorPlayerType")
  local ClientIngameUIFunctionLibrary = require("GameLua.Mod.Library.Client.ClientIngameUIFunctionLibrary")
  if ClientIngameUIFunctionLibrary.NeedShowVeteran() then
    if MentorType == EMentorPlayerType.MPT_NormalPlayer then
      MergeExecutionPath()
    elseif MentorType == EMentorPlayerType.MPT_Veteran then
      self.WidgetSwitcher_Veteran:SetActiveWidgetIndex(1)
      self.WidgetSwitcher_VetergenOut:SetActiveWidgetIndex(1)
      local STExtraUIUtils = import("/Script/ShadowTrackerExtra.STExtraUIUtils")
      local Path = ClientIngameUIFunctionLibrary.GetPlayerVeteranIconPathByLevel(VeteranLevel)
      STExtraUIUtils.SetImageTextureAsync(Path, self.rect)
    elseif MentorType == EMentorPlayerType.MPT_Recruit then
      self.WidgetSwitcher_VetergenOut:SetActiveWidgetIndex(2)
      self.WidgetSwitcher_Veteran:SetActiveWidgetIndex(2)
    end
  else
    MergeExecutionPath()
  end
end
function MiniMapPlayerIconItem:SetDist(Dist)
  return ""
end
function MiniMapPlayerIconItem:SetPlayerName(Name)
  return ""
end
function MiniMapPlayerIconItem:SetSingleStyle(IsSingle)
  self.CanvasPanel_Single:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
  self.CanvasPanel_Team:SetWidgetVisibility(ESlateVisibility.Collapsed)
  return false
end
function MiniMapPlayerIconItem:SetPlayerBpIconVisible(Reason, bIsShow)
  if not self.ForbidVisibleReason then
    return
  end
  print(bWriteLog and string.format("MiniMapPlayerIconItem:SetPlayerBpIconVisible %s -> %s -> %s", tostring(self.TeammateIndex), tostring(Reason), tostring(bIsShow)))
  if not bIsShow then
    self.ForbidVisibleReason:AddUnique(Reason)
  else
    self.ForbidVisibleReason:RemoveContent(Reason)
  end
  self:RefreshRootPanelVisible()
end
function MiniMapPlayerIconItem:RefreshRootPanelVisible()
  local bHasReason = self.ForbidVisibleReason:Num() > 0
  if bHasReason then
    self.CanvasPanel_SelfPosition:SetWidgetVisibility(ESlateVisibility.Collapsed)
    self.LastRootVisible = false
    return false
  else
    self.CanvasPanel_SelfPosition:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
    self.LastRootVisible = true
    return true
  end
end
local class = require("class")
local CDelegateContainer = require("GameLua.Mod.BaseMod.Common.UI.UILuaUserWidget")
return class(CDelegateContainer, nil, MiniMapPlayerIconItem)