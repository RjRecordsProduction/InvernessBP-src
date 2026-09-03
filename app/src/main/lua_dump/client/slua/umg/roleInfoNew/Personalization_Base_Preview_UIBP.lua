local Personalization_Base_Preview_UIBP = {}
function Personalization_Base_Preview_UIBP:ctor(_)
  self.downloadPakNames = {}
end
function Personalization_Base_Preview_UIBP:RegistEvents()
  Personalization_Base_Preview_UIBP.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_PUFFER, EVENTID_PUFFER_DOWNLOADFINISH, self.OnDownloadFinish, self)
end
function Personalization_Base_Preview_UIBP:AddDownloadResPath(path)
  log_format("Personalization_Base_Preview_UIBP:AddDownloadResPath. path=%s", path)
  if path == nil or path == "" then
    return
  end
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local pakName = PufferManager.GetPakName(path)
  if pakName ~= "" then
    self.downloadPakNames[pakName] = true
  end
end
function Personalization_Base_Preview_UIBP:OnDownloadFinish(_, _, eventData)
  if eventData == nil then
    return
  end
  local pakName = eventData.pakName
  if pakName == nil then
    return
  end
  if not self.downloadPakNames[pakName] then
    return
  end
  log_format("Personalization_Base_Preview_UIBP:OnDownloadFinish. after pakName=%s", pakName)
  self:HandlePakDownloaded(pakName)
end
function Personalization_Base_Preview_UIBP:HandlePakDownloaded(pakName)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CUITemplate = class(ui_base, nil, Personalization_Base_Preview_UIBP)
return CUITemplate