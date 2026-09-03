local mode_anim_mgr = {}
function mode_anim_mgr:ctor(selfType, bpPath, soundPath, soundID)
  self.  self.  self.end
function mode_anim_mgr:OnInitialize()
  mode_anim_mgr.__super.OnInitialize(self)
  self.util = require("client.slua_ui_framework.util")
  local UIUtil = require("client.common.ui_util")
  UIUtil.SetAdaptation(self.UIRoot.IPX)
end
function mode_anim_mgr:RegistEvents()
  mode_anim_mgr.__super.RegistEvents(self)
end
function mode_anim_mgr:OnPostInitialize()
  mode_anim_mgr.__super.OnPostInitialize(self)
end
function mode_anim_mgr:OnShow()
  mode_anim_mgr.__super.OnShow(self)
  if not self.bpPath then
    return
  end
  self:CreateChildWindowWithBpPath("IPX", UIManager.UI_Config.ModeSelection_Opening_UIBP, self.bpPath)
  xpcall(function()
    if self.soundID then
      self:PlayMusic(self.soundID)
    elseif self.soundPath then
      self:PlayAudio(self.soundPath)
    end
  end, function()
  end)
  EventSystem:postEvent(EVENTTYPE_SKILL_SELECTION, EVENTID_SKILL_SELECTION_ON_MODE_ANIM_SHOW)
end
function mode_anim_mgr:ShowNotice(Content, bFast)
  self:CreateChildWindow(self.UIRoot.MsgNode, UIManager.UI_Config.PopupTipItem, Content, bFast)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CUIModeAnimMgr = class(ui_base, nil, mode_anim_mgr)
return CUIModeAnimMgr