local AkAudioMonitor = import("AkAudioMonitor")
local audio_system = {}
function audio_system:OnInitialize()
  audio_system.__super.OnInitialize(self)
  self.MonitorData = AkAudioMonitor.GetMonitorDataPtr()
  if Client.IsDevelopment() then
    log(bWriteLog and "audio_system:OnInitialize, Client and not Client.IsDevelopment(). ")
    AkAudioMonitor.SetMonitorFlag({65535}, 50, 10)
  end
end
function audio_system:AkAudioEventTrigger(name, code)
  log(bWriteLog and string.format("audio_system:AkAudioEventTrigger, name, code:%s, %d", name, code))
  EventSystem:postEvent(EVENTTYPE_SOUND, EVENTID_AUDIO_EVENT_STATUS_CHANGED, name, code)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Caudio_system = class(CModuleBase, nil, audio_system)
return Caudio_system