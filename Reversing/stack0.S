0x080483f4 <+0>:	push   ebp                         ;Save base pointer on the stack
0x080483f5 <+1>:	mov    ebp,esp                     ;Move ESP into EBP so that where ESP was pointing before is now the base pointer
0x080483f7 <+3>:	and    esp,0xfffffff0              ;Align the stack pointer to a 16-byte boundary
0x080483fa <+6>:	sub    esp,0x60                    ;Subtract 96 bytes from the stack (remembering that EBP points to the top of the stack and ESP points at the bottom of the stack)
0x080483fd <+9>:	mov    DWORD PTR [esp+0x5c],0x0    ;Set the 4-byte value at ESP+0x5c to 0. ("int modified = 0;")
0x08048405 <+17>:	lea    eax,[esp+0x1c]              ;Load the value ESP+0x1c into EAX. This is the string argument to "char* gets(char*)". Notice that 0x5c - 0x1c = 0x40 = 64. This is local char[64] buffer on the stack.
0x08048409 <+21>:	mov    DWORD PTR [esp],eax         ;Set the 4-byte value at ESP to EAX.
0x0804840c <+24>:	call   0x804830c <gets@plt>        ;Call gets()
0x08048411 <+29>:	mov    eax,DWORD PTR [esp+0x5c]    ;Move the 4-byte value at ESP+0x5c (which we decided was "int modified") to EAX
0x08048415 <+33>:	test   eax,eax                     ;Bitwise AND eax to itself and set EFLAGS. Specifically, we will have ZF=1 if EAX is 0. Otherwise, ZF will be 0.
0x08048417 <+35>:	je     0x8048427 <main+51>         ;Jump if ZF=1. Meaning in the context of this binary, if EAX=0, that is, ESP+0x5c, that is "int modified"
0x08048419 <+37>:	mov    DWORD PTR [esp],0x8048500   ;Move the address of the string "you have changed the 'modified' variable" on the stack.
0x08048420 <+44>:	call   0x804832c <puts@plt>        ;Call puts(), which is what happens when you call printf(), but there were no va_args.
0x08048425 <+49>:	jmp    0x8048433 <main+63>         ;Exit the program.
0x08048427 <+51>:	mov    DWORD PTR [esp],0x8048529   ;Move the address of the string "Try again?" on the stack.
0x0804842e <+58>:	call   0x804832c <puts@plt>        ;Call puts(), which happens when we fail to get the CTF flag.
0x08048433 <+63>:	leave
0x08048434 <+64>:	ret
