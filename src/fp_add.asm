// fp_add.asm
// Complete 16-bit Floating-Point Addition (Sign, 5-bit Exp, 10-bit Mantissa)

ORG 100

// -----------------------------------------
// Phase 1: Extraction and Masking
// -----------------------------------------
LDA FLTA            
AND MSK_MANT        
STA MANT_A          

LDA FLTA            
AND MSK_EXP         
STA EXP_A           

LDA FLTB            
AND MSK_MANT        
STA MANT_B          

LDA FLTB            
AND MSK_EXP         
STA EXP_B           

// -----------------------------------------
// Phase 2: Exponent Alignment Loop
// -----------------------------------------
ALIGN_LOOP:
    LDA EXP_B
    CMA                 
    INC                 
    ADD EXP_A           
    SZA                 
    BUN CHK_LARGER      
    BUN ADD_MANT        

CHK_LARGER:
    SPA                 
    BUN SHIFT_MANT_A    
    
SHIFT_MANT_B:
    LDA MANT_B
    CLE                 
    CIR                 
    STA MANT_B          
    LDA EXP_B
    INC                 
    STA EXP_B
    BUN ALIGN_LOOP      

SHIFT_MANT_A:
    LDA MANT_A
    CLE                 
    CIR                 
    STA MANT_A          
    LDA EXP_A
    INC                 
    STA EXP_A
    BUN ALIGN_LOOP      

// -----------------------------------------
// Phase 3: Mantissa Addition & Reconstruction
// -----------------------------------------
ADD_MANT:
    LDA MANT_A
    ADD MANT_B          // Add the aligned mantissas together
    STA MANT_RES        // Store the resulting mantissa
    
    LDA EXP_A           // Load the aligned exponent (EXP_A == EXP_B now)
    ADD MANT_RES        // Combine exponent and new mantissa 
    STA FLT_RES         // Store final floating-point result
    
    HLT                 // Halt execution

// -----------------------------------------
// Variables & Data Segment
// -----------------------------------------
ORG 200
FLTA:       HEX 3C00    // Input: Float A 
FLTB:       HEX 4000    // Input: Float B 

MSK_MANT:   HEX 03FF    // 0000 0011 1111 1111 (Mantissa Mask)
MSK_EXP:    HEX 7C00    // 0111 1100 0000 0000 (Exponent Mask)

MANT_A:     HEX 0000
EXP_A:      HEX 0000
MANT_B:     HEX 0000
EXP_B:      HEX 0000
MANT_RES:   HEX 0000
FLT_RES:    HEX 0000