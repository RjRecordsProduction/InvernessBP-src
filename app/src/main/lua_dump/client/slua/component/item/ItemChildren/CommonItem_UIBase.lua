local Promise = require("common.Promise")
local CommonItem_UIBase = {}
function CommonItem_UIBase:ctor()
  self._cObj_promise = nil
end
function CommonItem_UIBase:OnInitialize()
  CommonItem_UIBase.__super.OnInitialize(self)
end
function CommonItem_UIBase:RegistEvents()
  CommonItem_UIBase.__super.RegistEvents(self)
end
function CommonItem_UIBase:OnPostInitialize()
  CommonItem_UIBase.__super.OnPostInitialize(self)
end
function CommonItem_UIBase:OnClose()
  self._cObj_promise = nil
  CommonItem_UIBase.__super.OnClose(self)
end
function CommonItem_UIBase:UIOperation(fResolveCallback, fRejectCallback)
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
function CommonItem_UIBase:RestoreUIOperation()
  if self._cObj_promise then
    self._cObj_promise:Resolve(self)
    self._cObj_promise = nil
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CCommonItem_UIBase = class(ui_base, nil, CommonItem_UIBase)
return CCommonItem_UIBase