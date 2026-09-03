local LogicXMissionBeginnerGuide = {
  state_NotStart = 0,
  state_ReceivedGift = 10,
  state_Equiped = 20,
  state_HaveClickedLevel = 50,
  state_HaveClickedStart = 100,
  state_ReceivedReward = 1000,
  state_End = 10000,
  state_NoRecord = 0,
  state_HaveRecord = 1,
  state_CompletedGuide = 2,
  haveReceivedInfo = false,
  widget = nil,
  currentProgress = 0,
  currentState = {
    state = 0,
    victory = 0,
    defeat = 0,
    victoryCount = 0,
    totalCount = 0
  },
  videoPath = "./MoviesPakDir/XMission_Guider.mp4",
  test = false,
  disable = false
}
function LogicXMissionBeginnerGuide.OnModePostSwitch(preState, nextState)
  log(bWriteLog and "LogicXMissionBeginnerGuide.OnModePostSwitch, nextState = " .. tostring(nextState))
  if nextState == GameStatus.Lobby then
    if LogicXMissionBeginnerGuide.test then
      LogicXMissionBeginnerGuide.haveReceivedInfo = true
    else
      LogicXMissionBeginnerGuide.GetGuideStateReq()
    end
  end
end
function LogicXMissionBeginnerGuide.ClearData()
  log(bWriteLog and "LogicXMissionBeginnerGuide.ClearData")
  LogicXMissionBeginnerGuide.currentProgress = 0
  LogicXMissionBeginnerGuide.haveReceivedInfo = false
  LogicXMissionBeginnerGuide.currentState = {
    state = 0,
    victory = 0,
    defeat = 0,
    victoryCount = 0,
    totalCount = 0
  }
end
function LogicXMissionBeginnerGuide.GetCurrentState()
  log_tree("LogicXMissionBeginnerGuide.GetCurrentState, currentState = ", LogicXMissionBeginnerGuide.currentState)
  return LogicXMissionBeginnerGuide.currentState
end
function LogicXMissionBeginnerGuide.HaveFinishedBeginnerGuide()
  local result = false
  if LogicXMissionBeginnerGuide.currentState.state == LogicXMissionBeginnerGuide.state_End then
    result = true
  end
  if LogicXMissionBeginnerGuide.haveReceivedInfo == false then
    result = true
  elseif LogicXMissionBeginnerGuide.currentState.state == LogicXMissionBeginnerGuide.state_HaveClickedStart then
    result = true
  elseif LogicXMissionBeginnerGuide.currentState.state == LogicXMissionBeginnerGuide.state_ReceivedReward and LogicXMissionBeginnerGuide.currentState.totalCount > 0 then
    if LogicXMissionBeginnerGuide.currentState.victory ~= LogicXMissionBeginnerGuide.state_HaveRecord and LogicXMissionBeginnerGuide.currentState.defeat ~= LogicXMissionBeginnerGuide.state_HaveRecord then
      result = true
    end
    if LogicXMissionBeginnerGuide.currentState.totalCount == 1 and LogicXMissionBeginnerGuide.currentState.victory == 0 then
      result = false
    end
  end
  if LogicXMissionBeginnerGuide.disable == true then
    result = true
  end
  local skipUI = UIManager.GetUI(UIManager.UI_Config.Xmission_Guide_Skip_UIBP)
  if result and skipUI then
    skipUI:CloseSelf()
  end
  log(bWriteLog and "LogicXMissionBeginnerGuide.HaveFinishedBeginnerGuide, result = " .. tostring(result))
  return result
end
function LogicXMissionBeginnerGuide.IsGuidingEquipItem(progress)
  local result = false
  if LogicXMissionBeginnerGuide.currentState.state == LogicXMissionBeginnerGuide.state_ReceivedGift and (progress == nil or LogicXMissionBeginnerGuide.currentProgress == progress) then
    result = true
  end
  log(bWriteLog and "LogicXMissionBeginnerGuide.IsGuidingEquipItem, progress = " .. tostring(progress) .. ", result = " .. tostring(result))
  return result
end
function LogicXMissionBeginnerGuide.IsGuidingDepositItemAfterBattle()
  local result = false
  if LogicXMissionBeginnerGuide.currentState.state == LogicXMissionBeginnerGuide.state_ReceivedReward and LogicXMissionBeginnerGuide.currentState.victory == LogicXMissionBeginnerGuide.state_HaveRecord then
    result = true
  end
  log(bWriteLog and "LogicXMissionBeginnerGuide.IsGuidingDepositItemAfterBattle, result = " .. tostring(result))
  return result
end
function LogicXMissionBeginnerGuide.IsGuidingEquipItemAfterBattle()
  local result = false
  if LogicXMissionBeginnerGuide.currentState.state == LogicXMissionBeginnerGuide.state_ReceivedReward and LogicXMissionBeginnerGuide.currentState.defeat == LogicXMissionBeginnerGuide.state_HaveRecord then
    result = true
  end
  log(bWriteLog and "LogicXMissionBeginnerGuide.IsGuidingEquipItemAfterBattle, result = " .. tostring(result))
  return result
end
function LogicXMissionBeginnerGuide.IsGuidingSellItemAfterBattle()
  local result = false
  if LogicXMissionBeginnerGuide.currentState.state == LogicXMissionBeginnerGuide.state_ReceivedReward and (LogicXMissionBeginnerGuide.currentState.victory == LogicXMissionBeginnerGuide.state_HaveRecord or LogicXMissionBeginnerGuide.currentState.defeat == LogicXMissionBeginnerGuide.state_HaveRecord) then
    result = true
  end
  log(bWriteLog and "LogicXMissionBeginnerGuide.IsGuidingSellItemAfterBattle, result = " .. tostring(result))
  return result
end
function LogicXMissionBeginnerGuide.IsGuidingLevelReward()
  local result = false
  if LogicXMissionBeginnerGuide.currentState.state == LogicXMissionBeginnerGuide.state_Equiped then
    result = true
  end
  log(bWriteLog and "LogicXMissionBeginnerGuide.IsGuidingLevelReward, result = " .. tostring(result))
  return result
end
function LogicXMissionBeginnerGuide.GetStateAndProgress()
  local state = LogicXMissionBeginnerGuide.currentState.state
  local progress = LogicXMissionBeginnerGuide.currentProgress
  log(bWriteLog and "LogicXMissionBeginnerGuide.GetStateAndProgress, state = " .. tostring(state) .. ", progress = " .. tostring(progress))
  return state, progress
end
function LogicXMissionBeginnerGuide.GetItemWidget()
  return LogicXMissionBeginnerGuide.widget
end
function LogicXMissionBeginnerGuide.ShowTipsWhenLeaderStartGameFailed()
  log(bWriteLog and "LogicXMissionBeginnerGuide.ShowTipsWhenLeaderStartGameFailed")
  ShowNotice(LocUtil.GetLocalizeResStr(22014))
end
function LogicXMissionBeginnerGuide.SyncLocalProgress()
  log(bWriteLog and "LogicXMissionBeginnerGuide.SyncLocalProgress, currentProgress = " .. tostring(LogicXMissionBeginnerGuide.currentProgress) .. " --> " .. tostring(LogicXMissionBeginnerGuide.currentProgress + 1))
  LogicXMissionBeginnerGuide.currentProgress = LogicXMissionBeginnerGuide.currentProgress + 1
end
function LogicXMissionBeginnerGuide.ContinueBeginnerGuide(widget)
  log(bWriteLog and "LogicXMissionBeginnerGuide.ContinueBeginnerGuide")
  if UIManager.IsUIShow(UIManager.UI_Config.ModeSelection_Opening_Train_UIBP) then
    local time_ticker = require("common.time_ticker")
    time_ticker.AddTimerOnce(1, LogicXMissionBeginnerGuide.ContinueBeginnerGuide, widget)
    return
  end
  log_tree("LogicXMissionBeginnerGuide.currentState = ", LogicXMissionBeginnerGuide.currentState)
  log_tree("LogicXMissionBeginnerGuide.currentProgress = ", LogicXMissionBeginnerGuide.currentProgress)
  if LogicXMissionBeginnerGuide.HaveFinishedBeginnerGuide() then
    log(bWriteLog and "LogicXMissionBeginnerGuide.ContinueBeginnerGuide 1")
    return
  end
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if LogicTxMissionMain.IsInXMission() == false then
    log(bWriteLog and "LogicXMissionBeginnerGuide.ContinueBeginnerGuide 2")
    return
  end
  local logic_xmission_room_team = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_room_team)
  if logic_xmission_room_team:IsSelfInXmissionRoom() then
    log(bWriteLog and "LogicXMissionBeginnerGuide.ContinueBeginnerGuide room return")
    return
  end
  UIManager.HideUI(UIManager.UI_Config.ModeSelection_Select_UIBP)
  if LogicXMissionBeginnerGuide.currentState.state > LogicXMissionBeginnerGuide.state_NotStart and not UIManager.IsUIShow(UIManager.UI_Config.Xmission_Guide_Skip_UIBP) and UIManager.IsUIShow(UIManager.UI_Config.xmission_main) and not UIManager.IsUIShow(UIManager.UI_Config.Xmission_Room_UIBP) and LogicXMissionBeginnerGuide.currentState.state ~= LogicXMissionBeginnerGuide.state_HaveClickedLevel then
    UIManager.ShowUI(UIManager.UI_Config.Xmission_Guide_Skip_UIBP)
  end
  if LogicTxMissionMain.IsTalentSystemOpen(false) == false or DataMgr.GetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_XMISSION_TALENT, 2) ~= nil then
    log(bWriteLog and "LogicXMissionBeginnerGuide.ContinueBeginnerGuide 3")
    LogicXMissionBeginnerGuide.    if LogicXMissionBeginnerGuide.currentState.state == LogicXMissionBeginnerGuide.state_NotStart then
      log(bWriteLog and "LogicXMissionBeginnerGuide.ContinueBeginnerGuide 4")
      LogicXMissionBeginnerGuide.PlayBeginnerVideo()
    elseif LogicXMissionBeginnerGuide.currentState.state == LogicXMissionBeginnerGuide.state_ReceivedGift then
      log(bWriteLog and "LogicXMissionBeginnerGuide.ContinueBeginnerGuide 5")
      if LogicXMissionBeginnerGuide.currentProgress == 0 then
        log(bWriteLog and "LogicXMissionBeginnerGuide.ContinueBeginnerGuide 6")
        local ui = UIManager.GetUI(UIManager.UI_Config.xmission_main)
        if ui then
          log(bWriteLog and "LogicXMissionBeginnerGuide.ContinueBeginnerGuide 7")
          LogicXMissionBeginnerGuide.widget = ui.UIRoot.Button_Wardrobe
          if LogicTxMissionMain.IsInPureXMissionLobby() and not LogicXMissionBeginnerGuide.HaveFinishedBeginnerGuide() then
            log(bWriteLog and "LogicXMissionBeginnerGuide.ContinueBeginnerGuide 8")
            UIManager.ShowUI(UIManager.UI_Config.xmission_beginner_guide)
          end
        end
      else
        log(bWriteLog and "LogicXMissionBeginnerGuide.ContinueBeginnerGuide 9")
        local ui = UIManager.GetUI(UIManager.UI_Config.xmission_beginner_guide)
        if ui then
          log(bWriteLog and "LogicXMissionBeginnerGuide.ContinueBeginnerGuide 10")
          ui:RefreshUI()
        else
          log(bWriteLog and "LogicXMissionBeginnerGuide.ContinueBeginnerGuide 11")
          if LogicTxMissionMain.IsInPureXMissionLobby() and not LogicXMissionBeginnerGuide.HaveFinishedBeginnerGuide() then
            log(bWriteLog and "LogicXMissionBeginnerGuide.ContinueBeginnerGuide 12")
            UIManager.ShowUI(UIManager.UI_Config.xmission_beginner_guide)
          end
        end
      end
    elseif LogicXMissionBeginnerGuide.currentState.state == LogicXMissionBeginnerGuide.state_Equiped then
      log(bWriteLog and "LogicXMissionBeginnerGuide.ContinueBeginnerGuide 13")
      if LogicTxMissionMain.IsInPureXMissionLobby() and not LogicXMissionBeginnerGuide.HaveFinishedBeginnerGuide() then
        log(bWriteLog and "LogicXMissionBeginnerGuide.ContinueBeginnerGuide 14")
        UIManager.ShowUI(UIManager.UI_Config.xmission_beginner_guide)
      end
    elseif LogicXMissionBeginnerGuide.currentState.state == LogicXMissionBeginnerGuide.state_HaveClickedLevel then
      log(bWriteLog and "LogicXMissionBeginnerGuide.ContinueBeginnerGuide 15")
      if LogicTxMissionMain.IsInPureXMissionLobby() and not LogicXMissionBeginnerGuide.HaveFinishedBeginnerGuide() then
        log(bWriteLog and "LogicXMissionBeginnerGuide.ContinueBeginnerGuide 16")
        local ui = UIManager.GetUI(UIManager.UI_Config.xmission_main)
        if ui then
          local entryUI = ui.subUIs[UIManager.UI_Config.xmission_match_entry.keyName]
          if entryUI then
            entryUI.UIRoot.CanvasPanel_FirstGuide:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
            entryUI.UIRoot.UTRichTextBlock_1:SetText(LocUtil.GetLocalizeResStr(11664))
          end
        end
      end
    elseif LogicXMissionBeginnerGuide.currentState.state == LogicXMissionBeginnerGuide.state_ReceivedReward then
      log(bWriteLog and "LogicXMissionBeginnerGuide.ContinueBeginnerGuide 17")
      if LogicXMissionBeginnerGuide.currentState.victory == LogicXMissionBeginnerGuide.state_HaveRecord then
        log(bWriteLog and "LogicXMissionBeginnerGuide.ContinueBeginnerGuide 18")
        if LogicXMissionBeginnerGuide.currentState.victoryCount == 1 then
          if LogicXMissionBeginnerGuide.currentProgress == 0 then
            if LogicXMissionBeginnerGuide.currentState.totalCount == 1 then
              local XMissionConversationSystem = require("client.slua.logic.TxMission.logic_xmission_conversation")
              if XMissionConversationSystem.HaveBeginnerGuideConversation() then
                log(bWriteLog and "LogicXMissionBeginnerGuide.ContinueBeginnerGuide1, XMissionConversationSystem.HaveBeginnerGuideConversation(). ")
                XMissionConversationSystem.NextConversation()
              else
                LogicXMissionBeginnerGuide.SyncLocalProgress()
                LogicXMissionBeginnerGuide.ContinueBeginnerGuide()
                return
              end
            else
              local ui = UIManager.GetUI(UIManager.UI_Config.xmission_main)
              if ui then
                LogicXMissionBeginnerGuide.widget = ui.UIRoot.Button_Wardrobe
                if LogicTxMissionMain.IsInPureXMissionLobby() and not LogicXMissionBeginnerGuide.HaveFinishedBeginnerGuide() then
                  UIManager.ShowUI(UIManager.UI_Config.xmission_beginner_guide)
                end
              end
            end
          elseif LogicXMissionBeginnerGuide.currentProgress == 1 then
            if LogicXMissionBeginnerGuide.currentState.totalCount == 1 then
              local ui = UIManager.GetUI(UIManager.UI_Config.xmission_main)
              if ui then
                LogicXMissionBeginnerGuide.widget = ui.UIRoot.Button_Wardrobe
                if LogicTxMissionMain.IsInPureXMissionLobby() and not LogicXMissionBeginnerGuide.HaveFinishedBeginnerGuide() then
                  UIManager.ShowUI(UIManager.UI_Config.xmission_beginner_guide)
                end
              end
            else
              local ui = UIManager.GetUI(UIManager.UI_Config.xmission_main)
              if ui then
                ui:ShowBeginnerGuideTips("blackmarket", true)
              end
            end
          elseif LogicXMissionBeginnerGuide.currentProgress == 2 then
            if LogicXMissionBeginnerGuide.currentState.totalCount == 1 then
              local ui = UIManager.GetUI(UIManager.UI_Config.xmission_main)
              if ui then
                LogicXMissionBeginnerGuide.widget = ui.UIRoot.Button_FoldUI_Unfold
                if LogicTxMissionMain.IsInPureXMissionLobby() and not LogicXMissionBeginnerGuide.HaveFinishedBeginnerGuide() then
                  UIManager.ShowUI(UIManager.UI_Config.xmission_beginner_guide)
                end
              end
            else
              local ui = UIManager.GetUI(UIManager.UI_Config.xmission_main)
              if ui then
                ui:ShowBeginnerGuideTips("blackmarket", true)
              end
            end
          else
            local ui = UIManager.GetUI(UIManager.UI_Config.xmission_main)
            if ui then
              ui:ShowBeginnerGuideTips("blackmarket", true)
            end
          end
        else
          local ui = UIManager.GetUI(UIManager.UI_Config.xmission_main)
          if ui then
            ui:ShowBeginnerGuideTips("wardrobe", true)
          end
        end
      elseif 0 < LogicXMissionBeginnerGuide.currentState.totalCount and 0 >= LogicXMissionBeginnerGuide.currentState.victoryCount then
        log(bWriteLog and "LogicXMissionBeginnerGuide.ContinueBeginnerGuide 51")
        if LogicXMissionBeginnerGuide.currentProgress == 0 then
          log(bWriteLog and "LogicXMissionBeginnerGuide.ContinueBeginnerGuide 52")
          local ui = UIManager.GetUI(UIManager.UI_Config.xmission_main)
          if ui then
            log(bWriteLog and "LogicXMissionBeginnerGuide.ContinueBeginnerGuide 53")
            LogicXMissionBeginnerGuide.widget = ui.UIRoot.Button_FoldUI_Unfold
            if LogicTxMissionMain.IsInPureXMissionLobby() and not LogicXMissionBeginnerGuide.HaveFinishedBeginnerGuide() then
              log(bWriteLog and "LogicXMissionBeginnerGuide.ContinueBeginnerGuide 54")
              UIManager.ShowUI(UIManager.UI_Config.xmission_beginner_guide)
            end
          end
        else
          log(bWriteLog and "LogicXMissionBeginnerGuide.ContinueBeginnerGuide 55")
          local ui = UIManager.GetUI(UIManager.UI_Config.xmission_main)
          if ui then
            log(bWriteLog and "LogicXMissionBeginnerGuide.ContinueBeginnerGuide 56")
            ui:ShowBeginnerGuideTips("blackmarket", true)
            LogicXMissionBeginnerGuide.SyncGuideStateReq(LogicXMissionBeginnerGuide.state_End)
            LogicXMissionBeginnerGuide.currentState.state = LogicXMissionBeginnerGuide.state_End
          end
        end
      elseif LogicXMissionBeginnerGuide.currentState.defeat == LogicXMissionBeginnerGuide.state_HaveRecord then
        log(bWriteLog and "LogicXMissionBeginnerGuide.ContinueBeginnerGuide 30")
        if LogicXMissionBeginnerGuide.currentProgress == 0 then
          log(bWriteLog and "LogicXMissionBeginnerGuide.ContinueBeginnerGuide 31")
          local XMissionConversationSystem = require("client.slua.logic.TxMission.logic_xmission_conversation")
          if XMissionConversationSystem.HaveBeginnerGuideConversation() then
            log(bWriteLog and "LogicXMissionBeginnerGuide.ContinueBeginnerGuide 32")
            XMissionConversationSystem.NextConversation()
          else
            log(bWriteLog and "LogicXMissionBeginnerGuide.ContinueBeginnerGuide 33")
            LogicXMissionBeginnerGuide.SyncLocalProgress()
            LogicXMissionBeginnerGuide.ContinueBeginnerGuide()
            return
          end
        elseif LogicXMissionBeginnerGuide.currentProgress == 1 then
          log(bWriteLog and "LogicXMissionBeginnerGuide.ContinueBeginnerGuide 34")
          if LogicXMissionBeginnerGuide.currentState.totalCount == 1 then
            log(bWriteLog and "LogicXMissionBeginnerGuide.ContinueBeginnerGuide 35")
            local XMissionConversationSystem = require("client.slua.logic.TxMission.logic_xmission_conversation")
            if XMissionConversationSystem.HaveBeginnerGuideConversation() then
              log(bWriteLog and "LogicXMissionBeginnerGuide.ContinueBeginnerGuide 36")
              XMissionConversationSystem.NextConversation()
            else
              log(bWriteLog and "LogicXMissionBeginnerGuide.ContinueBeginnerGuide 37")
              LogicXMissionBeginnerGuide.SyncLocalProgress()
              LogicXMissionBeginnerGuide.ContinueBeginnerGuide()
              return
            end
          else
            log(bWriteLog and "LogicXMissionBeginnerGuide.ContinueBeginnerGuide 38")
            local ui = UIManager.GetUI(UIManager.UI_Config.xmission_main)
            if ui then
              log(bWriteLog and "LogicXMissionBeginnerGuide.ContinueBeginnerGuide 39")
              LogicXMissionBeginnerGuide.widget = ui.UIRoot.Button_Wardrobe
              if LogicTxMissionMain.IsInPureXMissionLobby() and not LogicXMissionBeginnerGuide.HaveFinishedBeginnerGuide() then
                log(bWriteLog and "LogicXMissionBeginnerGuide.ContinueBeginnerGuide 40")
                UIManager.ShowUI(UIManager.UI_Config.xmission_beginner_guide)
              end
            end
          end
        elseif LogicXMissionBeginnerGuide.currentProgress == 2 then
          log(bWriteLog and "LogicXMissionBeginnerGuide.ContinueBeginnerGuide 41")
          if LogicXMissionBeginnerGuide.currentState.totalCount == 1 then
            log(bWriteLog and "LogicXMissionBeginnerGuide.ContinueBeginnerGuide 42")
            local ui = UIManager.GetUI(UIManager.UI_Config.xmission_main)
            if ui then
              log(bWriteLog and "LogicXMissionBeginnerGuide.ContinueBeginnerGuide 43")
              LogicXMissionBeginnerGuide.widget = ui.UIRoot.Button_Wardrobe
              if LogicTxMissionMain.IsInPureXMissionLobby() and not LogicXMissionBeginnerGuide.HaveFinishedBeginnerGuide() then
                log(bWriteLog and "LogicXMissionBeginnerGuide.ContinueBeginnerGuide 44")
                UIManager.ShowUI(UIManager.UI_Config.xmission_beginner_guide)
              end
            end
          end
        elseif LogicXMissionBeginnerGuide.currentProgress == 3 then
          log(bWriteLog and "LogicXMissionBeginnerGuide.ContinueBeginnerGuide 45")
          local ui = UIManager.GetUI(UIManager.UI_Config.xmission_main)
          log(bWriteLog and "LogicXMissionBeginnerGuide.ContinueBeginnerGuide 46")
          if ui then
            log(bWriteLog and "LogicXMissionBeginnerGuide.ContinueBeginnerGuide 47")
            ui:ShowBeginnerGuideTips("blackmarket", true)
          end
        end
      end
    end
    LogicXMissionBeginnerGuide.widget = nil
  else
    log(bWriteLog and "LogicXMissionBeginnerGuide.ContinueBeginnerGuide 50")
  end
end
function LogicXMissionBeginnerGuide.FinishDragGuide(parent, widget)
  if LogicXMissionBeginnerGuide.IsGuidingEquipItem(3) then
    log(bWriteLog and "LogicXMissionBeginnerGuide.FinishDragGuide")
    LogicXMissionBeginnerGuide.SyncLocalProgress()
  elseif LogicXMissionBeginnerGuide.IsGuidingEquipItem(4) then
    LogicXMissionBeginnerGuide.SyncGuideStateReq(LogicXMissionBeginnerGuide.state_HaveClickedLevel)
    UIManager.CloseUI(UIManager.UI_Config.xmission_beginner_guide)
    UIManager.CloseUI(UIManager.UI_Config.Xmission_Guide_Skip_UIBP)
    if parent and widget then
      parent:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      widget:SetText(LocUtil.GetLocalizeResStr(11680))
    end
  end
end
function LogicXMissionBeginnerGuide.GetVideoShowCloseBtnTime()
  local showCloseTime = 20
  local key = 98765
  if LobbySystem.LobbyMenuOpenStatus[key] == nil then
    log(bWriteLog and "LogicXMissionBeginnerGuide.GetVideoShowCloseBtnTime, have't received data, read local.")
    local maxPowerCfg = CDataTable.GetTableData("TxMissionExtra", "guide_video_watch_time")
    if maxPowerCfg then
      showCloseTime = maxPowerCfg.value
    end
  else
    showCloseTime = LobbySystem.LobbyMenuOpenStatus[key].is_open
  end
  log(bWriteLog and "LogicXMissionBeginnerGuide.GetVideoShowCloseBtnTime, showCloseTime = " .. tostring(showCloseTime))
  return showCloseTime
end
function LogicXMissionBeginnerGuide.PlayBeginnerVideo()
  local VideoLibrary = require("client.slua.logic.video.lobby_video_function_library")
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsCEVersion() then
    return
  end
  if PublishRegionMacros.BLUEHOLE == Client.GetPublishRegion() then
    LogicXMissionBeginnerGuide.OnVideoEnd(nil, nil, LogicXMissionBeginnerGuide.videoPath)
    return
  end
  EventSystem:registEvent(EVENTTYPE_VIDEO, EVENTID_VIDEO_ENDS, LogicXMissionBeginnerGuide.OnVideoEnd)
  local showCloseTime = LogicXMissionBeginnerGuide.GetVideoShowCloseBtnTime()
  local result = VideoLibrary.PlayVideo(LogicXMissionBeginnerGuide.videoPath, {animation = true, topRightClose = true})
  if result == false then
    EventSystem:unregistEvent(EVENTTYPE_VIDEO, EVENTID_VIDEO_ENDS, LogicXMissionBeginnerGuide.OnVideoEnd)
    LogicXMissionBeginnerGuide.OnVideoEnd(nil, nil, LogicXMissionBeginnerGuide.videoPath)
  end
end
function LogicXMissionBeginnerGuide.OnVideoEnd(_, _, filePath)
  log(bWriteLog and "LogicXMissionBeginnerGuide.OnVideoEnd, filePath = " .. tostring(filePath))
  if filePath == LogicXMissionBeginnerGuide.videoPath then
    LogicXMissionBeginnerGuide.SyncGuideStateReq(LogicXMissionBeginnerGuide.state_ReceivedGift)
    EventSystem:unregistEvent(EVENTTYPE_VIDEO, EVENTID_VIDEO_ENDS, LogicXMissionBeginnerGuide.OnVideoEnd)
  end
end
function LogicXMissionBeginnerGuide.GetGuideStateReq()
  log(bWriteLog and "LogicXMissionBeginnerGuide.GetGuideStateReq, haveReceivedInfo = " .. tostring(LogicXMissionBeginnerGuide.haveReceivedInfo))
  local TxMissionHandler = require("client.network.Protocol.TxMissionHandler")
  TxMissionHandler.send_metro_guide_query_req()
end
function LogicXMissionBeginnerGuide.GetGuideStateRsp(err, state, victoryCount, totalCount)
  log(bWriteLog and "LogicXMissionBeginnerGuide.GetGuideStateRsp, victoryCount = " .. tostring(victoryCount) .. ", totalCount = " .. tostring(totalCount))
  log_tree("LogicXMissionBeginnerGuide.GetGuideStateRsp, state = ", state)
  LogicXMissionBeginnerGuide.currentState = {
    state = state and state.progress or 0,
    victory = state and state.win_status or 0,
    defeat = state and state.lose_status or 0,
    victoryCount = victoryCount or 0,
    totalCount = totalCount or 0
  }
  LogicXMissionBeginnerGuide.haveReceivedInfo = true
  LogicXMissionBeginnerGuide.currentProgress = 0
  local func
  local time_ticker = require("common.time_ticker")
  function func()
    LogicXMissionBeginnerGuide.ContinueBeginnerGuide()
  end
end
function LogicXMissionBeginnerGuide.SyncGuideStateReq(state)
  log(bWriteLog and "LogicXMissionBeginnerGuide.SyncGuideStateReq, state = " .. tostring(state))
  if state > LogicXMissionBeginnerGuide.currentState.state then
    LogicXMissionBeginnerGuide.currentProgress = 0
    local TxMissionHandler = require("client.network.Protocol.TxMissionHandler")
    TxMissionHandler.send_metro_guide_set_progress_req(state)
  end
end
function LogicXMissionBeginnerGuide.SyncGuideStateRsp(err, state)
  log(bWriteLog and "LogicXMissionBeginnerGuide.SyncGuideStateRsp, state = " .. tostring(state))
  LogicXMissionBeginnerGuide.currentState.end
function LogicXMissionBeginnerGuide.SyncGuideBattleStateReq(state)
  local battle
  if LogicXMissionBeginnerGuide.currentState.victory == LogicXMissionBeginnerGuide.state_HaveRecord then
    battle = 1
  elseif LogicXMissionBeginnerGuide.currentState.defeat == LogicXMissionBeginnerGuide.state_HaveRecord then
    battle = 2
  end
  log(bWriteLog and "LogicXMissionBeginnerGuide.SyncGuideBattleStateReq, battle = " .. tostring(battle) .. ", state = " .. tostring(state))
  if battle ~= nil then
    local TxMissionHandler = require("client.network.Protocol.TxMissionHandler")
    TxMissionHandler.send_metro_guide_set_status_req(battle, state)
  end
  if LogicXMissionBeginnerGuide.state_CompletedGuide == state then
    LogicXMissionBeginnerGuide.SyncGuideStateReq(LogicXMissionBeginnerGuide.state_End)
    LogicXMissionBeginnerGuide.currentState.state = LogicXMissionBeginnerGuide.state_End
    local skipUI = UIManager.GetUI(UIManager.UI_Config.Xmission_Guide_Skip_UIBP)
    if skipUI then
      skipUI:CloseSelf()
    end
  end
end
function LogicXMissionBeginnerGuide.SyncGuideBattleStateRsp(err, battle, state)
  log(bWriteLog and "LogicXMissionBeginnerGuide.SyncGuideBattleStateRsp, battle = " .. tostring(battle) .. ", state = " .. tostring(state))
  if battle == 1 then
    LogicXMissionBeginnerGuide.currentState.victory = state
  elseif battle == 2 then
    LogicXMissionBeginnerGuide.currentState.defeat = state
  end
  if LogicXMissionBeginnerGuide.state_CompletedGuide == state then
    LogicXMissionBeginnerGuide.SyncGuideStateReq(LogicXMissionBeginnerGuide.state_End)
    LogicXMissionBeginnerGuide.currentState.state = LogicXMissionBeginnerGuide.state_End
    local skipUI = UIManager.GetUI(UIManager.UI_Config.Xmission_Guide_Skip_UIBP)
    if skipUI then
      skipUI:CloseSelf()
    end
  end
end
return LogicXMissionBeginnerGuide