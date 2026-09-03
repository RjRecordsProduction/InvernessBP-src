local LogicShowBrand = {}
local Promise = require("common.Promise")
function LogicShowBrand:DefineAndResetData()
  self.cachePerUid = {}
  self.settingMap = {}
  self.activeBrand = nil
  self.previewItemId = nil
  self.RequestBrandInfoCallBack = {}
  self.RequestBrandInfoTimer = {}
end
function LogicShowBrand:OnInitialize()
end
function LogicShowBrand:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_SHOWBRAND_QUERY_RESP, self.OnShowBrandQueryResp, self)
end
function LogicShowBrand:OnLogOut()
  self:DefineAndResetData()
end
function LogicShowBrand:OnPreSwitchGameStatus(preState, nextState)
  printf("LogicShowBrand:OnPreSwitchGameStatus preState:%s nextState:%s", preState, nextState)
  if nextState == GameStatus.Lobby then
    self:DefineAndResetData()
  end
end
function LogicShowBrand:ChangeSetting(template_id, slotIndex, dataId, val, data_source)
  printf("LogicShowBrand:ChangeSetting template_id:%s, slotIndex:%s, dataId:%s, val:%s, data_source:%s", template_id, slotIndex, dataId, val, data_source)
  self.settingMap[template_id][slotIndex].id = dataId
  self.settingMap[template_id][slotIndex].  if data_source then
    self.settingMap[template_id][slotIndex].  end
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_SHOWBRAND_ON_SETTING_CHANGE, template_id, slotIndex, dataId)
end
function LogicShowBrand:ChangeSettingFormNewSetting(template_id, newsettings)
  self.settingMap[template_id] = newsettings
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_SHOWBRAND_ON_SETTING_CHANGE, template_id, 0, 0)
end
function LogicShowBrand:ApplySelfSetting(template_id, settings, prefix)
  local ShowBrandHandler = require("client.network.Protocol.ShowBrandHandler")
  if settings == nil then
    settings = self.settingMap[template_id]
    if settings == nil then
      printf("LogicShowBrand:ApplySelfSetting empty settings")
      return
    end
  end
  local ShowBrandConst = require("client.slua.logic.showbrand.ShowBrandConst")
  for _, v in pairs(settings) do
    if type(v) == "table" and v.id and ShowBrandConst.PatrollerDataType[v.id] then
      local PatrollerModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PatrollerModule)
      v.val = PatrollerModule:GetPatrollerStatData(v.id)
    end
  end
  printf("LogicShowBrand:ApplySelfSetting template_id:%s", template_id)
  log_tree("LogicShowBrand:ApplySelfSetting", settings)
  ShowBrandHandler.send_save_common_brand_req(template_id, settings):Then(function(err)
    self.settingMap[template_id] = settings
    ShowBrandHandler.send_query_common_brand_req(DataMgr.roleData.uid, template_id)
  end)
end
function LogicShowBrand:GetSelfSetting(template_id)
  return self.settingMap[template_id] or nil
end
function LogicShowBrand:SaveBrandInfo(uid, template_id, settings)
  if uid == 0 or tostring(uid) == DataMgr.roleData.uid then
    self.activeBrand = template_id
    printf("LogicShowBrand:SaveBrandInfo myself template_id:%s", template_id)
    if not settings or not next(settings) then
      printf("LogicShowBrand:SaveBrandInfo empty settings\227\128\130use default settings")
      local ShowBrandUtils = require("client.slua.logic.showbrand.ShowBrandUtils")
      local defaultSettings = ShowBrandUtils.GetDefaultSettings(template_id)
      settings = {}
      for i, v in pairs(defaultSettings) do
        settings[i] = {id = v}
      end
    end
    local prevSettings = self.settingMap[template_id]
    if template_id == 1 then
      if prevSettings then
        for i, v in pairs(settings) do
          if prevSettings[i] then
            v.data_source = prevSettings[i].data_source
          end
        end
      else
        for i, v in pairs(settings) do
          v.data_source = v.data_source or 1100 + v.id
        end
      end
    end
    self.settingMap[template_id] = settings
  end
  local suid = tostring(uid)
  self.cachePerUid[suid] = {template_id = template_id, settings = settings}
end
function LogicShowBrand:OnShowBrandQueryResp(_, _, uid, template_id, settings)
  if self.RequestBrandInfoCallBack and self.RequestBrandInfoCallBack[uid] then
    local callBackList = self.RequestBrandInfoCallBack[uid]
    self.RequestBrandInfoCallBack[uid] = nil
    for _, func in ipairs(callBackList) do
      func(template_id, settings)
    end
  end
end
function LogicShowBrand:GetOrRequestBrandInfo(uid, template_id, callback)
  if uid == 0 then
  else
    uid = tonumber(uid)
    template_id = nil
  end
  if not self.RequestBrandInfoCallBack[uid] then
    self.RequestBrandInfoCallBack[uid] = {}
  end
  table.insert(self.RequestBrandInfoCallBack[uid], callback)
  local ShowBrandHandler = require("client.network.Protocol.ShowBrandHandler")
  ShowBrandHandler.send_query_common_brand_req(uid, template_id)
  if self.RequestBrandInfoTimer[uid] then
    self:RemoveTimer(self.RequestBrandInfoTimer[uid])
    self.RequestBrandInfoTimer[uid] = nil
  end
  self.RequestBrandInfoTimer[uid] = self:AddTimerOnce(5, function()
    self.RequestBrandInfoCallBack[uid] = nil
    self.RequestBrandInfoTimer[uid] = nil
  end)
end
function LogicShowBrand:GetCacheBrandInfo(uid)
  uid = tostring(uid)
  if uid ~= DataMgr.roleData.uid then
    return self.cachePerUid[uid]
  end
  if not self.activeBrand or not self.settingMap[self.activeBrand] then
    return nil
  end
  return {
    template_id = self.activeBrand,
    settings = self.settingMap[self.activeBrand]
  }
end
function LogicShowBrand:RemoveCacheBrandInfo(uid)
  uid = tostring(uid)
  if uid ~= DataMgr.roleData.uid then
    self.cachePerUid[uid] = nil
    return
  end
  self.activeBrand = nil
end
function LogicShowBrand:SetDefaultPartnerName(name)
  self._DefaultPartnerName = tostring(name)
end
function LogicShowBrand:GetDefaultPartnerName()
  if not self._DefaultPartnerName then
    return LocUtil.GetLocalizeResStr(106052)
  end
  return self._DefaultPartnerName
end
function LogicShowBrand:SetActiveBrand(template_id)
  self.activeBrand = template_id
end
function LogicShowBrand:SetPreviewModeId(previewItemId)
  self.end
function LogicShowBrand:GetActiveBrandCfg()
  local cfg = CDataTable.GetTableData("ShowBrandTemplateCfg", self.activeBrand)
  return cfg
end
function LogicShowBrand:CheckIsUsing(itemId)
  local cfg = CDataTable.GetTableData("ShowBrandTemplateCfg", self.activeBrand)
  return cfg and cfg.ItemID == itemId
end
function LogicShowBrand:on_query_player_partner_info_rsp(uid1, uid2)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogicShowBrand = class(CModuleBase, nil, LogicShowBrand)
return CLogicShowBrand