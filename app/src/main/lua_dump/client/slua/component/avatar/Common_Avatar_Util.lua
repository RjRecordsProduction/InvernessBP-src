local Common_Avatar_Util = {}
local local StringUtil = require("common.string_util")
local SNormal = "width=100&height=100"
local SIcon40 = "width=40&height=40"
function Common_Avatar_Util.GetSmallIcon(url)
  local isFb = string.find(url, SNormal)
  if isFb then
    return StringUtil.StrReplace(url, SNormal, SIcon40)
  else
    local revStr = string.reverse(url)
    local _, endPos = string.find(revStr, "/", 1, true)
    if endPos ~= nil then
      return string.sub(url, 1, string.len(revStr) - endPos + 1) .. "40"
    end
    return url
  end
end
function Common_Avatar_Util.DownloadAvatar(uiBase, widget, path, successCallback, params)
  params = params or {}
  params.onDownloadSuccess = successCallback
  function params.onDownloadFail()
    local params1 = {}
    params1.AvatarIconOriginUrl = path
    params1.onDownloadSuccess = successCallback
    local miniIconUrl = Common_Avatar_Util.GetSmallIcon(path)
    log(bWriteLog and "Common_Avatar_All_UIBP:DownloadAvatar try again: " .. miniIconUrl)
    uiBase:SetTexture(widget, miniIconUrl, params1)
  end
  return uiBase:SetTexture(widget, path, params)
end
return Common_Avatar_Util