local Promise = require("common.Promise")
local Common_Avatar_UIBase = {}
function Common_Avatar_UIBase:ctor()
  self._cObj_promise = nil
end
function Common_Avatar_UIBase:OnPostInitialize()
  Common_Avatar_UIBase.__super.OnPostInitialize(self)
end
function Common_Avatar_UIBase:UIOperation(fResolveCallback, fRejectCallback)
  if self:IsAsyncLoading() then
    if not self._cObj_promise then
      self._cObj_promise = Promise.new()
    end
    self._cObj_promise:Then(fResolveCallback, fRejectCallback)
    return
  end
  if fResolveCallback and type(fResolveCallback) then
    fResolveCallback(self)
  end
end
function Common_Avatar_UIBase:RestoreUIOperation()
  if self._cObj_promise then
    self._cObj_promise:Resolve(self)
    self._cObj_promise = nil
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CCommon_Avatar_UIBase = class(ui_base, nil, Common_Avatar_UIBase)
return CCommon_Avatar_UIBase