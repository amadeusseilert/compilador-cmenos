  0:     LD  5,0(0) 
  1:    LDA  6,0(5) 
  2:     ST  0,0(0) 
  4:     ST  1,0(5) 
  3:    LDC  1,6(0) 
  6:     ST  0,-1(6) 
  7:    LDC  0,-2(0) 
  8:    ADD  0,6,0 
  9:     LD  0,0(0) 
 10:     ST  0,-3(6) 
 11:    LDC  0,1(0) 
 12:     LD  1,-3(6) 
 13:    SUB  0,1,0 
 14:    JEQ  0,2(7) 
 15:    LDC  0,0(0) 
 16:    LDA  7,1(7) 
 17:    LDC  0,1(0) 
 19:    LDC  0,1(0) 
 20:     LD  7,-1(6) 
 18:    JEQ  0,3(7) 
 22:    LDC  0,-2(0) 
 23:    ADD  0,6,0 
 24:     LD  0,0(0) 
 25:     ST  0,-3(6) 
 26:    LDC  0,-2(0) 
 27:    ADD  0,6,0 
 28:     LD  0,0(0) 
 29:     ST  0,-4(6) 
 30:    LDC  0,1(0) 
 31:     LD  1,-4(6) 
 32:    SUB  0,1,0 
 33:     ST  0,-6(6) 
 34:     ST  6,-4(6) 
 35:    LDA  6,-4(6) 
 36:    LDA  0,1(7) 
 37:     LD  7,0(5) 
 38:     LD  6,0(6) 
 39:     LD  1,-3(6) 
 40:    MUL  0,1,0 
 41:     LD  7,-1(6) 
 21:    LDA  7,20(7) 
 42:     LD  7,-1(6) 
  5:    LDA  7,37(7) 
 44:     ST  1,-1(5) 
 43:    LDC  1,46(0) 
 46:     ST  0,-1(6) 
 47:    LDC  0,-2(0) 
 48:    ADD  0,6,0 
 49:     ST  0,-3(6) 
 50:     IN  0,0,0 
 51:     LD  1,-3(6) 
 52:     ST  0,0(1) 
 53:    LDC  0,-2(0) 
 54:    ADD  0,6,0 
 55:     ST  0,-3(6) 
 56:    LDC  0,-2(0) 
 57:    ADD  0,6,0 
 58:     LD  0,0(0) 
 59:     ST  0,-6(6) 
 60:     ST  6,-4(6) 
 61:    LDA  6,-4(6) 
 62:    LDA  0,1(7) 
 63:     LD  7,0(5) 
 64:     LD  6,0(6) 
 65:     LD  1,-3(6) 
 66:     ST  0,0(1) 
 67:    LDC  0,-2(0) 
 68:    ADD  0,6,0 
 69:     LD  0,0(0) 
 70:     ST  0,-5(6) 
 71:     LD  0,-5(6) 
 72:    OUT  0,0,0 
 73:    LDC  0,-2(0) 
 74:    ADD  0,6,0 
 75:     LD  0,0(0) 
 76:     LD  7,-1(6) 
 77:     LD  7,-1(6) 
 45:    LDA  7,32(7) 
 78:    LDC  0,-2(0) 
 79:    ADD  6,6,0 
 80:     ST  6,0(6) 
 81:    LDA  6,0(6) 
 82:    LDA  0,1(7) 
 83:    LDC  7,46(0) 
 84:     LD  6,0(6) 
 85:   HALT  0,0,0 
