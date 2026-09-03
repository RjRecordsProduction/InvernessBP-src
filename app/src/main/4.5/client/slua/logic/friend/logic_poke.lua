local logic_poke = {}
function logic_poke:DefineAndResetData()
  self.GetAllPokeCD = 120
  self.GetAllNoFriPokeCD = 120
  self.GetAllPokeStamp = 0
  self.GetAllNoFriPokeStamp = 0
  self.poke_frd_list = {}
  self.bepoke_frd_list = {}
  self.poke_no_frd_list = {}
  self.bepoke_no_frd_list = {}
  self.poke_poke_count = 0
  self.poke_bepoke_count = 0
  self.poke_update_time = 0
  self.bepoke_update_time = 0
  self.pokeUid = 0
  self.AlreadyProcessed = {}
  self.PokeType = {
    None = 1,
    FriendPokeSelf = 2,
    FriendBackPokeself = 3
  }
  self.limitTime = 1.5
  self.lastTime = 0
  self.ChatLookPoke = {}
end
function logic_poke:OnInitialize()
end
function logic_poke:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_NEXTDAY, EVENTID_NEXTDAY_ZERO, self.OnNextDayZeroCome, self)
end
function logic_poke:OnLogin(bReLogin)
end
function logic_poke:OnLogOut()
end
function logic_poke:OnPreSwitchGameStatus(preState, nextState)
end
function logic_poke:OnPostSwitchGameStatus(preState, nextState)
end
function logic_poke:OnNextDayZeroCome()
  self.poke_frd_list = {}
  self.bepoke_frd_list = {}
  self.poke_no_frd_list = {}
  self.bepoke_no_frd_list = {}
end
function logic_poke:IsPokeSelf(uid)
  if not self.bepoke_frd_list or not next(self.bepoke_frd_list) then
    return false
  end
  if self.bepoke_frd_list[uid] then
    return self.bepoke_frd_list[uid]
  else
    return false
  end
end
function logic_poke:IsPokeFriend(uid)
  if not self.poke_frd_list or not next(self.poke_frd_list) then
    return false
  end
  if self.poke_frd_list[uid] then
    return self.poke_frd_list[uid]
  else
    return false
  end
end
function logic_poke:FriendPokeStatus(uid)
  local type
  if not self.bepoke_frd_list or not next(self.bepoke_frd_list) then
    self.bepoke_frd_list = {}
  end
  if not self.poke_frd_list or not next(self.poke_frd_list) then
    self.poke_frd_list = {}
  end
  if self.bepoke_frd_list[uid] and not self.poke_frd_list[uid] then
    return self.PokeType.FriendPokeSelf
  elseif self.bepoke_frd_list[uid] and self.poke_frd_list[uid] and self.poke_frd_list[uid] < self.bepoke_frd_list[uid] then
    return self.PokeType.FriendBackPokeself
  else
    return self.PokeType.None
  end
end
function logic_poke:NoFriendPokeStatus(uid)
  local type
  if not self.bepoke_frd_list or not next(self.bepoke_frd_list) then
    self.bepoke_frd_list = {}
  end
  if not self.poke_frd_list or not next(self.poke_frd_list) then
    self.poke_frd_list = {}
  end
  if self.bepoke_frd_list[uid] and not self.poke_frd_list[uid] then
    return self.PokeType.FriendPokeSelf
  elseif self.bepoke_frd_list[uid] and self.poke_frd_list[uid] and self.poke_frd_list[uid] < self.bepoke_frd_list[uid] then
    return self.PokeType.FriendBackPokeself
  else
    return self.PokeType.None
  end
end
function logic_poke:ChatAddPoke(uid, pokeSelf)
  for k, v in pairs(self.AlreadyProcessed) do
    if v.id == uid and v.pokeSelf == pokeSelf then
      return nil
    end
  end
  local data = {id = uid, pokeSelf = pokeSelf}
  table.insert(self.AlreadyProcessed, data)
  log(bWriteLog and "[v_yunjxing] logic_poke:ChatAddPoke " .. tostring(uid) .. "pokeSelf" .. tostring(pokeSelf))
  log_tree("[v_yunjxing] logic_poke:ChatAddPoke ", self.AlreadyProcessed)
  return true
end
function logic_poke:PokeChatBox(uid)
  log(bWriteLog and "[v_yunjxing] logic_poke:PokeChatBox " .. tostring(uid))
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.PokeChatBox) or {}
  local TimeUtil = require("client.common.time_util")
  if saveData and saveData[uid] and TimeUtil.IsToday(saveData[uid].showTime) then
    return false
  else
    return true
  end
end
function logic_poke:ChatClosePokeBox()
  log(bWriteLog and "[v_yunjxing] logic_poke:ChatClosePokeBox ")
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.PokeChatBox) or {}
  local TimeUtil = require("client.common.time_util")
  local nowTime = TimeUtil.GetServerTimeInSec()
  if not self.ChatLookPoke or not next(self.ChatLookPoke) then
    log(bWriteLog and "[v_yunjxing] logic_poke:ChatClosePokeBox not ChatClosePokeBox")
    return
  end
  for uid, _ in pairs(self.ChatLookPoke) do
    if (not saveData[uid] or not TimeUtil.IsToday(saveData[uid].showTime)) and self:FriendPokeStatus(uid) ~= self.PokeType.None then
      saveData[uid] = {showTime = nowTime}
    end
  end
  PlayerPrefsSystem.SaveTableToFile_N(saveData, PlayerPrefsSystem.ePlayerPrefsType.PokeChatBox)
  self.ChatLookPoke = {}
end
function logic_poke:HasShowPokeBox(uid)
  self.ChatLookPoke[uid] = true
end
function logic_poke:LimitTiming()
  local TimeUtil = require("client.common.time_util")
  local nowTime = TimeUtil.GetServerTimeInSec()
  if nowTime - self.lastTime > self.limitTime then
    self.lastTime = nowTime
    log(bWriteLog and "logic_poke:LimitTiming true:")
    return true
  else
    log(bWriteLog and "logic_poke:LimitTiming false:")
    return false
  end
end
function logic_poke:send_poke_friend_req(fri_uid)
  if self:LimitTiming() then
    local ChatHandler = require("client.network.Protocol.ChatHandler")
    log(bWriteLog and "logic_poke:send_poke_friend_req")
    ChatHandler.send_poke_friend_req(tonumber(fri_uid))
  else
    ShowNotice(34735)
  end
end
function logic_poke:on_poke_friend_rsp(err, fri_uid, is_recent_frd)
  log(bWriteLog and "logic_poke:on_poke_friend_rsp")
  if err == 13070011 then
    log(bWriteLog and "logic_poke:on_poke_friend_rsp 1")
    ShowNotice(LocUtil.LocalizeResFormat(73606))
  elseif err == 13070012 then
    log(bWriteLog and "logic_poke:on_poke_friend_rsp 2")
    ShowNotice(LocUtil.LocalizeResFormat(73569))
  elseif err == 13070013 then
    log(bWriteLog and "logic_poke:on_poke_friend_rsp 3")
    ShowNotice(LocUtil.LocalizeResFormat(73570))
  elseif err == 13070014 then
    log(bWriteLog and "logic_poke:on_poke_friend_rsp 5")
    ShowNotice(LocUtil.LocalizeResFormat(700008))
  elseif err == 13070102 then
    log(bWriteLog and "logic_poke:on_poke_friend_rsp 4")
    ShowNotice(LocUtil.LocalizeResFormat(73569))
  elseif err == 13070015 then
    log(bWriteLog and "logic_poke:on_poke_friend_rsp 5")
    ShowNotice(LocUtil.LocalizeResFormat(84369))
  elseif err == 0 then
    if not UIManager.IsUIShow(UIManager.UI_Config.Chat_ScintillaTip_UIBP) then
      ShowNotice(LocUtil.LocalizeResFormat(73568))
    end
    self:send_daily_poke_list_req(true)
    self:send_no_fri_poke_list_req(true)
    log(bWriteLog and "logic_poke:send_daily_poke_list_req")
    local logic_chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
    if self:ChatAddPoke(fri_uid, true) and not is_recent_frd then
      logic_chat_main.AddPokeMsg(fri_uid, true)
    end
    self.pokeUid = fri_uid
  else
    log(bWriteLog and "logic_poke:on_poke_friend_rsp 5")
    ShowNotice(err)
  end
end
function logic_poke:send_daily_poke_list_req(bForce)
  local TimeUtil = require("client.common.time_util")
  if not bForce and TimeUtil.GetServerTimeInSec() - self.GetAllPokeStamp < self.GetAllPokeCD then
    log(bWriteLog and "logic_poke:send_daily_poke_list_req CD")
    return
  end
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  log(bWriteLog and "logic_poke:send_daily_poke_list_req")
  ChatHandler.send_daily_poke_list_req()
end
function logic_poke:on_daily_poke_list_rsp(poke_frd_list, bepoke_frd_list)
  log(bWriteLog and "logic_poke.on_daily_poke_list_rsp")
  if poke_frd_list and poke_frd_list.frd_uids then
    self.poke_frd_list = poke_frd_list.frd_uids
    self.poke_poke_count = poke_frd_list.count
    self.poke_update_time = poke_frd_list.update_time
  else
    self.poke_frd_list = {}
    self.poke_poke_count = 0
    self.poke_update_time = 0
  end
  if bepoke_frd_list and bepoke_frd_list.list then
    self.bepoke_frd_list = bepoke_frd_list.list
    self.poke_bepoke_count = bepoke_frd_list.count
    self.bepoke_update_time = bepoke_frd_list.update_time
  else
    self.bepoke_frd_list = {}
    self.poke_bepoke_count = 0
    self.bepoke_update_time = 0
  end
  if self.pokeUid ~= 0 then
    EventSystem:postEvent(EVENTTYPE_CHAT, EVENTID_CHAT_POKE_RSP, self.pokeUid)
  end
end
function logic_poke:send_no_fri_poke_list_req(bForce)
  local TimeUtil = require("client.common.time_util")
  if not bForce and TimeUtil.GetServerTimeInSec() - self.GetAllNoFriPokeStamp < self.GetAllNoFriPokeCD then
    log(bWriteLog and "logic_poke:send_no_fri_poke_list_req CD")
    return
  end
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  log(bWriteLog and "logic_poke:send_no_fri_poke_list_req")
  ChatHandler.send_no_fri_poke_list_req()
end
function logic_poke:on_no_fri_poke_list_rsp(poke_no_frd_list, bepoke_no_frd_list)
  log(bWriteLog and "logic_poke.on_daily_poke_list_rsp")
  if poke_no_frd_list then
    self.poke_no_frd_list = poke_no_frd_list.frd_uids
    self.poke_poke_count = poke_no_frd_list.count
    self.poke_update_time = poke_no_frd_list.update_time
  end
  if bepoke_no_frd_list then
    self.bepoke_no_frd_list = bepoke_no_frd_list.list
    self.poke_bepoke_count = bepoke_no_frd_list.count
    self.bepoke_update_time = bepoke_no_frd_list.update_time
  end
  if self.pokeUid ~= 0 then
    EventSystem:postEvent(EVENTTYPE_CHAT, EVENTID_CHAT_POKE_RSP, self.pokeUid)
  end
end
function logic_poke:on_frd_poke_notify(frd_uid, is_recent_frd)
  log(bWriteLog and "logic_poke:on_frd_poke_notify")
  self.pokeUid = frd_uid
  if not is_recent_frd then
    self:send_daily_poke_list_req(true)
    local logic_chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
    if self:ChatAddPoke(frd_uid, false) then
      logic_chat_main.AddPokeMsg(frd_uid, false)
    end
  else
    self:send_no_fri_poke_list_req(true)
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_poke = class(CModuleBase, nil, logic_poke)
return Clogic_poke