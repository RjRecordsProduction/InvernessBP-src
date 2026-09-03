GameMasterSystem = GameMasterSystem or {sdkInited = false}
function GameMasterSystem.Init()
  if GameMasterSystem.sdkInited == false then
    GameMasterSystem.sdkInited = true
    log(bWriteLog and "GameMasterSystem.Init InitJavaFunctions")
    Client.InitJavaFunctions()
  end
end
function GameMasterSystem.GetPlayerCountryNo()
  local countryNumber = FuncUtil.GetCountryIPCode()
  return countryNumber
end
function GameMasterSystem.GetGUID()
  local guid = Client.GetGameMasterGUID()
  return guid
end
function GameMasterSystem.IsEnvVailable()
  local platName = Client.GetDevicePlatformName()
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if platName ~= DevicePlatformNameMacros.Android then
    return false
  end
  local region = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if region ~= PublishRegionMacros.GLOBAL and region ~= PublishRegionMacros.CE then
    return false
  end
  return true
end
function GameMasterSystem.GetUserId()
  local userid = Client.GameMasterGetUserID()
  if userid == nil then
    userid = ""
  end
  return userid
end
function GameMasterSystem.OpenGameMasterRechargePage()
  local redirectURL = Client.GameMasterGetWebUIUrl(7)
  redirectURL = Client.UrlEncode(redirectURL)
  local url = FuncUtil.GetDomainByID(3366036) .. "/act/a20200930xunyou/index.html?sTicket={itop_ticket}&language={language}&game_area={game_area}&region={country}&nickname={nickname}&openid={itop_openid}&area_id={areaid}&head_pic={head_pic}&gameid={gameid}"
  url = url .. "&callback=" .. redirectURL
  local webModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.webModule)
  url = webModule:AddParameterByPersonalInfo(url)
  local WebviewSDK = require("client.slua.logic.url.logic_webview_sdk")
  WebviewSDK:OpenURL(url)
end
return GameMasterSystem