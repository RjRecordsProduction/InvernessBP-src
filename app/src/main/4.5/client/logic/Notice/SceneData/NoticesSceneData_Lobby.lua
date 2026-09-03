local NoticesSceneData_Lobby = {}
local NoticesUtil = require("client.logic.Notice.NoticesUtil")
local NoticesConst = require("client.logic.Notice.NoticesConst")
function NoticesSceneData_Lobby:ctor()
  self.CollectionPageNotices = {}
  self.NormalNotices = {}
  self.NormalResourceNotices = {}
end
function NoticesSceneData_Lobby:GenerateData()
  log(bWriteLog and string.format("NoticesSceneData_Lobby:GenerateData. IsJKB:%s", tostring(NoticesUtil.IsJKB())))
  local AllNotices = {}
  NoticesUtil.GetITopNotices(AllNotices, NoticesConst.ITopScene.SLAP_SCENE_AFTER_LOGIN)
  NoticesUtil.GetActivityNotices(AllNotices)
  NoticesUtil.SortNotices(AllNotices)
  log(bWriteLog and string.format("NoticesSceneData_Lobby:GenerateData. AllNotices count:%d", #AllNotices))
  if NoticesUtil.IsJKB() then
    self:FilterNoticesJKB(AllNotices)
  else
    self:FilterNoticesGlobal(AllNotices)
  end
  NoticesUtil.SortNotices(self.CollectionPageNotices)
  if not NoticesUtil.IsJKB() then
    local list = {}
    local occupyTimes = 0
    local MaxShowNum = self.SeqNumOfShow - 1
    for _, data in ipairs(self.NormalNotices) do
      local length = #list
      if MaxShowNum <= length + occupyTimes then
        break
      end
      if not NoticesUtil.IsDependResourceReady(data) then
        table.insert(self.NormalResourceNotices, data)
        log(bWriteLog and string.format("NoticesSceneData_Lobby:GenerateData. Isn't Ready, path:%s", data.PicPath))
      elseif NoticesUtil.IsPandoraOrGameletUrl(data.MsgUrl) then
        if NoticesUtil.IsPandoraOrGameletCanJump(data.MsgUrl) then
          list[#list + 1] = data
        else
          occupyTimes = occupyTimes + 1
          local DelayNoticesModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.DelayNoticesModule)
          DelayNoticesModule:SaveDelayNotices(data)
        end
      else
        list[#list + 1] = data
      end
    end
    self.NormalNotices = list
  end
  log(bWriteLog and string.format("NoticesSceneData_Lobby:GenerateData. CollectionPageNotices count:%d, NormalNotices count:%d", #self.CollectionPageNotices, #self.NormalNotices))
  log_tree(bWriteLog and "NoticesSceneData_Lobby:GenerateData. CollectionPageNotices = ", self.CollectionPageNotices)
  log_tree(bWriteLog and "NoticesSceneData_Lobby:GenerateData. NormalNotices = ", self.NormalNotices)
end
function NoticesSceneData_Lobby:GenerateSeq()
  log(bWriteLog and string.format("NoticesSceneData_Lobby:GenerateSeq. SeqNumOfShow:%d, CollectionPageNotices count:%d, NormalNotices count:%d", self.SeqNumOfShow, #self.CollectionPageNotices, #self.NormalNotices))
  local ShowCount = self.SeqNumOfShow
  if #self.CollectionPageNotices > 0 then
    local UIConfig = UIManager.UI_Config.Notices_CollectionPage_UIBP
    table.insert(self.Seq, {
      UIConfig = UIConfig,
      Data = self.CollectionPageNotices
    })
  end
  ShowCount = ShowCount - 1
  if #self.NormalNotices > 0 then
    if NoticesUtil.IsJKB() then
      local UIConfig = UIManager.UI_Config.Notices_JKB_UIBP
      table.insert(self.Seq, {
        UIConfig = UIConfig,
        Data = self.NormalNotices
      })
      log(bWriteLog and string.format("NoticesSceneData_Lobby:GenerateSeq. JKB insert Notices_JKB_UIBP, data count:%d", #self.NormalNotices))
    else
      local times = math.min(#self.NormalNotices, ShowCount)
      for i = 1, times do
        local noticeData = self.NormalNotices[i]
        local UIConfig = UIManager.UI_Config.Notices_ImageOrBlueprint_UIBP
        if noticeData.MsgContentType == NoticesConst.NoticeContentType.Text then
          UIConfig = UIManager.UI_Config.Notices_CollectionPage_UIBP
        end
        table.insert(self.Seq, {
          UIConfig = UIConfig,
          Data = {noticeData}
        })
        log(bWriteLog and string.format("NoticesSceneData_Lobby:GenerateSeq. insert seq[%d] MsgId:%s ContentType:%d", i, tostring(noticeData.MsgId), tostring(noticeData.MsgContentType)))
      end
    end
  end
  log(bWriteLog and string.format("NoticesSceneData_Lobby:GenerateSeq. final Seq count:%d", #self.Seq))
end
function NoticesSceneData_Lobby:HasData()
  if not self.IsInit then
    log_error(bWriteLog and "NoticesSceneData_Lobby.HasData. Has not init")
    return false
  end
  if NoticesUtil.IsJKB() and NoticesUtil.IsTodayNoShow() then
    log(bWriteLog and "NoticesSceneData_Lobby:HasData. JKB Is Today No Show.")
    return false
  end
  local ui_show_queue_manager = require("client.common.uibase.ui_show_queue_manager")
  local LobbyQueuePopUIKeyDefine = require("client.slua.config.LobbyQueuePopUIKeyDefine")
  if ui_show_queue_manager.IsLimitByReturn(LobbyQueuePopUIKeyDefine.UIKey_Notices_Main_UIBP) then
    log(bWriteLog and "NoticesSceneData_Lobby:HasData. Is Show Queue.")
    return false
  end
  local hasData = false
  hasData = hasData or #self.CollectionPageNotices ~= 0
  hasData = hasData or #self.NormalNotices ~= 0
  return hasData
end
function NoticesSceneData_Lobby:PreHandleDependResource()
  local resourceList = {}
  for _, noticeData in ipairs(self.NormalResourceNotices) do
    NoticesUtil.HandleDependResources(resourceList, noticeData)
  end
  NoticesUtil.HandleDownloadResource(resourceList)
end
function NoticesSceneData_Lobby:FilterNoticesGlobal(allNotices)
  for j = 1, #allNotices do
    local v = allNotices[j]
    if NoticesUtil.CanShowForBaseParams(v) == true and NoticesUtil.IsCollectionPageNotice(v) then
      table.insert(self.CollectionPageNotices, v)
    end
  end
  local iTopID = NoticesUtil.GetPreDisplayIDByType(NoticesConst.DataSource.iTop)
  local activityID = NoticesUtil.GetPreDisplayIDByType(NoticesConst.DataSource.Activity)
  local iTopList, activityList = NoticesUtil.GetiTopAndActivityNotices(allNotices)
  NoticesUtil.GetShowNoticesByPreID(self.NormalNotices, iTopList, iTopID, NoticesConst.DataSource.iTop, self.SeqNumOfShow - 1)
  NoticesUtil.GetShowNoticesByPreID(self.NormalNotices, activityList, activityID, NoticesConst.DataSource.Activity, self.SeqNumOfShow - 1)
end
function NoticesSceneData_Lobby:FilterNoticesJKB(allNotices)
  for j = 1, #allNotices do
    local v = allNotices[j]
    if NoticesUtil.CanShowForBaseParams(v) == true then
      if NoticesUtil.IsCollectionPageNotice(v) then
        table.insert(self.CollectionPageNotices, v)
      else
        table.insert(self.NormalNotices, v)
      end
    end
  end
end
local class = require("class")
local NoticesSceneData_Base = require("client.logic.Notice.SceneData.NoticesSceneData_Base")
local CNoticesSceneData_Lobby = class(NoticesSceneData_Base, nil, NoticesSceneData_Lobby)
return CNoticesSceneData_Lobby