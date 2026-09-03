local NoticesSceneData_Base = {}
function NoticesSceneData_Base:ctor()
  self.IsInit = false
  self.Seq = {}
  self.SeqIndex = 0
  self.SeqNumOfShow = 3
end
function NoticesSceneData_Base:Init()
  if self.IsInit then
    return
  end
  self:GenerateData()
  self:GenerateSeq()
  self.IsInit = true
end
function NoticesSceneData_Base:GenerateData()
end
function NoticesSceneData_Base:GenerateSeq()
end
function NoticesSceneData_Base:HasData()
end
function NoticesSceneData_Base:PreHandleDependResource()
end
function NoticesSceneData_Base:GetSeqNextData()
  self.SeqIndex = self.SeqIndex + 1
  if self.SeqIndex > self.SeqNumOfShow then
    return
  end
  return self.Seq[self.SeqIndex]
end
function NoticesSceneData_Base:IsLeftNotices()
  if not self.SeqIndex then
    return false
  end
  return self.SeqIndex < math.min(#self.Seq, self.SeqNumOfShow)
end
function NoticesSceneData_Base:ClearData()
end
function NoticesSceneData_Base:GetShowParams()
  local ui_show_queue_config = require("client.common.uibase.ui_show_queue_config")
  local ParamTable = ui_show_queue_config.GetParamTable(nil, "Common")
  return ParamTable
end
local class = require("class")
local DelegateContainer = require("common.delegate_container")
local CNoticesSceneData_Base = class(DelegateContainer, nil, NoticesSceneData_Base)
return CNoticesSceneData_Base