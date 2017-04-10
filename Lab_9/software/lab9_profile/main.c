
/*---------------------------------------------------------------------------
  --      hello_world.c                                                    --
  --      Christine Chen                                                   --
  --      Fall 2013                                                           --
  --                                                                       --
  --      Updated Spring 2015                                                --
  --      Yi Liang                                                           --
  --                                                                       --
  --      For use with ECE 385 Experiment 9                                --
  --      UIUC ECE Department                                              --
  ---------------------------------------------------------------------------*/


#include <stdio.h>
#include <stdlib.h>

#include "system.h"

#include "main.h"
#include "aes.h"

#define to_hw_port (volatile char*) TO_HW_PORT_BASE // actual address here
#define to_hw_sig (volatile char*) TO_HW_SIG_BASE // actual address here
#define to_sw_port (char*) TO_SW_PORT_BASE // actual address here
#define to_sw_sig (char*) TO_SW_SIG_BASE // actual address here

int main()
{
//    unsigned char plainText[33]; //should be 1 more character to account for string terminator
//    unsigned char plainKey[33];

    // Start with pressing reset
    *to_hw_sig = 0;
    *to_hw_port = 0;
    printf("Press reset!\n");
    while (*to_sw_sig != 3);

    while (1) {
        *to_hw_sig = 0;

        // Convert message and key from strings to byte arrays
        unsigned char message[16] = {0xEC, 0xE2, 0x98, 0xDC, 0xEC, 0xE2, 0x98, 0xDC,
                0xEC, 0xE2, 0x98, 0xDC, 0xEC, 0xE2, 0x98, 0xDC};
        unsigned char key[16] = {0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08,
                0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F};

        int counter = 0;
		while (1) {
			counter++;
			// Declare an array for the result and put the encrypted message there
			unsigned char encryptedMsg[16];
			encryptAES(message, key, encryptedMsg);

			if (counter % 10 == 0)
				printf("\r%6d\n", counter);
		}
    }
    return 0;
}

char charToHex(char c)
{
    char hex = c;

    if (hex >= '0' && hex <= '9')
        hex -= '0';
    else if (hex >= 'A' && hex <='F')
    {
        hex -= 'A';
        hex += 10;
    }
    else if (hex >= 'a' && hex <='f')
    {
        hex -= 'a';
        hex += 10;
    }
    return hex;
}

char charsToHex(char c1, char c2)
{
    char hex1 = charToHex(c1);
    char hex2 = charToHex(c2);
    return (hex1 << 4) + hex2;
}
