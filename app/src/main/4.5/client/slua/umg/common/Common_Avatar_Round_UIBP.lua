local Common_Avatar_Round_UIBP = {}
function Common_Avatar_Round_UIBP:ctor(_)
  log(bWriteLog and "Common_Avatar_Round_UIBP:ctor")
  self.uid = nil
  self.iconURL = nil
end
function Common_Avatar_Round_UIBP:OnInitialize()
  Common_Avatar_Round_UIBP.__super.OnInitialize(self)
end
function Common_Avatar_Round_UIBP:RegistEvents()
  Common_Avatar_Round_UIBP.__super.RegistEvents(self)
end
function Common_Avatar_Round_UIBP:OnPostInitialize()
  Common_Avatar_Round_UIBP.__super.OnPostInitialize(self)
end
function Common_Avatar_Round_UIBP:SetData(uid, iconURL, cur_avatar_box_id)
  if not self.UIRoot or not slua.isValid(self.UIRoot) then
    return
  end
  if self.UIRoot.Common_Avatar_BP then
    self.UIRoot.Common_Avatar_BP:InitView(nil, uid, iconURL, nil, cur_avatar_box_id, nil, false)
  else
    log(bWriteLog and "Common_Avatar_Round_UIBP:SetData invalid Common_Avatar_BP")
  end
end
function Common_Avatar_Round_UIBP:PlayFadein()
  log(bWriteLog and "Common_Avatar_Round_UIBP:PlayFadein")
  if not self.UIRoot or not slua.isValid(self.UIRoot) then
    log(bWriteLog and "Common_Avatar_Round_UIBP:PlayFadein invalid UIRoot")
    return
  end
  if not self.UIRoot.Fadein then
    log(bWriteLog and "Common_Avatar_Round_UIBP:PlayFadein invalid Fadein")
    return
  end
  self:PlayUserWidgetAnimation(self.UIRoot.Fadein, 0, 1, 0, 1)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CCommon_Avatar_Round_UIBP = class(ui_base, nil, Common_Avatar_Round_UIBP)
return CCommon_Avatar_Round_UIBP