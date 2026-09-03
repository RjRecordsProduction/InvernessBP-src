local EntireMapPlayerIconItem = {}
local ESlateVisibility = UEnums.ESlateVisibility
function EntireMapPlayerIconItem:ctor()
  self.TeammateIndex = -1
end
function EntireMapPlayerIconItem:Initialize()
  self:OnTransformerStateChange()
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
function EntireMapPlayerIconItem:LoadTeamIndexIcon(Index)
  local DataInfo = CDataTable.GetTableData("IngameTeammateIndexIconPath", Index)
  if DataInfo ~= nil then
    local Out = DataInfo.IconPath
    if self.CurIndexIconPath ~= Out then
      self.Image_SelfNumIcon:SetBrushFromPathAsync(Out, false)
    end
  else
    print(bWriteLog and "invalid team index " .. tostring(Index))
  end
end
function EntireMapPlayerIconItem:SwitchAliveDeadIcon(IsDead)
  if IsDead then
    self.Image_SelfBG:SetWidgetVisibility(ESlateVisibility.Collapsed)
    self.RotArrow:SetWidgetVisibility(ESlateVisibility.Collapsed)
    self.WidgetSwitcher_Veteran:SetWidgetVisibility(ESlateVisibility.Collapsed)
    self.Image_SelfDead:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
    self.WidgetSwitcher_Veteran:SetActiveWidgetIndex(2)
  else
    self.Image_SelfBG:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
    self.RotArrow:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
    self.WidgetSwitcher_Veteran:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
    self.Image_SelfDead:SetWidgetVisibility(ESlateVisibility.Collapsed)
    self.WidgetSwitcher_Veteran:SetActiveWidgetIndex(0)
  end
  return true
end
function EntireMapPlayerIconItem:SwitchInOutRange(bIsInRange, Degree, bEnableNewStyle)
  return false
end
function EntireMapPlayerIconItem:GetRotationDisplayWidget()
  return self.RotArrow
end
function EntireMapPlayerIconItem:SetDist(Dist)
  self.Player02InfoDist:SetText(Dist)
  return Dist
end
function EntireMapPlayerIconItem:SetSelfStyle(bIsSelf)
  if bIsSelf then
    self.PlayerMaker:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
  else
    self.PlayerMaker:SetWidgetVisibility(ESlateVisibility.Collapsed)
  end
  return false
end
function EntireMapPlayerIconItem:SwitchVisibility(bIsShow)
  if bIsShow then
    self:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
  else
    self:SetWidgetVisibility(ESlateVisibility.Collapsed)
  end
  return false
end
function EntireMapPlayerIconItem:SetPlayerName(Name)
  self.TextBlock_Player02NameInMap:SetText(Name)
  return Name
end
function EntireMapPlayerIconItem:SetSingleStyle(bIsSingle)
  if bIsSingle then
    self.CanvasPanel_Single:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
    self.CanvasPanel_Team:SetWidgetVisibility(ESlateVisibility.Collapsed)
    self.TextBlock_Player02NameInMap:SetWidgetVisibility(ESlateVisibility.Collapsed)
    self.CanvasPanel_Dist:SetWidgetVisibility(ESlateVisibility.Collapsed)
  else
    self.CanvasPanel_Single:SetWidgetVisibility(ESlateVisibility.Collapsed)
    self.CanvasPanel_Team:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
    self.TextBlock_Player02NameInMap:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
    self.CanvasPanel_Dist:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
  end
  return true
end
function EntireMapPlayerIconItem:UpdateVeteranStatus(MentorType, VeteranLevel)
  local ClientIngameUIFunctionLibrary = require("GameLua.Mod.Library.Client.ClientIngameUIFunctionLibrary")
  if ClientIngameUIFunctionLibrary.NeedShowVeteran() then
    local EMentorPlayerType = import("EMentorPlayerType")
    if MentorType == EMentorPlayerType.MPT_NormalPlayer then
      self.WidgetSwitcher_Veteran:SetActiveWidgetIndex(0)
    elseif MentorType == EMentorPlayerType.MPT_Veteran then
      self.WidgetSwitcher_Veteran:SetActiveWidgetIndex(1)
      local Path = ClientIngameUIFunctionLibrary.GetPlayerVeteranIconPathByLevel(VeteranLevel)
      local STExtraUIUtils = import("/Script/ShadowTrackerExtra.STExtraUIUtils")
      STExtraUIUtils.SetImageTextureAsync(Path, self.veteran)
    elseif MentorType == EMentorPlayerType.MPT_Recruit then
      self.WidgetSwitcher_Veteran:SetActiveWidgetIndex(2)
    end
  else
    self.WidgetSwitcher_Veteran:SetActiveWidgetIndex(0)
  end
end
function EntireMapPlayerIconItem:SetPlayerBpIconVisible(Reason, bIsShow)
  if not self.ForbidVisibleReason then
    return
  end
  print(bWriteLog and string.format("EntireMapPlayerIconItem:SetPlayerBpIconVisible %s -> %s -> %s", tostring(self.TeammateIndex), tostring(Reason), tostring(bIsShow)))
  if not bIsShow then
    self.ForbidVisibleReason:AddUnique(Reason)
  else
    self.ForbidVisibleReason:RemoveContent(Reason)
  end
  self:RefreshRootPanelVisible()
end
function EntireMapPlayerIconItem:RefreshRootPanelVisible()
  local bHasReason = self.ForbidVisibleReason:Num() > 0
  if bHasReason then
    self.PlayerInfo:SetWidgetVisibility(ESlateVisibility.Collapsed)
    self.LastRootVisible = false
    return false
  else
    self.PlayerInfo:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
    self.LastRootVisible = true
    return true
  end
end
function EntireMapPlayerIconItem:OnTransformerStateChange()
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
function EntireMapPlayerIconItem:SetTeammateInfo(TeammateIndex, TeammateColor)
  self.  return self.Super:SetTeammateInfo(TeammateIndex, TeammateColor)
end
local class = require("class")
local CDelegateContainer = require("GameLua.Mod.BaseMod.Common.UI.UILuaUserWidget")
return class(CDelegateContainer, nil, EntireMapPlayerIconItem)