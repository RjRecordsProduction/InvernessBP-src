local logic_login_background = {
  ENUM_PHASE = {VERSION_UPDATE = 1, LOGIN = 2}
}
local ENUM_BG_TYPE = {
  VIDEO = 1,
  BP = 2,
  IMAGE = 3
}
local DEFAULT_BG = "/Game/UMG/Texture_200/Lobby_NoAtlas/LoginUI/Login_UIPanelBG.Login_UIPanelBG"
local DEFAULT_BLUEHOLE_BG = "/Game/Mod/Lobby/Base/Login/Texture/NoAtlas/LOGIN_image_bg_1_kr_jp_.LOGIN_image_bg_1_kr_jp_"
local DEFAULT_BP = "/Game/Mod/Lobby/Base/Login/Other/Login_UIPanelBG.Login_UIPanelBG"
local DEFAULT_JK_BP = "/Game/Mod/Lobby/Base/Login/Other/LoginKPJP_UIPanelBG.LoginKPJP_UIPanelBG"
local DEFAULT_BGM = "/Game/WwiseEvent/Music/Music_Main/Play_Music_Hall.Play_Music_Hall"
local DEFAULT_VIDEO = ""
local DEFAULT_PLAYER_MAT = "/Game/Movies/NewMediaPlayer_Video_Mat.NewMediaPlayer_Video_Mat"
local DEFAULT_PLAYER = "/Game/Movies/SGTMediaP.SGTMediaP"
local bUseVideoBackground = true
local VideoPathList, ResPath, BGMPath, TexPath, currentPhase
local tryPlayVideo = false
local cachedAssets
local InitConfig = function()
  local TimeUtil = require("client.common.time_util")
  log(bWriteLog and "[jonahwei]logic_login_background:InitConfig")
  local tableName = "LoginRes"
  ResPath = DEFAULT_BP
  TexPath = DEFAULT_BG
  BGMPath = DEFAULT_BGM
  if GlobalData.IsJapanOrKorea() then
    tableName = "LoginRes_JP"
    ResPath = DEFAULT_JK_BP
  elseif GlobalData.IsBLUEHOLE() then
    TexPath = DEFAULT_BLUEHOLE_BG
    tableName = "LoginRes_IN"
  end
  local region = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if region == PublishRegionMacros.CE or region == PublishRegionMacros.FITCE then
    return
  end
  local StringUtil = require("common.string_util")
  local cfg = CDataTable.GetTable(tableName)
  local VideoPath = ""
  local UIUtil = require("client.common.ui_util")
  local currdeviceLevel = UIUtil.GetGameInstance():GetExactDeviceLevel()
  local isLow = currdeviceLevel <= 0
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if Client.GetDevicePlatformName() == DevicePlatformNameMacros.IOS then
    isLow = currdeviceLevel <= 1
  end
  local useDefaultBP = HDmpveRemote.HDmpveRemoteConfigGetBool("DefaultLoginBackgroundBP", false)
  local useDefaultTex = HDmpveRemote.HDmpveRemoteConfigGetBool("DefaultLoginBackgroundTex", false)
  for _, info in pairs(cfg) do
    local beginTime = TimeUtil.TimeStringToUnixstamp(info.BeginTime)
    local endTime = TimeUtil.TimeStringToUnixstamp(info.EndTime)
    local curTime = TimeUtil.GetServerTimeInSec()
    if beginTime <= curTime and endTime > curTime then
      VideoPath = info.VideoPath
      BGMPath = info.BGMPath
      if not useDefaultBP then
        ResPath = info.ResPath
        if info.ResLodPath ~= "" and isLow then
          ResPath = info.ResLodPath
        end
      end
      if not useDefaultTex then
        TexPath = info.TexPath
      end
    end
  end
  if VideoPath and VideoPath ~= "" then
    VideoPathList = StringUtil.Split(VideoPath, "|")
  else
    VideoPathList = {DEFAULT_VIDEO}
  end
  if not Client.IsEditor() then
    for k, v in ipairs(VideoPathList) do
      VideoPathList[k] = string.gsub(v, "MoviesPak/", "MoviesPakDir/")
    end
  end
  tryPlayVideo = true
end
local CheckCanShowVideo = function()
  if not bUseVideoBackground then
    return false
  end
  if HDmpveRemote.HDmpveRemoteConfigGetBool("DisableLoginVideo", false) then
    return false
  end
  if not tryPlayVideo then
    return false
  end
  if not VideoPathList or #VideoPathList <= 0 then
    return false
  end
  return true
end
local GetBackGroundType = function(phase)
  if CheckCanShowVideo() then
    return ENUM_BG_TYPE.VIDEO
  else
    tryPlayVideo = false
  end
  if phase == logic_login_background.ENUM_PHASE.VERSION_UPDATE then
    return ENUM_BG_TYPE.IMAGE
  end
  if phase == logic_login_background.ENUM_PHASE.LOGIN then
    return ENUM_BG_TYPE.BP
  end
  return ENUM_BG_TYPE.IMAGE
end
local ShowBackground = function(type)
  local pak_util = require("client.common.pak_util")
  log(bWriteLog and "[jonahwei]logic_login_background:ShowBackground   type:" .. tostring(type))
  if Client.IsJaguar() and type == ENUM_BG_TYPE.BP and not pak_util.IsPufferDownloaded(ResPath) then
    log(bWriteLog and "ShowBackground.  pak_util.IsPufferDownloaded false show image")
    type = ENUM_BG_TYPE.IMAGE
  end
  if type == ENUM_BG_TYPE.VIDEO then
    UIManager.CloseUI(UIManager.UI_Config.login_background)
    if not UIManager.IsUIShow(UIManager.UI_Config.login_video) then
      UIManager.ShowUI(UIManager.UI_Config.login_video, VideoPathList)
    end
  elseif type == ENUM_BG_TYPE.BP then
    UIManager.ShowUI(UIManager.UI_Config.login_background, ENUM_BG_TYPE.BP, ResPath, BGMPath, TexPath)
    UIManager.CloseUI(UIManager.UI_Config.login_video)
  elseif type == ENUM_BG_TYPE.IMAGE then
    if not pak_util.IsFileExist(TexPath) then
      log(bWriteLog and "ShowBackground. pak_util.IsFileExist false show default image")
      TexPath = DEFAULT_BG
      local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
      if PublishRegionMacros.IsBLUEHOLE() then
        TexPath = DEFAULT_BLUEHOLE_BG
      end
    end
    UIManager.ShowUI(UIManager.UI_Config.login_background, ENUM_BG_TYPE.IMAGE, ResPath, BGMPath, TexPath)
    UIManager.CloseUI(UIManager.UI_Config.login_video)
  end
end
function logic_login_background:OnInitialize()
  logic_login_background.__super.OnInitialize(self)
  InitConfig()
end
function logic_login_background:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_LOGIN, EVENTID_LOGIN_VIDEO_CLOSE, self.UpdateBackground, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_LOADING_BEGIN, self.CloseBackground, self)
end
function logic_login_background:ShowBackground(phase)
  currentPhase = phase
  local type = GetBackGroundType(phase)
  ShowBackground(type)
end
function logic_login_background:CloseBackground()
  log(bWriteLog and "[jonahwei]logic_login_background:CloseBackground")
  UIManager.CloseUI(UIManager.UI_Config.login_background)
  UIManager.CloseUI(UIManager.UI_Config.login_video)
end
function logic_login_background:UpdateBackground()
  tryPlayVideo = false
  local type = GetBackGroundType(currentPhase)
  ShowBackground(type)
end
local AsyncLoadSingleAssetCompleted = function(path, object)
  if not path then
    return
  end
  if not slua.isValid(object) then
    return
  end
  if not cachedAssets then
    cachedAssets = {}
  end
  if cachedAssets[path] then
    return
  end
  slua.addRef(object)
  cachedAssets[path] = object
end
function logic_login_background:PreloadLoginVideoResources()
  if not CheckCanShowVideo() then
    return
  end
  if VideoPathList and next(VideoPathList) then
    local preloadAssetpaths = {DEFAULT_PLAYER_MAT, DEFAULT_PLAYER}
    local util = require("client.slua_ui_framework.util")
    for i = 1, #preloadAssetpaths do
      if not cachedAssets or not cachedAssets[preloadAssetpaths[i]] then
        util.GetAssetAsync(preloadAssetpaths[i], function(object)
          AsyncLoadSingleAssetCompleted(preloadAssetpaths[i], object)
        end)
      end
    end
  end
end
function logic_login_background:GetCachedAssetByPath(path)
  if not path then
    return nil
  end
  if not cachedAssets then
    return nil
  end
  return cachedAssets[path]
end
function logic_login_background:ClearLoadedVideoResources()
  if cachedAssets then
    for _, v in pairs(cachedAssets) do
      if slua.isValid(v) then
        slua.removeRef(v)
      end
    end
    cachedAssets = nil
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogicLoginBackground = class(CModuleBase, nil, logic_login_background)
return CLogicLoginBackground