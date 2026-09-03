local common_popup_box = {}
function common_popup_box:SetData(mainUI, titleText, extraData)
  self:_InitUI(mainUI, titleText, extraData)
end
function common_popup_box:SetTitle(titleText)
  self.  self:_SetTitle()
end
function common_popup_box:ClosePopup()
  self:_PlayFadeOut()
end
local class = require("class")
local ui_base = require("client.slua.component.common.common_popup_box_base")
local CCommon_popup_box = class(ui_base, nil, common_popup_box)
return CCommon_popup_box