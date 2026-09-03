local Theme_Entrance_Item = {}
function Theme_Entrance_Item:ctor()
end
function Theme_Entrance_Item:OnInitialize()
end
function Theme_Entrance_Item:RegistEvents()
  self:AddOnClickedEventByControl(self.UIRoot.Button_Enter, self.OnClickButton_Enter, self)
end
function Theme_Entrance_Item:OnPostInitialize()
  self:UpdateUI()
  self:AddTimerOnce(0.5, function()
    if self:IsValid() and slua.isValid(self.UIRoot) then
      self:PlayAnimation("Fadein", 0, 1, 0, 1)
    end
  end)
end
function Theme_Entrance_Item:OnClose()
end
function Theme_Entrance_Item:OnClickButton_Enter()
  self:PlayAudio(sound_config.click_v1)
  local ui_jump_manager = require("client.common.uibase.ui_jump_manager")
  local ThemeConfig = require("client.slua.logic.theme_system.theme_config")
  ui_jump_manager.OpenJumpModule(BP_ENUM_MODULE_THEME_SYSTEM, {
    tab = ThemeConfig.SubSystem.GameIntroduction
  })
end
function Theme_Entrance_Item:UpdateUI()
  log(bWriteLog and "Theme_Entrance_Item:UpdateUI")
  self.UIRoot.TextBlock_Name:SetText(LocUtil.GetLocalizeResStr(33020413))
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
return class(ui_base, nil, Theme_Entrance_Item)