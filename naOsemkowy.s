.data
STDIN = 0
STDOUT = 1
SYSREAD = 0
SYSWRITE = 1
SYSEXIT = 60
EXIT_SUCCESS = 0

POCZ_LICZB = 0x30	#kod ascii pierwszej cyfry - 0 (48)
NOWA_LINIA = 0xA	#kod ascii nowej linii - (10)

BUFLEN = 512

PODST_WEJ = 10		#podstawa systemu dziesiętna - liczba z wejścia
PODST_WYJ = 8		#podstawa systemu siódemkowa - na wyjście

komunikat: .ascii "Nie podano liczby\n"
komunikat_len = .-komunikat

.bss
#alokacja
.comm textin, 512	#bufor do ciągu wczytanego od użytkownika
.comm textinv, 512 	#bufor do którego wpiszemy ciąg w odwrotenj kolejności
.comm textout, 512	#bufor z wyjściową liczbą wypisanej w poprawnej kolejności

.text
.global main

#----------------------------------------------
#wczytanie liczby od użytkownika
main:
movq $SYSREAD, %rax
movq $STDIN, %rdi
movq $textin, %rsi
movq $BUFLEN, %rdx
syscall







#----------------------------------------------
#odczyt z ascii do liczby
movq %rax, %rdi		#w rax siedzi liczba znaków, wrzucamy to do rdi - posłuży 
			#nam za licznik
movq %rax, %r9		#w r9 przechowujemy liczbę znaków (w rdi zostanie ona obniżona, bo to licznik)

sub $2, %r9		#nie bierzemy pod uwagę \n i liczymy od 0
sub $2, %rdi		#odejmujemy 2, bo: odejmujemy znak \n na końcu i będziemy
			#liczyć od zera, a nie od jedynki
movq $1, %rsi		#na razie do rsi wrzucamy pierwszą (dlatego 1) potęgę 10, 
			#później będziemy tu wrzucać kolejne potęgi (2,3...)
movq $0, %r8		#wynik końcowy, na razie wynosi 0

jmp petla_zamiany_na_liczby

#----------------------------------------------
petla_zamiany_na_liczby:

cmp $0, %rdi			#wyskoczenie z petli jesli licznik jest < 0,
				#czyli wszystkie liczby zostały odwiedzone
jl zamiana_na_osemkowy  	#wykonuje skok, jeśli rdi < 0
movq $0, %rax			#wczesniej bylo tu Sysread
movb textin(, %rdi, 1), %al	#odczyt (po jednym bajcie = 8bitów) litery
				#do rejestru al (rax wyzerowany),
				#8 bitowy fragment rax
sub $POCZ_LICZB, %al		#w al jest liczba, bo odjęliśmy pocz_liczb od ascii w
				#rejestrze al i zapisaliśmy wynik do al

#---Sprawdzenie czy cyfra---
cmp $PODST_WEJ, %al	#48 to 0 ... 57 to 9, więc x-48 jeśli jest większe niż 10
			#czyli podstawa systemu, znaczy, że wprowadzono złą liczbę
jge blad		#jge = jump if greater of equal

cmp $0, %al		#jeśli mniejsze od zera, to też nie wprowadzono cyfry
			#druga (wyższa) strona przedziału ascii
jl blad			#jump if less
#---Sprawdzenie czy cyfra --- koniec ---

mul %rsi		#wynik wpisuje do rejestru rax (tak działa mul)
			#mnożymy rsi (kolejne potęgi 10tki, najpierw 1) razy rax
			#(wcześniej wyzerowany)
			#(znajduje się tu tylko wartość zapisana w al - czyli nasza cyfra)
			#czyli np. 1 * 8, 10 * 7, 100 * 200 itd. Zapisujemy od końca
add %rax, %r8		#dodanie obecnego wyniku do globalnego (r8 trzyma wartość całej liczby)

#Wyliczenie kolejnej potęgi podstawy, czyli w tym przypadku 1, 10, 100 itd.
#która potęga (rsi) * 10 (PODST_WEJ) -> zapisanie wyniku do rsi
#Ale funckja mul wymaga umieszczenia mnożenj w rejestrze rax
#więc nie można od razu pomnoźyć rsi*podstawy i zapisać w rsi

movq %rsi, %rax
movq $PODST_WEJ, %rbx
mul %rbx
movq %rax, %rsi

#zmniejszenie licznika, czyli rdi i powrot na poczatek petli
dec %rdi
jmp petla_zamiany_na_liczby






#===Zamiana na system ósemkowy===

zamiana_na_osemkowy:

movq %r8, %rax		#zapisanie wyniku globalnego do raxa
movq $PODST_WYJ, %rbx	#zapisanej podstawy wyjściowej do rbx (rbx zawsze trzyma podstawy)
movq $0, %rcx		#wyzerowanie rcx - licznik
jmp zamiana_na_system_wyj	


zamiana_na_system_wyj:
movq $0, %rdx		#rdx wcześniej trzymał B/2 - 1
div %rbx		#dzielenie bez znaku liczby z rejestru rax (wynik globalny) przez rbx
			#(podstawa wyjściowego systemu), zapis wyniku do rax, a reszta z dzielenia
			#do rdx

#Reszta zapisana w rdx to część wyniku po konwersji
add $POCZ_LICZB, %rdx		#Dodanie kodu znaku pierwszej liczby - zakodowanie w ascii
mov %dl, textinv(,%rcx,1)	#zapisanie z dl do bufora w odwrotnej kolejności

inc %rcx					#zwiększenie licznika
cmp $0, %rax					#czy wynik dzielenia jest juz zerowy
jne zamiana_na_system_wyj			#jeśli nie, rób pętle zamiany na system dalej
jmp odwrocenie_kolejnosci_przygotowanie		#jeśli tak, odwróć kolejność

#----------------------------------------------
odwrocenie_kolejnosci_przygotowanie:

movq $0, %rdi
movq %rcx, %rsi		#zapisanie do licznika rsi tego, co bylo w liczniku rcx
			#a jest tam liczba cyfr zamienionej liczby na system wyjsciowy
dec %rsi		#odejmujemy ostatni przypadek, w którym wynik okazuje sie juz zerowy
			#tego zera nie należy rozpatrywać
jmp odwrocenie_kolejnosci

odwrocenie_kolejnosci:
movq textinv(,%rsi,1), %rax	#zapisznie do raxa ostatniej cyfry wyniku
movq %rax, textout(, %rdi, 1) 	#z raxa do wynikowego bufora
# w ten sposób tworzona jest dobra kolejność

inc %rdi	#zwiększenie licznika pętli
dec %rsi	#zmniejszenie licznika, który liczy cyfry
cmp %rcx, %rdi	#porównanie licznika pętli z wartością ile razy pętla ma się wykonać, a ma się
		#wykonać tyle razy, ile jest cyfr w systemie wyjściowym - liczba tych cyfr w rcx

jle odwrocenie_kolejnosci
jmp wyswietl_wynik


#----------------------------------------------
#wyświetlenie wyniku - zamienionej liczby na system wyjsciowy
wyswietl_wynik:

movb $NOWA_LINIA, textout(, %rcx, 1)		#w rcx liczba cyfr wyniku
inc %rcx					#zwiększenie rcx, bo teraz jeszcze wpisaliśmy \n

movq $SYSWRITE, %rax
movq $STDOUT, %rdi
movq $textout, %rsi
movq %rcx, %rdx					#długość ciągu znaków
syscall
jmp exit


#----------------------------------------------
#wyświetlanie komunikatu o błędzie
blad:
movq $SYSWRITE, %rax
movq $STDOUT, %rdi
movq $komunikat, %rsi
movq $komunikat_len, %rdx
syscall



#----------------------------------------------
exit:
#zakończenie programu
movq $SYSEXIT, %rax
movq $EXIT_SUCCESS, %rdi
syscall








