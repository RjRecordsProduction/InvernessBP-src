local Switcher = {}
local USmartBearerManagerBPLibrary = import("SmartBearerManagerBPLibrary")
function Switcher.OnPostSwitch(_, _, status)
  print(bWriteLog and "Switcher.OnPostSwitch")
  if status.current == GameStatus.Fighting and not GameStatus.IsInLobbyOrMainCity() then
    Switcher.OpenSwitch()
  else
    Switcher.CloseSwitch()
  end
end
function Switcher.OpenSwitch()
  print(bWriteLog and "Switcher.OpenSwitch")
  local platformName = Client.GetDevicePlatformName()
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  local STExtraGameInstance = import("STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
  local DeviceLevel = GameInstance:GetExactDeviceLevel()
  if platformName == DevicePlatformNameMacros.Android then
    GameInstance:ExecuteCMD("r.Mobile.ParallelGatherDynamicMeshElement", 1)
    if DeviceLevel <= 0 then
      local UGameplayStatics = import("GameplayStatics")
      local sLevel = UGameplayStatics.GetCurrentLevelName(GameInstance, true)
      if sLevel ~= "SocialIsland_Main" then
        GameInstance:ExecuteCMD("Slate.EnableWidgetSizeCacheOpt", 1)
      end
      if USmartBearerManagerBPLibrary.IsSmartBearerOptSwitcherEnable(27) then
        GameInstance:ExecuteCMD("w.UnderWaterCompOpt", 1)
      end
      if USmartBearerManagerBPLibrary.IsSmartBearerOptSwitcherEnable(28) then
        GameInstance:ExecuteCMD("chara.weaponsoundopt", 1)
      end
    end
  end
  GameInstance:ExecuteCMD("r.SeparateTranslucencySupport_GamePlay", 1)
end
function Switcher.CloseSwitch()
  print(bWriteLog and "Switcher.CloseSwitch")
  local platformName = Client.GetDevicePlatformName()
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  local STExtraGameInstance = import("STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
  if platformName == DevicePlatformNameMacros.Android then
    GameInstance:ExecuteCMD("Slate.EnableWidgetSizeCacheOpt", 0)
    GameInstance:ExecuteCMD("chara.weaponsoundopt", 0)
    GameInstance:ExecuteCMD("w.UnderWaterCompOpt", 0)
    GameInstance:ExecuteCMD("r.Mobile.ParallelGatherDynamicMeshElement", 0)
  end
  GameInstance:ExecuteCMD("r.SeparateTranslucencySupport_GamePlay", 0)
end
return Switcher