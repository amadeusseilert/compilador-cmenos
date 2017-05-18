* C- Compilation to TM Code
* File: output/gcd.tm
* Standard prelude:
  0:     LD  5,0(0) 	load gp with maxaddress
  1:    LDA  6,0(5) 	copy gp to mp
  2:     ST  0,0(0) 	clear location 0
* End of standard prelude.
* -> Function (gcd)
  4:     ST  1,0(5) 	func: store the location of func. entry
* func: unconditional jump to next declaration belongs here
* func: function body starts here
  3:    LDC  1,6(0) 	func: load function location
  6:     ST  0,-1(6) 	func: store return address
* -> param
* u
* <- param
* -> param
* v
* <- param
* -> compound
* -> if
* -> Op
* -> Id (v)
  7:    LDC  0,-3(0) 	id: load varOffset
  8:    ADD  0,6,0 	id: calculate the address
  9:     LD  0,0(0) 	load id value
* <- Id
 10:     ST  0,-4(6) 	op: push left
* -> Const
 11:    LDC  0,0(0) 	load const
* <- Const
 12:     LD  1,-4(6) 	op: load left
 13:    SUB  0,1,0 	op ==
 14:    JEQ  0,2(7) 	br if true
 15:    LDC  0,0(0) 	false case
 16:    LDA  7,1(7) 	unconditional jmp
 17:    LDC  0,1(0) 	true case
* <- Op
* if: jump to else belongs here
* -> return
* -> Id (u)
 19:    LDC  0,-2(0) 	id: load varOffset
 20:    ADD  0,6,0 	id: calculate the address
 21:     LD  0,0(0) 	load id value
* <- Id
 22:     LD  7,-1(6) 	return: to caller
* <- return
* if: jump to end belongs here
 18:    JEQ  0,5(7) 	if: jmp to else
* -> return
* -> Call
* -> Id (v)
 24:    LDC  0,-3(0) 	id: load varOffset
 25:    ADD  0,6,0 	id: calculate the address
 26:     LD  0,0(0) 	load id value
* <- Id
 27:     ST  0,-6(6) 	call: push argument
* -> Op
* -> Id (u)
 28:    LDC  0,-2(0) 	id: load varOffset
 29:    ADD  0,6,0 	id: calculate the address
 30:     LD  0,0(0) 	load id value
* <- Id
 31:     ST  0,-4(6) 	op: push left
* -> Op
* -> Op
* -> Id (u)
 32:    LDC  0,-2(0) 	id: load varOffset
 33:    ADD  0,6,0 	id: calculate the address
 34:     LD  0,0(0) 	load id value
* <- Id
 35:     ST  0,-5(6) 	op: push left
* -> Id (v)
 36:    LDC  0,-3(0) 	id: load varOffset
 37:    ADD  0,6,0 	id: calculate the address
 38:     LD  0,0(0) 	load id value
* <- Id
 39:     LD  1,-5(6) 	op: load left
 40:    DIV  0,1,0 	op /
* <- Op
 41:     ST  0,-5(6) 	op: push left
* -> Id (v)
 42:    LDC  0,-3(0) 	id: load varOffset
 43:    ADD  0,6,0 	id: calculate the address
 44:     LD  0,0(0) 	load id value
* <- Id
 45:     LD  1,-5(6) 	op: load left
 46:    MUL  0,1,0 	op *
* <- Op
 47:     LD  1,-4(6) 	op: load left
 48:    SUB  0,1,0 	op -
* <- Op
 49:     ST  0,-7(6) 	call: push argument
 50:     ST  6,-4(6) 	call: store current mp
 51:    LDA  6,-4(6) 	call: push new frame
 52:    LDA  0,1(7) 	call: save return in ac
 53:     LD  7,0(5) 	call: relative jump to function entry
 54:     LD  6,0(6) 	call: pop current frame
* <- Call
 55:     LD  7,-1(6) 	return: to caller
* <- return
 23:    LDA  7,32(7) 	jmp to end
* <- if
* <- compound
 56:     LD  7,-1(6) 	func: load pc with return address
  5:    LDA  7,51(7) 	func: unconditional jump to next declaration
* <- Function (gcd)
* -> Function (main)
 58:     ST  1,-1(5) 	func: store the location of func. entry
* func: unconditional jump to next declaration belongs here
* func: function body starts here
 57:    LDC  1,60(0) 	func: load function location
 60:     ST  0,-1(6) 	func: store return address
* -> compound
* -> assign
* -> Id (x)
 61:    LDC  0,-2(0) 	id: load varOffset
 62:    ADD  0,6,0 	id: calculate the address
* <- Id
 63:     ST  0,-4(6) 	assign: push left (address)
* -> Call
 64:     IN  0,0,0 	read integer value
* <- Call
 65:     LD  1,-4(6) 	assign: load left (address)
 66:     ST  0,0(1) 	assign: store value
* <- assign
* -> assign
* -> Id (y)
 67:    LDC  0,-3(0) 	id: load varOffset
 68:    ADD  0,6,0 	id: calculate the address
* <- Id
 69:     ST  0,-4(6) 	assign: push left (address)
* -> Call
 70:     IN  0,0,0 	read integer value
* <- Call
 71:     LD  1,-4(6) 	assign: load left (address)
 72:     ST  0,0(1) 	assign: store value
* <- assign
* -> Call
* -> Call
* -> Id (x)
 73:    LDC  0,-2(0) 	id: load varOffset
 74:    ADD  0,6,0 	id: calculate the address
 75:     LD  0,0(0) 	load id value
* <- Id
 76:     ST  0,-6(6) 	call: push argument
* -> Id (y)
 77:    LDC  0,-3(0) 	id: load varOffset
 78:    ADD  0,6,0 	id: calculate the address
 79:     LD  0,0(0) 	load id value
* <- Id
 80:     ST  0,-7(6) 	call: push argument
 81:     ST  6,-4(6) 	call: store current mp
 82:    LDA  6,-4(6) 	call: push new frame
 83:    LDA  0,1(7) 	call: save return in ac
 84:     LD  7,0(5) 	call: relative jump to function entry
 85:     LD  6,0(6) 	call: pop current frame
* <- Call
 86:     ST  0,-6(6) 	call: push argument
 87:     LD  0,-6(6) 	load arg to ac
 88:    OUT  0,0,0 	write ac
* <- Call
* <- compound
 89:     LD  7,-1(6) 	func: load pc with return address
 59:    LDA  7,30(7) 	func: unconditional jump to next declaration
* <- Function (main)
 90:    LDC  0,-2(0) 	init: load globalOffset
 91:    ADD  6,6,0 	init: initialize mp with globalOffset
* -> Call
 92:     ST  6,0(6) 	call: store current mp
 93:    LDA  6,0(6) 	call: push new frame
 94:    LDA  0,1(7) 	call: save return in ac
 95:    LDC  7,60(0) 	call: unconditional jump to main() entry
 96:     LD  6,0(6) 	call: pop current frame
* <- Call
* End of execution.
 97:   HALT  0,0,0 	
