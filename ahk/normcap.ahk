#NoEnv
#SingleInstance Force
^PrintScreen::
EnvGet, UserProfile, UserProfile
cmd := UserProfile "\AppData\Local\Programs\NormCap\python\pythonw.exe -m normcap"
Run, %cmd%
return
