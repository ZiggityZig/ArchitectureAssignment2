%macro printReg 2
  pushad
  mov edx ,%1
  push edx
  push %2
  call printf
  add esp,8
  popad
%endmacro
%macro printNewLine 0
  pushad
  push newLine
  call printf
  add esp,4
  popad
%endmacro

%macro popStack 0
  pushad
  push last
  call freeList
  add esp,4
  sub dword [last],4
  popad
%endmacro


%macro countDigits 0         ; counts the number of links in the last list and saves them in eax
push ecx
mov dword ecx,[last]
mov dword ecx,[ecx]
mov eax,0
%%count:
    add eax,1
    mov dword ecx,[ecx+1]
    cmp ecx,0
    jne %%count
pop ecx
%endmacro

section .data 
newLine: db 10,0
forO: db "%o",0
for: db "%o",10,0
msg: db "calc: ",0
deb: db "here",10,0
for3: db "%s",10,0
for4: db "%p",10,0

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
  ;pushad
  
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
  mov dword ecx,buff
  cmp byte [ecx], '7'
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
  jmp start
  ;popad                    	         		
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
   jne isNum
   call addition

;  ;isMult:
;   ; cmp byte [ecx],'*'
;   ; jne isAnd
;   ; call multiplication

;  isAnd:
;    cmp byte [ecx],'&'
;    jne isNum
;    call bitwise_and

 isNum:
   cmp byte [ecx],'n'
   jne isEnd
   call num_of_bytes

;  isDup:
;    cmp byte [ecx],'d'
;    jne isEnd
;    call duplicate

 isEnd:
   cmp byte [ecx],'q'
   jne return
   ;; add code to free all memory
   push dword [result]
   push for
   call printf
   add esp, 8
   mov eax,1
   mov ebx,0
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
  dec ecx
  mov edx,0
  mov dl,[ecx]
  sub dl,'0'
  mov byte [eax],dl
  mov dword [eax+1],0
  sub dword [num],1
  cmp dword [num],0
  je endconv
  conv:
    dec ecx
    mov edx,0
    mov dl,[ecx]
    sub dl,'0'
    push edx
    push eax
    call create_link
    add esp,8
    
    sub dword [num],1
    cmp dword [num],0
    jne conv
  ; pushad
  ; mov dword ecx,[last]
  ; mov dword ebx,[ecx]
  ; mov edx,0
  ; mov byte dl,[ebx]
  ; push edx
  ; push for
  ; call printf
  ; popad
 endconv:
 mov dword ecx,[last]
  popad                    	         		
  mov esp, ebp			
  pop ebp				
  ret  


create_link:
  push ebp              		
  mov ebp, esp         		
  ;pushad
  ;sub esp,4   
  push ecx             			
	push dword 5
  call malloc
  add esp,4
  pop ecx
  mov dword ebx,[ebp+8]
  mov dword edx,[ebp+12]
  mov byte [eax],dl
  mov dword [eax+1],0
  mov dword [ebx+1],eax
  
  ;mov [ebp-4], eax
 
  ;popad
  ;mov eax, [ebp-4]                    	         		
  mov esp, ebp			
  pop ebp				
  ret

pop_and_print:
  push ebp              		
  mov ebp, esp         		

  mov dword ecx,[last]
  mov dword ecx,[ecx]
  
  ;mov dword [temp],eax
  mov dword [num],0
  
  count:
    add dword [num],1
    mov dword ecx,[ecx+1]
    cmp ecx,0
    jne count

  
  push dword [num]      ; allocating space for the bytes for printing
  call malloc
  add esp,4
  
  mov dword ecx,[last]
  mov dword ecx,[ecx]
  mov ebx,0
  mov edx,0
  join:                 ; saving the bytes from the linked list on the allocated space
    mov byte bl,[ecx]
    mov byte [eax],bl
   ; mov byte dl,[eax]
    inc eax
    mov dword ecx,[ecx+1]
    cmp ecx,0
    jne join

  mov dword ecx,[last]  ; pop
  ;mov dword ecx,[ecx]
  push last
  call freeList
  add esp,4
  ; mov dword ecx,[last]
  ; sub ecx,4
  ; mov dword [last],ecx


      ; now eax points to the end of the number
  mov edx,0         ;print
  Print:            ; printing in reverse order
    sub eax,1
    mov byte dl,[eax]
    printReg edx,forO
    sub dword [num],1
    cmp dword [num],0
    jne Print
    printNewLine 
  push eax
  call free
  add esp,4
  sub dword [last],4  
  mov dword ecx,[last]
  mov esp, ebp			
  pop ebp				
  ret


addition:
  push ebp              		
  mov ebp, esp         		
  pushad   
  mov dword ebx,[last]      ;; put the adress of the next two operands in to the registers
  mov dword ecx,[last-4]
  mov dword ebx,[ebx] 
  mov dword ecx,[ecx]  
  call pad
  countDigits             ;; number of calculations is equal to number of digits
  ;dec eax
  .loop:
    mov byte dl,[ebx]
    add byte [ecx], dl   ;;result is overloaded on to second operand
    mov dword ecx,[ecx+1]
    mov dword ebx,[ebx+1]
    dec eax
    cmp eax, 0
    jg .loop
  
  ;; need to add code to test for overflow
  ;; add code to free top operand
  add dword [last],4 ;; top of the stack will point to result
  popad                    	         		
  mov esp, ebp			
  pop ebp				
  ret  

pad: ;; This function ensures the next two operands are of identical length
  push ebp              		
  mov ebp, esp         		
  pushad   
  mov dword ebx,[last]    ;; calculates the difference in length
  mov dword ecx,[last-4] 
  mov dword ebx,[ebx] 
  mov dword ecx,[ecx]   
  countDigits
  mov edx, eax
  sub dword [last], 4
  countDigits
  add dword [last], 4
  sub edx, eax            ;; edx now holds the length difference
  cmp edx, 0
  jb secondGreater        ;; Iterates to the last link of the shorter list and adds 0s.
  ;dec edx
  .loop1:
    mov dword ecx,[ecx+1]
    ;dec edx
    cmp ecx, 0
    jg .loop1  
  .loop2:
      push 0
      push dword [ecx]
      call create_link
      add esp,8
      ;mov ecx, eax
      dec edx
      cmp edx, 0
      jg .loop2
    finish
secondGreater:
  ; add edx, eax
  ; sub eax, edx
  ; mov edx, eax
  neg edx
  .loop1:
    mov dword ebx,[ebx+1]
    
    cmp ebx, 0
    jg .loop1  
   .loop2:
      push 0
      push dword [ebx]
      call create_link
      add esp,8
      ;mov ecx, eax
      dec edx
      cmp edx, 0
      jg .loop2

finsh:
  popad                    	         		
  mov esp, ebp			
  pop ebp				
  ret 

num_of_bytes:
  push ebp              		
  mov ebp, esp         		  
  countDigits
  mov edx,1
  and edx,eax
  shr eax,1
  add eax,edx
  mov dword [num],eax 
  popStack
  add dword [last],4
  push 5
  call malloc
  add esp,4
  mov dword ecx,[last]
  mov dword [ecx],eax
  mov dword [last],ecx
  mov edx,7
  and dword edx,[num]
  mov dword ebx, [num]
  shr dword ebx,3
  mov dword [num],ebx
  mov byte [eax],dl
  mov dword [eax+1],0
  cmp dword [num],0
  je .endloop1
  .loop1:
    mov edx,7
    and dword edx,[num]
    mov dword ebx, [num]
    shr dword ebx,3
    mov dword [num],ebx
    push edx
    push eax
    call create_link
    add esp,8
    cmp dword [num],0
    jne .loop1
  .endloop1:
  mov esp, ebp			
  pop ebp				
  ret 

bitwise_and:
  push ebp              		
  mov ebp, esp         		
  pushad  
  mov ecx, [last]
  mov edx, 0
  


  popad                    	         		
  mov esp, ebp			
  pop ebp				
  ret 


freeList:
  push ebp              		
  mov ebp, esp      
  mov dword ecx,[ebp+8]
  mov ebx,[ecx]     ;free first link
  mov ebx,[ebx]
  pushad
    push ebx
    call free
    add esp,4
    popad
  mov ecx,[ebx]
  cmp ecx,0
  je endloop      ; if there's more than one continue to the others
  freeLoop:
    mov dword ebx,[ecx+1]
    pushad
    push ecx
    call free
    add esp,4
    popad
    mov ecx,ebx
    cmp ecx,0
    jne freeLoop
  endloop:
  mov esp, ebp			
  pop ebp				
  ret 