  0:     LD  5,0(0) 
  1:    LDA  6,0(5) 
  2:     ST  0,0(0) 
  4:     ST  1,0(5) 
  3:    LDC  1,6(0) 
  6:     ST  0,-1(6) 
  7:    LDC  0,-3(0) 
  8:    ADD  0,6,0 
  9:     LD  0,0(0) 
 10:     ST  0,-4(6) 
 11:    LDC  0,0(0) 
 12:     LD  1,-4(6) 
 13:    SUB  0,1,0 
 14:    JEQ  0,2(7) 
 15:    LDC  0,0(0) 
 16:    LDA  7,1(7) 
 17:    LDC  0,1(0) 
 19:    LDC  0,-2(0) 
 20:    ADD  0,6,0 
 21:     LD  0,0(0) 
 22:     LD  7,-1(6) 
 18:    JEQ  0,5(7) 
 24:    LDC  0,-3(0) 
 25:    ADD  0,6,0 
 26:     LD  0,0(0) 
 27:     ST  0,-6(6) 
 28:    LDC  0,-2(0) 
 29:    ADD  0,6,0 
 30:     LD  0,0(0) 
 31:     ST  0,-4(6) 
 32:    LDC  0,-2(0) 
 33:    ADD  0,6,0 
 34:     LD  0,0(0) 
 35:     ST  0,-5(6) 
 36:    LDC  0,-3(0) 
 37:    ADD  0,6,0 
 38:     LD  0,0(0) 
 39:     LD  1,-5(6) 
 40:    DIV  0,1,0 
 41:     ST  0,-5(6) 
 42:    LDC  0,-3(0) 
 43:    ADD  0,6,0 
 44:     LD  0,0(0) 
 45:     LD  1,-5(6) 
 46:    MUL  0,1,0 
 47:     LD  1,-4(6) 
 48:    SUB  0,1,0 
 49:     ST  0,-7(6) 
 50:     ST  6,-4(6) 
 51:    LDA  6,-4(6) 
 52:    LDA  0,1(7) 
 53:     LD  7,0(5) 
 54:     LD  6,0(6) 
 55:     LD  7,-1(6) 
 23:    LDA  7,32(7) 
 56:     LD  7,-1(6) 
  5:    LDA  7,51(7) 
 58:     ST  1,-1(5) 
 57:    LDC  1,60(0) 
 60:     ST  0,-1(6) 
 61:    LDC  0,-2(0) 
 62:    ADD  0,6,0 
 63:     ST  0,-4(6) 
 64:     IN  0,0,0 
 65:     LD  1,-4(6) 
 66:     ST  0,0(1) 
 67:    LDC  0,-3(0) 
 68:    ADD  0,6,0 
 69:     ST  0,-4(6) 
 70:     IN  0,0,0 
 71:     LD  1,-4(6) 
 72:     ST  0,0(1) 
 73:    LDC  0,-2(0) 
 74:    ADD  0,6,0 
 75:     LD  0,0(0) 
 76:     ST  0,-6(6) 
 77:    LDC  0,-3(0) 
 78:    ADD  0,6,0 
 79:     LD  0,0(0) 
 80:     ST  0,-7(6) 
 81:     ST  6,-4(6) 
 82:    LDA  6,-4(6) 
 83:    LDA  0,1(7) 
 84:     LD  7,0(5) 
 85:     LD  6,0(6) 
 86:     ST  0,-6(6) 
 87:     LD  0,-6(6) 
 88:    OUT  0,0,0 
 89:     LD  7,-1(6) 
 59:    LDA  7,30(7) 
 90:    LDC  0,-2(0) 
 91:    ADD  6,6,0 
 92:     ST  6,0(6) 
 93:    LDA  6,0(6) 
 94:    LDA  0,1(7) 
 95:    LDC  7,60(0) 
 96:     LD  6,0(6) 
 97:   HALT  0,0,0 
