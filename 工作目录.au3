#include <GUIConstantsEx.au3>
#include <MsgBoxConstants.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <process.au3>
#include <Array.au3>
#include <Clipboard.au3>

Opt("GUIOnEventMode", 1) ; Change to OnEvent mode

Local $base_path = "D:\mst\"
local $win_w = 1200;
local $win_h = 600;
;点击窗口关闭事件函数
Func closeApp()
   Exit;
EndFunc
;创建窗口
Func createGui($w,$h)
   Local $hGUI = GUICreate($base_path, $w, $h)
   GUISetOnEvent($GUI_EVENT_CLOSE, "closeApp")
   GUISetFont ( 12 )
   ;$WS_VSCROLL
   GUISetState(@SW_SHOW, $hGUI)
EndFunc

createGui($win_w,$win_h);


local $aVscodeCtrls = []
local $aOpenDirCtrls = []

Func resetArray(ByRef $arr)
   For $i In $arr
	  If $i Then
		 If IsNumber($i) Then
			GUICtrlDelete($i)
		 EndIf
		 _ArrayDelete($arr, $i)
	  EndIf
   Next
EndFunc
Func reload()
   resetArray($aVscodeCtrls)
   resetArray($aOpenDirCtrls)
   Example()
EndFunc

local $vscodeButtonBandle = GUICtrlCreateButton ( " 重新加载 ", 10, 4)
GUICtrlSetOnEvent(-1, "reload")
local $nodeVersion = createLabel("node:" & getVersionByOrder("node -v"),120,8)
local $npmVersion = createLabel("npm:" & getVersionByOrder("npm -v"),280,8)
local $ipv4 = createLabel("ipv4:" & @IPAddress1,440,8)
GUICtrlSetOnEvent(-1, "copyIpv4")

Example()

While 1
   Sleep(100) ; Sleep to reduce CPU usage
WEnd

;运行vscode
Func RunVsCode($dir)
   Run(@ComSpec & ' /c ' & "code " & $dir, @ScriptDir, @SW_HIDE)
EndFunc
;打开文件夹
Func RunOpenDir($dir)
   _rundos('start ' & $dir)
EndFunc
;事件处理中间函数 $ctrls 是数组，存放着按钮的ctrlId列表，$event_ctrlId是当前点击事件的ctrlId, $fn要调用的函数
Func eventMiddleware(ByRef $ctrls, $event_ctrlId, $fn)
   Local $ctrlId;
   For $arr In $ctrls
	  If $ctrlId Then
		 $fn($arr)
		 ;MsgBox(0,"title",$arr & "|" & @GUI_CtrlId)
		 ExitLoop
	  EndIf


	  If $arr = $event_ctrlId Then
		 $ctrlId = $event_ctrlId
	  EndIf
   Next
EndFunc

;code 打开 事件
Func vscodeButtonBandle()
   eventMiddleware($aVscodeCtrls, @GUI_CtrlId, RunVsCode)
EndFunc
;打开文件夹 事件
Func openDirHandle()
   eventMiddleware($aOpenDirCtrls, @GUI_CtrlId, RunOpenDir)
EndFunc

Func Example()
    ; Assign a Local variable the search handle of all files in the current directory.
    Local $hSearch = FileFindFirstFile($base_path & "*")
    ; Check if the search was successful, if not display a message and return False.
    If $hSearch = -1 Then
        MsgBox($MB_SYSTEMMODAL, "", "Error: No files/directories matched the search pattern.")
        Return False
    EndIf

    ; Assign a Local variable the empty string which will contain the files names found.
    Local $sFileName = "", $iResult = 0

	local $y = 1;
	local $rowHeight = 35 ;一行的高度

    While 1
        $sFileName = FileFindNextFile($hSearch)
        ; If there is no more file matching the search.
        If @error Then ExitLoop

		Local $absolutePath = $base_path & $sFileName


        Local $top = $rowHeight * $y
		local $lintMarginLeft = 10; ;左边距
		;画分隔线
		Local $line = GUICtrlCreateGraphic($lintMarginLeft, $top, $win_w - ($lintMarginLeft * 2), 1)
	    GUICtrlSetColor(-1, 0) ;设置分隔线的颜色

		;显示文件目录
		Local $dir = GUICtrlCreateLabel($sFileName, $lintMarginLeft, $top + 8)
		GUICtrlSetTip(-1, $absolutePath)
		;创建code按钮
        local $vscodeButtonBandle = GUICtrlCreateButton ( "open in vscode", 300, $top + 4)
		GUICtrlSetTip(-1, "在vscode 中打开")
		GUICtrlSetOnEvent(-1, "vscodeButtonBandle")
		local $temp[4] = [$vscodeButtonBandle, $absolutePath, $dir, $line]
		 _ArrayAdd($aVscodeCtrls,$temp)
		;创建 打开文件夹按钮
		local $openDirHandle = GUICtrlCreateButton ( "打开文件夹", 430, $top + 4)
		GUICtrlSetTip(-1, "打开这个文件夹")
		GUICtrlSetOnEvent(-1, "openDirHandle")
		local $temp[2] = [$openDirHandle, $absolutePath]
		 _ArrayAdd($aOpenDirCtrls,$temp)



		$y += 1;
		Sleep(60)
        ; Display the file name.
        ;$iResult = MsgBox(BitOR($MB_SYSTEMMODAL, $MB_OKCANCEL), "", "File: " & $sFileName)
        ;If $iResult <> $IDOK Then ExitLoop ; If the user clicks on the cancel/close button.
    WEnd

    ; Close the search handle.
    FileClose($hSearch)
 EndFunc   ;==>Example


Func getVersionByOrder($order)
   Local $v = Run(@ComSpec & ' /c ' & $order,"", @SW_HIDE, $STDOUT_CHILD)
   Local $sDat = ''
   While 1
	  $sDat1 = StdoutRead($v,false,true)
	  If @error Then
		 ProcessWaitClose($v)
		 ExitLoop
	  EndIf
	  $sDat &= BinaryToString($sDat1,1)
   WEnd
   return StringTrimRight(StringStripCR($sDat), StringLen(@CRLF) - 1)
EndFunc

Func createLabel($text = "label",$left = 0,$top = 0)
   return GUICtrlCreateLabel($text, $left ,$top)
EndFunc

Func copyIpv4()
   Local $aArray = StringSplit(GUICtrlRead(@GUI_CtrlId), ":")
   _ClipBoard_SetData($aArray[2])
   MsgBox(0,'ipv4复制成功', $aArray[2], 1.5)
EndFunc