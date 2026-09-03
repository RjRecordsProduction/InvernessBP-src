local RecentGiftAniSystem = {
  AniInfoList = {},
  Timer = nil,
  AniInsList = {},
  CurrUID = 0
}
function RecentGiftAniSystem.SetCurrUID(uid)
  log(bWriteLog and "RecentGiftAniSystem.SetCurrUID uid = " .. tostring(uid))
  RecentGiftAniSystem.CurrUID = uid
end
function RecentGiftAniSystem.IsSelf()
  log(bWriteLog and "RecentGiftAniSystem.IsSelf CurrUID = " .. tostring(RecentGiftAniSystem.CurrUID))
  return tonumber(RecentGiftAniSystem.CurrUID) == tonumber(DataMgr.roleData.uid)
end
function RecentGiftAniSystem.AddAnimIns(cObj_ui)
  table.insert(RecentGiftAniSystem.AniInsList, cObj_ui)
end
function RecentGiftAniSystem.RemoveIns(ui)
  local TableUtil = require("common.table_util")
  TableUtil.Remove(RecentGiftAniSystem.AniInsList, ui)
end
function RecentGiftAniSystem.StartAni()
  local time_ticker = require("common.time_ticker")
  RecentGiftAniSystem.Timer = time_ticker.AddTimer(0, function()
    while #RecentGiftAniSystem.AniInfoList > 0 do
      local first = table.remove(RecentGiftAniSystem.AniInfoList, 1)
      EventSystem:postEvent(EVENTTYPE_LOBBY_SOCIAL, EVENTID_SOCIAL_LOBBY_RECENT_GIFT_ANIM, first)
      coroutine.yield(2.5)
    end
  end)
end
function RecentGiftAniSystem.StopAllAni()
  RecentGiftAniSystem.AniInfoList = {}
  for i, v in ipairs(RecentGiftAniSystem.AniInsList) do
    v:Close()
  end
  RecentGiftAniSystem.AniInsList = {}
end
function RecentGiftAniSystem.AddAni(Info)
  log(bWriteLog and "RecentGiftAniSystem.AddAni:" .. tostring(Info.name))
  local logic_send_gift = require("client.slua.logic.gift.logic_send_gift")
  local giftInfo = logic_send_gift.GetGiftData(Info.gift_type)
  if not giftInfo then
    log(bWriteLog and "RecentGiftAniSystem.AddAni invalid gift info with type" .. tostring(Info.gift_type))
    return
  end
  table.insert(RecentGiftAniSystem.AniInfoList, Info)
  local time_ticker = require("common.time_ticker")
  if not RecentGiftAniSystem.Timer or not time_ticker.IsRunning(RecentGiftAniSystem.Timer) then
    RecentGiftAniSystem.StartAni()
  end
end
function RecentGiftAniSystem.CheckPlayAni(uid, playAni)
  uid = tostring(uid)
  local RoleInfoPopularitySystem = require("client.slua.logic.person_space.logic_roleinfo_popularity")
  local logic_send_gift = require("client.slua.logic.gift.logic_send_gift")
  local RecentGifts = {}
  for i, trend in ipairs(RoleInfoPopularitySystem.LastTrend) do
    if trend.name and trend.name ~= "" then
      local TimeUtil = require("client.common.time_util")
      local diff = TimeUtil.GetServerTimeInSec() - trend.devote_time
      if diff <= 259200 and 0 <= diff then
        local giftInfo = logic_send_gift.GetGiftData(trend.gift_type)
        if giftInfo then
          table.insert(RecentGifts, trend)
        end
      end
    end
  end
  for i, trend in ipairs(RoleInfoPopularitySystem.MsgTrend) do
    if trend.name and trend.name ~= "" then
      local TimeUtil = require("client.common.time_util")
      local diff = TimeUtil.GetServerTimeInSec() - trend.devote_time
      if diff <= 259200 and 0 <= diff then
        local giftInfo = logic_send_gift.GetGiftData(trend.gift_type)
        if giftInfo then
          table.insert(RecentGifts, trend)
        end
      end
    end
  end
  if 0 < #RecentGifts then
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.ePersonSpaceGiftAniTime)
    local filter = {}
    if saveData then
      local lastEnterTime = saveData[tostring(uid)] or 0
      for i, trend in ipairs(RecentGifts) do
        if lastEnterTime < trend.devote_time then
          table.insert(filter, trend)
        end
      end
    else
      filter = RecentGifts
    end
    table.sort(filter, function(trend1, trend2)
      local gift1Info = logic_send_gift.GetGiftData(trend1.gift_type)
      local gift2Info = logic_send_gift.GetGiftData(trend2.gift_type)
      if gift1Info.popularity ~= gift2Info.popularity then
        return gift1Info.popularity > gift2Info.popularity
      end
      return trend1.devote_time < trend2.devote_time
    end)
    if playAni then
      local count = 0
      for i, v in ipairs(filter) do
        RecentGiftAniSystem.AddAni(v)
        count = count + 1
        if 5 <= count then
          break
        end
      end
    end
    saveData = saveData or {}
    local TimeUtil = require("client.common.time_util")
    saveData[tostring(uid)] = TimeUtil.GetServerTimeInSec()
    local _count = 0
    for i, v in pairs(saveData) do
      if v - TimeUtil.GetServerTimeInSec() > 259200 then
        saveData[i] = v
      else
        _count = _count + 1
      end
    end
    local max = 100
    if _count > max then
      local tb = {}
      for i, v in pairs(saveData) do
        table.insert(tb, {uid = i, time = v})
      end
      table.sort(tb, function(data1, data2)
        return data1.time > data2.time
      end)
      for i = math.floor(max / 2), _count do
        saveData[tb[i].uid] = nil
      end
    end
    PlayerPrefsSystem.SaveTableToFile_N(saveData, PlayerPrefsSystem.ePlayerPrefsType.ePersonSpaceGiftAniTime)
  end
end
return RecentGiftAniSystem