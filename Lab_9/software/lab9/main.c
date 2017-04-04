
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

#define to_hw_port (volatile char*) TO_HW_PORT_BASE
#define to_hw_sig (volatile char*) TO_HW_SIG_BASE
#define to_sw_port (volatile char*) TO_SW_PORT_BASE
#define to_sw_sig (volatile char*) TO_SW_SIG_BASE

int main()
{
    int i;
    unsigned char plainText[33]; //should be 1 more character to account for string terminator
    unsigned char plainKey[33];

    // Start with pressing reset
    *to_hw_sig = 0;
    *to_hw_port = 0;
    printf("Press reset!\n");
    while (*to_sw_sig != 3);

    while (1) {
        *to_hw_sig = 0;
        printf("\n");

        printf("\nEnter plain text:\n");
        scanf ("%s", plainText);
        printf ("\n");
        printf("\nEnter key:\n");
        scanf ("%s", plainKey);
        printf ("\n");

        // Convert message and key from strings to byte arrays
        unsigned char message[16];
        unsigned char key[16];

        for (int i = 0; i < 16; i++) {
            message[i] = charsToHex(plainText[2*i], plainText[2*i+1]);
            key[i] = charsToHex(plainKey[2*i], plainKey[2*i+1]);
        }

        // Declare an array for the result and put the encrypted message there
        unsigned char encryptedMsg[16];
        encryptAES(message, key, encryptedMsg);

        // Display the encrypted message
        printf("\nEncrypted message is\n");
        for (int i = 0; i < 16; i++) {
            printf("%x", encryptedMsg[i]);
        }
        putchar('\n');
        fflush(stdout);

        // Transmit encrypted message to hardware side for decryption.
        printf("\nTransmitting message...\n");

        for (i = 0; i < 16; i++) {
            *to_hw_sig = 1;
            *to_hw_port = encryptedMsg[i];

            while (*to_sw_sig != 1);
            *to_hw_sig = 2;
            while (*to_sw_sig != 0);
        }
        *to_hw_sig = 0;

        // Transmit encrypted message to hardware side for decryption.
        printf("\nTransmitting key...\n");

        for (i = 0; i < 16; i++) {
            *to_hw_sig = 2;
            *to_hw_port = key[i];

            while (*to_sw_sig != 1);
            *to_hw_sig = 1;
            while (*to_sw_sig != 0);
        }
        *to_hw_sig = 0;

        printf("\n\n");

        // Initiate AES decryption
        *to_hw_sig = 3;

        // Wait for the AES module to finish
        while (*to_sw_sig != 2);

        // Indicate that we're ready to receive the result
        *to_hw_sig = 1;

        // Start retrieving the message
        printf("\nRetrieving message...\n");

        unsigned char decodedMessage[16];
        for (i = 0; i < 16; ++i) {

            // Ready to receive byte
            *to_hw_sig = 1;

            // Wait for hardware to be ready to send
            while (*to_sw_sig != 1);

            // Read value from hardware
            decodedMessage[i] = *to_sw_port;

            // Confirm receipt of data
            *to_hw_sig = 2;

            // Wait for hardware to acknowledge receipt of data
            while (*to_sw_sig != 0);
        }

        // Return to wait state
        *to_sw_sig = 0;

        //printf("\n\n");

        printf("Decoded message:\n");
        for (i = 0; i < 16; i++) {
            printf("%X", decodedMessage[i]);
        }
        putchar('\n');
        fflush(stdout);
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
