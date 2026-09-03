BeginnerGuideSystem = BeginnerGuideSystem or {
  playerExperienceGrade = 0,
  finishedGuide = {}
}
function BeginnerGuideSystem.on_get_fresher_info_rsp(fresher_info)
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  TARRAY_PlayerFinishedGuideList = {}
  for k, v in pairs(fresher_info) do
    local data = {guideID = k, finishedCounts = v}
    table.insert(TARRAY_PlayerFinishedGuideList, data)
  end
  local player_level = DataMgr.roleData.level
  local player_fresher_type = LogicNewbie.newbieType
  log(bWriteLog and "get_fresher_info_rsp player_fresher_type" .. tostring(player_fresher_type))
  log(bWriteLog and "get_fresher_info_rsp LogicNewbie.newbieType" .. tostring(LogicNewbie.newbieType))
  IngameBeginnerGuide:on_retrive_finished_guide_finish(TARRAY_PlayerFinishedGuideList, player_level, player_fresher_type)
end
function BeginnerGuideSystem.send_refresher_info_req()
  log(bWriteLog and "get_fresher_info_rsp request player finished guide list--")
  local LoginHandler = require("client.network.Protocol.LoginHandler")
  LoginHandler.send_get_fresher_info_req()
end
function BeginnerGuideSystem.send_record_finished_guide_req(guide_id)
  log(bWriteLog and "get_fresher_info_rsp request record finished guide --")
  local LoginHandler = require("client.network.Protocol.LoginHandler")
  LoginHandler.send_set_fresher_info_req(guide_id)
end