local logic_newbie_bubble = {
  activityData = {},
  isShowNewBie = false,
  bannerConfig = nil,
  wordMessageConfig = nil
}
local Inited = false
function logic_newbie_bubble.IsNewer()
  local logic_newbie_assist = require("client.slua.logic.activity.newbie.logic_newbie_assist")
  if not logic_newbie_assist.IsShowLobbyEntrance() then
    log(bWriteLog and "[v_wllwu]logic_newbie_bubble.IsNewer is false")
    return false
  end
  return true
end
function logic_newbie_bubble.CheckShowNewBie()
  if not logic_newbie_bubble.IsNewer() then
    return false
  end
  local logic_newbie = require("client.logic.newbie.logic_newbie")
  local enter_game_num = logic_newbie.newbieTotalGameCnt or 0
  log(bWriteLog and "[v_wllwu]logic_newbie_bubble.CheckShowNewBie: enter_game_num = " .. enter_game_num)
  if enter_game_num < 2 then
    log(bWriteLog and "[v_wllwu] logic_newbie_bubble enter_game_num is less than 2")
    return false
  end
  return true
end
function logic_newbie_bubble.IsCanShowNewBieBubble()
  local logic_newbie_assist = require("client.slua.logic.activity.newbie.logic_newbie_assist")
  if not logic_newbie_assist.GetLobbySwitchState() then
    return false
  end
  if not Inited then
    logic_newbie_bubble.isShowNewBie = logic_newbie_bubble.CheckShowNewBie()
    log(bWriteLog and "[v_Wllwu] logic_newbie_bubble.IsNewer = " .. tostring(logic_newbie_bubble.isShowNewBie))
  end
  return logic_newbie_bubble.isShowNewBie
end
function logic_newbie_bubble.SaveNewBieBannerInfo(display_table)
  logic_newbie_bubble.activityData = display_table or {}
  logic_newbie_bubble.SetBannerData()
  logic_newbie_bubble.SetWordActData()
end
function logic_newbie_bubble.SetBannerData()
  logic_newbie_bubble.bannerConfig = {}
  for _, act in pairs(logic_newbie_bubble.activityData) do
    if act.IconPath ~= "" and logic_newbie_bubble.CheckActData(act) then
      logic_newbie_bubble.bannerConfig[#logic_newbie_bubble.bannerConfig + 1] = act
    end
  end
end
function logic_newbie_bubble.GetBannerData()
  if not logic_newbie_bubble.IsCanShowNewBieBubble() then
    return nil
  end
  if not logic_newbie_bubble.bannerConfig then
    logic_newbie_bubble.SetBannerData()
  end
  local newData = {}
  local TimeUtil = require("client.common.time_util")
  for _, act in pairs(logic_newbie_bubble.bannerConfig) do
    if act.IconPath ~= "" and logic_newbie_bubble.CheckActData(act) and TimeUtil.UnixTimeBetween(act.StartTimeUTC, act.EndTimeUTC) == 0 then
      table.insert(newData, act)
    end
  end
  return newData
end
function logic_newbie_bubble.SetWordActData()
  logic_newbie_bubble.wordMessageConfig = {}
  for _, act in pairs(logic_newbie_bubble.activityData) do
    if logic_newbie_bubble.CheckActData(act) then
      logic_newbie_bubble.wordMessageConfig[#logic_newbie_bubble.wordMessageConfig + 1] = act
    end
  end
  log_tree("logic_newbie_bubble.wordMessageConfig = ", logic_newbie_bubble.wordMessageConfig)
end
function logic_newbie_bubble.GetWordActData()
  if not logic_newbie_bubble.IsCanShowNewBieBubble() then
    return nil
  end
  if not logic_newbie_bubble.wordMessageConfig then
    logic_newbie_bubble.SetWordActData()
  end
  return logic_newbie_bubble.wordMessageConfig
end
function logic_newbie_bubble.CheckActData(act)
  if not act then
    return
  end
  local registerTime = DataMgr.registertime or 0
  log(bWriteLog and "logic_newbie_bubble.CheckActData registertime = " .. tostring(registerTime))
  local TimeUtil = require("client.common.time_util")
  local nowTime = TimeUtil.GetServerTimeInSec()
  log(bWriteLog and "logic_newbie_bubble.CheckActData nowTime = " .. tostring(nowTime))
  local duringTime = nowTime - registerTime
  local startTime = 0
  local endTime = 0
  if act.EndShowDay ~= nil and act.EndShowDay ~= "" then
    endTime = tonumber(act.EndShowDay) * 86400
  end
  if act.StartShowDay ~= nil and act.StartShowDay ~= "" then
    startTime = tonumber(act.StartShowDay) * 86400
  end
  if duringTime < startTime then
    return false
  elseif endTime ~= 0 and duringTime >= endTime then
    return false
  end
  return true
end
function logic_newbie_bubble.OnModePostSwitch(preState, nextState)
  if not GameStatus.IsInLobbyOrMainCity() then
    logic_newbie_bubble.ResetData()
  end
end
function logic_newbie_bubble.ResetData()
  Inited = false
  logic_newbie_bubble.isShowNewBie = false
  logic_newbie_bubble.bannerConfig = nil
  logic_newbie_bubble.wordMessageConfig = nil
end
return logic_newbie_bubble