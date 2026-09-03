local NetManager = require("client.network.comm.NetManager")
local MVPMotionHander = {}
function MVPMotionHander.send_settl_motion_info_req()
  NetManager.SendPkg(86742451)
end
function MVPMotionHander.on_settl_motion_info_rsp(err, res_list)
  if err then
    log(bWriteLog and "on_settl_motion_info_rspres " .. tostring(err))
    if err == 0 and res_list then
      local Mvp_Motion_System = require("client.slua.logic.mvp_motion.logic_mvp_motion")
      Mvp_Motion_System:Set_Cur_Motion_ResID_List(res_list)
    end
  end
end
function MVPMotionHander.send_put_on_settl_motion_req(item_insid)
  NetManager.SendPkg(891304463, item_insid)
end
function MVPMotionHander.on_put_on_settl_motion_rsp(err, res_id)
  if err then
    log(bWriteLog and "MVPMotionHander err " .. tostring(err))
    if err == 0 then
      if res_id then
        local Mvp_Motion_System = require("client.slua.logic.mvp_motion.logic_mvp_motion")
        local oldInsID = Mvp_Motion_System:Set_Cur_Motion_ResID(res_id)
        EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_MVPMOTION_DATA, res_id, oldInsID)
        if Mvp_Motion_System._Delay_Net_Go then
          local rs = coroutine.resume(Mvp_Motion_System._Delay_Net_Go)
          if not rs then
            log_error("on_put_on_settl_motion_rsp")
          end
        end
      end
    else
      ShowNotice(err)
    end
  end
end
return MVPMotionHander