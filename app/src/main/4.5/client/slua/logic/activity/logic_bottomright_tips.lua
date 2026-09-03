BottomRightTipsSystem = BottomRightTipsSystem or {
  tipData = {}
}
function BottomRightTipsSystem.ResetData()
  BottomRightTipsSystem.tipData = {}
end
function BottomRightTipsSystem.ProcessData(itemID, Title, content, jumpInfo)
  log(bWriteLog and "[gpb] BottomRightTipsSystem, ProcessData = " .. tostring(content))
  local RightPopSystem = require("client.slua.logic.lobby_popui.logic_right_popup")
  local path = jumpInfo.texturePath
  if itemID then
    local UIUtil = require("client.common.ui_util")
    path = UIUtil.GetItemBigIcon(itemID)
  end
  local ConfigTab = {}
  RightPopSystem.CommonPopup(ConfigTab, Title, content, path, jumpInfo)
end
function BottomRightTipsSystem.OnModePostSwitch(preState, nextState)
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  log(bWriteLog and "[v_wllwu]BottomRightTipsSystem.OnModeSwitched, nextState = " .. tostring(nextState))
  if nextState == GameStatus.Lobby then
    if LogicNewbie.IsNewbie() and LogicNewbie.NeedShowNewbieGuide(10008) then
      log(bWriteLog and "BottomRightTipsSystem.OnModeSwitched newbie stage")
      return
    end
    BottomRightTipsSystem.CheckTipData()
  end
end
function BottomRightTipsSystem.CheckTipData()
  if BottomRightTipsSystem.tipData == nil then
    return
  end
  log(bWriteLog and "[gpb] BottomRightTipsSystem, CheckTipData" .. tostring(#BottomRightTipsSystem.tipData))
  if #BottomRightTipsSystem.tipData <= 0 then
    return
  end
  local data = BottomRightTipsSystem.tipData[1]
  if data then
    BottomRightTipsSystem.ProcessData(data.item_id, data.title, data.content, data.jump_info)
    table.remove(BottomRightTipsSystem.tipData, 1)
  end
end
function BottomRightTipsSystem.HandleItemData(itemID, Title, content, jumpInfo)
  log(bWriteLog and "[gpb] BottomRightTipsSystem, HandleItemData")
  if GameStatus.IsInLobbyOrMainCity() and not UIManager.IsUIShow(UIManager.UI_Config.Common_RightBottom_Tip_UIBP) then
    BottomRightTipsSystem.ProcessData(itemID, Title, content, jumpInfo)
  else
    BottomRightTipsSystem.AddItemData(itemID, Title, content, jumpInfo)
  end
end
function BottomRightTipsSystem.AddItemData(itemID, Title, content, jumpInfo)
  log(bWriteLog and "[gpb] BottomRightTipsSystem, AddItemData")
  local info = {}
  info.item_id = itemID
  info.title = Title
  info.  info.jump_info = jumpInfo
  table.insert(BottomRightTipsSystem.tipData, info)
end
return BottomRightTipsSystem