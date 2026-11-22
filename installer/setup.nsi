; -*- coding: utf-8 -*-
Unicode true
!include "MUI2.nsh"
!include "nsDialogs.nsh"
!include "x64.nsh"
!include "WinVer.nsh"
!include "FileFunc.nsh"

!ifndef APP_ID
  !define APP_ID "Daozai"
!endif
!ifndef APP_NAME
  !define APP_NAME "島仔"
  !define LEGACY_APP_NAME "岛仔"
!endif
!define UNINSTALL_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_ID}"
Name "${APP_NAME}"
OutFile "${OUTPUT_FILE}"
InstallDir "$LOCALAPPDATA\Programs\${APP_ID}"
InstallDirRegKey HKCU "${UNINSTALL_KEY}" "InstallLocation"
RequestExecutionLevel user
ManifestDPIAware true
SetCompressor /SOLID lzma
VIProductVersion "${APP_VERSION}.0"
VIAddVersionKey /LANG=1028 "ProductName" "${APP_NAME}"
VIAddVersionKey /LANG=1028 "FileDescription" "${APP_NAME}安裝程式"
VIAddVersionKey /LANG=1028 "FileVersion" "${APP_VERSION}"
VIAddVersionKey /LANG=1028 "LegalCopyright" "島仔貢獻者"
!define MUI_ICON "${PROJECT_DIR}\assets\daozai.ico"
!define MUI_UNICON "${PROJECT_DIR}\assets\daozai.ico"
!define MUI_ABORTWARNING
Var BrandIcon
Var PathInput
Var DesktopCheckbox
Var AutoStartCheckbox
Var DesktopChoice
Var AutoStartChoice
Page custom InstallPage InstallPageLeave
!insertmacro MUI_PAGE_INSTFILES
!define MUI_FINISHPAGE_TITLE "島仔已安裝"
!define MUI_FINISHPAGE_TEXT "音樂、提醒和日常小事，現在都在桌面上的小島裡。"
!define MUI_FINISHPAGE_RUN "$INSTDIR\daozai.exe"
!define MUI_FINISHPAGE_RUN_TEXT "開啟島仔"
!insertmacro MUI_PAGE_FINISH
!define MUI_UNCONFIRMPAGE_TEXT_TOP "即將解除安裝島仔。設定、待辦事項和連線記錄會保留，重新安裝後仍可使用。"
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_LANGUAGE "TradChinese"
BrandingText "島仔 · Daozai"
SetFont "Microsoft JhengHei UI" 9

Function .onInit
  ${IfNot} ${RunningX64}
    MessageBox MB_OK|MB_ICONSTOP "島仔需要 64 位元的 Windows 10 或 Windows 11。" /SD IDOK
    SetErrorLevel 1
    Quit
  ${EndIf}
  ${IfNot} ${AtLeastWin10}
    MessageBox MB_OK|MB_ICONSTOP "島仔需要 Windows 10 或 Windows 11。" /SD IDOK
    SetErrorLevel 1
    Quit
  ${EndIf}
  SetShellVarContext current
  SetRegView 64
  StrCpy $DesktopChoice 1
  StrCpy $AutoStartChoice 0
  ReadRegStr $0 HKCU "${UNINSTALL_KEY}" "InstallLocation"
  ${If} $0 != ""
    StrCpy $DesktopChoice 0
    ${If} ${FileExists} "$DESKTOP\${APP_NAME}.lnk"
!ifdef LEGACY_APP_NAME
    ${OrIf} ${FileExists} "$DESKTOP\${LEGACY_APP_NAME}.lnk"
!endif
      StrCpy $DesktopChoice 1
    ${EndIf}
  ${EndIf}
  ReadRegStr $0 HKCU "Software\Microsoft\Windows\CurrentVersion\Run" "${APP_ID}"
  ${If} $0 != ""
    StrCpy $AutoStartChoice 1
  ${EndIf}
  ; 靜默安裝使用同一組選項，/D 路徑由 NSIS 處理。
  ${GetParameters} $0
  ${GetOptions} $0 "/DESKTOP=" $1
  ${If} $1 == "0"
  ${OrIf} $1 == "1"
    StrCpy $DesktopChoice $1
  ${EndIf}
  ${GetOptions} $0 "/AUTOSTART=" $1
  ${If} $1 == "0"
  ${OrIf} $1 == "1"
    StrCpy $AutoStartChoice $1
  ${EndIf}
FunctionEnd

Function InstallPage
  !insertmacro MUI_HEADER_TEXT "歡迎使用島仔" "Windows 螢幕頂端的桌面夥伴"
  nsDialogs::Create 1018
  Pop $0
  InitPluginsDir
  File /oname=$PLUGINSDIR\brand.ico "${PROJECT_DIR}\assets\daozai.ico"
  ${NSD_CreateIcon} 0 6u 44u 44u ""
  Pop $0
  System::Call 'user32::LoadImageW(p 0, w "$PLUGINSDIR\brand.ico", i 1, i 64, i 64, i 0x10) p .r1'
  StrCpy $BrandIcon $1
  SendMessage $0 0x170 $1 0
  ${NSD_CreateLabel} 58u 8u 240u 22u "${APP_NAME}"
  Pop $0
  CreateFont $1 "Microsoft JhengHei UI" 18 700
  SendMessage $0 ${WM_SETFONT} $1 0
  ${NSD_CreateLabel} 112u 14u 188u 14u "v${APP_VERSION} · 升級時保留設定和記錄"
  Pop $0
  ${NSD_CreateLabel} 58u 34u 240u 20u "讓重要的資訊輕輕出現在螢幕頂端。"
  Pop $0
  ${NSD_CreateLabel} 0 58u 300u 16u "歌詞 · 電子郵件驗證碼 · 行程提醒 · AI 額度"
  Pop $0
  ${NSD_CreateLabel} 0 80u 300u 12u "安裝位置"
  Pop $0
  ${NSD_CreateDirRequest} 0 96u 245u 16u "$INSTDIR"
  Pop $PathInput
  ${NSD_CreateBrowseButton} 250u 96u 50u 16u "瀏覽…"
  Pop $0
  ${NSD_OnClick} $0 BrowseDirectory
  ${NSD_CreateCheckbox} 0 122u 150u 14u "建立桌面捷徑"
  Pop $DesktopCheckbox
  ${NSD_SetState} $DesktopCheckbox $DesktopChoice
  ${NSD_CreateCheckbox} 165u 122u 135u 14u "開機時自動啟動"
  Pop $AutoStartCheckbox
  ${NSD_SetState} $AutoStartCheckbox $AutoStartChoice
  GetDlgItem $0 $HWNDPARENT 1
  SendMessage $0 ${WM_SETTEXT} 0 "STR:一鍵安裝"
  nsDialogs::Show
FunctionEnd

; 接受磁碟機或 UNC 共用位置下的完整子資料夾路徑。先正規化，避免將空白輸入或磁碟機代號補成安裝路徑。
Function CheckFolderPath
  ${GetRoot} "$INSTDIR" $0
  ${If} $0 != ""
    StrLen $1 $0
    StrCpy $2 "$INSTDIR" "" $1
    StrCpy $1 $2 1
    ${If} $1 == "\"
    ${AndIf} $2 != "\"
      System::Call 'kernel32::GetFullPathNameW(w "$INSTDIR", i ${NSIS_MAX_STRLEN}, w .r2, p 0) i .r0'
      ${If} $0 == 0
      ${OrIf} $0 >= ${NSIS_MAX_STRLEN}
        Goto invalid_path
      ${EndIf}
      System::Call 'shlwapi::PathIsRootW(w "$2") i .r0'
      ${If} $0 == 0
        StrCpy $INSTDIR $2
        StrCpy $0 1
        Return
      ${EndIf}
    ${EndIf}
  ${EndIf}
  invalid_path:
  StrCpy $0 0
FunctionEnd

; 選取的資料夾若已有其他檔案，會建立 Daozai 子資料夾，避免將整個共用資料夾登記為安裝位置。
; 資料夾名稱為 Daozai、已安裝島仔、不存在或為空時，直接使用該路徑。
Function EnsureOwnFolder
  Call CheckFolderPath
  ${If} $0 == 0
    Return
  ${EndIf}
  StrCpy $0 $INSTDIR 1 -1
  ${If} $0 == "\"
    StrCpy $INSTDIR $INSTDIR -1
  ${EndIf}
  ${GetFileName} "$INSTDIR" $0
  ${If} $0 == "${APP_ID}"
    Return
  ${EndIf}
  ${If} ${FileExists} "$INSTDIR\daozai.exe"
    Return
  ${EndIf}
  ClearErrors
  FindFirst $1 $2 "$INSTDIR\*.*"
  ${DoWhile} $2 != ""
    ${If} $2 != "."
    ${AndIf} $2 != ".."
      FindClose $1
      StrCpy $INSTDIR "$INSTDIR\${APP_ID}"
      Return
    ${EndIf}
    FindNext $1 $2
  ${Loop}
  FindClose $1
  ClearErrors
FunctionEnd

Function BrowseDirectory
  Pop $0
  ${NSD_GetText} $PathInput $0
  nsDialogs::SelectFolderDialog "選擇島仔的安裝資料夾" "$0"
  Pop $0
  ${If} $0 != "error"
    StrCpy $INSTDIR $0
    Call EnsureOwnFolder
    ${NSD_SetText} $PathInput "$INSTDIR"
  ${EndIf}
FunctionEnd

Function ValidateDirectory
  Call CheckFolderPath
  ${If} $0 == 0
    Goto invalid
  ${EndIf}
  ClearErrors
  CreateDirectory "$INSTDIR"
  IfErrors invalid
  GetFullPathName $INSTDIR "$INSTDIR"
  IfErrors invalid
  GetTempFileName $0 "$INSTDIR"
  IfErrors invalid
  Delete "$0"
  SetErrorLevel 0
  Return
  invalid:
    MessageBox MB_OK|MB_ICONEXCLAMATION "請選擇可寫入的安裝資料夾，例如 D:\Apps\Daozai。請避開磁碟根目錄和需要系統管理員權限的資料夾。" /SD IDOK
    SetErrorLevel 1
    Abort
FunctionEnd

Function InstallPageLeave
  ${NSD_GetText} $PathInput $INSTDIR
  ${NSD_GetState} $DesktopCheckbox $DesktopChoice
  ${NSD_GetState} $AutoStartCheckbox $AutoStartChoice
  Call EnsureOwnFolder
  ${NSD_SetText} $PathInput "$INSTDIR"
  Call ValidateDirectory
FunctionEnd

Function .onGUIEnd
  System::Call 'user32::DestroyIcon(p $BrandIcon)'
FunctionEnd

; 程式執行時提示使用者從系統匣結束程式。
!macro ClosedCheck Prefix
Function ${Prefix}CheckClosed
  retry:
  System::Call 'kernel32::OpenMutexW(i 0x100000, i 0, w "Local\${APP_ID}.SingleInstance") p .r0'
  ${If} $0 != 0
    System::Call 'kernel32::CloseHandle(p r0)'
    MessageBox MB_RETRYCANCEL|MB_ICONINFORMATION "請先從系統匣結束${APP_NAME}，再按「重試」。" /SD IDCANCEL IDRETRY retry
    SetErrorLevel 2
    Abort
  ${EndIf}
FunctionEnd
!macroend
!insertmacro ClosedCheck ""
!insertmacro ClosedCheck "un."

!macro DeleteLegacyShortcuts
!ifdef LEGACY_APP_NAME
  Delete "$DESKTOP\${LEGACY_APP_NAME}.lnk"
  Delete "$SMPROGRAMS\${LEGACY_APP_NAME}.lnk"
  Delete "$SMPROGRAMS\${LEGACY_APP_NAME}设置.lnk"
  Delete "$SMPROGRAMS\收集${LEGACY_APP_NAME}诊断.lnk"
!endif
!macroend

Section "安裝"
  Call CheckClosed
  ; 靜默安裝的 /D 路徑也使用專用資料夾規則。
  Call EnsureOwnFolder
  Call ValidateDirectory
  SetOutPath "$INSTDIR"
  SetOverwrite on
  File /oname=daozai.exe "${SOURCE_EXE}"
  File "${PROJECT_DIR}\LICENSE"
  File "${PROJECT_DIR}\THIRD_PARTY_NOTICES.txt"
  ; 程式已內建診斷功能，移除測試版留下的獨立診斷檔案。
  Delete "$INSTDIR\收集岛仔诊断.cmd"
  Delete "$INSTDIR\scripts\collect-diagnostics.ps1"
  RMDir "$INSTDIR\scripts"
  WriteUninstaller "$INSTDIR\Uninstall.exe"
  !insertmacro DeleteLegacyShortcuts
  ${If} $DesktopChoice == 1
    CreateShortcut "$DESKTOP\${APP_NAME}.lnk" "$INSTDIR\daozai.exe"
  ${Else}
    Delete "$DESKTOP\${APP_NAME}.lnk"
  ${EndIf}
  ${If} $AutoStartChoice == 1
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Run" "${APP_ID}" '"$INSTDIR\daozai.exe"'
  ${Else}
    DeleteRegValue HKCU "Software\Microsoft\Windows\CurrentVersion\Run" "${APP_ID}"
  ${EndIf}
  CreateShortcut "$SMPROGRAMS\${APP_NAME}.lnk" "$INSTDIR\daozai.exe"
  CreateShortcut "$SMPROGRAMS\${APP_NAME}設定.lnk" "$INSTDIR\daozai.exe" "--settings"
  ; 島仔無法開啟或沒有回應時，可從這裡收集診斷資料。
  CreateShortcut "$SMPROGRAMS\收集${APP_NAME}診斷.lnk" "$INSTDIR\daozai.exe" "--collect-diagnostics" "$INSTDIR\daozai.exe" 0
  WriteRegStr HKCU "${UNINSTALL_KEY}" "DisplayName" "${APP_NAME} Daozai"
  WriteRegStr HKCU "${UNINSTALL_KEY}" "DisplayVersion" "${APP_VERSION}"
  WriteRegStr HKCU "${UNINSTALL_KEY}" "Publisher" "島仔"
  WriteRegStr HKCU "${UNINSTALL_KEY}" "InstallLocation" "$INSTDIR"
  WriteRegStr HKCU "${UNINSTALL_KEY}" "DisplayIcon" "$INSTDIR\daozai.exe,0"
  WriteRegStr HKCU "${UNINSTALL_KEY}" "UninstallString" '"$INSTDIR\Uninstall.exe"'
  WriteRegStr HKCU "${UNINSTALL_KEY}" "QuietUninstallString" '"$INSTDIR\Uninstall.exe" /S'
  WriteRegDWORD HKCU "${UNINSTALL_KEY}" "NoModify" 1
  WriteRegDWORD HKCU "${UNINSTALL_KEY}" "NoRepair" 1
  ; 登記島仔檔案的大小（KB），以免 Windows 將整個安裝資料夾納入統計。
  ${GetSize} "$INSTDIR" "/M=daozai.exe /S=0K /G=0" $0 $1 $2
  ${GetSize} "$INSTDIR" "/M=Uninstall.exe /S=0K /G=0" $3 $1 $2
  IntOp $0 $0 + $3
  ${GetSize} "$INSTDIR" "/M=THIRD_PARTY_NOTICES.txt /S=0K /G=0" $3 $1 $2
  IntOp $0 $0 + $3
  IntOp $0 $0 + 8
  WriteRegDWORD HKCU "${UNINSTALL_KEY}" "EstimatedSize" $0
  Delete "$INSTDIR\uninstall.ps1"
SectionEnd

Function un.onInit
  SetShellVarContext current
  SetRegView 64
FunctionEnd

Section "Uninstall"
  Call un.CheckClosed
  Delete "$INSTDIR\daozai.exe"
  Delete "$INSTDIR\daozai-previous.exe"
  Delete "$INSTDIR\daozai-v0.2-backup.exe"
  Delete "$INSTDIR\LICENSE"
  Delete "$INSTDIR\THIRD_PARTY_NOTICES.txt"
  Delete "$INSTDIR\uninstall.ps1"
  Delete "$INSTDIR\收集岛仔诊断.cmd"
  Delete "$INSTDIR\scripts\collect-diagnostics.ps1"
  RMDir "$INSTDIR\scripts"
  Delete "$INSTDIR\Uninstall.exe"
  Delete "$DESKTOP\${APP_NAME}.lnk"
  Delete "$SMPROGRAMS\${APP_NAME}.lnk"
  Delete "$SMPROGRAMS\${APP_NAME}設定.lnk"
  Delete "$SMPROGRAMS\收集${APP_NAME}診斷.lnk"
  !insertmacro DeleteLegacyShortcuts
  ReadRegStr $0 HKCU "Software\Microsoft\Windows\CurrentVersion\Run" "${APP_ID}"
  ${If} $0 == '"$INSTDIR\daozai.exe"'
    DeleteRegValue HKCU "Software\Microsoft\Windows\CurrentVersion\Run" "${APP_ID}"
  ${EndIf}
  DeleteRegKey HKCU "${UNINSTALL_KEY}"
  ; 只移除空的安裝資料夾，保留使用者資料及自行放入的檔案。
  RMDir "$INSTDIR"
SectionEnd
