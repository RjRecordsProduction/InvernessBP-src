local BattleFlagTeamArmorUI = {}
local UKismetMathLibrary = import("KismetMathLibrary")
local BattleFlagConfig = require("GameLua.ExtraModule.SkillCore.Gameplay.BattleFlag.BattleFlagConfig")
function BattleFlagTeamArmorUI:ctor()
  self.LastPercent = -1
end
function BattleFlagTeamArmorUI:OnInitialize()
  print(bWriteLog and "BattleFlagTeamArmorUI:OnInitialize")
  BattleFlagTeamArmorUI.__super.OnInitialize(self)
end
function BattleFlagTeamArmorUI:OnShow()
  print(bWriteLog and "BattleFlagTeamArmorUI:OnShow")
  BattleFlagTeamArmorUI.__super.OnShow(self)
  self:AttachToParentPanel(self._parentUI, "GridPanel_2")
  self.LastPercent = -1
  self:AddCommonEvent(EVENTTYPE_SKILLCORE_NORMAL, EVENTID_BATTLEFLAG_ARMOR_CHANGED, self.OnBattleFlagArmorChanged, self)
end
function BattleFlagTeamArmorUI:OnHide()
  print(bWriteLog and "BattleFlagTeamArmorUI:OnHide")
  BattleFlagTeamArmorUI.__super.OnHide(self)
  self:RemoveCommonEvent(EVENTTYPE_SKILLCORE_NORMAL, EVENTID_BATTLEFLAG_ARMOR_CHANGED)
end
function BattleFlagTeamArmorUI:AttachToParentPanel(ParentPanel, SlotName)
  if not ParentPanel then
    return
  end
  ParentPanel:AttachChildWindow(SlotName, self)
  self:SetZOrder(1)
  self:SetAnchors(0, 0, 1, 1)
  self:SetOffsets(0, 0, 0, 0)
  self.UIRoot.Slot:SetLayer(10)
  ParentPanel.UIRoot[SlotName]:ReSortSlot()
end
function BattleFlagTeamArmorUI:OnBattleFlagArmorChanged(_, _, PlayerKey, BattleFlagArmor)
  if not self._parentUI then
    print(bWriteLog and "BattleFlagTeamArmorUI:OnBattleFlagArmorChanged _parentUI is nil")
    return
  end
  local uPlayerState = self._parentUI.uPlayerState
  if not slua.isValid(uPlayerState) then
    print(bWriteLog and "BattleFlagTeamArmorUI:OnBattleFlagArmorChanged uPlayerState is nil")
    return
  end
  if uPlayerState.PlayerKey ~= PlayerKey then
    return
  end
  print(bWriteLog and string.format("BattleFlagTeamArmorUI:OnBattleFlagArmorChanged - PlayerKey: %s, Armor: %s", tostring(PlayerKey), tostring(BattleFlagArmor)))
  self:RefreshArmorBar(BattleFlagArmor)
end
function BattleFlagTeamArmorUI:RefreshArmorBar(CurArmor)
  local MaxArmor = BattleFlagConfig.ArmorValue
  if MaxArmor <= 0 then
    return
  end
  local Percent = CurArmor / MaxArmor
  Percent = UKismetMathLibrary.FClamp(Percent, 0, 1)
  if self.LastPercent == -1 then
    self.Last  end
  if Percent <= 0 then
    if slua.isValid(self.UIRoot.Box_Yellow) then
      self.UIRoot.Box_Yellow:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
    self.LastPercent = -1
  elseif slua.isValid(self.UIRoot.Box_Yellow) then
    self.UIRoot.Box_Yellow:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
  self.UIRoot:PlayAnimationTo(self.UIRoot.Anim_Unyielding_Decrease, 1 - self.LastPercent, 1 - Percent, 1, 0, 1)
  self.Lastend
local class = require("class")
local UIBase = require("GameLua.Mod.BaseMod.Client.DynamicMountUIBase")
return class(UIBase, nil, BattleFlagTeamArmorUI)