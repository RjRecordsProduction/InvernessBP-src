local MixItemModule = {}
local MixItemConfig = require("client.slua.logic.MixItem.Config.MixItemConfig")
function MixItemModule:DefineAndResetData()
  self.SmeltConfig = {}
  self.SmeltConfigReqCache = {}
  self.ItemKindData = {}
  self.PlanItemMap = {}
  self.PlanCondMap = {}
  self.EEGotData = {}
  self.EEUnlockedData = {}
  self.GlobalConfig = nil
end
function MixItemModule:OnInitialize()
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  BasicDataServerTable:GetOrReqData(data_config_marco.mix_item_global_config, function(table_name, table_data)
    log_format("MixItemModule:OnInitialize. table_name=%s ", tostring(table_name))
    log_tree("MixItemModule:OnInitialize. table_data = ", table_data)
    self.GlobalConfig = table_data
  end)
end
function MixItemModule:RegistEvents()
end
function MixItemModule:OnJumpPlannerChat(jumpBackData)
  UIManager.CloseUI(UIManager.UI_Config.NewSupplySystem)
  local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
  local logic_chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  logic_chat_main.RecordJumpBackData(jumpBackData)
  logic_chat_main.OpenChatMainByTopic(chat_macro.PlannerChatTopic)
end
function MixItemModule:ReqSmeltConfig(ActId, SmeltSchemeID)
  if not ActId or not SmeltSchemeID then
    return
  end
  if self.SmeltConfigReqCache[SmeltSchemeID] then
    local MixItemEasterEggUtil = require("client.slua.logic.MixItem.Util.MixItemEasterEggUtil")
    MixItemEasterEggUtil.SetConfigReady(true)
    EventSystem:postEvent(EVENTTYPE_SUPPLY, EVENTID_MIX_ITEM_SMELT_SCHEME_UPDATE)
    return
  end
  local MixItemHandler = require("client.network.Protocol.MixItemHandler")
  MixItemHandler.send_get_smelt_plan_cfg_req(ActId)
end
function MixItemModule:PreCheckActId(actId)
  if not actId then
    return false
  end
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local actData = ActivityNewSystem.GetActivityByID(actId)
  if not actData then
    return false
  end
  return true, actData
end
function MixItemModule:GetUnbackActId(actId)
  local valid, actData = self:PreCheckActId(actId)
  if not valid then
    return 0
  end
  local Conditions = actData.List[1].Condition
  if not Conditions or not Conditions[1] then
    return 0
  end
  return Conditions[1]
end
function MixItemModule:GetSmeltSchemeID(actId)
  local valid, actData = self:PreCheckActId(actId)
  if not valid then
    return 0
  end
  local Conditions = actData.List[1].Condition
  if not Conditions or not Conditions[2] then
    return 0
  end
  return Conditions[2]
end
function MixItemModule:GetBackBoItemIDList(actId)
  local valid, actData = self:PreCheckActId(actId)
  if not valid then
    return ""
  end
  local Conditions = actData.List[1].Condition
  local result = {}
  for i = 3, 5 do
    if Conditions[i] then
      table.insert(result, tonumber(Conditions[i]))
    end
  end
  return result
end
function MixItemModule:GetBackBoxWeight()
  return {
    [1] = 70,
    [2] = 93,
    [3] = 837
  }
end
function MixItemModule:GetBackBoxList(actId)
  local valid, actData = self:PreCheckActId(actId)
  if not valid then
    return {}
  end
  local Conditions = actData.List[1].Condition
  local result = {}
  for Index, value in ipairs(Conditions) do
    if Index == 3 or Index == 4 or Index == 5 then
      table.insert(result, {
        itemId = tonumber(value),
        hasGot = false,
        valid_hours = 0
      })
    end
  end
  return result
end
function MixItemModule:GetBackPrice(actId)
  local valid, actData = self:PreCheckActId(actId)
  if not valid then
    return 0
  end
  local Conditions = actData.List[1].Condition
  if not Conditions or not Conditions[6] then
    return 0
  end
  return Conditions[6]
end
function MixItemModule:GetSmeltBaseConfig(SmeltSchemeID)
  if not SmeltSchemeID then
    return
  end
  local TotalConfig = self.SmeltConfig[SmeltSchemeID]
  if not TotalConfig then
    return
  end
  local BaseConfig = TotalConfig.smelt_basic_limit_cfg
  if not BaseConfig then
    return
  end
  return BaseConfig
end
function MixItemModule:GetSmeltSchemeConfig(SmeltSchemeID)
  if not SmeltSchemeID then
    return
  end
  local TotalConfig = self.SmeltConfig[SmeltSchemeID]
  if not TotalConfig then
    return
  end
  local SmeltSchemeConfig = TotalConfig.plan_cfg
  if not SmeltSchemeConfig then
    return
  end
  return SmeltSchemeConfig
end
function MixItemModule:GetEasterEggClueConfig(SmeltSchemeID)
  if not SmeltSchemeID then
    return
  end
  local TotalConfig = self.SmeltConfig[SmeltSchemeID]
  if not TotalConfig then
    return
  end
  local clueConfig = TotalConfig.easter_egg_clue_table
  if not clueConfig then
    return
  end
  return clueConfig
end
function MixItemModule:GetSmeltAttrConfigByAttrType(SmeltSchemeID, AttrType, Attr, limitType, limitAttr)
  local SmeltSchemeConfig = self:GetSmeltSchemeConfig(SmeltSchemeID)
  if not SmeltSchemeConfig then
    return
  end
  local AttrConfig = SmeltSchemeConfig[AttrType]
  if not AttrConfig or not AttrConfig[Attr] then
    return
  end
  if not limitType then
    return AttrConfig[Attr][1]
  end
  for _, cfg in ipairs(AttrConfig[Attr]) do
    if cfg[limitType] == limitAttr then
      return cfg
    end
  end
end
function MixItemModule:GetSmeltProductID(actId)
  if not actId or actId == 0 then
    return 0
  end
  local SmeltSchemeID = self:GetSmeltSchemeID(actId)
  local BaseConfig = self:GetSmeltBaseConfig(SmeltSchemeID)
  if not BaseConfig then
    return 0
  end
  return BaseConfig.output_res
end
function MixItemModule:GetItemKindList(actId)
  if self.ItemKindData[actId] then
    return self.ItemKindData[actId]
  end
  local result = {}
  local valid, _ = self:PreCheckActId(actId)
  if not valid then
    return result
  end
  local SmeltSchemeID = self:GetSmeltSchemeID(actId)
  if SmeltSchemeID == 0 then
    return result
  end
  local AllItemSubTypeList = {}
  local AllItemIDList = {}
  local KindMap = {}
  local TableName = self:GetTableName("SmeltItemKind")
  local TableData = CDataTable.GetTableByFilter(TableName, "SmeltSchemeID", SmeltSchemeID)
  for _, data in pairs(TableData) do
    local KindName = data.KindName
    local ele
    local bFirst = true
    local existedIndex = #result + 1
    if not KindMap[KindName] then
      ele = {
        text = data.KindName,
        ItemSubTypeList = {},
        ItemList = {}
      }
    else
      bFirst = false
      existedIndex = KindMap[KindName]
      ele = result[existedIndex]
    end
    if data.ItemID ~= 0 then
      table.insert(ele.ItemList, data.ItemID)
      table.insert(AllItemIDList, data.ItemID)
    elseif data.ItemSubType ~= 0 then
      local SubTypeData = {
        ItemSubType = data.ItemSubType,
        ItemQuality = data.ItemQuality
      }
      table.insert(ele.ItemSubTypeList, SubTypeData)
      table.insert(AllItemSubTypeList, SubTypeData)
    end
    if bFirst then
      KindMap[KindName] = existedIndex
    end
    result[existedIndex] = ele
  end
  local planEnumCfg = self:GetPlanEnumCfg(SmeltSchemeID)
  local MixItemConfig = require("client.slua.logic.MixItem.Config.MixItemConfig")
  local EasterEggModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.EasterEggModule)
  if planEnumCfg then
    for plan_id, cfg in pairs(planEnumCfg) do
      local EEID = MixItemConfig.PlanBindEasterEgg[plan_id]
      if EEID then
        if EasterEggModule:HasSolvedAllClues(actId, EEID) then
          for itemId, _ in pairs(cfg) do
            table.insert(AllItemIDList, itemId)
          end
        end
      else
        for itemId, _ in pairs(cfg) do
          table.insert(AllItemIDList, itemId)
        end
      end
    end
  end
  table.insert(result, 1, {
    text = LocUtil.GetLocalizeResStr(3000039),
    ItemSubTypeList = AllItemSubTypeList,
    ItemList = AllItemIDList
  })
  self.ItemKindData[actId] = result
  return result
end
function MixItemModule:GetItemMaximum(SmeltSchemeID)
  if not SmeltSchemeID or SmeltSchemeID == 0 then
    return 0
  end
  local BaseConfig = self:GetSmeltBaseConfig(SmeltSchemeID)
  if not BaseConfig then
    return 0
  end
  local upper = BaseConfig.total_count_limit
  if upper == 0 then
    return -1
  end
  return upper
end
function MixItemModule:GetItemSlotMaximum(SmeltSchemeID)
  if not SmeltSchemeID or SmeltSchemeID == 0 then
    return 0
  end
  local BaseConfig = self:GetSmeltBaseConfig(SmeltSchemeID)
  if not BaseConfig then
    return 0
  end
  return BaseConfig.slot_count_limit
end
function MixItemModule:GetSingleItemMaximum(SmeltSchemeID)
  if not SmeltSchemeID or SmeltSchemeID == 0 then
    return 0
  end
  local BaseConfig = self:GetSmeltBaseConfig(SmeltSchemeID)
  if not BaseConfig then
    return 0
  end
  local upper = BaseConfig.single_res_count
  if upper == 0 then
    upper = self:GetItemMaximum(SmeltSchemeID)
  end
  return upper
end
function MixItemModule:GetSmeltScoreByItemID(ActId, ItemID)
  local SmeltSchemeID = self:GetSmeltSchemeID(ActId)
  if SmeltSchemeID == 0 then
    return 0
  end
  local AttrConfig = self:GetSmeltAttrConfigByAttrType(SmeltSchemeID, 1, ItemID)
  if not AttrConfig then
    return 0
  end
  return AttrConfig.ratio
end
function MixItemModule:GetSmeltScoreByItemSubType(ActId, ItemSubType, LimitType, LimitAttr)
  local SmeltSchemeID = self:GetSmeltSchemeID(ActId)
  if SmeltSchemeID == 0 then
    return 0
  end
  local AttrConfig = self:GetSmeltAttrConfigByAttrType(SmeltSchemeID, 2, ItemSubType, LimitType, LimitAttr)
  if not AttrConfig then
    return 0
  end
  return AttrConfig.ratio
end
function MixItemModule:GetLowerNumByItemID(ActId, ItemID)
  local SmeltSchemeID = self:GetSmeltSchemeID(ActId)
  if SmeltSchemeID == 0 then
    return 0
  end
  local AttrConfig = self:GetSmeltAttrConfigByAttrType(SmeltSchemeID, 1, ItemID)
  if not AttrConfig then
    return 0
  end
  return AttrConfig.min_left
end
function MixItemModule:GetLowerNumByItemSubType(ActId, ItemSubType, LimitType, LimitAttr)
  local SmeltSchemeID = self:GetSmeltSchemeID(ActId)
  if SmeltSchemeID == 0 then
    return 0
  end
  local AttrConfig = self:GetSmeltAttrConfigByAttrType(SmeltSchemeID, 2, ItemSubType, LimitType, LimitAttr)
  if not AttrConfig then
    return 0
  end
  return AttrConfig.min_left
end
function MixItemModule:GetExchangeCondition(SmeltSchemeID, ExchangeID)
  if not (SmeltSchemeID and SmeltSchemeID ~= 0 and ExchangeID) or ExchangeID == 0 then
    return {}
  end
  if self.PlanCondMap[ExchangeID] then
    return self.PlanCondMap[ExchangeID]
  end
  local PlanEnumCfg = self:GetPlanEnumCfg(SmeltSchemeID)
  if not PlanEnumCfg then
    return {}
  end
  local Cfg = PlanEnumCfg[ExchangeID]
  if not Cfg then
    return {}
  end
  local Cond = {}
  local ItemCount = 0
  for itemId, _ in pairs(Cfg) do
    table.insert(Cond, {
      arg = itemId,
      compare_type = 1,
      type = 1,
      value = 1
    })
    ItemCount = ItemCount + 1
  end
  table.insert(Cond, {
    arg = 0,
    compare_type = 1,
    type = 2,
    value = ItemCount
  })
  local result = {Cond}
  self.PlanCondMap[ExchangeID] = result
  return result
end
function MixItemModule:GetPlanEnumCfg(SmeltSchemeID)
  if not SmeltSchemeID or SmeltSchemeID == 0 then
    return {}
  end
  if not self.SmeltConfig[SmeltSchemeID] then
    return {}
  end
  local SmeltConfig = self.SmeltConfig[SmeltSchemeID]
  return SmeltConfig.plan_enums
end
function MixItemModule:IsPlanEnumItemID(itemID)
  return self.PlanItemMap[itemID] ~= nil
end
function MixItemModule:GetEEConfig(SmeltSchemeID)
  if not SmeltSchemeID or SmeltSchemeID == 0 then
    return {}
  end
  if not self.SmeltConfig[SmeltSchemeID] then
    return {}
  end
  local SmeltConfig = self.SmeltConfig[SmeltSchemeID]
  return SmeltConfig.easter_egg_cfg
end
function MixItemModule:GetEEConditionConfig(SmeltSchemeID)
  if not SmeltSchemeID or SmeltSchemeID == 0 then
    return {}
  end
  if not self.SmeltConfig[SmeltSchemeID] then
    return {}
  end
  local SmeltConfig = self.SmeltConfig[SmeltSchemeID]
  return SmeltConfig.easter_cond_cfg
end
function MixItemModule:GetAllEEData(actId)
  if self.AllEEData then
    return self.AllEEData
  end
  local SmeltSchemeId = self:GetSmeltSchemeID(actId)
  if SmeltSchemeId == 0 then
    return {}
  end
  local EEConfig = self:GetEEConfig(SmeltSchemeId)
  local VersionCache = {}
  local TableName = self:GetTableName("MixItemEasterEgg")
  local Result = {}
  self.EEDataMap = {}
  for EEID, Config in pairs(EEConfig) do
    local VersionLimit = Config.min_cli_version
    local Limit = VersionCache[VersionLimit]
    if Limit == nil then
      Limit = FuncUtil.IsNewVersion(VersionLimit)
      VersionCache[VersionLimit] = Limit
    end
    if not Limit then
      local localizeData = CDataTable.GetTableData(TableName, EEID)
      if localizeData then
        Result[#Result + 1] = {
          EEID = EEID,
          EEItemID = Config.bonus_resid,
          EEItemCount = Config.bonus_count,
          EEName = localizeData.EEName,
          EETip = localizeData.EETip,
          EEDesc = localizeData.EEDesc,
          EEGetTip = Config.hint_cond_cfg,
          EEConditionID = Config.obtain_cond_cfg,
          EEType = MixItemConfig.EEStatus.Unknown,
          ExchangePlanID = Config.exchange_plan_id,
          JumpUrl = localizeData.JumpUrl
        }
        self.EEDataMap[EEID] = Result[#Result]
      end
    end
  end
  self.AllEEData = Result
  return Result
end
function MixItemModule:GetEEData(EEID)
  if not self.EEDataMap or not self.EEDataMap[EEID] then
    return
  end
  return self.EEDataMap[EEID]
end
function MixItemModule:GetTableName(TableName)
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsJapanOrKorea() then
    TableName = TableName .. "JK"
  end
  return TableName
end
function MixItemModule:IsFirstTimeEnter()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local Cache = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eMixItemGuidePopup) or {}
  local Time = Cache.FirstTime or 0
  return Time == 0
end
function MixItemModule:SaveFirstEnterTime()
  local TimeUtil = require("client.common.time_util")
  local data = {
    FirstTime = TimeUtil.GetServerTimeInSec()
  }
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(data, PlayerPrefsSystem.ePlayerPrefsType.eMixItemGuidePopup)
end
function MixItemModule:IsNarrowScreen()
  local UIUtil = require("client.common.ui_util")
  local viewPortSize = UIUtil.GetViewportSize()
  local ratio = tonumber(viewPortSize.X) / tonumber(viewPortSize.Y)
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  return ratio <= Lobby_camera_manager_module.CONST.LONG_SCREEN_THRESHOLD
end
function MixItemModule:UseEEProduct()
  UIManager.ShowUI(UIManager.UI_Config.MillionUC_Main_UIBP)
end
function MixItemModule:IsSpecialGotEE(EEID)
  if not MixItemConfig.SpecialGot[EEID] then
    return false
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cache = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eMixItemSpecialEE) or {}
  if not cache[EEID] or cache[EEID].Show == false then
    return true
  end
  return false
end
function MixItemModule:IsSpecialHintEE(EEID)
  if not MixItemConfig.SpecialHint[EEID] then
    return false
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cache = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eMixItemSpecialEE) or {}
  if not cache[EEID] or cache[EEID].Show == false then
    return true
  end
  return false
end
function MixItemModule:SaveSpecialGotEE(EEID, ItemID, ItemCount, ShowStatus)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cache = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eMixItemSpecialEE) or {}
  local TimeUtil = require("client.common.time_util")
  cache[EEID] = {
    Time = TimeUtil.GetServerTimeInSec(),
    ItemID = ItemID,
    ItemCount = ItemCount,
      }
  PlayerPrefsSystem.SaveTableToFile_N(cache, PlayerPrefsSystem.ePlayerPrefsType.eMixItemSpecialEE)
end
function MixItemModule:SetSpecialGotEEShowStatus(EEID, ShowStatus)
  if not EEID then
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cache = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eMixItemSpecialEE) or {}
  if not cache[EEID] or not cache[EEID].ShowStatus then
    return
  end
  cache[EEID].  PlayerPrefsSystem.SaveTableToFile_N(cache, PlayerPrefsSystem.ePlayerPrefsType.eMixItemSpecialEE)
end
function MixItemModule:GetSpecialEECache(EEID)
  if not EEID then
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cache = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eMixItemSpecialEE) or {}
  return cache[EEID]
end
function MixItemModule:GetMillionUCItemID()
  return self.GlobalConfig and self.GlobalConfig[4] or 0
end
function MixItemModule:GetMillionUCBoxItemID()
  return self.GlobalConfig and self.GlobalConfig[5] or 0
end
function MixItemModule:send_mix_item_smelt_req(activity_id, instance_tab, expected_res, expected_cnt)
  local MixItemHandler = require("client.network.Protocol.MixItemHandler")
  MixItemHandler.send_mix_item_smelt_req(activity_id, instance_tab, expected_res, expected_cnt)
end
function MixItemModule:on_mix_item_smelt_rsp(error_code, smelt_res, smelt_history)
  log(bWriteLog and string.format("MixItemModule:on_mix_item_smelt_rsp. error_code=%s", tostring(error_code)))
  log_tree("smelt_res = ", smelt_res)
  if error_code ~= 0 then
    local LocId = MixItemConfig.ErrCode[error_code] or error_code
    ShowNotice(LocId)
    return
  end
  log(bWriteLog and string.format("MixItemModule:on_mix_item_smelt_rsp. count=%s", tostring(smelt_res.count)))
  EventSystem:postEvent(EVENTTYPE_SUPPLY, EVENTID_MIX_ITEM_SMELT_RESULT_UPDATED)
end
function MixItemModule:send_exchange_mix_item_chest_req(activity_id)
  local MixItemHandler = require("client.network.Protocol.MixItemHandler")
  MixItemHandler.send_exchange_mix_item_chest_req(activity_id)
end
function MixItemModule:on_exchange_mix_item_chest_rsp(err_code, chest_id, item_list, decompose_list)
  log(bWriteLog and string.format("MixItemModule:on_exchange_mix_item_chest_rsp. err_code=%s, chest_id=%s", tostring(err_code), tostring(chest_id)))
  log_tree("item_list = ", item_list)
  log_tree("decompose_list = ", decompose_list)
  if err_code ~= 0 then
    local LocId = MixItemConfig.ErrCode[err_code] or err_code
    ShowNotice(LocId)
    return
  end
  local MixItemDrawUtil = require("client.slua.logic.MixItem.Util.MixItemDrawUtil")
  MixItemDrawUtil.SaveDrawInfo(chest_id, 1, 0, MixItemConfig.DrawSession.BackSession)
  MixItemDrawUtil.SaveBackBoxData(item_list, decompose_list)
  EventSystem:postEvent(EVENTTYPE_SUPPLY, EVENTID_MIX_ITEM_EXCHANGE_SUCCESS, chest_id, item_list, decompose_list)
end
function MixItemModule:send_get_hint_easter_egg_req(activity_id)
  if not self:CheckOldVersion(activity_id) then
    local MixItemHandler = require("client.network.Protocol.MixItemHandler")
    MixItemHandler.send_get_easter_egg_data_req(activity_id)
    return
  end
  local MixItemHandler = require("client.network.Protocol.MixItemHandler")
  MixItemHandler.send_get_hint_easter_egg_req(activity_id)
end
function MixItemModule:on_get_hint_easter_egg_rsp(err_code, got_eggs, hint, new_hints)
  log(bWriteLog and string.format("MixItemModule:on_get_hint_easter_egg_rsp. err_code=%s", tostring(err_code)))
  log_tree("got_eggs = ", got_eggs)
  log_tree("hint = ", hint)
  log_tree("new_hints = ", new_hints)
  if err_code ~= 0 then
    local LocId = MixItemConfig.ErrCode[err_code] or err_code
    ShowNotice(LocId)
    return
  end
  local MixItemEasterEggUtil = require("client.slua.logic.MixItem.Util.MixItemEasterEggUtil")
  MixItemEasterEggUtil.SetGotData(got_eggs)
  MixItemEasterEggUtil.SetHintData(hint)
  MixItemEasterEggUtil.SetDataReady(true)
  EventSystem:postEvent(EVENTTYPE_SUPPLY, EVENTID_MIX_ITEM_EASTER_EGG_DATA_UPDATED)
  if new_hints then
    local flag = false
    for _, EEID in ipairs(new_hints) do
      if self:IsSpecialHintEE(EEID) and EEID == MixItemConfig.SpecialEE.NotFound404 then
        flag = true
        local MixItemPopupUtil = require("client.slua.logic.MixItem.Util.MixItemPopupUtil")
        MixItemPopupUtil.Push({
          popupType = MixItemConfig.PopupType.NotFound404
        })
      end
    end
    if flag then
      EventSystem:postEvent(EVENTTYPE_SUPPLY, EVENTID_MIX_ITEM_POPUP_SHOW_UPDATED)
    end
  end
end
function MixItemModule:on_kick_easter_egg_notify(err_code, triggered_eggs)
  log(bWriteLog and string.format("MixItemModule:on_kick_easter_egg_rsp. err_code=%s", tostring(err_code)))
  log_tree("triggered_eggs = ", triggered_eggs)
  if err_code ~= 0 then
    local LocId = MixItemConfig.ErrCode[err_code] or err_code
    ShowNotice(LocId)
    return
  end
  local MixItemRedDotModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.MixItemRedDotModule)
  local MixItemEasterEggUtil = require("client.slua.logic.MixItem.Util.MixItemEasterEggUtil")
  local ItemList = {}
  local ItemMap = {}
  for EEID, data in pairs(triggered_eggs) do
    MixItemEasterEggUtil.AddGotData(EEID)
    if self:IsSpecialGotEE(EEID) then
      do
        local MixItemPopupUtil = require("client.slua.logic.MixItem.Util.MixItemPopupUtil")
        if EEID == MixItemConfig.SpecialEE.PlannerChat then
          MixItemPopupUtil.Push({
            popupType = MixItemConfig.PopupType.PlannerChatGo
          })
          self:SaveSpecialGotEE(EEID, data.resid, data.count, MixItemConfig.SpecialEEShowStatus.Wait)
        elseif EEID == MixItemConfig.SpecialEE.NotFound404 then
          local MixItemPopupUtil = require("client.slua.logic.MixItem.Util.MixItemPopupUtil")
          MixItemPopupUtil.Push({
            popupType = MixItemConfig.PopupType.SpecialEEGet,
                      })
          self:SaveSpecialGotEE(EEID, data.resid, data.count, MixItemConfig.SpecialEEShowStatus.CanShow)
          MixItemRedDotModule:AddRedDotNode(EEID)
        end
      end
    else
      local Ele, Index
      if ItemMap[data.resid] then
        Index = ItemMap[data.resid]
        Ele = ItemList[Index]
        Ele.count = Ele.count + data.count
      else
        Index = #ItemList + 1
        ItemMap[data.resid] = Index
        Ele = {
          res_id = data.resid,
          count = data.count,
          valid_hours = 0
        }
      end
      ItemList[Index] = Ele
      MixItemRedDotModule:AddRedDotNode(EEID)
    end
  end
  local MixItemPopupUtil = require("client.slua.logic.MixItem.Util.MixItemPopupUtil")
  if MixItemPopupUtil.IsInit() then
    MixItemPopupUtil.Push({
      popupType = MixItemConfig.PopupType.ItemGet,
          })
  else
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    Logic_CommonItemGet.ShowPanel_DefaultStyle(ItemList)
  end
  EventSystem:postEvent(EVENTTYPE_SUPPLY, EVENTID_MIX_ITEM_EASTER_EGG_DATA_UPDATED)
  EventSystem:postEvent(EVENTTYPE_SUPPLY, EVENTID_MIX_ITEM_POPUP_SHOW_UPDATED)
end
function MixItemModule:on_get_smelt_plan_cfg_rsp(err_code, cfg)
  log(bWriteLog and string.format("MixItemHandler.on_get_smelt_plan_cfg_rsp. err_code=%s", tostring(err_code)))
  log_tree("on_get_smelt_plan_cfg_rsp cfg = ", cfg)
  if err_code ~= 0 then
    local LocId = MixItemConfig.ErrCode[err_code] or err_code
    ShowNotice(LocId)
    return
  end
  local SmeltSchemeID = cfg.plan_id
  self.SmeltConfigReqCache[SmeltSchemeID] = true
  self.SmeltConfig[SmeltSchemeID] = cfg
  local planEnumCfg = cfg.plan_enums
  if planEnumCfg then
    for planId, planEnum in pairs(planEnumCfg) do
      for itemId, _ in pairs(planEnum) do
        self.PlanItemMap[itemId] = true
      end
    end
  end
  local MixItemEasterEggUtil = require("client.slua.logic.MixItem.Util.MixItemEasterEggUtil")
  MixItemEasterEggUtil.SetConfigReady(true)
  EventSystem:postEvent(EVENTTYPE_SUPPLY, EVENTID_MIX_ITEM_SMELT_SCHEME_UPDATE)
end
function MixItemModule:on_exchange_easter_egg_rsp(err_code, egg_id)
  EventSystem:postEvent(EVENTTYPE_SUPPLY, EVENTID_MIX_ITEM_SMELT_RESULT_UPDATED)
end
function MixItemModule:ErrCodeConversion(err_code)
  return MixItemConfig.ErrCode[err_code] or err_code
end
function MixItemModule:CheckOldVersion(nActID)
  if GlobalData.IsBLUEHOLE() then
    return 639252001 == nActID
  elseif GlobalData.IsJapanOrKorea() then
    return 239252001 == nActID
  end
  return 439252001 == nActID
end
function MixItemModule:AddItemListToAllKind(actId, itemList)
  if not actId or not itemList then
    return
  end
  if not self.ItemKindData or not self.ItemKindData[actId] then
    return
  end
  local kindList = self.ItemKindData[actId]
  local allKind = kindList[1]
  for _, itemId in pairs(itemList) do
    table.insert(allKind.ItemList, itemId)
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CMixItemModule = class(CModuleBase, nil, MixItemModule)
return CMixItemModule