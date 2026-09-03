local logic_peakgame_ace = {}
function logic_peakgame_ace:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_ACE, self.OnJumpAce, self)
end
function logic_peakgame_ace:OnJumpAce()
  log(bWriteLog and "logic_peakgame_ace:OnJumpAce")
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.PeakGame_Ace_Jump)
  local AceImprintLogic = require("client.logic.season.AceImprintLogic")
  AceImprintLogic.ShowAceMarkUI(DataMgr.roleData.uid)
end
function logic_peakgame_ace:OnSetAceShowTypeRsp(err_code, ace_show_type)
  log(bWriteLog and "logic_peakgame_ace:OnSetAceShowTypeRsp")
  if err_code ~= 0 then
    return
  end
  LobbySystem.roleData.end
function logic_peakgame_ace:OnGetPeakGameSegmentAllRsp(err_code, segment_info)
  log(bWriteLog and "logic_peakgame_ace:OnGetPeakGameSegmentAllRsp")
  if err_code ~= 0 then
    return
  end
  self.  EventSystem:postEvent(EVENTTYPE_PEAKGAME, EVENTID_PEAKGAME_GET_ALL_SEGMENT)
end
function logic_peakgame_ace:OnPeakGameAceReissueNotify(segment_info)
  log(bWriteLog and "logic_peakgame_ace:OnPeakGameAceReissueNotify")
  if segment_info == nil or not next(segment_info) then
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(segment_info, PlayerPrefsSystem.ePlayerPrefsType.ePeakGameAceReissueData)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_peakgame_ace = class(CModuleBase, nil, logic_peakgame_ace)
return Clogic_peakgame_ace