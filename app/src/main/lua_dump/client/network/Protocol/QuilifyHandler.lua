local NetManager = require("client.network.comm.NetManager")
local QuilifyHandler = {
  url_cfgs = {}
}
function QuilifyHandler.send_get_tournament_rank_req(tournament_id, data_time)
  NetManager.SendPkg(1997759351, tournament_id, data_time)
end
function QuilifyHandler.on_get_tournament_rank_rsp(ret, tournament_id, date_time, rank_data, daily_score)
  local uncompressData = slua.LuaArchiverDecode(LuaStateWrapper, rank_data)
  if ret ~= 0 then
    ShowNotice(ret)
    return
  end
  if not uncompressData or not next(uncompressData) then
    ShowNotice(505021)
    EventSystem:postEvent(EVENTTYPE_INDIA_COMPETITION, EVENTID_TOURNAMENT_RANK_RES, {})
    return
  end
  EventSystem:postEvent(EVENTTYPE_INDIA_COMPETITION, EVENTID_TOURNAMENT_RANK_RES, uncompressData)
end
function QuilifyHandler.send_get_tournament_unions_req()
  NetManager.SendPkg(1401033071)
end
function QuilifyHandler.on_get_tournament_unions_rsp(data)
  log_tree("on_get_tournament_unions_rsp", data)
  if not data or not next(data) then
    ShowNotice(520027)
    return
  end
  for k, v in pairs(data) do
    QuilifyHandler.data = v
    break
  end
  UIManager.ShowUI(UIManager.UI_Config.qualifying_match, data)
end
function QuilifyHandler.getStartTime()
  if not QuilifyHandler.data or not QuilifyHandler.data.childrens then
    return 0
  end
  for k, v in pairs(QuilifyHandler.data.childrens) do
    if v.tournament.type == 1000 and v.tournament.user_data.enroll_state == 1 then
      return v.tournament.type_data.start_time
    end
  end
  return 0
end
function QuilifyHandler.getRoomName()
  if not QuilifyHandler.data or not QuilifyHandler.data.childrens then
    return ""
  end
  for k, v in pairs(QuilifyHandler.data.childrens) do
    if v.tournament.type == 1000 and v.tournament.user_data.enroll_state == 1 then
      return v.tournament.title
    end
  end
  return ""
end
function QuilifyHandler.on_tournament_return_notify(cost_info)
  if cost_info and cost_info.id then
    local itemcfg = CDataTable.GetTableData("Item", cost_info.id)
    if itemcfg then
      local tip = LocUtil.LocalizeResFormat("9171", itemcfg.ItemName)
      ShowNotice(tip or "")
    end
  end
end
function QuilifyHandler.send_get_tournament_unions_winner_req()
  NetManager.SendPkg(1568244647)
end
function QuilifyHandler.on_get_tournament_unions_winner_rsp(status, email, phone)
  log(bWriteLog and "on_get_tournament_unions_winner_rsp " .. tostring(status) .. tostring(email) .. tostring(phone))
  if status and status == 1 then
    UIManager.ShowUI(UIManager.UI_Config.qualifying_regist, email, phone)
  end
end
function QuilifyHandler.send_submit_tournament_unions_winner_info(email, phone)
  NetManager.SendPkg(684740812, email, phone)
end
function QuilifyHandler.on_submit_tournament_unions_winner_info_rsp(errcode)
  if errcode ~= 0 then
    ShowNotice(errcode)
  end
end
function QuilifyHandler.on_tournament_scrollview(cfgs)
  log_tree("on_tournament_scrollview", cfgs)
  if cfgs then
    QuilifyHandler.url_  end
end
return QuilifyHandler