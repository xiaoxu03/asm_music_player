.386

.model flat,stdcall
option casemap:none
.stack 4096

;     include files
include windows.inc
include masm32.inc
include gdi32.inc
include user32.inc
include kernel32.inc
include Comctl32.inc
include comdlg32.inc
include shell32.inc
include oleaut32.inc
include msvcrt.inc
include winmm.inc
include shfolder.inc
include dnslib.inc

;     libraries
includelib masm32.lib
includelib gdi32.lib
includelib user32.lib
includelib kernel32.lib
includelib Comctl32.lib
includelib comdlg32.lib
includelib shell32.lib
includelib oleaut32.lib
includelib msvcrt.lib
includelib winmm.lib

WinMain proto:DWORD, :DWORD, :DWORD, :DWORD
InitInstance proto:HINSTANCE,:DWORD
SelectPlay proto


.data
play_status dword 0
load_status dword 0

NLOADED dword 0
LOADED dword 1

STOP dword 0
PLAY dword 1
PAUSER dword 2;pause在visual studio下不能识别

duration dword 100
position dword 0
new_time dword 0
total_length dword 0

szWindowClass db "MusicPlayer",0
szTitle db "音乐播放器v1.0",0
AppName db "音乐播放器v1.0", 0
szTextFileName db "文件名",0
szTextFileSize db "文件大小",0

fontname db 'Arial', 0
text_button db "button", 0
text_play db "开始播放", 0
text_stop db "停止播放", 0
text_pause db "暂停播放", 0
text_resume db "继续播放", 0
text_nrepeat db "单曲播放", 0
text_repeat db "单曲循环", 0
text_repeatlist db "列表循环", 0
text_repeatrand db "随机循环", 0
text_edit db "编辑",0
text_opendir db "打开目录", 0
text_browse_folder db "Browse folder", 0
text_listbox db "listbox", 0
text_showtext db "文件列表",0
text_filename db "未播放文件",0

sz_path db 1024 dup(0)
sz_selected db 1024 dup(0)
index_selected dword 0
sz_music db 1024 dup(0)

play_position db 128 dup(0)
play_length db 128 dup(0)

play_current 	db 128 dup(0)
play_total 		db 128 dup(0)

cmd_open db "open", 0
cmd_play db "play music", 0
cmd_alias db "alias", 0
cmd_music db "music", 0
cmd_pause db "pause music", 0
cmd_resume db "resume music", 0
cmd_stop db "close music", 0
cmd_position db "status music position", 0
cmd_length db "status music length", 0
cmd_mode db "status music mode", 0
cmd_seek db "seek music to start", 0
seek_format db "seek music to %d",0

cmd db 1024 dup(0)

find_dir_fmt db '%', 0, 's', 0, '\', 0, '*',0, 0, 0
; "%s\\*"
handle_play_fmt db 'C', 0, 'o', 0, 'u', 0, 'n', 0, 't', 0, '=', 0, '%', 0, 'd', 0, ' ', 0, 'M', 0, 'a', 0, 'r', 0, 'k', 0, '=', 0, '%', 0, 'd', 0, 0, 0
;"Count=%d Mark=%d"
s_fmt db '%',0,'s',0, 0, 0 
;"%s"
d_fmt db '%', 0, 'd', 0, 0, 0
;"%d"
noneplay_fmt db '%', 0, '.', 0, '2', 0, 'd', 0, ':', 0, '%', 0, '.', 0, '2', 0, 'd', 0, 0, 0 
;"%.2d:%.2d"
startplay_fmt db '%', 0, 's', 0, '\', 0, '%', 0, 's', 0, 0, 0
;"%s\\%s"
stopplay_fmt db '00:00', 0
;"00:00"
text_static db "static",0
text_0000 db "00:00",0
;PROGRESSCLASS db "msctls_progress32",0
TRACKBAR_CLASS db "msctls_trackbar32",0

lpsz_title db "请选择文件夹", 0

error db "错误！", 0
err_folder db "请打开目录文件夹", 0

; 控件的全局ID
IDC_TEXT HMENU 206
IDC_LISTBOX HMENU 207
IDC_PROGRESSBAR HMENU 208
IDC_CURRENTTIME HMENU 209
IDC_TOTALTIME HMENU 210
IDC_PLAYBTN HMENU 211
IDC_FILESELECTBTN HMENU 212
IDC_PAUSEBTN HMENU 213
IDC_STOPBTN HMENU 214
IDC_REPEATE HMENU 215
IDC_REPEATELIST HMENU 216
IDC_NREPEATE HMENU 217
IDC_REPEATERAND HMENU 218
IDC_FILENAME HMENU 219


.data?
hInstance HINSTANCE ?
CommandLine LPSTR ? 

; 控件的Handle
hFont HFONT ?
hText HWND ?
hListBox HWND ?
hProgressBar HWND ?
hCurrentTime HWND ?
hTotalTime HWND ?
hPlayBtn HWND ?
hFileSelectBtn HWND ?
hPauseBtn HWND ?
hStopBtn HWND ?
hRepeate HWND ?
hRepeateList HWND ?
hNRepeate HWND ?
hRepeateRand HWND ?
hFileName HWND ?




.code
start:
    ;获取hinstance和commandline
	invoke GetModuleHandle, NULL
	mov hInstance, eax
	invoke GetCommandLine
	mov CommandLine, eax
	invoke WinMain, hInstance, NULL, CommandLine, SW_SHOWDEFAULT
	invoke ExitProcess, eax
    ;注册窗口通用语法
    MyRegisterClass proc hInst:HINSTANCE
	    LOCAL wcex: WNDCLASSEXW
	    mov wcex.cbSize, sizeof WNDCLASSEX
	    mov wcex.style, CS_HREDRAW or CS_VREDRAW
	    mov wcex.lpfnWndProc, OFFSET WndProc 
	    mov wcex.cbClsExtra, NULL
	    mov wcex.cbWndExtra, NULL
	    push hInst
	    pop wcex.hInstance
	    mov wcex.hbrBackground, COLOR_WINDOW + 1
	    mov wcex.lpszMenuName, NULL
	    mov wcex.lpszClassName ,offset szWindowClass
	    invoke LoadIcon, NULL, IDI_APPLICATION
	    mov wcex.hIcon, eax
	    mov wcex.hIconSm, eax
	    invoke LoadCursor, NULL, IDC_ARROW
	    mov wcex.hCursor, eax
	    invoke RegisterClassEx, addr wcex
	    ret
    MyRegisterClass endp

    WinMain proc hInst:HINSTANCE, hPrevInst:HINSTANCE, CmdLine: LPSTR, CmdShow:DWORD
	    local msg :MSG


	    invoke MyRegisterClass, hInst
	    invoke InitInstance, hInst, CmdShow

	    ; 主消息循环
	    .while TRUE
		    invoke GetMessage, addr msg, NULL, 0, 0
		    .break .if (!eax)
		    invoke TranslateMessage, addr msg
		    invoke DispatchMessage, addr msg
	    .endw

	    mov eax, msg.wParam
	    ret

    WinMain endp



    InitInstance proc hInst: HINSTANCE, CmdShow :DWORD
	    local hwnd:HWND
	    invoke CreateWindowEx, NULL, addr szWindowClass, addr szTitle, 
		    WS_OVERLAPPEDWINDOW, CW_USEDEFAULT, CW_USEDEFAULT, 500, 600, 
		    NULL, NULL, hInst, NULL
	    mov hwnd, eax

	    .if (!eax)
		    ret
	    .endif
	
	    invoke ShowWindow, hwnd, SW_SHOWNORMAL
	    invoke UpdateWindow, hwnd

	    ret
    InitInstance endp 
    

    ;创建控件
    CreateWindowControl proc uses eax hWnd:HWND
        ;创建字体
	    invoke CreateFont, 12 , 0, 0, 0, FW_NORMAL,
		    FALSE, FALSE, FALSE, DEFAULT_CHARSET,
		    OUT_CHARACTER_PRECIS,CLIP_CHARACTER_PRECIS,
		    DEFAULT_QUALITY,FF_DONTCARE,
		    offset fontname
	    mov hFont, eax
        ;创建固定文本框
        invoke CreateWindowEx, 0, offset text_static, offset text_showtext,
		    WS_CHILD or WS_VISIBLE or SS_LEFT,
		    0, 0, 0, 0,
		    hWnd, IDC_TEXT, hInstance, NULL
	    mov hText, eax
	    invoke SendMessage, hText, WM_SETFONT, hFont, NULL
        
        ;创建listbox
        invoke CreateWindowEx, WS_EX_CLIENTEDGE, offset text_listbox, NULL,
              WS_CHILD or WS_VISIBLE or LBS_STANDARD,
              0, 0, 0, 0,
              hWnd, IDC_LISTBOX, hInstance, NULL
        mov hListBox, eax
        invoke SendMessage, hListBox, WM_SETFONT, hFont, NULL

		;创建当前文件文本框
        invoke CreateWindowEx, 0, offset text_static, offset text_filename,
              WS_CHILD or WS_VISIBLE or SS_CENTER,
              0, 0, 0, 0,
              hWnd, IDC_FILENAME, hInstance, NULL
        mov hFileName, eax
        invoke SendMessage, hFileName, WM_SETFONT, hFont, NULL

        ;创建进度条
        invoke CreateWindowEx, NULL, offset TRACKBAR_CLASS, NULL,
              WS_CHILD or WS_VISIBLE or TBS_NOTICKS or TBS_BOTH,
              0, 0, 0, 0,
              hWnd, IDC_PROGRESSBAR, hInstance, NULL
        mov hProgressBar, eax
        invoke SendMessage, hProgressBar, WM_SETFONT, hFont, NULL
		; 设置滑块控件的范围为 0 到 100
		mov eax, 100
		shl eax, 16
		invoke SendMessage, hProgressBar, TBM_SETRANGE, TRUE, eax
        ;创建当前时间文本框
        invoke CreateWindowEx, 0, offset text_static, offset text_0000,
              WS_CHILD or WS_VISIBLE or SS_RIGHT,
              0, 0, 0, 0,
              hWnd, IDC_CURRENTTIME, hInstance, NULL
        mov hCurrentTime, eax
        invoke SendMessage, hCurrentTime, WM_SETFONT, hFont, NULL

        ;创建总时间文本框
        invoke CreateWindowEx, 0, offset text_static, offset text_0000,
              WS_CHILD or WS_VISIBLE or SS_LEFT,
              0, 0, 0, 0,
              hWnd, IDC_TOTALTIME, hInstance, NULL
        mov hTotalTime, eax
        invoke SendMessage, hTotalTime, WM_SETFONT, hFont, NULL

        ;创建打开新目录按钮
        invoke CreateWindowEx, 0, offset text_button, offset text_opendir,
              WS_CHILD or WS_VISIBLE or BS_PUSHBUTTON,
              0, 0, 0, 0,
              hWnd, IDC_FILESELECTBTN, hInstance, NULL
        mov hFileSelectBtn, eax
        invoke SendMessage, hFileSelectBtn, WM_SETFONT, hFont, NULL

        ;创建播放按钮
        invoke CreateWindowEx, 0, offset text_button, offset text_play,
              WS_CHILD or WS_VISIBLE or BS_PUSHBUTTON,
              0, 0, 0, 0,
              hWnd, IDC_PLAYBTN, hInstance, NULL
        mov hPlayBtn, eax
        invoke SendMessage, hPlayBtn, WM_SETFONT, hFont, NULL

        ;创建暂停按钮
        invoke CreateWindowEx, 0, offset text_button, offset text_pause,
              WS_CHILD or WS_VISIBLE or BS_PUSHBUTTON,
              0, 0, 0, 0,
              hWnd, IDC_PAUSEBTN, hInstance, NULL
        mov hPauseBtn, eax
        invoke SendMessage, hPauseBtn, WM_SETFONT, hFont, NULL

        ;创建停止按钮
        invoke CreateWindowEx, 0, offset text_button, offset text_stop,
              WS_CHILD or WS_VISIBLE or BS_PUSHBUTTON,
              0, 0, 0, 0,
              hWnd, IDC_STOPBTN, hInstance, NULL
        mov hStopBtn, eax
        invoke SendMessage, hStopBtn, WM_SETFONT, hFont, NULL

        ;创建单曲循环复选框
        ;invoke CreateWindowEx, 0, offset text_button, offset text_repeat,
        ;      WS_CHILD or WS_VISIBLE or BS_AUTOCHECKBOX,
        ;      0, 0, 0, 0,
        ;      hWnd, IDC_REPEATE, hInstance, NULL
        ;mov hRepeate, eax
        ;invoke SendMessage, hRepeate, WM_SETFONT, hFont, NULL

		;创建“单曲播放”复选框
		invoke CreateWindowEx, 0, offset text_button, offset text_nrepeat,
			WS_CHILD or WS_VISIBLE or BS_AUTORADIOBUTTON,
			0, 0, 0, 0,
			hWnd, IDC_NREPEATE, hInstance, NULL
		mov hNRepeate, eax
		invoke SendMessage, hNRepeate, BM_SETCHECK, BST_CHECKED, 0
		invoke SendMessage, hNRepeate, WM_SETFONT, hFont, NULL

		;创建“单曲循环”复选框
		invoke CreateWindowEx, 0, offset text_button, offset text_repeat,
			WS_CHILD or WS_VISIBLE or BS_AUTORADIOBUTTON,
			0, 0, 0, 0,
			hWnd, IDC_REPEATE, hInstance, NULL
		mov hRepeate, eax
		invoke SendMessage, hRepeate, BM_SETCHECK, BST_UNCHECKED, 0
		invoke SendMessage, hRepeate, WM_SETFONT, hFont, NULL

		;创建“列表循环”复选框
		invoke CreateWindowEx, 0, offset text_button, offset text_repeatlist,
			WS_CHILD or WS_VISIBLE or BS_AUTORADIOBUTTON,
			0, 0, 0, 0,
			hWnd, IDC_REPEATELIST, hInstance, NULL
		mov hRepeateList, eax
		invoke SendMessage, hRepeateList, BM_SETCHECK, BST_UNCHECKED, 0
		invoke SendMessage, hRepeateList, WM_SETFONT, hFont, NULL

		;创建“随机循环”复选框
		invoke CreateWindowEx, 0, offset text_button, offset text_repeatrand,
			WS_CHILD or WS_VISIBLE or BS_AUTORADIOBUTTON,
			0, 0, 0, 0,
			hWnd, IDC_REPEATERAND, hInstance, NULL
		mov hRepeateRand, eax
		invoke SendMessage, hRepeateRand, BM_SETCHECK, BST_UNCHECKED, 0
		invoke SendMessage, hRepeateRand, WM_SETFONT, hFont, NULL


        ret
    CreateWindowControl endp


    ; 调整控件位置
    ReSizeWindowControl proc uses eax ebx hWnd:HWND
         local rc:RECT
         local current_width:DWORD
	     local current_height:DWORD
         local playBtn_bottom:DWORD
         local middle:DWORD
         local temleft:DWORD
         local temwidth:DWORD
         local temheight:DWORD
         local temtop:DWORD
         ;获取窗口大小
         invoke GetClientRect, hWnd, addr rc 
         mov ebx, rc.right
	     sub ebx, rc.left
	     mov current_width, ebx
         mov ebx, rc.bottom
	     sub ebx, rc.top
	     mov current_height, ebx
         mov eax,current_width
         mov ebx,2
         mov edx,0
         div ebx
         mov middle,eax ;current_width/2
         mov eax, 0 
         ;调整文本框位置 
         mov eax,rc.top
         mov temtop,eax
         add temtop,10
         mov eax,rc.left
         mov temleft,eax
         add temleft,20
         invoke MoveWindow, hText,temleft,temtop, 45,15, TRUE
         ;调整列表框位置 
         mov eax,rc.top
         mov temtop,eax
         add temtop,30
         mov eax,rc.left
         mov temleft,eax
         add temleft,20
         mov eax,current_width
         mov temwidth,eax
         sub temwidth,40
         mov eax,current_height
         mov temheight,eax
         sub temheight,250
         invoke MoveWindow, hListBox,temleft,temtop, temwidth,temheight, TRUE 
		 ;调整当前文件文本框位置
		 mov eax,rc.bottom
         mov temtop,eax
         sub temtop,150
         mov eax,rc.left
         mov temleft,eax
         add temleft,120
         mov eax,current_width
         mov temwidth,eax
         sub temwidth,240
         invoke MoveWindow, hFileName, temleft,temtop, temwidth, 15, TRUE 
         ;调整进度条位置 
         mov eax,rc.bottom
         mov temtop,eax
         sub temtop,100
         mov eax,rc.left
         mov temleft,eax
         add temleft,80
         mov eax,current_width
         mov temwidth,eax
         sub temwidth,160
         invoke MoveWindow, hProgressBar, temleft,temtop, temwidth, 15, TRUE 
         ;调整当前时间文本框位置 
         mov eax,rc.bottom
         mov temtop,eax
         sub temtop,100
         mov eax,rc.left
         mov temleft,eax
         add temleft,20
         invoke MoveWindow, hCurrentTime,temleft,temtop, 55, 15, TRUE  
         ;调整总时间文本框位置 
         mov eax,rc.bottom
         mov temtop,eax
         sub temtop,100
         mov eax,rc.right
         mov temleft,eax
         sub temleft,75
         invoke MoveWindow, hTotalTime,temleft,temtop, 55, 15, TRUE 
         ;调整打开新目录按钮位置 
         mov eax,rc.bottom
         mov temtop,eax
         sub temtop,55
         mov eax,middle
         mov temleft,eax
         sub temleft,180
         invoke MoveWindow, hFileSelectBtn,temleft,temtop, 60, 30, TRUE 
         ;调整播放按钮位置 
         mov eax,rc.bottom
         mov temtop,eax
         sub temtop,55
         mov eax,middle
         mov temleft,eax
         sub temleft,100
         invoke MoveWindow, hPlayBtn, temleft,temtop, 60, 30, TRUE 
         ;调整暂停按钮位置 
         mov eax,rc.bottom
         mov temtop,eax
         sub temtop,55
         mov eax,middle
         mov temleft,eax
         sub temleft,20
         invoke MoveWindow, hPauseBtn,temleft, temtop, 60, 30, TRUE 
         ;调整停止按钮位置 
         mov eax,rc.bottom
         mov temtop,eax
         sub temtop,55
         mov eax,middle
         mov temleft,eax
         add temleft,60
         invoke MoveWindow, hStopBtn, temleft,temtop, 60, 30, TRUE 
		 ;调整单曲播放复选框位置 
         mov eax,rc.bottom
         mov temtop,eax
         sub temtop,70
         mov eax,middle
         mov temleft,eax
         add temleft,140
         invoke MoveWindow, hNRepeate, temleft,temtop, 60, 15, TRUE
		 ;调整单曲循环复选框位置 
         mov eax,rc.bottom
         mov temtop,eax
         sub temtop,55
         mov eax,middle
         mov temleft,eax
         add temleft,140
         invoke MoveWindow, hRepeate, temleft,temtop, 60, 15, TRUE
		 ;调整列表循环复选框位置 
         mov eax,rc.bottom
         mov temtop,eax
         sub temtop,40
         mov eax,middle
         mov temleft,eax
         add temleft,140
         invoke MoveWindow, hRepeateList, temleft,temtop, 60, 15, TRUE
         ;调整随机循环复选框位置 
         mov eax,rc.bottom
         mov temtop,eax
         sub temtop,25
         mov eax,middle
         mov temleft,eax
         add temleft,140
         invoke MoveWindow, hRepeateRand, temleft,temtop, 60, 15, TRUE
         ret

    ReSizeWindowControl endp


	random32	proc	random_seed:DWORD,max_val:DWORD 
				push	ecx
				push	edx
				call	GetTickCount
				mov		ecx,random_seed
				add		eax,ecx 
				rol		ecx,1
				add		ecx,666h 
				mov		random_seed,ecx 

				push	32 
				pop		ecx 

	crc_bit:	shr		eax,1
				jnc		loop_crc_bit 
				xor		eax,0edb88320h

	loop_crc_bit:	loop	crc_bit
				mov		ecx,max_val
				xor		edx,edx
				div		ecx
				xchg	edx,eax
				or		eax,eax
				pop		edx
				pop		ecx
				ret		0008H
	random32	Endp 


; 定时更新进度条函数
FlashProc PROC hWnd:HWND, uMsg:UINT, idEvent:DWORD, dwTime:DWORD
    	; 在这里执行定时器触发时的操作
   	invoke mciSendString, addr cmd_position, addr play_position, 128, 0
    invoke atol, addr play_position
		; 设置滑块控件的位置
   	push eax
		;movzx eax,play_position
		mov ebx,total_length
		mov edx,100
		mul edx ; 将播放位置乘以 100
		div ebx ; 将结果除以总长度
		invoke SendMessage, hProgressBar, TBM_SETPOS, TRUE, eax
   	pop eax
    	mov edx, 0
  	mov ebx, 1000
   	div ebx
   	mov edx, 0
    	mov ebx, 60
    	div ebx
	push edx
	invoke ltoa, eax, addr play_current
	pop edx
	.if eax < 10
		mov ebx, offset play_current
		mov cl, 58
		inc ebx
		mov [ebx], cl
		inc ebx
		invoke ltoa, edx, ebx
	.else 
		mov ebx, offset play_current
		mov cl, 58
		inc ebx
		mov [ebx], cl
		inc ebx
		invoke ltoa, edx, ebx
	.endif
	invoke SetWindowText, hCurrentTime, addr play_current

	invoke SendMessage, hNRepeate, BM_GETCHECK, 0, 0
	.if eax == TRUE
		invoke atol, addr play_position
		push eax
		invoke atol, addr play_length
		mov ebx, eax
		pop eax
		.if eax == ebx
			mov ebx, play_status
			invoke SetWindowText, hFileName, addr text_filename
			; 正在播放的情况下，直接停止
			.if ebx == PLAY
				invoke mciSendString, addr cmd_stop, 0, 0, 0
				mov edx, STOP
				mov play_status, edx
			.elseif ebx == PAUSER
				invoke mciSendString, addr cmd_stop, 0, 0, 0
				invoke SetWindowText, hPauseBtn, addr text_pause
				mov edx, STOP
				mov play_status, edx
			.endif
		.endif
	.endif
	invoke SendMessage, hRepeate, BM_GETCHECK, 0, 0
	.if eax == TRUE
		invoke atol, addr play_position
		push eax
		invoke atol, addr play_length
		mov ebx, eax
		pop eax
		.if eax == ebx
			invoke mciSendString, addr cmd_seek, 0, 0, 0
			invoke mciSendString, addr cmd_play, 0, 0, 0
		.endif
	.endif
	invoke SendMessage, hRepeateList, BM_GETCHECK, 0, 0
	.if eax == TRUE
		invoke atol, addr play_position
		push eax
		invoke atol, addr play_length
		mov ebx, eax
		pop eax
		.if eax == ebx
			; 获取当前选中项的索引
			mov eax,index_selected
			; 增加索引
			inc eax
			push eax
			; 获取列表框的项数
			invoke SendMessage, hListBox, LB_GETCOUNT, 0, 0
			mov edx,eax
			pop eax
			; 如果新的索引大于等于项数，将索引重置为 0
			cmp eax, edx
			jge reset_index
			jmp get_next_item
		reset_index:
			mov eax, 0
		get_next_item:
			; 使用新的索引获取下一项的文本
			mov index_selected,eax
			invoke SendMessage, hListBox, LB_GETTEXT, eax, addr sz_selected
			invoke SelectPlay
			ret
		.endif
	.endif
	invoke SendMessage, hRepeateRand, BM_GETCHECK, 0, 0
	.if eax == TRUE
		invoke atol, addr play_position
		push eax
		invoke atol, addr play_length
		mov ebx, eax
		pop eax
		.if eax == ebx
			; 获取当前选中项的索引
			mov eax,index_selected
			; 获取列表框的项数
			push eax
			invoke SendMessage, hListBox, LB_GETCOUNT, 0, 0
			mov ecx, eax
			pop eax
			; 检查列表框的项数是否为 1
			cmp ecx, 1
			je single_item
			jmp generate_random_index
		single_item:
			; 使用索引 0 获取该项的文本
			mov eax, 0
			mov index_selected,eax
			invoke SendMessage, hListBox, LB_GETTEXT, eax, addr sz_selected
			invoke SelectPlay
			ret
		generate_random_index:
			; 获取当前的系统时间
			invoke GetTickCount
			; 调用 rand 函数生成一个随机数
			invoke random32,eax,ecx
			; 检查新的索引是否等于当前选中项的索引
			cmp eax, index_selected
			je generate_random_index
			; 使用新的索引获取下一项的文本
			mov index_selected,eax
			invoke SendMessage, hListBox, LB_GETTEXT, eax, addr sz_selected
			invoke SelectPlay
			ret
		.endif
	.endif
    ret
FlashProc ENDP

SelectPlay PROC
			mov eax, offset sz_path
			mov ebx, offset sz_music
			mov cl, [eax]
			.while cl != 42
				mov [ebx], cl
				inc eax
				inc ebx
				mov cl, [eax]
			.endw
			mov eax, offset sz_selected
			mov cl, [eax]
			.while cl != 0
				mov [ebx], cl
				inc eax
				inc ebx
				mov cl, [eax]
			.endw
			mov [ebx], cl
			
			
		play:
			mov eax, play_status
			.if eax != STOP
				invoke mciSendString, addr cmd_stop, 0, 0, 0
				invoke SetWindowText, hPauseBtn, addr text_pause
				mov edx, STOP
				mov play_status, edx
			.endif
			mov eax, offset cmd
			mov ebx, offset cmd_open
			
			mov cl, [ebx]
			.while cl != 0
				mov [eax], cl
				inc eax
				inc ebx
				mov cl, [ebx]
			.endw
			
			mov dl, 32
			mov [eax], dl
			inc eax
			
			mov ebx, offset sz_music
			mov cl, [ebx]
			.while cl != 0
				mov [eax], cl
				inc eax
				inc ebx
				mov cl, [ebx]
			.endw
			
			mov dl, 32
			mov [eax], dl
			inc eax
			
			mov ebx, offset cmd_alias
			mov cl, [ebx]
			.while cl != 0
				mov [eax], cl
				inc eax
				inc ebx
				mov cl, [ebx]
			.endw
			
			mov dl, 32
			mov [eax], dl
			inc eax
			
			mov ebx, offset cmd_music
			mov cl, [ebx]
			.while cl != 0
				mov [eax], cl
				inc eax
				inc ebx
				mov cl, [ebx]
			.endw
			
			mov dl, 0
			mov [eax], dl
			
			invoke mciSendString, addr cmd, 0, 0, 0
			invoke mciSendString, addr cmd_play, 0, 0, 0
			mov ebx, PLAY
			mov play_status, ebx
			invoke mciSendString, addr cmd_length, addr play_length, 128, 0
			
			invoke atol, addr play_length
			mov total_length, eax
			push eax
			pop eax
			mov edx, 0
			mov ebx, 1000
			div ebx
			mov edx, 0
			mov ebx, 60
			div ebx
			push edx
			invoke ltoa, eax, addr play_total
			pop edx
			.if eax < 10
				mov ebx, offset play_total
				mov cl, 58
				inc ebx
				mov [ebx], cl
				inc ebx
				invoke ltoa, edx, ebx
			.else 
				mov ebx, offset play_total
				mov cl, 58
				inc ebx
				mov [ebx], cl
				inc ebx
				invoke ltoa, edx, ebx
			.endif
			invoke SetWindowText, hTotalTime, addr play_total
			invoke SetWindowText, hFileName, addr sz_selected
			invoke SetTimer, NULL, 0, 500, FlashProc
SelectPlay ENDP



    ;窗口操作
WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM 
   	 LOCAL bi: BROWSEINFO
   	 LOCAL find_data: WIN32_FIND_DATA 
   	 LOCAL hFind: HWND
        .if uMsg == WM_DESTROY
		invoke PostQuitMessage,NULL
        ;创建控件
        .elseif uMsg == WM_CREATE
		invoke InitCommonControls
		invoke CreateWindowControl, hWnd
        ; 窗口变化大小
	.elseif uMsg == WM_SIZE
		invoke ReSizeWindowControl, hWnd
	.elseif uMsg == WM_HSCROLL
		invoke GetDlgCtrlID, lParam
    	.if eax == IDC_PROGRESSBAR
			; 暂停音乐播放
			invoke mciSendString, addr cmd_pause, 0, 0, 0
			invoke SetWindowText, hPauseBtn, addr text_resume
			mov edx, PAUSER
			mov play_status, edx

            ; 获取进度条的新位置
            invoke SendMessage, hProgressBar, TBM_GETPOS, 0, 0
            ; 将进度条的位置转换为音乐的播放时间
            ; 这里假设进度条的范围是 0 到 100，音乐的长度是 total_length
            imul eax, total_length
            xor edx, edx
			mov ecx, 100
			idiv ecx
            mov new_time, eax
            ; 构造 seek 命令
            invoke wsprintf, addr cmd_seek, addr seek_format, new_time
			invoke mciSendString, addr cmd_resume, 0, 0, 0
			invoke SetWindowText, hPauseBtn, addr text_pause
				mov edx, PLAY
				mov play_status, edx
            ; 将音乐的播放位置设置为新的时间
            invoke mciSendString, addr cmd_seek, 0, 0, 0
            ; 继续播放音乐
            invoke mciSendString, addr cmd_play, 0, 0, 0
		.endif
	.elseif uMsg == WM_COMMAND
	   	mov eax, wParam
	   	.if eax == IDC_FILESELECTBTN
	   		invoke SendMessage, hListBox, LB_RESETCONTENT, 0, 0
	   		; 选择文件夹窗口创建配置
		    	mov bi.hwndOwner, NULL
		    	mov bi.ulFlags, BIF_EDITBOX
		    	mov bi.lpszTitle, offset lpsz_title
		    	mov bi.pszDisplayName, offset sz_path
		    	mov bi.pidlRoot, NULL
		    	mov bi.lpfn, NULL
		    	mov bi.lParam, 0
		    	mov bi.iImage, NULL
		    	invoke SHBrowseForFolder, addr bi
		    	.if eax
		    		invoke SHGetPathFromIDList, eax, addr sz_path
		    		
		    		mov ebx, offset sz_path
		    		.while ebx
		    			mov cl, [ebx]
		    			.if cl == 0
		    				jmp outside
		    			.endif
		    			inc ebx
				.endw
				
			outside:
				mov cl, 92
				mov [ebx], cl
				inc ebx
				mov cl, 42
				mov [ebx], cl
				inc ebx
				mov cl, 0
				mov [ebx], cl
				
		    		invoke FindFirstFile, addr sz_path, addr find_data
		    		.if eax == INVALID_HANDLE_VALUE
		    			je fail
		    		.endif
		    		mov hFind, eax
		    	show_name:
		    		lea eax, find_data.cFileName
		    		mov ebx, 0
		    		mov cl, [eax]
		    		.while cl != 0
		    			inc ebx
		    			inc eax
		    			mov cl, [eax]
		    		.endw
		    		.if ebx < 4
		    			invoke FindNextFile, hFind, addr find_data
		    			jmp show_name
		    		.endif
		    		invoke SendMessage, hListBox, LB_ADDSTRING, 0, addr find_data.cFileName
		    		invoke FindNextFile, hFind, addr find_data
		    		.if eax == FALSE
		    			mov ebx, LOADED
		    			mov load_status, ebx
		 			jmp fail
		    		.endif
		    		jmp show_name
		    	.else
		    		; 报错：非法路径
		    		
		    	.endif
		    	fail:
		
		    	
		.elseif eax == IDC_PLAYBTN
			mov ebx, load_status
			.if ebx != LOADED
				invoke MessageBox, hWnd, addr err_folder, addr error, NULL
				jmp err
			.endif
			invoke SendMessage, hListBox, LB_GETCURSEL, 0, 0
			mov index_selected,eax
			invoke SendMessage, hListBox, LB_GETTEXT, eax, addr sz_selected
			invoke SelectPlay
			
		.elseif eax == IDC_PAUSEBTN
			mov ebx, play_status
			.if ebx == PLAY
				invoke mciSendString, addr cmd_pause, 0, 0, 0
				invoke SetWindowText, hPauseBtn, addr text_resume
				mov edx, PAUSER
				mov play_status, edx
			.elseif ebx == PAUSER
				invoke mciSendString, addr cmd_resume, 0, 0, 0
				invoke SetWindowText, hPauseBtn, addr text_pause
				mov edx, PLAY
				mov play_status, edx
			.endif
		.elseif eax == IDC_STOPBTN
			mov ebx, play_status
			invoke SetWindowText, hFileName, addr text_filename
			; 正在播放的情况下，直接停止
			.if ebx == PLAY
				invoke mciSendString, addr cmd_stop, 0, 0, 0
				mov edx, STOP
				mov play_status, edx
			.elseif ebx == PAUSER
				invoke mciSendString, addr cmd_stop, 0, 0, 0
				invoke SetWindowText, hPauseBtn, addr text_pause
				mov edx, STOP
				mov play_status, edx
			.endif
	   	.endif
		.elseif eax == IDC_NREPEATE
			invoke SendMessage, hNRepeate, BM_SETCHECK, BST_CHECKED, 0
            invoke SendMessage, hRepeate, BM_SETCHECK, BST_UNCHECKED, 0
			invoke SendMessage, hRepeateList, BM_SETCHECK, BST_UNCHECKED, 0
			invoke SendMessage, hRepeateRand, BM_SETCHECK, BST_UNCHECKED, 0
		.elseif eax == IDC_REPEATE
			invoke SendMessage, hNRepeate, BM_SETCHECK, BST_UNCHECKED, 0
            invoke SendMessage, hRepeate, BM_SETCHECK, BST_CHECKED, 0
			invoke SendMessage, hRepeateList, BM_SETCHECK, BST_UNCHECKED, 0
			invoke SendMessage, hRepeateRand, BM_SETCHECK, BST_UNCHECKED, 0
		.elseif eax == IDC_REPEATELIST
			invoke SendMessage, hNRepeate, BM_SETCHECK, BST_UNCHECKED, 0
            invoke SendMessage, hRepeate, BM_SETCHECK, BST_UNCHECKED, 0
			invoke SendMessage, hRepeateList, BM_SETCHECK, BST_CHECKED, 0
			invoke SendMessage, hRepeateRand, BM_SETCHECK, BST_UNCHECKED, 0
		.elseif eax == IDC_REPEATERAND
			invoke SendMessage, hNRepeate, BM_SETCHECK, BST_UNCHECKED, 0
            invoke SendMessage, hRepeate, BM_SETCHECK, BST_UNCHECKED, 0
			invoke SendMessage, hRepeateList, BM_SETCHECK, BST_UNCHECKED, 0
			invoke SendMessage, hRepeateRand, BM_SETCHECK, BST_CHECKED, 0
	    .else
		    invoke DefWindowProc, hWnd, uMsg, wParam, lParam 
	    .endif
	    err:
        ret 
WndProc endp
end start