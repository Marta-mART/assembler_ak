#include <stdio.h>
 
// Deklaracja zmiennej przechowującej ciąg znaków do konwersji
int liczba = 1233;
char buf[10] = {0};
char textinv[10] = {0};

int main(void)
{
    //
    // Wstawka Asemblerowa
    //
    asm(


"movq $0, %%rax \n"
"movl %0, %%eax \n"		//zapisanie wyniku globalnego do raxa
"movq $8, %%rbx \n"		//zapisanej podstawy wyjściowej do rbx (rbx zawsze trzyma podstawy)
"movq $0, %%rcx \n"		//wyzerowanie rcx - licznik
"jmp zamiana_na_system_wyj \n"	


"zamiana_na_system_wyj: \n"
"movq $0, %%rdx\n"		//rdx wcześniej trzymał B/2 - 1
"div %%rbx\n"			//dzielenie bez znaku liczby z rejestru rax (wynik globalny) przez rbx
				//(podstawa wyjściowego systemu), zapis wyniku do rax, a reszta z dzielenia
				//do rdx

//Reszta zapisana w rdx to część wyniku po konwersji
"add $0x30, %%rdx\n"		//Dodanie kodu znaku pierwszej liczby - zakodowanie w ascii
"mov %%dl, (%2,%%rcx,1)\n"	//zapisanie z dl do bufora w odwrotnej kolejności

"inc %%rcx\n"					//zwiększenie licznika
"cmp $0, %%rax\n"				//czy wynik dzielenia jest juz zerowy
"jne zamiana_na_system_wyj\n"			//jeśli nie, rób pętle zamiany na system dalej
"jmp odwrocenie_kolejnosci_przygotowanie\n"     //jeśli tak, odwróć kolejność


"odwrocenie_kolejnosci_przygotowanie:\n" 

"movq $0, %%rdi\n" 
"movq %%rcx, %%rsi\n" 		//zapisanie do licznika rsi tego, co bylo w liczniku rcx
				//jest tam liczba cyfr zamienionej liczby na system wyjsciowy
"dec %%rsi\n" 			//odejmujemy ostatni przypadek, w którym wynik okazuje sie juz zerowy
				//tego zera nie należy rozpatrywać
"jmp odwrocenie_kolejnosci\n" 

"odwrocenie_kolejnosci:\n" 
"movq (%2,%%rsi,1), %%rax\n" 		//zapisznie do raxa ostatniej cyfry wyniku
"movq %%rax, (%1, %%rdi, 1) \n" 	//z raxa do wynikowego bufora
					// w ten sposób tworzona jest dobra kolejność

"inc %%rdi\n" 		//zwiększenie licznika pętli
"dec %%rsi\n" 		//zmniejszenie licznika, który liczy cyfry
"cmp %%rcx, %%rdi\n" 	//porównanie licznika pętli z wartością ile razy pętla ma się wykonać, a ma się
			//wykonać tyle razy, ile jest cyfr w systemie wyjściowym - liczba tych cyfr w rcx

"jle odwrocenie_kolejnosci\n" 


 
    :// Nie mamy żadnych parametrów wyjściowych. Jeśli by takie były
    // należało by je zadeklarować podobnie jak w lini poniżej, jednak
    // zamiast "r" należało by użyć "r=". Spowodowało by to przeniesienie
    // wartości z rejestru oznaczonego w kodzie jako %0, %1 itp. do zmiennej
    // po wykonaniu wstawki.
 
    :"r"(liczba), "r"(&buf), "r"(&textinv) // Lista parametrów wejściowych - zmiennych które zostaną
    // zapisane do rejestrów i będzie możliwy ich odczyt w kodzie Asemblerowym.
    // Podobnie jak wyżej - są one dostępne jako aliasy na rejestry - %0, %1 itp.
 
    :"%rax", "%rbx", "%rcx", "%rdx", "%rsi", "%rdi" // Rejestry których będziemy używać w kodzie Asemblerowym.
    );
 
    
    //Wyświetlenie wyniku
    printf("Wynik: %s\n", buf);
 
    // Zwrot wartości EXIT_SUCCESS
    return 0;
}
