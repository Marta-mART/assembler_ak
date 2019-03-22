.data
STDOUT = 1
SYSREAD = 0
SYSWRITE = 1
SYSOPEN = 2
SYSCLOSE = 3
EXIT_SUCCESS = 0
SYSEXIT = 60

LICZBA_WYRAZOW = 4
LICZBA_POCZ = 3

.bss
.comm textout, 512

.text
.global main

main:

mov $LICZBA_WYRAZOW, %r9	#Licznik pętli

movq $1, %r11
call rekurencyjna


exit:
#---Koniec programu---
mov $SYSEXIT, %rax
mov $EXIT_SUCCESS, %rdi
syscall



#---Funkcja rekurencyjna---rejestry---
rekurencyjna:
cmp $0, %r11
jne poczatkowy_zabieg

dalej:
cmp $0, %r9
jnz obliczenia
ret


obliczenia:
movq $(-5), %r10
imul %r10
add $7, %rax			#Wynik jest w rax

movq %rax, textout(, %r9, 1)	#Nic nie robi

dec %r9
call rekurencyjna
ret

poczatkowy_zabieg:
dec %r11
mov $LICZBA_POCZ, %rax 		#Wkladamy 3 - liczbe od ktorej zaczynamy ciag
jmp dalej






