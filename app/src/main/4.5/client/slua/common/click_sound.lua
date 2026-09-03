local click_sound = {}
function click_sound.PlaySoundNameByIndex(index)
  local audio_util = require("client.common.audio_util")
  local name = sound_config.Sound_Map[index]
  if name then
    audio_util.PlayAudio(sound_config[name])
    log(bWriteLog and "PlaySoundNameByIndex name:" .. name)
  else
    log(bWriteLog and "PlaySoundNameByIndex nil")
  end
end
function click_sound.Init()
  local sButton = import("/Script/UMG.Button")
  if nil ~= sButton.SetOnClickSound then
    local OnClickSoundDelegate = slua.createDelegate(click_sound.PlaySoundNameByIndex)
    local delegates = {}
    click_sound._    table.insert(delegates, OnClickSoundDelegate)
    sButton.SetOnClickSound(OnClickSoundDelegate)
  end
end
return click_sound