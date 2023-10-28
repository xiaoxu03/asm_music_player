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


.data
szWindowClass db "MusicPlayer",0
szTitle db "���ֲ�����v1.0",0
AppName db "���ֲ�����v1.0", 0
szTextFileName db "�ļ���",0
szTextFileSize db "�ļ���С",0

fontname db 'Arial', 0
text_button db "button", 0
text_play db "��ʼ����", 0
text_stop db "ֹͣ����", 0
text_pause db "��ͣ����", 0
text_resume db "���¿�ʼ", 0
text_repeat db "����ѭ��", 0
text_edit db "�༭",0
text_opendir db "��Ŀ¼", 0
text_browse_folder db "Browse folder", 0
text_listbox db "listbox", 0
text_showtext db "�ļ��б�",0


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
PROGRESSCLASS db "msctls_progress32",0

; �ؼ���ȫ��ID
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

.data?
hInstance HINSTANCE ?
CommandLine LPSTR ? 

; �ؼ���Handle
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



.code
start:
    ;��ȡhinstance��commandline
	invoke GetModuleHandle, NULL
	mov hInstance, eax
	invoke GetCommandLine
	mov CommandLine, eax
	invoke WinMain, hInstance, NULL, CommandLine, SW_SHOWDEFAULT
	invoke ExitProcess, eax
    ;ע�ᴰ��ͨ���﷨
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

	    ; ����Ϣѭ��
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
    

    ;�����ؼ�
    CreateWindowControl proc uses eax hWnd:HWND
        ;��������
	    invoke CreateFont, 12 , 0, 0, 0, FW_NORMAL,
		    FALSE, FALSE, FALSE, DEFAULT_CHARSET,
		    OUT_CHARACTER_PRECIS,CLIP_CHARACTER_PRECIS,
		    DEFAULT_QUALITY,FF_DONTCARE,
		    offset fontname
	    mov hFont, eax
        ;�����̶��ı���
        invoke CreateWindowEx, 0, offset text_static, offset text_showtext,
		    WS_CHILD or WS_VISIBLE or SS_LEFT,
		    0, 0, 0, 0,
		    hWnd, IDC_TEXT, hInstance, NULL
	    mov hText, eax
	    invoke SendMessage, hText, WM_SETFONT, hFont, NULL
        
        ;����listbox
        invoke CreateWindowEx, WS_EX_CLIENTEDGE, offset text_listbox, NULL,
              WS_CHILD or WS_VISIBLE or LBS_STANDARD,
              0, 0, 0, 0,
              hWnd, IDC_LISTBOX, hInstance, NULL
        mov hListBox, eax
        invoke SendMessage, hListBox, WM_SETFONT, hFont, NULL

        ;����������
        invoke CreateWindowEx, 0,offset PROGRESSCLASS, NULL,
              WS_CHILD or WS_VISIBLE,
              0, 0, 0, 0,
              hWnd, IDC_PROGRESSBAR, hInstance, NULL
        mov hProgressBar, eax
        invoke SendMessage, hProgressBar, WM_SETFONT, hFont, NULL

        ;������ǰʱ���ı���
        invoke CreateWindowEx, 0, offset text_static, offset text_0000,
              WS_CHILD or WS_VISIBLE or SS_RIGHT,
              0, 0, 0, 0,
              hWnd, IDC_CURRENTTIME, hInstance, NULL
        mov hCurrentTime, eax
        invoke SendMessage, hCurrentTime, WM_SETFONT, hFont, NULL

        ;������ʱ���ı���
        invoke CreateWindowEx, 0, offset text_static, offset text_0000,
              WS_CHILD or WS_VISIBLE or SS_LEFT,
              0, 0, 0, 0,
              hWnd, IDC_TOTALTIME, hInstance, NULL
        mov hTotalTime, eax
        invoke SendMessage, hTotalTime, WM_SETFONT, hFont, NULL

        ;��������Ŀ¼��ť
        invoke CreateWindowEx, 0, offset text_button, offset text_opendir,
              WS_CHILD or WS_VISIBLE or BS_PUSHBUTTON,
              0, 0, 0, 0,
              hWnd, IDC_FILESELECTBTN, hInstance, NULL
        mov hFileSelectBtn, eax
        invoke SendMessage, hFileSelectBtn, WM_SETFONT, hFont, NULL

        ;�������Ű�ť
        invoke CreateWindowEx, 0, offset text_button, offset text_play,
              WS_CHILD or WS_VISIBLE or BS_PUSHBUTTON,
              0, 0, 0, 0,
              hWnd, IDC_PLAYBTN, hInstance, NULL
        mov hPlayBtn, eax
        invoke SendMessage, hPlayBtn, WM_SETFONT, hFont, NULL

        ;������ͣ��ť
        invoke CreateWindowEx, 0, offset text_button, offset text_pause,
              WS_CHILD or WS_VISIBLE or BS_PUSHBUTTON,
              0, 0, 0, 0,
              hWnd, IDC_PAUSEBTN, hInstance, NULL
        mov hPauseBtn, eax
        invoke SendMessage, hPauseBtn, WM_SETFONT, hFont, NULL

        ;����ֹͣ��ť
        invoke CreateWindowEx, 0, offset text_button, offset text_stop,
              WS_CHILD or WS_VISIBLE or BS_PUSHBUTTON,
              0, 0, 0, 0,
              hWnd, IDC_STOPBTN, hInstance, NULL
        mov hStopBtn, eax
        invoke SendMessage, hStopBtn, WM_SETFONT, hFont, NULL

        ;��������ѭ����ѡ��
        invoke CreateWindowEx, 0, offset text_button, offset text_repeat,
              WS_CHILD or WS_VISIBLE or BS_AUTOCHECKBOX,
              0, 0, 0, 0,
              hWnd, IDC_REPEATE, hInstance, NULL
        mov hRepeate, eax
        invoke SendMessage, hRepeate, WM_SETFONT, hFont, NULL

        ret
    CreateWindowControl endp


    ; �����ؼ�λ��
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
         ;��ȡ���ڴ�С
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
         ;�����ı���λ�� 
         mov eax,rc.top
         mov temtop,eax
         add temtop,10
         mov eax,rc.left
         mov temleft,eax
         add temleft,20
         invoke MoveWindow, hText,temleft,temtop, 45,15, TRUE
         ;�����б��λ�� 
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
         ;����������λ�� 
         mov eax,rc.bottom
         mov temtop,eax
         sub temtop,70
         mov eax,rc.left
         mov temleft,eax
         add temleft,80
         mov eax,current_width
         mov temwidth,eax
         sub temwidth,160
         invoke MoveWindow, hProgressBar, temleft,temtop, temwidth, 15, TRUE 
         ;������ǰʱ���ı���λ�� 
         mov eax,rc.bottom
         mov temtop,eax
         sub temtop,70
         mov eax,rc.left
         mov temleft,eax
         add temleft,20
         invoke MoveWindow, hCurrentTime,temleft,temtop, 55, 15, TRUE  
         ;������ʱ���ı���λ�� 
         mov eax,rc.bottom
         mov temtop,eax
         sub temtop,70
         mov eax,rc.right
         mov temleft,eax
         sub temleft,75
         invoke MoveWindow, hTotalTime,temleft,temtop, 55, 15, TRUE 
         ;��������Ŀ¼��ťλ�� 
         mov eax,rc.bottom
         mov temtop,eax
         sub temtop,40
         mov eax,middle
         mov temleft,eax
         sub temleft,180
         invoke MoveWindow, hFileSelectBtn,temleft,temtop, 60, 30, TRUE 
         ;�������Ű�ťλ�� 
         mov eax,rc.bottom
         mov temtop,eax
         sub temtop,40
         mov eax,middle
         mov temleft,eax
         sub temleft,100
         invoke MoveWindow, hPlayBtn, temleft,temtop, 60, 30, TRUE 
         ;������ͣ��ťλ�� 
         mov eax,rc.bottom
         mov temtop,eax
         sub temtop,40
         mov eax,middle
         mov temleft,eax
         sub temleft,20
         invoke MoveWindow, hPauseBtn,temleft, temtop, 60, 30, TRUE 
         ;����ֹͣ��ťλ�� 
         mov eax,rc.bottom
         mov temtop,eax
         sub temtop,40
         mov eax,middle
         mov temleft,eax
         add temleft,60
         invoke MoveWindow, hStopBtn, temleft,temtop, 60, 30, TRUE 
         ;��������ѭ����ѡ��λ�� 
         mov eax,rc.bottom
         mov temtop,eax
         sub temtop,40
         mov eax,middle
         mov temleft,eax
         add temleft,140
         invoke MoveWindow, hRepeate, temleft,temtop, 60, 30, TRUE
         ret
    ReSizeWindowControl endp


    ;���ڲ���
    WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM 
        .if uMsg == WM_DESTROY
		    invoke PostQuitMessage,NULL
        ;�����ؼ�
        .elseif uMsg == WM_CREATE
		    invoke InitCommonControls
		    invoke CreateWindowControl, hWnd
        ; ���ڱ仯��С
	    .elseif uMsg == WM_SIZE
		    invoke ReSizeWindowControl, hWnd
	    .else
		    invoke DefWindowProc, hWnd, uMsg, wParam, lParam 
	    .endif
        ret 
    WndProc endp
    end start
