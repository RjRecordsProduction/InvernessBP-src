local NoticesSceneData_DelayNotices = {}
local NoticesUtil = require("client.logic.Notice.NoticesUtil")
local NoticesConst = require("client.logic.Notice.NoticesConst")
function NoticesSceneData_DelayNotices:ctor()
  self.CollectionPageNotices = {}
  self.NormalNotices = {}
end
function NoticesSceneData_DelayNotices:GenerateData()
  local DelayNoticesModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.DelayNoticesModule)
  self.NormalNotices = DelayNoticesModule:GetShowList()
  log(bWriteLog and string.format("NoticesSceneData_DelayNotices:GenerateData. NormalNotices count:%d", #self.NormalNotices))
  log_tree(bWriteLog and "NoticesSceneData_DelayNotices:GenerateData. NormalNotices = ", self.NormalNotices)
end
function NoticesSceneData_DelayNotices:GenerateSeq()
  log(bWriteLog and string.format("NoticesSceneData_DelayNotices:GenerateSeq. NormalNotices count:%d, SeqNumOfShow:%d", #self.NormalNotices, self.SeqNumOfShow))
  local ShowCount = self.SeqNumOfShow - 1
  if #self.NormalNotices > 0 then
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
      log(bWriteLog and string.format("NoticesSceneData_DelayNotices:GenerateSeq. insert seq[%d] MsgId:%s ContentType:%d", i, tostring(noticeData.MsgId), tostring(noticeData.MsgContentType)))
    end
  end
  log(bWriteLog and string.format("NoticesSceneData_DelayNotices:GenerateSeq. final Seq count:%d", #self.Seq))
end
function NoticesSceneData_DelayNotices:HasData()
  if not self.IsInit then
    log_error(bWriteLog and "NoticesSceneData_DelayNotices.HasData. Has not init")
    return false
  end
  local NewFaceSlapSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NewFaceSlapSystem)
  if not NewFaceSlapSystem:IsSlapEnd() then
    log_warning(bWriteLog and "NoticesSceneData_DelayNotices:HasData. NewFaceSlapSystem is not end")
    return false
  end
  local ui_show_queue_manager = require("client.common.uibase.ui_show_queue_manager")
  local LobbyQueuePopUIKeyDefine = require("client.slua.config.LobbyQueuePopUIKeyDefine")
  if ui_show_queue_manager.IsLimitByReturn(LobbyQueuePopUIKeyDefine.UIKey_Notices_Main_UIBP) then
    log(bWriteLog and "NoticesSceneData_Lobby:HasData. Is Show Queue.")
    return false
  end
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if LogicTxMissionMain.IsInXMission() then
    log(bWriteLog and "NoticesSceneData_DelayNotices:HasData. Is in T mission")
    return false
  end
  local hasData = false
  hasData = hasData or #self.NormalNotices ~= 0
  return hasData
end
local class = require("class")
local NoticesSceneData_Base = require("client.logic.Notice.SceneData.NoticesSceneData_Base")
local CNoticesSceneData_DelayNotices = class(NoticesSceneData_Base, nil, NoticesSceneData_DelayNotices)
return CNoticesSceneData_DelayNotices