local noticeTb = {}
local NoticeSystem = {}
local ActivityMacros = require("client.slua.logic.activity.RedPoint.ActivityMacros")
function NoticeSystem.InitOnlyOne()
  log(bWriteLog and "  : NoticeSystem.InitOnlyOne")
  EventSystem:registEvent(EVENTTYPE_NEXTDAY, EVENTID_NEXTDAY_ZERO, NoticeSystem.PostNoticeData)
end
function NoticeSystem.OnModePostSwitch(preState, nextState)
  log(bWriteLog and "NoticeSystem: OnModePostSwitch")
  if nextState == GameStatus.Lobby then
    NoticeSystem.PostNoticeData()
  end
end
function NoticeSystem.PostNoticeData()
  local NoticeHandler = require("client.network.Protocol.NoticeHandler")
  NoticeHandler.send_get_bulletin_list_req()
end
function NoticeSystem.GetNoticeData()
  if not noticeTb or not next(noticeTb) then
    return nil
  end
  local returnNotices = {}
  for i, v in pairs(noticeTb) do
    table.insert(returnNotices, v)
  end
  return returnNotices
end
function NoticeSystem.NoticeExist(bulletin_list, id)
  for _, v in pairs(bulletin_list) do
    if v.id == id then
      return true
    end
  end
end
function NoticeSystem.OnGetNoticeData(bulletin_list)
  local TimeUtil = require("client.common.time_util")
  log_tree("[  :OnGetNoticeData data", bulletin_list)
  bulletin_list = bulletin_list or {}
  local changeList = {
    idList = {},
    typeList = {}
  }
  if noticeTb and next(noticeTb) then
    for id, _ in pairs(noticeTb) do
      if not NoticeSystem.NoticeExist(bulletin_list, id) then
        changeList.idList[id] = true
        log(bWriteLog and "  : NoticeSystem.remove  id" .. tostring(id))
      end
    end
  end
  local lastNotices = noticeTb
  noticeTb = {}
  for _, v in pairs(bulletin_list) do
    if TimeUtil.UnixTimeBetween(v.start_time, v.end_time) == 0 then
      local _drop = {}
      local TableUtil = require("common.table_util")
      local drop = TableUtil.GetTableValue(v, "awards")
      if drop and next(drop) then
        for _, oneItem in pairs(drop) do
          table.insert(_drop, {
            itemId = oneItem.resid,
            count = oneItem.count,
            expireTime = oneItem.valid_hours or 0
          })
        end
      end
      local oneNotice = {
        TabType = 6,
        Order = v.show_order or 0,
        StartTime = v.start_time or 0,
        StartStr = TimeUtil.FormatTime_MDHM(v.start_time),
        EndStr = TimeUtil.FormatTime_MDHM(v.end_time),
        ShowSceneID = 1,
        other = {},
        Desc = v.content or "",
        ImgLink = v.jump,
        Title = v.title,
        ID = v.id,
        Type = 116,
        LabelDesc = v.title or "",
        Detail = v.content or "",
        ImgUrl = "",
        List = {
          {
            Order = v.show_order or 0,
            Drop = _drop,
            Desc = v.content or "",
            ImgLink = v.jump,
            Type = 116,
            Status = v.award_status or 0,
            CostList = {}
          }
        },
        nActID = v.id,
        sName = v.title,
        nRedDotNum = 0,
        bRedDot = function()
          local Red = v.award_status == ActivityProgressStatus.Done
          if Red then
            return Red, ActivityMacros.RedDotType.Reward
          end
          return Red, ActivityMacros.RedDotType.None
        end,
        sBgUrl = "",
        nStartTime = v.start_time or 0
      }
      noticeTb[v.id] = oneNotice
    end
  end
  for _, v in pairs(noticeTb) do
    local id = v.ID
    if not lastNotices or not lastNotices[id] then
      changeList.idList[id] = true
      changeList.typeList[v.Type] = true
    end
  end
  if next(changeList.idList) then
    log(bWriteLog and "  : hasChanged")
    EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CHANGE, changeList)
  end
end
function NoticeSystem.OnGetReward(err_code, id)
  if err_code ~= 0 then
    if err_code == 100000003 then
      ShowNotice(9910111)
      NoticeSystem.PostNoticeData()
    else
      ShowNotice(err_code)
    end
    return
  end
  local arrayItemData = {}
  log(bWriteLog and "  : id" .. tostring(id))
  local noticeData = noticeTb[id]
  if noticeData then
    log(bWriteLog and "  : findAct")
    local TableUtil = require("common.table_util")
    local data = TableUtil.GetTableValue(noticeData, "List", 1)
    if not data then
      log(bWriteLog and "  : no act")
      return
    end
    function noticeData.bRedDot()
      return false
    end
    data.Status = ActivityProgressStatus.Get
    for _, dropData in ipairs(data.Drop) do
      table.insert(arrayItemData, {
        res_id = dropData.itemId,
        count = dropData.count,
        valid_hours = dropData.expireTime
      })
    end
    if next(arrayItemData) then
      local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
      Logic_CommonItemGet.ShowPanel_DefaultStyle(arrayItemData)
    end
  end
  EventSystem:postEvent(EVENTTYPE_ACTIVITY_CENTER_NOTICE, EVENTID_ACTIVITY_CENTER_NOTICE_GOT, id)
end
return NoticeSystem