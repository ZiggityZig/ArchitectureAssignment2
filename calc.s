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
  cmp dword [operands],1
  je %%sub_op
  sub dword [last],4
  %%sub_op:
  sub dword [operands], 1
  popad
%endmacro

%macro pushRegs 0           ; for functions where we don't want to change the value of ecx,ebx,edx
  push ecx
  push ebx
  push edx
%endmacro

%macro popRegs 0
  pop edx
  pop ebx
  pop ecx
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

%macro printReg_debug 2
  pushad
  mov edx ,%1
  push edx
  push %2
  push dword [stderr]
  call fprintf
  add esp,12
  popad
%endmacro

section .data 
newLine: db 10,0
forO: db "%o",0
for: db "%o",10,0
msg: db "calc: ",0
deb: db "Debug mode: ",0
error1: db "Error: Operand Stack Overflow",10,0
error2: db "Error: Insufficient Number of Arguments on Stack",10,0

section .bss			
	buff: resb 60	
  result: resd 1
  stack: resb 63
  max: resd 1
  last: resd 1
  num: resd 1
  operands: resd 1
  carryFlag: resb 1
  prev: resd 1
  debugFlag: resb 1
  argc: resd 1

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
  push ebp
  mov ebp, esp
  mov edx,5
  mov byte [debugFlag],0
  mov dword ecx, [ebp+12]
  mov dword ebx ,[ebp+8]
  mov dword [argc], ebx
  cmp dword [argc],1
  je startProgram
  ;mov dword ecx, [ecx+4]
  mov ebx,1
  arguments:
  cmp dword [argc],1
  je startProgram
  mov dword ecx, [ebp+12]
  mov dword ecx, [ecx+4*ebx]
  mov byte al,[ecx]
  cmp byte al,'-'
  je debug
  cmp byte al,'7'
  ja arguments
  cmp byte al,'0'
  jb arguments
  mov eax,0
  mov edx,0
  calArg:
    mov byte al,[ecx]
    sub byte al,'0'
    shl edx,3
    add edx,ebx
    inc ecx
    cmp byte [ecx],0
    jne calArg
    sub dword [argc],1
    inc ebx
    jmp arguments
  debug:
    mov byte [debugFlag],1
    sub dword [argc],1
    inc ebx
    jmp arguments
  startProgram:
  mov dword [max],edx
  call myCalc
  mov esp, ebp			
  pop ebp				
  ret

myCalc:
  push ebp
  mov ebp, esp
  mov dword [operands],0
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
   jne isAnd
   call addition

 isAnd:
   cmp byte [ecx],'&'
   jne isNum
   call bitwise_and

 isNum:
   cmp byte [ecx],'n'
   jne isDup
   call num_of_bytes

 isDup:
   cmp byte [ecx],'d'
   jne isDebug
   call duplicate

 isDebug:
  cmp byte [debugFlag],0
  je isEnd
  cmp byte [ecx],'p'
  je isEnd
  cmp byte [ecx],'q'
  je isEnd
  call debug_print

 isEnd:
   cmp byte [ecx],'q'
   jne return
   ;; add code to free all memory
   push dword [result]
   push for
   call printf
   add esp, 8
   mov dword ecx,[operands]
   cmp ecx,0
   je Exit
   free_stack:
    popStack
    loop free_stack,ecx
   Exit:
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
  mov dword edx,[operands]
  cmp dword edx,[max]
  jb .start
  pushad
  push error1
  call printf
  add esp, 4
  popad
  jmp end_add_number
  .start:
  push dword 5
  call malloc
  add esp,4
  cmp dword [operands], 0
  je firstLink
  add dword [last], 4
  firstLink:
  mov dword ecx,[last]
  mov dword [ecx],eax
  mov dword ecx,[ebp+8]
  cmp byte [debugFlag],0
  je lastchar
  pushad
  push deb
  push dword [stderr]
  call fprintf
  add esp,8
  popad
  pushad
  push ecx
  push dword [stderr]
  call fprintf
  add esp,8
  popad
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
  endconv:
  add dword [operands], 1
  end_add_number:
  popad                    	         		
  mov esp, ebp			
  pop ebp				
  ret  


create_link:
  push ebp              		
  mov ebp, esp         		
  pushRegs   
	push dword 5
  call malloc
  add esp,4
  mov dword ebx,[ebp+8]
  mov dword edx,[ebp+12]
  mov byte [eax],dl
  mov dword [eax+1],0
  mov dword [ebx+1],eax    
  popRegs                	         		
  mov esp, ebp			
  pop ebp				
  ret

pop_and_print:
  push ebp              		
  mov ebp, esp   
  pushRegs      		
  cmp dword [operands], 0
  jne .start
  pushad
  push error2
  call printf
  add esp, 4
  popad
  jmp end_print
  .start:
  call unpad
  mov dword ecx,[last]
  mov dword ecx,[ecx]
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
    inc eax
    mov dword ecx,[ecx+1]
    cmp ecx,0
    jne join

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
  popStack
  end_print:
  popRegs
  mov esp, ebp			
  pop ebp				
  ret


addition: 
  push ebp              		
  mov ebp, esp         		
  pushad
  cmp dword [operands],2
  jae .start
  pushad
  push error2
  call printf
  add esp, 4
  popad
  jmp end_add
  .start:
  mov dword ebx,[last]      ;; put the adress of the next two operands in to the registers
  sub dword [last],4
  mov dword ecx,[last]
  add dword [last],4
  mov dword ebx,[ebx] 
  mov dword ecx,[ecx]  

  call pad
  countDigits             ;; number of calculations is equal to number of digits
  mov byte [carryFlag],0
  addition_loop:
    mov byte dl,[ebx]
    add byte [ecx], dl   ;;result is overloaded on to second operand
    mov byte dl, [carryFlag]
    add byte [ecx],dl
    cmp byte [ecx], 8
    jae carry
    mov byte [carryFlag], 0
    jmp finally
    carry:
      mov byte [carryFlag], 1  
      sub byte [ecx], 8  

    finally:
      mov dword [prev],ecx   ;Used to keep track of last link in the case of overflow
      mov dword ecx,[ecx+1]
      mov dword ebx,[ebx+1]
      dec eax
      cmp eax, 0
      jg addition_loop

    cmp byte [carryFlag], 1
    jne added
    mov edx,1
    push edx
    push dword [prev]
    call create_link
    add esp,8
  added:
    popStack
  end_add:
    popad                    	         		
    mov esp, ebp			
    pop ebp				
    ret  

pad:                      ;; This function ensures the next two operands are of identical length
  push ebp              		
  mov ebp, esp         		
  pushad   
  mov dword ebx,[last]    ;; calculates the difference in length
  sub dword [last],4
  mov dword ecx,[last]
  add dword [last],4
  mov dword ebx,[ebx] 
  mov dword ecx,[ecx]   
  countDigits
  mov edx, eax
  sub dword [last], 4
  countDigits
  add dword [last], 4
  cmp edx, eax  
  je finish  
  cmp edx, eax          
  sub edx, eax            ;; edx now holds the length difference
  jb secondGreater        ;; Iterates to the last link of the shorter list and adds 0s.
  .loop1:
    mov dword [prev],ecx
    mov dword ecx, [ecx+1]
    cmp ecx, 0
    jg .loop1 
  mov dword ecx,[prev] 
  .loop2:
      push 0
      push ecx
      call create_link
      add esp,8
      mov ecx, eax
      dec edx
      cmp edx, 0
      jg .loop2
    jmp finish
secondGreater:
  neg edx
  .loop1:
    mov dword [prev], ebx
    mov dword ebx, [ebx+1]
    cmp ebx, 0
    jg .loop1  
  mov dword ebx,[prev]
  .loop2:
    push 0
    push ebx
    call create_link
    add esp,8
    mov ebx, eax 
    dec edx
    cmp edx, 0
    jg .loop2

finish:
  popad                    	         		
  mov esp, ebp			
  pop ebp				
  ret 

num_of_bytes:
  push ebp                ;; Calculate number of bytes, save to eax and pop the number from stack
  mov ebp, esp 
  cmp dword [operands], 0
  jne .start
  pushad
  push error2
  call printf
  add esp, 4
  popad
  jmp end_num_of_bytes 
  .start:  
  call unpad     		  
  countDigits 
  pushRegs 
  dec eax
  mov edx,eax
  shl eax,1
  add eax,edx
  inc eax
  mov dword ecx,[last]
  mov dword ecx, [ecx]
  .loop1:
    mov dword [prev],ecx
    mov dword ecx, [ecx+1]
    cmp ecx, 0
    jg .loop1 
  mov dword ecx,[prev] 
  mov edx, 0
  mov byte dl,[ecx] 
  cmp edx, 2
  jb end_byte_calc
  inc eax
  cmp edx, 4
  jb end_byte_calc
  inc eax
  end_byte_calc:
  mov dl, 7
  and edx, eax
  shr eax, 3
  cmp edx,0
  je pushToStack
  inc eax
  pushToStack:
  popRegs
  mov dword [num],eax 
  popStack
  add dword [last],4
  push 5
  call malloc
  add esp,4               ;; Do-While loop to add number of bytes to the stack
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
    mov edx,7            ;; Iteration done by masking the number with 7, dividing by 8 and comparing to 0
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
  add dword [operands], 1
  end_num_of_bytes:
  mov esp, ebp			
  pop ebp				
  ret 

bitwise_and:
  push ebp              		
  mov ebp, esp    
  pushad
  cmp dword [operands], 2
  jae .start
  pushad
  push error2
  call printf
  add esp, 4
  popad
  jmp end_and  
  .start:    		
  call pad
  mov edx, eax
  mov dword ebx,[last]    
  sub dword [last],4
  mov dword ecx,[last]
  add dword [last],4
  mov dword ebx,[ebx] 
  mov dword ecx,[ecx] 
  mov eax,0
  mov edx,0  
  andLoop:
    mov byte al, [ebx]
    mov byte dl, [ecx]
    and dl,al
    mov byte [ecx],dl
    mov dword ecx, [ecx+1]
    mov dword ebx, [ebx+1]
    cmp ecx,0
    jne andLoop
  popStack 
  end_and:
  popad                   	         		
  mov esp, ebp			
  pop ebp				
  ret 


freeList:
  push ebp              		
  mov ebp, esp 
  pushad   
  mov dword ecx,[ebp+8]
  mov dword ebx,[ecx]     ;free first link
  mov dword ebx,[ebx]
  mov dword ecx,[ebx+1]
  pushad
  push ebx
  call free
  add esp,4
  popad 
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
  popad
  mov esp, ebp			
  pop ebp				
  ret 

duplicate:
  push ebp              		
  mov ebp, esp 
  pushad
  cmp dword [operands], 0
  jne check_if_full
  pushad
  push error2
  call printf
  add esp, 4
  popad
  jmp end_dup 
  check_if_full:
  mov dword edx,[operands]
  cmp dword edx,[max]
  jb .start
  pushad
  push error1
  call printf
  add esp, 4
  popad
  jmp end_dup
  .start:
  mov dword ebx,[last]
  mov dword ebx, [ebx]
  pushRegs
  push 5
  call malloc
  add esp,4 
  popRegs
  add dword [last], 4      ;; update stack to point at the new operand
  mov dword ecx, [last]
  mov dword [ecx], eax
  mov edx, 0
  mov byte dl, [ebx]
  mov byte [eax], dl
  mov dword [eax+1],0
  mov dword ebx, [ebx+1]
  cmp ebx, 0
  je finish_dup  
   duplication_loop:
    mov byte dl, [ebx]
    push edx
    push eax
    call create_link
    add esp, 8
    mov dword ebx, [ebx+1]
    cmp ebx, 0
    jne duplication_loop
     finish_dup:
  add dword [operands],1
  end_dup:
  popad                    	         		
  mov esp, ebp			
  pop ebp				
  ret

  unpad:
  push ebp              		
  mov ebp, esp 
  pushad
  unpad_loop:
    mov dword ebx, [last]
    mov dword ebx, [ebx]
    cmp dword [ebx+1], 0
    je finish_unpad
    lastlink:
      cmp dword [ebx+1], 0
      je endlastlink
      mov dword ecx, ebx
      mov dword ebx, [ebx+1]
      jmp lastlink
    endlastlink:
    mov edx, 0
    mov byte dl, [ebx]
    cmp edx, 0
    jne finish_unpad
    mov dword [ecx+1], 0
    pushRegs
    push ebx
    call free
    add esp, 4
    popRegs
    jmp unpad_loop


  finish_unpad:
  popad                    	         		
  mov esp, ebp			
  pop ebp				
  ret

debug_print:
  push ebp              		
  mov ebp, esp         		

  .start:
  pushad
  push deb
  push dword [stderr]
  call fprintf
  add esp,8
  popad
  call unpad
  mov dword ecx,[last]
  mov dword ecx,[ecx]
  mov dword [num],0
  .count:
    add dword [num],1
    mov dword ecx,[ecx+1]
    cmp ecx,0
    jne .count
  push dword [num]      ; allocating space for the bytes for printing
  call malloc
  add esp,4
  mov dword ecx,[last]
  mov dword ecx,[ecx]
  mov ebx,0
  mov edx,0
  .join:                 ; saving the bytes from the linked list on the allocated space
    mov byte bl,[ecx]
    mov byte [eax],bl
    inc eax
    mov dword ecx,[ecx+1]
    cmp ecx,0
    jne .join

        ; now eax points to the end of the number
  mov edx,0         ;print
  .Print:            ; printing in reverse order
    sub eax,1
    mov byte dl,[eax]
    printReg_debug edx,forO
    sub dword [num],1
    cmp dword [num],0
    jne .Print
    printNewLine 
  push eax
  call free
  add esp,4
  mov esp, ebp			
  pop ebp				
  ret

