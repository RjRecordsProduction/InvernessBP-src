local LogicUGCExposure = {}
local TableUtil = require("common.table_util")
local TimeUtil = require("client.common.time_util")
local Promise = require("common.Promise")
local Config_UGC = require("client.slua.logic.ugc.config_ugc")
local ReportType = Config_UGC.Enum_PromotionReportType
function LogicUGCExposure:DefineAndResetData()
  self.ItemExposure = {}
  local UGCExposureConfigTable = CDataTable.GetTable("UGCExposureConfig")
  for _, V in pairs(UGCExposureConfigTable) do
    self.ItemExposure[V.ItemID] = V.ExposureValue
  end
  self.ExposureRecordReqCD = 0
  self.ModLog = {}
  self.PromotionModLog = {}
  self.RankingModLog = {}
  self.ExposureLogReqCD = nil
  self.MatchReqList = {}
  self.MatchReqTimer = nil
  self.LoopReqTime = 5
  self.SendType = {ModLog = 1, PromotionModLog = 2}
  self.PublishWorksList = {}
end
function LogicUGCExposure:RegistEvents()
  print(bWriteLog and "LogicUGCExposure:RegistEvents")
  EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_UGC_USE_COUPONS, self._OnJumpUrlCouponUse, self)
end
function LogicUGCExposure:OnUnRegistEvents()
  print(bWriteLog and "LogicUGCExposure:OnUnRegistEvents")
  self:_ClearTimer()
  self:_ClearPromotionTimer()
  self:_ClearRankingPromotionTimer()
  if self:_SendExposureLogToServer() then
    self.PromotionModLog = {}
    self.RankingModLog = {}
  end
  self:_SendPromotionLogToServer()
  self:_SendRankingPromotionLogToServer()
end
function LogicUGCExposure:OnLogOut()
  print(bWriteLog and "LogicUGCExposure:OnLogOut")
  self:_ClearTimer()
  self:_ClearPromotionTimer()
  self:_ClearRankingPromotionTimer()
  if self:_SendExposureLogToServer() then
    self.PromotionModLog = {}
    self.RankingModLog = {}
  end
  self:_SendPromotionLogToServer()
  self:_SendRankingPromotionLogToServer()
end
function LogicUGCExposure:OnDestroy()
  if self:_SendExposureLogToServer() then
    self.PromotionModLog = {}
    self.RankingModLog = {}
  end
  self:_SendPromotionLogToServer()
  self:_SendRankingPromotionLogToServer()
end
function LogicUGCExposure:SetExposureLogReqCD(CD)
  self.ExposureLogReqCD = tonumber(CD)
  if not self.ExposureLogReqCD or self.ExposureLogReqCD < 1 then
    self.ExposureLogReqCD = 30
  end
end
function LogicUGCExposure:GetCoupons()
  local Coupons = {}
  local OneThousandCouponsCtn, TenThousandCouponsCtn, OneHundredCouponsCtn = 0, 0, 0
  local WardrobeDate = require("client.slua.logic.wardrobe.wardrobe_data")
  local ArrayHallDepotItemInfo = WardrobeDate:GetArrayHallDepotItemInfo()
  local DecomposeSystem = require("client.logic.decompose.logic_decompose")
  for _, Item in pairs(ArrayHallDepotItemInfo) do
    if Item.itemType == ENUM_ITEM_TYPE.Item_Card and Item.itemSubType == ENUM_ITEM_SUBTYPE.UGC_Exposure_Coupon then
      local ItemCfg = CDataTable.GetTableData("Item", Item.resID)
      local NewItem = {
        ins_id = 0,
        res_id = 0,
        total = 0,
        itemName = "",
        itemImage = "",
        itemQuality = 0,
        expireTS = nil,
        isTimeLimit = false
      }
      NewItem.ins_id = Item.insID
      NewItem.res_id = Item.resID
      NewItem.itemName = ItemCfg.ItemName
      NewItem.itemImage = ItemCfg.ItemSmallIcon
      NewItem.itemQuality = ItemCfg.ItemQuality
      NewItem.total = Item.count - WardrobeDate:GetUseCount(Item.insID)
      NewItem.expireTS = Item.expireTS
      if 0 < NewItem.expireTS then
        NewItem.isTimeLimit = true
        NewItem.itemName = NewItem.itemName .. " " .. DecomposeSystem.GetRemainTimeDays(Item.expireTS)
      else
        NewItem.itemName = ItemCfg.itemName
        NewItem.isTimeLimit = false
      end
      NewItem.exposure = self.ItemExposure[Item.resID]
      if NewItem.exposure == 1000 then
        OneThousandCouponsCtn = OneThousandCouponsCtn + 1
      elseif NewItem.exposure == 10000 then
        TenThousandCouponsCtn = TenThousandCouponsCtn + 1
      elseif NewItem.exposure == 100000 then
        OneHundredCouponsCtn = OneHundredCouponsCtn + 1
      end
      table.insert(Coupons, NewItem)
    end
  end
  table.sort(Coupons, function(a, b)
    return a.expireTS < b.expireTS
  end)
  return Coupons, OneThousandCouponsCtn, TenThousandCouponsCtn, OneHundredCouponsCtn
end
function LogicUGCExposure:GetCouponCtn()
  local Ctn = 0
  local WardrobeDate = require("client.slua.logic.wardrobe.wardrobe_data")
  local ArrayHallDepotItemInfo = WardrobeDate:GetArrayHallDepotItemInfo()
  for _, Item in pairs(ArrayHallDepotItemInfo) do
    if Item.itemType == ENUM_ITEM_TYPE.Item_Card and Item.itemSubType == ENUM_ITEM_SUBTYPE.UGC_Exposure_Coupon then
      Ctn = Ctn + 1
    end
  end
  return Ctn
end
function LogicUGCExposure:_OnJumpUrlCouponUse()
  local LogicUGCAuthor = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAuthor)
  if LogicUGCAuthor:NewCheckPlayerIsAuthor(DataMgr.roleData.uid) then
    if IsWoWEditor then
      UIManager.AndroidBackToLobby()
    else
      UIManager.ShowUI(UIManager.UI_Config.ugc_mine_main)
    end
  else
    ShowNotice(116009)
  end
end
function LogicUGCExposure:GetExposureRecords(bForce)
  local Promise = Promise.new()
  if not bForce and self.ExposureRecords then
    local Time = TimeUtil.GetServerTimeInSec()
    if Time < self.ExposureRecordReqCD then
      print(bWriteLog and "LogicUGCExposure:GetExposureRecords return cache exposure_record_req_cd: " .. self.ExposureRecordReqCD)
      Promise:Resolve(self.ExposureRecords)
      return Promise
    end
  end
  print(bWriteLog and "LogicUGCExposure:GetExposureRecords request new exposure_record_req_cd: " .. self.ExposureRecordReqCD)
  local UGCHandler = require("client.network.Protocol.UGCHandler")
  UGCHandler.send_ugc_promotion_record_req():Then(function(ErrCode, Records)
    self.Exposure    print(bWriteLog and "LogicUGCExposure:GetExposureRecords receive new")
    self.ExposureRecordReqCD = TimeUtil.GetServerTimeInSec() + 15
    Promise:Resolve(self.ExposureRecords)
  end, function(Reason)
    Promise:Reject(Reason)
  end)
  return Promise
end
function LogicUGCExposure:HasCacheMod(ModID)
  return self.ExposureRecords and self.ExposureRecords[ModID] ~= nil
end
function LogicUGCExposure:UpdateRecord(Record)
  if self.ExposureRecords and Record and Record.mod_id then
    for _, TempRecord in pairs(self.ExposureRecords) do
      if TempRecord.mod_id == Record.mod_id then
        TableUtil.OverrideTable(TempRecord, Record)
      end
    end
  end
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_USE_EXPOSURE_COUPON)
end
function LogicUGCExposure:_SendExposureLogToServer()
  log(bWriteLog and "LogicUGCExposure:_SendExposureLogToServer bIsResultPromotion:" .. tostring(self.bIsResultPromotion))
  local bExposure = false
  if next(self.ModLog) then
    local UGCHandler = require("client.network.Protocol.UGCHandler")
    if self.bIsResultPromotion == true then
      local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
      self:AddSendLog(self.SendType.ModLog, self.ModLog, ReportType.ResultPromotion, LogicUGC.trans_info)
    elseif self.bIsRankingPromotion then
      local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
      self:AddSendLog(self.SendType.ModLog, self.ModLog, ReportType.RankingPromotion, LogicUGC.trans_info)
    else
      local logic_ugc_hot_theme = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_hot_theme)
      self:AddSendLog(self.SendType.ModLog, self.ModLog, ReportType.HotThemePromotion, logic_ugc_hot_theme.trans_info)
    end
    bExposure = true
  end
  self.ModLog = {}
  self:_ClearTimer()
  return bExposure
end
function LogicUGCExposure:AddSendLog(SendType, Data, ResultPromotion, trans_info)
  if not SendType or not Data then
    log(bWriteLog and "LogicUGCExposure:AddSendLog SendType or Data is nil")
    return
  end
  if SendType == self.SendType.ModLog or SendType == self.SendType.PromotionModLog then
    table.insert(self.MatchReqList, {
      SendType = SendType,
      Data = Data,
      ResultPromotion = ResultPromotion,
          })
  end
  self:OpenSendLogTime()
end
function LogicUGCExposure:SendLogReq()
  if not self.MatchReqList or not next(self.MatchReqList) then
    return
  end
  local UGCHandler = require("client.network.Protocol.UGCHandler")
  local ReqList = self.MatchReqList[1]
  log_tree("LogicUGCExposure:SendLogReq ReqList = ", ReqList)
  if ReqList.ResultPromotion then
    log(bWriteLog and "LogicUGCExposure:SendLogReq ResultPromotion is " .. tostring(ReqList.ResultPromotion))
    UGCHandler.send_ugc_report_promotion_view_req(ReqList.Data, ReqList.ResultPromotion, ReqList.trans_info)
  else
    log(bWriteLog and "LogicUGCExposure:SendLogReq ResultPromotion is nil")
    UGCHandler.send_ugc_report_promotion_view_req(ReqList.Data)
  end
  table.remove(self.MatchReqList, 1)
  if not next(self.MatchReqList) then
    self:EndSendLogTime()
  end
end
function LogicUGCExposure:OpenSendLogTime()
  if self.MatchReqTimer then
    return
  end
  self.MatchReqTimer = self:AddGameTimer(self.LoopReqTime, true, function()
    self:SendLogReq()
  end)
end
function LogicUGCExposure:EndSendLogTime()
  if self.MatchReqTimer then
    self:RemoveTimer(self.MatchReqTimer)
    self.MatchReqTimer = nil
  end
end
function LogicUGCExposure:UserEnterDetail(ModID)
  log(bWriteLog and "LogicUGCExposure:UserEnterDetail ModID=" .. tostring(ModID))
  self:_InitTimerIfNot()
  if self.ModLog[ModID] == nil then
    self.ModLog[ModID] = {}
  end
  self.ModLog[ModID].detail = 1
end
function LogicUGCExposure:UserStartMatch(ModID)
  log(bWriteLog and "LogicUGCExposure:UserStartMatch ModID=" .. tostring(ModID))
  if self.MayStartMatchMod == ModID then
    self:_InitTimerIfNot()
    if self.ModLog[ModID] == nil then
      self.ModLog[ModID] = {}
    end
    self.ModLog[ModID].match = 1
    self:_SendExposureLogToServer()
  else
    self:ClearMayState()
  end
end
function LogicUGCExposure:UserDisplayMod(ModID)
  log(bWriteLog and "LogicUGCExposure:UserDisplayMod ModID=" .. tostring(ModID))
  local Logic_UGC_TLog = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_UGC_TLog)
  if Logic_UGC_TLog.TLogSwitch == false then
    return
  end
  self:_InitTimerIfNot()
  if self.ModLog[ModID] == nil then
    self.ModLog[ModID] = {}
  end
end
function LogicUGCExposure:UserExposurePromotion(ModID)
  log(bWriteLog and "LogicUGCExposure:UserExposurePromotion ModID=" .. tostring(ModID))
  self:_InitPromotionTimerIfNot()
  if self.PromotionModLog[ModID] == nil then
    self.PromotionModLog[ModID] = {}
  end
end
function LogicUGCExposure:UserEnterPromotionDetail(ModID)
  log(bWriteLog and "LogicUGCExposure:UserEnterPromotionDetail ModID=" .. tostring(ModID))
  self:_InitPromotionTimerIfNot()
  if self.PromotionModLog[ModID] == nil then
    self.PromotionModLog[ModID] = {}
  end
  self.PromotionModLog[ModID].detail = 1
end
function LogicUGCExposure:UserChooseMod(ModID, isResultPromotion, bIsRankingPromotion)
  log(bWriteLog and "LogicUGCExposure:UserChooseMod ModID=" .. tostring(ModID) .. " isResultPromotion:" .. tostring(isResultPromotion))
  self.MayStartMatchMod = ModID
  self.bIsResultPromotion = isResultPromotion == true
  self.bIsRankingPromotion = bIsRankingPromotion == true
end
function LogicUGCExposure:UserCreateRoom(ModID, isResultPromotion)
  log(bWriteLog and "LogicUGCExposure:UserCreateRoom ModID=" .. tostring(ModID) .. " isResultPromotion:" .. tostring(isResultPromotion))
  self.MayStartMatchMod = ModID
  self.bIsResultPromotion = isResultPromotion == true
end
function LogicUGCExposure:ClearMayState()
  print(bWriteLog and "LogicUGCExposure:ClearMayState")
  self.MayStartMatchMod = nil
  self.bIsResultPromotion = nil
  self.bIsRankingPromotion = nil
end
function LogicUGCExposure:UserExposureRankingPromotion(ModID)
  log(bWriteLog and "LogicUGCExposure:UserExposureRankingPromotion ModID=" .. tostring(ModID))
  self:_InitRankingPromotionTimerIfNot()
  if self.RankingModLog[ModID] == nil then
    self.RankingModLog[ModID] = {}
  end
end
function LogicUGCExposure:UserEnterRankingPromotionDetail(ModID)
  log(bWriteLog and "LogicUGCExposure:UserEnterRankingPromotionDetail ModID=" .. tostring(ModID))
  self:_InitRankingPromotionTimerIfNot()
  if self.RankingModLog[ModID] == nil then
    self.RankingModLog[ModID] = {}
  end
  self.RankingModLog[ModID].detail = 1
end
function LogicUGCExposure:_InitTimerIfNot()
  if not self.LoopTimer then
    self.LoopTimer = self:AddGameTimer(self.ExposureLogReqCD or 30, true, function()
      self:_SendExposureLogToServer()
    end)
  end
end
function LogicUGCExposure:_ClearTimer()
  if self.LoopTimer then
    self:RemoveTimer(self.LoopTimer)
    self.LoopTimer = nil
  end
end
function LogicUGCExposure:_InitPromotionTimerIfNot()
  print(bWriteLog and "LogicUGCExposure:_InitPromotionTimerIfNot LoopTimerPromotion:" .. tostring(self.LoopTimerPromotion))
  if not self.LoopTimerPromotion then
    print(bWriteLog and "LogicUGCExposure:_InitPromotionTimerIfNot")
    self.LoopTimerPromotion = self:AddGameTimer(self.ExposureLogReqCD or 30, false, function()
      self.LoopTimerPromotion = nil
      self:_SendPromotionLogToServer()
    end)
  end
end
function LogicUGCExposure:_SendPromotionLogToServer()
  print(bWriteLog and "LogicUGCExposure:_SendPromotionLogToServer")
  if next(self.PromotionModLog) then
    local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
    self:AddSendLog(self.SendType.PromotionModLog, self.PromotionModLog, ReportType.ResultPromotion, LogicUGC.trans_info)
  end
  self.PromotionModLog = {}
  self:_ClearPromotionTimer()
end
function LogicUGCExposure:_ClearPromotionTimer()
  if self.LoopTimerPromotion then
    self:RemoveTimer(self.LoopTimerPromotion)
    self.LoopTimerPromotion = nil
  end
end
function LogicUGCExposure:_InitRankingPromotionTimerIfNot()
  print(bWriteLog and "LogicUGCExposure:_InitRankingPromotionTimerIfNot LoopTimerPromotion:" .. tostring(self.LoopTimerPromotion))
  if not self.LoopTimerRanking then
    print(bWriteLog and "LogicUGCExposure:_InitRankingPromotionTimerIfNot")
    self.LoopTimerRanking = self:AddGameTimer(5, false, function()
      self.LoopTimerRanking = nil
      self:_SendRankingPromotionLogToServer()
    end)
  end
end
function LogicUGCExposure:_SendRankingPromotionLogToServer()
  print(bWriteLog and "LogicUGCExposure:_SendRankingPromotionLogToServer")
  if next(self.RankingModLog) then
    local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
    self:AddSendLog(self.SendType.PromotionModLog, self.RankingModLog, ReportType.RankingPromotion, LogicUGC.trans_info)
  end
  self.RankingModLog = {}
  self:_ClearRankingPromotionTimer()
end
function LogicUGCExposure:_ClearRankingPromotionTimer()
  if self.LoopTimerRanking then
    self:RemoveTimer(self.LoopTimerRanking)
    self.LoopTimerRanking = nil
  end
end
function LogicUGCExposure:IsCouponRedDot()
  local bFoundNew = false
  local WardrobeDate = require("client.slua.logic.wardrobe.wardrobe_data")
  local ArrayHallDepotItemInfo = WardrobeDate:GetArrayHallDepotItemInfo()
  for _, Item in pairs(ArrayHallDepotItemInfo) do
    if Item.itemType == ENUM_ITEM_TYPE.Item_Card and Item.itemSubType == ENUM_ITEM_SUBTYPE.UGC_Exposure_Coupon and Item.isNew then
      bFoundNew = true
      break
    end
  end
  return bFoundNew
end
function LogicUGCExposure:IsFirstTimeGetCoupon()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local Data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUGCNewbieExposureCoupon)
  if Data then
    return Data.NewbieExposureCoupon ~= true
  end
  return true
end
function LogicUGCExposure:MarkReadCoupons()
  local InstIdList = {}
  local WardrobeDate = require("client.slua.logic.wardrobe.wardrobe_data")
  local ArrayHallDepotItemInfo = WardrobeDate:GetArrayHallDepotItemInfo()
  local WardrobeLogic = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  for _, Item in pairs(ArrayHallDepotItemInfo) do
    if Item.itemType == ENUM_ITEM_TYPE.Item_Card and Item.itemSubType == ENUM_ITEM_SUBTYPE.UGC_Exposure_Coupon and Item.isNew then
      table.insert(InstIdList, tonumber(Item.insID))
    end
  end
  if 0 < #InstIdList then
    WardrobeLogic:wardrobe_change_item_list_new_status(InstIdList)
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local Data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUGCNewbieExposureCoupon) or {}
  if Data and not Data.NewbieExposureCoupon then
    Data.NewbieExposureCoupon = true
    PlayerPrefsSystem.SaveTableToFile_N(Data, PlayerPrefsSystem.ePlayerPrefsType.eUGCNewbieExposureCoupon)
  end
end
function LogicUGCExposure:CheckExposureCouponShowTips()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local LoadTable = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUGCExposureCouponTips)
  if LoadTable ~= nil and LoadTable.lastShowTipsTime ~= 0 then
    local time_util = require("client.common.time_util")
    if time_util.IsSameDay(time_util.GetServerTimeInSec(), LoadTable.lastShowTipsTime or 0) then
      log(bWriteLog and "LogicUGCExposure:CheckExposureCouponShowTips have show")
      return false
    end
  end
  log(bWriteLog and "LogicUGCExposure:CheckExposureCouponShowTips can show")
  return true
end
function LogicUGCExposure:SaveExposureCouponShowTipsTime()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local SaveTable = {
    lastShowTipsTime = FuncUtil.GetServerTimeInSec()
  }
  log(bWriteLog and "LogicUGCExposure:SaveExposureCouponShowTipsTime lastShowTipsTime =" .. tostring(SaveTable.lastShowTipsTime))
  PlayerPrefsSystem.SaveTableToFile_N(SaveTable, PlayerPrefsSystem.ePlayerPrefsType.eUGCExposureCouponTips)
end
function LogicUGCExposure:PublicModListToArray(modList)
  if not modList or not next(modList) then
    return nil
  end
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local pubList = LogicUGC:GetSortedPubModList()
  if not pubList or not next(pubList) then
    log(bWriteLog and "LogicUGCExposure:PublicModListToArray no publist")
    return nil
  end
  self.PublishWorksList = {}
  for _, pubInfo in ipairs(pubList) do
    if pubInfo.modId and modList[pubInfo.modId] then
      self.PublishWorksList[pubInfo.modId] = modList[pubInfo.modId]
    end
  end
  return self.PublishWorksList
end
function LogicUGCExposure:GetPublishWorksList()
  return self.PublishWorksList
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogicUGCRank = class(CModuleBase, nil, LogicUGCExposure)
return CLogicUGCRank