local NetManager = require("client.network.comm.NetManager")
local NetJumpHandler = {}
function NetJumpHandler.send_get_market_jump_info()
  NetManager.SendPkg(587134668)
end
function NetJumpHandler.on_get_market_jump_info_rsp(res)
  local time_util = require("client.common.time_util")
  local startTIme = time_util.GetMiliseconds()
  log(bWriteLog and "[SY]NetJumpHandler.on_get_market_jump_info_rsp.")
  local JumpUtils = require("client.logic.store.jump_utils")
  JumpUtils.OnRecvMarketJumpInfo(res)
  JumpUtils.OnRecvJumpMapInfo(JumpUtils.Enum_GetJump_Type.Market)
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_REFRESH_CURRENT_TAB)
  local ShopCouponSystem = require("client.slua.logic.coupon.logic_coupon_shop")
  ShopCouponSystem.CachedCouponID_Reflect_ItemID(res)
  local endtime = time_util.GetMiliseconds()
  log(bWriteLog and "[SY]NetJumpHandler.CostTime " .. endtime - startTIme)
  EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_JUMP_DATA_REFRESH)
end
function NetJumpHandler.send_get_shop_jump_info()
  NetManager.SendPkg(667811244)
end
function NetJumpHandler.on_get_shop_jump_info_rsp(res)
  local JumpUtils = require("client.logic.store.jump_utils")
  JumpUtils.OnRecvShopJumpInfo(res)
  JumpUtils.OnRecvJumpMapInfo(JumpUtils.Enum_GetJump_Type.Shop)
end
return NetJumpHandler