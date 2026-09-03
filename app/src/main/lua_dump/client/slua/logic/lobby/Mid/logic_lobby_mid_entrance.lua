local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
local logic_lobby_mid_entrance = {
  entranceMap = {},
  bHasData = false,
  clickCountMap = nil
}
local ENTRANCE_TYPE = {
  ACTIVITY = 1001,
  RP = 1002,
  SPECIAL_OFFER = 1003,
  SPORT = 1004,
  BP = 1005
}
local PLAYER_TYPE = {
  NORMAL = 0,
  NEWBIE = 1,
  RETURN = 2
}
logic_lobby_mid_entrance.local LoadClickCountMap = function()
  if logic_lobby_mid_entrance.clickCountMap == nil then
    logic_lobby_mid_entrance.clickCountMap = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eCommerceEntranceClickCount) or {}
  end
  return logic_lobby_mid_entrance.clickCountMap
end
local SaveClickCountMap = function()
  PlayerPrefsSystem.SaveTableToFile_N(logic_lobby_mid_entrance.clickCountMap or {}, PlayerPrefsSystem.ePlayerPrefsType.eCommerceEntranceClickCount)
end
local IsEntryExpired = function(entryType, static_pic_show_times)
  if not static_pic_show_times or static_pic_show_times <= 0 then
    return false
  end
  local countMap = LoadClickCountMap()
  local clickCount = countMap[tostring(entryType)] or 0
  return static_pic_show_times <= clickCount
end
function logic_lobby_mid_entrance.OnEntranceClicked(entrance_id_type)
  if not entrance_id_type then
    return
  end
  local countMap = LoadClickCountMap()
  local key = tostring(entrance_id_type)
  local count = (countMap[key] or 0) + 1
  countMap[key] = count
  SaveClickCountMap()
  local entry = logic_lobby_mid_entrance.entranceMap[entrance_id_type]
  if entry and 0 < entry.static_pic_show_times and count >= entry.static_pic_show_times then
    logic_lobby_mid_entrance.entranceMap[entrance_id_type] = nil
    EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_COMMERCE_ENTRANCE_UPDATE)
  end
end
function logic_lobby_mid_entrance.SendCommerceEntranceInfoReq()
  local LobbyHandler = require("client.network.Protocol.LobbyHandler")
  LobbyHandler.send_commerce_entrance_info_req()
end
function logic_lobby_mid_entrance.SaveCommerceEntranceInfo(ret_info)
  if not ret_info then
    return
  end
  logic_lobby_mid_entrance.entranceMap = {}
  local bIsNewbie = DataMgr.IsRecruit()
  for _, info in ipairs(ret_info) do
    local entryType = info.entrance_id_type
    if entryType then
      local showTimes = info.static_pic_show_times or 0
      if not IsEntryExpired(entryType, showTimes) then
        local playerType = info.show_player_type or 0
        if playerType ~= PLAYER_TYPE.NEWBIE or bIsNewbie then
          local existing = logic_lobby_mid_entrance.entranceMap[entryType]
          local existingType = existing and existing.show_player_type or -1
          local shouldReplace = bIsNewbie and playerType == PLAYER_TYPE.NEWBIE or existingType ~= PLAYER_TYPE.NEWBIE and (not existing or (info.priority or 0) > (existing.priority or 0))
          if shouldReplace then
            logic_lobby_mid_entrance.entranceMap[entryType] = {
              text = info.text or "",
              priority = info.priority or 0,
              static_pic_url = info.static_pic_url or "",
              entrance_id_type = entryType,
              jump_url = info.jump_url or "",
              static_pic_show_times = showTimes,
              show_player_type = playerType
            }
          end
        end
      end
    end
  end
  logic_lobby_mid_entrance.bHasData = true
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_COMMERCE_ENTRANCE_UPDATE)
end
function logic_lobby_mid_entrance.GetEntranceConfig(entrance_id_type)
  if not logic_lobby_mid_entrance.bHasData then
    return nil
  end
  return logic_lobby_mid_entrance.entranceMap[entrance_id_type]
end
function logic_lobby_mid_entrance.HasData()
  return logic_lobby_mid_entrance.bHasData
end
function logic_lobby_mid_entrance.Clear()
  logic_lobby_mid_entrance.entranceMap = {}
  logic_lobby_mid_entrance.bHasData = false
  logic_lobby_mid_entrance.clickCountMap = {}
end
return logic_lobby_mid_entrance