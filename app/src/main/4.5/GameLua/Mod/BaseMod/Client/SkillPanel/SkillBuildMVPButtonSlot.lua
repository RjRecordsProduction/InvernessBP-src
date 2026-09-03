local SkillBuildMVPButtonSlot = {}
function SkillBuildMVPButtonSlot:ctor(selfType)
end
function SkillBuildMVPButtonSlot:OnInitialize()
  SkillBuildMVPButtonSlot.__super.OnInitialize(self)
  print(bWriteLog and "SkillBuildMVPButtonSlot:OnInitialize()")
end
function SkillBuildMVPButtonSlot:RegistEvents()
  SkillBuildMVPButtonSlot.__super.RegistEvents(self)
  print(bWriteLog and "SkillBuildMVPButtonSlot:RegistEvents()")
  local EWidgetVisible = import("EWidgetVisible")
  self.UIRoot:SetWidgetRender(EWidgetVisible.ForceVisible)
  local HandleStateCanvasUtils = require("GameLua.Mod.BaseMod.Common.UICanvas.HandleStateCanvasUtils")
  HandleStateCanvasUtils.RegisterCanvasVisibleEvent(self.UIRoot, self, "SkillBuildMVPButtonSlot_BP")
end
function SkillBuildMVPButtonSlot:OnUnRegistEvents()
  print(bWriteLog and "SkillBuildMVPButtonSlot:OnUnRegistEvents")
  local HandleStateCanvasUtils = require("GameLua.Mod.BaseMod.Common.UICanvas.HandleStateCanvasUtils")
  HandleStateCanvasUtils.UnRegisterCanvasVisibleEvent(self.UIRoot)
end
local class = require("class")
local UIBase = require("GameLua.Mod.BaseMod.Client.SkillPanel.SkillButtonSlotBase")
return class(UIBase, nil, SkillBuildMVPButtonSlot)