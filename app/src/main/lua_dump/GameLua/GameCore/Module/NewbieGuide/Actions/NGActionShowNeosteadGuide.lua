local NGActionShowNeosteadGuide = {}
function NGActionShowNeosteadGuide:RunAction(InGuideID)
  NGActionShowNeosteadGuide.__super.RunAction(self, InGuideID)
  self:SetCanvasPanel_TipsShowHide(true)
  return true
end
function NGActionShowNeosteadGuide:EndAction()
  NGActionShowNeosteadGuide.__super.EndAction(self)
  self:SetCanvasPanel_TipsShowHide(false)
end
function NGActionShowNeosteadGuide:Clear()
  NGActionShowNeosteadGuide.__super.Clear(self)
  self:SetCanvasPanel_TipsShowHide(false)
  self.WeaponSlotUI = nil
end
function NGActionShowNeosteadGuide:SetCanvasPanel_TipsShowHide(bShow)
  print(bWriteLog and "NGActionShowNeosteadGuide: bShow", bShow)
  local ESurviveWeaponPropSlot = import("ESurviveWeaponPropSlot")
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local ShootingUILuaClass = InGameUITools.GetShootingUIPanelLuaClass()
  if not ShootingUILuaClass then
    print(bWriteLog and "NGActionShowNeosteadGuide: ShootingUILuaClass return")
    return
  end
  local OperateSubsystem = SubsystemMgr:Get("OperateSubsystem")
  if not OperateSubsystem then
    return
  end
  local CurWeaponSlot = OperateSubsystem:GetCurrentUsingPropSlot()
  if CurWeaponSlot == ESurviveWeaponPropSlot.SWPS_MainShootWeapon1 then
    self.WeaponSlotUI = ShootingUILuaClass.FirWeaponSlot.UIRoot
  elseif CurWeaponSlot == ESurviveWeaponPropSlot.SWPS_MainShootWeapon2 then
    self.WeaponSlotUI = ShootingUILuaClass.SecWeaponSlot.UIRoot
  end
  if not slua.isValid(self.WeaponSlotUI) then
    print(bWriteLog and "NGActionShowNeosteadGuide: WeaponSlotUI return")
    return
  end
  print(bWriteLog and "NGActionShowNeosteadGuide: self.bShowingTip", self.bShowingTip)
  if bShow then
    self.WeaponSlotUI.Tips21_22:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.WeaponSlotUI.UTRichTextBlock_Tips22_Text1:SetText(LocUtil.GetLocalizeResStr(44130))
    self.bShowingTip = true
  else
    if self.bShowingTip then
      self.WeaponSlotUI.Tips21_22:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
    self.bShowingTip = false
  end
end
local class = require("class")
local CObject = require("GameLua.GameCore.Module.NewbieGuide.Actions.NewbieGuideActionBase")
local CNGActionShowNeosteadGuide = class(CObject, nil, NGActionShowNeosteadGuide)
return CNGActionShowNeosteadGuide