void encryptAES(unsigned char plaintext[17], unsigned char key[17], unsigned char cipherText[17])
{

    // Calculate round keys
    unsigned char roundKeys[12][4][4];
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
        addRoundKey(state, roundKeys[i+1]);
    }

    subBytes(state);
    shiftRows(state);
    addRoundKey(state, roundKeys[11]);

    return;
}

// TODO: implement this
void subBytes(unsigned char state[4][4])
{
}

// TODO: implement this
void shiftRows(unsigned char state[4][4])
{
}

// TODO: implement this
void mixColumns(unsigned char state[4][4])
{
}

void addRoundKey(unsigned char state[4][4], unsigned char[4][4] key)
{
    for (int i = 0; i < 4; i++)
        for (int j = 0; j < 4; j++)
            state ^= key;

    return;
}

void keyExpansion(unsigned char key[17], unsigned char roundKeys[12][4][4])
{
    // nk = 4
    unsigned char temp[4];

    // Copy the key into roundKeys[0]
    for (int col = 0; col < 4; col++)
        for (int row = 0; row < 4; row++ )
            roundKeys[0][row][col] = key[row + 4*col];

    // For the rest of the keys, XOR the
    for (int i = 1; i < 12; i++) {
        for (int col = 0; col < 4; col++) {

            // Assign temp as the previous word
            for (int row = 0; row < 4; row++) {
                if (col == 0)
                    temp[row] = roundKeys[i-1][row][3];
                else
                    temp[row] = roundKeys[i][row][col-1]
            }

            if (col == 0) {
                subWord(rotWord(temp));
                temp ^= Rcon[i-1];
            }

            // Current word of key is temp XOR with current word of previous key
            for (int row = 0; row < 4; row++) {
                roundKeys[i][row][col] = roundKeys[i-1][row][col] ^ temp[row];
            }
        }
    }

    return;
}

void subWord(unsigned char word[4], unsigned char result[4])
{
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
        result[i] = temp[i];

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
