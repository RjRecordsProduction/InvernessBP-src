local logic_version_album = {}
function logic_version_album:DefineAndResetData()
  self.player_albums = nil
  self.addPhotoCDTime = 300
end
function logic_version_album:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_MY_VERSION_ALBUM, self.OnJumpMyVersionAlbum, self)
end
function logic_version_album:GetAlbumData(target_uid, album_id)
  if not self.player_albums then
    log(bWriteLog and "logic_version_album:GetAlbumData no player_albums")
    return nil
  end
  if not self.player_albums[target_uid] or not next(self.player_albums[target_uid]) then
    log(bWriteLog and "logic_version_album:GetAlbumData no target_uid album")
    return nil
  end
  return self.player_albums[target_uid][album_id]
end
function logic_version_album:GetAlbumCurrentBackgroundId(target_uid, album_id)
  local albumData = self:GetAlbumData(target_uid, album_id)
  if not albumData then
    log(bWriteLog and "logic_version_album:GetAlbumCurrentBackgroundId no albumData")
    return 0
  end
  local background_id = albumData.background_id or 0
  log(bWriteLog and "logic_version_album:GetAlbumCurrentBackgroundId background_id:" .. tostring(background_id))
  return background_id
end
function logic_version_album:IsUsedBackgroundId(target_uid, album_id, background_id)
  local cur_background_id = self:GetAlbumCurrentBackgroundId(target_uid, album_id)
  return cur_background_id == background_id
end
function logic_version_album:GetAlbumPhotoCount(target_uid, album_id)
  local albumData = self:GetAlbumData(target_uid, album_id)
  if not albumData or not albumData.photo_list then
    log(bWriteLog and "logic_version_album:GetAlbumPhotoCount no photo")
    return 0
  end
  log_tree(bWriteLog and "logic_version_album:GetAlbumPhotoCount photo_list:", albumData.photo_list)
  return #albumData.photo_list
end
function logic_version_album:IsAlbumFull(target_uid, album_id)
  local logic_version_album_macro = require("client.slua.logic.version_album.logic_version_album_macro")
  local photoCount = self:GetAlbumPhotoCount(target_uid, album_id)
  return photoCount >= logic_version_album_macro.MaxPhotos
end
function logic_version_album:CanShowAlbum(cfg)
  return self:IsValidVersionAlbum(cfg)
end
function logic_version_album:IsValidVersionAlbum(albumCfg)
  log_tree(bWriteLog and "logic_version_album:IsValidVersionAlbum cfg", albumCfg)
  local version_util = require("client.common.version_util")
  local ClientVersion = version_util.GetClientFormat(Client.GetAppVersion())
  local time_util = require("client.common.time_util")
  local curTime = time_util.GetServerTimeInSec()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local isBluehole = Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE
  if isBluehole and version_util.CompareVersionMain("4.0.0", albumCfg.Version) > 0 then
    return false
  end
  if version_util.CompareVersionMain(ClientVersion, albumCfg.Version) >= 0 and curTime >= time_util.TimeStringToUnixstamp(albumCfg.BeginTime) then
    log(bWriteLog and "logic_version_album:IsValidVersionAlbum true")
    return true
  end
  log(bWriteLog and "logic_version_album:IsValidVersionAlbum false")
  return false
end
function logic_version_album:IsCurrentVersionAlbum(albumCfg)
  log_tree(bWriteLog and "logic_version_album:IsCurrentVersionAlbum cfg", albumCfg)
  local version_util = require("client.common.version_util")
  local ClientVersion = version_util.GetClientFormat(Client.GetAppVersion())
  local time_util = require("client.common.time_util")
  local curTime = time_util.GetServerTimeInSec()
  if version_util.CompareVersionMain(ClientVersion, albumCfg.Version) == 0 and curTime >= time_util.TimeStringToUnixstamp(albumCfg.BeginTime) and curTime <= time_util.TimeStringToUnixstamp(albumCfg.EndTime) then
    log(bWriteLog and "logic_version_album:IsCurrentVersionAlbum true")
    return true
  end
  log(bWriteLog and "logic_version_album:IsCurrentVersionAlbum false")
  return false
end
function logic_version_album:CanEditAlbum(target_uid, album_id)
  log(bWriteLog and "logic_version_album:CanEditAlbum target_uid:" .. tostring(target_uid))
  log(bWriteLog and "logic_version_album:CanEditAlbum album_id:" .. tostring(album_id))
  if tonumber(DataMgr.roleData.uid) ~= target_uid then
    log(bWriteLog and "logic_version_album:CanEditAlbum other album")
    return false
  end
  local albumCfg = CDataTable.GetTableData("VersionAlbumControlCfg", album_id)
  if not albumCfg then
    log(bWriteLog and "logic_version_album:CanEditAlbum no albumCfg")
    return false
  end
  log(bWriteLog and "logic_version_album:CanEditAlbum check version:")
  return self:IsCurrentVersionAlbum(albumCfg)
end
function logic_version_album:CanDeleteAlbumPhoto(target_uid, album_id)
  log(bWriteLog and "logic_version_album:CanDeleteAlbumPhoto target_uid:" .. tostring(target_uid))
  log(bWriteLog and "logic_version_album:CanDeleteAlbumPhoto album_id:" .. tostring(album_id))
  if tonumber(DataMgr.roleData.uid) ~= target_uid then
    log(bWriteLog and "logic_version_album:CanDeleteAlbumPhoto other album")
    return false
  end
  local albumCfg = CDataTable.GetTableData("VersionAlbumControlCfg", album_id)
  if not albumCfg then
    log(bWriteLog and "logic_version_album:CanDeleteAlbumPhoto no albumCfg")
    return false
  end
  log(bWriteLog and "logic_version_album:CanDeleteAlbumPhoto check version:")
  return self:IsValidVersionAlbum(albumCfg)
end
function logic_version_album:AddPhotoToAlbumAuto(origin_path, thumb_path, shareSceneType)
  local photo_list = {
    [1] = {origin_path = origin_path, thumb_path = thumb_path}
  }
  log_tree(bWriteLog and "logic_version_album:AddPhotoToAlbumAuto photo_list:", photo_list)
  local album_id = self:GetEditAlbumId()
  if album_id <= 0 then
    log(bWriteLog and "logic_version_album:AddPhotoToAlbumAuto invalid album_id")
    return false
  end
  if self:IsAlbumFull(tonumber(DataMgr.roleData.uid), album_id) then
    log(bWriteLog and "logic_version_album:AddPhotoToAlbumAuto AlbumFull")
    return false
  end
  if self:IsInAddPhotoCD() then
    log(bWriteLog and "logic_version_album:AddPhotoToAlbumAuto In CD")
    return false
  end
  local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
  if PlanPH_GamePlay_Tools.IsPHomeMode() then
    log(bWriteLog and "logic_version_album:AddPhotoToAlbumAuto In PHome")
    return false
  end
  if shareSceneType == ShareSceneType.PartyInviteShare then
    log(bWriteLog and "logic_version_album:AddPhotoToAlbumAuto PartyInviteShare")
    return false
  end
  self:AddPhotosToAlbum(album_id, photo_list)
  self:SaveAddPhotoTime()
  return true
end
function logic_version_album:AddPhotosToAlbum(album_id, photoList, handler)
  local tb = {album_id = album_id, photoList = photoList}
  log_tree(bWriteLog and "logic_version_album:AddPhotosToAlbum tb:", tb)
  if album_id == 0 then
    log(bWriteLog and "logic_version_album:AddPhotosToAlbum invalid album_id")
    if handler then
      handler()
    end
    return
  end
  if not photoList or not next(photoList) then
    log(bWriteLog and "logic_version_album:AddPhotosToAlbum no photo")
    if handler then
      handler()
    end
    return
  end
  local add_photo_list = {}
  local SendAddPhotoReq = function()
    if handler then
      handler()
    end
    if not next(add_photo_list) then
      log(bWriteLog and "logic_version_album:AddPhotosToAlbum no add_photo_list")
      return
    end
    log(bWriteLog and "logic_version_album:AddPhotosToAlbum SendAddPhotoReq")
    self:send_version_album_add_photo_req(album_id, add_photo_list)
  end
  local function uploadFile(index)
    if index > #photoList then
      log(bWriteLog and "logic_version_album:AddPhotosToAlbum uploadFile over")
      SendAddPhotoReq()
      return
    end
    local origin_path = photoList[index].origin_path
    local thumb_path = photoList[index].thumb_path
    self:UploadPhoto2CDN(origin_path, thumb_path, function(success, origin_url, thumb_url)
      log(bWriteLog and "logic_version_album:AddPhotosToAlbum uploadFile result:" .. tostring(success))
      if success then
        add_photo_list[index] = {original_url = origin_url, thumbnail_url = thumb_url}
        uploadFile(index + 1)
      else
        SendAddPhotoReq()
      end
    end)
  end
  uploadFile(1)
end
function logic_version_album:UploadPhoto2CDN(origin_path, thumb_path, handler)
  local ui_moment_util = require("client.slua.umg.moment.ui_moment_util")
  local CanUsePhoto = ui_moment_util:CanUsePhoto(origin_path)
  if not CanUsePhoto then
    log(bWriteLog and "logic_version_album:UploadPhoto2CDN cannot UsePhoto")
    handler(false, nil, nil)
    return
  end
  local logic_moment_helper = require("client.slua.logic.moment.logic_moment_helper")
  local cdnDomain = logic_moment_helper.GetDomain(1)
  local ShareMgr = require("client.logic.share.share_logic")
  local HDmpveUploadConfig = require("client.slua.logic.HDmpveUpload.HDmpveUploadConfig")
  if HDmpveUploadConfig.bOpen then
    local LogicHDmpveUpload = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicHDmpveUpload)
    LogicHDmpveUpload:UploadLargeAndThumbImageByPath(origin_path, thumb_path, ShareMgr.ShareFileType.VersionAlbum, function(bSuccess, imgUrl, thumbImgUrl)
      local origin_url
      if imgUrl and imgUrl ~= "" then
        origin_url = string.sub(imgUrl, string.len(cdnDomain) + 1, string.len(imgUrl))
      end
      if bSuccess then
        local thumb_url = string.sub(thumbImgUrl, string.len(cdnDomain) + 1, string.len(thumbImgUrl))
        handler(true, origin_url, thumb_url)
      else
        handler(false, origin_url, nil)
      end
    end, {bCheckHash = false, dontShowWaitingUI = true})
    return
  end
  ShareMgr.HDmpveUploadFile(origin_path, function(isSuccess, imgUrl)
    log(bWriteLog and "logic_version_album:UploadPhoto2CDN HDmpveUploadFile1:" .. tostring(isSuccess) .. ", imgUrl:" .. tostring(imgUrl))
    if isSuccess then
      local origin_url = string.sub(imgUrl, string.len(cdnDomain) + 1, string.len(imgUrl))
      ShareMgr.HDmpveUploadFile(thumb_path, function(isSuccess2, imgUrl2)
        log(bWriteLog and "logic_version_album:UploadPhoto2CDN HDmpveUploadFile2:" .. tostring(isSuccess2) .. ", imgUrl2:" .. tostring(imgUrl2))
        if isSuccess2 then
          local thumb_url = string.sub(imgUrl2, string.len(cdnDomain) + 1, string.len(imgUrl2))
          handler(true, origin_url, thumb_url)
        else
          handler(false, origin_url, nil)
        end
      end, 0, ShareMgr.ShareFileType.VersionAlbum, true)
    else
      handler(false, nil, nil)
    end
  end, 0, ShareMgr.ShareFileType.VersionAlbum, true)
end
function logic_version_album:GetEditAlbumId()
  local version_util = require("client.common.version_util")
  local ClientVersion = version_util.GetClientFormat(Client.GetAppVersion())
  local time_util = require("client.common.time_util")
  local curTime = time_util.GetServerTimeInSec()
  local albumCfg = CDataTable.GetTable("VersionAlbumControlCfg")
  for album_id, cfg in pairs(albumCfg) do
    if version_util.CompareVersionMain(ClientVersion, cfg.Version) == 0 and curTime >= time_util.TimeStringToUnixstamp(cfg.BeginTime) and curTime <= time_util.TimeStringToUnixstamp(cfg.EndTime) then
      log(bWriteLog and "logic_version_album:GetEditAlbumId album_id:" .. tostring(album_id))
      return album_id
    end
  end
  log(bWriteLog and "logic_version_album:GetEditAlbumId default")
  return 0
end
function logic_version_album:send_version_album_query_data_req(target_uid)
  if self.player_albums and self.player_albums[target_uid] then
    log(bWriteLog and "logic_version_album:send_version_album_query_data_req have data, target_uid:" .. tostring(target_uid))
    EventSystem:postEvent(EVENTTYPE_VERSION_ALBUM, EVENTID_VERSION_ALBUM_QUERY_DATA_RSP, target_uid)
    return
  end
  local VersionAlbumHandler = require("client.network.Protocol.VersionAlbumHandler")
  VersionAlbumHandler.send_version_album_query_data_req(target_uid)
end
function logic_version_album:on_version_album_query_data_rsp(target_uid, albums)
  if not self.player_albums then
    self.player_albums = {}
  end
  self.player_albums[target_uid] = albums
  EventSystem:postEvent(EVENTTYPE_VERSION_ALBUM, EVENTID_VERSION_ALBUM_QUERY_DATA_RSP, target_uid)
end
function logic_version_album:send_version_album_move_photo_req(album_id, photo_list)
  if album_id == 0 then
    log(bWriteLog and "logic_version_album:send_version_album_move_photo_req invalid album_id")
    return
  end
  local VersionAlbumHandler = require("client.network.Protocol.VersionAlbumHandler")
  VersionAlbumHandler.send_version_album_move_photo_req(album_id, photo_list)
end
function logic_version_album:on_version_album_move_photo_rsp(album_id, photo_list)
  local albumData = self:GetAlbumData(tonumber(DataMgr.roleData.uid), album_id)
  if not albumData then
    log(bWriteLog and "logic_version_album:on_version_album_move_photo_rsp no albumData")
    return
  end
  albumData.  EventSystem:postEvent(EVENTTYPE_VERSION_ALBUM, EVENTID_VERSION_ALBUM_MOVE_PHOTO_RSP)
end
function logic_version_album:send_version_album_delete_photo_req(album_id, index, thumbnail_url, original_url)
  if album_id == 0 then
    log(bWriteLog and "logic_version_album:send_version_album_delete_photo_req invalid album_id")
    return
  end
  local VersionAlbumHandler = require("client.network.Protocol.VersionAlbumHandler")
  VersionAlbumHandler.send_version_album_delete_photo_req(album_id, index, thumbnail_url, original_url)
end
function logic_version_album:on_version_album_delete_photo_rsp(album_id, index)
  local albumData = self:GetAlbumData(tonumber(DataMgr.roleData.uid), album_id)
  if not albumData then
    log(bWriteLog and "logic_version_album:on_version_album_delete_photo_rsp no albumData")
    return
  end
  if not albumData.photo_list or not albumData.photo_list[index] then
    log(bWriteLog and "logic_version_album:on_version_album_delete_photo_rsp no photo")
    return
  end
  table.remove(albumData.photo_list, index)
  EventSystem:postEvent(EVENTTYPE_VERSION_ALBUM, EVENTID_VERSION_ALBUM_DELETE_PHOTO_RSP)
end
function logic_version_album:send_version_album_add_photo_req(album_id, add_photo_list)
  if album_id == 0 then
    log(bWriteLog and "logic_version_album:send_version_album_add_photo_req invalid album_id")
    return
  end
  local VersionAlbumHandler = require("client.network.Protocol.VersionAlbumHandler")
  VersionAlbumHandler.send_version_album_add_photo_req(album_id, add_photo_list)
end
function logic_version_album:on_version_album_add_photo_rsp(album_id, add_photo_list)
  self:InitMyAlbum(album_id)
  local myUid = tonumber(DataMgr.roleData.uid)
  local albumData = self.player_albums[myUid][album_id]
  if not albumData.photo_list then
    albumData.photo_list = {}
  end
  for _, photo in ipairs(add_photo_list) do
    table.insert(albumData.photo_list, photo)
  end
  EventSystem:postEvent(EVENTTYPE_VERSION_ALBUM, EVENTID_VERSION_ALBUM_ADD_PHOTO_RSP)
end
function logic_version_album:send_version_album_change_background_req(album_id, background_id)
  if album_id == 0 then
    log(bWriteLog and "logic_version_album:send_version_album_change_background_req invalid album_id")
    return
  end
  local VersionAlbumHandler = require("client.network.Protocol.VersionAlbumHandler")
  VersionAlbumHandler.send_version_album_change_background_req(album_id, background_id)
end
function logic_version_album:on_version_album_change_background_rsp(album_id, background_id)
  self:InitMyAlbum(album_id)
  local myUid = tonumber(DataMgr.roleData.uid)
  local albumData = self.player_albums[myUid][album_id]
  albumData.  EventSystem:postEvent(EVENTTYPE_VERSION_ALBUM, EVENTID_VERSION_ALBUM_CHANGE_BG_RSP, background_id)
end
function logic_version_album:SaveAddPhotoTime()
  log(bWriteLog and "logic_version_album:SaveAddPhotoTime")
  local time_util = require("client.common.time_util")
  local playerprefs = require("client.logic.LogicPlayerPrefs.playerprefs")
  local info = {
    lastTime = time_util.GetServerTimeInSec()
  }
  playerprefs.SaveTableToFile_N(info, playerprefs.ePlayerPrefsType.eSaveAddPhotoTime)
end
function logic_version_album:IsInAddPhotoCD()
  local playerprefs = require("client.logic.LogicPlayerPrefs.playerprefs")
  local info = playerprefs.LoadFileToTable_N(playerprefs.ePlayerPrefsType.eSaveAddPhotoTime)
  local lastTime = info and info.lastTime or 0
  local time_util = require("client.common.time_util")
  local curTime = time_util.GetServerTimeInSec()
  if curTime - lastTime < self.addPhotoCDTime then
    log(bWriteLog and "logic_version_album:IsInAddPhotoCD in CD")
    return true
  end
  log(bWriteLog and "logic_version_album:IsInAddPhotoCD not in CD")
  return false
end
function logic_version_album:InitMyAlbum(album_id)
  if not self.player_albums then
    self.player_albums = {}
  end
  local myUid = tonumber(DataMgr.roleData.uid)
  if not self.player_albums[myUid] then
    self.player_albums[myUid] = {}
  end
  if not self.player_albums[myUid][album_id] then
    self.player_albums[myUid][album_id] = {}
  end
end
function logic_version_album:OnJumpMyVersionAlbum()
  log(bWriteLog and "logic_version_album:OnJumpMyVersionAlbum")
  UIManager.ShowUI(UIManager.UI_Config.VersionAlbum_Main_My, tonumber(DataMgr.roleData.uid))
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_version_album = class(CModuleBase, nil, logic_version_album)
return Clogic_version_album