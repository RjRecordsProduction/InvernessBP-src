local EntireMapTaskMenuBtn = {
  LuaEventContainer = {"OnSelect"}
}
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local Util = require("client.slua_ui_framework.util")
local FXTaskStateType = import("FXTaskStateType")
function EntireMapTaskMenuBtn:ctor(_, Type, Index)
  self.  self.  self.bIsCompleted = false
end
function EntireMapTaskMenuBtn:RegistEvents()
  EntireMapTaskMenuBtn.__super.RegistEvents(self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Task, self.OnClickButton, self)
end
function EntireMapTaskMenuBtn:OnPostInitialize()
  printf("EntireMapTaskMenuBtn:OnPostInitialize")
  EntireMapTaskMenuBtn.__super.OnPostInitialize(self)
  local Config = GamePlayTools.GetCurrentConfig("EntireMapTaskConfig")
  local ModuleConfig = Config.TypeModule
  local TypeConfig = ModuleConfig[self.Type]
  if TypeConfig then
    self.UIRoot.Image_TaskType:SetBrushFromPathAsync(TypeConfig.IconPath, false)
    self.UIRoot.Image_Select:SetBrushFromPathAsync(TypeConfig.IconPath, false)
  end
  self:AttachWindow()
end
function EntireMapTaskMenuBtn:AttachWindow()
  local EntireMapTaskUI = UIManager.GetUI(UIManager.UI_Config_InGame.EntireMapTaskUI)
  if EntireMapTaskUI and EntireMapTaskUI.UIRoot and EntireMapTaskUI.UIRoot.VerticalLeftMenu then
    EntireMapTaskUI.UIRoot.VerticalLeftMenu:AddChildAt(self.Index, self.UIRoot)
  end
end
function EntireMapTaskMenuBtn:OnClickButton()
  if self.bIsCompleted then
    return
  end
  self:LuaBroadcast("OnSelect", self.Type)
end
function EntireMapTaskMenuBtn:OnComplete()
  self.UIRoot.WidgetSwitcher_Select:SetActiveWidgetIndex(0)
  self.UIRoot.Image_TaskType:SetOpacity(0.5)
  self.bIsCompleted = true
end
function EntireMapTaskMenuBtn:RefreshType(curType)
  if self.Type == curType then
    self.UIRoot.WidgetSwitcher_Select:SetActiveWidgetIndex(1)
  else
    self.UIRoot.WidgetSwitcher_Select:SetActiveWidgetIndex(0)
  end
end
function EntireMapTaskMenuBtn:OnClose()
  EntireMapTaskMenuBtn.__super.OnClose(self)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CEntireMapTaskMenuBtn = class(ui_base, nil, EntireMapTaskMenuBtn)
return CEntireMapTaskMenuBtn