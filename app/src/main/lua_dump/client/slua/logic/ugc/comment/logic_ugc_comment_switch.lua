local logic_ugc_comment_switch = {}
function logic_ugc_comment_switch:DefineAndResetData()
  self.ParamsTableConfig = nil
end
function logic_ugc_comment_switch:OnInitialize()
end
function logic_ugc_comment_switch:RegistEvents()
end
function logic_ugc_comment_switch:OnLogin(bReLogin)
end
function logic_ugc_comment_switch:OnLogOut()
end
function logic_ugc_comment_switch:OnPreSwitchGameStatus(preState, nextState)
end
function logic_ugc_comment_switch:OnPostSwitchGameStatus(preState, nextState)
end
function logic_ugc_comment_switch:IsNeedReqParamsConfigTable()
  return self.ParamsTableConfig == nil
end
function logic_ugc_comment_switch:GetParamsConfigTable()
  if not self.ParamsTableConfig then
    local paramsConfig = CDataTable.GetTable("UGCCommentParamsConfig")
    if paramsConfig then
      return {
        CommentsOpenPlayCnt = paramsConfig.CommentsOpenPlayCnt.value,
        ScoreOpenPlayCnt = paramsConfig.ScoreOpenPlayCnt.value,
        ScoreOpenEvaluateCnt = paramsConfig.ScoreOpenEvaluateCnt.value,
        ScoreOpenModScore = paramsConfig.ScoreOpenModScore.value,
        ScoreTagCnt = paramsConfig.ScoreTagCnt.value,
        CommentsOpenSeg = paramsConfig.CommentsOpenSeg.value
      }
    end
  end
  return self.ParamsTableConfig
end
function logic_ugc_comment_switch:ReqGetParamsConfigTable()
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  BasicDataServerTable:GetOrReqData(data_config_marco.ugc_comments_params_cfg_table, function(_, configData)
    log_tree(bWriteLog and "logic_ugc_comment_switch:ReqGetParamsConfigTable, configData is:", configData)
    self.ParamsTableConfig = configData
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_GET_COMMENT_PARAMS_CONFIG)
  end)
end
function logic_ugc_comment_switch:CheckCommentSwitchOpen()
  return LobbySystem and LobbySystem.CheckOpen(BP_ENUM_UGC_COMMENT_SWITCH)
end
function logic_ugc_comment_switch:CheckCommentFlagSwitchOpen()
  return LobbySystem and LobbySystem.CheckOpen(BP_ENUM_UGC_COMMENT_FLAG_SWITCH)
end
function logic_ugc_comment_switch:CheckCommentVisitorOpen(playCount)
  if not self:CheckCommentFlagSwitchOpen() then
    log(bWriteLog and string.format("logic_ugc_comment_switch:CheckCommentVisitorOpen, not BP_ENUM_UGC_COMMENT_FLAG_SWITCH:%s", BP_ENUM_UGC_COMMENT_FLAG_SWITCH))
    return false
  end
  if not self:IsReachThreshold(playCount) then
    log(bWriteLog and string.format("logic_ugc_comment_switch:CheckCommentVisitorOpen, not reach threshold playCount:%s", playCount))
    return false
  end
  if not self:IsReachSegment() then
    log(bWriteLog and "logic_ugc_comment_switch:CheckCommentVisitorOpen, not reach segment")
    return false
  end
  return true
end
function logic_ugc_comment_switch:IsReachThreshold(playCount)
  playCount = playCount or 0
  local paramsTableConfig = self:GetParamsConfigTable()
  local threshold = tonumber(paramsTableConfig.CommentsOpenPlayCnt)
  if playCount <= threshold then
    log(bWriteLog and string.format("logic_ugc_comment_switch:IsReachThreshold, playCount < threshold:%s < %s", playCount, threshold))
    return false
  end
  return true
end
function logic_ugc_comment_switch:IsReachSegment()
  local paramsTableConfig = self:GetParamsConfigTable()
  local threshold = tonumber(paramsTableConfig.CommentsOpenSeg)
  local maxSegment = DataMgr.GetMaxRankLevel()
  if threshold >= maxSegment then
    log(bWriteLog and string.format("logic_ugc_comment_switch:IsReachSegment, maxSegment < threshold:%s < %s", maxSegment, threshold))
    return false
  end
  return true
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_ugc_comment_switch = class(CModuleBase, nil, logic_ugc_comment_switch)
return Clogic_ugc_comment_switch