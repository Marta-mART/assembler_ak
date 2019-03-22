.data
STDOUT = 1
SYSREAD = 0
SYSWRITE = 1
SYSOPEN = 2
SYSCLOSE = 3
FREAD = 0
FWRITE = 1
EXIT_SUCCESS = 0
SYSEXIT = 60

file_in_1: .ascii "in_1.txt\0"	#w tej ścieżce znajduje się pierwsza liczba zapisana czwórkowo
file_in_2: .ascii "in_2.txt\0"	#-||- druga liczba zapisana czwórkowo
file_out: .ascii "result.txt\0" #wynik dodawania
 
max_input_len = 246
max_val_len = 128
max_out_len = 64

.bss
.comm in_1, max_input_len	#wczytujemy dużą liczbę w systemie czworkowym
.comm in_2, max_input_len	#druga liczba czwórkowa
.comm out, max_out_len 		#bufor zawiera wynikowy ciąg ascii

.comm result_in_1, max_val_len		#pierwsza liczba w postaci bajtowej
.comm result_in_2, max_val_len		#druga liczba
.comm result_out, max_val_len		#wynik 


.text
.globl _start

_start:


movq $max_val_len, %r8			#licznik dla pętli, która zeruje
movb $0, %al			#wstawiamy 0

petla_zerujaca:
dec %r8
mov %al, result_in_1(, %r8, 1)	#zapisywanie 0 z al do bufora pierwszego
mov %al, result_in_2(, %r8, 1)	#zapisywanie 0 z al do bufora pierwszego
mov %al, out(, %r8,1)
cmp $0, %r8			#sprawdzamy licznik 
jg petla_zerujaca


#----------------------------------------------
#PIERWSZY CIĄG
#----------------------------------------------

#Wczytanie pierwszego ciągu
#----------------------------------------------
#Otwarcie pliku file_in_1 do odczytu i wczytanie ascii pierwszej liczby czwórkowej

wczytaj1:
movq $SYSOPEN, %rax
movq $file_in_1, %rdi
movq $FREAD, %rsi
movq $0, %rdx
syscall
mov %rax, %r10			#identyfikator pliku będzie w r10


#Z pliku do bufora
movq $SYSREAD, %rax
movq %r10, %rdi			#tak jaby z stdin (podajemy id pliku, które jest w r10)
movq $in_1, %rsi			
movq $max_input_len, %rdx
syscall
movq %rax, %r8			#liczba odczytanych bajtów w r8 (r8 był licznikiem, można ponownie
				#go użyć)

#Zamknięcie pliku
movq $SYSCLOSE, %rax
movq %r10, %rdi
movq $0, %rsi
movq $0, %rdx
syscall

#----------------------------------------------

#Dekodowanie wartości pliku
dec %r8				#nie bierzemy pod uwagę znaku '/n'
movq $max_val_len, %r9			#licznik, będziemy zapisywać od końca
				#dekodowane wartości na koniec bufora

petla_dekodujaca_1:
dec %r8				#obniżamy licznik liczby znaków, żeby liczył od 0
dec %r9				#obniżamy licznik, który zapisuje od końca bufora

#Dekodowanie pierwszych 2 bitów 
movb in_1(, %r8, 1), %al	#wczytanie kodu ascii do rejestru al
sub $48, %al			#uzyskiwanie liczby z ascii

cmp $0, %r8			#jeśli pozostała liczba znaków do odczytania jest równa zero, to
				#ciąg się skończył i możemy zapisać do bufora
jle zakoduj_do_bufora


#Dekodowanie kolejnych 2 bitów
dec %r8
mov in_1(, %r8, 1), %bl		#Pobranie kolejnej cyfry
sub $48, %bl			#Zdekodowanie z ascii na liczbę
shl $2, %bl			#Przesunięcie bitowe w lewo o 2 (na dwóch miejscach można zapisać
				#nawiększą cyfrę - 3 w systemie czwórkowym), bl jest rejestrem
				#pomocniczym, służącym do przesuwania aktualnie umieszczanej cyfry
add %bl, %al 			#Dodanie tych właśnie przesuniętych dwóch bitów do poprzednich

cmp $0, %r8			#Porównianie, czy cyfry się nie skończyły i nie trzeba skończyć
jle zakoduj_do_bufora

	
#Kodowanie kolejnych 2 bitów
dec %r8
mov in_1(, %r8, 1), %bl		#Pobranie kolejnej cyfry
sub $48, %bl			#Zdekodowanie z ascii na liczbę
shl $4, %bl			#Przesunięcie bitowe w lewo o 4 (na dwóch miejscach można zapisać
				#nawiększą cyfrę - 3 w systemie czwórkowym)
add %bl, %al 			#Dodanie tych właśnie przesuniętych dwóch bitów do poprzednich

cmp $0, %r8			#Porównianie, czy cyfry się nie skończyły i nie trzeba skończyć
jle zakoduj_do_bufora


#Kodowanie kolejnych 2 bitów
dec %r8
mov in_1(, %r8, 1), %bl		#Pobranie kolejnej cyfry
sub $48, %bl			#Zdekodowanie z ascii na liczbę
shl $6, %bl			#Przesunięcie bitowe w lewo o 6 (na dwóch miejscach można zapisać
				#nawiększą cyfrę - 3 w systemie czwórkowym)
add %bl, %al 			#Dodanie tych właśnie przesuniętych dwóch bitów do poprzednich

cmp $0, %r8			#Porównianie, czy cyfry się nie skończyły i nie trzeba skończyć
jle zakoduj_do_bufora


#Zapisanie wartości (cały rejestr al się zapełnił albo nie zapałnił, bo było mniej cyfr, ale były tam już zera w al, więc jest w porządku)

zakoduj_do_bufora:
mov %al, result_in_1(, %r9, 1)	#Zapisanie zdekodowanego bajtu do bufora wynikowego

cmp $0, %r8			#Powrót na początek, aby dekodować dalej cyfry, jeśli się nie
				#skończyły
jg petla_dekodujaca_1


#----------------------------------------------
#Drugi ciąg
#----------------------------------------------

zpliku:
#Otwarcie pliku file_in_2 do odczytu i wczytanie ascii pierwszej liczby czwórkowej

movq $SYSOPEN, %rax
movq $file_in_2, %rdi
movq $FREAD, %rsi
movq $0, %rdx
syscall
mov %rax, %r10			#identyfikator pliku będzie w r10


#Z pliku do bufora
movq $SYSREAD, %rax
movq %r10, %rdi			#tak jaby z stdin (podajemy id pliku, które jest w r10)
movq $in_2, %rsi			
movq $max_input_len, %rdx
syscall
movq %rax, %r11			#liczba odczytanych bajtów w r11 



#----------------------------------

#Dekodowanie wartości pliku
dec %r11				#nie bierzemy pod uwagę znaku '/n'
movq $max_val_len, %r9		#licznik, będziemy zapisywać od końca
				#dekodowane wartości na koniec bufora


petla_dekodujaca_2:
dec %r11				#obniżamy licznik liczby znaków, żeby liczył od 0
dec %r9				#obniżamy licznik, który zapisuje od końca bufora

#Dekodowanie pierwszych 2 bitów 
movb in_2(, %r11, 1), %al	#wczytanie kodu ascii do rejestru al
sub $48, %al			#uzyskiwanie liczby z ascii

cmp $0, %r11			#jeśli pozostała liczba znaków do odczytania jest równa zero, to
				#ciąg się skończył i możemy zapisać do bufora
jle zakoduj_do_bufora2


#Dekodowanie kolejnych 2 bitów
dec %r11
mov in_2(, %r11, 1), %bl	#Pobranie kolejnej cyfry
sub $48, %bl			#Zdekodowanie z ascii na liczbę
shl $2, %bl			#Przesunięcie bitowe w lewo o 2 (na dwóch miejscach można zapisać
				#nawiększą cyfrę - 3 w systemie czwórkowym), bl jest rejestrem
				#pomocniczym, służącym do przesuwania aktualnie umieszczanej cyfry
add %bl, %al 			#Dodanie tych właśnie przesuniętych dwóch bitów do poprzednich

cmp $0, %r11			#Porównianie, czy cyfry się nie skończyły i nie trzeba skończyć
jle zakoduj_do_bufora2

	
#Kodowanie kolejnych 2 bitów
dec %r11
mov in_2(, %r11, 1), %bl	#Pobranie kolejnej cyfry
sub $48, %bl			#Zdekodowanie z ascii na liczbę
shl $4, %bl			#Przesunięcie bitowe w lewo o 4 (na dwóch miejscach można zapisać
				#nawiększą cyfrę - 3 w systemie czwórkowym)
add %bl, %al 			#Dodanie tych właśnie przesuniętych dwóch bitów do poprzednich

cmp $0, %r11			#Porównianie, czy cyfry się nie skończyły i nie trzeba skończyć
jle zakoduj_do_bufora2


#Kodowanie kolejnych 2 bitów
dec %r11
mov in_2(, %r11, 1), %bl	#Pobranie kolejnej cyfry
sub $48, %bl			#Zdekodowanie z ascii na liczbę
shl $6, %bl			#Przesunięcie bitowe w lewo o 6 (na dwóch miejscach można zapisać
				#nawiększą cyfrę - 3 w systemie czwórkowym)
add %bl, %al 			#Dodanie tych właśnie przesuniętych dwóch bitów do poprzednich

cmp $0, %r11			#Porównianie, czy cyfry się nie skończyły i nie trzeba skończyć
jle zakoduj_do_bufora2


#Zapisanie wartości (cały rejestr al się zapełnił albo nie zapałnił, bo było mniej cyfr, ale były tam już zera w al, więc jest w porządku)

zakoduj_do_bufora2:
mov %al, result_in_2(, %r9, 1)	#Zapisanie zdekodowanego bajtu do bufora wynikowego

cmp $0, %r11			#Powrót na początek, aby dekodować dalej cyfry, jeśli się nie
				#skończyły
jg petla_dekodujaca_2

#----------------------------------------------
#Dodanie dwóch wartości
#----------------------------------------------

clc 				#Wyczyszczenie flagi przeniesienia z poprzedniej pozycji
pushfq				#Włożenie rejestru z flagą na stos
mov $max_input_len, %r8	#Licznik pętli

petla_dodajaca:

mov result_in_1(, %r8, 8), %rax	#Zapis wartości z budora do al (pierwsza liczba)-jej część końcowa
mov result_in_2(, %r8, 8), %rbx	#Zapis drugiej do bl 
popfq				#Pobranie zawartości rejestru flagowego ze stosu, bo instrukcja
				#cmp modyfikuje CF
adc %rbx, %rax			#Dodanie z propagacją i przeniesieniem
pushfq				#Umieszczenie rejestru flagowego na stosie
mov %rax, result_out(, %r8, 8)	#Zapis wyniku do bufora

dec %r8
cmp $8, %r8			#Powrót na początek pętli, jeśli licznik != 0
jnz petla_dodajaca		#Pętla się wykonuje dla każdej pozycji w buforze wyniku -
				#pozycję, czyli co każde 8 bitów

#----------------------------------------------
#Zamiana na szestnastkowy system 0x
#----------------------------------------------
movq $max_val_len, %r8			#licznik bajtów z bufora result
movq $max_out_len, %r9			#licznik znaków 16stkowych z bufora out

petla_konwersji_na_0x:

movq $0, %rax			#odczyt kolejnych bitów - 4 i przesuniecia bitowe, aby pobrac z bufora result do rejestru rax 4 kolejne bity

dec %r8

movb result_out(, %r8, 1), %al

movq $2, %r10			#Zagniezdzona petla bedzie wykonywac sie 2 razy, dla ostatniej czworki bitow i przedostatniej z 8bitowego rejestru

zagniezdzona_petla:
movb %al, %bl			#w bl ciąg 8 bitowy
andb $0xf, %bl			#usuniecie wszystkich bitow poza 4rema najmniej znaczacymi, logiczne AND

cmp $10, %bl
jl cyfra

#W przeciwnym razie kodujemy litere
add $39, %bl

cyfra:
add $48, %bl


movb %bl, out(, %r9, 1)		#Zapis znaku ascii do bufora wyjsciowego

shr $4, %rax			#Przesuniecie bitowe dotychczasowej linii, tak aby pozbyć się zdekodowanych juz 4 bitów

dec %r9				#Zmniejszenie licznika petli
dec %r10

cmp $0, %r10			#Skok z zagnieżdżonej pętli 298
jg zagniezdzona_petla


cmp $0, %r8	
jg petla_konwersji_na_0x
			

movq $0, %rdi
movq $max_out_len, %r8
inc %r8
movb $0x0A, out(, %r8, 1)
inc %r8



#-----Wyświetlanie------
#Wyświetlenie wyniku w konsoli
movq $SYSWRITE, %rax
movq $STDOUT, %rdi
movq $out, %rsi
movq %r8, %rdx
syscall


#Zapis wyniku 0x do pliku
#Otworzenie pliku
movq $SYSOPEN, %rax
movq $file_out, %rdi
movq $FWRITE, %rsi
movq $0644, %rdx
syscall
movq %rax, %r9

#Zapis z bufora out do pliku
movq $SYSWRITE, %rax
movq %r9, %rdi
movq $out, %rsi
movq %r8, %rdx
syscall

#Zamkniecie pliku
movq $SYSCLOSE, %rax
movq %r9, %rdi
movq $0, %rsi
movq $0, %rdx
syscall


#Zamknięcie pliku
movq $SYSCLOSE, %rax
movq %r10, %rdi
movq $0, %rsi
movq $0, %rdx
syscall

exit:
#Koniec programu
mov $SYSEXIT, %rax
mov $EXIT_SUCCESS, %rdi
syscall















