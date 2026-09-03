local PufferErrorHandler = {lastShowTipsTime = 0}
function PufferErrorHandler.ShowErrorTips(errorCode)
  if errorCode == 0 then
    return
  end
  local noticeStr
  if errorCode == 269615110 or errorCode == 269615111 or errorCode == 269549569 or errorCode == 269615507 or errorCode == 269615156 or errorCode == 269615160 or errorCode == 269615520 or errorCode == 269615508 or errorCode == 269550069 then
    noticeStr = LocUtil.GetLocalizeResStr(7433) .. " " .. tostring(errorCode) .. ""
    ShowNotice(noticeStr)
  elseif errorCode == 269811740 or errorCode == 203423772 or errorCode == 271581189 then
    ShowNotice(7432)
    local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
    PufferManager.PauseAllDownloadTasks()
  elseif errorCode == PufferDownloader.ERR_PAK_CORRUPTED then
    ShowNotice(7427)
  elseif errorCode == 1 then
    if Client.IsDevelopment() then
      local TimeUtil = require("client.common.time_util")
      local now = TimeUtil.GetServerTimeInSec()
      if now - PufferErrorHandler.lastShowTipsTime > 5 then
        ShowDevNotice("###\232\181\132\230\186\144\230\156\141\229\138\161\229\153\168\228\184\138\230\156\170\230\137\190\229\136\176\232\175\165\232\181\132\230\186\144\239\188\140\232\175\183\228\189\191\231\148\168GM\229\145\189\228\187\164\226\128\156\228\184\139\232\189\189\232\135\170\229\138\168\230\163\128\230\159\165\226\128\157\239\188\140\232\190\147\229\135\186\232\175\166\231\187\134\233\148\153\232\175\175\228\191\161\230\129\175")
        PufferErrorHandler.lastShowTipsTime = now
      end
    end
  else
    noticeStr = LocUtil.GetLocalizeResStr(7434) .. " " .. tostring(errorCode) .. ""
    ShowNotice(noticeStr)
  end
end
return PufferErrorHandler