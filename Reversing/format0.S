main:
0x0804842b <+0>:push   ebp                          ;Function prologue
0x0804842c <+1>:mov    ebp,esp
0x0804842e <+3>:and    esp,0xfffffff0
0x08048431 <+6>:sub    esp,0x10                     ;Reserve 16 bytes on the stack.
0x08048434 <+9>:mov    eax,DWORD PTR [ebp+0xc]      ;Move argv into EAX
0x08048437 <+12>:add    eax,0x4                     ;Setting up to dereference this pointer as argv[1].
0x0804843a <+15>:mov    eax,DWORD PTR [eax]         ;Load address argv[1] to EAX.
0x0804843c <+17>:mov    DWORD PTR [esp],eax         ;Pass argv[1] to vuln() on the stack.
0x0804843f <+20>:call   0x80483f4 <vuln>            ;Call void vuln(char*)
0x08048444 <+25>:leave                              ;Function epilogue
0x08048445 <+26>:ret

;int main(int argc, char** argv)
;{
;    vuln(argv[1]);
;}

vuln:
0x080483f4 <+0>:push   ebp                          ;Function prologue
0x080483f5 <+1>:mov    ebp,esp
0x080483f7 <+3>:sub    esp,0x68                     ;Subtract 104 bytes from the stack pointer.
0x080483fa <+6>:mov    DWORD PTR [ebp-0xc],0x0      ;Move zero into the address pointed to by EBP-0xc.
                                                    ;Since we're subtracting from EBP rather than adding,
                                                    ;we appear to be referencing a local integer variable,
                                                    ;rather than a function argument.
0x08048401 <+13>:mov    eax,DWORD PTR [ebp+0x8]     ;EBP+0x8 is the passed char* argv[1], moving to EAX.
0x08048404 <+16>:mov    DWORD PTR [esp+0x4],eax     ;Move this value to ESP+0x4, meaning it's the second
                                                    ;argument to a CDECL function we're about to call.
0x08048408 <+20>:lea    eax,[ebp-0x4c]              ;Load address EBP-0x4c into EAX.
0x0804840b <+23>:mov    DWORD PTR [esp],eax         ;Move the address into ESP, so it's the first argument.
0x0804840e <+26>:call   0x8048300 <sprintf@plt>     ;Call sprintf(char* str, chat* fmt, ...);
                                                    ;In this instance, we know that "str" is a local buffer,
                                                    ;and since 0x4c - 0xc = 0x40, we can guess that this
                                                    ;local buffer is a char[64]. The argument "fmt" is
                                                    ;argv[1]. The problem here is that this is a format
                                                    ;string, which should be static or validated in some way.
                                                    ;However, in this instance, it is unvalidated,
                                                    ;user-controlled data. Nothing prevents us from using
                                                    ;%s to read arbitrary memory locations or %n to write to
                                                    ;arbitrary memory locations. Furthermore, there is no
                                                    ;bounds checking on the destination buffer "str" to which
                                                    ;we will be "printf"-ing to.
0x08048413 <+31>:mov    eax,DWORD PTR [ebp-0xc]     ;Load the integer variable "x" into EAX in preparation for
                                                    ;a comparison.
0x08048416 <+34>:cmp    eax,0xdeadbeef              ;Is $eax == 0xdeadbeef? If so, ZF = 1.
0x0804841b <+39>:jne    0x8048429 <vuln+53>         ;Jump if ZF = 0, in other words, we failed to do perform
                                                    ;the correct overwrite.
0x0804841d <+41>:mov    DWORD PTR [esp],0x8048510   ;Load the string "you have hit the target correctly :)" into ESP
0x08048424 <+48>:call   0x8048330 <puts@plt>        ;Call printf (optimized to puts), because there are no VA_ARGs.
0x08048429 <+53>:leave
0x0804842a <+54>:ret

;void vuln(char* str)
;{
;   int x = 0;              // $ebp - 0x0c
;   char buffer[64];        // $ebp - 0x4c
;   sprintf(buffer, str);
;   if(x == 0xdeadbeef)
;       printf("you have hit the target correctly :)");
;}

;There are many possible exploits here, but the simplest is "A"*64 + "x\xef\xbe\xad\xde"
