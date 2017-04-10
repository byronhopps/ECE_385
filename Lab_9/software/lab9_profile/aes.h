#ifndef AES_H
#define AES_H

// This function encrypts the data stored in the plaintext array (null-terminated),
//   storing the ciphertext in the array pointed to by cipherText
void encryptAES(unsigned char plaintext[17], unsigned char key[17], unsigned char cipherText[17]);

// AES helper functions
void subBytes(unsigned char state[4][4]);
void shiftRows(unsigned char state[4][4]);
void mixColumns(unsigned char state[4][4]);
void addRoundKey(unsigned char state[4][4], unsigned char key[4][4]);

// Key expansion stuff
void keyExpansion(unsigned char key[17], unsigned char roundKeys[11][4][4]);
void subWord(unsigned char word[4]);
void rotWord(unsigned char word[4]);

// Transpose the input into the 4x4 output matrix in column-major ordering
void transpose(unsigned char input[17], unsigned char output[4][4]);

// Constant declarations
extern const unsigned char aes_sbox[16][16];
extern const unsigned char aes_invsbox[16][16];
extern const unsigned char gf_mul[256][6];
extern const unsigned long Rcon[];

#endif // #ifndef AES_H
