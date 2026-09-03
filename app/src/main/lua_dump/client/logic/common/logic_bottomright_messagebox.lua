local BottomRightMessageBoxSystem = {
  itemId = 0,
  count = 0,
  maxCount = 0,
  type = 0
}
function BottomRightMessageBoxSystem.ResetData()
  BottomRightMessageBoxSystem.itemId = 0
  BottomRightMessageBoxSystem.count = 0
  BottomRightMessageBoxSystem.maxCount = 0
  BottomRightMessageBoxSystem.type = 0
end
function BottomRightMessageBoxSystem.OnModePostSwitch(preState, nextState)
  log(bWriteLog and "BottomRightMessageBoxSystem.OnModePostSwitch, nextState = " .. tostring(nextState))
  if GameStatus.IsInLobbyOrMainCity() and BottomRightMessageBoxSystem.itemId ~= 0 then
    BottomRightMessageBoxSystem.ProcessData(BottomRightMessageBoxSystem.itemId, BottomRightMessageBoxSystem.count, BottomRightMessageBoxSystem.maxCount, BottomRightMessageBoxSystem.type, BottomRightMessageBoxSystem.can_into_depot)
  end
end
function BottomRightMessageBoxSystem.ProcessData(itemId, count, maxCount, type, can_into_depot)
  log(bWriteLog and "BottomRightMessageBoxSystem.ProcessData")
  BottomRightMessageBoxSystem.ResetData()
  local text = LocUtil.GetLocalizeResStr(4996)
  local num = 1
  if not maxCount then
    num = count
  else
    num = maxCount
  end
  local callback = function()
    FuncUtil.ItemJump(itemId)
  end
  local jumpInfo = {btnText = text, callback = callback}
  if can_into_depot ~= 1 then
    jumpInfo = nil
  end
  local topLimit
  if not maxCount then
    topLimit = false
  else
    topLimit = true
  end
  log(bWriteLog and "  : num" .. tostring(num))
  local RightPopSystem = require("client.slua.logic.lobby_popui.logic_right_popup")
  local title = LocUtil.LocalizeResFormat(6719)
  RightPopSystem.ShowPopupWithNum(title, itemId, num, topLimit, jumpInfo)
end
function BottomRightMessageBoxSystem.On_add_battle_item_notify(itemId, count, maxCount, type, can_into_depot)
  log(bWriteLog and "BottomRightMessageBoxSystem.On_add_battle_item_notify, itemId = " .. tostring(itemId) .. ", count = " .. tostring(count) .. ", maxCount = " .. tostring(maxCount) .. ", type = " .. tostring(type) .. ", can_into_depot = " .. tostring(can_into_depot))
  if type == 1 then
    if GameStatus.IsInLobbyOrMainCity() then
      BottomRightMessageBoxSystem.ProcessData(itemId, count, maxCount, type, can_into_depot)
    else
      BottomRightMessageBoxSystem.      BottomRightMessageBoxSystem.      BottomRightMessageBoxSystem.      BottomRightMessageBoxSystem.      BottomRightMessageBoxSystem.    end
  end
end
return BottomRightMessageBoxSystem