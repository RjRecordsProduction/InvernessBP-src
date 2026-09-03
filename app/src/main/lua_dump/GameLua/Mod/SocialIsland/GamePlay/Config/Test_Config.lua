local Test_Config = {
  bOpenSimulate = false,
  bConnectLobbySvr = false,
  bAutoConnectLobbySvr = false,
  bEnableSingleRacing = 0,
  PlayerStartGroupId = 2,
  HomeStoreSwitchOpen = true,
  nSpinAcceMode = "sss",
  bLocalEditorShowSeq = false,
  bLocalEditorShowGuideSlap = false,
  bLocalEditorOpenPet = false
}
local serverList
local initServerList = function()
  if serverList then
    return
  end
  serverList = {}
  local str = Client.LoadFileToString("serverList.txt")
  local key = Client.GetSpecialData()
  local StringUtil = require("common.string_util")
  str = StringUtil.EncodeXOR(str, false, key)
  str = json.decode(str)
  local arrList = {}
  for index = 1, #str do
    local serverObj = str[index]
    if serverObj.region == "ALL" or serverObj.region == "GL" then
      serverList[serverObj.name] = serverObj.addr[1]
    end
  end
end
function Test_Config:OnConnectLobbySvr(uid)
  printf("Test_Config:OnConnectLobbySvr uid:%d", uid)
  local NetManager = require("client.network.comm.NetManager")
  NetManager.SendPkg(801897474, "gm_no_llm_edit_aes()")
end
function Test_Config:ConnectLobbySvr(explicitServerName)
  initServerList()
  local ip
  local serverName = explicitServerName
  local matchedServers = {}
  for k, v in pairs(serverList) do
    if string.find(k, serverName) then
      matchedServers[k] = v
    end
  end
  local shortestName
  for k, v in pairs(matchedServers) do
    if shortestName == nil or string.len(k) < string.len(shortestName) then
      shortestName = k
      ip = v
    end
  end
  if shortestName then
    serverName = shortestName
  end
  assert(ip, "can't find serverName in serverList")
  if not Test_Config._firstConnectLobbySvr then
    Test_Config._firstConnectLobbySvr = true
    local preOnconnect = NetUtil.OnConnected
    function NetUtil.OnConnected(isConnected, nReason)
      preOnconnect(isConnected, nReason)
      if isConnected then
        Test_Config.bConnectLobbySvr = true
        local time_ticker = require("common.time_ticker")
        time_ticker.AddTimer(2.0, function()
          local uid = DataMgr.roleData.uid
          ShowNotice(" lobby server connect success ...serverName:" .. serverName .. " uid:" .. uid)
          self:OnConnectLobbySvr(uid)
        end)
        local logic_gm_server = RequireBlackList("blacklist.slua.logic.lobby_gm.logic_gm_server")
        if logic_gm_server then
          logic_gm_server._cur_server = serverName
        end
        EventSystem:postEvent(EVENTTYPE_SOCIAL_ISLAND, EVENTID_ISLAND_EDITOR_ON_LOBBY_CONNECT)
      else
        Test_Config.bConnectLobbySvr = false
        ShowNotice("lobby server connect failed ...serverName:" .. serverName .. " ip:" .. ip)
      end
    end
  end
  NetUtil.ConnectToURL(ip)
  local NetManager = require("client.network.comm.NetManager")
  NetManager.Init()
  local logic_manager = require("client.logic.common.logic_manager")
  logic_manager.Init()
  function NetUtil.CheckTime()
  end
  function NetManager.checkTimeHandler()
  end
  local time_ticker = require("common.time_ticker")
  time_ticker.AddTimer(3.0, function()
    logic_connection_waiting:Hide(1)
  end)
end
function Test_Config.GetOpenSimulate()
  if g_game_id == 0 then
    return true
  end
  return false
end
function Test_Config.InitTestData_DS(PlayerKey)
  if Test_Config.bOpenSimulate then
    local extraData = {
      SourceUID = 54300001000,
      TargetUID = 54300002000,
      SourceScore = 49,
      TargetScore = 1,
      Type = 2,
      TimeStamp = 1597459839,
      WinnerUID = 54300001000,
      ResultType = 2
    }
    local BattleRankTopNData = require("GameLua.Mod.SocialIsland.DS.BattleRank.BattleRankTopNData")
    BattleRankTopNData.AddOneRecord(UEnums.EMatchType.MultiRoundOneVsOne, extraData)
    BattleRankTopNData.AddOneRecord(UEnums.EMatchType.MultiRoundOneVsOne, extraData)
    BattleRankTopNData.AddOneRecord(UEnums.EMatchType.MultiRoundOneVsOne, extraData)
    local extraDataRacing = {
      SourceUID = PlayerKey,
      TargetUID = 54300002000,
      TimeStamp = 1597459839,
      WinnerUID = 54300002000,
      ResultType = 2,
      VehicleId = 2,
      Laps = 1,
      IsSingle = false,
      SourceTotalSeconds = 90,
      TargetTotalSeconds = 90,
      SourceBestSingleLapSeconds = 45,
      TargetBestSingleLapSeconds = 45
    }
    local extraDataRacing2 = {
      SourceUID = PlayerKey,
      TargetUID = 54300002000,
      TimeStamp = 1597459839,
      WinnerUID = PlayerKey,
      ResultType = 2,
      VehicleId = 4,
      Laps = 2,
      IsSingle = false,
      SourceTotalSeconds = 80,
      TargetTotalSeconds = 80,
      SourceBestSingleLapSeconds = 40,
      TargetBestSingleLapSeconds = 40
    }
    local extraDataRacing3 = {
      SourceUID = PlayerKey,
      TargetUID = 54300002000,
      TimeStamp = 1597460000,
      WinnerUID = PlayerKey,
      ResultType = 2,
      VehicleId = 5,
      Laps = 2,
      IsSingle = false,
      SourceTotalSeconds = 100,
      TargetTotalSeconds = 100,
      SourceBestSingleLapSeconds = 55,
      TargetBestSingleLapSeconds = 55
    }
    local extraDataRacing4 = {
      SourceUID = PlayerKey,
      TargetUID = 54300002000,
      TimeStamp = 1597460001,
      WinnerUID = PlayerKey,
      ResultType = 2,
      VehicleId = 5,
      Laps = 2,
      IsSingle = false,
      SourceTotalSeconds = 103,
      TargetTotalSeconds = 103,
      SourceBestSingleLapSeconds = 56,
      TargetBestSingleLapSeconds = 56
    }
    local extraDataRacing5 = {
      SourceUID = PlayerKey,
      TargetUID = 54300002000,
      TimeStamp = 1597460002,
      WinnerUID = PlayerKey,
      ResultType = 2,
      VehicleId = 4,
      Laps = 2,
      IsSingle = false,
      SourceTotalSeconds = 100,
      TargetTotalSeconds = 100,
      SourceBestSingleLapSeconds = 55,
      TargetBestSingleLapSeconds = 55
    }
    BattleRankTopNData.AddOneRecord(UEnums.EMatchType.RacingGame, extraDataRacing)
    BattleRankTopNData.AddOneRecord(UEnums.EMatchType.RacingGame, extraDataRacing2)
    BattleRankTopNData.AddOneRecord(UEnums.EMatchType.RacingGame, extraDataRacing3)
    BattleRankTopNData.AddOneRecord(UEnums.EMatchType.RacingGame, extraDataRacing4)
    BattleRankTopNData.AddOneRecord(UEnums.EMatchType.RacingGame, extraDataRacing5)
  end
end
function Test_Config.GenerateDSPlayerInfo(uid)
  local tInfo = {
    wear = {},
    socialland_player_info = {
      friend_uid = 0,
      luckmate_match_status = 0,
      quit_count = 0,
      cur_socialland_alias_id = 0,
      luckmate_uid = 0,
      ban_timestamp = 0,
      luckmate_daily_reward = 1,
      socialland_alias_list = {
        2494001,
        2494002,
        2494003
      },
      diamond = 10,
      luckmate_match_ts = 0
    }
  }
  return tInfo
end
return Test_Config