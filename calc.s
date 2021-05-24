section .data 
for: db "%o",10,0
msg: db "calc: ",0

section .bss			
	buff: resb 60	
  result: resd 1
  stack: resb 63
  max: resd 1
  last: resd 1
  num: resd 1
  temp: resd 1

section .text
  align 16
  global main
  extern printf
  extern fprintf 
  extern fflush
  extern malloc 
  extern calloc 
  extern free 
  extern gets 
  extern getchar 
  extern fgets 
  extern stdout
  extern stdin
  extern stderr
main:
  pushad 
  pushfd
  call myCalc
  popfd 
popad

myCalc:
  push ebp
  mov ebp, esp
  pushad
  mov dword [last],stack
  start:
  push msg
  call printf
  add esp,4
  push dword [stdin]
  push 60
  push buff
  call fgets
  add esp, 12
 ; mov dword ecx,[buff]
  cmp byte [buff], '7'
  ja op
  cmp byte [ecx], '0'
  jb op
  push ecx
  call addNum
  add esp ,4
  jmp start
  op:
  push ecx
  call applyOperator
  add esp,4
  popad                    	         		
  mov esp, ebp			
  pop ebp				
  ret


applyOperator:
  push ebp
  mov ebp, esp
  pushad

  mov dword ecx,[ebp+8]
  cmp byte [ecx],'p' ;;if-elseif pattern - identify operator and call appropriate function
  ;jne isAdd
  call pop_and_print

; isAdd:
;   cmp byte [ecx],'+'
;   jne isMult
;   call addition

; isMult:
;   cmp byte [ecx],'*'
;   jne isAnd
;   call multiplication

; isAnd:
;   cmp byte [ecx],'&'
;   jne isNum
;   call bitwise_and

; isNum:
;   cmp byte [ecx],'n'
;   jne isDup
;   call is_num_of

; isDup:
;   cmp byte [ecx],'d'
;   jne isEnd
;   call duplicate

; isEnd:
;   cmp byte [ecx],'q'
;   jne return
;   ;; add code to free all memory
;   push dword [result]
;   push for
;   call printf
;   add esp, 8
;   mov eax,1
;   mov ebx,0
;   int 0x80

return:
  add dword [result], 1 ;; Add 1 to operation counter
  popad                    	         		
  mov esp, ebp			
  pop ebp				
  ret


addNum:
  push ebp
  mov ebp, esp
  pushad
  push dword 5
  call malloc
  add esp,4
  mov dword ecx,[last]
  add ecx,4
  mov dword [ecx],eax
  mov dword [last],ecx
  mov dword ecx,[ebp+8]
  lastchar:
    add dword [num],1
    inc ecx
    cmp byte [ecx],10
    jne lastchar
  conv:
    mov edx,0
    mov dl,[ecx]
    sub dl,'0'
    push edx
    push eax
    call create_link
    add esp,8
    dec ecx
    sub dword [num],1
    cmp dword [num],0
    jne conv
  popad                    	         		
  mov esp, ebp			
  pop ebp				
  ret  


create_link:
  push ebp              		
  mov ebp, esp         		
  pushad   
  sub esp,4                			
	push dword 5
  call malloc
  add esp,4
  mov dword ecx,[ebp+8]
  mov dword edx,[ebp+12]
  mov byte [eax],dl
  mov dword [eax+1],0
  mov dword [ecx+1],eax
  mov [ebp-4], ebx
  popad
  mov eax, [ebp-4]                    	         		
  mov esp, ebp			
  pop ebp				
  ret

pop_and_print:
  push ebp              		
  mov ebp, esp         		
  pushad 
  mov dword ecx,[last]
  push dword 5
  call malloc
  add esp,4
  mov dword [temp],eax
  mov dword [num],0
  reverse:
    add dword [num],1
    push dword [ecx]
    push eax
    call create_link
    add esp,4
    mov dword ecx,[ecx+1]
    cmp dword [ecx],0
    jne reverse
  push dword [num]
  call calloc
  add esp,0
  
  mov edx,temp
  recreate: 
  mov byte ebx,[edx]
    mov byte [eax],bl
    inc eax
    mov dword edx,[edx+1]
    cmp dword [edx],0
    jne recreate
  sub dword eax,[num]
  push eax
  push for
  call printf
  add esp,4

  popad                    	         		
  mov esp, ebp			
  pop ebp				
  ret


;  addition:
;   push ebp              		
;   mov ebp, esp         		
;   pushad   
;   mov dword ebx,[last]  ;; put the adress of the next two operands in to the registers
;   mov dword ecx,[last-4]  
  

;   popad                    	         		
;   mov esp, ebp			
;   pop ebp				
;   ret  

; pad: ;; This function ensures the next two operands are of identical length
;   push ebp              		
;   mov ebp, esp         		
;   pushad   
;   mov dword ebx,[last]  
;   mov dword ecx,[last-4]  
;   call num_of
;   mov edx, eax
;   sub dword [last], 4
;   call num_of
;   add dword [last], 4
;   cmp edx, eax
;   jb secondGreater
;   sub edx, eax
; .loop:


;   dec edx;
;   cmp edx, 0;
;   jg .loop

; secondGreater:

;   popad                    	         		
;   mov esp, ebp			
;   pop ebp				
;   ret  
