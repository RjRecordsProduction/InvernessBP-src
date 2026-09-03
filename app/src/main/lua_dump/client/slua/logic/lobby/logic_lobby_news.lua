local logic_lobby_news = {
  WarningNoticeID = 0,
  WarningNoticePos = "",
  WarningNoticeJump = "",
  WarningNoticeTitle = "",
  WarningNoticeImgUrl = "",
  WarningNoticeContent = "",
  NewsType = 0,
  NewsShowPos = 0,
  NewsShowTitle = "",
  NewsShowContent = "",
  NewsLogData = {
    ID = 0,
    icon = 0,
    type = 0,
    jump = 0,
    redPoint = false
  },
  NewsItemID = {},
  NoticeIcon = 0,
  NewsEndTime = 0,
  NewsStartTime = 0
}
function logic_lobby_news.ReqNewsInfo()
  local lobbyHandler = require("client.network.Protocol.LobbyHandler")
  lobbyHandler.send_get_release_notes()
end
function logic_lobby_news.RspNewsInfo(msg)
  log_tree("[LobbyNews] RspNewsInfo", msg)
  if msg and next(msg) then
    logic_lobby_news.GenerateData(msg)
    EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_LOBBY_NEWS_RESPONSE)
  else
    log(bWriteLog and "[LobbyNews] News is nil")
  end
end
function logic_lobby_news.GenerateData(msg)
  if msg.start_time and msg.end_time then
    logic_lobby_news.NewsEndTime = msg.start_time
    logic_lobby_news.NewsEndTime = msg.end_time
  end
  logic_lobby_news.NoticeIcon = msg.icon
  logic_lobby_news.NewsLogData.ID = msg.id
  logic_lobby_news.NewsLogData.type = msg.type
  logic_lobby_news.NewsLogData.icon = msg.icon
  logic_lobby_news.NewsLogData.redPoint = true
  if msg.type == 1 then
    logic_lobby_news.NewsItemID = {}
    if msg.item_ids then
      for _, itemIDIndex in ipairs(msg.item_ids) do
        table.insert(logic_lobby_news.NewsItemID, itemIDIndex)
      end
      log_tree("[LobbyNews] News item ID ", logic_lobby_news.NewsItemID)
    end
    logic_lobby_news.NewsType = 1
    logic_lobby_news.NewsShowPos = msg.align_type
    logic_lobby_news.NewsShowTitle = msg.title
    logic_lobby_news.NewsShowContent = msg.text_content
  elseif msg.type > 1 then
    logic_lobby_news.NewsType = 2
    logic_lobby_news.WarningNoticeID = msg.id
    logic_lobby_news.WarningNoticePos = msg.align_type
    logic_lobby_news.WarningNoticeJump = msg.jump
    logic_lobby_news.WarningNoticeTitle = msg.title
    logic_lobby_news.WarningNoticeImgUrl = msg.map
    logic_lobby_news.WarningNoticeContent = msg.text_content
  end
end
function logic_lobby_news.CheckShowNews()
  if logic_lobby_news.NesType == 0 then
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local currentTime = TimeUtil.GetServerTimeInSec()
  log(bWriteLog and "[LogicNewsInfo] " .. tostring(currentTime) .. " " .. tostring(logic_lobby_news.NewsStartTime) .. " " .. tostring(logic_lobby_news.NewsEndTime))
  if currentTime > logic_lobby_news.NewsStartTime and currentTime < logic_lobby_news.NewsEndTime then
    return true
  else
    return false
  end
end
return logic_lobby_news