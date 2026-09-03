local logic_mail_utils = {}
local PlayerStatusUtil = require("client.slua.logic.player_status.PlayerStatusUtil")
function logic_mail_utils.IsBlackFriendMail(mailInfo)
  local MailMacro = require("client.slua.logic.mail.mail_macro")
  local mailType = mailInfo.opt.type
  if mailType ~= MailMacro.Enum_Mail_Type.Friend then
    return
  end
  local senderUid = mailInfo.opt.sender_uid
  local logic_friend_blacklist = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_blacklist)
  return logic_friend_blacklist:IsBlacklist(senderUid)
end
function logic_mail_utils.IsNeedRemoveMail(mailInfo)
  if not mailInfo.item_instids then
    return
  end
  local WardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
  for _, insID in pairs(mailInfo.item_instids) do
    local data = WardrobeData:GetHallDepotItemDataByInsID(insID)
    if data and data.resID and DataMgr.IsValidTime(data.expireTS) then
      return false
    end
  end
  return true
end
function logic_mail_utils.GetValidItemsList(mailInfo)
  if not mailInfo.item_instids then
    return
  end
  local validItems = {}
  local WardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
  for _, insID in pairs(mailInfo.item_instids) do
    local data = WardrobeData:GetHallDepotItemDataByInsID(insID)
    if data and data.resID and DataMgr.IsValidTime(data.expireTS) then
      table.insert(validItems, {
        attachId = data.resID,
        attachCount = data.count,
        attachValidTime = data.validHours,
        hasInDepot = true
      })
    end
  end
  return validItems
end
local _IsMailTop = function(mailInfo)
  local TableUtil = require("common.table_util")
  local topFlag = TableUtil.GetTableValue(mailInfo, "opt", "top")
  if not topFlag then
    return false
  end
  local MailMacro = require("client.slua.logic.mail.mail_macro")
  local mailType = TableUtil.GetTableValue(mailInfo, "opt", "type")
  local mailSubType = TableUtil.GetTableValue(mailInfo, "opt", "subtype")
  if mailType == MailMacro.Enum_Mail_Type.Security and mailSubType == MailMacro.Enum_Security_SubTabType.Report and mailInfo.read then
    return false
  end
  return true
end
local addTimeTop = 300000000
local addTimeAttach = 200000000
local addTimeNotRead = 100000000
function logic_mail_utils.GetMailSortIndex(mailInfo)
  local defaultIndex = mailInfo.time
  local priority = logic_mail_utils.GetMailSortPriority(mailInfo)
  local sortIndex = defaultIndex + priority
  return sortIndex
end
function logic_mail_utils.GetMailSortPriority(mailInfo)
  if _IsMailTop(mailInfo) then
    return addTimeTop
  end
  if not logic_mail_utils.IsHaveRead(mailInfo) then
    if logic_mail_utils.IsWithAttach(mailInfo) then
      return addTimeAttach
    else
      return addTimeNotRead
    end
  end
  return 0
end
local _GetItemSortByItemId = function(itemId, dyn_attr_list)
  if not (itemId and dyn_attr_list) or not dyn_attr_list[itemId] then
    return 0
  end
  return dyn_attr_list[itemId].gift_id or 0
end
local GetMailAttachList = function(mailInfo)
  local attach = mailInfo.attachments
  if not attach or not attach.items then
    return
  end
  local list = {}
  for id, num in pairs(attach.items) do
    local m = {
      attachId = id,
      attachCount = num,
      attachValidTime = 0
    }
    if type(mailInfo.opt.dyn_attr_list) == "table" then
      local dyn = mailInfo.opt.dyn_attr_list[id]
      if dyn and type(dyn) ~= "number" then
        if type(dyn.valid_hours) == "number" then
          local h = math.floor(dyn.valid_hours)
          if 0 < h then
            m.attachValidTime = h
          end
        end
        m.attachColor = dyn.color or 0
        m.attachPattern = dyn.pattern or 0
        m.expire_ts = dyn.expire_ts
        if dyn.expire_ts and dyn.expire_ts ~= 0 then
          m.expire_ts = dyn.expire_ts
        elseif dyn.extra_str and dyn.extra_str ~= "" then
          local ActivityUtil = require("client.slua.logic.activity.ActivityUtil")
          m.expire_ts = ActivityUtil.GetReviseExpireTime(dyn.extra_str, id)
        end
      end
    end
    table.insert(list, m)
  end
  if mailInfo.opt.cfg_id and mailInfo.opt.cfg_id == 10556 and 0 < #list then
    local dynAttrList = mailInfo.opt.dyn_attr_list
    table.sort(list, function(a, b)
      local aItemSort = _GetItemSortByItemId(a.attachId, dynAttrList)
      local bItemSort = _GetItemSortByItemId(b.attachId, dynAttrList)
      return aItemSort < bItemSort
    end)
  end
  return list
end
function logic_mail_utils.AddExtraValue(mailInfo)
  local attachList = GetMailAttachList(mailInfo)
  if attachList and 0 < #attachList then
    mailInfo.    if mailInfo.attachments and mailInfo.attachments.fetched then
      mailInfo.read = true
    end
  end
  mailInfo.sortIndex = logic_mail_utils.GetMailSortIndex(mailInfo)
  return mailInfo
end
function logic_mail_utils.IsWithAttach(mailInfo)
  if mailInfo and mailInfo.attachList and #mailInfo.attachList > 0 then
    return true
  end
  return false
end
function logic_mail_utils.hasUnRecvAttach(mailInfo)
  if not logic_mail_utils.IsWithAttach(mailInfo) then
    return false
  end
  if mailInfo.attachments and mailInfo.attachments.fetched then
    return false
  end
  return true
end
function logic_mail_utils.IsFriendMail(mailInfo)
  if not mailInfo then
    return
  end
  local MailMacro = require("client.slua.logic.mail.mail_macro")
  local mailType = mailInfo.opt.type
  if mailType == MailMacro.Enum_Mail_Type.Friend then
    return true
  end
  return false
end
function logic_mail_utils.IsPresentedCoin(mailInfo)
  if not mailInfo then
    return
  end
  local MailMacro = require("client.slua.logic.mail.mail_macro")
  local mailType = mailInfo.opt.type
  local mailSubType = mailInfo.opt.subtype
  if mailType ~= MailMacro.Enum_Mail_Type.Friend then
    return
  end
  for _, subType in ipairs(MailMacro.FriendMailRebateSubTypeList) do
    if mailSubType == subType then
      return true
    end
  end
  return false
end
function logic_mail_utils.IsCanPresentCoin(mailInfo)
  if not logic_mail_utils.IsPresentedCoin(mailInfo) then
    return
  end
  local senderUid = mailInfo.opt.sender_uid
  local logic_friend_gift = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_gift)
  if logic_friend_gift:CanSendCoin(senderUid) then
    return true
  end
  return false
end
function logic_mail_utils.isOldFriendGift(mailInfo)
  if not mailInfo then
    return false
  end
  local MailMacro = require("client.slua.logic.mail.mail_macro")
  local mailType = mailInfo.opt.type
  local mailSubType = mailInfo.opt.subtype
  if mailType ~= MailMacro.Enum_Mail_Type.Friend then
    return false
  end
  if mailSubType ~= MailMacro.Enum_Mail_SubType.OldFriendGift then
    return false
  end
  return true
end
local itemId = 1109
function logic_mail_utils.isMailRelation(mailInfo)
  if not logic_mail_utils.IsPresentedCoin(mailInfo) then
    return
  end
  if mailInfo.attachments and mailInfo.attachments.items and mailInfo.attachments.items[itemId] then
    return true
  end
  return false
end
function logic_mail_utils.IsHaveRead(mailInfo)
  return mailInfo.read
end
function logic_mail_utils.GetPlayerTeamState(uid)
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  local status = PlayerStatusMgr:GetStatusData(uid)
  if PlayerStatusUtil.ISLANDIdle(status) or PlayerStatusUtil.WoWIdle(status) then
    return 0
  elseif PlayerStatusUtil.ISLANDInTeam(status) or PlayerStatusUtil.WoWInTeam(status) then
    return 1
  end
  return status.teamState
end
function logic_mail_utils.GetMailTitle(mailInfo)
  local strTitle = mailInfo.opt.title_id and LocUtil.LocalizeResFormat(mailInfo.opt.title_id) or mailInfo.title or ""
  if mailInfo.opt ~= nil and mailInfo.opt.from_idip ~= nil then
    local StringUtil = require("common.string_util")
    strTitle = StringUtil.DecodeURI(strTitle)
  end
  return strTitle
end
local AddMailUrlParam = function(url1)
  local urlStart = string.find(url1, "url=", 0)
  if urlStart == nil then
    return url1
  end
  urlStart = urlStart + 5
  local urlTempIndex = string.find(url1, "\"", urlStart)
  if not urlTempIndex then
    return url1
  end
  local urlEnd = urlTempIndex - 1
  local url2 = string.sub(url1, urlStart, urlEnd)
  local webModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.webModule)
  url2 = webModule:AddParameterByPersonalInfo(url2)
  return string.sub(url1, 0, urlStart - 1) .. url2 .. string.sub(url1, urlEnd + 1, #url1)
end
local FormatStrByStr = function(strFormat, ...)
  local paramNum = select("#", ...)
  if paramNum <= 0 then
    return strFormat
  end
  local res = strFormat
  local IsNewStyle = string.find(strFormat, "{0}")
  if IsNewStyle then
    local IntlHelper = import("IntlHelper")
    local arg = table.pack(...)
    res = IntlHelper.FormatLocalizeStrByStr(strFormat, arg)
  else
    local formatNum = 0
    for _ in string.gmatch(strFormat, "%%s") do
      formatNum = formatNum + 1
    end
    if paramNum >= formatNum then
      res = string.format(strFormat, ...)
    end
  end
  return res
end
function logic_mail_utils.LocalizeResFormatIndexSubOne(id, ...)
  if id == nil then
    log_error("LocalizeRes format is empty id=nil")
    return ""
  end
  local strFormat = LocUtil.GetLocalizeResStr(id)
  if strFormat == "" then
    log_error("LocalizeRes format is empty id=" .. id)
  end
  local isContainID = string.find(strFormat, "{#")
  if isContainID then
    return LocUtil.LocalizeFormatConcatenation(id, ...)
  end
  local IsBeginByOne = string.find(strFormat, "{1}") and not string.find(strFormat, "{0}")
  if IsBeginByOne then
    strFormat = "{0}" .. strFormat
    return FormatStrByStr(strFormat, "", ...)
  end
  return FormatStrByStr(strFormat, ...)
end
function logic_mail_utils.PreProcessMailParams(mailInfo)
  local TableUtil = require("common.table_util")
  local newParams = TableUtil.CopyTable(mailInfo.params)
  if mailInfo.opt.cfg_id == 10832 then
    local timeStr = newParams[2]
    local device = newParams[3]
    local channel = newParams[4]
    local region = newParams[5]
    if type(timeStr) == "number" then
      local TimeUtil = require("client.common.time_util")
      timeStr = TimeUtil.FormatTime_YMDHMS(timeStr, false)
    end
    local logic_lbs_select_region = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_lbs_select_region)
    local regionStr = logic_lbs_select_region:GetRegionText(region)
    local SettingSystem = require("client.logic.setting.logic_setting")
    local channelStr = SettingSystem.GetNameByImsdkChannel(channel)
    newParams[2] = timeStr
    newParams[3] = device
    newParams[4] = channelStr
    newParams[5] = regionStr
  elseif mailInfo.opt.cfg_id == 10884 then
    newParams = newParams or {}
    local TimeUtil = require("client.common.time_util")
    newParams[1] = TimeUtil.FormatTime_YMD(mailInfo.time - 94608000, false)
  elseif mailInfo.opt.jump_param_index and mailInfo.opt.jump_param_index > 0 then
    newParams[mailInfo.opt.jump_param_index] = nil
  end
  for i = #newParams, 1, -1 do
    if newParams[i] == " " then
      newParams[i] = ""
    else
      break
    end
  end
  return newParams
end
function logic_mail_utils.GetMailContent(mailInfo)
  local strContent
  if mailInfo.opt.content_id and mailInfo.params then
    local params = logic_mail_utils.PreProcessMailParams(mailInfo)
    strContent = logic_mail_utils.LocalizeResFormatIndexSubOne(mailInfo.opt.content_id, table.unpack(params))
    strContent = string.gsub(strContent, "{%d+}", "")
  else
    strContent = mailInfo.content
  end
  if not strContent or strContent == "" then
    log(bWriteLog and "[v_wllwu] logic_mail_utils.GetMailContent content is nil ")
    return ""
  end
  if mailInfo.opt ~= nil and mailInfo.opt.from_idip ~= nil then
    local StringUtil = require("common.string_util")
    strContent = StringUtil.DecodeURI(strContent)
  end
  strContent = AddMailUrlParam(strContent)
  local MailMacro = require("client.slua.logic.mail.mail_macro")
  if mailInfo.opt.type == MailMacro.Enum_Mail_Type.MsgCenter and mailInfo.opt.subtype == MailMacro.Enum_Mail_SubType.FriendAgreeApply and mailInfo.opt.source then
    local id = tonumber("199" .. tostring(mailInfo.opt.source))
    local strSource = LocUtil.LocalizeResFormat(id)
    strContent = LocUtil.LocalizeResFormat(35136, strSource)
  end
  if mailInfo and mailInfo.opt and mailInfo.opt.cfg_id and mailInfo.opt.cfg_id == 10606 then
    local NewDayTaskSystem = require("client.slua.logic.task.logic_new_day_task")
    local tips1 = NewDayTaskSystem.GetDailyTaskDesc(mailInfo.params[1])
    local tips2 = mailInfo.params[2]
    strContent = logic_mail_utils.LocalizeResFormatIndexSubOne(mailInfo.opt.content_id, tips1, tips2)
  end
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  if mailInfo and mailInfo.opt and mailInfo.opt.cfg_id and mailInfo.opt.cfg_id == 10619 then
    local FriendProfile = logic_profile:GetLocalProfile(mailInfo.params[1])
    if FriendProfile then
      local tips1 = FriendProfile.nickName
      local UIUtil = require("client.common.ui_util")
      local tips2 = UIUtil.GetIntimacyRelationName(mailInfo.params[2])
      strContent = logic_mail_utils.LocalizeResFormatIndexSubOne(mailInfo.opt.content_id, tips1, tips2, mailInfo.params[3])
    end
  end
  if mailInfo and mailInfo.opt and mailInfo.opt.cfg_id and mailInfo.opt.cfg_id >= 10741 and mailInfo.opt.cfg_id <= 10743 then
    local FriendProfile = logic_profile:GetLocalProfile(mailInfo.params[2])
    if FriendProfile then
      local tips1 = FriendProfile.nickName
      local UIUtil = require("client.common.ui_util")
      local tips2 = UIUtil.GetIntimacyRelationName(mailInfo.params[1])
      strContent = logic_mail_utils.LocalizeResFormatIndexSubOne(mailInfo.opt.content_id, tips2, tips1, mailInfo.params[3], mailInfo.params[4])
    end
  end
  if mailInfo and mailInfo.opt and mailInfo.opt.cfg_id and mailInfo.opt.cfg_id == 10966 then
    local SocialCardSystem = require("client.slua.logic.lobby.Left.logic_social_card")
    local myProfileSocialCard = SocialCardSystem.SocialCard
    if myProfileSocialCard and myProfileSocialCard.birthday and type(myProfileSocialCard.birthday) == "string" then
      local _, month, day = myProfileSocialCard.birthday:match("(%d+)-(%d+)-(%d+)")
      month = string.format("%02d", month)
      day = string.format("%02d", day)
      strContent = logic_mail_utils.LocalizeResFormatIndexSubOne(mailInfo.opt.content_id, month, day)
    end
  end
  if mailInfo and mailInfo.opt and mailInfo.opt.cfg_id and mailInfo.opt.cfg_id == 11166 then
    local TimeUtil = require("client.common.time_util")
    local timeStr = TimeUtil.FormatTime_YMD(mailInfo.params[1], true, false)
    strContent = logic_mail_utils.LocalizeResFormatIndexSubOne(mailInfo.opt.content_id, timeStr)
  end
  if mailInfo and mailInfo.opt and mailInfo.opt.cfg_id and (mailInfo.opt.cfg_id == 11024 or mailInfo.opt.cfg_id == 11110 or mailInfo.opt == 11405) and mailInfo.params then
    local mapname = mailInfo.params[1]
    local mod_id = mailInfo.opt.mod_id
    if mapname and mod_id then
      local linkStr = "<a id=\"MailHyLink\" style=\"MailLink\" url=\"game://?module=300001&mod_rel_id=" .. tostring(mod_id) .. "\">" .. mapname .. "</>"
      strContent = string.gsub(strContent, mapname, linkStr)
    end
  end
  if mailInfo and mailInfo.opt and mailInfo.opt.cfg_id and mailInfo.opt.cfg_id == 11175 then
    strContent = string.gsub(strContent, ", X", " X")
    strContent = string.gsub(strContent, ", , ", "")
    strContent = string.gsub(strContent, ", %.", ".")
    strContent = string.gsub(strContent, "%s+ ", "")
  end
  return strContent
end
function logic_mail_utils.IsReportMailBySubType(subType)
  local MailMacro = require("client.slua.logic.mail.mail_macro")
  if subType == MailMacro.Enum_Security_SubTabType.Report or subType == MailMacro.Enum_Security_SubTabType.ReportButNoLink then
    return true
  end
  return false
end
function logic_mail_utils.GetSecureMailSubType(subType)
  local MailMacro = require("client.slua.logic.mail.mail_macro")
  if subType == MailMacro.Enum_Security_SubTabType.ReportButNoLink then
    return MailMacro.Enum_Security_SubTabType.Report
  end
  return subType
end
function logic_mail_utils.GetMailExtraData(showAttachIData, opt)
  local extraData = {}
  local ActivityUtil = require("client.slua.logic.activity.ActivityUtil")
  ActivityUtil.CombineExpireTs(showAttachIData.expire_ts, extraData)
  local allAffixs = {}
  if opt.dyn_attr_list and opt.dyn_attr_list[showAttachIData.attachId] then
    local affixs = opt.dyn_attr_list[showAttachIData.attachId].affixs
    local pve_affixs = opt.dyn_attr_list[showAttachIData.attachId].pve_affixs
    for affixId, order in pairs(affixs or {}) do
      allAffixs[affixId] = order
    end
    for affixId, order in pairs(pve_affixs or {}) do
      allAffixs[affixId] = order
    end
    extraData.affixs = allAffixs
  end
  return extraData
end
function logic_mail_utils.JumpByMailInfo(mailInfo)
  if not mailInfo then
    return
  end
  if mailInfo.opt.is_soft_link then
    log(bWriteLog and "logic_mail_utils.JumpByMailInfo is_soft_link = " .. tostring(mailInfo.opt.is_soft_link))
    if mailInfo.opt.is_soft_link == 1 then
      local language = Client.GetCurrentLanguage()
      local StringUtil = require("common.string_util")
      local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
      local loginType = login_module.nLoginType
      local country = login_module:GetIpRegion()
      local IntlHelper = import("IntlHelper")
      local timezone = IntlHelper.GetLocalTimezone()
      local strUserName = StringUtil.EncodeURI(DataMgr.roleData.nickName)
      local WebviewSDK = require("client.slua.logic.url.logic_webview_sdk")
      WebviewSDK:OpenURL(FuncUtil.GetDomainByID(3366177) .. "/user_guide/index.html?" .. FuncUtil.GetKeywordByID(3377009) .. "Id=" .. Client.GetITopGameId() .. "&language=" .. language .. "&country=" .. country .. "&loginType=" .. loginType .. "&roleName=" .. strUserName .. "&timeZone=" .. timezone, true)
      return
    end
    if mailInfo.opt.is_soft_link == 2 then
      local logic_security = require("client.slua.logic.security.logic_security")
      logic_security.JumpAppealURL()
      local BasicDataTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataTLogReport)
      BasicDataTLogReport:ReportImmediate(TLogEventDefine.Safe_Mail_Click_Go, mailInfo.opt.is_soft_link)
      return
    end
  end
  local jumpLink = mailInfo.opt.jumplink
  if jumpLink and jumpLink ~= "" then
    log(bWriteLog and "[chub]MailDetailUI:OnClickJump(), jumpLink = " .. jumpLink .. " self.Info.my_id = " .. tostring(mailInfo.my_id))
    local util = require("client.slua_ui_framework.util")
    if util.IsOnlineImageUrl(jumpLink) then
      local webModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.webModule)
      jumpLink = webModule:AddParameterByPersonalInfo(jumpLink)
    end
    GlobalData.JumpUrl(jumpLink)
    logic_mail_utils.IsInheritInvited(mailInfo)
  else
    local mailSubType = mailInfo.opt.subtype
    local logic_ugc_comment = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_comment)
    local MailMacro = require("client.slua.logic.mail.mail_macro")
    if mailSubType == MailMacro.Enum_Security_SubTabType.Report then
      local jump_utils = require("client.logic.store.jump_utils")
      local jumpurlData = CDataTable.GetTableData("Entrance2JumpUrl", 1)
      local jumpUrl = jumpurlData.JumpUrl
      local defaultReportUrl = "game://?module=1000092&appPage=index&page=report&from=3"
      local jumpIdx = mailInfo.opt.jump_param_index
      if jumpIdx and 0 < jumpIdx and mailInfo.params and mailInfo.params[jumpIdx] then
        local paramUrl = mailInfo.params[jumpIdx]
        local report_id = string.match(paramUrl, "report_id=([^&]+)")
        if report_id and string.match(report_id, "^%d+$") then
          GlobalData.JumpUrl(paramUrl)
        else
          GlobalData.JumpUrl(defaultReportUrl)
        end
      elseif jump_utils.IsGameJumpUrl(jumpUrl) then
        local StringUtil = require("common.string_util")
        local params = StringUtil.ParseURLParams(jumpUrl)
        local moduleId = tonumber(params.module)
        log(bWriteLog and "MailDetailUI:OnClickJump(), jump 2 BP_ENUM_MODULE_HOSTED_SAFETY_CENTER")
        jump_utils.OpenJumpModule(moduleId, params)
      else
        local jump_from = require("client.logic.store.jump_from")
        log(bWriteLog and "MailDetailUI:OnClickJump(), jump - BP_ENUM_MODULE_HOSTED_SAFETY_CENTER only from")
        jump_utils.OpenJumpModule(BP_ENUM_MODULE_HOSTED_SAFETY_CENTER, {
          from = jump_from.SDK_SafetyCenter_from.Mail
        })
      end
    elseif mailSubType == MailMacro.Enum_Security_SubTabType.Punish then
      log(bWriteLog and "[chub]MailDetailUI:OnClickJump(), subtype == MailMacro.Enum_Security_SubTabType.Punish")
      local defaultReportUrl = "game://?module=1000092&appPage=index&page=report&from=3"
      local jumpIdx = mailInfo.opt.jump_param_index
      if jumpIdx and 0 < jumpIdx and mailInfo.params and mailInfo.params[jumpIdx] then
        local paramUrl = mailInfo.params[jumpIdx]
        local report_id = string.match(paramUrl, "report_id=([^&]+)")
        if report_id and string.match(report_id, "^%d+$") then
          GlobalData.JumpUrl(paramUrl)
        else
          GlobalData.JumpUrl(defaultReportUrl)
        end
      else
        UIManager.ShowUI(UIManager.UI_Config.ReputationSystem_Popup02_UIBP, true)
      end
    elseif mailSubType == 16 then
      local PufferConst = require("client.slua.logic.download.puffer_const")
      local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
      local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
      if PublishRegionMacros.IsFITVersion() and PufferManager.ShowDownloadTips(PufferConst.ENUM_DownloadType.ODPACK, {
        PufferConst.EODPackID.SocialLobby
      }) then
        return
      end
      local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
      tlog_report_utils.ReportTLogEvent(TLogEventDefine.PersonPopularityMailJumpSendGift)
      local SocialPersonSpaceSystem = require("client.slua.logic.lobby.Left.logic_social_person_space")
      SocialPersonSpaceSystem.EnterPersonSpace(mailInfo.opt.uid, true)
      local RoleInfoPopularitySystem = require("client.slua.logic.person_space.logic_roleinfo_popularity")
      RoleInfoPopularitySystem.enter(mailInfo.opt.uid)
      UIManager.ShowUI(UIManager.UI_Config.roleinfo_send_gift, RoleInfoPopularitySystem.GiftSourceType.MailSend, nil, nil, mailInfo.opt.uid)
    elseif logic_ugc_comment:CheckIsUGCCommentMail(mailInfo) then
      local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
      if LogicTxMissionMain.IsInXMission() then
        log(bWriteLog and "logic_mail_utils.JumpByMailInfo IsInXMission true")
        ShowNotice(49290)
      else
        local modId = logic_ugc_comment:GetUGCCommentMailModId(mailInfo)
        local Logic_UGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
        Logic_UGC:OpenDetailUIByModId(modId)
      end
    end
  end
end
function logic_mail_utils.GetFriendMailAttachCount(mailInfo, itemInfo)
  if mailInfo.attachments and mailInfo.attachments.is_dropid then
    local cfg = CDataTable.GetTableData("FriendMailAttachNumConfig", itemInfo.attachId)
    if cfg and cfg.ItemNum > 0 then
      return cfg.ItemNum
    end
  end
  return itemInfo.attachCount
end
function logic_mail_utils.IsInheritMail(mailInfo)
  local opt = mailInfo and mailInfo.opt
  local collect_inherit_data = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_inherit_data)
  if opt.cfg_id == collect_inherit_data.mailType then
    if mailInfo.bGetHidden then
      return
    end
    opt.jumplink = "game://?module=1002300&index=16"
    opt.pic_type = 2
    opt.jedi_challenge = true
    opt.expire_hours = collect_inherit_data.mailDays * 24
    collect_inherit_data:AddInheritInvited(mailInfo.opt.uid, mailInfo)
  end
end
function logic_mail_utils.IsInheritInvited(mailInfo)
  local opt = mailInfo and mailInfo.opt
  local collect_inherit_data = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_inherit_data)
  if opt.cfg_id == collect_inherit_data.mailType and opt.uid then
    collect_inherit_data:ShowInheritPupupOrInvitedPage(mailInfo.opt.uid, mailInfo)
    return true
  end
  return false
end
return logic_mail_utils