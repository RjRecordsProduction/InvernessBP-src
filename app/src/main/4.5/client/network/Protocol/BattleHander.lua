local NetManager = require("client.network.comm.NetManager")
local BattleHander = {}
function BattleHander.on_voice_ban_notify(uid, reason, endtime)
  local ClientBanLogic = require("GameLua.Mod.BaseMod.Client.Ban.ClientBanLogic")
  ClientBanLogic.OnRealTimeVoiceBanNotify(uid, reason, endtime)
end
function BattleHander.on_voice_ban_success(uid, name, ban_time)
  local ClientBanLogic = require("GameLua.Mod.BaseMod.Client.Ban.ClientBanLogic")
  ClientBanLogic.OnVoiceBanSuccess(uid, name, ban_time)
end
function BattleHander.on_sync_mic_suspicious(suspicious_flag)
  print(bWriteLog and "BattleHander.on_sync_mic_suspicious" .. tostring(suspicious_flag))
  local ClientBanLogic = require("GameLua.Mod.BaseMod.Client.Ban.ClientBanLogic")
  ClientBanLogic.OnSyncMicSuspicious(suspicious_flag)
end
function BattleHander.on_sync_mic_pre_filter(ban_id)
  print(bWriteLog and "BattleHander.on_sync_mic_pre_filter" .. tostring(ban_id))
  local ClientBanLogic = require("GameLua.Mod.BaseMod.Client.Ban.ClientBanLogic")
  ClientBanLogic.OnSyncMicPreFilter(ban_id)
end
function BattleHander.send_suspicious_flag_req()
  NetManager.SendPkg(1892132977)
end
function BattleHander.send_get_ban_id_req(ban_id)
  NetManager.SendPkg(446448067, ban_id)
end
function BattleHander.on_ban_info_notify(ban_id, is_banned, end_time)
  printf("BattleHander.on_ban_info_notify ban_id: %s, is_banned: %s, end_time: %s", ban_id, is_banned, end_time)
  local ClientBanLogic = require("GameLua.Mod.BaseMod.Client.Ban.ClientBanLogic")
  ClientBanLogic.OnSyncBanInfo(ban_id, is_banned)
  EventSystem:postEvent(EVENTTYPE_MINI_TV, EVENTID_MINI_BAN_FLAG_UPDATE, ban_id, is_banned, end_time)
end
function BattleHander.on_notify_tips_to_client(text_id, is_off_mic)
  print(bWriteLog and "BattleHander.on_notify_tips_to_client ", text_id, is_off_mic)
  local ClientBanLogic = require("GameLua.Mod.BaseMod.Client.Ban.ClientBanLogic")
  ClientBanLogic.OnNotifyWarningTips(text_id, is_off_mic)
end
function BattleHander.send_popularity_showcase_lottery_req()
  print(bWriteLog and "BattleHander.send_popularity_showcase_lottery_req")
  NetManager.SendPkg(448674447)
end
function BattleHander.on_popularity_showcase_lottery_rsp(err_code, itemlist, postison)
  print(bWriteLog and "BattleHander.on_popularity_showcase_lottery_rsp")
  EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_POPULARITY_SHOWCASE_LOTTERY_RSP, err_code, itemlist, postison)
end
return BattleHander