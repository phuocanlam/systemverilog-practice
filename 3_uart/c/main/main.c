/**
 * Write a function to convert a number based 2, 8, 10, 16 to string 
 */

#include <stdio.h>

void disp(int n, int base, int len) {
    char buf[33];
    char *str;
    char ch, sign;
    int rem, i;
    unsigned int un;

    if (base != 2 && base != 8 && base != 16)   
    {
        base = 10;
    }

    if (len > 32) {
        len = 32;
    }
    /* handle neg decimal # */
    if (base == 10 && n < 0)
    {
        un = (unsigned) -n;
        sign = '-';
    } else {
        un = (unsigned) n;
        sign = ' ';
    }
    // printf("un = : %d\n", un);
    // printf("sign = : %c\n", sign);
    /* convert # to string */
    str = &buf[33];
    *str = '\0';
    i = 0;
    printf("str = %s\n", str);
    do
    {   
    str--;
        rem = un % base;
        un  = un / base;
        if (rem < 10) {
            ch = (char) rem + '0';
        }
        else { 
            ch = (char) rem - 10 + 'a';
        }
        *str = ch;
        i++;
        
    } while (un);
    printf("str result step 1 = %s\n", str);
    /* attach - sign for neg decimal # */
    if (sign == '-')
    {
        str--;
        *str = sign;
        i++;
    }
    printf("str result step 2 = %s\n", str);
    /* pad with blank */
    while (i < len) {
        str--;
        *str = ' ';
        i++;
    };
    printf("str result step 3 = %s\n", str);

}

void main() {
    printf(" Hello World\n");
    printf(" Test 1\n");
    disp (-255, 10, 6);
    printf(" Test 2\n");
    disp (765, 10, 6);
    printf(" Test 3\n");
    disp (7622, 10, 6);
    printf(" Test 4\n");
    disp (-7622, 10, 6);
    printf(" Test 5\n");
    disp (-76222222, 10, 6);
    printf(" Test 6\n");
    disp (15, 16, 8);
    printf(" Test 7\n");
    disp (15, 2, 8);
}