local NetManager = require("client.network.comm.NetManager")
local ShowBrandHandler = {ct = 0}
function ShowBrandHandler.send_save_common_brand_req(template_id, settings)
  printf("ShowBrandHandler.send_save_common_brand_req template_id:%s, settings:%s", template_id, settings)
  NetManager.SendPkg(1145380047, template_id, settings)
end
function ShowBrandHandler.on_save_common_brand_rsp(err)
  printf("ShowBrandHandler.on_save_common_brand_rsp err:%s", err)
  if err ~= 0 then
    ShowNotice(err)
    return true
  end
end
function ShowBrandHandler.send_query_common_brand_req(uid, template_id)
  printf("ShowBrandHandler.send_query_common_brand_req uid:%s, template_id:%s", uid, template_id)
  if ShowBrandHandler.bLocalTest then
    local time_ticker = require("common.time_ticker")
    time_ticker.AddTimerOnce(0, function()
      ShowBrandHandler.ct = ShowBrandHandler.ct + 1
      local template_id = ShowBrandHandler.ct % 2 + 1
      if template_id == 1 then
        ShowBrandHandler.on_query_common_brand_rsp(0, uid, template_id, {
          [1] = {
            id = 13,
            val = 0,
            data_val = 99
          },
          [2] = {
            id = 14,
            val = 0,
            data_val = 2
          },
          [3] = {
            id = 5,
            val = 0,
            data_val = 4
          },
          [4] = {
            id = 6,
            val = 0,
            data_val = 5
          }
        })
      else
        ShowBrandHandler.on_query_common_brand_rsp(0, uid, template_id, {
          [1] = {id = 17, val = "asdasd"}
        })
      end
    end)
  else
    NetManager.SendPkg(1059049799, uid, template_id)
  end
end
function ShowBrandHandler.on_query_common_brand_rsp(err, uid, template_id, settings)
  printf("ShowBrandHandler.on_query_common_brand_rsp err:%s, uid:%s, template_id:%s, #settings:%s", err, uid, template_id, settings and #settings or 0)
  if err ~= 0 then
    ShowNotice(err)
    return true
  end
  for _, v in pairs(settings) do
    if type(v) == "table" and v.data_val == nil and type(v.data_source) == "number" and v.data_source >= 3301 and v.data_source <= 3312 then
      v.data_val = 0
    end
  end
  local LogicShowBrand = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicShowBrand)
  LogicShowBrand:SaveBrandInfo(uid, template_id, settings)
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_SHOWBRAND_QUERY_RESP, uid, template_id, settings)
end
function ShowBrandHandler.send_set_active_brand_req(template_id)
  printf("ShowBrandHandler.send_set_active_brand_req template_id:%s", template_id)
  local LogicShowBrand = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicShowBrand)
  LogicShowBrand:SetActiveBrand(template_id)
  NetManager.SendPkg(1500198759, template_id)
end
function ShowBrandHandler.on_set_active_brand_rsp(err, template_id)
  printf("ShowBrandHandler.on_set_active_brand_rsp err:%s, template_id:%s", err, template_id)
  if err ~= 0 then
    ShowNotice(err)
    return true
  end
end
function ShowBrandHandler.send_query_player_partner_info_req(uid)
  NetManager.SendPkg(293481587, uid)
end
function ShowBrandHandler.on_query_player_partner_info_rsp(err_code, uid1, uid2)
  log(bWriteLog and string.format("ShowBrandHandler.on_query_player_partner_info_rsp %s %s %s", tostring(err_code), tostring(uid1), tostring(uid2)))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return true
  end
  local LogicShowBrand = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicShowBrand)
  LogicShowBrand:on_query_player_partner_info_rsp(uid1, uid2)
end
local reqRsp = {
  send_save_common_brand_req = "on_save_common_brand_rsp",
  send_query_common_brand_req = "on_query_common_brand_rsp",
  send_set_active_brand_req = "on_set_active_brand_rsp",
  send_query_player_partner_info_req = "on_query_player_partner_info_rsp"
}
local ProtoPromiseHookTool = require("client.network.comm.ProtoPromiseHookTool")
ProtoPromiseHookTool.HookPair(reqRsp, ShowBrandHandler)
return ShowBrandHandler