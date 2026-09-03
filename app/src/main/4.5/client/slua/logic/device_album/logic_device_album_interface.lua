local logic_device_album_interface = {hasRegisterScreenCaptureListener = false}
function logic_device_album_interface.OnLogin()
  log(bWriteLog and "[WSL] device_album_interface:OnLogin")
  logic_device_album_interface.RegisterScreenCaptureListener()
end
function logic_device_album_interface.OnLogout()
  log(bWriteLog and "[WSL] device_album_interface:OnLogout")
  logic_device_album_interface.UnRegisterScreenCaptureListener()
end
function logic_device_album_interface.RegisterScreenCaptureListener()
  log(bWriteLog and "[WSL] device_album_interface:RegisterScreenCaptureListener")
  if not logic_device_album_interface.ScreenCaptureListenerEnabled() then
    log(bWriteLog and "[WSL] device_album_interface:RegisterScreenCaptureListener, enableScreenCaptureDetect == false")
    return
  end
  local UPhotoAlbumHelper = import("PhotoAlbumHelper")
  local UPhotoAlbumHelperInstance = UPhotoAlbumHelper.GetInstance()
  if UPhotoAlbumHelperInstance == nil then
    log(bWriteLog and "[WSL] device_album_interface:RegisterScreenCaptureListener, UPhotoAlbumHelperInstance == nil")
    return
  end
  if logic_device_album_interface.hasRegisterScreenCaptureListener then
    log(bWriteLog and "[WSL] device_album_interface:RegisterScreenCaptureListener, hasRegisterScreenCaptureListener == true")
    return
  end
  UPhotoAlbumHelperInstance.ScreenCapturedCompleteCallback:Clear()
  UPhotoAlbumHelperInstance.ScreenCapturedCompleteCallback:Add(function(retCode, retJson)
    log(bWriteLog and "[WSL] device_album_interface:RegisterScreenCaptureListener, ScreenCapturedCompleteCallback: " .. tostring(retCode) .. ", " .. retJson)
    if retCode == 0 then
      logic_device_album_interface.ReportScreenCaptureTlog()
      local ScreenShotLogUtil = RequireBlackList("blacklist.tools.ScreenShotLog.ScreenShotLogUtil")
      if ScreenShotLogUtil then
        ScreenShotLogUtil.LogScreenCaptureInfo()
      end
    end
  end)
  logic_device_album_interface.hasRegisterScreenCaptureListener = true
  local screenshotFolderNames = "screenshot,screen_shot,screen-shot,screen shot,screencapture,screen_capture,screen-capture,screen capture,screencap,screen_cap,screen-cap,screen cap,snap,\230\136\170\229\177\143"
  local screenshotMimeType = "image/png,image/jpeg"
  UPhotoAlbumHelperInstance:RegisterScreenCaptureListener(screenshotFolderNames, screenshotMimeType)
end
function logic_device_album_interface.ReportScreenCaptureTlog()
  log(bWriteLog and "logic_device_album_interface.ReportScreenCaptureTlog")
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  if SubsystemMgr then
    local BattleResultSubSystem = SubsystemMgr:Get("BattleResultSubSystem")
    if BattleResultSubSystem then
      local curBattleResultProcessCfg = BattleResultSubSystem:GetCurBattleResultProcessCfg() or {}
      local curResultProcessIndex = BattleResultSubSystem.CurResultProcessIndex
      if curResultProcessIndex and curBattleResultProcessCfg[curResultProcessIndex] and curBattleResultProcessCfg[curResultProcessIndex].ProcessName then
        local processName = curBattleResultProcessCfg[curResultProcessIndex].ProcessName
        local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
        local ModType = GameMainConfig.GetModType() or ""
        log(bWriteLog and "logic_device_album_interface.ReportScreenCaptureTlog processName = " .. tostring(processName) .. " ModType = " .. tostring(ModType))
        local reportStr = ModType .. "_" .. processName
        tlog_report_utils.ReportTLogEvent(TLogEventDefine.Screen_Capture_Report, 0, reportStr)
        return
      end
    end
  end
  log(bWriteLog and "logic_device_album_interface.ReportScreenCaptureTlog others")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.Screen_Capture_Report, 0, "Others")
end
function logic_device_album_interface.UnRegisterScreenCaptureListener()
  log(bWriteLog and "[WSL] device_album_interface:UnRegisterScreenCaptureListener")
  if not logic_device_album_interface.ScreenCaptureListenerEnabled() then
    log(bWriteLog and "[WSL] device_album_interface:UnRegisterScreenCaptureListener, enableScreenCaptureDetect == false")
    return
  end
  local UPhotoAlbumHelper = import("PhotoAlbumHelper")
  local UPhotoAlbumHelperInstance = UPhotoAlbumHelper.GetInstance()
  if UPhotoAlbumHelperInstance == nil then
    log(bWriteLog and "[WSL] device_album_interface:UnRegisterScreenCaptureListener, UPhotoAlbumHelperInstance == nil")
    return
  end
  UPhotoAlbumHelperInstance.ScreenCapturedCompleteCallback:Clear()
  UPhotoAlbumHelperInstance:UnRegisterScreenCaptureListener()
  logic_device_album_interface.hasRegisterScreenCaptureListener = false
end
function logic_device_album_interface.ScreenCaptureListenerEnabled()
  local enableScreenCaptureDetect = HDmpveRemote.HDmpveRemoteConfigGetBool("EnableScreenCaptureDetect", true)
  if not enableScreenCaptureDetect then
    return false
  end
  local Platform = Client.GetDevicePlatformName()
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if Platform == DevicePlatformNameMacros.Android then
    local device_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.device_module)
    local OSMajorVersion = device_module:GetOSMajorVersion()
    if OSMajorVersion <= 4 then
      return false
    end
  end
  local publishRegion = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if publishRegion ~= PublishRegionMacros.GLOBAL and publishRegion ~= PublishRegionMacros.CE and publishRegion ~= PublishRegionMacros.FIT and publishRegion ~= PublishRegionMacros.FITCE then
    return false
  end
  return true
end
return logic_device_album_interface