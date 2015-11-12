0x08048454 <+0>:	push   ebp                             ;Function prologue
0x08048455 <+1>:	mov    ebp,esp
0x08048457 <+3>:	sub    esp,0x218                       ;Subtract 536 from the stack pointer
0x0804845d <+9>:	mov    eax,ds:0x80496d8                ;Move the value in 0x80496d8 (which is 0) to EAX. [<stdin@@GLIBC_2.0>]
0x08048462 <+14>:	mov    DWORD PTR [esp+0x8],eax         ;Move EAX onto the stack as a third function argument.
0x08048466 <+18>:	mov    DWORD PTR [esp+0x4],0x200       ;Move 512 onto the stack as a second function argument.
0x0804846e <+26>:	lea    eax,[ebp-0x208]                 ;Load effective address of EBP - 520 to EAX. (This is some local buffer.)
0x08048474 <+32>:	mov    DWORD PTR [esp],eax             ;Load EAX onto the stack as a first function argument.
0x08048477 <+35>:	call   0x804835c <fgets@plt>           ;Call "char *fgets(char *s, int size, FILE *stream);"
                                                               ;fgets(&local_buffer, 512, stdin);
0x0804847c <+40>:	lea    eax,[ebp-0x208]                 ;Load effective address of EBP - 520 to EAX. (This is some local buffer.) 
0x08048482 <+46>:	mov    DWORD PTR [esp],eax             ;Load EAX onto the stack for printf()
0x08048485 <+49>:	call   0x804837c <printf@plt>          ;printf(local_buffer);
                                                               ;The variable local_buffer is unvalidated, user-controlled data.
0x0804848a <+54>:	mov    eax,ds:0x80496e4                ;Move the DWORD "target" in the BSS section into EAX. This value is zero
                                                               ;when the program is run.
0x0804848f <+59>:	cmp    eax,0x40                        ;Check to see if EAX is 64.
0x08048492 <+62>:	jne    0x80484a2 <vuln+78>             ;If it's not, go to the part where we failed to change the target.
0x08048494 <+64>:	mov    DWORD PTR [esp],0x8048590       ;Move address of the string "you have modified the target :)" into ESP.
0x0804849b <+71>:	call   0x804838c <puts@plt>            ;Print out confirmation of success.
0x080484a0 <+76>:	jmp    0x80484b9 <vuln+101>            ;Exit the program.
0x080484a2 <+78>:	mov    edx,DWORD PTR ds:0x80496e4      ;Move the value of the "target" variable into EDX.
0x080484a8 <+84>:	mov    eax,0x80485b0                   ;Move address of the string "target is %d :(\n" into EAX.
0x080484ad <+89>:	mov    DWORD PTR [esp+0x4],edx         ;Move EDX into first va_arg position for printf.
0x080484b1 <+93>:	mov    DWORD PTR [esp],eax             
0x080484b4 <+96>:	call   0x804837c <printf@plt>          ;printf("target is %d :(\n", target);
0x080484b9 <+101>:	leave
0x080484ba <+102>:	ret

;void vuln(char* string)
;{
;    char local_buffer[512];
;    fgets(local_buffer, 512, stdin);
;    printf(local_buffer); // Arbitrary write here.
;    if(target == 0x40)
;        puts("you have modified the target :)");
;    else
;        printf("target is %d :(\n", target);
;}