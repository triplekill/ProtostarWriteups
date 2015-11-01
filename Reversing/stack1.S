0x08048464 <+0>:push   ebp                                  ;Function prologue
0x08048465 <+1>:mov    ebp,esp                              ;
0x08048467 <+3>:and    esp,0xfffffff0                       ;Align stack pointer to 16-byte boundary
0x0804846a <+6>:sub    esp,0x60                             ;Subtract 96 bytes from the stack pointer.
0x0804846d <+9>:cmp    DWORD PTR [ebp+0x8],0x1              ;First, let's explain the significance of EBP+0x8. In the CDECL calling convention,
                                                            ;we are going to push our arguments onto the stack in reverse order, then CALL, then
                                                            ;do our function prologue, PUSH EBP, and then subtract from the stack pointer. That
                                                            ;means that the address EBP is the saved frame pointer, EBP+0x4 is the saved instruction
                                                            ;pointer, and EBP+0x8 is the first argument to the function, EBP+0xc is the second argument,
                                                            ;and so on. We're in main(), so that means that EBP+0x8 is the "int argc" in 
                                                            ;"int main(int argc, char** argv)".
                                                            ;CMP is a subtract that sets certain flags, so we're effectively calculating argc - 1.
                                                            ;What we're interesting in is ZF, because if argc == 1, then argc - 1 will be zero, meaning
                                                            ;ZF = 1.
0x08048471 <+13>:jne    0x8048487 <main+35>                 ;Go to main+35 if ZF=0.
0x08048473 <+15>:mov    DWORD PTR [esp+0x4],0x80485a0       ;Move address of "please specify an argument\n" onto the stack plus 4 bytes.
0x0804847b <+23>:mov    DWORD PTR [esp],0x1                 ;Move 1 onto the stack.
0x08048482 <+30>:call   0x8048388 <errx@plt>                ;Call errx() in the program linkage table. According to http://linux.die.net/man/3/errx
                                                            ;this is the non-returning function err().
                                                            ;So far, we seem to have something like if(argc == 1) err(1, "please specify an argument\n");
0x08048487 <+35>:mov    DWORD PTR [esp+0x5c],0x0            ;Now we have "int modified = 0;"
0x0804848f <+43>:mov    eax,DWORD PTR [ebp+0xc]             ;Move argv into EAX
0x08048492 <+46>:add    eax,0x4                             ;Remember argv is char**. So EAX+0x4 is equivalent to the element argv[1].
0x08048495 <+49>:mov    eax,DWORD PTR [eax]                 ;This is moving the char* argv[1] into EAX.
0x08048497 <+51>:mov    DWORD PTR [esp+0x4],eax             ;Moving EAX into the stack plus 4 bytes.
0x0804849b <+55>:lea    eax,[esp+0x1c]                      ;Moving 0x1c up the stack into EAX. 
0x0804849f <+59>:mov    DWORD PTR [esp],eax                 ;Moving EAX into the the stack. Let's think about what we've done so far. We moved the pointer
                                                            ;to some kind of local variable on the stack into the memory pointed to by the stack, and we
                                                            ;have also moved the value of argv[1] onto the stack plus four bytes. This looks like setting
                                                            ;up a CDECL call...
0x080484a2 <+62>:call   0x8048368 <strcpy@plt>              ;strcpy(buffer, argv[1]);
                                                            ;This is a vulnerable string copy. There is no bounds checking copying the string argv[1] into
                                                            ;buffer. Looking farther up the assemb  ly, we notice that the vulnerable buffer on the stack
                                                            ;begins at ESP+0x1c, and we have another local variable "int modified" at ESP+0x5c. Again,
                                                            ;since 0x5c - 0x1c = 0x40, we can guess that the size of the buffer is a char[64].
0x080484a7 <+67>:mov    eax,DWORD PTR [esp+0x5c]            ;After the strcpy, we move the value of "modified" into EAX.
0x080484ab <+71>:cmp    eax,0x61626364                      ;Here we are checking to see if EAX is exactly equal to 0x61626364. The point here is to teach
                                                            ;byte ordering or endianness. Intel is a little-endian architecture. This means if we wrote
                                                            ;"A"*64+"\x61\x62\x63\x64" here, we would have it the wrong way around, and the "modified"
                                                            ;variable would be 0x64636261. If this were ARM instead, this would be right. However, it's
                                                            ;not, so we need to write the exploit with "A"*64+"\x64\x63\x62\x61" to produce the desired
                                                            ;result.
0x080484b0 <+76>:jne    0x80484c0 <main+92>                 ;If not exactly equal, jump to main+92.
0x080484b2 <+78>:mov    DWORD PTR [esp],0x80485bc           ;Load address of "you have correctly got the variable to the right value" to the stack.
0x080484b9 <+85>:call   0x8048398 <puts@plt>                ;Print the string "you have correctly got the variable to the right value"
0x080484be <+90>:jmp    0x80484d5 <main+113>                ;Exit gracefully.
0x080484c0 <+92>:mov    edx,DWORD PTR [esp+0x5c]            ;Move the value of "modified" to EDX, which is just a temporary location.
0x080484c4 <+96>:mov    eax,0x80485f3                       ;Load address of "Try again, you got 0x%08x\n" to the stack.
0x080484c9 <+101>:mov    DWORD PTR [esp+0x4],edx            ;Move EDX to stack plus 4 bytes.
0x080484cd <+105>:mov    DWORD PTR [esp],eax                ;Address of the string we just loaded goes to the stack.
0x080484d0 <+108>:call   0x8048378 <printf@plt>             ;Again, CDECL. Remember printf(fmt, ...), the ellipses mean printf is a VA_ARGS function.
                                                            ;We can have an arbitrary number of format arguments on the stack after this, and in this
                                                            ;case, we just want the one for the "%08x" part of the format string. This will print the
                                                            ;argument referenced on the stack (+4) in hex, up to eight width, and zero-pad it on the
                                                            ;left. Basically, this gives us a nice hex print out of the value of "modified" if we did
                                                            ;not perform our arbitrary write correctly.
0x080484d5 <+113>:leave
0x080484d6 <+114>:ret