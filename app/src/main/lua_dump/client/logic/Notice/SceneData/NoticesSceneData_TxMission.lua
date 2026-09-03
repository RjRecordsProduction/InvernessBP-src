local NoticesSceneData_TxMission = {}
local NoticesUtil = require("client.logic.Notice.NoticesUtil")
local NoticesConst = require("client.logic.Notice.NoticesConst")
function NoticesSceneData_TxMission:ctor()
  self.CollectionPageNotices = {}
  self.NormalNotices = {}
  self.NormalResourceNotices = {}
end
function NoticesSceneData_TxMission:GenerateData()
  log(bWriteLog and string.format("NoticesSceneData_TxMission:GenerateData. IsJKB:%s", tostring(NoticesUtil.IsJKB())))
  local allNotices = {}
  NoticesUtil.GetTxMissionNotices(allNotices)
  NoticesUtil.SortNotices(allNotices)
  log(bWriteLog and string.format("NoticesSceneData_TxMission:GenerateData. allNotices count:%d", #allNotices))
  self:FilterNotices(allNotices)
  NoticesUtil.SortNotices(self.CollectionPageNotices)
  local list = {}
  for _, data in ipairs(self.NormalNotices) do
    if NoticesUtil.IsDependResourceReady(data) then
      log(bWriteLog and string.format("NoticesSceneData_TxMission:GenerateData. Is Ready, path:%s", data.PicPath))
      list[#list + 1] = data
    else
      table.insert(self.NormalResourceNotices, data)
      log(bWriteLog and string.format("NoticesSceneData_TxMission:GenerateData. Isn't Ready, path:%s", data.PicPath))
    end
  end
  self.NormalNotices = list
  log(bWriteLog and string.format("NoticesSceneData_TxMission:GenerateData. CollectionPageNotices count:%d, NormalNotices count:%d", #self.CollectionPageNotices, #self.NormalNotices))
  log_tree(bWriteLog and "NoticesSceneData_TxMission:GenerateData. CollectionPageNotices = ", self.CollectionPageNotices)
  log_tree(bWriteLog and "NoticesSceneData_TxMission:GenerateData. NormalNotices = ", self.NormalNotices)
end
function NoticesSceneData_TxMission:GenerateSeq()
  log(bWriteLog and string.format("NoticesSceneData_TxMission:GenerateSeq. IsJKB:%s, SeqNumOfShow:%d, CollectionPageNotices count:%d, NormalNotices count:%d", tostring(NoticesUtil.IsJKB()), self.SeqNumOfShow, #self.CollectionPageNotices, #self.NormalNotices))
  local ShowCount = self.SeqNumOfShow
  if #self.CollectionPageNotices > 0 then
    local UIConfig = UIManager.UI_Config.Notices_CollectionPage_UIBP
    table.insert(self.Seq, {
      UIConfig = UIConfig,
      Data = self.CollectionPageNotices
    })
    log(bWriteLog and string.format("NoticesSceneData_TxMission:GenerateSeq. insert CollectionPage, data count:%d", #self.CollectionPageNotices))
  end
  ShowCount = ShowCount - 1
  if #self.NormalNotices > 0 then
    if NoticesUtil.IsJKB() then
      local UIConfig = UIManager.UI_Config.Notices_JKB_UIBP
      table.insert(self.Seq, {
        UIConfig = UIConfig,
        Data = self.NormalNotices
      })
      log(bWriteLog and string.format("NoticesSceneData_TxMission:GenerateSeq. JKB insert Notices_JKB_UIBP, data count:%d", #self.NormalNotices))
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
        log(bWriteLog and string.format("NoticesSceneData_TxMission:GenerateSeq. insert seq[%d] MsgId:%s ContentType:%d", i, tostring(noticeData.MsgId), tostring(noticeData.MsgContentType)))
      end
    end
  end
  log(bWriteLog and string.format("NoticesSceneData_TxMission:GenerateSeq. final Seq count:%d", #self.Seq))
end
function NoticesSceneData_TxMission:HasData()
  if not self.IsInit then
    log_error(bWriteLog and "NoticesSceneData_TxMission.HasData. Has not init")
    return false
  end
  if NoticesUtil.IsJKB() and NoticesUtil.IsTodayNoShow() then
    log(bWriteLog and "NoticesSceneData_TxMission:HasData. JKB Is Today No Show.")
    return false
  end
  local hasData = false
  hasData = hasData or #self.CollectionPageNotices ~= 0
  hasData = hasData or #self.NormalNotices ~= 0
  return hasData
end
function NoticesSceneData_TxMission:PreHandleDependResource()
  local resourceList = {}
  for _, noticeData in ipairs(self.NormalResourceNotices) do
    NoticesUtil.HandleDependResources(resourceList, noticeData)
  end
  NoticesUtil.HandleDownloadResource(resourceList)
end
function NoticesSceneData_TxMission:GetShowParams()
  return nil
end
function NoticesSceneData_TxMission:FilterNotices(allNotice)
  if NoticesUtil.IsJKB() then
    for j = 1, #allNotice do
      local v = allNotice[j]
      if NoticesUtil.CanShowForBaseParams(v) == true then
        if NoticesUtil.IsCollectionPageNotice(v) then
          table.insert(self.CollectionPageNotices, v)
        else
          table.insert(self.NormalNotices, v)
        end
      end
    end
  else
    local TxMissionList = {}
    for j = 1, #allNotice do
      local v = allNotice[j]
      if NoticesUtil.CanShowForBaseParams(v) == true then
        if NoticesUtil.IsCollectionPageNotice(v) then
          table.insert(self.CollectionPageNotices, v)
        else
          table.insert(TxMissionList, v)
        end
      end
    end
    local TxMissionID = NoticesUtil.GetPreDisplayIDByType(NoticesConst.Scene.TxMission)
    NoticesUtil.GetShowNoticesByPreID(self.NormalNotices, TxMissionList, TxMissionID, NoticesConst.Scene.TxMission, self.SeqNumOfShow - 1)
  end
end
local class = require("class")
local NoticesSceneData_Base = require("client.logic.Notice.SceneData.NoticesSceneData_Base")
local CNoticesSceneData_TxMission = class(NoticesSceneData_Base, nil, NoticesSceneData_TxMission)
return CNoticesSceneData_TxMission