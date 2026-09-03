BattleHandler = BattleHandler or {}
local BattleScriptHelper = import("BattleScriptHelper")
local GetWearData = function(tWear)
  local tItemList = {}
  if tWear then
    for i, v in pairs(tWear) do
      if v and next(v) ~= nil and v[1] then
        local item = {}
        item.ItemTableID = v[1]
        local color_id = v[2] or 0
        local pattern_id = v[3] or 0
        item.AdditionIntData = {color_id, pattern_id}
        item.Count = 1
        table.insert(tItemList, item)
      end
    end
  end
  return tItemList
end
local GetAllWearData = function(tAllWear)
  local tOutAllWear = {}
  if tAllWear then
    for i = 1, 4 do
      local itemList = {}
      local wear = tAllWear[i]
      if wear == nil then
        local rolewearInfo = {RolewearInfo = itemList, IsLocked = true}
        table.insert(tOutAllWear, rolewearInfo)
      else
        for i, v in pairs(wear) do
          if v and next(v) ~= nil and v[1] then
            local item = {}
            item.ItemTableID = v[1]
            local color_id = v[2] or 0
            local pattern_id = v[3] or 0
            item.AdditionIntData = {color_id, pattern_id}
            item.Count = 1
            table.insert(itemList, item)
          end
        end
        local rolewearInfo = {RolewearInfo = itemList, IsLocked = false}
        table.insert(tOutAllWear, rolewearInfo)
      end
    end
  end
  return tOutAllWear
end
local GetTestPlayerData = function()
  local tInfo = {}
  tInfo.PlayerType = "Normal"
  tInfo.PlayerName = "Test"
  tInfo.PlayerGender = 1
  local tWear = {
    [1] = {
      [1] = 401997
    },
    [2] = {
      [2] = 401015
    },
    [3] = {
      [1] = 40601001
    },
    [4] = {
      [1] = 1400708,
      [2] = 5,
      [3] = 6
    },
    [5] = {
      [1] = 402001
    },
    [6] = {
      [1] = 703001
    }
  }
  tInfo.ItemList = GetWearData(tWear)
  tInfo.ExpressionItemList = {
    [1] = {ItemTableID = 2200101, Count = 1},
    [2] = {ItemTableID = 2200301, Count = 1},
    [3] = {ItemTableID = 2200201, Count = 1},
    [4] = {ItemTableID = 12200701, Count = 1},
    [5] = {ItemTableID = 12201101, Count = 1}
  }
  tInfo.EquipmentAvatar = {}
  tInfo.EquipmentAvatar.BagAvatar = 1504000001
  tInfo.EquipmentAvatar.HelmetAvatar = 1505000001
  tInfo.PlaneAvatarId = 1801105
  return tInfo
end
function BattleHandler.SyncGameInfo(params)
  if slua_GameFrontendHUD then
    log_tree("BattleHandler.SyncGameInfo", params)
    local BattleUtils = slua_GameFrontendHUD:GetBattleUtils()
    BattleScriptHelper.SyncGameInfo(BattleUtils, params)
  end
end
function BattleHandler.SyncGameExit()
  if slua_GameFrontendHUD then
    print(bWriteLog and "BattleHandler.SyncGameExit")
    local BattleUtils = slua_GameFrontendHUD:GetBattleUtils()
    BattleScriptHelper.SyncGameExit(BattleUtils)
  end
end
function BattleHandler.SyncNewBattlePlayer(params)
  local PlayerKey = 0
  if slua_GameFrontendHUD then
    local BattleUtils = slua_GameFrontendHUD:GetBattleUtils()
    if params and params.bTest then
      local PlayerUID = params.PlayerUID
      local tInfo = GetTestPlayerData()
      log_tree("BattleHandler.SyncNewBattlePlayer Test", tInfo)
      PlayerKey = BattleScriptHelper.SyncNewBattlePlayer(BattleUtils, PlayerUID, tInfo)
    else
      log_tree("BattleHandler.SyncNewBattlePlayer", params)
      local PlayerUID
      if params and params.PlayerUID then
        PlayerUID = tonumber(params.PlayerUID)
      end
      PlayerUID = PlayerUID or 0
      PlayerKey = BattleScriptHelper.SyncNewBattlePlayer(BattleUtils, PlayerUID, params)
    end
  end
  return PlayerKey
end
function BattleHandler.SyncBattlePlayerExit(params)
  if slua_GameFrontendHUD then
    log_tree("BattleHandler.SyncBattlePlayerExit", params)
    local BattleUtils = slua_GameFrontendHUD:GetBattleUtils()
    local PlayerUID = params.PlayerUID or 0
    local PlayerType = params.PlayerType or "Normal"
    local Reason = params.Reason or -1
    if type(params.PlayerUID) == "string" then
      PlayerUID = tonumber(params.PlayerUID) or 0
    end
    BattleScriptHelper.SyncBattlePlayerExit(BattleUtils, PlayerUID, PlayerType, Reason)
  end
end
function BattleHandler.RandomGenerateAIPlayerParams(playerKey, playerType)
  if slua_GameFrontendHUD then
    local BattleUtils = slua_GameFrontendHUD:GetBattleUtils()
    if CGameMode and CGameMode.GenerateAIPlayerInfo then
      local tInfo = CGameMode:GenerateAIPlayerInfo(playerKey, playerType)
      BattleScriptHelper.GenerateAIPlayerParams(BattleUtils, tInfo)
      return
    end
    print(bWriteLog and "BattleHandler.RandomGenerateAIPlayerParams PlayerKey:" .. playerKey)
    local tInfo = {}
    tInfo.PlayerKey = playerKey
    tInfo.PlayerType = playerType or "Normal"
    tInfo.PlayerName = string.format("Robot%d", playerKey)
    tInfo.TeamID = -1
    tInfo.Campid = -1
    tInfo.PlayerBornPointID = 2
    local tWear = {
      [1] = {
        [1] = 401997
      },
      [2] = {
        [1] = 40601001
      },
      [3] = {
        [1] = 703001
      }
    }
    tInfo.ItemList = GetWearData(tWear)
    tInfo.PlayerGender = 1
    BattleScriptHelper.GenerateAIPlayerParams(BattleUtils, tInfo)
  end
end