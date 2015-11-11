0x0804841c <+0>:push   ebp                        ;Function prologue - Save previous frame pointer.
0x0804841d <+1>:mov    ebp,esp                    ;The stack pointer coming in should now by the frame pointer.
0x0804841f <+3>:and    esp,0xfffffff0             ;Aligning ESP to 16 byte boundary
0x08048422 <+6>:sub    esp,0x10                   ;Subtracting 16 from ESP
0x08048425 <+9>:mov    eax,DWORD PTR [ebp+0xc]    ;Move the DWORD value pointed at by EBP+0xc into EAX. EBP+0xc is going to be pointing at argv
0x08048428 <+12>:add    eax,0x4                   ;Add 4 to EAX so that we can dereference this as argv[1]
0x0804842b <+15>:mov    eax,DWORD PTR [eax]       ;Since the data type of EAX is char**, we're saying we want to move the value pointed to by EAX into EAX. This is derefencing argv[1], and EAX is now a char*.
0x0804842d <+17>:mov    DWORD PTR [esp],eax       ;Pass argv[1] (a char*) on the stack, to the function "void vuln(char*)"
0x08048430 <+20>:call   0x80483f4 <vuln>          ;Call vuln()
0x08048435 <+25>:leave                            ;Function epilogue
0x08048436 <+26>:ret

;static int target = 0; // Reason for this will be seen further down in the disassembly.
;int main(int argc, char** argv)
;{
;    vuln(argv[1]);
;}

0x080483f4 <+0>:push   ebp                        ;Function prologue
0x080483f5 <+1>:mov    ebp,esp
0x080483f7 <+3>:sub    esp,0x18                   ;Subtracting 24 from ESP
0x080483fa <+6>:mov    eax,DWORD PTR [ebp+0x8]    ;Move the first and only argument to this function into EAX.
0x080483fd <+9>:mov    DWORD PTR [esp],eax        ;Pass this argument on the stack to printf.
0x08048400 <+12>call   0x8048320 <printf@plt>     ;Call printf().
                                                  ;Notice here, that ESP is user-controlled input, and it is not validated.
                                                  ;There are no va_args being passed farther up the stack, meaning that we
                                                  ;can just do whatever we want here.
0x08048405 <+17>:mov    eax,ds:0x8049638          ;This is a move instruction with data segment addressing. We're moving
                                                  ;the value pointed at by 0x8049638 to EAX. You can run objdump -d -j .bss format1
                                                  ;to find out what this is. It turns out that since debugging symbols were not
                                                  ;stripped from this binary, this is a DWORD called "target" with the value 0.
                                                  ;Because it was found in the BSS section, we know this is a global variable.
0x0804840a <+22>:test   eax,eax                   ;We are now checking for EAX == 0
0x0804840c <+24>:je     0x804841a <vuln+38>       ;If EAX == 0, leave-ret. (We did not get the flag.)
0x0804840e <+26>:mov    DWORD PTR [esp],0x8048500 ;This address points to the string "you have modified the target :)"
0x08048415 <+33>:call   0x8048330 <puts@plt>      ;Print confirmation that we got the flag.
0x0804841a <+38>:leave                            ;Function epilogue
0x0804841b <+39>:ret

;void vuln(char* str)
;{
;    printf(str);
;    if(target != 0)
;        puts("you have modified the target :)");
;}

;General exploitation strategy: Find the address of str by writing a unique pattern and using direct parameter access until we find it.
;Once we have found it, change the address to the little-endian format of the target address: 0x8049638. Use %n to write to it. 