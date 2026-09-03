local Common_Avatar_Reddot_UIBP = {}
function Common_Avatar_Reddot_UIBP:OnInitialize()
  local reddot_node_collect_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.reddot_node_collect_manager)
  local collectTab = reddot_node_collect_manager:GetCollectTab()
  if not reddot_node_collect_manager:ShowNewReddot(self.UIRoot, self.UIRoot.Reddot_Anchor_Component, collectTab.collect_lobby) and self.UIRoot.Image_RedDot then
    local logic_reddot_limitation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_reddot_limitation)
    logic_reddot_limitation:ToggleReddotActivation(self.UIRoot.Image_RedDot, true)
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CCommon_Avatar_Reddot = class(ui_base, nil, Common_Avatar_Reddot_UIBP)
return CCommon_Avatar_Reddot