0x08048467 <+0>:	push   ebp                         ;Function prologue
0x08048468 <+1>:	mov    ebp,esp
0x0804846a <+3>:	sub    esp,0x218                   ;Subtract 536 from the stack pointer
0x08048470 <+9>:	mov    eax,ds:0x80496e8            ;This is the reference to stdin
0x08048475 <+14>:	mov    DWORD PTR [esp+0x8],eax     ;Third argument to fgets = stdin
0x08048479 <+18>:	mov    DWORD PTR [esp+0x4],0x200   ;Second argument to fgets = 512
0x08048481 <+26>:	lea    eax,[ebp-0x208]             ;EBP-520 is a local buffer. Probably a char[512];
0x08048487 <+32>:	mov    DWORD PTR [esp],eax         ;First argument to fgets = local_buffer
0x0804848a <+35>:	call   0x804835c <fgets@plt>       ;fgets(local_buffer, 512, stdin);
0x0804848f <+40>:	lea    eax,[ebp-0x208]             ;Load local_buffer address into EAX.
0x08048495 <+46>:	mov    DWORD PTR [esp],eax         ;Move address of local_buffer to stack for printbuffer call.
0x08048498 <+49>:	call   0x8048454 <printbuffer>     ;Another function. Seriously?
0x0804849d <+54>:	mov    eax,ds:0x80496f4            ;Move DWORD for "target" into EAX. Found in BSS section.
                                                           ;Global variable initialized to zero.
0x080484a2 <+59>:	cmp    eax,0x1025544               ;Check if target == 0x01025544
0x080484a7 <+64>:	jne    0x80484b7 <vuln+80>
0x080484a9 <+66>:	mov    DWORD PTR [esp],0x80485a0
0x080484b0 <+73>:	call   0x804838c <puts@plt>
0x080484b5 <+78>:	jmp    0x80484ce <vuln+103>
0x080484b7 <+80>:	mov    edx,DWORD PTR ds:0x80496f4
0x080484bd <+86>:	mov    eax,0x80485c0
0x080484c2 <+91>:	mov    DWORD PTR [esp+0x4],edx
0x080484c6 <+95>:	mov    DWORD PTR [esp],eax
0x080484c9 <+98>:	call   0x804837c <printf@plt>
0x080484ce <+103>:	leave
0x080484cf <+104>:	ret