local RoleInfoBigAvatarSystem = {}
function RoleInfoBigAvatarSystem.ShowUI(profile)
  UIManager.ShowUI(UIManager.UI_Config.role_info_big_avatar, profile)
end
function RoleInfoBigAvatarSystem.CloseUI()
  UIManager.CloseUI(UIManager.UI_Config.role_info_big_avatar)
end
function RoleInfoBigAvatarSystem.IsShow()
  local isShow = UIManager.IsUIShow(UIManager.UI_Config.role_info_big_avatar)
  return isShow
end
function RoleInfoBigAvatarSystem.RefreshBigImage(url)
  url = RoleInfoBigAvatarSystem.ModifyURLToBig(url)
  if RoleInfoBigAvatarSystem.IsShow() then
    EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_BIG_AVATAR, url)
  end
end
function RoleInfoBigAvatarSystem.IsStarWithHttp(url)
  url = url or ""
  if string.find(url, "http") then
    return true
  end
  return false
end
function RoleInfoBigAvatarSystem.IsBgBgAvatarUrl(url)
  url = url or ""
  if string.find(url, "q%.qlogo%.cn") then
    return true
  end
  return false
end
function RoleInfoBigAvatarSystem.GetBgBgAvatarURL(url, size)
  url = url or ""
  size = size or 0
  local reverseUrl = string.reverse(url)
  local reverserIndex = string.find(reverseUrl, "/")
  local outURL
  if reverserIndex and 0 < reverserIndex and RoleInfoBigAvatarSystem.IsBgBgAvatarUrl(url) then
    local index = string.len(url) - reverserIndex + 1
    outURL = string.sub(url, 0, index)
    outURL = outURL .. tostring(size)
  else
    outURL = url
  end
  return outURL
end
function RoleInfoBigAvatarSystem.ModifyURLToBig(url_small)
  local url = url_small or ""
  if string.find(url, ShareSource.Facebook) ~= nil then
    url = string.gsub(url, "width=100", "width=640")
    url = string.gsub(url, "height=100", "height=640")
  elseif string.find(url, "twimg") ~= nil then
    url = string.gsub(url, "_bigger", "")
    url = string.gsub(url, "_normal", "")
  elseif string.find(url, "wx%.qlogo%.cn") ~= nil then
    url = string.gsub(url, "/132", "/0")
  elseif string.find(url, "googleusercontent") ~= nil then
    url = string.gsub(url, "sz=50", "sz=640")
    url = string.gsub(url, "s96%-c", "s640-c")
  elseif string.find(url, "discordapp") ~= nil then
    url = url .. "?size=512"
  end
  return url
end
return RoleInfoBigAvatarSystem