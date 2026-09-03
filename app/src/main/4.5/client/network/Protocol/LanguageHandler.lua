local NetManager = require("client.network.comm.NetManager")
local LanguageHandler = {}
function LanguageHandler.send_set_player_langs_req(id1, id2)
  NetManager.SendPkg(728609639, id1, id2)
end
function LanguageHandler.on_set_player_langs_rsp(err_code, data)
  local LanguageSelectSystem = require("client.logic.language_select.logic__language_select")
  LanguageSelectSystem.set_player_langs_rsp(err_code, data)
end
function LanguageHandler.send_set_player_match_langs_req(id1, id2, bOpenMatch, lang_timeout)
  local tb = {
    id1 = id1,
    id2 = id2,
    bOpenMatch = bOpenMatch,
      }
  log_tree(bWriteLog and "LanguageHandler.send_set_player_match_langs_req tb:", tb)
  NetManager.SendPkg(512934919, id1, id2, bOpenMatch, lang_timeout)
end
function LanguageHandler.on_set_player_match_langs_rsp(err_code, data)
  local tb = {err_code = err_code, data = data}
  log_tree(bWriteLog and "LanguageHandler.on_set_player_match_langs_rs tb:", tb)
  local LanguageSelectSystem = require("client.logic.language_select.logic__language_select")
  LanguageSelectSystem.set_player_match_langs_rsp(err_code, data)
end
function LanguageHandler.send_set_player_ugc_match_langs_req(only_match, lang_timeout)
  NetManager.SendPkg(1863627591, only_match, lang_timeout)
end
function LanguageHandler.on_set_player_ugc_match_langs_rsp(err_code, data)
  log(bWriteLog and "[v_yibxu]  LanguageHandler.on_set_player_ugc_match_langs_rsp err_code = " .. err_code)
  if err_code == 0 then
    local LanguageSelectSystem = require("client.logic.language_select.logic__language_select")
    LanguageSelectSystem.set_player_ugc_match_langs_rsp(data)
  end
end
function LanguageHandler.on_match_langs_change_notify(match_langs)
  log(bWriteLog and "LanguageHandler.on_match_langs_change_notify")
  local LanguageSelectSystem = require("client.logic.language_select.logic__language_select")
  LanguageSelectSystem.on_match_langs_change_notify(match_langs)
end
function LanguageHandler.send_query_match_langs_req()
  log(bWriteLog and "LanguageHandler.send_query_match_langs_req")
  NetManager.SendPkg(331463203)
end
function LanguageHandler.on_query_match_langs_rsp(match_langs, bIsLeader)
  log(bWriteLog and "LanguageHandler.on_match_langs_change_notify")
  local LanguageSelectSystem = require("client.logic.language_select.logic__language_select")
  LanguageSelectSystem.on_query_match_langs_rsp(match_langs, bIsLeader)
end
return LanguageHandler