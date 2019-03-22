.data
SYSEXIT = 60 
SYSREAD = 0
SYSWRITE = 1
STDOUT = 1
STDIN = 0
EXIT_SUCCESS = 0

.bss
.comm bufor, 32
.comm bufor_wyn, 10000

.text
.global main
main:

#movq $SYSREAD, %rax
#movq $STDIN, %rdi
#movq $bufor, %rsi			#ile cyfr ciagu chcemy
#movq $BUF_SIZE, %rdx
#syscall

#movq $rax, %r8				#ilosc zczytanych znakow
#push $11
mov $11 , %rbx
call fibo_wrp
#movq $SYSWRITE, %rax
#movq $STDOUT, %rdi
#movq $bufor, %rsi
#movq $BUF_SIZE, %rdx
#syscall
xd:
pop %r15
movq $SYSEXIT, %rax
movq $EXIT_SUCCESS, %rdi
syscall

fibo_wrp:
push %rbp
mov %rsp, %rbp
fibo:
push %rbx			#
#mov 16(%rbp), %rbx	#sciagam parametr ze stosu
mov $1, %rax		#inicjalizacja dla dodawania
cmp $2, %rbx		#pierwsze dwie w ciagu to jedynki
jbe finish

start:
dec %rbx			#zmniejszam licznik zeby uzyskac n-1	
push %rbx			#wrzucam na stos jako parametr
call fibo_wrp	
pop %rbx			#sciagam licznik ze stosu
push %rax			#wrzucam wynik z n-1 na stos
dec %rbx			#zmniejszam licznik zeby uzyksac n-2
push %rbx			#wrzucam na stos jako parametr
call fibo_wrp
pop %rbx			#sciagam licznik ze stosu, ktory jest tutaj juz niepotrzebny
pop %rbx			#sciagam wynik z pierwszej funkcji
add %rbx, %rax		#dodaje oba wyniki i uzyskuje n

finish:
mov %rbp, %rsp
pop %rbp
ret
