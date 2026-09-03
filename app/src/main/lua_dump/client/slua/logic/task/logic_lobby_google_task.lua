local logic_lobby_google_task = {}
function logic_lobby_google_task:OnInitialize()
  log(bWriteLog and "logic_lobby_google_task:OnInitialize")
  logic_lobby_google_task.__super.OnInitialize(self)
  self.bServerSwitch = nil
  self.bSDKValid = nil
  self.bSDKLoaded = nil
end
function logic_lobby_google_task:proc_show_google_task_rsp(needShow)
  log(bWriteLog and "logic_lobby_google_task:proc_show_google_task_rsp needShow = " .. tostring(needShow))
  self.bServerSwitch = needShow
end
function logic_lobby_google_task:CanShow()
  log(bWriteLog and "logic_lobby_google_task:CanShow")
  if not self.bServerSwitch then
    log(bWriteLog and "logic_lobby_google_task:CanShow 1")
    return false
  end
  local AdvertiseSdk = require("client.logic.advertise.logic_advertise_sdk")
  if self.bSDKValid == nil then
    log(bWriteLog and "logic_lobby_google_task:CanShow 2")
    self.bSDKValid = AdvertiseSdk:IsAdvertiseVaild()
  end
  if not self.bSDKValid then
    log(bWriteLog and "logic_lobby_google_task:CanShow 3")
    return false
  end
  self.bSDKLoaded = AdvertiseSdk:IsAdvertiseLoaded()
  if not self.bSDKLoaded then
    log(bWriteLog and "logic_lobby_google_task:CanShow 4")
    return false
  end
  log(bWriteLog and "logic_lobby_google_task:CanShow 5")
  return true
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_lobby_google_task = class(CModuleBase, nil, logic_lobby_google_task)
return Clogic_lobby_google_task