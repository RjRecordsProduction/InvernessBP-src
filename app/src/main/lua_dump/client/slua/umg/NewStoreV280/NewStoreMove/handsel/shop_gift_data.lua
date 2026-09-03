local shop_gift_data = {
  MsgCenterTabType = {
    rec_gift = 0,
    ask = 1,
    give_away = 2,
    thanks = 3
  },
  EMsgType = {
    Receive = 11,
    Ask = 12,
    Give = 13
  }
}
shop_gift_data.tabType2msgType = {
  [shop_gift_data.MsgCenterTabType.rec_gift] = shop_gift_data.EMsgType.Receive,
  [shop_gift_data.MsgCenterTabType.ask] = shop_gift_data.EMsgType.Ask,
  [shop_gift_data.MsgCenterTabType.give_away] = shop_gift_data.EMsgType.Give
}
local StringUtil = require("common.string_util")
function shop_gift_data.GetName(profileInfo)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local friendData = logic_profile:GetLocalProfile(profileInfo.uid)
  local tagName = ""
  if friendData ~= nil then
    if friendData.remarks_name and friendData.remarks_name ~= "" then
      tagName = friendData.remarks_name
    elseif profileInfo.platName and profileInfo.platName ~= "" then
      tagName = profileInfo.platName
    end
  end
  local name = profileInfo.nickName
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  if LogicFriend.IsPlatFriend(profileInfo.uid) and tagName ~= "" then
    tagName = StringUtil.SubString(tagName, 1, 15)
    name = string.format("%s(%s)", profileInfo.nickName, tagName)
  end
  return name, profileInfo.nickName, tagName
end
function shop_gift_data.BuildRecv(i, v, tmplist)
  local data = v
  if data ~= nil then
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local profileInfo = logic_profile:GetLocalProfile(data.sender)
    local alias = {
      id = 0,
      title = "",
      nation = "",
      rank_id = 0
    }
    if profileInfo and profileInfo.alias then
      alias.id = profileInfo.alias.id
      alias.title = profileInfo.alias.title
      alias.nation = profileInfo.alias.nation
      alias.rank_id = profileInfo.alias.rank_id
    end
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local recv = {
      uid = tostring(data.sender),
      name = "",
      nickName = "",
      iconUrl = "",
      gender = 1,
      level = 1,
      avatarBox = 1,
      intimacy = 0,
      relation = 0,
      time = data.time or 0,
      date = "",
      shopid = data.shopid,
      item = data.itemid,
      give_type = data.give_type,
      read = data.read or 0,
      style = data.style,
      message = "",
      notice = data.msg,
      isFetched = data.fetch ~= 0,
      inited = false,
      roleNation = logic_profile:GetPlayerNation(data.sender) or "",
      alias_id = alias.id,
      alias_title = alias.title,
      alias_nation = alias.nation,
      alias_rank_id = alias.rank_id,
      colorID = data.color,
      patternID = data.pattern,
      valid_hours = data.valid_hours,
      itemNum = data.item_count or 1,
      intimacy_one = data.intimacy_one or 0,
      index = i
    }
    local TimeUtil = require("client.common.time_util")
    recv.date = TimeUtil.FormatTime_MD(data.time, true)
    if recv.isFetched then
      local text = LocUtil.GetLocalizeResStr(501002)
      recv.message = string.format(text, "", shop_gift_data.GetShopItemName(recv.item, recv.colorID, recv.patternID))
    else
      recv.message = LocUtil.GetLocalizeResStr(501001)
    end
    table.insert(tmplist, recv)
    local itemCfg = CDataTable.GetTableData("TxMissionItem", data.itemid)
    if itemCfg then
      local LogicTxMissionDownload = require("client.slua.logic.TxMission.logic_xmission_download")
      local PufferMapManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_map_manager)
      if LogicTxMissionDownload.GetTPlanMapDownloadState(LogicTxMissionDownload.BASE_MAP_KEY) then
        PufferMapManager:MountMapPak(LogicTxMissionDownload.BASE_MAP_KEY)
        log(bWriteLog and "shop_gift_data.BuildRecv:MountMapPak called")
      end
      log(bWriteLog and "shop_gift_data.BuildRecv:MountMapPak")
    end
  end
end
function shop_gift_data.BuildSend(i, v, tmplist)
  local data = v
  if not data then
    return
  end
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profileInfo = logic_profile:GetLocalProfile(data.sender)
  local alias = {
    id = 0,
    title = "",
    nation = "",
    rank_id = 0
  }
  if profileInfo and profileInfo.alias then
    alias.id = profileInfo.alias.id
    alias.title = profileInfo.alias.title
    alias.nation = profileInfo.alias.nation
    alias.rank_id = profileInfo.alias.rank_id
  end
  local recv = {
    uid = tostring(data.receiver),
    name = "",
    nickName = "",
    iconUrl = "",
    gender = 1,
    level = 1,
    avatarBox = 1,
    intimacy = 0,
    relation = 0,
    time = data.time,
    date = "",
    shopid = data.shopid,
    item = data.itemid,
    give_type = data.give_type,
    read = data.read,
    style = data.style,
    message = data.msg,
    inited = false,
    roleNation = logic_profile:GetPlayerNation(data.receiver),
    alias_id = alias.id,
    alias_title = alias.title,
    alias_nation = alias.nation,
    alias_rank_id = alias.rank_id,
    valid_hours = data.valid_hours,
    itemNum = data.item_count,
    ask_index = data.ask_index,
    index = i
  }
  local TimeUtil = require("client.common.time_util")
  recv.date = TimeUtil.FormatTime_MD(data.time, true)
  local text = LocUtil.GetLocalizeResStr(501004)
  recv.message = string.format(text, shop_gift_data.GetShopItemName(recv.item, nil, nil, recv.itemNum))
  log(bWriteLog and "gift center 13 rolenation = " .. tostring(recv.roleNation))
  table.insert(tmplist, recv)
end
function shop_gift_data.BuildAsk(i, v, tmplist)
  local AskForSystem = require("client.slua.logic.ask_for.logic_ask_for")
  local data = v
  if data ~= nil and data.given == nil then
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local profileInfo = logic_profile:GetLocalProfile(data.sender)
    local alias = {
      id = 0,
      title = "",
      nation = "",
      rank_id = 0
    }
    if profileInfo and profileInfo.alias then
      alias.id = profileInfo.alias.id
      alias.title = profileInfo.alias.title
      alias.nation = profileInfo.alias.nation
      alias.rank_id = profileInfo.alias.rank_id
    end
    local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
    local recv = {
      uid = tostring(data.sender),
      name = "",
      nickName = "",
      iconUrl = "",
      gender = 1,
      level = 1,
      avatarBox = 1,
      intimacy = LogicFriend.GetInnerFriendIntimacy(data.sender) or 0,
      relation = 0,
      time = data.cadge_time or 0,
      date = "",
      cadge_id = data.cadge_id,
      item = AskForSystem.GetItemIdByCadgeId(data.cadge_id),
      message = "",
      notice = data.text,
      gived = data.given,
      roleNation = logic_profile:GetPlayerNation(data.sender),
      alias_id = alias.id,
      alias_title = alias.title,
      alias_nation = alias.nation,
      alias_rank_id = alias.rank_id,
      valid_hours = data.valid_hours,
      read = data.read or 0,
      index = i
    }
    if data.refuse then
      recv.is_refused = true
    else
      recv.is_refused = false
    end
    local TimeUtil = require("client.common.time_util")
    recv.date = TimeUtil.FormatTime_MD(data.time, true)
    local text = LocUtil.GetLocalizeResStr(501003)
    local itemDataCfg = CDataTable.GetTableData("Item", recv.item)
    if itemDataCfg ~= nil then
      recv.message = string.format(text, itemDataCfg.ItemName)
    end
    table.insert(tmplist, recv)
  end
end
function shop_gift_data.GetShopItemName(nItemId, colorID, patternID, itemNum)
  colorID = colorID or 0
  patternID = patternID or 0
  local itemDataCfg = CDataTable.GetTableData("Item", nItemId)
  if itemDataCfg ~= nil then
    if itemNum and FuncUtil.IsPlayerJPKR() and 2 <= itemNum then
      return FuncUtil.GetItemName(itemDataCfg.ItemName, colorID, patternID) .. " x" .. tostring(itemNum)
    end
    return FuncUtil.GetItemName(itemDataCfg.ItemName, colorID, patternID)
  end
  return ""
end
function shop_gift_data.GetIndexDataList(list, index)
  for i, v in pairs(list) do
    if v.index == index then
      return v
    end
  end
  return nil
end
return shop_gift_data