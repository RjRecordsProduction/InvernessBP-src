local ugc_mail_reddot_data = {}
local RedDot
local bIsInited = false
local RedDotType = {
  Message = 1,
  System = 1,
  Secure = 2
}
local GenerateData = function()
  local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
  local Category = reddot_macro.Category
  local data = {
    newCount = 0,
    desc = reddot_macro.SystemName.UGCMail,
    types = {
      newCount = 0,
      [RedDotType.Message] = {
        newCount = 0,
        subID = RedDotType.Message,
        category = Category.Receive,
        pages = {
          newCount = 0,
          [RedDotType.System] = {
            newCount = 0,
            subID = RedDotType.System,
            category = Category.Receive,
            pages = {
              newCount = 0,
              category = Category.Receive,
              isDynamic = true
            }
          },
          [RedDotType.Secure] = {
            newCount = 0,
            subID = RedDotType.Secure,
            category = Category.Receive,
            pages = {
              newCount = 0,
              category = Category.Receive,
              isDynamic = true
            }
          }
        }
      }
    }
  }
  return data
end
function ugc_mail_reddot_data.InitData()
  if bIsInited then
    return
  end
  bIsInited = true
  local data = GenerateData()
  local super_data = require("common.super_data")
  if RedDot == nil then
    RedDot = super_data.CreateSuperData(data)
  end
  local RedDotManager = require("client.slua.logic.reddot.reddot_manager")
  RedDotManager:Regist(RedDot)
end
function ugc_mail_reddot_data.DestroyData()
  RedDot = nil
  bIsInited = false
end
function ugc_mail_reddot_data.OnLogin()
  log(bWriteLog and "ugc_mail_reddot_data OnLogin")
  ugc_mail_reddot_data.InitData()
end
function ugc_mail_reddot_data.OnLogout()
  log(bWriteLog and "ugc_mail_reddot_data OnLogout")
  ugc_mail_reddot_data.DestroyData()
end
function ugc_mail_reddot_data.GetRedDot()
  return RedDot
end
function ugc_mail_reddot_data.GetMessageRedDot()
  if RedDot then
    return RedDot.types[RedDotType.Message]
  end
end
function ugc_mail_reddot_data.GetSubRedDot(subID)
  if RedDot then
    local redDotType
    if subID == RedDotType.System then
      redDotType = RedDotType.System
    elseif subID == RedDotType.Secure then
      redDotType = RedDotType.Secure
    end
    if redDotType then
      return RedDot.types[RedDotType.Message].pages[redDotType]
    end
  end
end
function ugc_mail_reddot_data.UpdateRedDot(MailList)
  local SystemRedDotData = ugc_mail_reddot_data.GetSubRedDot(RedDotType.System)
  local SecureRedDotData = ugc_mail_reddot_data.GetSubRedDot(RedDotType.Secure)
  local MessageRetDotData = ugc_mail_reddot_data.GetMessageRedDot()
  if not MailList or not next(MailList) then
    log(bWriteLog and "[v_yibxu] ugc_mail_reddot_data  UpdateRedDot MailList = nil")
    return
  else
    for k, v in pairs(MailList) do
      local mail_id = v.Mail.my_id
      local RedDot
      local redCategory, subID = ugc_mail_reddot_data.GetCategoryWithSubId(mail_id)
      if v.UGCMail.SubTab == RedDotType.System then
        RedDot = SystemRedDotData
      elseif v.UGCMail.SubTab == RedDotType.Secure then
        RedDot = SecureRedDotData
      end
      if RedDot then
        if not RedDot.pages[mail_id] then
          RedDot.pages[mail_id] = ugc_mail_reddot_data.GenDefaultSubData(subID, redCategory)
        else
          RedDot.pages[mail_id].category = redCategory
          RedDot.pages[mail_id].        end
        if v.Mail.read then
          RedDot.pages[mail_id].newCount = 0
        else
          RedDot.pages[mail_id].newCount = 1
        end
      end
    end
    ugc_mail_reddot_data.RemoveNotPlayerClickMailRed(MailList)
  end
end
function ugc_mail_reddot_data.RemoveNotPlayerClickMailRed(newMailList)
  if not RedDot then
    return
  end
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  local NewMailList = {}
  for key, value in pairs(newMailList) do
    NewMailList[value.Mail.my_id] = value
  end
  for _, mail_type in pairs(Config_UGC.Config_UGC_MessageType) do
    local tabData = RedDot.types[RedDotType.Message].pages[mail_type] or {}
    ugc_mail_reddot_data.SendMailRedRemoveTLog(tabData.pages, NewMailList)
  end
end
function ugc_mail_reddot_data.SendMailRedRemoveTLog(list, new_list)
  if not list then
    return
  end
  for k, v in pairs(list) do
    if type(v) == "table" and not new_list[k] and v.newCount and v.newCount ~= 0 then
      v.newCount = 0
      log(bWriteLog and "[v_yibxu] ugc_mail_reddot_data DelReddot mail_id = " .. k .. " newCount = 0")
    end
  end
end
function ugc_mail_reddot_data.GenDefaultSubData(subID, redType)
  local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
  local data = {
    newCount = 0,
    category = redType or reddot_macro.Category.Other,
    subID = subID,
    instanceId = {_isLeaf = true}
  }
  return data
end
function ugc_mail_reddot_data.GetCategoryWithSubId(mailID)
  local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
  local logic_mail = require("client.slua.logic.mail.logic_mail")
  local logic_mail_utils = require("client.slua.logic.mail.logic_mail_utils")
  local UGC_Config = require("client/slua/logic/ugc/config_ugc")
  local category = reddot_macro.Category.Other
  local sub_id = UGC_Config.Enum_RedPoint_SubID.Msg
  local b_attach = false
  local mail_info = logic_mail.GetMailInfoById(mailID)
  if mail_info then
    if logic_mail_utils.IsWithAttach(mail_info) then
      b_attach = true
      category = reddot_macro.Category.Receive
    end
    sub_id = b_attach and UGC_Config.Enum_RedPoint_SubID.MsgWithAttach or UGC_Config.Enum_RedPoint_SubID.Msg
  end
  return category, sub_id
end
return ugc_mail_reddot_data