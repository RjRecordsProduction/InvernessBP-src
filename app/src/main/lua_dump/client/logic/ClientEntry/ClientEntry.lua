local Init = function()
  local regist_events = require("common.regist_events")
  regist_events.Init(require("client.slua.config.event.event"))
  local click_sound = require("client.slua.common.click_sound")
  click_sound.Init()
  local CacheCPPApii = require("client.slua.common.CacheCPPApi")
  CacheCPPApii.Init()
end
Init()