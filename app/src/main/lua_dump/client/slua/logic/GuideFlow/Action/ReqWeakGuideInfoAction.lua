local ReqWeakGuideInfoAction = {}
function ReqWeakGuideInfoAction.Run(node)
  local GuideFlowLog = require("client.slua.logic.GuideFlow.GuideFlowLog")
  GuideFlowLog.log(GuideFlowLog.bLog and "ReqWeakGuideInfoAction Run")
  local PlayerLabelHandler = require("client.network.Protocol.PlayerLabelHandler")
  PlayerLabelHandler.send_get_match_num_req()
  local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
  if not growthprojectMgrB.IsFinishAllNewGuide() then
    return
  end
end
return ReqWeakGuideInfoAction