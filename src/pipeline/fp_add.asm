/ --------------------------------------------------------
/ FLOATING POINT ADDITION (16-bit: 1 Sign, 5 Exp, 10 Mantissa)
/ --------------------------------------------------------
         ORG 000
START,   LDA NUM1
         AND MSK_MAN
         ADD HID_BIT / Add implied leading 1 (0x0400)
         STA MAN1

         LDA NUM2
         AND MSK_MAN
         ADD HID_BIT 
         STA MAN2

/ --- EXTRACT EXPONENTS ---
         LDA NUM1
         AND MSK_EXP
         STA EXP1

         LDA NUM2
         AND MSK_EXP
         STA EXP2

/ --- CALCULATE EXPONENT DIFFERENCE ---
         LDA EXP2
         CMA
         INC         / 2's complement of EXP2
         ADD EXP1    / AC = EXP1 - EXP2
         SNA         / Skip next if EXP2 > EXP1 (AC is negative)
         BUN E1_BIG

/ --- EXP2 IS LARGER (Shift MAN1) ---
E2_BIG,  STA DIFF    / DIFF is negative
         LDA DIFF
         CMA
         INC
         STA DIFF    / DIFF is now positive difference
         LDA EXP2
         STA RES_EXP / Final exponent will be the larger one
ALIGN1,  LDA DIFF
         SZA
         BUN SH1     / Shift MAN1 if DIFF != 0
         BUN DO_ADD  / If DIFF == 0, exponents aligned
SH1,     LDA MAN1
         CLE         / Clear E flag before shift
         CIR         / Shift Mantissa 1 Right
         STA MAN1
         / Decrement difference by 0x0400 (1 in exponent position)
         LDA DIFF
         CMA
         INC
         ADD EXP_ONE
         CMA
         INC
         STA DIFF
         BUN ALIGN1

/ --- EXP1 IS LARGER (Shift MAN2) ---
E1_BIG,  STA DIFF    / DIFF = EXP1 - EXP2
         LDA EXP1
         STA RES_EXP / Final exponent is EXP1
ALIGN2,  LDA DIFF
         SZA
         BUN SH2
         BUN DO_ADD
SH2,     LDA MAN2
         CLE
         CIR         
         STA MAN2
         LDA DIFF
         CMA
         INC
         ADD EXP_ONE
         CMA
         INC
         STA DIFF
         BUN ALIGN2

/ --- ADD ALIGNED MANTISSAS ---
DO_ADD,  LDA MAN1
         ADD MAN2
         STA RES_MAN
         HLT         / End of computation

/ --------------------------------------------------------
/ DATA SECTION
/ --------------------------------------------------------
NUM1,    HEX 4500    / 0 10001 0100000000 
NUM2,    HEX 4100    / 0 10000 0100000000 
MSK_MAN, HEX 03FF    
MSK_EXP, HEX 7C00    
HID_BIT, HEX 0400    
EXP_ONE, HEX 0400    
MAN1,    HEX 0000
MAN2,    HEX 0000
EXP1,    HEX 0000
EXP2,    HEX 0000
DIFF,    HEX 0000
RES_EXP, HEX 0000
RES_MAN, HEX 0000