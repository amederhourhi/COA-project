// fp_add.asm
// Phase 1: Extraction and Masking for 16-bit FP Addition
// Format: 1-bit Sign, 5-bit Exponent, 10-bit Mantissa

ORG 100             // Start execution at memory address 100

// -----------------------------------------
// Extract Float A
// -----------------------------------------
LDA FLTA            // Load Float A into the Accumulator
AND MSK_MANT        // Apply mask to isolate the 10-bit mantissa
STA MANT_A          // Store the isolated mantissa in memory

LDA FLTA            // Reload Float A 
AND MSK_EXP         // Apply mask to isolate the 5-bit exponent
STA EXP_A           // Store the isolated exponent in memory

// -----------------------------------------
// Extract Float B
// -----------------------------------------
LDA FLTB            // Load Float B into the Accumulator
AND MSK_MANT        // Apply mask to isolate the 10-bit mantissa
STA MANT_B          // Store the isolated mantissa

LDA FLTB            // Reload Float B
AND MSK_EXP         // Apply mask to isolate the 5-bit exponent
STA EXP_B           // Store the isolated exponent

HLT                 // Halt execution (End of Extraction Phase)

// -----------------------------------------
// Variables & Data Segment
// -----------------------------------------
ORG 200
FLTA:       HEX 3C00    // Input: Float A (Example value)
FLTB:       HEX 4000    // Input: Float B (Example value)

// Bitmasks
MSK_MANT:   HEX 03FF    // 0000 0011 1111 1111 (Isolates Bits 0-9)
MSK_EXP:    HEX 7C00    // 0111 1100 0000 0000 (Isolates Bits 10-14)

// Storage Allocation
MANT_A:     HEX 0000
EXP_A:      HEX 0000
MANT_B:     HEX 0000
EXP_B:      HEX 0000