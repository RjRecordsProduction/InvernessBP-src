local DefaultSeatGeneralUI = {}
function DefaultSeatGeneralUI:ctor()
  self.CurrentSeatPopupUIConfig = UIManager.UI_Config_InGame.DefaultSeatPopupUI
end
function DefaultSeatGeneralUI:OnInitialize()
  DefaultSeatGeneralUI.__super.OnInitialize(self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_SHOW_SEAT_GENERAL_UI_NEWBIE_GUIDE_TIPS, self.StartGuide, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_HIDE_SEAT_GENERAL_UI_NEWBIE_GUIDE_TIPS, self.FinishGuide, self)
end
function DefaultSeatGeneralUI:StartGuide()
  local VehicleGuideSlideTips = self:CreateChildWindow(self.UIRoot.CanvasPanel_Socket, UIManager.UI_Config_InGame.VehicleGuideSlideTips)
  if VehicleGuideSlideTips then
    VehicleGuideSlideTips:SetAnchors(0, 0, 1, 1)
    VehicleGuideSlideTips:SetOffsets(0, 0, 0, 0)
    VehicleGuideSlideTips:SetAlignment(0, 0.5)
  end
end
function DefaultSeatGeneralUI:OnEnterVehicle()
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_SHOW_SEAT_GENERAL_UI)
end
function DefaultSeatGeneralUI:FinishGuide()
  UIManager.CloseUI(UIManager.UI_Config_InGame.VehicleGuideSlideTips)
end
function DefaultSeatGeneralUI:OnClose()
  self:FinishGuide()
  DefaultSeatGeneralUI.__super.OnClose(self)
end
local class = require("class")
local BaseSeatGeneralUI = require("GameLua.Mod.BaseMod.Client.InGameUI.VehicleControl.Seat.BaseSeatGeneralUI")
return class(BaseSeatGeneralUI, nil, DefaultSeatGeneralUI)