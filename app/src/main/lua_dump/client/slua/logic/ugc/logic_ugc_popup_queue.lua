local logic_ugc_popup_queue = {}
local ASYNC_TIME_OUT = 10
function logic_ugc_popup_queue:ctor()
  self.PopupTipsQueue = nil
  self.ShowNextCD = 0.2
  self.iCurShowIndex = 0
  self.ext_event_stat = {}
  self.cur_show_queue = {}
  self.bReset = false
  self.scene_type = nil
  self.nCheckQuiteQueueGM = false
end
function logic_ugc_popup_queue:OnInitialize()
  self.queue_cfg = require("client.slua.logic.ugc.config_ugc_popup_queue")
  self:InitIntentionCfg()
  self.showePopupMap = {}
  for i, v in pairs(self.queue_cfg) do
    if not self.showePopupMap[v.scene_type] then
      self.showePopupMap[v.scene_type] = {}
      self.showePopupMap[v.scene_type].need_show_cnt = 0
    end
    if not self.showePopupMap[v.scene_type][v.ui_cfg.ui_name] then
      self.showePopupMap[v.scene_type][v.ui_cfg.ui_name] = {hide = false, need_show = false}
    end
  end
end
function logic_ugc_popup_queue:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_OLD_WIDGET, EVENTID_ON_ALL_WIDGET_HIDE, self.OnWidgetHide, self)
  if self.queue_cfg then
    for _, v in pairs(self.queue_cfg) do
      if v.ext_event and v.ext_event.type and v.ext_event.id then
        self:AddCommonEvent(v.ext_event.type, v.ext_event.id, self.OnDelayEvent, self)
      end
    end
  end
end
function logic_ugc_popup_queue:OnLogin()
end
function logic_ugc_popup_queue:OnLogOut()
  self.PopupTipsQueue = nil
  self.ext_event_stat = nil
end
local WaitDataStatus = {
  Wait = 1,
  TimeOut = 2,
  Completed = 3
}
function logic_ugc_popup_queue:OnWidgetHide(_, _, keyName)
  log(bWriteLog and "logic_ugc_popup_queue:OnWidgetHide keyName = " .. tostring(keyName))
  if not self.showePopupMap or not self.scene_type then
    return
  end
  if self._inWidgetHide then
    log(bWriteLog and "logic_ugc_popup_queue:OnWidgetHide already in process, skip recursive call")
    return
  end
  self._inWidgetHide = true
  for scene_type, v in pairs(self.showePopupMap) do
    if self.scene_type == scene_type then
      for key_name, uidata in pairs(v) do
        if key_name == keyName then
          uidata.hide = true
          log(bWriteLog and "logic_ugc_popup_queue:OnWidgetHide keyName = " .. keyName .. " be close")
          self:CheckEnd(scene_type)
          break
        end
      end
    end
  end
  self._inWidgetHide = nil
end
function logic_ugc_popup_queue:BeginShowTips(scene_type)
  if not self:CheckCanShow(scene_type) then
    return
  end
  self.  local iListCount = self.cur_show_queue and #self.cur_show_queue or 0
  log(bWriteLog and "logic_ugc_popup_queue:BeginShowTips, #queue = " .. tostring(iListCount))
  for i = 1, iListCount do
    local info = self.cur_show_queue[i]
    if info then
      if not self.showePopupMap[scene_type][info.ui_cfg.ui_name].need_show then
        if info.ext_event and info.ext_event.type and info.ext_event.id then
          local key = info.ext_event.type .. "_" .. info.ext_event.id
          if not self.ext_event_stat[key] then
            self:_DelayCheckExtEvent(info.ext_event.type, info.ext_event.id, scene_type)
            log(bWriteLog and "logic_ugc_popup_queue:BeginShowTips return because ext_event not has, will wait for response key = " .. key)
            break
          end
          if self.ext_event_stat[key] == WaitDataStatus.Completed and info.check then
            local bShow, data = info.check()
            if bShow then
              self:_Show(scene_type, i)
              if not self.nCheckQuiteQueueGM and info.quit_queue then
                log(bWriteLog and "logic_ugc_popup_queue:BeginShowTips quit_queue ui_name = " .. info.ui_cfg.ui_name)
                self:_EndSlap(scene_type)
                break
              end
            else
              log(bWriteLog and "logic_ugc_popup_queue:BeginShowTips return false of info.ui_cfg.ui_name = " .. info.ui_cfg.ui_name)
            end
          end
        elseif info.check then
          local bShow, data = info.check()
          if bShow then
            self:_Show(scene_type, i)
            if not self.nCheckQuiteQueueGM and info.quit_queue then
              log(bWriteLog and "logic_ugc_popup_queue:BeginShowTips quit_queue ui_name = " .. info.ui_cfg.ui_name)
              self:_EndSlap(scene_type)
              break
            end
          else
            log(bWriteLog and "logic_ugc_popup_queue:BeginShowTips return false of info.ui_cfg.ui_name = " .. info.ui_cfg.ui_name)
          end
        end
      else
        log(bWriteLog and "logic_ugc_popup_queue:BeginShowTips return false of ui has show info.ui_cfg.ui_name = " .. info.ui_cfg.ui_name)
      end
    end
  end
end
function logic_ugc_popup_queue:_HasWaitData()
  for _, status in pairs(self.ext_event_stat) do
    if status == WaitDataStatus.Wait then
      return true
    end
  end
  return false
end
function logic_ugc_popup_queue:_DelayCheckExtEvent(eventType, eventId, scene_type)
  local key = eventType .. "_" .. eventId
  if not self.ext_event_stat then
    self.ext_event_stat = {}
  end
  if not self.ext_event_stat[key] then
    log(bWriteLog and "logic_ugc_popup_queue:_DelayCheckExtEvent async start, key = " .. key)
    local async = require("client.common.async")
    async.Run(function(co)
      async.AwaitEvent(co, ASYNC_TIME_OUT, eventType, eventId)
      log(bWriteLog and "logic_ugc_popup_queue:_DelayCheckExtEvent async end, key = " .. key)
      if not self.ext_event_stat then
        log(bWriteLog and "logic_ugc_popup_queue:_DelayCheckExtEvent async end, ext_event_stat is nil, skip")
        return
      end
      if self.ext_event_stat[key] ~= WaitDataStatus.Completed then
        log(bWriteLog and "logic_ugc_popup_queue:_DelayCheckExtEvent async end, time out, key = " .. key)
        self.ext_event_stat[key] = WaitDataStatus.TimeOut
      end
      self:BeginShowTips(scene_type)
    end)
    self.ext_event_stat[key] = WaitDataStatus.Wait
  else
    log(bWriteLog and "NewFaceSlapSystem:_DelayCheckExtEvent async is running, key = " .. key)
  end
end
function logic_ugc_popup_queue:CheckCanShow(scene_type)
  if not scene_type then
    log(bWriteLog and "logic_ugc_popup_queue:CheckCanShow return false of scene_type = nil")
    return false
  end
  self.cur_show_queue = {}
  for i, v in pairs(self.queue_cfg) do
    if v.scene_type == scene_type then
      table.insert(self.cur_show_queue, v)
    end
  end
  if not self.cur_show_queue or not next(self.cur_show_queue) then
    log(bWriteLog and "logic_ugc_popup_queue:CheckCanShow queue = nil popup_type = " .. tostring(scene_type))
    return false
  end
  log_tree(bWriteLog and "logic_ugc_popup_queue:CheckCanShow queue = ", self.cur_show_queue)
  local config_ugc = require("client.slua.logic.ugc.config_ugc")
  local ugc_popup_cfg
  local ugc_popup_queue_cfg = config_ugc.Enum_UGCPopup_Type
  for i, v in pairs(ugc_popup_queue_cfg) do
    if v.scene_type == scene_type then
      ugc_popup_cfg = v
      break
    end
  end
  if ugc_popup_cfg and ugc_popup_cfg.check_strongnewguide_fun then
    if ugc_popup_cfg.check_strongnewguide_fun() then
      log(bWriteLog and "logic_ugc_popup_queue:CheckCanShow return false of strong_guide = true ")
      return false
    end
  else
    log(bWriteLog and "logic_ugc_popup_queue:CheckCanShow ugc_popup_cfg = nil or ugc_popup_cfg.check_strongnewguide_fun = nil")
  end
  return true
end
function logic_ugc_popup_queue:_Show(scene_type, index)
  local info = self.cur_show_queue[index]
  if not info then
    log(bWriteLog and "logic_ugc_popup_queue:_Show return of info = nil,index = " .. index)
    self:_EndSlap()
    return
  end
  log(bWriteLog and "logic_ugc_popup_queue:_Show index = " .. index)
  if info.check then
    local bShow, data = info.check()
    if bShow then
      log_tree("logic_ugc_popup_queue:_Show, ui_cfg = ", info.ui_cfg)
      info.show_fun(data)
      self.showePopupMap[scene_type][info.ui_cfg.ui_name] = {need_show = true, hide = false}
      self.showePopupMap[scene_type].need_show_cnt = self.showePopupMap[scene_type].need_show_cnt + 1
    end
  end
end
function logic_ugc_popup_queue:_EndSlap(scene_type)
  if self._endingSlap then
    log(bWriteLog and "logic_ugc_popup_queue:_EndSlap already in ending process, skip")
    return
  end
  self.cur_show_queue = {}
  self.ext_event_stat = {}
  self.iCurShowIndex = 0
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_POPUP_QUEUE_END, scene_type)
  self:ReSetPopupData(scene_type)
  log(bWriteLog and "logic_ugc_popup_queue:_EndSlap self.scene_type = " .. tostring(scene_type))
  self._endingSlap = false
end
function logic_ugc_popup_queue:OnDelayEvent(eventType, eventID)
  local key = eventType .. "_" .. eventID
  self.ext_event_stat[key] = WaitDataStatus.Completed
  log(bWriteLog and "logic_ugc_popup_queue:OnDelayEvent  BeginShowTips key = " .. key)
end
function logic_ugc_popup_queue:ReSetPopupData(scene_type)
  log(bWriteLog and "logic_ugc_popup_queue:ReSetPopupData scene_type = " .. scene_type)
  self.bReset = true
  self.cur_show_queue = {}
  self.iCurShowIndex = 0
  self.showePopupMap[scene_type].need_show_cnt = 0
  for key_name, ui_data in pairs(self.showePopupMap[scene_type]) do
    if type(ui_data) ~= "number" then
      ui_data.hide = false
      ui_data.need_show = false
    end
  end
end
function logic_ugc_popup_queue:CheckEnd(scene_type)
  if not self.showePopupMap[scene_type] then
    return
  end
  local all_popup_cnt = self.showePopupMap[scene_type].need_show_cnt
  local showed_cnt = 0
  for key_name, ui_data in pairs(self.showePopupMap[scene_type]) do
    if type(ui_data) ~= "number" and ui_data.need_show and ui_data.hide then
      showed_cnt = showed_cnt + 1
    end
  end
  if showed_cnt == all_popup_cnt then
    log(bWriteLog and "logic_ugc_popup_queue:CheckEnd scene_type = " .. scene_type)
    self:_EndSlap(scene_type)
  end
end
function logic_ugc_popup_queue:InitIntentionCfg()
  local logic_ugc_intention = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_intention)
  local IntentionAbtest = logic_ugc_intention.IntentionAbtest
  if IntentionAbtest == 1 then
    return
  end
  for _, v in pairs(self.queue_cfg) do
    if v.ui_cfg.ui_name == "UGC_Main_Intention_Panel_UI" then
      log(bWriteLog and "logic_ugc_popup_queue:InitIntentionCfg v.ext_event = nil")
      v.ext_event = nil
    end
  end
end
function logic_ugc_popup_queue:SetQuiteQueueCheckGM(bCheck)
  self.nCheckQuiteQueueGM = bCheck
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_ugc_popupu_queue = class(CModuleBase, nil, logic_ugc_popup_queue)
return Clogic_ugc_popupu_queue