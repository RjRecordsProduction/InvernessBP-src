VersionUpdater = VersionUpdater or {
  bEnableUseCDNUpdate = true,
  bUseDolphinUpdateAfterCDNFailed = false,
  bUseCDNUpdateAfterDolphinFailed = true,
  cdnUpdate_domain = FuncUtil.GetDomainByID(3366005) .. "/igm/",
  cdndownload_retryTimes = 3,
  cdndownload_retryDelayTime = 2,
  dolphinUpdaterErrorCode = 0
}
function VersionUpdater.StartUpdate()
end
function VersionUpdater.CancelUpdate()
end
function VersionUpdater.OnVersionUpdate(verinfo)
end
function VersionUpdater.OnUpdateEnd(Successful, needRestart)
end
function VersionUpdater.OnUpdateProcess(stage, percent, finished)
end
function VersionUpdater.GetStageString(curStage)
  local stageString = {
    [69] = "GetingVerInfo",
    [10] = "extract first resource",
    [71] = "download apk-update config",
    [72] = "download apk-update diff file",
    [73] = "Downloading",
    [74] = "CheckDownload",
    [75] = "check local apk",
    [76] = "check apk-update config",
    [77] = "check apk-update diff file",
    [78] = "create apk file",
    [79] = "check download apk file",
    [91] = "download src-update config",
    [92] = "prepare src-update",
    [93] = "src-update analyse diff",
    [94] = "download src-update file",
    [95] = "Extraing",
    [99] = "success",
    [100] = "failed"
  }
  if stageString[curStage] ~= nil then
    return stageString[curStage]
  end
  return "updating"
end
function VersionUpdater.GetChannelDir(curChannel)
  local dirString = {
    [48] = "live/global/ios/",
    [46] = "live/global/ios_5s_shipping/",
    [43] = "live/global/ios_5s_dev/",
    [47] = "live/global/android/",
    [59] = "live/global/android_samsung/",
    [122] = "live/global/android_multichannel/",
    [180] = "live/global/android_amazon/",
    [231] = "live/global/android_hms/",
    [33] = "preupdate/global/ios/",
    [45] = "preupdate/global/ios_5s_shipping/",
    [44] = "preupdate/global/ios_5s_dev/",
    [32] = "preupdate/global/android/",
    [60] = "preupdate/global/android_samsung/",
    [123] = "preupdate/global/android_multichannel/",
    [181] = "preupdate/global/android_amazon/",
    [232] = "preupdate/global/android_hms/",
    [30] = "trunk/global/windows/",
    [29] = "trunk/global/ios/",
    [36] = "trunk/global/ios_5s_shipping/",
    [35] = "trunk/global/ios_5s_dev/",
    [28] = "trunk/global/android/",
    [62] = "trunk/global/android_samsung/",
    [124] = "trunk/global/android_multichannel/",
    [183] = "trunk/global/android_amazon/",
    [234] = "trunk/global/android_hms/",
    [3091] = "live/kr/ios/",
    [3092] = "live/kr/ios_5s_shipping/",
    [3093] = "live/kr/ios_5s_dev/",
    [3090] = "live/kr/android/",
    [3098] = "live/kr/android_samsung/",
    [3095] = "preupdate/kr/ios/",
    [3097] = "preupdate/kr/ios_5s_shipping/",
    [3096] = "preupdate/kr/ios_5s_dev/",
    [3094] = "preupdate/kr/android/",
    [3099] = "preupdate/kr/android_samsung/",
    [3087] = "trunk/kr/ios/",
    [3089] = "trunk/kr/ios_5s_shipping/",
    [3088] = "trunk/kr/ios_5s_dev/",
    [3086] = "trunk/kr/android/",
    [3100] = "trunk/kr/android_samsung/",
    [54] = "ce/global/ios/",
    [55] = "ce/global/ios_5s_shipping/",
    [49] = "ce/global/android/",
    [119] = "live/vng/ios/",
    [121] = "live/vng/ios_5s_shipping/",
    [117] = "live/vng/android/",
    [118] = "preupdate/vng/ios/",
    [120] = "preupdate/vng/ios_5s_shipping/",
    [116] = "preupdate/vng/android/",
    [125] = "trunk/vng/ios/",
    [126] = "trunk/vng/ios_5s_dev/",
    [127] = "trunk/vng/android/",
    [138] = "live/tw/ios/",
    [141] = "live/tw/ios_5s_shipping/",
    [137] = "live/tw/android/",
    [144] = "preupdate/tw/ios/",
    [145] = "preupdate/tw/ios_5s_shipping/",
    [143] = "preupdate/tw/android/"
  }
  if dirString[curChannel] ~= nil then
    return dirString[curChannel]
  end
  return ""
end
function VersionUpdater.StartCDNUpdate(code)
  log(bWriteLog and "HDmpve update failed, will start cdn update: " .. tostring(VersionUpdater.bUseCDNUpdateAfterDolphinFailed))
  log(bWriteLog and "bEnableUseCDNUpdate=" .. tostring(VersionUpdater.bEnableUseCDNUpdate))
  log(bWriteLog and "bUseDolphinUpdateAfterCDNFailed=" .. tostring(VersionUpdater.bUseDolphinUpdateAfterCDNFailed))
  log(bWriteLog and "bUseCDNUpdateAfterDolphinFailed=" .. tostring(VersionUpdater.bUseCDNUpdateAfterDolphinFailed))
  if VersionUpdater.bEnableUseCDNUpdate and VersionUpdater.bUseCDNUpdateAfterDolphinFailed then
    log(bWriteLog and "hasRetried712 is true, start CDNUpdate after dolphinUpdate failed")
    VersionUpdater.StartCDNUpdateAfterDolphinUpdateFailed()
    return true
  end
  log(bWriteLog and "HDmpve update failed\239\188\140but bUseCDNUpdateAfterDolphinFailed equals false.")
  return false
end
function VersionUpdater.StartCDNUpdateAfterDolphinUpdateFailed()
  log(bWriteLog and "VersionUpdater.StartCDNUpdateAfterDolphinUpdateFailed")
  Client.StartCDNUpdateAfterDolphinUpdateFailed(GameFrontendHUD)
end