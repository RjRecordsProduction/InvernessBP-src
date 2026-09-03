local Common_Avatar_CollectLevel = {}
function Common_Avatar_CollectLevel:ctor(_, uid, collectPara)
  self._  self._extraPara = collectPara or {}
end
function Common_Avatar_CollectLevel:OnPostInitialize()
  if not self._uid then
    return
  end
  log(bWriteLog and string.format("Common_Avatar_CollectLevel:OnPostInitialize"))
  self.UIRoot.Common_Collect_Level_DynamicLoading_UIBP:InitCollectBadge(self._uid, self._extraPara.collectData, self._extraPara.showCollectTips)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CCommon_Avatar_CollectLevel = class(ui_base, nil, Common_Avatar_CollectLevel)
return CCommon_Avatar_CollectLevel