.data
STDOUT = 1
SYSREAD = 0
SYSWRITE = 1
SYSOPEN = 2
SYSCLOSE = 3
EXIT_SUCCESS = 0
SYSEXIT = 60
STDIN = 0

seqSize = 64
SEARCHED = 48				#Kod ascii zera

komunikat_dl: .ascii "Dlugosc najdluzszego ciagu zer: "
komunikat_dl_len = .-komunikat_dl

komunikat_ind: .ascii "Znajduje sie pod indeksem: "
komunikat_ind_len = .-komunikat_ind

.bss
.comm seqWithZeros, seqSize
.comm out, 32
.comm out_ind, 32

.comm out_inv, 32
.comm out_ind_inv, 32

.text
.global main

main:

#===Wczytanie ciagu===
movq $SYSREAD, %rax
movq $STDIN, %rdi
movq $seqWithZeros, %rsi
movq $seqSize, %rdx
syscall

#===Dlugosc ciagu w rejestrze r8===
movq %rax, %r8
sub $2, %r8				#liczymy od zera
call funkcja_zer


#===Zmiana na ascii===
zmiana_na_ascii:


movq %r10, %rax
movq $0, %rdi

#===Petla uzyskujaca cyfry - ale w odwrotnej kolejnosci===
petla_zamiany:

movq $0, %rdx

movq $10, %rbx
div %rbx

add $48, %rdx				#dodanie 48 - zamiana na ascii
mov %dl, out_inv(, %rdi,1)


inc %rdi	#zwiększenie licznika pętli
cmp $0, %rax	

jne petla_zamiany
jmp odwrocenie_przygotowanie

#===Petla wpisujaca cyfry do bufora w dobrej kolejnosci===
odwrocenie_przygotowanie:
movq $0, %rcx
movq %rdi, %rsi

dec %rsi

petla_odwrocenia:
movq out_inv(,%rsi,1), %rax	#zapisznie do raxa ostatniej cyfry wyniku
movq %rax, out(, %rcx, 1) 	#z raxa do wynikowego bufora
# w ten sposób tworzona jest dobra kolejność

inc %rcx	#zwiększenie licznika pętli
dec %rsi	#zmniejszenie licznika, który liczy cyfry
cmp %rdi, %rcx	#porównanie licznika pętli z wartością ile razy pętla ma się wykonać, a ma się
		#wykonać tyle razy, ile jest cyfr w systemie wyjściowym - liczba tych cyfr w rcx

jle petla_odwrocenia
jmp procedura_dla_ind


#===Ta sama procedura dla r11===
procedura_dla_ind:

#===Zmiana na ascii - początek===
movq %r11, %rax
movq $0, %rdi

#===Petla uzyskujaca cyfry - ale w odwrotnej kolejnosci===
petla_zamiany_2:

movq $0, %rdx

movq $10, %rbx
div %rbx

add $48, %rdx				#dodanie 48 - zamiana na ascii
mov %dl, out_ind_inv(, %rdi,1)


inc %rdi	#zwiększenie licznika pętli
cmp $0, %rax	

jne petla_zamiany_2
jmp odwrocenie_przygotowanie_2

#===Petla wpisujaca cyfry do bufora w dobrej kolejnosci===
odwrocenie_przygotowanie_2:
movq $0, %r12
movq %rdi, %rsi

dec %rsi

petla_odwrocenia_2:
movq out_ind_inv(,%rsi,1), %rax	#zapisznie do raxa ostatniej cyfry wyniku
movq %rax, out_ind(, %r12, 1) 	#z raxa do wynikowego bufora
# w ten sposób tworzona jest dobra kolejność

inc %r12	#zwiększenie licznika pętli
dec %rsi	#zmniejszenie licznika, który liczy cyfry
cmp %rdi, %r12	#porównanie licznika pętli z wartością ile razy pętla ma się wykonać, a ma się
		#wykonać tyle razy, ile jest cyfr w systemie wyjściowym - liczba tych cyfr w rcx

jle petla_odwrocenia_2
jmp koniec_linii



koniec_linii:
movb $0x0A, out(, %rcx, 1)
movb $0x0A, out_ind(, %r12, 1)
inc %rcx
inc %r12

#===Wypisanie
wypisz:


movq $SYSWRITE, %rax
movq $STDOUT, %rdi
movq $komunikat_dl, %rsi
movq $komunikat_dl_len, %rdx
syscall


#Wyświetlenie wyniku w konsoli
movq $SYSWRITE, %rax
movq $STDOUT, %rdi
movq $out, %rsi
movq %rcx, %rdx
syscall


movq $SYSWRITE, %rax
movq $STDOUT, %rdi
movq $komunikat_ind, %rsi
movq $komunikat_ind_len, %rdx
syscall

#Wyświetlenie wyniku w konsoli
movq $SYSWRITE, %rax
movq $STDOUT, %rdi
movq $out_ind, %rsi
movq %r12, %rdx
syscall

exit:
#===Koniec programu===
mov $SYSEXIT, %rax
mov $EXIT_SUCCESS, %rdi
syscall


#===Funkcja===

funkcja_zer:
#===rsi - i w pętli
#===r9 - licznik liczby zer w aktualnym ciągu zer===
#===r10 - liczba poprzednich zer (najdłuższego, poprzedniego ciągu zer)===
#===r11 - indeks pierwszego zera najdluzszego ciagu===
movq $0, %rsi
movq $(-1), %r11
movq $0, %r10
movq $0, %r9


#===Petla wykonujaca sie aż do osiagniecia konca calego ciagu

petla_sprawdzajaca:

	cmp %r8, %rsi
	jg zmiana_na_ascii

	movb seqWithZeros(, %rsi, 1), %al	
	inc %rsi

	cmp $SEARCHED, %al	
	jne petla_sprawdzajaca
	
	#===Petla zagniezdzona===
	petla_zliczajaca_zera:
		cmp $SEARCHED, %al	
		jne przypisanie
		inc %r9
		
		movb seqWithZeros(, %rsi, 1), %al
		inc %rsi
		
	jmp petla_zliczajaca_zera		#Jesli licznik < dlugosci
	
przypisanie:
	cmp %r10, %r9
	jl zerowanie

	movq %r9, %r10
	movq %rsi, %r11
	dec %r11
	sub %r9, %r11
zerowanie:
	movq $0, %r9
	
jmp petla_sprawdzajaca
ret


