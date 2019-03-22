.data
SYSEXIT = 60 
SYSREAD = 0
SYSWRITE = 1
STDOUT = 1
STDIN = 0
EXIT_SUCCESS = 0
IN_SIZE = 30

entry_text: .ascii "Podaj nieujemna liczbe calkowita\n"
entry_len = .-entry_text
.bss

.comm input, IN_SIZE
.comm bufor, 1000

.text
.global main

main:

movq $SYSWRITE, %rax
movq $STDOUT, %rdi
movq $entry_text, %rsi
movq $entry_len, %rdx
syscall

movq $SYSREAD, %rax
movq $STDIN, %rdi
movq $input, %rsi
movq $IN_SIZE, %rdx
syscall

dec %rax
movq %rax , %r8
xor %rdi, %rdi
xor %rax, %rax
mov $10, %rcx
decode:
movb input(,%rdi,1), %bl
sub $'0' , %rbx
inc %rdi
add %rbx, %rax
cmp %r8, %rdi
jnz decode_cont
jz get_num

decode_cont:
mul %rcx				#mnoze przez 10
jmp decode

get_num:
push $bufor				#wrzucam drugi argument
push %rax				#wrzucam pierwszy argument
call prime_fact			#wywoluje funkcje
#pop %rdx				#sciagam liczbe znakow ze stosu
sub $24, %rsp			#wyczyszczenie jednego nienadpisanego argumentu na stosie
pop %rdx

movq $SYSWRITE, %rax
movq $STDOUT, %rdi
movq $bufor, %rsi
syscall

movq $SYSEXIT, %rax
movq $EXIT_SUCCESS, %rdi
syscall

prime_fact:				#funkcja w rax bedzie zwracac ilosc czynnikow
pushq %rbp				#wrzucenie oldRBP na stos
movq %rsp, %rbp			#rsp wskazuje teraz na nowa ramke stosu
sub $8, %rsp			#alokowanie 1 bajtu na zmienna lokalna
movq 16(%rbp), %rax		#pierwszy argument - liczba
movq 24(%rbp), %rbx		#drugi argument - adres tablicy znakow
movq $2, %rcx			#w rcx umieszczam 2, jako pierwsza liczbe pierwsza
movq $10, %r8			#do dzielenia modulo 10
xor %rdi, %rdi			#czyszczenie rejestrow licznikowych
xor %rsi, %rsi
out_loop:
cmp $1, %rax			#petla zewnetrzna
movq %rax, %r14			
jle end				#jesli liczba<=1 to koniec
jg inn_loop				#jesli liczba>1 to wchodzimy do drugiej petli

inn_loop:
xor %rdx, %rdx			#wyzerowanie rejestru dla reszty z dzielenia
div %rcx				#w rax wynik dzielenia, w rdx reszta
cmp $0, %rdx			#sprawdzam czy reszta z dzielenia == 0
jz inn_loop_cont			#jesli tak to kontynuuje petle
jnz out_loop_cont			#jesli nie to przechodze do zwiekszenia liczby pierwszej

inn_loop_cont:				#gdy reszta z dzielenia 0
movq %rax, %r14				#przenosze wynik z dzielenia do r9
movq %rcx, %rax				#przenosze liczbe pierwsza do rax
movq %rdi, %rsi
ascii_loop:
xor %rdx, %rdx
div %r8						#dziele liczbe pierwsza przez 10 aby uzyskac znak
add $'0', %rdx				#dodaje do reszty wartosc znaku 0
push %rdx					#wrzucam na stos
inc %rsi					#zwiekszam wewnetrzny licznik dla liczby znakow pierwszego
cmp $0, %rax				#czynnika
jnz ascii_loop
jz add_to_arr

add_to_arr:
pop %rax					#biore ze stosu po kolei cyfry czynnika
mov %rax, (%rbx,%rdi,1)		#wsadzam je do tablicy znakow podanej w funkcji
inc %rdi					#zwiekszam calkowita liczbe znakow do wypisania
cmp %rsi , %rdi				#porownuje czy wszystkie cyfry czynnika juz zostaly dodane
jnz add_to_arr
jz arr_finish

arr_finish:
movb $'*', (%rbx,%rdi,1)	#dodaje znak mnozenia
inc %rdi					#zwiekszam calkowita liczbe znakow
mov %r14, %rax				#przygotowuje do dzielenia w inn_loop
jmp inn_loop

out_loop_cont:
inc %rcx				#szukam kolejnej liczby pierwszej
movq %r14, %rax			#przygotowuje do porownania liczby z '1'
jmp out_loop

end:
dec %rdi					#zmniejszam licznik zeby pozbyc sie ostatniego znaku mnozenia
movb $'\n' , (%rbx,%rdi,1)	#dodaje znak konca linii
inc %rdi					
movb $0 , (%rbx,%rdi,1)		#dodaje '0' aby zakonczyc lancuch znakow
inc %rdi
dx:
push %rdi					#wrzucam calkowita liczbe znakow na stos
mov %rbp, %rsp				#ustawiam %rsp na OLD RBP
pop %rbp					#pobieram OLD RBP
ret							#wracam do adresu 
