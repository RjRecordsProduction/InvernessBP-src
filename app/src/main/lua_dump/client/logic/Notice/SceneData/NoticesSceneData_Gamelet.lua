local NoticesSceneData_Gamelet = {}
local NoticesUtil = require("client.logic.Notice.NoticesUtil")
local NoticesConst = require("client.logic.Notice.NoticesConst")
function NoticesSceneData_Gamelet:ctor()
  self.NormalNotices = {}
end
local IsGameletNotices = function(v)
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local GameletUtil = require("client.slua.logic.gamelet.GameletUtil")
  if not v.cfg then
    log(bWriteLog and "NoticesSceneData_Gamelet:GenerateData. v.cfg is nil")
    return false
  end
  if not GameletUtil.IsGameletFaceSlapByServerData(v) then
    log(bWriteLog and "NoticesSceneData_Gamelet:GenerateData. back_int_value is not GameletFaceSlap")
    return false
  end
  if not ActivityNewSystem.IsGameletReadyByJumpUrl(v.cfg.page_link) then
    log(bWriteLog and "NoticesSceneData_Gamelet:GenerateData. gamelet isn't ready jumpUrl:", tostring(v.cfg.page_link))
    return false
  end
  return true
end
function NoticesSceneData_Gamelet:GenerateData()
  log(bWriteLog and "NoticesSceneData_Gamelet:GenerateData. start")
  local StoreUtils = require("client.slua.logic.store.utils.store_utils")
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local actDataList = ActivityNewSystem.GetServerDataByType(ActivityType.NOTICE_INFO)
  if not actDataList then
    log(bWriteLog and "NoticesSceneData_Gamelet:GenerateData. actDataList is nil")
    return
  end
  local allNotices = {}
  for k, v in pairs(actDataList) do
    if IsGameletNotices(v) then
      local item = NoticesUtil.GenerateNoticeData(v, NoticesConst.DataSource.Activity)
      table.insert(allNotices, item)
      StoreUtils.AddParameterToJumpURL(item, "jump", StoreConst.source_NoticeJumpToCrate)
    end
  end
  log(bWriteLog and string.format("NoticesSceneData_Gamelet:GenerateData. allNotices count:%d", #allNotices))
  local gameletID = NoticesUtil.GetPreDisplayIDByType(NoticesConst.Scene.Gamelet)
  NoticesUtil.GetShowNoticesByPreID(self.NormalNotices, allNotices, gameletID, NoticesConst.Scene.Gamelet, self.SeqNumOfShow - 1)
  log(bWriteLog and string.format("NoticesSceneData_Gamelet:GenerateData. NormalNotices count:%d, preDisplayID:%s", #self.NormalNotices, tostring(gameletID)))
  log_tree(bWriteLog and "NoticesSceneData_Gamelet:GenerateData. NormalNotices = ", self.NormalNotices)
end
function NoticesSceneData_Gamelet:GenerateSeq()
  log(bWriteLog and string.format("NoticesSceneData_Gamelet:GenerateSeq. NormalNotices count:%d, SeqNumOfShow:%d", #self.NormalNotices, self.SeqNumOfShow))
  if #self.NormalNotices > 0 then
    local ShowCount = self.SeqNumOfShow - 1
    local times = math.min(#self.NormalNotices, ShowCount)
    for i = 1, times do
      local noticeData = self.NormalNotices[i]
      local UIConfig = UIManager.UI_Config.Notices_Gamelet_UIBP
      table.insert(self.Seq, {
        UIConfig = UIConfig,
        Data = {noticeData}
      })
      log(bWriteLog and string.format("NoticesSceneData_Gamelet:GenerateSeq. insert seq[%d] MsgId:%s", i, tostring(noticeData.MsgId)))
    end
  end
  log(bWriteLog and string.format("NoticesSceneData_Gamelet:GenerateSeq. final Seq count:%d", #self.Seq))
end
function NoticesSceneData_Gamelet:HasData()
  if not self.IsInit then
    log_error(bWriteLog and "NoticesSceneData_Gamelet.HasData. Has not init")
    return false
  end
  local ui_show_queue_manager = require("client.common.uibase.ui_show_queue_manager")
  local LobbyQueuePopUIKeyDefine = require("client.slua.config.LobbyQueuePopUIKeyDefine")
  if ui_show_queue_manager.IsLimitByReturn(LobbyQueuePopUIKeyDefine.UIKey_GameletFaceSlapContainer_UIBP) then
    log(bWriteLog and "NoticesSceneData_Lobby:HasData. Is Show Queue.")
    return false
  end
  local hasData = false
  hasData = hasData or #self.NormalNotices ~= 0
  return hasData
end
local class = require("class")
local NoticesSceneData_Base = require("client.logic.Notice.SceneData.NoticesSceneData_Base")
local CNoticesSceneData_Gamelet = class(NoticesSceneData_Base, nil, NoticesSceneData_Gamelet)
return CNoticesSceneData_Gamelet