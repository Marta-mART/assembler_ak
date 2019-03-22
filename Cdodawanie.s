.data
STDOUT = 1
SYSREAD = 0
SYSWRITE = 1
SYSOPEN = 2
SYSCLOSE = 3
EXIT_SUCCESS = 0
SYSEXIT = 60

format_d: .asciz "%d"		#Łańcuch znaków do wywołania scanf
format_f: .asciz "%f"		#Łańcuch znaków do wywołania printf
format_l: .asciz "%lf/n"		#Łańcuch znaków do wywołania printf
nowa_linia: .asciz "/n"

.bss
.comm liczba1, 4		#Bufory na liczby typu int, float i double
.comm liczba2, 4
.comm liczba3, 8

.text
.global main

main:


#===Wczytanie liczby typu int===
movq $0, %rax			#Wczytujemy zero elementów zmiennoprzecinkowych
movq $format_d, %rdi 		#Pierwszy parametr całkowity dla scanf - format wyniku
movq $liczba1, %rsi		#Drugi parametr całkowity dla scanf - adres bufora
call scanf			#Wywolanie scanf z biblioteki stdio

#===Wczytywanie float===
movq $0, %rax
movq $format_f, %rdi
movq $liczba2, %rsi
call scanf

#===Wczytywanie double===
movq $0, %rax
movq $format_l, %rdi
movq $liczba3, %rsi
call scanf

movq $1, %rax			#Jeden arg zmiennoprzecinkowy - przesyłany jeden parametr w rejestrze XMM0
movq $0, %rdi			#Czyszcenie rdi
movq $0, %rcx			#Licznik, by adresować pamieć poniżej
mov liczba1(, %rcx, 4), %edi	#Przeniesienie pierwszego parametru - typ int - do rdi

movss liczba2, %xmm0		#Przeniesienie drugiego parametru - typu zmiennoprzecinkowego do rejestru XMM0
movsd liczba3, %xmm1		#Przeniesienie drugiego parametru - typu zmiennoprzecinkowego do rejestru XMM0

sub $8, %rsp	
dod:
call dodawanie
#cvtps2pd %xmm0, %xmm0		#Konwersja wyniku na double, aby wyświetlić przez funkcje printf
add $8, %rsp	

#===Wyswietlenie wyniku z uzycie funkcji printf

mov $1, %rax			#Jednen parametr zmiennoprzecinkowy - liczba do wyswietlenia w rejestrze XMM0
mov $format_l, %rdi		
sub $8, %rsp			#Żeby printf nie zmienił wartości ostatniej komórki na stosie
call printf
add $8, %rsp

#===Znak nowej linii===
movq $0, %rax			#Nie przesyłamy parametrów zmiennoprzecinkowych
movq $nowa_linia, %rdi		#Parametr typu int
				#wsk na ciąg znaków do wyświetlenia
				#Znak nowej linii
call printf


#===Koniec programu===
mov $SYSEXIT, %rax
mov $EXIT_SUCCESS, %rdi
syscall

