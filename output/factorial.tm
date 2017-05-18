* C- Compilation to TM Code
* File: output/factorial.tm
* Standard prelude:
  0:     LD  5,0(0) 	load gp with maxaddress
  1:    LDA  6,0(5) 	copy gp to mp
  2:     ST  0,0(0) 	clear location 0
* End of standard prelude.
* -> Function (factorial)
  4:     ST  1,0(5) 	func: store the location of func. entry
* func: unconditional jump to next declaration belongs here
* func: function body starts here
  3:    LDC  1,6(0) 	func: load function location
  6:     ST  0,-1(6) 	func: store return address
* -> param
* n
* <- param
* -> compound
* -> if
* -> Op
* -> Id (n)
  7:    LDC  0,-2(0) 	id: load varOffset
  8:    ADD  0,6,0 	id: calculate the address
  9:     LD  0,0(0) 	load id value
* <- Id
 10:     ST  0,-3(6) 	op: push left
* -> Const
 11:    LDC  0,1(0) 	load const
* <- Const
 12:     LD  1,-3(6) 	op: load left
 13:    SUB  0,1,0 	op ==
 14:    JEQ  0,2(7) 	br if true
 15:    LDC  0,0(0) 	false case
 16:    LDA  7,1(7) 	unconditional jmp
 17:    LDC  0,1(0) 	true case
* <- Op
* if: jump to else belongs here
* -> return
* -> Const
 19:    LDC  0,1(0) 	load const
* <- Const
 20:     LD  7,-1(6) 	return: to caller
* <- return
* if: jump to end belongs here
 18:    JEQ  0,3(7) 	if: jmp to else
* -> return
* -> Op
* -> Id (n)
 22:    LDC  0,-2(0) 	id: load varOffset
 23:    ADD  0,6,0 	id: calculate the address
 24:     LD  0,0(0) 	load id value
* <- Id
 25:     ST  0,-3(6) 	op: push left
* -> Call
* -> Op
* -> Id (n)
 26:    LDC  0,-2(0) 	id: load varOffset
 27:    ADD  0,6,0 	id: calculate the address
 28:     LD  0,0(0) 	load id value
* <- Id
 29:     ST  0,-4(6) 	op: push left
* -> Const
 30:    LDC  0,1(0) 	load const
* <- Const
 31:     LD  1,-4(6) 	op: load left
 32:    SUB  0,1,0 	op -
* <- Op
 33:     ST  0,-6(6) 	call: push argument
 34:     ST  6,-4(6) 	call: store current mp
 35:    LDA  6,-4(6) 	call: push new frame
 36:    LDA  0,1(7) 	call: save return in ac
 37:     LD  7,0(5) 	call: relative jump to function entry
 38:     LD  6,0(6) 	call: pop current frame
* <- Call
 39:     LD  1,-3(6) 	op: load left
 40:    MUL  0,1,0 	op *
* <- Op
 41:     LD  7,-1(6) 	return: to caller
* <- return
 21:    LDA  7,20(7) 	jmp to end
* <- if
* <- compound
 42:     LD  7,-1(6) 	func: load pc with return address
  5:    LDA  7,37(7) 	func: unconditional jump to next declaration
* <- Function (factorial)
* -> Function (main)
 44:     ST  1,-1(5) 	func: store the location of func. entry
* func: unconditional jump to next declaration belongs here
* func: function body starts here
 43:    LDC  1,46(0) 	func: load function location
 46:     ST  0,-1(6) 	func: store return address
* -> compound
* -> assign
* -> Id (a)
 47:    LDC  0,-2(0) 	id: load varOffset
 48:    ADD  0,6,0 	id: calculate the address
* <- Id
 49:     ST  0,-3(6) 	assign: push left (address)
* -> Call
 50:     IN  0,0,0 	read integer value
* <- Call
 51:     LD  1,-3(6) 	assign: load left (address)
 52:     ST  0,0(1) 	assign: store value
* <- assign
* -> assign
* -> Id (a)
 53:    LDC  0,-2(0) 	id: load varOffset
 54:    ADD  0,6,0 	id: calculate the address
* <- Id
 55:     ST  0,-3(6) 	assign: push left (address)
* -> Call
* -> Id (a)
 56:    LDC  0,-2(0) 	id: load varOffset
 57:    ADD  0,6,0 	id: calculate the address
 58:     LD  0,0(0) 	load id value
* <- Id
 59:     ST  0,-6(6) 	call: push argument
 60:     ST  6,-4(6) 	call: store current mp
 61:    LDA  6,-4(6) 	call: push new frame
 62:    LDA  0,1(7) 	call: save return in ac
 63:     LD  7,0(5) 	call: relative jump to function entry
 64:     LD  6,0(6) 	call: pop current frame
* <- Call
 65:     LD  1,-3(6) 	assign: load left (address)
 66:     ST  0,0(1) 	assign: store value
* <- assign
* -> Call
* -> Id (a)
 67:    LDC  0,-2(0) 	id: load varOffset
 68:    ADD  0,6,0 	id: calculate the address
 69:     LD  0,0(0) 	load id value
* <- Id
 70:     ST  0,-5(6) 	call: push argument
 71:     LD  0,-5(6) 	load arg to ac
 72:    OUT  0,0,0 	write ac
* <- Call
* -> return
* -> Id (a)
 73:    LDC  0,-2(0) 	id: load varOffset
 74:    ADD  0,6,0 	id: calculate the address
 75:     LD  0,0(0) 	load id value
* <- Id
 76:     LD  7,-1(6) 	return: to caller
* <- return
* <- compound
 77:     LD  7,-1(6) 	func: load pc with return address
 45:    LDA  7,32(7) 	func: unconditional jump to next declaration
* <- Function (main)
 78:    LDC  0,-2(0) 	init: load globalOffset
 79:    ADD  6,6,0 	init: initialize mp with globalOffset
* -> Call
 80:     ST  6,0(6) 	call: store current mp
 81:    LDA  6,0(6) 	call: push new frame
 82:    LDA  0,1(7) 	call: save return in ac
 83:    LDC  7,46(0) 	call: unconditional jump to main() entry
 84:     LD  6,0(6) 	call: pop current frame
* <- Call
* End of execution.
 85:   HALT  0,0,0 	
