local CustomType = require("client.logic.setting.CustomType")
local Socialize_UIBP = {}
local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
function Socialize_UIBP:ctor()
end
function Socialize_UIBP:OnInitialize()
  Socialize_UIBP.__super.OnInitialize(self)
  self.util = require("client.slua_ui_framework.util")
end
function Socialize_UIBP:RegistEvents()
  Socialize_UIBP.__super.RegistEvents(self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Socialize, self.OnButton_SocializeClick, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_SPECTATING, EVENTID_ENTER_OBSERVING, self.CloseSelf, self)
  self:AddCommonEvent(EVENTTYPE_STATE, EVENTID_GAMESTATE_ON_BATTLE_RESULT, self.CloseSelf, self)
end
function Socialize_UIBP:OnPostInitialize()
  Socialize_UIBP.__super.OnPostInitialize(self)
  self.isOpenTeamInfo = false
  self.UIRoot.WidgetSwitcher_Socialize:SetActiveWidgetIndex(0)
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if MainControlBaseUI and MainControlBaseUI.CanvasPanel_1 then
    MainControlBaseUI.CanvasPanel_1:AddChild(self.UIRoot)
    self.UIRoot.Slot:SetAnchors(FAnchors(0, 0, 1, 1))
    self.UIRoot.Slot:SetOffsets(FMargin(0, 0, 0, 0))
    self.UIRoot.Slot:SetZOrder(10)
  end
end
function Socialize_UIBP:OnClose()
  if slua.isValid(self.UIRoot) then
  end
  Socialize_UIBP.__super.OnClose(self)
end
function Socialize_UIBP:OnButton_SocializeClick()
  self.isOpenTeamInfo = not self.isOpenTeamInfo
  if self.isOpenTeamInfo then
    self.UIRoot.WidgetSwitcher_Socialize:SetActiveWidgetIndex(1)
    local IngameTeamUIBP = UIManager.ShowUI(UIManager.UI_Config_InGame.IngameTeamUIBP)
    self.UIRoot.CanvasPanel_s193:ClearChildren()
    self:AttachChildWindowByControl(self.UIRoot.CanvasPanel_s193, IngameTeamUIBP)
    IngameTeamUIBP:SetAutoSize(true)
  else
    self.UIRoot.WidgetSwitcher_Socialize:SetActiveWidgetIndex(0)
    UIManager.HideUI(UIManager.UI_Config_InGame.IngameTeamUIBP)
  end
  self:SetWidgetVisible(self.UIRoot.Image_Socialize_Glow, false)
end
function Socialize_UIBP:CheckDelayRed()
  self:SetWidgetVisible(self.UIRoot.Image_Socialize_Glow, false)
  local logic_team_zone_ping = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_team_zone_ping)
  if not logic_team_zone_ping:InGameDelayShow() then
    return
  end
  self:SetWidgetVisible(self.UIRoot.Image_Socialize_Glow, true)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CSocialize_UIBP = class(ui_base, nil, Socialize_UIBP)
return CSocialize_UIBP