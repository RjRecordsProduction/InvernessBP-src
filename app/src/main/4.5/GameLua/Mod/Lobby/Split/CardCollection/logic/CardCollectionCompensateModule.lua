local CardCollectionCompensateModule = {}
local TimeUtil = require("client.common.time_util")
local LOBBY_CD_SECONDS = 1800
local CARDCOLLECTION_CD_SECONDS = 600
local SURPRISE_OP_QUERY = 1
local SURPRISE_OP_CLAIM = 2
local REQUEST_DELAY_SECONDS = 2
function CardCollectionCompensateModule:DefineAndResetData()
  self.lobbyNextAllowTime = 0
  self.cardCollectionNextAllowTime = 0
  self.pendingLobbyCD = false
  self.pendingCardCollectionCD = false
  self.queryTimer = nil
  self.claimTimer = nil
end
function CardCollectionCompensateModule:OnInitialize()
end
function CardCollectionCompensateModule:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_CARD_COLLECTION, EVENTID_CARDCOLLECTION_QUERY_COMPENSATE_LOBBY, self._OnQueryCompensateLobby, self)
  self:AddCommonEvent(EVENTTYPE_CARD_COLLECTION, EVENTID_CARDCOLLECTION_QUERY_COMPENSATE_CARD, self._OnQueryCompensateCardCollection, self)
end
function CardCollectionCompensateModule:OnLogin(bReLogin)
end
function CardCollectionCompensateModule:OnLogOut()
  self:_ClearRequestTimers()
  self:DefineAndResetData()
end
function CardCollectionCompensateModule:OnPreSwitchGameStatus(preState, nextState)
end
function CardCollectionCompensateModule:OnPostSwitchGameStatus(preState, nextState)
end
function CardCollectionCompensateModule:_OnQueryCompensateLobby()
  if TimeUtil.GetServerTimeInSec() < self.lobbyNextAllowTime then
    log(bWriteLog and "[CardCollection] CardCollectionCompensateModule: lobby CD not ready")
    return
  end
  self.pendingLobbyCD = true
  self:_TryScheduleQuery()
end
function CardCollectionCompensateModule:_OnQueryCompensateCardCollection()
  if TimeUtil.GetServerTimeInSec() < self.cardCollectionNextAllowTime then
    log(bWriteLog and "[CardCollection] CardCollectionCompensateModule: cardcollection CD not ready")
    return
  end
  self.pendingCardCollectionCD = true
  self:_TryScheduleQuery()
end
function CardCollectionCompensateModule:_TryScheduleQuery()
  if self.queryTimer then
    return
  end
  self.queryTimer = self:AddTimerOnce(REQUEST_DELAY_SECONDS, function()
    self.queryTimer = nil
    self:_SendQueryCompensateReq()
  end)
end
function CardCollectionCompensateModule:_SendQueryCompensateReq()
  log(bWriteLog and "[CardCollection] CardCollectionCompensateModule:_SendQueryCompensateReq")
  local CardCollectionSeasonHandler = require("GameLua.Mod.Lobby.Split.CardCollection.ModCardCollectionSeasonHandler")
  CardCollectionSeasonHandler.send_card_collect_pack_surprise_req(SURPRISE_OP_QUERY)
end
function CardCollectionCompensateModule:on_card_collect_pack_surprise_rsp(op_type, theme_count)
  log(bWriteLog and string.format("[CardCollection] CardCollectionCompensateModule:on_card_collect_pack_surprise_rsp op_type=%s theme_count=%s", tostring(op_type), tostring(theme_count)))
  if op_type == SURPRISE_OP_QUERY then
    self:_OnQueryRsp(theme_count)
  elseif op_type == SURPRISE_OP_CLAIM then
    self:_OnClaimRsp(theme_count)
  end
end
function CardCollectionCompensateModule:_OnQueryRsp(theme_count)
  local now = TimeUtil.GetServerTimeInSec()
  if self.pendingLobbyCD then
    self.lobbyNextAllowTime = now + LOBBY_CD_SECONDS
    self.pendingLobbyCD = false
  end
  if self.pendingCardCollectionCD then
    self.cardCollectionNextAllowTime = now + CARDCOLLECTION_CD_SECONDS
    self.pendingCardCollectionCD = false
  end
  if not theme_count or theme_count <= 0 then
    log(bWriteLog and "[CardCollection] CardCollectionCompensateModule: no compensate")
    return
  end
  if self:_IsCardCollectionOpen() then
    log(bWriteLog and "[CardCollection] CardCollectionCompensateModule: postEvent DUPLICATE_COMPENSATE")
    EventSystem:postEvent(EVENTTYPE_CARD_COLLECTION, EVENTID_CARDCOLLECTION_DUPLICATE_COMPENSATE, theme_count)
  else
    log(bWriteLog and "[CardCollection] CardCollectionCompensateModule: report MiniTV")
    self:_ReportToSmartAssistant(theme_count)
  end
end
function CardCollectionCompensateModule:_OnClaimRsp(theme_count)
  log(bWriteLog and string.format("[CardCollection] CardCollectionCompensateModule: claim success granted=%s", tostring(theme_count)))
  if theme_count and 0 < theme_count then
    EventSystem:postEvent(EVENTTYPE_CARD_COLLECTION, EVENTID_CARDCOLLECTION_FRAGMENT_UPDATE)
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    local tExtendData = {
      sTipStr = LocUtil.LocalizeResFormat(33020233, theme_count)
    }
    Logic_CommonItemGet.ShowPanel_DefaultStyle({
      {res_id = 1024, count = theme_count}
    }, nil, nil, tExtendData)
  end
end
function CardCollectionCompensateModule:ClaimCompensation()
  if self.claimTimer then
    log(bWriteLog and "[CardCollection] CardCollectionCompensateModule:ClaimCompensation ignored, claim pending")
    return
  end
  self.claimTimer = self:AddTimerOnce(REQUEST_DELAY_SECONDS, function()
    self.claimTimer = nil
    log(bWriteLog and "[CardCollection] CardCollectionCompensateModule:ClaimCompensation send op_type=2")
    local CardCollectionSeasonHandler = require("GameLua.Mod.Lobby.Split.CardCollection.ModCardCollectionSeasonHandler")
    CardCollectionSeasonHandler.send_card_collect_pack_surprise_req(SURPRISE_OP_CLAIM)
  end)
end
function CardCollectionCompensateModule:_ClearRequestTimers()
  if self.queryTimer then
    self:RemoveTimer(self.queryTimer)
    self.queryTimer = nil
  end
  if self.claimTimer then
    self:RemoveTimer(self.claimTimer)
    self.claimTimer = nil
  end
end
function CardCollectionCompensateModule:_IsCardCollectionOpen()
  local mainUI = UIManager.GetUI(UIManager.UI_Config.CardCollection_Main_UIBP)
  if mainUI and slua.isValid(mainUI.UIRoot) then
    return true
  end
  local setUI = UIManager.GetUI(UIManager.UI_Config.CardCollection_Set_UIBP)
  return setUI ~= nil and slua.isValid(setUI.UIRoot)
end
function CardCollectionCompensateModule:_ReportToSmartAssistant(theme_count)
  local SmartAssistantHandler = require("client.network.Protocol.SmartAssistantHandler")
  local MiniTVConst = require("client.lobby_ue_object.Actor.MiniTV.MiniTVConst")
  SmartAssistantHandler.send_report_minitv_raw_event_req(MiniTVConst.RAW_EVENT_TYPE.CARDCOLLECTION_COMPENSATE, {theme_count = theme_count})
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CCardCollectionCompensateModule = class(CModuleBase, nil, CardCollectionCompensateModule)
return CCardCollectionCompensateModule