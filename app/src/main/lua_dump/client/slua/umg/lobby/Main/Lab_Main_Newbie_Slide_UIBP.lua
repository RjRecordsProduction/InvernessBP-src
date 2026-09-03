local Lab_Main_Newbie_Slide_UIBP = {}
function Lab_Main_Newbie_Slide_UIBP:ctor()
end
function Lab_Main_Newbie_Slide_UIBP:OnInitialize()
  Lab_Main_Newbie_Slide_UIBP.__super.OnInitialize(self)
  self.util = require("client.slua_ui_framework.util")
  self.Button_Skip = self.UIRoot.Button_Skip
  self:PlayUserWidgetAnimation(self.UIRoot.Slide, 0, 0, 0, 1)
end
function Lab_Main_Newbie_Slide_UIBP:RegistEvents()
  Lab_Main_Newbie_Slide_UIBP.__super.RegistEvents(self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Skip, self.OnButton_SkipClick, self)
end
function Lab_Main_Newbie_Slide_UIBP:OnPostInitialize()
  Lab_Main_Newbie_Slide_UIBP.__super.OnPostInitialize(self)
  self:UpdateUI()
end
function Lab_Main_Newbie_Slide_UIBP:UpdateUI()
end
function Lab_Main_Newbie_Slide_UIBP:Close()
  Lab_Main_Newbie_Slide_UIBP.__super.Close(self)
end
function Lab_Main_Newbie_Slide_UIBP:OnButton_SkipClick()
  self:PlayAudio(sound_config.click_v1)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CLab_Main_Newbie_Slide_UIBP = class(ui_base, nil, Lab_Main_Newbie_Slide_UIBP)
return CLab_Main_Newbie_Slide_UIBP