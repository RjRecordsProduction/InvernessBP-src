local UI = require("client.slua.umg.NewSetting.Sound.setting_sound_data")
function UI:CreateResDownload()
  local node_root = self.UIRoot
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local common_download_handler = require("client.slua.common.common_download_handler")
  local params = {}
  params.size = 26
  params.pos = FVector2D(4, -4)
  params.showProgress = true
  common_download_handler.CreateDownloadUIReturnUIBase(PufferConst.ENUM_DownloadType.RES, {
    "res_audiolow"
  }, self, node_root.Panel_Download_AudioLow, params)
  common_download_handler.CreateDownloadUIReturnUIBase(PufferConst.ENUM_DownloadType.RES, {
    "res_audiohigh"
  }, self, node_root.Panel_Download_AudioHigh, params)
end
function UI:GetHighAudioDownloadState()
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.RES, {
    "res_audiohigh"
  })
  return state
end
function UI:CanSetLowAudio()
  if not GameStatus.IsInLobbyOrMainCity() then
    local fileName = "res_audiolow_" .. Client.GetApplicationVersion() .. ".pak"
    if PufferDownloader.IsFileExist(GameFrontendHUD, fileName) then
      if not Client.SetSoundEffectQuality(0) then
        log_shipping_client("error PufferDownloader.OnInitReturn SetSoundEffectQuality(0) fail")
      end
      local title = LocUtil.GetLocalizeResStr(110115)
      local quality = LocUtil.GetLocalizeResStr(11376)
      local content = LocUtil.LocalizeResFormat(7636, quality)
      local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
      CommonMsgBoxMgr.Show(1, title, content)
      self.nCurSoundQuality = 0
      self:InitSoundQuality()
    else
      ShowNotice(37283)
    end
    return false
  end
  if not PufferDownloader.PufferJsonDownloadReturn then
    local fileName = "res_audiolow_" .. Client.GetApplicationVersion() .. ".pak"
    local realFileName = PufferDownloader.GetRealFilename(fileName)
    if Client.IsFileExistsWithOutPakCheck(Client.ProjectSavedDir() .. PufferDownloader.DOWNLOAD_DIR_RELATIVE .. realFileName) then
      return true
    elseif not _G.IsEditor then
      ShowNotice(301239)
      return false
    end
  end
  return true
end
function UI:CanSetHighAudio()
  if not GameStatus.IsInLobbyOrMainCity() then
    local fileName = "res_audiohigh_" .. Client.GetApplicationVersion() .. ".pak"
    if PufferDownloader.IsFileExist(GameFrontendHUD, fileName) then
      if not Client.SetSoundEffectQuality(2) then
        log_shipping_client("error PufferDownloader.OnInitReturn SetSoundEffectQuality(2) fail")
      end
      local title = LocUtil.GetLocalizeResStr(110115)
      local quality = LocUtil.GetLocalizeResStr(7637)
      local content = LocUtil.LocalizeResFormat("7636", quality)
      local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
      CommonMsgBoxMgr.Show(1, title, content)
      self.nCurSoundQuality = 2
      self:InitSoundQuality()
    else
      ShowNotice(7746)
    end
    return false
  end
  if 2 > Client.GetDeviceMaxSupportSoundEffect() then
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(1, LocUtil.GetLocalizeResStr(101001), LocUtil.GetLocalizeResStr(116006))
    return false
  end
  if not PufferDownloader.PufferJsonDownloadReturn then
    local fileName = "res_audiohigh_" .. Client.GetApplicationVersion() .. ".pak"
    local realFileName = PufferDownloader.GetRealFilename(fileName)
    if Client.IsFileExistsWithOutPakCheck(Client.ProjectSavedDir() .. PufferDownloader.DOWNLOAD_DIR_RELATIVE .. realFileName) then
      return true
    elseif not _G.IsEditor then
      ShowNotice(301239)
      return false
    end
  end
  return true
end