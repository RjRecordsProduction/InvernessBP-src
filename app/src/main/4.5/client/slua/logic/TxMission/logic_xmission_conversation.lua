local XMissionConversationSystem = {
  conversationQueue = {},
  bPlaying = false,
  nextConversationTimer = nil,
  INSURANCE_GUIDE_PLOTID = 200030,
  INSURANCE_REMAIN_PLOTID = 200031,
  OPERATION_PLOTID = 200032,
  DEFEAT_CARE_PLOTID = 200033,
  PVE_AFFIXS_GUIDE_GET = 200035,
  PVE_RETURN_EQUIP_PLOTID = 200036,
  PVP_AFFIXS_GUIDE_GET = 200037,
  PVP_AND_PVE_AFFIXS_GUIDE_GET = 200038,
  WEEKEND_TALENT_OPEN = 200039,
  REPUTATION_ADJUST_NOTIFI = 200040
}
local E_ConversationAwardType = {
  Item = 1,
  Tips = 2,
  Jump = 3
}
XMissionConversationSystem.
function XMissionConversationSystem.OnModePostSwitch(preState, nextState)
  if GameStatus.IsInLobbyOrMainCity() then
    EventSystem:registEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_CONVERSATION_DONE, XMissionConversationSystem.OnConversationDone)
  else
    EventSystem:unregistEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_CONVERSATION_DONE, XMissionConversationSystem.OnConversationDone)
    XMissionConversationSystem.ClearConversationQueue()
  end
  if XMissionConversationSystem.nextConversationTimer then
    local timer_ticker = require("common.time_ticker")
    timer_ticker.RemoveTimer(XMissionConversationSystem.nextConversationTimer)
  end
  XMissionConversationSystem.nextConversationTimer = nil
  XMissionConversationSystem.bPlaying = false
end
local _CheckPlotIDValid = function(plotID)
  local config = CDataTable.GetTableData("PlotConfig", plotID)
  if not config then
    return false
  end
  return true
end
function XMissionConversationSystem.StartConversation(plotID, items)
  if not _CheckPlotIDValid(plotID) then
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.xmission_npc_conversation, plotID, items)
end
function XMissionConversationSystem.StopConversation()
  if not UIManager.IsUIShow(UIManager.UI_Config.xmission_npc_conversation) then
    log_warning("[edward][logic_xmission_conversation] XMissionConversationSystem:StopConversation, there is no conversation!")
    return
  end
  if #XMissionConversationSystem.conversationQueue > 1 then
    local first = table.remove(XMissionConversationSystem.conversationQueue, 1)
    XMissionConversationSystem.conversationQueue = {first}
  end
  local ui = UIManager.GetUI(UIManager.UI_Config.xmission_npc_conversation)
  ui:ForceDoneConversation()
end
function XMissionConversationSystem.PushConversation(plotID, type, param)
  log(bWriteLog and string.format("XMissionConversationSystem.PushConversation, plotID, type, param:%s, %s, %s", plotID, type, param))
  XMissionConversationSystem.AddToConversationList(plotID, type, param)
  XMissionConversationSystem.NextConversation()
end
function XMissionConversationSystem.AddToConversationList(plotID, type, param, business, itemGetCloseCallback)
  log(bWriteLog and "XMissionConversationSystem.AddToConversationList, plotID = " .. tostring(plotID))
  if not _CheckPlotIDValid(plotID) then
    return
  end
  local conversation = {
    plotID = plotID,
    type = type or 0,
    param = param,
    business = business,
      }
  table.insert(XMissionConversationSystem.conversationQueue, conversation)
end
function XMissionConversationSystem.NextConversation()
  log(bWriteLog and "XMissionConversationSystem.NextConversation")
  if XMissionConversationSystem.bPlaying then
    return
  end
  if UIManager.IsUIShow(UIManager.UI_Config.xmission_npc_conversation) then
    log(bWriteLog and "[edward][logic_xmission_conversation] XMissionConversationSystem:StopConversation, there is a conversation!")
    return
  end
  if #XMissionConversationSystem.conversationQueue == 0 then
    return
  end
  local ui = UIManager.GetUI(UIManager.UI_Config.xmission_beginner_guide)
  if ui ~= nil then
    UIManager.CloseUI(UIManager.UI_Config.xmission_beginner_guide)
  end
  XMissionConversationSystem.bPlaying = true
  local conversation = XMissionConversationSystem.conversationQueue[1]
  local XMissionNpcSystem = require("client.slua.logic.TxMission.logic_xmission_npc")
  if conversation.plotID == XMissionConversationSystem.INSURANCE_GUIDE_PLOTID or conversation.plotID == XMissionConversationSystem.INSURANCE_REMAIN_PLOTID or conversation.plotID == XMissionConversationSystem.OPERATION_PLOTID or conversation.plotID == XMissionConversationSystem.DEFEAT_CARE_PLOTID or conversation.plotID == XMissionConversationSystem.PVE_AFFIXS_GUIDE_GET or conversation.plotID == XMissionConversationSystem.PVE_RETURN_EQUIP_PLOTID or conversation.plotID == XMissionConversationSystem.PVP_AFFIXS_GUIDE_GET or conversation.plotID == XMissionConversationSystem.REPUTATION_ADJUST_NOTIFI or conversation.plotID == XMissionConversationSystem.PVP_AND_PVE_AFFIXS_GUIDE_GET then
    XMissionConversationSystem.StartConversation(conversation.plotID, conversation.param)
  else
    XMissionConversationSystem.StartConversation(conversation.plotID)
  end
end
function XMissionConversationSystem.HaveBeginnerGuideConversation()
  local result = false
  if #XMissionConversationSystem.conversationQueue > 0 then
    local conversation = XMissionConversationSystem.conversationQueue[1]
    local XMissionNpcSystem = require("client.slua.logic.TxMission.logic_xmission_npc")
    if conversation.business == XMissionNpcSystem.E_PlotParamType.BeginnerGuide then
      result = true
    end
  end
  log(bWriteLog and "XMissionConversationSystem.HaveBeginnerGuideConversation, result = " .. tostring(result))
  return result
end
function XMissionConversationSystem.ClearConversationQueue()
  XMissionConversationSystem.conversationQueue = {}
end
function XMissionConversationSystem.HaveConversation()
  if #XMissionConversationSystem.conversationQueue == 0 and not XMissionConversationSystem.bPlaying then
    return false
  end
  return true
end
function XMissionConversationSystem.OnConversationDone(_, _, plotID)
  log(bWriteLog and "XMissionConversationSystem.OnConversationDone, plotID = " .. tostring(plotID))
  XMissionConversationSystem.bPlaying = false
  if not plotID then
    return
  end
  if #XMissionConversationSystem.conversationQueue == 0 then
    return
  end
  local conversation = XMissionConversationSystem.conversationQueue[1]
  local conversation_type = conversation.type
  log_tree("XMissionConversationSystem.OnConversationDone conversationQueue = ", XMissionConversationSystem.conversationQueue)
  if conversation.plotID ~= plotID then
    return
  end
  local timer_ticker = require("common.time_ticker")
  if XMissionConversationSystem.nextConversationTimer then
    timer_ticker.RemoveTimer(XMissionConversationSystem.nextConversationTimer)
    XMissionConversationSystem.nextConversationTimer = nil
  end
  if conversation.plotID == XMissionConversationSystem.INSURANCE_GUIDE_PLOTID then
    EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_NPC_INSURANCE_GIFT)
  end
  if conversation.plotID == XMissionConversationSystem.INSURANCE_REMAIN_PLOTID then
    conversation.type = E_ConversationAwardType.Tips
    conversation.param = LocUtil.GetLocalizeResStr(48345)
  end
  local XMissionNpcSystem = require("client.slua.logic.TxMission.logic_xmission_npc")
  local nextConversationTime = 0
  conversation = table.remove(XMissionConversationSystem.conversationQueue, 1)
  if XMissionConversationSystem.conversationQueue[1] and conversation_type == 0 and (XMissionConversationSystem.conversationQueue[1].plotID == XMissionConversationSystem.REPUTATION_ADJUST_NOTIFI or XMissionConversationSystem.conversationQueue[1].plotID == XMissionConversationSystem.WEEKEND_TALENT_OPEN) then
    nextConversationTime = 1
  end
  if conversation.type == E_ConversationAwardType.Item then
    local awardList = conversation.param
    if awardList and type(awardList) == "table" and next(awardList) then
      local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
      if conversation.business == XMissionNpcSystem.E_PlotParamType.BeginnerGuide then
        local tExtendData = {
          fCloseCallback = function()
            local LogicXMissionBeginnerGuide = require("client.slua.logic.TxMission.logic_xmission_beginner_guide")
            if LogicXMissionBeginnerGuide.IsGuidingSellItemAfterBattle() then
              LogicXMissionBeginnerGuide.SyncLocalProgress()
            end
            LogicXMissionBeginnerGuide.ContinueBeginnerGuide()
          end
        }
        Logic_CommonItemGet.ShowPanel_DefaultStyle(awardList, true, true, tExtendData)
      else
        local tExtendData = {
          fCloseCallback = function()
            if conversation.itemGetCloseCallback then
              conversation.itemGetCloseCallback()
            end
            XMissionConversationSystem.NextConversation()
          end
        }
        if Client and Client.IsDevelopment() then
          for _, v in pairs(awardList) do
            if type(v) ~= "table" then
              ShowDevNotice("### \239\188\129\239\188\129\239\188\129\230\138\165\233\148\153\228\186\134\239\188\140\233\186\187\231\131\166\229\143\150\230\151\165\229\191\151\232\129\148\231\179\187\228\184\139 yuncaihuang")
              local utility = require("common.utility")
              local sMsg = "XMissionConversationSystem.OnConversationDone Show Get Item Error: "
              utility.ErrorMessageHandlerExtra(sMsg, nil, sMsg)
              break
            end
          end
        end
        Logic_CommonItemGet.ShowPanel_DefaultStyle(awardList, false, true, tExtendData)
      end
    end
  elseif conversation.type == E_ConversationAwardType.Tips then
    local msg = conversation.param
    if msg and type(msg) == "string" and msg ~= "" then
      ShowNotice(msg)
      nextConversationTime = 1
    end
  elseif conversation.type == E_ConversationAwardType.Jump then
    local jumpStr = conversation.param
    if jumpStr and type(jumpStr) == "string" and jumpStr ~= "" then
      XMissionConversationSystem:ClearConversationQueue()
      GlobalData.JumpUrl(jumpStr)
    end
  end
  if conversation.business ~= XMissionNpcSystem.E_PlotParamType.BeginnerGuide and #XMissionConversationSystem.conversationQueue > 0 and 0 < nextConversationTime then
    XMissionConversationSystem.nextConversationTimer = timer_ticker.AddTimerOnce(nextConversationTime, function()
      EventSystem:postEvent(EVENTTYPE_COMMON_ITEM_GET, EVENTID_CHECK_NEXT_SHOW)
      log(bWriteLog and "XMissionConversationSystem.OnConversationDone, conversation.business ~= XMissionNpcSystem.E_PlotParamType.BeginnerGuide . ")
      XMissionConversationSystem.NextConversation()
      if XMissionConversationSystem.nextConversationTimer then
        timer_ticker.RemoveTimer(XMissionConversationSystem.nextConversationTimer)
      end
      XMissionConversationSystem.nextConversationTimer = nil
    end)
  end
end
function XMissionConversationSystem.IsPlaying()
  return XMissionConversationSystem.bPlaying
end
return XMissionConversationSystem