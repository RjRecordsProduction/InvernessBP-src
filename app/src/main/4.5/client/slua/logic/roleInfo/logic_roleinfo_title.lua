local logic_roleinfo_title = {
  typeListName = {""},
  sortListName = {""},
  aliasList = {},
  arr_temp = {},
  alias_list_info = {},
  selectAliasId = 0,
  newCheckId = 0,
  newrank_id = 0,
  aliasInfo = {},
  currentChangeState = 1,
  openType = 0,
  Current_CheckHad = 0,
  Current_SelectType = 0,
  isNeedGuide = false,
  isCheck = false,
  isFirstIn = true,
  enum_Alias_State_Type = {
    notHave = 0,
    have = 1,
    use = 2
  }
}
local AliasData
local InitAliasTitle = function()
  for k, v in pairs(logic_roleinfo_title.alias_list_info) do
    local cfg = CDataTable.GetTableData("AliasCfg", k)
    if cfg ~= nil then
      v.title = FuncUtil.Gen_title(k, v.rank, v.ext_info, v.rank_id)
      log_format(bWriteLog and "InitAliasTitle id=%s, title=%s", k, v.title)
    end
  end
end
function logic_roleinfo_title.initSortList()
  logic_roleinfo_title.sortListName = {}
  for id = 4670, 4673 do
    local data = LocUtil.GetLocalizeResStr(id)
    table.insert(logic_roleinfo_title.sortListName, data)
  end
end
function logic_roleinfo_title.InitTypeList()
  logic_roleinfo_title.typeListName = {}
  local data = LocUtil.GetLocalizeResStr(4462)
  table.insert(logic_roleinfo_title.typeListName, data)
  for id = 4675, 4677 do
    local val = LocUtil.GetLocalizeResStr(id)
    table.insert(logic_roleinfo_title.typeListName, val)
  end
end
function logic_roleinfo_title.Enter()
  logic_roleinfo_title.alias_list_info = {}
  logic_roleinfo_title.get_alias_list()
  EventSystem:registEvent(EVENTTYPE_LOBBY, EVNETID_ITEM_GET_DONE, logic_roleinfo_title.OnGetItemDone)
end
function logic_roleinfo_title.Init()
end
function logic_roleinfo_title.OnBackLogin()
  AliasData = nil
end
function logic_roleinfo_title.OnModePostSwitch()
end
function logic_roleinfo_title.OnGetItemDone()
  log(bWriteLog and "logic_roleinfo_title.OnGetItemDone")
  logic_roleinfo_title.ShowGetAliasNow()
end
function logic_roleinfo_title.GetAliasListData()
  return logic_roleinfo_title.alias_list_info
end
function logic_roleinfo_title.ShowGetAliasNow()
  log(bWriteLog and "logic_roleinfo_title.ShowGetAliasNow")
  local logic_post_switch_popup = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_post_switch_popup)
  logic_post_switch_popup:TryExecuteOne(BP_ENUM_MODULE_ALIAS_POPUP)
end
function logic_roleinfo_title.ShowGetAlias()
  if not AliasData then
    log(bWriteLog and "ShowGetAlias no AliasData")
    return
  end
  if not logic_roleinfo_title.CheckAliasPopupExist() then
    log(bWriteLog and "logic_roleinfo_title.ShowGetAlias no exist")
    return false
  end
  log(bWriteLog and "[ : logic_roleinfo_title.ShowGetAlias")
  local ItemPrewViewSystem = require("client.slua.logic.item_preview.logic_itemPreview")
  ItemPrewViewSystem.CloseItemPreviewPanel()
  if not UIManager.GetUI(UIManager.UI_Config.Alias_popup) then
    UIManager.ShowUI(UIManager.UI_Config.Alias_popup, AliasData)
    logic_roleinfo_title.ClearAliasData()
  end
end
function logic_roleinfo_title.get_alias_list()
  local CharacterHandler = require("client.network.Protocol.CharacterHandler")
  CharacterHandler.send_get_alias_list()
end
function logic_roleinfo_title:click_alias_batch_report(clicked_alias)
  local CharacterHandler = require("client.network.Protocol.CharacterHandler")
  CharacterHandler.send_click_alias_batch_report(clicked_alias)
end
function logic_roleinfo_title.alias_list_res(res, list, red_point, alias)
  log_tree(bWriteLog and "logic_roleinfo_title.alias_list_res list:", list)
  log_tree(bWriteLog and "logic_roleinfo_title.alias_list_res alias:", alias)
  if res == NetErrorCode_NONE then
    log(bWriteLog and "[YY]alias_list_res==" .. tostring(red_point))
    if type(list) == "table" then
      logic_roleinfo_title.alias_list_info = list
      InitAliasTitle()
      logic_roleinfo_title.refreshAliasList()
      local SocialBottomAliasSystem = require("client.slua.logic.lobby.Left.logic_social_bottom_alias")
      SocialBottomAliasSystem.InitAlias(list)
      if alias and alias.id == 0 then
        DataMgr.roleData.alias.id = 0
        DataMgr.roleData.alias.title = ""
        DataMgr.roleData.alias.nation = ""
        DataMgr.roleData.alias.rank_id = 0
      end
      EventSystem:postEvent(EVENTTYPE_LOBBY_SOCIAL, EVENTID_LOBBY_SOCIAL_GOT_ALIAS_DATA)
      EventSystem:postEvent(EVENTTYPE_LOBBY_SOCIAL, EVENTID_LOBBY_SOCIAL_ALIAS_LIST)
      EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_IS_SHOW_ALIAS_ENTER_BROADCAST, alias.is_show_enter_broadcast)
    end
  end
end
function logic_roleinfo_title.refreshAliasList()
  if logic_roleinfo_title.isShow == false then
    return
  end
  logic_roleinfo_title.initAliasInfo()
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_NEW_ALIAS_REDDOT)
end
function logic_roleinfo_title.initAliasInfo()
  log(bWriteLog and "[ljw]initAliasInfo ")
  logic_roleinfo_title.aliasList = {}
  logic_roleinfo_title.arr_temp = {}
  DataMgr.roleData.alias.id = 0
  DataMgr.roleData.alias.title = ""
  DataMgr.roleData.alias.nation = ""
  logic_roleinfo_title.isNeedGuide = false
  logic_roleinfo_title.selectAliasId = 0
  logic_roleinfo_title.selectRankId = 0
  logic_roleinfo_title.aliasInfo = {}
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local clickData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eTitleRedPoint) or {}
  local TimeUtil = require("client.common.time_util")
  for _k, _v in pairs(logic_roleinfo_title.alias_list_info) do
    local cfg = CDataTable.GetTableData("AliasCfg", _k)
    if cfg ~= nil then
      local myItem = {}
      myItem.id = _k
      myItem.aliasState = _v.state
      myItem.aliasQuality = cfg.AliasQuality
      myItem.aliasDesc = cfg.AliasDesc
      myItem.aliasGetDesc = cfg.AliasGetDesc
      myItem.aliasType = tonumber(cfg.AliasType)
      myItem.aliasIconUrl = cfg.AliasIconPath
      myItem.aliasIconUrlBig = cfg.AliasIconPathBig
      myItem.aliasSortWeight = cfg.AliasSortWeight
      myItem.aliasReceiveTimeCompare = _v.receive_time
      myItem.aliasExpireTimeNum = _v.expire_ts
      myItem.rank_id = _v.rank_id
      if _v.state == logic_roleinfo_title.enum_Alias_State_Type.have or _v.state == logic_roleinfo_title.enum_Alias_State_Type.use then
        myItem.aliasReceiveTime = LocUtil.LocalizeResFormat("6422", TimeUtil.FormatTime_YMD(_v.receive_time))
        myItem.aliasExpireTime = _v.expire_ts
        myItem.aliasTitle = _v.title
        myItem.aliasReceiveTimeCompare = _v.receive_time
        myItem.aliasIsHaveUse = _v.have_used
        myItem.aliasNation = _v.nation
        myItem.bReddot = clickData[_k] ~= true and _v.have_used ~= 1 or false
      else
        myItem.aliasReceiveTime = 0
        myItem.aliasExpireTime = 0
        myItem.aliasTitle = cfg.AliasName
        myItem.aliasReceiveTimeCompare = 0
        myItem.aliasIsHaveUse = 0
        myItem.aliasNation = ""
      end
      if _v.state == logic_roleinfo_title.enum_Alias_State_Type.have then
        logic_roleinfo_title.isNeedGuide = true
      end
      if _v.state == logic_roleinfo_title.enum_Alias_State_Type.use then
        DataMgr.roleData.alias.id = myItem.id
        DataMgr.roleData.alias.title = myItem.aliasTitle
        DataMgr.roleData.alias.nation = myItem.aliasNation
        DataMgr.roleData.alias.rank_id = myItem.rank_id
      end
      table.insert(logic_roleinfo_title.aliasList, myItem)
      table.insert(logic_roleinfo_title.arr_temp, myItem)
    end
  end
  table.sort(logic_roleinfo_title.aliasList, logic_roleinfo_title.sortListFunction)
  logic_roleinfo_title:UpdateReddot()
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_ALL_TITLE)
end
function logic_roleinfo_title:UpdateReddot()
  local red_point = 0
  for k, v in ipairs(logic_roleinfo_title.aliasList) do
    if v.bReddot then
      red_point = 1
      break
    end
  end
  if red_point == 0 and red_point ~= DataMgr.roleData.alias.red_point then
    log(bWriteLog and "click_alias_batch_report")
    logic_roleinfo_title:click_alias_batch_report()
  end
  DataMgr.roleData.alias.end
function logic_roleinfo_title:RemoveReddot(itemID)
  log(bWriteLog and "logic_roleinfo_title:RemoveReddot id = " .. tostring(itemID))
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local clickData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eTitleRedPoint) or {}
  clickData[itemID] = true
  PlayerPrefsSystem.SaveTableToFile_N(clickData, PlayerPrefsSystem.ePlayerPrefsType.eTitleRedPoint)
  logic_roleinfo_title:UpdateReddot()
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_NEW_ALIAS_REDDOT)
end
function logic_roleinfo_title.sortListFunction(a, b)
  if a.aliasState == b.aliasState then
    if a.bReddot == b.bReddot then
      return a.id < b.id
    else
      return a.bReddot
    end
  else
    return a.aliasState > b.aliasState
  end
end
function logic_roleinfo_title.Release()
  EventSystem:unregistEvent(EVENTTYPE_LOBBY, EVNETID_ITEM_GET_DONE, logic_roleinfo_title.OnGetItemDone)
  EventSystem:unregistEvent(EVENTTYPE_LOBBY, EVENTID_ON_FACESLAP_END, logic_roleinfo_title.OnFaceSlapEnd)
end
function logic_roleinfo_title.change_alias_req(id, state)
  local CharacterHandler = require("client.network.Protocol.CharacterHandler")
  CharacterHandler.send_change_alias_req(id, state)
end
function logic_roleinfo_title.change_alias_rsp(res, id, rank_id)
  logic_roleinfo_title.newCheckId = id
  logic_roleinfo_title.new  if res == 0 then
    ShowNotice(49951)
    logic_roleinfo_title.get_alias_list()
  end
end
function logic_roleinfo_title.notify_add_alias(isShow, alias_id, alias_info, isClickReward)
  if isShow then
    DataMgr.roleData.alias.red_point = 1
    EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_GET_NEW_ALIAS)
    EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_NEW_ALIAS_REDDOT)
  end
  if isClickReward ~= 0 then
    log(bWriteLog and "logic_roleinfo_title.notify_add_alias is MinitvOneClickReward")
    return
  end
  AliasData = {}
  local cfg = CDataTable.GetTableData("AliasCfg", alias_id)
  if cfg ~= nil then
    local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
    local strRegion = Client.GetPublishRegion()
    local time_util = require("client.common.time_util")
    if strRegion == PublishRegionMacros.BLUEHOLE or PublishRegionMacros.IsJapanOrKorea() then
      AliasData.aliasGetTime = time_util.FormatTime_YMD(alias_info.receive_time, true)
    else
      AliasData.aliasGetTime = time_util.FormatTime_YMD(alias_info.receive_time)
    end
    AliasData.aliasId = alias_id
    AliasData.aliasIconUrl = cfg.AliasIconPath
    AliasData.aliasIconUrlBig = cfg.AliasIconPathBig
    AliasData.aliasTitle = FuncUtil.Gen_title(alias_id, alias_info.rank, alias_info.ext_info, alias_info.rank_id)
    AliasData.aliasQuality = cfg.AliasQuality
    AliasData.aliasDesc = cfg.AliasDesc
    AliasData.aliasNation = alias_info.nation
    AliasData.aliasType = cfg.AliasType
    AliasData.aliasSmallIconUrl = cfg.AliasIconPathSmall
    AliasData.rank_id = alias_info.rank_id
    if cfg.PopupImmediately == 1 then
      log(bWriteLog and "logic_roleinfo_title.notify_add_alias is Popup Immediately")
      logic_roleinfo_title.ShowGetAliasNow()
    elseif UIManager.IsUIShow(UIManager.UI_Config.Vehicle_CollectUI_UIBP) then
      log(bWriteLog and "logic_roleinfo_title.notify_add_alias is In Vehicle_CollectUI_UIBP")
      logic_roleinfo_title.ShowGetAliasNow()
    end
  end
end
function logic_roleinfo_title.ClearAliasData()
  AliasData = nil
  log(bWriteLog and "[ : ClearAliasData")
end
function logic_roleinfo_title.ShouldSlap()
  if not logic_roleinfo_title.CheckAliasPopupExist() then
    log(bWriteLog and "logic_roleinfo_title.ShouldSlap no exist")
    return false
  end
  if AliasData then
    log(bWriteLog and "logic_roleinfo_title.ShouldSlap true")
    return true
  end
  log(bWriteLog and "logic_roleinfo_title.ShouldSlap false")
  return false
end
function logic_roleinfo_title.ShowShareAlias(aliasId, _aliasData)
  local pAliasId = aliasId
  if not _aliasData then
    log(bWriteLog and "  : not AliasData")
    return
  end
  local Util = require("client.slua_ui_framework.util")
  local shareCfg = {
    sceneType = 7,
    share_type = ShareBtnTLogShareTypeDefine.ShareAfterWinningTheTitle,
    isOld = true,
    campaign = "alias",
    reasonStr = json.encode({
      uid = DataMgr.roleData.uid,
      aliasId = pAliasId
    })
  }
  Util.ShowShare(shareCfg, UIManager.UI_Config.Alias_Share, _aliasData)
end
function logic_roleinfo_title.ShowMomentShareAlias(closeCB)
  local logic_moment = require("client.slua.logic.moment.logic_moment")
  logic_moment.ShowMomentShare(closeCB)
end
function logic_roleinfo_title.hasRedpoint()
  if DataMgr.roleData.alias.red_point == 1 then
    return true
  end
  return false
end
function logic_roleinfo_title.IsHasSensitiveTitle()
  for k, v in pairs(logic_roleinfo_title.alias_list_info) do
    local cfg = CDataTable.GetTableData("AliasMatchCfg", k)
    if cfg ~= nil and tonumber(cfg.IsUnbindDelete) == 1 then
      return true
    end
  end
  return false
end
function logic_roleinfo_title.IsHasFeature(aliasID, featureType)
  local aliasCfg = CDataTable.GetTableData("FeaturesItems", aliasID)
  if aliasCfg then
    local StringUtil = require("common.string_util")
    local features = StringUtil.Split(aliasCfg.Features, ";")
    for _, featureID in ipairs(features) do
      local featureCfg = CDataTable.GetTableData("FeaturesConfig", tonumber(featureID))
      if featureCfg and featureCfg.FeatureType == featureType then
        return true
      end
    end
  end
  return false
end
function logic_roleinfo_title.CloseUI()
  logic_roleinfo_title.ClearCacheData()
end
function logic_roleinfo_title.ClearCacheData()
  logic_roleinfo_title.aliasList = {}
  logic_roleinfo_title.arr_temp = {}
  logic_roleinfo_title.typeListName = {}
  logic_roleinfo_title.aliasInfo = {}
  logic_roleinfo_title.selectAliasId = 0
  logic_roleinfo_title.isNeedGuide = false
  logic_roleinfo_title.newCheckId = 0
  logic_roleinfo_title.newrank_id = 0
end
function logic_roleinfo_title.CheckBoxSelect(check)
  logic_roleinfo_title.aliasList = {}
  if check then
    for k, v in pairs(logic_roleinfo_title.arr_temp) do
      if v.aliasState == logic_roleinfo_title.enum_Alias_State_Type.have or v.aliasState == logic_roleinfo_title.enum_Alias_State_Type.use then
        table.insert(logic_roleinfo_title.aliasList, v)
      end
    end
  else
    for k, v in pairs(logic_roleinfo_title.arr_temp) do
      table.insert(logic_roleinfo_title.aliasList, v)
    end
  end
  table.sort(logic_roleinfo_title.aliasList, logic_roleinfo_title.sortListFunction)
  if #logic_roleinfo_title.aliasList == 0 then
    logic_roleinfo_title.aliasInfo = {}
    logic_roleinfo_title.selectAliasId = 0
  elseif logic_roleinfo_title.newCheckId == 0 then
    logic_roleinfo_title.selectAliasId = logic_roleinfo_title.aliasList[1].id
    logic_roleinfo_title.aliasInfo = logic_roleinfo_title.aliasList[1]
  else
    local bMatch = false
    for _, v in pairs(logic_roleinfo_title.aliasList) do
      if logic_roleinfo_title.newCheckId == v.id then
        logic_roleinfo_title.selectAliasId = logic_roleinfo_title.newCheckId
        logic_roleinfo_title.aliasInfo = v
        bMatch = true
        break
      end
    end
    if not bMatch then
      logic_roleinfo_title.selectAliasId = logic_roleinfo_title.aliasList[1].id
      logic_roleinfo_title.aliasInfo = logic_roleinfo_title.aliasList[1]
    end
  end
end
function logic_roleinfo_title.CheckAliasPopupExist()
  local uiConfig = UIManager.GetConfigByKey("Alias_popup")
  if not uiConfig then
    log(bWriteLog and "logic_roleinfo_title.CheckAliasPopupExist UI config not found ")
    return false
  end
  local pak_util = require("client.common.pak_util")
  if not pak_util.IsFileExist(uiConfig.path) then
    log(bWriteLog and "logic_roleinfo_title.CheckAliasPopupExist uiConfig.path not exist ")
    return false
  end
  return true
end
return logic_roleinfo_title