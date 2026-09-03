local long_txt_manager = {}
local GetContentByPath = function(path)
  local content
  if type(path) == "string" then
    content = require(path)
  else
    log_error("[jonahwei]long_txt_manager:GetContentByPath  path = " .. tostring(path))
  end
  if type(content) ~= "string" then
    content = ""
    log_error("[jonahwei]long_txt_manager:GetContentByPath  content not found!!")
  end
  return content
end
function long_txt_manager:GetPrivacyAgreementVersion()
  local region = Client.GetPublishRegion()
  log(bWriteLog and "[jonahwei]long_txt_manager:GetPrivacyAgreementVersion, region = " .. tostring(region))
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local privacyAgreementConfig = require("client.slua.config.longs.privacy_agreement.privacy_agreement_config")
  local version
  if region == PublishRegionMacros.JAPAN then
    version = privacyAgreementConfig.PrivacyPolicy_jp_Version
  elseif region == PublishRegionMacros.KOREA then
    version = privacyAgreementConfig.PrivacyPolicy_kr_Version
  elseif region == PublishRegionMacros.VNG then
    version = privacyAgreementConfig.PrivacyPolicy_VNG_Version
  elseif region == PublishRegionMacros.TW then
    version = privacyAgreementConfig.PrivacyPolicy_TW_Version
  elseif region == PublishRegionMacros.BLUEHOLE then
    version = privacyAgreementConfig.PrivacyPolicy_BH_Version
  else
    version = privacyAgreementConfig.PrivacyPolicy_Global_Version
  end
  if type(version) ~= "number" then
    version = 0
    log_error("[jonahwei]long_txt_manager:GetPrivacyAgreementVersion  version not found!!")
  end
  return version
end
function long_txt_manager:GetPrivacyAgreementTitle()
  local region = Client.GetPublishRegion()
  log(bWriteLog and "[jonahwei]long_txt_manager:GetPrivacyAgreementTitle, region = " .. tostring(region))
  local privacyAgreementConfig = require("client.slua.config.longs.privacy_agreement.privacy_agreement_config")
  local title = LocUtil.GetLocalizeResStr(privacyAgreementConfig.PrivacyPolicy_Title)
  if type(title) ~= "string" then
    title = ""
    log_error("[jonahwei]long_txt_manager:GetPrivacyAgreementTitle  title not found!!")
  end
  return title
end
function long_txt_manager:GetPrivacyAgreementContent()
  local language = Client.GetCurrentLanguage()
  local region = Client.GetPublishRegion()
  log(bWriteLog and "[jonahwei]long_txt_manager:GetPrivacyAgreementContent, region = " .. tostring(region) .. ", language = " .. tostring(language))
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local privacyAgreementConfig = require("client.slua.config.longs.privacy_agreement.privacy_agreement_config")
  local contentFile
  if region == PublishRegionMacros.JAPAN then
    contentFile = privacyAgreementConfig.japanContent
  elseif region == PublishRegionMacros.KOREA then
    contentFile = privacyAgreementConfig.koreaContent
  elseif region == PublishRegionMacros.VNG then
    contentFile = privacyAgreementConfig.vngContent
  elseif region == PublishRegionMacros.TW then
    contentFile = privacyAgreementConfig.twContent
  elseif region == PublishRegionMacros.BLUEHOLE then
    contentFile = privacyAgreementConfig.bhContent
  else
    return ""
  end
  return GetContentByPath(contentFile)
end
function long_txt_manager:GetUserAgreementVersion()
  local region = Client.GetPublishRegion()
  log(bWriteLog and "[jonahwei]long_txt_manager:GetUserAgreementVersion, region = " .. tostring(region))
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local userAgreementConfig = require("client.slua.config.longs.user_agreement.user_agreement_config")
  local version
  if region == PublishRegionMacros.JAPAN then
    version = userAgreementConfig.UserAgreement_jp_Version
  elseif region == PublishRegionMacros.KOREA then
    version = userAgreementConfig.UserAgreement_kr_Version
  elseif region == PublishRegionMacros.VNG then
    version = userAgreementConfig.UserAgreement_VNG_Version
  elseif region == PublishRegionMacros.TW then
    version = userAgreementConfig.UserAgreement_TW_Version
  elseif region == PublishRegionMacros.BLUEHOLE then
    version = userAgreementConfig.UserAgreement_BH_Version
  else
    version = userAgreementConfig.UserAgreement_Global_Version
  end
  if type(version) ~= "number" then
    version = 0
    log_error("[jonahwei]long_txt_manager:GetUserAgreementVersion  version not found!!")
  end
  return version
end
function long_txt_manager:GetUserAgreementTitle()
  local language = Client.GetCurrentLanguage()
  local region = Client.GetPublishRegion()
  log(bWriteLog and "[jonahwei]long_txt_manager:GetUserAgreementTitle, region = " .. tostring(region))
  local userAgreementConfig = require("client.slua.config.longs.user_agreement.user_agreement_config")
  local title = LocUtil.GetLocalizeResStr(userAgreementConfig.UserAgreement_Title)
  if type(title) ~= "string" then
    title = ""
    log_error("[jonahwei]long_txt_manager:GetUserAgreementTitle  title not found!!")
  end
  return title
end
function long_txt_manager:GetUserAgreementContent()
  local language = Client.GetCurrentLanguage()
  local region = Client.GetPublishRegion()
  log(bWriteLog and "[jonahwei]long_txt_manager:GetUserAgreementContent, region = " .. tostring(region) .. ", language = " .. tostring(language))
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local userAgreementConfig = require("client.slua.config.longs.user_agreement.user_agreement_config")
  local contentFile
  if region == PublishRegionMacros.JAPAN then
    contentFile = userAgreementConfig.japanContent
  elseif region == PublishRegionMacros.KOREA then
    contentFile = userAgreementConfig.koreaContent
  elseif region == PublishRegionMacros.VNG then
    contentFile = userAgreementConfig.vngContent
  elseif region == PublishRegionMacros.TW then
    contentFile = userAgreementConfig.twContent
  elseif region == PublishRegionMacros.BLUEHOLE then
    contentFile = userAgreementConfig.bhContent
  else
    return ""
  end
  return GetContentByPath(contentFile)
end
function long_txt_manager:GetageLimiteTitle()
  local userAgreementConfig = require("client.slua.config.longs.user_agreement.user_agreement_config")
  local title = userAgreementConfig.UserAgeLimit_title_kr
  if type(title) ~= "string" then
    title = ""
    log_error("[v_jqqqzhang]long_txt_manager:GetageLimiteTitle  title not found!!")
  end
  return title
end
function long_txt_manager:GetageLimiteContent()
  local language = Client.GetCurrentLanguage()
  local region = Client.GetPublishRegion()
  log(bWriteLog and "[v_jqqqzhang]long_txt_manager:GetUserAgreementContent, region = " .. tostring(region) .. ", language = " .. tostring(language))
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local userAgreementConfig = require("client.slua.config.longs.user_agreement.user_agreement_config")
  local contentFile
  contentFile = userAgreementConfig.koreaageContent
  return GetContentByPath(contentFile)
end
function long_txt_manager:GetAntiAddictionContent()
  local config = require("client.slua.config.longs.anti_addiction.anti_addiction_config")
  local contentFile = config.Anti_Addiction_Content
  return GetContentByPath(contentFile)
end
function long_txt_manager:GetJapanLawTitle()
  local config = require("client.slua.config.longs.japan_law.japan_law_config")
  local title = config.Japan_Law_Title
  if type(title) ~= "string" then
    title = ""
    log_error("[jonahwei]long_txt_manager:GetJapanLawTitle  title not found!!")
  end
  return title
end
function long_txt_manager:GetJapanLawContent()
  local config = require("client.slua.config.longs.japan_law.japan_law_config")
  local contentFile = config.Japan_Law_Content
  return GetContentByPath(contentFile)
end
function long_txt_manager:GetJapanLawContent_New()
  local config = require("client.slua.config.longs.japan_law.japan_law_config")
  local contentFile = config.Japan_Law_Content_New
  return GetContentByPath(contentFile)
end
function long_txt_manager:GetJapanLawContent2_New()
  local config = require("client.slua.config.longs.japan_law.japan_law_config")
  local contentFile = config.Japan_Law_Content2_New
  return GetContentByPath(contentFile)
end
function long_txt_manager:GetJapanLawVersion_New()
  local config = require("client.slua.config.longs.japan_law.japan_law_config")
  return config.Japan_Law_Version_New
end
function long_txt_manager:GetJapanLawVersion2_New()
  local config = require("client.slua.config.longs.japan_law.japan_law_config")
  return config.Japan_Law_Version2_New
end
function long_txt_manager:GetDIYAgreementVersion()
  local region = Client.GetPublishRegion()
  log(bWriteLog and "[jonahwei]long_txt_manager:GetDIYAgreementVersion, region = " .. tostring(region))
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local diyAgreementConfig = require("client.slua.config.longs.diy_agreement.diy_agreement_config")
  local version
  if region == PublishRegionMacros.JAPAN then
    version = diyAgreementConfig.DIYAgreement_jp_Version
  elseif region == PublishRegionMacros.KOREA then
    version = diyAgreementConfig.DIYAgreement_kr_Version
  elseif region == PublishRegionMacros.VNG then
    version = diyAgreementConfig.DIYAgreement_VNG_Version
  elseif region == PublishRegionMacros.TW then
    version = diyAgreementConfig.DIYAgreement_TW_Version
  elseif region == PublishRegionMacros.BLUEHOLE then
    version = diyAgreementConfig.DIYAgreement_BH_Version
  else
    version = diyAgreementConfig.DIYAgreement_Global_Version
  end
  if type(version) ~= "number" then
    version = 0
    log_error("[jonahwei]long_txt_manager:GetDIYAgreementVersion  version not found!!")
  end
  return version
end
function long_txt_manager:GetDIYAgreementTitle()
  local language = Client.GetCurrentLanguage()
  local region = Client.GetPublishRegion()
  log(bWriteLog and "[jonahwei]long_txt_manager:GetDIYAgreementTitle, region = " .. tostring(region))
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local diyAgreementConfig = require("client.slua.config.longs.diy_agreement.diy_agreement_config")
  local title
  if region == PublishRegionMacros.JAPAN then
    title = diyAgreementConfig.DIYAgreement_title_jp
  elseif region == PublishRegionMacros.KOREA then
    title = diyAgreementConfig.DIYAgreement_title_kr
  elseif region == PublishRegionMacros.VNG then
    title = diyAgreementConfig.DIYAgreement_title_VNG
  elseif region == PublishRegionMacros.TW then
    title = diyAgreementConfig.DIYAgreement_title_TW
  elseif region == PublishRegionMacros.BLUEHOLE then
    title = diyAgreementConfig.DIYAgreement_title_BH
  elseif diyAgreementConfig.bUseDiffLanguage then
    title = diyAgreementConfig.globalTitle[language]
    if title == nil then
      title = diyAgreementConfig.globalTitle[diyAgreementConfig.defaultLanguage]
    end
  else
    title = diyAgreementConfig.globalTitle[diyAgreementConfig.defaultLanguage]
  end
  if type(title) ~= "string" then
    title = ""
    log_error("[jonahwei]long_txt_manager:GetDIYAgreementTitle  title not found!!")
  end
  return title
end
function long_txt_manager:GetDIYAgreementContent()
  local language = Client.GetCurrentLanguage()
  local region = Client.GetPublishRegion()
  log(bWriteLog and "[jonahwei]long_txt_manager:GetDIYAgreementContent, region = " .. tostring(region) .. ", language = " .. tostring(language))
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local diyAgreementConfig = require("client.slua.config.longs.diy_agreement.diy_agreement_config")
  local contentFile
  if region == PublishRegionMacros.JAPAN then
    contentFile = diyAgreementConfig.japanContent
  elseif region == PublishRegionMacros.KOREA then
    contentFile = diyAgreementConfig.koreaContent
  elseif region == PublishRegionMacros.VNG then
    contentFile = diyAgreementConfig.vngContent
  elseif region == PublishRegionMacros.TW then
    contentFile = diyAgreementConfig.twContent
  elseif region == PublishRegionMacros.BLUEHOLE then
    contentFile = diyAgreementConfig.bhContent
  elseif diyAgreementConfig.bUseDiffLanguage then
    contentFile = diyAgreementConfig.globalContent[language]
    if contentFile == nil then
      contentFile = diyAgreementConfig.globalContent[diyAgreementConfig.defaultLanguage]
    end
  else
    contentFile = diyAgreementConfig.globalContent[diyAgreementConfig.defaultLanguage]
  end
  return GetContentByPath(contentFile)
end
function long_txt_manager:IsInEUCountry(ipCode)
  local config = require("client.slua.config.longs.eu_ads.eu_ads_config")
  return config.EU_Ads_Country[tostring(ipCode)] ~= nil
end
function long_txt_manager:GetAdsTitle()
  local config = require("client.slua.config.longs.eu_ads.eu_ads_config")
  local LanguageMacros = require("client.slua.config.ClientMacros.LanguageMacros")
  local language = Client.GetCurrentLanguage()
  local title = config.EU_Ads_Title[language] or config.EU_Ads_Title[LanguageMacros.EN]
  log(bWriteLog and string.format("long_txt_manager:GetAdsTitle language : %s, title : %s", tostring(language), tostring(title)))
  return title
end
function long_txt_manager:GetAdsContent()
  local config = require("client.slua.config.longs.eu_ads.eu_ads_config")
  local LanguageMacros = require("client.slua.config.ClientMacros.LanguageMacros")
  local language = Client.GetCurrentLanguage()
  local filePath = config.EU_Ads_Content[language] or config.EU_Ads_Content[LanguageMacros.EN]
  log(bWriteLog and string.format("long_txt_manager:GetAdsContent language : %s, contentPath : %s", tostring(language), tostring(filePath)))
  return GetContentByPath(filePath)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLongTxtManager = class(CModuleBase, nil, long_txt_manager)
return CLongTxtManager