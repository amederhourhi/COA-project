# Problems Encountered & Fixes

This document records every significant problem we faced during the development of the microprogrammed Mano Computer and how we solved it.

---

## 1. OneDrive + Git conflicts
**Problem:** Git could not delete objects inside `.git/objects` because OneDrive was locking files.  
**Symptom:** Repeated “Deletion of directory failed” messages.  
**Fix:** Moved the entire repository out of OneDrive to `C:\Projects\COA-project`.

## 2. Missing `register.v`
**Problem:** After the move, `src/datapath/register.v` was missing.  
**Fix:** Recreated the generic register module.

## 3. SystemVerilog vs classic Verilog
**Problem:** `integer` declaration inside `initial` block caused compilation error.  
**Fix:** Used `-g2012` flag and proper `for (integer i = ...)` syntax.

## 4. Bus_Select hardwired to 0
**Problem:** Common bus was always zero → PC and IR could not be loaded correctly.  
**Fix:** Encoded 3-bit `Bus_Select` in the microinstruction and drove it from `ctrl_signals[4:2]`.

## 5. Uninitialized Memory
**Problem:** IR was reading `xxxx` because memory array started as unknown.  
**Fix:** Pre-loaded a small test program in the testbench.

## 6. Current status (to be updated)
- Fetch cycle works
- MAP works
- LDA works
- ADD still incorrect
- IR sometimes cleared after JUMP
- ALU → AC path incomplete

---