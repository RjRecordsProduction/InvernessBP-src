local Lobby_Main_City_Preload = {}
local main_city_config = require("client.slua.logic.lobby.MainCity.main_city_config")
function Lobby_Main_City_Preload.Preload()
  log(bWriteLog and "Lobby_Main_City_Preload.Preload")
  local fileStr = Client.LoadFileToString("main_city_preload.txt")
  if fileStr == "" then
    log(bWriteLog and "Lobby_Main_City_Preload.Preload no open")
    return
  end
  local Main_City_Download_Tool = require("client.slua.logic.lobby.MainCity.Main_City_Download_Tool")
  if not Main_City_Download_Tool.IsMainCityMapDownloaded() then
    log(bWriteLog and "Lobby_Main_City_Preload.Preload not download")
    return
  end
  Main_City_Download_Tool.MountMainCityMap()
  LobbySceneManager.LoadStreamLevel(true, LobbySceneManager.LEVEL_NAME.MAINCITY_MAP, nil, nil, {
    bAsync = false,
    Callback = function()
    end
  })
end
return Lobby_Main_City_Preload