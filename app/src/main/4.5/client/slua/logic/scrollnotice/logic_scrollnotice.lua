local ScrollNoticeSystem = {rankNoticeQueue = nil, rankNoticeQueueIndex = 1}
function ScrollNoticeSystem.OnLogin(bReLogin)
  if not bReLogin then
    local xqueue = require("client.common.uibase.xqueue")
    ScrollNoticeSystem.rankNoticeQueue = xqueue.Create(100)
  end
end
return ScrollNoticeSystem