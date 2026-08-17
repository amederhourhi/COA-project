# Problems Encountered & Fixes

This document records the main problems faced during development of the microprogrammed Mano Computer and how they were solved.

---

## 1. OneDrive + Git conflicts
**Problem:** Git could not delete objects because OneDrive locked files.  
**Fix:** Moved the repository to `C:\Projects\COA-project`.

## 2. Missing `register.v`
**Problem:** Generic register module was lost after the move.  
**Fix:** Recreated the parameterized register module.

## 3. SystemVerilog compatibility
**Problem:** `integer` declaration inside `initial` caused compilation errors.  
**Fix:** Used `-g2012` flag with Icarus Verilog.

## 4. Bus_Select hardwired to 0
**Problem:** Common bus always zero → registers could not be loaded.  
**Fix:** Encoded 3-bit Bus_Select in the microinstruction and drove it from control signals.

## 5. Uninitialized memory
**Problem:** IR read as `xxxx`.  
**Fix:** Pre-loaded test programs in the testbench.

## 6. AC value not holding / wrong ADD result
**Problem:** ALU result was calculated but not written to AC, or was overwritten.  
**Fix:** 
- Gave AC a dedicated data input path from ALU
- Ensured `AC_Load` is asserted together with the ALU operation in the microprogram
- Introduced Microinstruction Register for proper timing

## 7. BUN loading full IR instead of address
**Problem:** `PC` became `4003` instead of `0003`.  
**Fix:** When Bus selects IR, only `IR[11:0]` is placed on the bus.

## 8. Extra cycles / delayed control signals
**Problem:** Microinstruction Register introduced a one-cycle delay.  
**Fix:** Adjusted sequencing and microprogram to work with the registered control signals.

## 9. Indirect addressing missing
**Problem:** No decision based on the `I` bit.  
**Fix:** Added Indirect decision in next-address logic using `IR[15]`.

## 10. FPGA readiness
**Status:** Constraints file, reset synchronizer, and FPGA top wrapper created.  
Ready to begin synthesis on Basys 3.

---