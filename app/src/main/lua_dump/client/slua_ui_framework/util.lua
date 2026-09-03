local util = {bIsHighTCDevice = nil}
local local local string_format = string.format
local local local local slua_isValid = slua.isValid
local local local local local local local local StringUtil = require("common.string_util")
local SetTextureConst = require("client.slua.logic.image_download.SetTextureConst")
function util.SetTexture(control, path, params)
  if not path or path == "" then
    if control then
      control:SetBrushFromTexture(nil, false)
      return SetTextureConst.Done
    else
      log_error("util.SetTexture path is " .. tostring(path))
      return SetTextureConst.Error
    end
  end
  params = params or {}
  local sync = params.sync
  if sync == nil then
    sync = true
  end
  local bMatchSize = params.bMatchSize
  if params.onDownloadSuccess then
    local LogicLoadTexture = require("client.slua.logic.texture.logic_load_texture")
    local textureOrSprite = LogicLoadTexture.LoadTextureOrSprite(path)
    if textureOrSprite then
      params.onDownloadSuccess(textureOrSprite, path)
    elseif params.onDownloadFail then
      params.onDownloadFail(path)
    end
  end
  if not control then
    log_error(string_format("util.SetTexture control is not nil path=%s", tostring(path)))
    return SetTextureConst.Error
  end
  if type(control) ~= "table" and not slua_isValid(control) then
    log_error(string_format("util.SetTexture control is not valid path=%s, control=%s", tostring(path), tostring(control)))
    return SetTextureConst.Error
  end
  log(bWriteLog and string_format("util.SetTexture path=%s, sync=%s, bHasAddKnownMissing=%s, onDownloadSuccess=%s, control=%s, bIsInCombatState=%s", tostring(path), tostring(sync), tostring(params.bHasAddKnownMissing), tostring(params.onDownloadSuccess), tostring(control), tostring(params.bIsInCombatState)))
  if not params.bIsInCombatState then
    local Client = import("ScriptHelperClient")
    if params.bHasAddKnownMissing == nil then
      local pak_util = require("client.common.pak_util")
      if not pak_util.IsTextureDownloadedByPath(path, true) then
        log(bWriteLog and " util.SetTexture >>> _SetDefaultIcon params.defaultIcon = " .. tostring(params.defaultIcon))
        util._SetDefaultIcon(control, params.defaultIcon, bMatchSize, true)
        if slua_isValid(control) then
          Client.AddKnownMissingPackage(path, control, true)
        end
        return SetTextureConst.Streaming
      end
    end
    if not params.bHasAddKnownMissing and slua_isValid(control) and Client.RemoveKnownMissingPackageRefObjectByObj then
      Client.RemoveKnownMissingPackageRefObjectByObj(control)
    end
  end
  if sync then
    if control.SetBrushResourceFromPathSync then
      control:SetBrushResourceFromPathSync(path, bMatchSize or false)
    end
  else
    util._SetDefaultIcon(control, params.defaultIcon, bMatchSize, true)
    control:SetBrushFromPathAsync(path, bMatchSize == true)
  end
  return SetTextureConst.Done
end
function util._SetDefaultIcon(widget, defaultIcon, bMatchSize, bAsync)
  if not widget then
    return
  end
  if type(widget) ~= "table" and not slua_isValid(widget) then
    return
  end
  if defaultIcon then
    if defaultIcon ~= "" then
      widget:SetBrushResourceFromPathSync(defaultIcon, bMatchSize or false)
    else
      widget:SetBrushFromTexture(nil, bMatchSize or false)
    end
  elseif bAsync then
    widget:SetBrushFromTexture(nil, bMatchSize or false)
  else
    local UIUtil = require("client.common.ui_util")
    defaultIcon = UIUtil.GetDefaultIcon()
    if defaultIcon ~= "" then
      widget:SetBrushResourceFromPathSync(defaultIcon, bMatchSize or false)
    else
      widget:SetBrushFromTexture(nil, bMatchSize or false)
    end
  end
end
local function BPObjectToTableRecursive(bpObject, data)
  local meta = getmetatable(bpObject)
  if meta[".get"] ~= nil then
    for k, _ in pairs(meta[".get"]) do
      local v = bpObject[k]
      local typeOfValue = type(v)
      if typeOfValue == "number" or typeOfValue == "boolean" or typeOfValue == "boolean" or typeOfValue == "string" then
        data[k] = v
      elseif typeOfValue == "userdata" or typeOfValue == "table" then
        local childData = {}
        data[k] = childData
        BPObjectToTableRecursive(v, childData)
      end
    end
    return
  end
  for k, v in pairs(bpObject) do
    local typeOfValue = type(v)
    if typeOfValue == "number" or typeOfValue == "boolean" or typeOfValue == "boolean" or typeOfValue == "string" then
      data[k] = v
    elseif typeOfValue == "userdata" or typeOfValue == "table" then
      local childData = {}
      data[k] = childData
      BPObjectToTableRecursive(v, childData)
    end
  end
end
function util.BPObjectToTable(bpObject, data)
  assert(type(bpObject) == "userdata", string_format("Parameter bpObject must be userdata but %s!", type(bpObject)))
  assert(data ~= nil, "Parameter data must not be nil!")
  local TimeUtil = require("client.common.time_util")
  local preTime = TimeUtil.GetMiliseconds()
  BPObjectToTableRecursive(bpObject, data)
  print(bWriteLog and "BPObjectToTable take time:", TimeUtil.GetMiliseconds() - preTime)
  return data
end
local function TableToBPObjectRecursive(data, bpObject)
  local meta = getmetatable(bpObject)
  for k, v in pairs(data) do
    local typeOfValue = type(v)
    if meta.__name == "LuaMap" then
      local childObject = bpObject:CreateValueTypeObject()
      if type(childObject) == "userdata" or type(childObject) == "table" then
        TableToBPObjectRecursive(v, childObject)
      else
        childObject = v
      end
      bpObject:Add(k, childObject)
    elseif meta.__name == "LuaArray" then
      local childObject = bpObject:CreateValueTypeObject()
      if type(childObject) == "userdata" or type(childObject) == "table" then
        TableToBPObjectRecursive(v, childObject)
      else
        childObject = v
      end
      if k == 0 then
        bpObject:Insert(0, childObject)
      else
        bpObject:Add(childObject)
      end
    elseif bpObject[k] ~= nil then
      local childMeta = getmetatable(bpObject[k])
      if childMeta and childMeta[".get"] ~= nil then
        local childData = _G[childMeta.__name]()
        TableToBPObjectRecursive(v, childData)
        bpObject[k] = childData
      elseif typeOfValue == "number" or typeOfValue == "boolean" or typeOfValue == "boolean" or typeOfValue == "string" then
        bpObject[k] = v
      elseif typeOfValue == "userdata" or typeOfValue == "table" then
        TableToBPObjectRecursive(v, bpObject[k])
      end
    else
      log_warning(string_format("bpObject has no key:%s", tostring(k)))
    end
  end
end
function util.TableToBPObject(data, bpObject)
  assert(data ~= nil, "Parameter data must not be nil!")
  assert(type(bpObject) == "userdata", string_format("Parameter bpObject must be userdata but %s!", type(bpObject)))
  TableToBPObjectRecursive(data, bpObject)
  return bpObject
end
local C_DownLoad_Try_Max_Count = 3
function util.NewLoadImage(data, onSuccess, onFail)
  if not data.sImgUrl or data.sImgUrl == "" or not data.widget then
    return
  end
  if data.bNeedLocalize then
    data.sImgUrl = util.GetUrlByLanguage(data.sImgUrl)
  end
  if util.IsOnlineImageUrl(data.sImgUrl) then
    data.nDownloadTryCount = 0
    data.nTryCountMax = data.nTryCountMax or C_DownLoad_Try_Max_Count
    local image_download_mgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.image_download_mgr)
    local texture = image_download_mgr:GetLocalImageCache(data.sImgUrl)
    if texture then
      data.widget:SetBrushFromTexture(texture, false)
      data.widget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    else
      if data.bIsHideInBeginning then
        data.widget:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
      end
      do
        local ondownloadsuccess = function(texture)
          if data.widget and slua_isValid(data.widget) and texture and slua_isValid(texture) then
            data.widget:SetBrushFromTexture(texture, false)
            data.widget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
          end
          if data.successCallFunc then
            data.successCallFunc()
          end
          if onSuccess then
            onSuccess(data)
          end
        end
        local function ondownloadfail()
          data.nDownloadTryCount = data.nDownloadTryCount + 1
          log(bWriteLog and string_format("image_download_mgr:DownloadImageForBase:Download texture[%s] failed, failed times = %d", data.sImgUrl, data.nDownloadTryCount))
          if data.nTryCountMax > data.nDownloadTryCount then
            image_download_mgr:DownloadImageByHttpWrapper(data.sImgUrl, ondownloadsuccess, ondownloadfail)
            return
          end
          if onFail then
            onFail(data)
          end
        end
        image_download_mgr:DownloadImageByHttpWrapper(data.sImgUrl, ondownloadsuccess, ondownloadfail)
      end
    end
  else
    util.SetTexture(data.widget, data.sImgUrl, {sync = true})
  end
end
function util.IsOnlineImageUrl(url)
  if StringUtil.Starts(url, "http://") or StringUtil.Starts(url, "https://") or StringUtil.Starts(url, " http://") or StringUtil.Starts(url, " https://") then
    return true
  end
  return false
end
function util.GetUrlByLanguage(url)
  local LanguageMacros = require("client.slua.config.ClientMacros.LanguageMacros")
  local lan = Client.GetCurrentLanguage()
  if lan == LanguageMacros.EN then
    return url
  end
  if StringUtil.StrFind(url, "_en") then
    url = string.gsub(url, "_en", "_" .. lan)
  end
  return url
end
function util.GetUrlByRegion(url)
  if not url or type(url) ~= "string" or url == "" then
    return ""
  end
  if not util.IsOnlineImageUrl(url) then
    return url
  end
  local region = FuncUtil.GetAccountRegionForBP() or ""
  local path, query = url:match("^([^?]+)(.*)$")
  if path then
    local base, ext = path:match("^(.*)(%..+)$")
    local suffix = region and "_" .. region or ""
    return (ext and base .. suffix .. ext or path .. suffix) .. (query or "")
  end
end
function util.GetAssetAsync(AssetsPath, Callback, ...)
  if not AssetsPath or AssetsPath == "" then
    log_error("util.GetAssetAsync path empty")
    return
  end
  local asset_util = require("common.asset_util")
  local HandleID = asset_util.GetAssetAsync(AssetsPath, Callback, ...)
  return HandleID
end
function util.ClearAssetAsync(HandleID)
  local asset_util = require("common.asset_util")
  asset_util.CancelAssetAsync(HandleID)
end
function util.SetAnchors(widget, minX, minY, maxX, maxY)
  if not assert(widget ~= nil, "widget == nil") then
    return
  end
  if widget.Slot.SetAnchors then
    local anchors = FAnchors(minX, minY, maxX, maxY)
    widget.Slot:SetAnchors(anchors)
  else
    log_warning("SetAnchors failed! Because widget.Slot.SetAnchors is nil")
  end
end
function util.SetAlignment(widget, x, y)
  if not assert(widget ~= nil, "widget == nil") then
    return
  end
  if widget.Slot and widget.Slot.SetAlignment then
    local align = FVector2D(x, y)
    widget.Slot:SetAlignment(align)
  else
    log_warning("SetAlignment failed! Because widget.Slot.SetAnchors is nil")
  end
end
function util.SetOffsets(widget, left, top, right, bottom)
  if not assert(widget ~= nil, "widget == nil") then
    return
  end
  if widget.Slot and widget.Slot.SetOffsets then
    local margin = FMargin(left, top, right, bottom)
    widget.Slot:SetOffsets(margin)
  else
    log_warning("SetOffsets failed! Because widget.Slot.SetOffsets is nil")
  end
end
function util.SetPosition(widget, x, y)
  if not assert(widget ~= nil, "widget == nil") then
    return
  end
  if widget.Slot and widget.Slot.SetPosition then
    local pos = FVector2D(x, y)
    widget.Slot:SetPosition(pos)
  else
    log_warning("SetPosition failed! Because Slot.SetPosition is nil")
  end
end
function util.ShowShare(shareCfg, childUiCfg, ...)
  if Client.IsMatchVersion and Client.IsMatchVersion() then
    ShowNotice(23579)
    return false
  end
  util.ShowShareWithUICfg(UIManager.UI_Config.share_component, shareCfg, childUiCfg, ...)
end
function util.ShowShareWithUICfg(uiCfg, shareCfg, childUiCfg, ...)
  UIManager.ShowUI(uiCfg, shareCfg, childUiCfg, ...)
end
local ProfileTimeMap = {}
function util.StartProfile(key)
  local TimeUtil = require("client.common.time_util")
  if key and ProfileTimeMap[key] == nil then
    ProfileTimeMap[key] = {}
    ProfileTimeMap[key].InTime = TimeUtil.GetMiliseconds()
  end
end
function util.StopProfile(key)
  local TimeUtil = require("client.common.time_util")
  if key and ProfileTimeMap[key] then
    local inTime = ProfileTimeMap[key].InTime
    if inTime then
      local runTime = TimeUtil.GetMiliseconds() - inTime
      log(bWriteLog and "Profile Time:" .. key .. ",time:" .. tostring(runTime))
    end
    ProfileTimeMap[key] = nil
  end
end
local PointProfileTimeMap = {}
local PointProfileTotalMap = {}
function util.StartProfilePoint(key)
  local TimeUtil = require("client.common.time_util")
  if key and ProfileTimeMap[key] == nil then
    PointProfileTimeMap[key] = {}
    PointProfileTimeMap[key].InTime = TimeUtil.GetMiliseconds()
  end
end
function util.StopProfilePoint(key)
  local TimeUtil = require("client.common.time_util")
  if key and PointProfileTimeMap[key] then
    local inTime = PointProfileTimeMap[key].InTime
    if inTime then
      local runTime = TimeUtil.GetMiliseconds() - inTime
      if PointProfileTotalMap[key] == nil then
        PointProfileTotalMap[key] = 0
      end
      PointProfileTotalMap[key] = PointProfileTotalMap[key] + runTime
    end
    PointProfileTimeMap[key] = nil
  end
end
function util.PrintPointProfileTotalMap()
  for key, value in pairs(PointProfileTotalMap) do
    log(bWriteLog and "Profile point Time:" .. key .. ",time:" .. tostring(value))
  end
  PointProfileTotalMap = {}
end
function util.ConvertCountryIDToDes(CountryID)
  if CountryID == nil then
    return "EN"
  end
  local StringUtil = require("common.string_util")
  local ids = StringUtil.Split(tostring(CountryID), ",")
  local table = CDataTable.GetTable("micLangTable")
  for k, v in pairs(table) do
    for _k, _v in pairs(ids) do
      if _v == v.id then
        return v.des
      end
    end
  end
  return CountryID
end
function util.SetMicImage(imageMic, mic_level)
  local data = CDataTable.GetTableData("micLevelTable", mic_level)
  if mic_level ~= 0 and data and data.imagePath then
    imageMic:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    util.SetTexture(imageMic, data.imagePath)
    return
  end
  imageMic:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function util.GetTextBLockLanguageText(micLevel, lang)
  if micLevel ~= 0 then
    log(bWriteLog and "god test lang 1 " .. lang)
    return util.ConvertCountryIDToDes(lang)
  else
    return ""
  end
end
function util.SetMicImageNew(imageMic, mic_level)
  local data = CDataTable.GetTableData("micLevelTable", mic_level)
  if mic_level ~= 0 and data and data.imagePath then
    util.SetTexture(imageMic, data.imagePath)
    return true
  end
  return false
end
function util.SetTexture5s(control, textureOrSprite, bMatchSize)
  if Client.IsIPhoneFiveS(GameFrontendHUD) then
    control:SetRenderScale(FVector2D(2, 1))
  end
  control:SetBrushFromTexture(textureOrSprite, bMatchSize)
end
function util.IsHighTCDevice()
  if util.bIsHighTCDevice ~= nil then
    return util.bIsHighTCDevice
  end
  local UIUtil = require("client.common.ui_util")
  local DeviceLevel = UIUtil.GetGameInstance():GetDeviceLevel()
  local TCDeviceLevel = Client.GetTCDeviceLevel()
  log(bWriteLog and "util.IsHighTCDevice DeviceLevel=" .. tostring(DeviceLevel) .. " TCDeviceLevel:" .. tostring(TCDeviceLevel))
  if DeviceLevel < 2 then
    util.bIsHighTCDevice = false
    return util.bIsHighTCDevice
  end
  if TCDeviceLevel < 8 then
    util.bIsHighTCDevice = false
    return util.bIsHighTCDevice
  end
  util.bIsHighTCDevice = true
  return util.bIsHighTCDevice
end
return util