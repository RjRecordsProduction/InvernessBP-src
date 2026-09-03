local UICommonFunctionLibrary = {}
function UICommonFunctionLibrary:SetAdaptation(widget)
  local UIUtil = require("client.common.ui_util")
  UIUtil.SetAdaptation(widget)
end
local class = require("class")
local object = require("object")
local ClassUICommonFunctionLibrary = class(object, nil, UICommonFunctionLibrary)
return ClassUICommonFunctionLibrary