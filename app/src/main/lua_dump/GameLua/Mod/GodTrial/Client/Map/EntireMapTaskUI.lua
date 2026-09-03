local GodTrialHonorWayConfig = require("GameLua.Mod.GodTrial.Client.Config.GodTrialHonorWayConfig")
local EntireMapTaskUI = {}
local TaskPanelType = "GodTrialHonorTask"
function EntireMapTaskUI:ctor()
  print(bWriteLog and "GodTrial EntireMapTaskUI:ctor")
  self.CurDisplayType = "Task"
  self.bGodTrialUIInited = false
end
function EntireMapTaskUI:OnInitialize(...)
  EntireMapTaskUI.__super.OnInitialize(self, ...)
  print(bWriteLog and "GodTrial EntireMapTaskUI:OnInitialize")
end
function EntireMapTaskUI:RegistEvents()
  EntireMapTaskUI.__super.RegistEvents(self)
  print(bWriteLog and "GodTrial EntireMapTaskUI:RegistEvents")
end
function EntireMapTaskUI:RefreshAllItem()
  EntireMapTaskUI.__super.RefreshAllItem(self)
end
function EntireMapTaskUI:CheckShowTaskUI()
  EntireMapTaskUI.__super.CheckShowTaskUI(self)
  print(bWriteLog and "GodTrial EntireMapTaskUI:CheckShowTaskUI")
  local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
  local MapType = GameMainConfig.GetMapType()
  if MapType ~= "Neon" then
    self:AddAllowType(TaskPanelType)
  end
  self:InitAllMenuBtn()
  self:UpdateMenu()
end
function EntireMapTaskUI:RefreshCompleteState()
  return true
end
function EntireMapTaskUI:OnExtendButtonClick()
  local bIsNeedShow = not self.IsShowTask
  self:OnExtendTaskUI(bIsNeedShow, true)
  if self.IsShowTask then
    self:RefreshAllItem()
  end
end
function EntireMapTaskUI:AddMenuBtn(Index, Type, TypePriority)
  if Type == TaskPanelType then
    Index = 2
  end
  if Index > #self.MenuBtns + 1 then
    Index = #self.MenuBtns + 1
  end
  EntireMapTaskUI.__super.AddMenuBtn(self, Index, Type, TypePriority)
end
function EntireMapTaskUI:InitAllMenuBtn()
  local allMenuBtn = self.MenuBtns
  for i, v in ipairs(allMenuBtn) do
    self:InitMenuBtn(v)
  end
end
function EntireMapTaskUI:InitMenuBtn(menuBtnInfo)
  if menuBtnInfo == nil then
    return
  end
  local menuBtn = menuBtnInfo.Widget
  if menuBtn then
    menuBtn.MenuType = menuBtnInfo.MenuType
    menuBtn.Priority = menuBtnInfo.Priority
    function menuBtn.OnClickedFunc(menuBtnType)
      self:BtnClicked(menuBtnType)
    end
  end
end
function EntireMapTaskUI:OnMenuBtnSelect(CurType)
  EntireMapTaskUI.__super.OnMenuBtnSelect(self, CurType)
  print(bWriteLog and "GodTrial EntireMapTaskUI:OnMenuBtnSelect")
  self:UpdateMenu()
end
function EntireMapTaskUI:SwitchToType(Type)
  print(bWriteLog and "GodTrial EntireMapTaskUI:SwitchToType Type:" .. tostring(Type))
  EntireMapTaskUI.__super.SwitchToType(self, Type)
  self:UpdateMenu()
end
function EntireMapTaskUI:UpdateMenu()
  if self.CurDisplayType == TaskPanelType then
    self:InitGodTrialUI()
    if self.UIRoot.TaskWidgetSwitcher then
      self.UIRoot.TaskWidgetSwitcher:SetActiveWidgetIndex(1)
    end
  elseif self.UIRoot.TaskWidgetSwitcher then
    self.UIRoot.TaskWidgetSwitcher:SetActiveWidgetIndex(0)
  end
end
function EntireMapTaskUI:InitGodTrialUI()
  if self.bGodTrialUIInited and self.HonorTipWidget then
    self.HonorTipWidget:RefreshUI()
    return
  end
  print(bWriteLog and "GodTrial EntireMapTaskUI:InitGodTrialUI")
  self:InitHonorTipPanel()
  self.bGodTrialUIInited = true
end
function EntireMapTaskUI:InitHonorTipPanel()
  if self.HonorTipWidget then
    self.HonorTipWidget:RefreshUI()
    return
  end
  print(bWriteLog and "GodTrial EntireMapTaskUI:InitHonorTipPanel - creating HonorTipWidget")
  if not self.UIRoot.TaskWidgetSwitcher then
    print(bWriteLog and "GodTrial EntireMapTaskUI:InitHonorTipPanel - TaskWidgetSwitcher not found")
    return
  end
  local HonorTipUI = self:CreateChildWindow(self.UIRoot.TaskWidgetSwitcher, UIManager.UI_Config_InGame.GodTrialHonourItemMapUI)
  if not HonorTipUI then
    print(bWriteLog and "GodTrial EntireMapTaskUI:InitHonorTipPanel - Failed to create HonorTipUI")
    return
  end
  self.HonorTipWidget = HonorTipUI
  self.HonorTipWidget:RefreshUI()
end
function EntireMapTaskUI:OnClose()
  print(bWriteLog and "GodTrial EntireMapTaskUI:OnClose")
  self.bGodTrialUIInited = false
  self.HonorTipWidget = nil
  if self.MenuBtns then
    for _, menuBtnInfo in ipairs(self.MenuBtns) do
      if menuBtnInfo and menuBtnInfo.Widget then
        menuBtnInfo.Widget.OnClickedFunc = nil
      end
    end
  end
  EntireMapTaskUI.__super.OnClose(self)
end
local class = require("class")
local UIBase = require("GameLua.Mod.BaseMod.Client.Map.MapWindow.EntireMapTaskUI")
local CEntireMapTaskUI = class(UIBase, nil, EntireMapTaskUI)
return CEntireMapTaskUI