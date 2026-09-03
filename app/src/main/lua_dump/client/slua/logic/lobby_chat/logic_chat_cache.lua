local logic_chat_cache = {
  bOpen = false,
  cacheMsgList = {}
}
function logic_chat_cache.cache_chat_notify(chat_type, sender_name, msg_id, chat_content, sender_uid, nation)
  if not logic_chat_cache.bOpen then
    return
  end
  log(bWriteLog and "logic_chat_cache.cache_chat_notify")
  local msg = {
    msg_type = 1,
    chat_type = chat_type,
    sender_name = sender_name,
    msg_id = msg_id,
    chat_content = chat_content,
    sender_uid = sender_uid,
      }
  table.insert(logic_chat_cache.cacheMsgList, msg)
end
function logic_chat_cache.cache_chat_merge_notify(merge_world_chat, is_history)
  if not logic_chat_cache.bOpen then
    return
  end
  log(bWriteLog and "logic_chat_cache.cache_chat_merge_notify")
  local msg = {
    msg_type = 2,
    merge_world_chat = merge_world_chat,
      }
  table.insert(logic_chat_cache.cacheMsgList, msg)
end
function logic_chat_cache.cache_chat_rsp(res, msg_id, chat_type, surplus, receiver_gid, chat_content, ext_info, tabContent)
  if not logic_chat_cache.bOpen then
    return
  end
  log(bWriteLog and "logic_chat_cache.cache_chat_rsp")
  local msg = {
    msg_type = 3,
    res = res,
    msg_id = msg_id,
    chat_type = chat_type,
    surplus = surplus,
    receiver_gid = receiver_gid,
    chat_content = chat_content,
    ext_info = ext_info,
      }
  table.insert(logic_chat_cache.cacheMsgList, msg)
end
function logic_chat_cache.save_cache_msg_list_file()
  log(bWriteLog and "logic_chat_cache.save_cache_msg_list_file")
  if not logic_chat_cache.bOpen then
    return
  end
  local binStr = slua.LuaArchiverEncode(LuaStateWrapper, logic_chat_cache.cacheMsgList)
  logic_chat_cache.cacheMsgList = {}
  require("GameLua.Mod.PlanPH.Tools.PlanPH_BinFileHelper")
  local CreativeModeBlueprintLibrary = import("CreativeModeBlueprintLibrary")
  local saveDir = CreativeModeBlueprintLibrary.ProjectSavedDir()
  local last_file_name = "SaveGames/cache_msg_list_100.bin"
  for i = 1, 50 do
    local fileName = "SaveGames/cache_msg_list_" .. i .. ".bin"
    if not Client.IsFileExistByFileName(fileName) then
      last_file_name = saveDir .. fileName
      break
    end
  end
  log(bWriteLog and "logic_chat_cache.save_cache_msg_list_file last_file_name = " .. last_file_name)
  LuaBinFileHelper.SaveToFile(binStr, last_file_name)
end
function logic_chat_cache.load_cache_msg_list_file()
  log(bWriteLog and "logic_chat_cache.load_cache_msg_list_file")
  if not logic_chat_cache.bOpen then
    return
  end
  require("GameLua.Mod.PlanPH.Tools.PlanPH_BinFileHelper")
  local CreativeModeBlueprintLibrary = import("CreativeModeBlueprintLibrary")
  local saveDir = CreativeModeBlueprintLibrary.ProjectSavedDir()
  for i = 1, 50 do
    local fileName = "SaveGames/cache_msg_list_" .. i .. ".bin"
    if Client.IsFileExistByFileName(fileName) then
      log(bWriteLog and "logic_chat_cache.load_cache_msg_list_file i = " .. i)
      local binStr = LuaBinFileHelper.LoadToFile(saveDir .. fileName)
      local msg_list = slua.LuaArchiverDecode(LuaStateWrapper, binStr)
      for i, v in ipairs(msg_list) do
        table.insert(logic_chat_cache.cacheMsgList, v)
      end
    end
  end
  logic_chat_cache.pop_cache_msg_list_file()
end
function logic_chat_cache.pop_cache_msg_list_file()
  log(bWriteLog and "logic_chat_cache.pop_cache_msg_list_file")
  local msg_list = {}
  for i, v in ipairs(logic_chat_cache.cacheMsgList) do
    table.insert(msg_list, v)
  end
  logic_chat_cache.cacheMsgList = {}
  local cacheOpen = logic_chat_cache.bOpen
  logic_chat_cache.bOpen = false
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  for i, v in ipairs(msg_list) do
    if v.msg_type == 1 then
      ChatHandler.on_chat_notify(v.chat_type, v.sender_name, v.msg_id, v.chat_content, v.sender_uid, v.nation)
    elseif v.msg_type == 2 then
      ChatHandler.on_chat_merge_notify(v.merge_world_chat, v.is_history)
    elseif v.msg_type == 3 then
      local logic_chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
      logic_chat_main.msgContentCacheMap[v.msg_id] = v.tabContent
      ChatHandler.on_chat_rsp(v.res, v.msg_id, v.chat_type, v.surplus, v.receiver_gid, v.chat_content, v.ext_info)
    end
  end
  logic_chat_cache.bOpen = cacheOpen
end
return logic_chat_cache