local SoundUtils = {
  BuiltinInterval = 100000.0,
  SoundEventTable = {},
  SoundCountDown = "/Game/Mod/EvoBase/WwiseEvent/Play_Target_Count.Play_Target_Count",
  SoundAddScore = "/Game/Mod/EvoBase/WwiseEvent/Play_Target_Score_1.Play_Target_Score_1",
  SoundStartTrain = "/Game/Mod/EvoBase/WwiseEvent/Play_Target_Count_Go.Play_Target_Count_Go",
  SoundShowResult = "/Game/Mod/EvoBase/WwiseEvent/Play_Target_Whistle.Play_Target_Whistle",
  SoundAddMiss = "/Game/Mod/SocialIsland/WwiseEvent/Play_Target_Alarm.Play_Target_Alarm"
}
function SoundUtils.PlayClickAudio()
  SoundUtils.PlayAudio(sound_config.click_v1)
end
function SoundUtils.PlayCloseAudio()
  SoundUtils.PlayAudio(sound_config.close_v1)
end
function SoundUtils.SoundMiss()
  SoundUtils.PlayAudio(SoundUtils.SoundAddMiss)
end
function SoundUtils.PlayStartAudio()
  SoundUtils.PlayAudio(SoundUtils.SoundStartTrain)
end
function SoundUtils.PlayCountDown()
  SoundUtils.PlayAudio(SoundUtils.SoundCountDown)
end
function SoundUtils.PlayAddScore()
  SoundUtils.PlayAudio(SoundUtils.SoundAddScore)
end
function SoundUtils.PlayShowResult()
  SoundUtils.PlayAudio(SoundUtils.SoundShowResult)
end
function SoundUtils.PlayAudio(audio_path)
  local lastPlayTimestamp = SoundUtils.SoundEventTable[audio_path]
  local currentTime = slua.getMicroseconds()
  if lastPlayTimestamp == nil or currentTime - lastPlayTimestamp >= SoundUtils.BuiltinInterval then
    SoundUtils.SoundEventTable[audio_path] = currentTime
    local audio_util = require("client.common.audio_util")
    audio_util.PlayAudio(audio_path)
  end
end
return SoundUtils