local AnimationBase = {}
local local local string_format = string.format
local local AnimationMap = {
  {name = "open"},
  {name = "Fadein"},
  {
    name = "Auto_Fadein"
  },
  {
    name = "Anim_In_Temp"
  },
  {
    name = "Common_Fadein",
    root = "Common_Popup_Small_UIBP"
  },
  {
    name = "Common_Fadein",
    root = "Common_Popup_Medium_UIBP"
  },
  {
    name = "Common_Fadein",
    root = "Common_Popup_MediumSmall_UIBP"
  },
  {
    name = "Common_Fadein",
    root = "Common_Popup_Medium_HaveTab_UIBP"
  },
  {
    name = "Common_Fadein",
    root = "Common_Popup_Large_HaveTab_UIBP"
  }
}
function AnimationBase:OnShow()
  for _, animData in ipairs(AnimationMap) do
    local root = self.UIRoot
    local rootName = animData.root
    if self.UIRoot[rootName] then
      root = self.UIRoot[rootName]
    end
    local animName = animData.name
    if root and animName then
      local anim = root[animName]
      if anim then
        self:PlayWidgetAnimation(root, anim, 0, 1, 0, 1)
        log(bWriteLog and string_format("AnimationBase:OnShow. animName = %s", animName))
      end
    end
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CAnimationBase = class(ui_base, nil, AnimationBase)
return CAnimationBase