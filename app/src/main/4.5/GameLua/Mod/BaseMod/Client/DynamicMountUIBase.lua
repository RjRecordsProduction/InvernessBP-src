local DynamicMountUIBase = {}
function DynamicMountUIBase:ctor()
  self.bAutoShow = true
  self.UIConfigName = nil
  self.Position = {X = 0, Y = 0}
  self.AnchorsData = {
    MinX = 0,
    MinY = 0,
    MaxX = 1,
    MaxY = 1
  }
  self.MarginData = {
    Left = 0.0,
    Top = 0.0,
    Right = 0.0,
    Bottom = 0.0
  }
end
function DynamicMountUIBase:OnInitialize()
  DynamicMountUIBase.__super.OnInitialize(self)
  local UIConfig = self._config or nil
  if UIConfig == nil and self.UIConfigName then
    UIConfig = UIManager.UI_Config_InGame[self.UIConfigName]
  end
  if UIConfig == nil then
    sandbox.LogError("DynamicMountUIBase, Config is nil")
    return
  end
  local ParentPanel
  if type(UIConfig.mountPanel) == "string" then
    local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
    local MainControlPanelTochButton = InGameUITools.GetMainControlPanelTochButton()
    ParentPanel = MainControlPanelTochButton and MainControlPanelTochButton[UIConfig.mountPanel] or nil
  elseif type(UIConfig.mountPanel) == "table" then
    local LogicManager = slua_GameFrontendHUD:GetLogicManagerByName("ingame")
    if LogicManager and LogicManager.GetMountCanvasPanel then
      ParentPanel = LogicManager:GetMountCanvasPanel(UIConfig.mountPanel.mountOuterName, UIConfig.mountPanel.mountName)
    end
  end
  if ParentPanel and ParentPanel.AddChild then
    ParentPanel:AddChild(self.UIRoot)
    self:SetZOrder(UIConfig.zOrder or 0)
  end
  self:SetPosition(self.Position.X, self.Position.Y)
  self:SetAnchors(self.AnchorsData.MinX, self.AnchorsData.MinY, self.AnchorsData.MaxX, self.AnchorsData.MaxY)
  self:SetOffsets(self.MarginData.Left, self.MarginData.Top, self.MarginData.Right, self.MarginData.Right)
end
function DynamicMountUIBase:RegistEvents()
  DynamicMountUIBase.__super.RegistEvents(self)
  if self.UIRoot.BeginShowTips then
    self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_BEGIN_SHOW_TIPS, self.BeginShowTips, self)
  end
  if self.UIRoot.EndShowTips then
    self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_END_SHOW_TIPS, self.EndShowTips, self)
  end
end
function DynamicMountUIBase:OnPostInitialize()
  DynamicMountUIBase.__super.OnPostInitialize(self)
  if self.UIRoot.Hide then
    self.UIRoot:Hide()
  end
  if self.UIRoot.InitWidget then
    self.UIRoot:InitWidget(true)
  end
  if self.bAutoShow and self.UIRoot.Show then
    self.UIRoot:Show()
  end
  if self.UIRoot.ReceivedMountWidget then
    self.UIRoot:ReceivedMountWidget()
  end
end
function DynamicMountUIBase:GetUIRoot()
  return self.UIRoot
end
function DynamicMountUIBase:BeginShowTips()
  if self.UIRoot.BeginShowTips then
    self.UIRoot:BeginShowTips()
  end
end
function DynamicMountUIBase:EndShowTips()
  if self.UIRoot.EndShowTips then
    self.UIRoot:EndShowTips()
  end
end
function DynamicMountUIBase:OnClose()
  DynamicMountUIBase.__super.OnClose(self)
end
local class = require("class")
local UIBase = require("client.slua_ui_framework.base")
return class(UIBase, nil, DynamicMountUIBase)