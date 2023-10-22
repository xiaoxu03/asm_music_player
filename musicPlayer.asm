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


.data
szWindowClass db "MusicPlayer",0
szTitle db "���ֲ�����v1.0",0
AppName db "���ֲ�����v1.0", 0
szTextFileName db "�ļ���",0
szTextFileSize db "�ļ���С",0

fontname db 'Consolas', 0
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
text_0000 db "00:00",0

; �ؼ���ȫ��ID
IDC_PLAYBTN HMENU 205
IDC_LISTVIEW HMENU 206
IDC_OPENDIRBTN HMENU 207
IDC_EDIT HMENU 208
IDC_CURRENTPLAYTIME HMENU 209
IDC_TOTALPLAYTIME HMENU 210
IDC_STOPBTN HMENU 211
IDC_PROGRESSBAR HMENU 212
IDC_LIST HMENU 213
IDC_REPEATE HMENU 214

.data?
hInstance HINSTANCE ?
CommandLine LPSTR ? 

; �ؼ���Handle
hFont HFONT ?
hPlayBtn HWND ?
hwndPB HWND ?
hListView HWND ?
hOpenDirBtn HWND ?
hwndEdit HWND ?
hStopBtn HWND ?
hTotalPlayTime HWND ?
hCurrentPlayTime HWND ?
hList HWND ?
hRepeatBtn HWND ?


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
	WinMain proc hInst:HINSTANCE
        LOCAL wc:WNDCLASSEX              
        LOCAL msg:MSG 
        LOCAL hwnd:HWND 

        mov   wc.cbSize,SIZEOF WNDCLASSEX   
        mov   wc.style, CS_HREDRAW or CS_VREDRAW 
        mov   wc.lpfnWndProc, OFFSET WndProc 
        mov   wc.cbClsExtra,NULL 
        mov   wc.cbWndExtra,NULL 
        push  hInstance 
        pop   wc.hInstance 
        mov   wc.hbrBackground,COLOR_WINDOW+1 
        mov   wc.lpszMenuName,NULL 
        mov   wc.lpszClassName,OFFSET ClassName 
        invoke LoadIcon,NULL,IDI_APPLICATION 
        mov   wc.hIcon,eax 
        mov   wc.hIconSm,eax 
        invoke LoadCursor,NULL,IDC_ARROW 
        mov   wc.hCursor,eax 
        invoke RegisterClassEx, addr wc   
        invoke CreateWindowEx,NULL,\ 
                    ADDR ClassName,\ 
                    ADDR AppName,\ 
                    WS_OVERLAPPEDWINDOW,\ 
                    0,\ 
                    0,\ 
                    300,\ 
                    300,\ 
                    NULL,\ 
                    NULL,\ 
                    hInst,\ 
                    NULL 
        mov   hwnd,eax 
        invoke ShowWindow, hwnd,SW_SHOWDEFAULT   
        invoke UpdateWindow, hwnd               

        .WHILE TRUE                                             
		    invoke GetMessage, ADDR msg,NULL,0,0 
            .BREAK .IF (!eax) 
            invoke TranslateMessage, ADDR msg 
            invoke DispatchMessage, ADDR msg 
       .ENDW 
        mov     eax,msg.wParam                      
        ret 
    WinMain endp
    

    ;�����ؼ�
    CreateWindowControl proc uses eax hWnd:HWND
    CreateWindowControl endp


    ; �����ؼ�λ��
    ReSizeWindowControl proc uses eax ebx hWnd:HWND
    ReSizeWindowControl endp


    ;���ڲ���
    WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM 
        .if uMsg == WM_DESTROY
		    invoke PostQuitMessage,NULL 
        ; ���ڱ仯��С
	    .elseif uMsg == WM_SIZE
		    invoke ReSizeWindowControl, hWnd
	    .else
		    invoke DefWindowProc, hWnd, uMsg, wParam, lParam 
	    .endif
        ret 
    WndProc endp
