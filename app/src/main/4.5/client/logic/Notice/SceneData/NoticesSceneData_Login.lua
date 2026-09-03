local NoticesSceneData_Login = {}
local NoticesUtil = require("client.logic.Notice.NoticesUtil")
local NoticesConst = require("client.logic.Notice.NoticesConst")
function NoticesSceneData_Login:ctor()
  self.CollectionPageNotices = {}
  self.NormalNotices = {}
end
function NoticesSceneData_Login:GenerateData()
  log(bWriteLog and "NoticesSceneData_Login:GenerateData. start")
  local AllNotices = {}
  NoticesUtil.GetITopNotices(AllNotices, NoticesConst.ITopScene.UPDATE_SCENE_NOTICE)
  NoticesUtil.GetITopNotices(AllNotices, NoticesConst.ITopScene.MAINTENANCE_NOTICE_BEFORE_LOGIN)
  NoticesUtil.GetITopNotices(AllNotices, NoticesConst.ITopScene.COMMON_SCENE_BEFORE_LOGIN)
  log(bWriteLog and string.format("NoticesSceneData_Login:GenerateData. AllNotices count:%d", #AllNotices))
  for index, notice in pairs(AllNotices) do
    if NoticesUtil.CanShowForBaseParams(notice) then
      if NoticesUtil.IsCollectionPageNotice(notice) then
        table.insert(self.CollectionPageNotices, notice)
      else
        table.insert(self.NormalNotices, notice)
      end
    else
      log(bWriteLog and "NoticesSceneData_Login:GenerateData. filtered notice " .. tostring(notice.MsgId))
    end
  end
  NoticesUtil.SortNotices(self.CollectionPageNotices)
  NoticesUtil.SortNotices(self.NormalNotices)
  log(bWriteLog and string.format("NoticesSceneData_Login:GenerateData. CollectionPageNotices count:%d, NormalNotices count:%d", #self.CollectionPageNotices, #self.NormalNotices))
  log_tree(bWriteLog and "NoticesSceneData_Login:GenerateData. CollectionPageNotices = ", self.CollectionPageNotices)
  log_tree(bWriteLog and "NoticesSceneData_Login:GenerateData. NormalNotices = ", self.NormalNotices)
end
function NoticesSceneData_Login:GenerateSeq()
  log(bWriteLog and string.format("NoticesSceneData_Login:GenerateSeq. CollectionPageNotices count:%d, NormalNotices count:%d", #self.CollectionPageNotices, #self.NormalNotices))
  if #self.CollectionPageNotices > 0 then
    local UIConfig = UIManager.UI_Config.Notices_CollectionPage_UIBP
    table.insert(self.Seq, {
      UIConfig = UIConfig,
      Data = self.CollectionPageNotices
    })
    log(bWriteLog and string.format("NoticesSceneData_Login:GenerateSeq. insert CollectionPage, data count:%d", #self.CollectionPageNotices))
  end
  if #self.NormalNotices > 0 then
    for i, noticeData in ipairs(self.NormalNotices) do
      local UIConfig = UIManager.UI_Config.Notices_ImageOrBlueprint_UIBP
      if noticeData.MsgContentType == NoticesConst.NoticeContentType.Text then
        UIConfig = UIManager.UI_Config.Notices_CollectionPage_UIBP
      end
      table.insert(self.Seq, {
        UIConfig = UIConfig,
        Data = {noticeData}
      })
      log(bWriteLog and string.format("NoticesSceneData_Login:GenerateSeq. insert seq[%d] MsgId:%s ContentType:%d", i, tostring(noticeData.MsgId), tostring(noticeData.MsgContentType)))
    end
  end
  log(bWriteLog and string.format("NoticesSceneData_Login:GenerateSeq. final Seq count:%d", #self.Seq))
end
function NoticesSceneData_Login:HasData()
  if not self.IsInit then
    log_error(bWriteLog and "NoticesSceneData_Login.HasData. Has not init")
    return false
  end
  if GlobalData.IsIOSCheck() then
    log(bWriteLog and "NoticesSceneData_Login.HasData. Is IOS Check!")
    return false
  end
  local hasData = false
  hasData = hasData or #self.CollectionPageNotices ~= 0
  hasData = hasData or #self.NormalNotices ~= 0
  return hasData
end
function NoticesSceneData_Login:GetShowParams()
  local ui_show_queue_config = require("client.common.uibase.ui_show_queue_config")
  local ParamTable = ui_show_queue_config.GetParamTable(nil, "Login")
  return ParamTable
end
local class = require("class")
local NoticesSceneData_Base = require("client.logic.Notice.SceneData.NoticesSceneData_Base")
local CNoticesSceneData_Login = class(NoticesSceneData_Base, nil, NoticesSceneData_Login)
return CNoticesSceneData_Login