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
  jne isAdd
  call pop_and_print

isAdd:
  cmp byte [ecx],'+'
  jne isMult
  call addition

isMult:
  cmp byte [ecx],'*'
  jne isAnd
  call multiplication

isAnd:
  cmp byte [ecx],'&'
  jne isNum
  call bitwise_and

isNum:
  cmp byte [ecx],'n'
  jne isDup
  call is_num_of

isDup:
  cmp byte [ecx],'d'
  jne isEnd
  call duplicate

isEnd:
  cmp byte [ecx],'q'
  jne return
  ;; add code to free all memory
  push dword [result]
  push for
  call printf
  add esp, 8
  push eax 1
  push ebx 0
  int 0x80

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
  mov dword ecx,[ebp+8]
  mov eax,0
  conv:
    mov edx,0
    shl eax,3
    mov dl,[ecx]
    sub dl,'0'
    add eax,edx
    inc ecx
    cmp byte [ecx],10
    jne conv
  mov dword [num],eax
  push dword 5
  call malloc
  add esp,4
  mov dword ecx,[last]
  add ecx,4
  mov dword [last],ecx
  mov dword [last],eax
  
  LL:
    push eax
    call create_link
    add esp,4
    mov dword edx,[num]
    shr edx,8
    mov dword [num],edx
    cmp dword [num],0
    jne LL
  popad                    	         		
  mov esp, ebp			
  pop ebp				
  ret  


create_link:
  push ebp              		
  mov ebp, esp         		
  pushad                   			
	push dword 5
  call malloc
  add esp,4
  mov dword ecx,[ebp+8]
  mov dword edx,[num]
  mov byte [eax],dl
  mov dword [eax+1],0
  mov dword [ecx+1],eax
;  mov dword [bot],eax
  popad                    	         		
  mov esp, ebp			
  pop ebp				
  ret

pop_and_print:
  push ebp              		
  mov ebp, esp         		
  pushad 
  mov dword ecx,[last]
  mov edx,0
  mov eax,3
  loop1:
    
    jne loop1
  push dword [num]
  push for
  call printf
  add esp,8
  mov dword ecx,[last]
  ; fix freeing 
  ;free
  ;loop2:
  ;  mov dword ebx,[ecx+1]
   ; push ecx
   ; call free
  ; ; add esp,4
  ;  mov ecx,ebx
   ; cmp ecx,0
  ;  jne loop1
  popad                    	         		
  mov esp, ebp			
  pop ebp				
  ret


addition:
  push ebp              		
  mov ebp, esp         		
  pushad   


  popad                    	         		
  mov esp, ebp			
  pop ebp				
  ret  
