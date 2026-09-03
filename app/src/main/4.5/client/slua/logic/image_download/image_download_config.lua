local image_download_config = {
  MaxDownloadNum = 5,
  strRootDir = "image_download_mgr",
  strShortTermRootDir = "image_download_mgr/temporary",
  strSubDir = "imgdownload_",
  thumbImageName = "_thumb",
  EnumImageDownloadStatus = {Waiting = 1, Downloading = 2},
  EnumHttpQueueType_ImageDownload = 1,
  EnumDiskCacheType = {
    DailyUpdate = 1,
    WeeklyUpdate = 2,
    VersionUpdate = 3,
    NeverDelete = 4
  },
  CacheTypeDirName = {
    [1] = "Daliy",
    [2] = "Weekly",
    [3] = "Version",
    [4] = ""
  },
  CacheTypeSeconds = {
    [1] = 86400,
    [2] = 604800,
    [3] = -1,
    [4] = -1
  },
  bCheckModeSwitchDownload = true,
  DisableWebpURLPrefixes = {},
  bShowDetailLog = false,
  bOpenDiskLoadStack = true,
  DiskLoadNumOneFrame = 1,
  DiskStartIndex = 65535
}
return image_download_config