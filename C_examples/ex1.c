#include <stdio.h>
#include <cstdint>

int main() {
    uint8_t temp = 0xA5; // 10100101 in binary
    
    printf("Original value: 0x%X (%d)\n\n", temp, temp);
    
    // Bitwise AND
    printf("Bitwise AND (temp & 0x0F): 0x%X\n", temp & 0x0F);
    
    // Bitwise OR
    printf("Bitwise OR (temp | 0x50): 0x%X\n", temp | 0x50);
    
    // Bitwise XOR
    printf("Bitwise XOR (temp ^ 0xFF): 0x%X\n", temp ^ 0xFF);
    
    // Bitwise NOT
    printf("Bitwise NOT (~temp): 0x%X\n", ~temp & 0xFF);
    
    // Left shift
    printf("Left shift (temp << 2): 0x%X\n", (temp << 2) & 0xFF);
    
    // Right shift
    printf("Right shift (temp >> 2): 0x%X\n", temp >> 2);
    
    return 0;
}