local logic_maincity_download = {}
function logic_maincity_download:OnInitialize()
  log(bWriteLog and "logic_maincity_download:OnInitialize")
end
function logic_maincity_download:OnDestroy()
  log(bWriteLog and "logic_maincity_download:OnDestroy")
end
function logic_maincity_download:RegistEvents()
  log(bWriteLog and "logic_maincity_download:RegistEvents")
  self:AddCommonEvent(EVENTTYPE_MAIN_CITY_LOBBY, EVENTID_MAIN_CITY_ENTER, self.OnEnterMainCity, self)
  self:AddCommonEvent(EVENTTYPE_MAIN_CITY_LOBBY, EVENTID_MAIN_CITY_RETURN_TO_LOBBY, self.OnLeaveMainCity, self)
  self:AddCommonEvent(EVENTTYPE_MAIN_CITY_LOBBY, EVENTID_MAINCITY_PLAYER_CHARACTER_ADD_LOBBY, self.OnAddChar, self)
  self:AddCommonEvent(EVENTTYPE_MAIN_CITY_LOBBY, EVENTID_MAINCITY_PLAYER_CHARACTER_REMOVE_LOBBY, self.OnRemoveChar, self)
  self:AddCommonEvent(EVENTTYPE_PUFFER, EVENTID_PUFFER_DOWNLOADFINISH, self.OnPufferDownloadFinish, self)
end
function logic_maincity_download:OnEnterMainCity()
  log(bWriteLog and "logic_maincity_download:OnEnterMainCity")
  self:UpdateMainCitySmartDownload()
end
function logic_maincity_download:OnLeaveMainCity()
  log(bWriteLog and "logic_maincity_download:OnLeaveMainCity")
  self:UpdateMainCitySmartDownload()
end
function logic_maincity_download:OnAddChar()
  log(bWriteLog and "logic_maincity_download:OnAddChar")
  self:UpdateMainCitySmartDownload()
end
function logic_maincity_download:OnRemoveChar()
  log(bWriteLog and "logic_maincity_download:OnRemoveChar")
  self:UpdateMainCitySmartDownload()
end
function logic_maincity_download:OnPufferDownloadFinish(eventType, eventID, data)
  printf("logic_maincity_download:OnPufferDownloadFinish.")
  local PufferConst = require("client.slua.logic.download.puffer_const")
  if data.downloadType ~= PufferConst.ENUM_DownloadType.MAP or data.pakName == nil then
    return
  end
  local PufferMapManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_map_manager)
  local mapKey = "map_planph_3"
  if PufferMapManager:GetMapPakName(mapKey) ~= data.pakName then
    return
  end
  PufferMapManager:MountMapPak(mapKey)
end
function logic_maincity_download:UpdateMainCitySmartDownload()
  if not Client then
    return
  end
  local PufferSwitch = require("client.slua.logic.download.puffer_switch")
  PufferSwitch.UpdateMainCitySmartDownload()
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
return class(CModuleBase, nil, logic_maincity_download)