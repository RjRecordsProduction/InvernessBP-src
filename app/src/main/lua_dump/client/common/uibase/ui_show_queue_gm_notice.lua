local ui_show_queue_config = require("client.common.uibase.ui_show_queue_config")
local TimeUtil = require("client.common.time_util")
local EShowLobbyType = ui_show_queue_config.EShowLobbyType
local EPlayerReturnType = ui_show_queue_config.EPlayerReturnType
local EPlayerType = ui_show_queue_config.EPlayerType
local ECantAddReason = ui_show_queue_config.ECantAddReason
local EUIBigType = ui_show_queue_config.EUIBigType
local EUISmallType = ui_show_queue_config.EUISmallType
local ui_show_queue_gm_notice = {
  showNotice = false,
  interceptedUIKeyList = {}
}
local EGMLobbyName = {
  [EShowLobbyType.Lobby_2D] = "2D\229\164\167\229\142\133",
  [EShowLobbyType.MainCity] = "\228\184\187\229\159\142",
  [EShowLobbyType.XMission] = "\229\156\176\233\147\129\229\164\167\229\142\133",
  [EShowLobbyType.WOW] = "WOW\229\164\167\229\142\133",
  [EShowLobbyType.SocialIsland] = "\232\129\154\228\185\144\229\155\173",
  [EShowLobbyType.Home] = "\229\174\182\229\155\173",
  [EShowLobbyType.Fighting] = "\229\177\128\229\134\133\231\142\169\230\179\149",
  [EShowLobbyType.UGCMineMain] = "UGC-\230\136\145\231\154\132\228\184\187\233\161\181",
  [EShowLobbyType.Supply] = "\232\161\165\231\187\153",
  [EShowLobbyType.CollectionHall] = "\231\143\141\232\151\143\229\177\149\233\166\134",
  [EShowLobbyType.Lobby_2D_Mid_Page] = "2D\229\164\167\229\142\133\228\184\173\229\164\174\233\161\181"
}
ui_show_queue_gm_notice.local EReturnTypeStr = {
  [EPlayerReturnType.None] = "\230\151\160\233\153\144\229\136\182",
  [EPlayerReturnType.LoginTotalCountLimit] = "\229\155\158\230\181\129\229\137\141n\230\172\161\231\153\187\229\189\149\233\153\144\229\136\182",
  [EPlayerReturnType.FirstDayLimit] = "\229\155\158\230\181\129\233\166\150\230\151\165\233\153\144\229\136\182",
  [EPlayerReturnType.FirstDayTotalCountLimit] = "\229\155\158\230\181\129\233\166\150\230\151\165\229\137\141n\230\172\161\231\153\187\229\189\149\233\153\144\229\136\182",
  [EPlayerReturnType.FirstDayOrLoginTotalCountLimit] = "\229\155\158\230\181\129\233\166\150\230\151\165\230\136\150\231\153\187\229\189\149\229\137\141n\230\172\161\233\153\144\229\136\182"
}
local EPlayerTypeStr = {
  [EPlayerType.Main] = "\229\164\167\231\155\152\231\148\168\230\136\183\233\133\141\231\189\174",
  [EPlayerType.ShortReturn] = "\231\159\173\229\155\158\230\181\129\231\148\168\230\136\183\233\133\141\231\189\174",
  [EPlayerType.NewBie] = "\230\150\176\230\137\139\231\148\168\230\136\183\233\133\141\231\189\174",
  [EPlayerType.AtRisk] = "\233\162\132\230\181\129\229\164\177\231\148\168\230\136\183\233\133\141\231\189\174",
  [EPlayerType.LongReturn] = "\233\149\191\229\155\158\230\181\129\231\148\168\230\136\183\233\133\141\231\189\174"
}
local EBigTypeStr = {
  [EUIBigType.Slap] = "\230\139\141\232\132\184\231\149\140\233\157\162",
  [EUIBigType.Guide] = "\229\188\149\229\175\188\231\149\140\233\157\162",
  [EUIBigType.Normal] = "\230\153\174\233\128\154\231\149\140\233\157\162",
  [EUIBigType.Popup] = "\229\188\185\231\170\151\231\149\140\233\157\162"
}
ui_show_queue_gm_notice.local ESmallTypeStr = {
  [EUISmallType.Normal] = "\230\153\174\233\128\154\231\149\140\233\157\162",
  [EUISmallType.Slap] = "\230\139\141\232\132\184\231\149\140\233\157\162",
  [EUISmallType.Guide] = "\229\188\149\229\175\188\231\149\140\233\157\162",
  [EUISmallType.Popup_Middle] = "\228\184\173\229\164\174\229\176\143\229\188\185\231\170\151",
  [EUISmallType.Popup_RightBottom] = "\229\143\179\228\184\139/\228\184\138\232\167\146\229\188\185\231\170\151",
  [EUISmallType.Popup_Top] = "\233\161\182\233\131\168Tips"
}
ui_show_queue_gm_notice.local ECantAddReasonFormat = {
  [ECantAddReason.ReturnFirstDayLimit] = "<GM_UI_Show_Queue_Text>\229\142\159\229\155\160\239\188\154\229\155\158\230\181\129\233\166\150\230\151\165\233\153\144\229\136\182</>",
  [ECantAddReason.ReturnLoginTotalCountLimit] = "<GM_UI_Show_Queue_Text>\229\142\159\229\155\160\239\188\154\229\155\158\230\181\129\229\137\141 %s \230\172\161\231\153\187\229\189\149\233\153\144\229\136\182\227\128\130</>\n" .. "<GM_UI_Show_Queue_Text>\229\155\158\230\181\129\229\144\142\230\128\187\229\133\177\229\183\178\231\153\187\229\189\149\230\172\161\230\149\176\239\188\154</><GM_UI_Show_Queue_Red>%s</>",
  [ECantAddReason.ReturnFirstDayTotalCountLimit] = "<GM_UI_Show_Queue_Text>\229\142\159\229\155\160\239\188\154\229\155\158\230\181\129\233\166\150\230\151\165\229\137\141 %s \230\172\161\231\153\187\229\189\149\233\153\144\229\136\182\227\128\130</>\n" .. "<GM_UI_Show_Queue_Text>\229\155\158\230\181\129\233\166\150\230\151\165\229\183\178\231\153\187\229\189\149\230\172\161\230\149\176\239\188\154</><GM_UI_Show_Queue_Red>%s</>",
  [ECantAddReason.ReturnFirstDayOrLoginTotalCountLimit] = "<GM_UI_Show_Queue_Text>\229\142\159\229\155\160\239\188\154\229\155\158\230\181\129\233\166\150\230\151\165\230\136\150\229\137\141 %s \230\172\161\231\153\187\229\189\149\233\153\144\229\136\182\227\128\130</>\n" .. "<GM_UI_Show_Queue_Text>\230\152\175\229\144\166\229\155\158\230\181\129\233\166\150\230\151\165\239\188\154</>%s \n" .. "<GM_UI_Show_Queue_Text>\229\155\158\230\181\129\229\144\142\230\128\187\229\133\177\229\183\178\231\153\187\229\189\149\230\172\161\230\149\176\239\188\154</>%s",
  [ECantAddReason.ShowCountLimit] = "<GM_UI_Show_Queue_Text>\229\142\159\229\155\160\239\188\154\229\183\178\232\190\190\228\187\138\230\151\165\229\177\149\231\164\186\230\172\161\230\149\176\228\184\138\233\153\144\227\128\130</>\n" .. "<GM_UI_Show_Queue_Text>\232\167\146\232\137\178\230\179\168\229\134\140\230\151\182\233\151\180: %s, \230\179\168\229\134\140\230\151\182\233\151\180\232\140\131\229\155\180: %s</>\n" .. "<GM_UI_Show_Queue_Text>\228\187\138\230\151\165\229\183\178\229\177\149\231\164\186\230\172\161\230\149\176: </>%s \n" .. "<GM_UI_Show_Queue_Text>\228\187\138\230\151\165\229\177\149\231\164\186\230\172\161\230\149\176\228\184\138\233\153\144: </>%s"
}
ui_show_queue_gm_notice.
function ui_show_queue_gm_notice.SetShowNotice(showNotice)
  ui_show_queue_gm_notice.end
function ui_show_queue_gm_notice.ShowGMNotice(lqcUIConfig, returnData, success)
  if not success then
    ui_show_queue_gm_notice.AddCantAddMsgToList(lqcUIConfig, returnData)
  end
  if not ui_show_queue_gm_notice.showNotice then
    return
  end
  local keyName = lqcUIConfig.KeyName
  local param = lqcUIConfig.Param
  local ID = returnData and returnData.uiPlayerTypeConfigID or 0
  local playerType = tonumber(LobbySystem.roleData.popui_type)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  if returnData then
    local returnParamStr
    local TimeUtil = require("client.common.time_util")
    if returnData.returnType == 1 then
      returnParamStr = "\n \229\155\158\230\181\129\229\144\142\231\153\187\229\189\149\230\172\161\230\149\176\239\188\154" .. tostring(returnData.returnLoginCount)
    else
      returnParamStr = "\n \230\136\170\230\173\162\229\155\158\230\181\129\231\172\172 " .. tostring(returnData.returnParam) .. " \229\164\169\239\188\136" .. TimeUtil.FormatTime_YMDHMS(returnData.returnLimitEndTime) .. "\239\188\137\231\153\187\229\189\149\230\172\161\230\149\176\239\188\154" .. tostring(returnData.returnLoginCount)
    end
    local rejoin_start_time = DataMgr.roleData.back_user_data and DataMgr.roleData.back_user_data.rejoin_start_time or 0
    local sTitle = "\231\149\140\233\157\162\230\143\146\229\133\165\233\152\159\229\136\151" .. (success and "\230\136\144\229\138\159\239\188\129" or "\229\164\177\232\180\165\239\188\140\230\151\160\230\179\149\230\137\147\229\188\128\233\161\181\233\157\162")
    local sMsg = "\229\143\151\227\128\138\229\164\167\229\142\133\229\188\185\231\170\151\233\152\159\229\136\151\230\142\167\229\136\182\232\161\168_New\227\128\139:\231\142\169\229\174\182\231\177\187\229\158\139\233\133\141\231\189\174 \230\142\167\229\136\182\239\188\129" .. "\n \229\189\147\229\137\141\231\142\169\229\174\182\231\177\187\229\158\139\239\188\154" .. playerType .. "\239\188\136" .. tostring(EPlayerTypeStr[playerType]) .. "\239\188\137" .. "\n UI\231\149\140\233\157\162\229\144\141\231\167\176\239\188\154" .. tostring(keyName) .. "\n \231\149\140\233\157\162Key\239\188\154" .. tostring(ID) .. "\n \229\143\130\230\149\176\239\188\154" .. tostring(param) .. "\n \229\189\147\229\137\141\232\167\146\232\137\178\231\154\132\230\179\168\229\134\140\230\151\182\233\151\180\239\188\154" .. math.floor(returnData.registerDay) .. "\n \231\149\140\233\157\162\230\151\182\233\151\180\232\140\131\229\155\180\239\188\154" .. tostring(returnData.startTime) .. " ~ " .. tostring(returnData.endTime) .. "\n \229\183\178\229\177\149\231\164\186\230\172\161\230\149\176\239\188\154" .. tostring(returnData.currentCount) .. "\n \233\153\144\229\136\182\229\177\149\231\164\186\230\172\161\230\149\176\239\188\154" .. tostring(returnData.limitCount) .. "\n \231\149\140\233\157\162\229\155\158\230\181\129\231\177\187\229\158\139\239\188\154" .. tostring(returnData.returnType) .. "\239\188\136" .. tostring(EReturnTypeStr[returnData.returnType]) .. "\239\188\137" .. "\n \231\149\140\233\157\162\229\155\158\230\181\129\229\143\130\230\149\176\239\188\154" .. tostring(returnData.returnParam) .. "\n \230\152\175\229\144\166\229\155\158\230\181\129\233\166\150\230\151\165\239\188\154" .. tostring(returnData.returnFirstDay) .. "\n \229\155\158\230\181\129\230\151\182\233\151\180\239\188\154" .. TimeUtil.FormatTime_YMDHMS(rejoin_start_time) .. returnParamStr
    CommonMsgBoxMgr.Show(CommonMsgBoxMgr.SHOW_TYPE_ONE, sTitle, sMsg)
    return
  end
  local sTitle = "\231\149\140\233\157\162\230\143\146\229\133\165\233\152\159\229\136\151\230\136\144\229\138\159"
  local sMsg = "\228\184\141\229\143\151\227\128\138\229\164\167\229\142\133\229\188\185\231\170\151\233\152\159\229\136\151\230\142\167\229\136\182\232\161\168_New\227\128\139:\231\142\169\229\174\182\231\177\187\229\158\139\233\133\141\231\189\174 \230\142\167\229\136\182" .. "\n UI\231\149\140\233\157\162\229\144\141\231\167\176\239\188\154" .. tostring(keyName)
  CommonMsgBoxMgr.Show(CommonMsgBoxMgr.SHOW_TYPE_ONE, sTitle, sMsg)
end
function ui_show_queue_gm_notice.AddCantAddMsgToList(lqcUIConfig, returnData)
  local keyName = lqcUIConfig.KeyName
  local ID = returnData and returnData.uiPlayerTypeConfigID or 0
  local reason = returnData and returnData.cantAddReason or ""
  local reasonFormat = ui_show_queue_gm_notice.ECantAddReasonFormat[reason]
  local reasonStr = ""
  if reason == ECantAddReason.ReturnLoginTotalCountLimit then
    reasonStr = string.format(reasonFormat, returnData.returnParam, returnData.returnLoginCount)
  elseif reason == ECantAddReason.ReturnFirstDayTotalCountLimit then
    reasonStr = string.format(reasonFormat, returnData.returnParam, returnData.returnLoginCount)
  elseif reason == ECantAddReason.ReturnFirstDayOrLoginTotalCountLimit then
    local returnFirstDay = returnData.returnFirstDay or false
    local returnLoginCount = returnData.returnLoginCount or 0
    local returnParam = returnData.returnParam or 0
    local returnFirstDayStr = "<GM_UI_Show_Queue_Text>" .. tostring(returnFirstDay) .. "</>"
    if returnFirstDay then
      returnFirstDayStr = "<GM_UI_Show_Queue_Red>" .. tostring(returnFirstDay) .. "</>"
    end
    local returnLoginCountStr = "<GM_UI_Show_Queue_Text>" .. returnLoginCount .. "</>"
    if returnLoginCount <= returnParam then
      returnLoginCountStr = "<GM_UI_Show_Queue_Red>" .. returnLoginCount .. "</>"
    end
    reasonStr = string.format(reasonFormat, returnParam, returnFirstDayStr, returnLoginCountStr)
  elseif reason == ECantAddReason.ShowCountLimit then
    local currentCount = returnData.currentCount or 0
    local limitCount = returnData.limitCount or 0
    local currentCountStr = "<GM_UI_Show_Queue_Text>" .. currentCount .. "</>"
    if currentCount >= limitCount then
      currentCountStr = "<GM_UI_Show_Queue_Red>" .. currentCount .. "</>"
    end
    local limitCountStr = "<GM_UI_Show_Queue_Text>" .. limitCount .. "</>"
    if limitCount == 0 then
      limitCountStr = "<GM_UI_Show_Queue_Red>" .. limitCount .. "</>"
    end
    reasonStr = string.format(reasonFormat, math.floor(returnData.registerDay), tostring(returnData.startTime) .. " ~ " .. tostring(returnData.endTime), currentCountStr, limitCountStr)
  end
  local item = {
    UIKey = ID,
    KeyName = keyName,
    Reason = reasonStr,
    AddTime = TimeUtil.FormatTime_YMDHMS(TimeUtil.GetServerTimeInSec())
  }
  table.insert(ui_show_queue_gm_notice.interceptedUIKeyList, 1, item)
end
function ui_show_queue_gm_notice.GetList()
  return ui_show_queue_gm_notice.interceptedUIKeyList
end
function ui_show_queue_gm_notice.Clear()
  ui_show_queue_gm_notice.interceptedUIKeyList = {}
end
return ui_show_queue_gm_notice