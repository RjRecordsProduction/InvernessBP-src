local newbie_download_module = {}
function newbie_download_module:OnInitialize()
  newbie_download_module.__super.OnInitialize(self)
  self.bNewbieGuideGame = false
end
function newbie_download_module:OnLogin(bReLogin)
end
function newbie_download_module:OnLogOut()
  self.bNewbieGuideGame = false
end
function newbie_download_module:OnPostSwitchGameStatus(preState, nextState)
  log(bWriteLog and string.format("[Jaguar newbie download] newbie_download_module:OnPostSwitchGameStatus preState[%s] nextState[%s]", preState, nextState))
  local bIsJaguar = Client.IsJaguar()
  if bIsJaguar then
    if nextState == GameStatus.Fighting and not GameStatus.IsInLobbyOrMainCity() then
      self:JaguarNewbieDownload()
    else
      self.bNewbieGuideGame = false
      if preState == GameStatus.Fighting then
        PufferDownloader.SetBattleDownloadSwitch(false)
      end
    end
  end
end
function newbie_download_module:SetNewbieGuideGameFlag(bFlag)
  self.bNewbieGuideGame = bFlag
end
function newbie_download_module:JaguarNewbieDownload()
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  local bNewbieFirstGame = false
  if LogicNewbie.newbieTotalGameCnt == 1 then
    bNewbieFirstGame = true
  end
  local bNewbieGuideGame = self.bNewbieGuideGame
  if not bNewbieFirstGame and not bNewbieGuideGame then
    log(bWriteLog and string.format("[Jaguar newbie download] JaguarNewbieDownload newbieTotalGameCnt[%s] bNewbieGuideGame[%s]", tostring(LogicNewbie.newbieTotalGameCnt), tostring(self.bNewbieGuideGame)))
    return
  end
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local downloadType = PufferConst.ENUM_DownloadType.ODPACK
  local bMain = false
  local keyList = {
    PufferConst.EODPackID.ModeSelect,
    PufferConst.EODPackID.MainIcon
  }
  local bOther = false
  local keyList_other = {
    PufferConst.EODPackID.ModeSelect,
    PufferConst.EODPackID.OtherIcon
  }
  local state = PufferManager.GetState(downloadType, keyList)
  if state ~= PufferConst.ENUM_DownloadState.Done then
    bMain = true
  end
  local state_other = PufferManager.GetState(downloadType, keyList_other)
  if state_other ~= PufferConst.ENUM_DownloadState.Done then
    bOther = true
  end
  if not bMain and not bOther then
    log(bWriteLog and string.format("[Jaguar newbie download] JaguarNewbieDownload bMain[%s] bOther[%s] ", tostring(bMain), tostring(bOther)))
    return
  end
  log(bWriteLog and string.format("[Jaguar newbie download] JaguarNewbieDownload state[%s] state_other[%s] ", tostring(state), tostring(state_other)))
  PufferDownloader.SetBattleDownloadSwitch(true)
  if bMain then
    PufferManager.Download(downloadType, keyList, nil, nil)
  end
  if bOther then
    local extraData = {bAutoDownload = true}
    PufferManager.Download(downloadType, keyList_other, nil, nil, extraData)
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogicNewbieDownload = class(CModuleBase, nil, newbie_download_module)
return CLogicNewbieDownload