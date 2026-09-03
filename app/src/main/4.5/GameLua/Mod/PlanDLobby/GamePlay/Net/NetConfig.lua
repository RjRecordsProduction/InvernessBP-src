local NetConfig = {
  msgMap = {},
  reconnectMsgMap = {}
}
function NetConfig.Init()
  NetConfig.msgMap = {
    [566290851] = {
      req = "get_rank_info_req",
      res = "get_rank_info_rsp",
      handler = "PlanDRankHandler"
    }
  }
  NetConfig.reconnectMsgMap = {718633438}
end
return NetConfig