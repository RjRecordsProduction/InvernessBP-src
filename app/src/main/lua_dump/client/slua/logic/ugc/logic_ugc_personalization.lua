local Logic_UGC_Personalization = {}
local TableUtil = require("common.table_util")
local facebookhandler = require("client.network.Protocol.FacebookHandler")
local interestLimitNum = 5
function Logic_UGC_Personalization:ctor(_, ModuleConfig)
  self.RecommendData = {}
  self.TagLimitNum = 5
  self.FavorModLimitNum = 5
  self.Allinterest_list = {}
  self.Allinterest_list_setting = {}
  self.favor_tags = {}
  self.favor_mod_setting = {}
  self.my_favor_mods = {}
  self.Changeinterest_list = {}
  self.Changeinterest_list_setting = {}
end
function Logic_UGC_Personalization:OnLogOut()
  self.RecommendData = nil
  self.Allinterest_list = nil
  self.Allinterest_list_setting = nil
  self.Changeinterest_list = nil
  self.Changeinterest_list_setting = nil
end
function Logic_UGC_Personalization:RsqRecommendSettingData(cur_save_count, max_save_count, my_favor_mods, interest_list, interest_list_setting, favor_tags, favor_mod_setting)
  self.RecommendData.  self.RecommendData.  self.Allinterest_list = TableUtil.CopyTable(interest_list)
  self.All  self.  self.  self:InitFavorModSetting()
  self.  self.Changeinterest_list = TableUtil.CopyTable(self.Allinterest_list)
  self.Changeinterest_list_setting = TableUtil.CopyTable(self.Allinterest_list_setting)
  local Show_interest_list = self:InitInterest_list(interest_list, my_favor_mods)
  self.RecommendData.interest_list = Show_interest_list
  local Show_interest_list_setting = self:InitInterest_list_setting(Show_interest_list, interest_list_setting)
  self.RecommendData.interest_list_setting = Show_interest_list_setting
  self.RecommendData.favor_tags = TableUtil.CopyTable(self.favor_tags)
  self.RecommendData.favor_mod_setting = TableUtil.CopyTable(self.favor_mod_setting)
  self.RecommendData.my_favor_mods = TableUtil.CopyTable(self.my_favor_mods)
  local ModIDList = {}
  for k, ModID in pairs(self.RecommendData.my_favor_mods) do
    table.insert(ModIDList, ModID)
  end
  for ModID, Score in pairs(self.RecommendData.interest_list) do
    table.insert(ModIDList, ModID)
  end
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local ModInfoList, ReqList = LogicUGC:BatchGetModInfo(ModIDList, LogicUGC.C_ModListTypes.RecommendSetting, nil, {bSplit = true, bSimple = true})
  local bNeedReq = ReqList and 0 < #ReqList
  if (not ModInfoList or not next(ModInfoList)) and not bNeedReq then
    log(bWriteLog and "UGC_AuthorModPage:RequestOnePageModData no need to request")
    self:OnModInfoBatchRsp(ModInfoList, LogicUGC.C_ModListTypes.RecommendSetting)
  end
end
function Logic_UGC_Personalization:OnModInfoBatchRsp(MetaList, ListType, Param, FilterOfflineModList)
  local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
  if UGCMacros.CheckMetaType(ListType, UGCMacros.ENUM_MODE_TYPE.RecommendSetting) then
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_RECOMMENDSETTINGDATA_REFRESH, self.RecommendData)
  end
end
function Logic_UGC_Personalization:SetRecommendSetting()
  local UGCSearchHandler = require("client.network.Protocol.UGCSearchHandler")
  log(bWriteLog and "[v_yibxu] Logic_UGC_Personalization:SetRecommendSetting")
  if TableUtil.CountTable(self.Changeinterest_list) > 50 then
    local Map_interest_list = {}
    for key, value in pairs(self.Changeinterest_list) do
      table.insert(Map_interest_list, {key = key, score = value})
    end
    table.sort(Map_interest_list, function(a, b)
      if a.score == b.score then
        return a.key > b.key
      else
        return a.score > b.score
      end
    end)
    local Top50_Changeinterest_list = {}
    local Top50_Changeinterest_list_setting = {}
    for index, value in ipairs(Map_interest_list) do
      if index <= 50 then
        Top50_Changeinterest_list[value.key] = value.score
        if self.Changeinterest_list_setting[value.key] then
          Top50_Changeinterest_list_setting[value.key] = self.Changeinterest_list_setting[value.key]
        end
      else
        break
      end
    end
    self.Changeinterest_list = Top50_Changeinterest_list
    self.Changeinterest_list_setting = Top50_Changeinterest_list_setting
  end
  UGCSearchHandler.send_set_recommend_setting_req(self.RecommendData.my_favor_mods, self.Changeinterest_list, self.Changeinterest_list_setting, self.RecommendData.favor_tags, self.RecommendData.favor_mod_setting)
end
function Logic_UGC_Personalization:RefreshLocalData(cur_save_count, max_save_count, my_favor_mods, interest_list, interest_list_setting, favor_tags, favor_mod_setting)
  self.RecommendData.  self.RecommendData.  self.All  self.All  self.  self.  self:InitFavorModSetting()
  self.  self.BChange = false
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_REFRESH_RECOMMENDSETTING_UI, self.RecommendData)
end
function Logic_UGC_Personalization:CheckShowTipsMenu()
  local guess_you_like_config_abtest = self:GetABTest()
  if not guess_you_like_config_abtest or guess_you_like_config_abtest ~= 1 then
    log(bWriteLog and "guess_you_like_config_abtest not hit")
    return fasle
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local LoadTable = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUGCPlayPreferenceTipsMenu)
  if LoadTable ~= nil and LoadTable.lastShowTipsTime ~= 0 then
    local time_util = require("client.common.time_util")
    if time_util.IsSameDay(time_util.GetServerTimeInSec(), LoadTable.lastShowTipsTime) then
      log(bWriteLog and "[v_yibxu] Logic_UGC_Personalization:CheckShowTipsMenu has show")
      return false
    end
  end
  log(bWriteLog and "[v_yibxu] Logic_UGC_Personalization:CheckShowTipsMenu can show")
  return true
end
function Logic_UGC_Personalization:SetModHot(heat)
  if not self.RecommendData.favor_mod_setting then
    log(bWriteLog and "[v_yibxu] Logic_UGC_Personalization:SetModHot self.RecommendData.favor_mod_setting = nil")
    return
  end
  self.RecommendData.favor_mod_setting.end
function Logic_UGC_Personalization:SetModTime(duration)
  if not self.RecommendData.favor_mod_setting then
    log(bWriteLog and "[v_yibxu] Logic_UGC_Personalization:SetModTime self.RecommendData.favor_mod_setting = nil")
    return
  end
  self.RecommendData.favor_mod_setting.end
function Logic_UGC_Personalization:SetFavorTags(tags)
  self.RecommendData.favor_  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_REFRESH_RECOMMENDSETTING_UI, self.RecommendData)
end
function Logic_UGC_Personalization:SetLikeState(mod_id, blike)
  if blike then
    if not self.RecommendData.interest_list_setting[mod_id] then
      self.RecommendData.interest_list_setting[mod_id] = {}
    end
    self.RecommendData.interest_list_setting[mod_id] = blike
    if not self.Changeinterest_list_setting[mod_id] then
      self.Changeinterest_list_setting[mod_id] = {}
    end
    self.Changeinterest_list_setting[mod_id] = blike
    ShowNotice(LocUtil.GetLocalizeResStr(76721))
  else
    self.RecommendData.interest_list_setting[mod_id] = nil
    self.Changeinterest_list_setting[mod_id] = nil
    ShowNotice(LocUtil.GetLocalizeResStr(62449))
  end
end
function Logic_UGC_Personalization:AddTOFavorModList(ModInfo)
  if #self.RecommendData.my_favor_mods < self.FavorModLimitNum then
    table.insert(self.RecommendData.my_favor_mods, ModInfo.mod_id)
    if self.RecommendData.interest_list[ModInfo.mod_id] then
      self.RecommendData.interest_list[ModInfo.mod_id] = nil
    end
    if self.RecommendData.interest_list_setting[ModInfo.mod_id] then
      self.RecommendData.interest_list_setting[ModInfo.mod_id] = nil
    end
    if self.Allinterest_list[ModInfo.mod_id] then
      self.Changeinterest_list[ModInfo.mod_id] = nil
    end
    if self.Allinterest_list_setting[ModInfo.mod_id] ~= nil then
      self.Changeinterest_list_setting[ModInfo.mod_id] = nil
    end
    ShowNotice(LocUtil.GetLocalizeResStr(76722))
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_REFRESH_RECOMMENDF_FAVORMAP_UI)
  else
    ShowNotice(LocUtil.GetLocalizeResStr(76723))
  end
end
function Logic_UGC_Personalization:DelFavorMod(ModInfo)
  for key, value in pairs(self.RecommendData.my_favor_mods) do
    if ModInfo.mod_id == value then
      table.remove(self.RecommendData.my_favor_mods, key)
    end
  end
  if self.Allinterest_list[ModInfo.mod_id] then
    self.Changeinterest_list[ModInfo.mod_id] = self.Allinterest_list[ModInfo.mod_id]
  end
  if self.Allinterest_list_setting[ModInfo.mod_id] ~= nil then
    self.Changeinterest_list_setting[ModInfo.mod_id] = self.Allinterest_list_setting[ModInfo.mod_id]
  end
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_REFRESH_RECOMMENDF_FAVORMAP_UI)
end
function Logic_UGC_Personalization:DeleteMod(ModInfo, soure)
  if soure == 1 then
    for key, value in pairs(self.RecommendData.my_favor_mods) do
      if ModInfo.mod_id == value then
        table.remove(self.RecommendData.my_favor_mods, key)
      end
    end
    if self.Allinterest_list[ModInfo.mod_id] then
      self.Changeinterest_list[ModInfo.mod_id] = self.Allinterest_list[ModInfo.mod_id]
    end
    if self.Allinterest_list_setting[ModInfo.mod_id] ~= nil then
      self.Changeinterest_list_setting[ModInfo.mod_id] = self.Allinterest_list_setting[ModInfo.mod_id]
    end
  elseif soure == 2 then
    self.RecommendData.interest_list[ModInfo.mod_id] = nil
    self.RecommendData.interest_list_setting[ModInfo.mod_id] = nil
    if self.Allinterest_list[ModInfo.mod_id] then
      self.Changeinterest_list[ModInfo.mod_id] = nil
    end
    if self.Allinterest_list_setting[ModInfo.mod_id] ~= nil then
      self.Changeinterest_list_setting[ModInfo.mod_id] = nil
    end
  end
end
function Logic_UGC_Personalization:GetReuseFallData()
  local Config_UGC_Center = require("client.slua.logic.ugc.center.config_ugc_center")
  local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local showList = {}
  if not self.RecommendData then
    log(bWriteLog and "[v_yibxu] Logic_UGC_Personalization:GetReuseFallData self.RecommendData = nil")
    return showList
  end
  if not (self.RecommendData.my_favor_mods and self.RecommendData.interest_list) or not self.RecommendData.interest_list_setting then
    return showList
  end
  local Title = {}
  Title.SubType = Config_UGC_Center.ItemDataType.Title
  Title.BFavorMap = true
  Title.FavorMapNum = #self.RecommendData.my_favor_mods
  table.insert(showList, Title)
  if not next(self.RecommendData.my_favor_mods) then
    local Content = {}
    Content.SubType = Config_UGC_Center.ItemDataType.Content
    Content.BFavorMap = true
    Content.State = 1
    Content.BVaild = true
    table.insert(showList, Content)
  else
    for key, value in pairs(self.RecommendData.my_favor_mods) do
      local ModInfo = LogicUGC:GetModByAllCache(value)
      if ModInfo then
        local Content = {}
        Content.SubType = Config_UGC_Center.ItemDataType.Content
        Content.BFavorMap = true
        Content.ModInfo = ModInfo.pub_mod_meta
        Content.State = 0
        Content.BVaild = false
        table.insert(showList, Content)
      else
        log(bWriteLog and "[v_yibxu] Logic_UGC_Personalization:GetReuseFallData mod_id = " .. value .. " ModInfo is nil")
      end
    end
  end
  local Spacer = {}
  Spacer.SubType = Config_UGC_Center.ItemDataType.Spacer
  table.insert(showList, Spacer)
  local Title = {}
  Title.SubType = Config_UGC_Center.ItemDataType.Title
  Title.BFavorMap = false
  table.insert(showList, Title)
  if not next(self.RecommendData.interest_list) then
    local Content = {}
    Content.SubType = Config_UGC_Center.ItemDataType.Content
    Content.BFavorMap = false
    Content.BVaild = true
    if not next(self.RecommendData.my_favor_mods) then
      Content.State = 2
    else
      Content.State = 1
    end
    table.insert(showList, Content)
  else
    for key, value in pairs(self.RecommendData.interest_list) do
      local ModInfo = LogicUGC:GetModByAllCache(key)
      if ModInfo then
        local Content = {}
        Content.SubType = Config_UGC_Center.ItemDataType.Content
        Content.BFavorMap = false
        Content.ModInfo = ModInfo.pub_mod_meta
        Content.State = 0
        Content.BVaild = false
        if self.RecommendData.interest_list_setting[key] then
          Content.BRecomment = self.RecommendData.interest_list_setting[key]
        else
          Content.BRecomment = false
          log(bWriteLog and "[v_yibxu] Logic_UGC_Personalization:GetReuseFallData self.RecommendData.interest_list_setting[key] = nil key = " .. key)
        end
        table.insert(showList, Content)
      else
        self:RemoveAbnormalInterestMod(key)
      end
    end
  end
  return showList
end
function Logic_UGC_Personalization:InitInterest_list(interest_list, my_favor_mods)
  local Show_interest_list = {}
  local Map_interest_list = {}
  if not interest_list then
    return Show_interest_list
  end
  for key, mod_id in pairs(my_favor_mods) do
    interest_list[mod_id] = nil
  end
  for key, value in pairs(interest_list) do
    table.insert(Map_interest_list, {key = key, score = value})
  end
  table.sort(Map_interest_list, function(a, b)
    if a.score == b.score then
      return a.key > b.key
    else
      return a.score > b.score
    end
  end)
  for index, value in ipairs(Map_interest_list) do
    if index <= interestLimitNum then
      Show_interest_list[value.key] = value.score
    end
  end
  return Show_interest_list
end
function Logic_UGC_Personalization:InitInterest_list_setting(Show_interest_list, interest_list_setting)
  local Show_interest_list_setting = {}
  for mod_id, value in pairs(Show_interest_list) do
    if interest_list_setting[mod_id] then
      Show_interest_list_setting[mod_id] = interest_list_setting[mod_id]
    else
      Show_interest_list_setting[mod_id] = nil
    end
  end
  return Show_interest_list_setting
end
function Logic_UGC_Personalization:InitFavorModSetting()
  if not self.favor_mod_setting.heat then
    self.favor_mod_setting.heat = 0
  end
  if not self.favor_mod_setting.duration then
    self.favor_mod_setting.duration = 0
  end
end
function Logic_UGC_Personalization:RemoveAbnormalFavorMod(mod_id)
  log(bWriteLog and "[v_yibxu] Logic_UGC_Personalization:RevoveAbnormalFavorMod mod_id = " .. mod_id .. " ModInfo is nil")
  for key, value in pairs(self.RecommendData.my_favor_mods) do
    if value == mod_id then
      table.remove(self.RecommendData.my_favor_mods, key)
      break
    end
  end
  for key, value in pairs(self.my_favor_mods) do
    if value == mod_id then
      table.remove(self.my_favor_mods, key)
      break
    end
  end
end
function Logic_UGC_Personalization:RemoveAbnormalInterestMod(mod_id)
  log(bWriteLog and "[v_yibxu] Logic_UGC_Personalization:RevoveAbnormalInterestMod mod_id = " .. mod_id .. " ModInfo is nil")
  if self.Changeinterest_list[mod_id] then
    self.Changeinterest_list[mod_id] = nil
  end
  if self.Changeinterest_list_setting[mod_id] then
    self.Changeinterest_list_setting[mod_id] = nil
  end
  if self.Allinterest_list[mod_id] then
    self.Allinterest_list[mod_id] = nil
  end
  if self.Allinterest_list_setting[mod_id] then
    self.Allinterest_list_setting[mod_id] = nil
  end
end
function Logic_UGC_Personalization:CheckRevise()
  local BChange = false
  log_tree(bWriteLog and "[v_yibxu] Logic_UGC_Personalization:CheckRevise self.Changeinterest_list = ", self.Changeinterest_list)
  log_tree(bWriteLog and "[v_yibxu] Logic_UGC_Personalization:CheckRevise self.Changeinterest_list_setting = ", self.Changeinterest_list_setting)
  if not TableUtil.IsSameTable(self.Changeinterest_list, self.Allinterest_list) then
    log(bWriteLog and "[v_yibxu] Logic_UGC_Personalization:CheckRevise \231\140\156\228\189\160\229\150\156\231\136\177\229\156\176\229\155\190\230\155\180\230\148\185")
    BChange = true
  end
  if not TableUtil.IsSameTable(self.Changeinterest_list_setting, self.Allinterest_list_setting) then
    log(bWriteLog and "[v_yibxu] Logic_UGC_Personalization:CheckRevise \231\140\156\228\189\160\229\150\156\231\136\177\229\156\176\229\155\190\229\164\154\229\164\154\230\142\168\232\141\144\230\155\180\230\148\185")
    BChange = true
  end
  if not TableUtil.IsSameTable(self.RecommendData.favor_mod_setting, self.favor_mod_setting) then
    log(bWriteLog and "[v_yibxu] Logic_UGC_Personalization:CheckRevise \229\156\176\229\155\190 \231\131\173\229\186\166or \230\151\182\233\149\191 \230\155\180\230\148\185")
    BChange = true
  end
  if not TableUtil.IsSameTable(self.RecommendData.favor_tags, self.favor_tags) then
    log(bWriteLog and "[v_yibxu] Logic_UGC_Personalization:CheckRevise \229\150\156\231\136\177\230\160\135\231\173\190\230\155\180\230\148\185")
    BChange = true
  end
  if not TableUtil.IsSameTable(self.RecommendData.my_favor_mods, self.my_favor_mods) then
    log(bWriteLog and "[v_yibxu] Logic_UGC_Personalization:CheckRevise \229\150\156\231\136\177\229\156\176\229\155\190\230\155\180\230\148\185")
    BChange = true
  end
  return BChange
end
function Logic_UGC_Personalization:SetABTest(guess_you_like_config_abtest)
  log(bWriteLog and "Logic_UGC_Personalization:SetABTest guess_you_like_config_abtest = " .. tostring(guess_you_like_config_abtest))
  self.end
function Logic_UGC_Personalization:GetABTest()
  return self.guess_you_like_config_abtest
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogic_UGC_Personalization = class(CModuleBase, nil, Logic_UGC_Personalization)
return CLogic_UGC_Personalization