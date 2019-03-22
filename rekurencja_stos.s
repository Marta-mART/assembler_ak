.data
STDOUT = 1
SYSREAD = 0
SYSWRITE = 1
SYSOPEN = 2
SYSCLOSE = 3
EXIT_SUCCESS = 0
SYSEXIT = 60

LICZBA_WYRAZOW = 1
LICZBA_POCZ = 3

.text
.global main

main:

movq $(-1), %rbx
movq $LICZBA_WYRAZOW, %r9	#Liczba wyrazow ciagu w rejestrze r9
movq $1, %r11			#Flaga w r11

push %r9				#Wrzucenie liczby wyrazow ciagu na stos
call rekurencyjna		#Wywolanie funkcji rekurencyjnej
add $8, %rsp			#Usunięcie parametrów ze stosu poprzez przesunięcie wsk rsp, będą potem nadpisane

#WYNIK W RAX
				

exit:
#---Koniec programu---
mov $SYSEXIT, %rax
mov $EXIT_SUCCESS, %rdi
syscall

#===Funkcja rekurencyjna===

rekurencyjna:
	cmp $(-1), %rbx			#Spr czy juz wyliczono wszystkie wtrazy ciagu
	jne spr_flagi			#Jesli nie, obliczenia

	push %rbp			#Umieszczenie na stosie poprzedniej wartości rejestru bazowego
	mov %rsp, %rbp			#Pobranie zawartosci rejestru rsp (wsk na ost element stosu) do rejestru bazowego
	sub $8, %rsp			#Zwiększenie wskaźnika stosu o 1 komórkę (ominięcie adr powrotu)

	mov 16(%rbp), %rbx		#Zapisanie argumentu ze stosu do rejestru rbx

	spr_flagi:
	cmp $0, %r11			#Sprawdzenie, czy jest flaga, jeśli tak - początkowy zabieg
	je dalej

	#===Zabieg początkowy===
	#===Usuniecie flagi, wpisanie 3 jako liczbe rozpoczynajaca ciag===
	#===Zapisanie argumentu przekazanego przez stos w rejestrze rbx===
	dec %r11			#Flaga z 1 na 0
	mov $LICZBA_POCZ, %rax 		#Wkladamy 3 - liczbe od ktorej zaczynamy ciag
	cmp $1, %rbx			#Jesli ktos chce tylko jeden wyraz ciagu, konczymy wczesniej z wynikiem 3 w rax
	je czyszczenie


	dalej:
	cmp $0, %rbx			#Spr czy juz wyliczono wszystkie wtrazy ciagu
	jne obliczenia			#Jesli nie, obliczenia
	czyszczenie:
	mov %rbp, %rsp
	pop %rbp
	ret

	obliczenia:
	movq $(-5), %r10		# -5
	imul %r10			# -5 * x_(n-1)
	add $7, %rax			#-5 * x_(n-1) + 7 -> wynik do rax

	dec %rbx			#Obniżenie licznika
call rekurencyjna		#Rekurencyjne wywołanie funkcji - działania na raxie




