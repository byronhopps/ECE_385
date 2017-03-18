#include "aes.h"

void encryptAES(unsigned char plaintext[17], unsigned char key[17], unsigned char cipherText[17])
{

    // Calculate round keys
    unsigned char roundKeys[11][4][4];
    keyExpansion(key, roundKeys);

    // Transpose inputs into column-major state matrix
    unsigned char state[4][4];
    transpose(plaintext, state);

    // Begin AES encryption
    addRoundKey(state, roundKeys[0]);

    for (int round = 0; round < 9; round++ ) {
        subBytes(state);
        shiftRows(state);
        mixColumns(state);
        addRoundKey(state, roundKeys[round+1]);
    }

    subBytes(state);
    shiftRows(state);
    addRoundKey(state, roundKeys[10]);

    return;
}

void subBytes(unsigned char state[4][4])
{
    // Substitute the values in each state element
    for (int row = 1; row < 4; row++) {
        for (int col = 0; col < 4; col++) {

            // state[row][col] = {8'upperNibble, 8'lowerNibble}
            unsigned char upperNibble = (state[row][col] >> 8) & 0x00FF;
            unsigned char lowerNibble = (state[row][col] >> 0) & 0x00FF;

            state[row][col] = aes_sbox[upperNibble][lowerNibble];
        }
    }

    return;
}

void shiftRows(unsigned char state[4][4])
{
    // Temporary register to keep the function atomic
    unsigned char tempRow[4];

    // Start at the second row, since the first row doesn't change
    for (int row = 1; row < 4; row++) {

        // Copy current row into temporary register
        for (int col = 0; col < 4; col++)
            tempRow[col] = state[row][col];

        // Overwrite the current state with the shifted values
        for (int col = 0; col < 4; col++)
            state[row][col] = tempRow[(col+row) % 4];
    }

    return;
}

void mixColumns(unsigned char state[4][4])
{
    // Variable to save the state of the current column
    unsigned char tempCol;

    for (int col = 0; col < 4; col++) {

        // Save the state of the current column
        for (int row = 0; row < 4; row++)
            tempCol[row] = state[row][col];

        // Write the new values to the current column
        state[0][col] = gf_mul[tempCol[0]][0] ^ gf_mul[tempCol[1]][1] ^ tempCol[2] ^ tempCol[3];
        state[1][col] = tempCol[0] ^ gf_mul[tempCol[1]][0] ^ gf_mul[tempCol[2]][1] ^ tempCol[3];
        state[2][col] = tempCol[0] ^ tempCol[1] ^ gf_mul[tempCol[2]][0] ^ gf_mul[tempCol[3]][1];
        state[3][col] = gf_mul[tempCol[0]][1] ^ tempCol[1] ^ tempCol[2] ^ gf_mul[tempCol[3]][0];
    }

    return;
}

void addRoundKey(unsigned char state[4][4], unsigned char key[4][4])
{
    for (int i = 0; i < 4; i++)
        for (int j = 0; j < 4; j++)
            state ^= key;

    return;
}

void keyExpansion(unsigned char key[17], unsigned char roundKeys[11][4][4])
{
    // nk = 4
    unsigned char temp[4];

    // Copy the key into roundKeys[0]
    for (int col = 0; col < 4; col++)
        for (int row = 0; row < 4; row++ )
            roundKeys[0][row][col] = key[row + 4*col];

    // For the rest of the keys, XOR the
    for (int i = 1; i < 11; i++) {
        for (int col = 0; col < 4; col++) {

            // Assign temp as the previous word
            for (int row = 0; row < 4; row++) {
                if (col == 0)
                    temp[row] = roundKeys[i-1][row][3];
                else
                    temp[row] = roundKeys[i][row][col-1];
            }

            if (col == 0) {
                subWord(rotWord(temp));

                // Only need to XOR the first byte of the word
                temp[0] ^= (Rcon[i-1]) >> 24;
            }

            // Current word of key is temp XOR with current word of previous key
            for (int row = 0; row < 4; row++) {
                roundKeys[i][row][col] = roundKeys[i-1][row][col] ^ temp[row];
            }
        }
    }

    return;
}

void subWord(unsigned char word[4])
{
    // Substitute for each element in the word
    for (int i = 0; i < 4; i++) {

        // word[i] = {8'upperNibble, 8'lowerNibble}
        unsigned char upperNibble = (word[i] >> 8) & 0x00FF;
        unsigned char lowerNibble = (word[i] >> 0) & 0x00FF;

        word[i] = aes_sbox[upperNibble][lowerNibble];
    }

    return;
}

void rotWord(unsigned char word[4])
{
    // A place to hold the result so this operation can be atomic
    unsigned char temp[4];

    // Rotate the current word by one byte
    for (int i = 0; i < 4; i++)
        temp[i] = word[(i+1) % 4];

    // Copy the temporary word into the result vector
    for (int i = 0; i < 4; i++)
        word[i] = temp[i];

    return;
}

// Transpose the input into the 4x4 output matrix in column-major ordering
void transpose(unsigned char input[17], unsigned char output[4][4])
{
    for (int col = 0; col < 4; col++)
        for (int row = 0; row < 4; row++)
            output[row][col] = input[row + 4*col];

    return;
}
