local ModeSelection_Opening_UIBP = {}
function ModeSelection_Opening_UIBP:ctor()
end
function ModeSelection_Opening_UIBP:OnInitialize()
  ModeSelection_Opening_UIBP.__super.OnInitialize(self)
  self.util = require("client.slua_ui_framework.util")
end
function ModeSelection_Opening_UIBP:RegistEvents()
  ModeSelection_Opening_UIBP.__super.RegistEvents(self)
  if self.UIRoot.fadein then
    self:AddControlEventByControl(self.UIRoot.fadein, "OnAnimationFinished", self.OnAnimEnd, self)
  end
end
function ModeSelection_Opening_UIBP:OnPostInitialize()
  ModeSelection_Opening_UIBP.__super.OnPostInitialize(self)
  self:UpdateUI()
  self:PlayUserWidgetAnimation(self.UIRoot.fadein, 0, 1, 0, 1)
end
function ModeSelection_Opening_UIBP:UpdateUI()
end
function ModeSelection_Opening_UIBP:OnAnimEnd()
  self:AddTimerOnce(0, function()
    UIManager.CloseUI(UIManager.UI_Config.loading_anim_mgr)
  end)
end
function ModeSelection_Opening_UIBP:OnClose()
  ModeSelection_Opening_UIBP.__super.OnClose(self)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CModeSelection_Opening_UIBP = class(ui_base, nil, ModeSelection_Opening_UIBP)
return CModeSelection_Opening_UIBP