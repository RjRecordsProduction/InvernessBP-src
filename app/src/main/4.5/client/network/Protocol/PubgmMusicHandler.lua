local NetManager = require("client.network.comm.NetManager")
local PubgmMusicHandler = {}
local HandleErrorCode = function(res, isnot_show_tip)
  if res ~= 0 then
    if isnot_show_tip then
      return true
    end
    if res == 100330004 then
      local logic_pubgm_music = require("client.slua.logic.pubgm_music.logic_pubgm_music")
      logic_pubgm_music.SendMusicBoxRequest()
    end
    ShowNotice(res)
    return true
  end
  return false
end
function PubgmMusicHandler.send_music_box_check_open_req()
  NetManager.SendPkg(2035169831)
end
function PubgmMusicHandler.on_music_box_check_open_rsp(err, open_param)
  local logic_pubgm_music = require("client.slua.logic.pubgm_music.logic_pubgm_music")
  if err == 0 then
    logic_pubgm_music.OnMusicBoxCheckOpenRsp(true)
  else
    log_tree("[edward][PubgmMusicHandler] PubgmMusicHandler.on_music_box_check_open_rsp", open_param)
    logic_pubgm_music.OnMusicBoxCheckOpenRsp(false)
  end
end
function PubgmMusicHandler.send_music_box_data_req()
  NetManager.SendPkg(238603399)
end
function PubgmMusicHandler.on_music_box_data_rsp(err, data)
  if HandleErrorCode(err) then
    log(bWriteLog and "[muidarzhang] PubgmMusicHandler.on_music_box_data_rs, err:" .. tostring(err))
    return
  end
  local logic_pubgm_music_option = require("client.slua.logic.pubgm_music.logic_pubgm_music_option")
  logic_pubgm_music_option.OnMusicBoxDataRsp(data)
  local logic_pubgm_music = require("client.slua.logic.pubgm_music.logic_pubgm_music")
  logic_pubgm_music.OnMusicBoxDataRsp(data)
  if logic_pubgm_music._changeLobbyBGMTime then
    local TimeUtil = require("client.common.time_util")
    if TimeUtil.GetServerTimeInSec() - logic_pubgm_music._changeLobbyBGMTime <= 1 then
      log(bWriteLog and "logic_pubgm_music.OnMusicBoxDataRsp RestoreLobbyBGM")
      GlobalData.RestoreLobbyBGM()
    else
      log(bWriteLog and "logic_pubgm_music.OnMusicBoxDataRsp Time out")
    end
  end
end
function PubgmMusicHandler.send_music_box_receive_newbie_gift_req()
  NetManager.SendPkg(1353998007)
end
function PubgmMusicHandler.on_music_box_receive_newbie_gift_rsp(err, res_map)
  if HandleErrorCode(err) then
    log(bWriteLog and "[muidarzhang] PubgmMusicHandler.on_music_box_receive_newbie_gift_rsp, err" .. tostring(err))
    return
  end
  local logic_pubgm_music = require("client.slua.logic.pubgm_music.logic_pubgm_music")
  logic_pubgm_music.OnMusicBoxReceiveNewbieGiftRsp(res_map)
end
function PubgmMusicHandler.send_music_box_clear_expire_req()
  NetManager.SendPkg(2034104295)
end
function PubgmMusicHandler.on_music_box_clear_expire_rsp(err, data)
  if HandleErrorCode(err) then
    log(bWriteLog and "[muidarzhang] PubgmMusicHandler.on_music_box_clear_expire_rsp(err)" .. tostring(err))
    return
  end
  local logic_pubgm_music = require("client.slua.logic.pubgm_music.logic_pubgm_music")
  logic_pubgm_music.OnMusicBoxClearExpireRsp(data)
end
function PubgmMusicHandler.send_music_box_check_gift_req(to_uid, music_res_id)
  NetManager.SendPkg(1372929127, to_uid, music_res_id)
end
function PubgmMusicHandler.on_music_box_check_gift_rsp(err, to_uid, music_res_id)
  HandleErrorCode(err)
  local logic_pubgm_music = require("client.slua.logic.pubgm_music.logic_pubgm_music")
  logic_pubgm_music.OnMusicBoxCheckGiftRsp(err, to_uid, music_res_id)
end
function PubgmMusicHandler.send_music_box_send_gift_req(to_uid, music_res_id, gift_msg)
  NetManager.SendPkg(1845205519, to_uid, music_res_id, gift_msg)
end
function PubgmMusicHandler.on_music_box_send_gift_rsp(err, to_uid, music_res_id)
  if HandleErrorCode(err) then
    log(bWriteLog and "[muidarzhang] PubgmMusicHandler.on_music_box_send_gift_rsp(err) " .. tostring(err))
    return
  end
  local logic_pubgm_music = require("client.slua.logic.pubgm_music.logic_pubgm_music")
  logic_pubgm_music.OnMusicBoxSendGiftRsp(err, to_uid, music_res_id)
end
function PubgmMusicHandler.send_music_box_set_bgm_music_req(bgm_music, bgm_music_type, bgm_music_single)
  log_tree("[muidarzhang] PubgmMusicHandler.send_music_box_set_bgm_music_req, bgm_music: ", bgm_music)
  log(bWriteLog and "[muidarzhang] PubgmMusicHandler.send_music_box_set_bgm_music_req, bgm_music_type: " .. tostring(bgm_music_type))
  log(bWriteLog and "[muidarzhang] PubgmMusicHandler.send_music_box_set_bgm_music_req, bgm_music_single:" .. tostring(bgm_music_single))
  NetManager.SendPkg(1712509119, bgm_music, bgm_music_type, bgm_music_single)
end
function PubgmMusicHandler.on_music_box_set_bgm_music_rsp(err, bgm_music, bgm_music_type, bgm_music_single)
  log(bWriteLog and "[muidarzhang] PubgmMusicHandler.on_music_box_set_bgm_music_rsp")
  if HandleErrorCode(err) then
    log(bWriteLog and "[muidarzhang] PubgmMusicHandler.on_music_box_set_bgm_music_rsp(err)" .. tostring(err))
    return
  end
  log_tree("[muidarzhang] PubgmMusicHandler.on_music_box_set_bgm_music_rsp, bgm_music", bgm_music)
  log(bWriteLog and "[muidarzhang] PubgmMusicHandler.on_music_box_set_bgm_music_rsp, bgm_music_single" .. tostring(bgm_music_single))
  log(bWriteLog and "[muidarzhang]PubgmMusicHandler.on_music_box_set_bgm_music_rsp, bgm_music_type" .. tostring(bgm_music_type))
  local logic_pubgm_music_option = require("client.slua.logic.pubgm_music.logic_pubgm_music_option")
  logic_pubgm_music_option.OnMusicBoxSetBgmRsp()
  local logic_pubgm_music = require("client.slua.logic.pubgm_music.logic_pubgm_music")
  logic_pubgm_music.OnMusicBoxSetBgmRsp(bgm_music, bgm_music_type, bgm_music_single)
end
function PubgmMusicHandler.send_music_box_set_car_music_req(car_music)
  log_tree("[muidarzhang] PubgmMusicHandler.send_music_box_set_car_music_req, car_music: ", car_music)
  NetManager.SendPkg(1810927471, car_music)
end
function PubgmMusicHandler.on_music_box_set_car_music_rsp(err, car_music)
  if HandleErrorCode(err) then
    log(bWriteLog and "[muidarzhang]  PubgmMusicHandler.on_music_box_set_car_music_rsp(err)" .. tostring(err))
    return
  end
  local logic_pubgm_music_option = require("client.slua.logic.pubgm_music.logic_pubgm_music_option")
  logic_pubgm_music_option.OnCarMusicSetRsp()
  local logic_pubgm_music = require("client.slua.logic.pubgm_music.logic_pubgm_music")
  logic_pubgm_music.OnCarMusicSetRsp(car_music)
end
function PubgmMusicHandler.send_music_box_get_friend_bgm_music_req(fri_uid)
  NetManager.SendPkg(354479751, fri_uid)
end
function PubgmMusicHandler.on_music_box_get_friend_bgm_music_rsp(err, fri_uid, bgm_music, bgm_music_type, bgm_music_single)
  HandleErrorCode(err, true)
  local logic_pubgm_music = require("client.slua.logic.pubgm_music.logic_pubgm_music")
  logic_pubgm_music.OnMusicBoxGetFriendBgmRsp(fri_uid, bgm_music, bgm_music_type, bgm_music_single)
end
function PubgmMusicHandler.send_set_scene_music_req(scene_music)
  log_tree("[wzp] PubgmMusicHandler.send_set_scene_music_req, scene_music", scene_music or 0)
  local PHomeHandler = require("client.network.Protocol.PHomeHandler")
  PHomeHandler.send_manor_on_client_call_req("set_scene_music_req", scene_music)
end
function PubgmMusicHandler.on_set_scene_music_rsp(ret, binScene_music)
  log(bWriteLog and "[wzp] PubgmMusicHandler.on_set_scene_music_rsp(ret)" .. tostring(ret))
  if ret ~= 0 then
    return
  end
  local logic_pubgm_music_option = require("client.slua.logic.pubgm_music.logic_pubgm_music_option")
  logic_pubgm_music_option.OnHomePlayerMusicSetRsp()
  local logic_pubgm_music = require("client.slua.logic.pubgm_music.logic_pubgm_music")
  local scene_music = slua.LuaArchiverDecode(LuaStateWrapper, binScene_music)
  logic_pubgm_music.SetHomePlayerMusicListRsp(scene_music)
end
return PubgmMusicHandler