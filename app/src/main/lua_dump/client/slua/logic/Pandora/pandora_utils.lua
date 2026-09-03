local PandoraUtils = {}
function PandoraUtils.JumpPandoraUrl(url)
  local pandoraSystem = require("client.slua.logic.Pandora.pandora_system")
  if not pandoraSystem.CheckSysOpen() then
    return
  end
  log(bWriteLog and "PandoraUtils.JumpPandoraUrl url = " .. url)
  local StringUtil = require("common.string_util")
  local params = StringUtil.ParseURLParams(url)
  local jump_utils = require("client.logic.store.jump_utils")
  jump_utils.OpenJumpModule(BP_ENUM_MODULE_PANDORA, params)
end
function PandoraUtils.PandoraHttpJump(url, has_token)
  log(bWriteLog and "PandoraHttpJump Url : " .. tostring(url))
  local webModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.webModule)
  if has_token then
    local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
    if not webModule:CheckQuestionMark(url) and not string.find(url, "?") then
      url = url .. "?"
    end
    local activity_id = ""
    local networkType = 0
    if Client.HasActiveWifi() then
      networkType = 1
    else
      networkType = 2
    end
    local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
    local gameId = Client.GetITopGameId(NetInterface)
    local sTicket = Client.GetWebViewTicket(NetInterface)
    local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
    local canpay
    if QRcodeRestrictManager:IsRestrictUC() then
      canpay = 1
    else
      canpay = 0
    end
    local noConnChar = true
    local lastChar = string.sub(url, 0, #url)
    if lastChar ~= "?" and lastChar ~= "&" and string.find(url, "&") then
      noConnChar = false
    end
    url = webModule:AddPersonalInfoPropertyAndValue(url, "openid", tostring(DataMgr.roleData.openID), noConnChar)
    url = webModule:AddPersonalInfoPropertyAndValue(url, webModule.h5Parameter.language, webModule:GetCurrentLanguage())
    url = webModule:AddPersonalInfoPropertyAndValue(url, "sign", webModule:SignOpenidAndLanguage())
    url = webModule:AddPersonalInfoPropertyAndValue(url, "uid", DataMgr.roleData.uid)
    url = webModule:AddPersonalInfoPropertyAndValue(url, webModule.h5Parameter.game_season, UnknowPassSystem.Season)
    url = webModule:AddPersonalInfoPropertyAndValue(url, "area", 9)
    url = webModule:AddPersonalInfoPropertyAndValue(url, webModule.h5Parameter.gameid, gameId)
    url = webModule:AddPersonalInfoPropertyAndValue(url, webModule.h5Parameter.sTicket, sTicket)
    url = webModule:AddPersonalInfoPropertyAndValue(url, "activity_id", activity_id)
    url = webModule:AddPersonalInfoPropertyAndValue(url, "networkType", networkType)
    url = webModule:AddPersonalInfoPropertyAndValue(url, webModule.h5Parameter.region, tostring(login_module.sIpRegion))
    url = webModule:AddPersonalInfoPropertyAndValue(url, "game_area", ZoneSystem.GetChooseZone())
    url = webModule:AddPersonalInfoPropertyAndValue(url, "canpay", canpay)
    url = webModule:AddPersonalInfoPropertyAndValue(url, "publishRegion", Client.GetPublishRegion())
    log(bWriteLog and "AppendTokenToUrl url = (new)" .. url)
  end
  url = webModule:AddPersonalInfoPropertyAndValue(url, "never_adjust", 1)
  GlobalData.JumpWebUrl(url)
end
function PandoraUtils.Share(strTitle, strDesc, strUrl, shareType)
  log(bWriteLog and "PandoraUtils.Share(" .. strTitle .. ", " .. strDesc .. ", " .. strUrl .. ", " .. shareType .. ")")
end
function PandoraUtils.GetModuleIdByUrl(url)
  log(bWriteLog and "PandoraUtils.GetModuleIdByUrl url:" .. url)
  local StringUtil = require("common.string_util")
  local params = StringUtil.ParseURLParams(url)
  local moduleId = tonumber(params.module)
  return moduleId
end
function PandoraUtils.GetActIdByUrl(url)
  log(bWriteLog and "PandoraUtils.GetActIdByUrl url:" .. url)
  local StringUtil = require("common.string_util")
  local params = StringUtil.ParseURLParams(url)
  local actId = tonumber(params.actid)
  return actId
end
function PandoraUtils.SplitCommonItemGetData(content)
  local result = {}
  local StringUtil = require("common.string_util")
  local list = StringUtil.Split(content, ",")
  for _, v in ipairs(list) do
    local subList = StringUtil.Split(v, ":")
    if #subList == 3 then
      local data = {
        res_id = tonumber(subList[1]),
        count = tonumber(subList[2]),
        valid_hours = tonumber(subList[3])
      }
      data.itemID = data.res_id
      result[#result + 1] = data
    else
      log_error("PandoraUtils.SplitCommonItemGetData subList data is valid\239\188\129#subList != 3")
    end
  end
  return result
end
return PandoraUtils