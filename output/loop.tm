* C- Compilation to TM Code
* File: output/loop.tm
* Standard prelude:
  0:     LD  5,0(0) 	load gp with maxaddress
  1:    LDA  6,0(5) 	copy gp to mp
  2:     ST  0,0(0) 	clear location 0
* End of standard prelude.
* -> var. decl.
* <- var. decl.
* -> Function (loop)
  4:     ST  1,-1(5) 	func: store the location of func. entry
* func: unconditional jump to next declaration belongs here
* func: function body starts here
  3:    LDC  1,6(0) 	func: load function location
  6:     ST  0,-1(6) 	func: store return address
* -> param
* a
* <- param
* -> param
* size
* <- param
* -> compound
* -> assign
* -> Id (i)
  7:    LDC  0,-4(0) 	id: load varOffset
  8:    ADD  0,6,0 	id: calculate the address
  9:    LDA  0,0(0) 	load id address
* <- Id
 10:     ST  0,-5(6) 	assign: push left (address)
* -> Const
 11:    LDC  0,0(0) 	load const
* <- Const
 12:     LD  1,-5(6) 	assign: load left (address)
 13:     ST  0,0(1) 	assign: store value
* <- assign
* -> while.
* while: jump after body comes back here
* -> Op
* -> Id (i)
 14:    LDC  0,-4(0) 	id: load varOffset
 15:    ADD  0,6,0 	id: calculate the address
 16:     LD  0,0(0) 	load id value
* <- Id
 17:     ST  0,-5(6) 	op: push left
* -> Id (size)
 18:    LDC  0,-3(0) 	id: load varOffset
 19:    ADD  0,6,0 	id: calculate the address
 20:     LD  0,0(0) 	load id value
* <- Id
 21:     LD  1,-5(6) 	op: load left
 22:    SUB  0,1,0 	op <
 23:    JLT  0,2(7) 	br if true
 24:    LDC  0,0(0) 	false case
 25:    LDA  7,1(7) 	unconditional jmp
 26:    LDC  0,1(0) 	true case
* <- Op
* while: jump to end belongs here
* -> compound
* -> Call
* -> Id (a)
 28:    LDC  0,-2(0) 	id: load varOffset
 29:    ADD  0,6,0 	id: load the memory address of base address of array to ac
 30:     LD  0,0,0 	id: load the base address of array to ac
 31:     ST  0,-5(6) 	id: push base address
* -> Id (i)
 32:    LDC  0,-4(0) 	id: load varOffset
 33:    ADD  0,6,0 	id: calculate the address
 34:     LD  0,0(0) 	load id value
* <- Id
 35:     LD  1,-5(6) 	id: pop base address
 36:    SUB  0,1,0 	id: calculate element address with index
 37:     LD  0,0(0) 	load id value
* <- Id
 38:     ST  0,-7(6) 	call: push argument
 39:     LD  0,-7(6) 	load arg to ac
 40:    OUT  0,0,0 	write ac
* <- Call
* <- compound
 41:    LDA  7,-28(7) 	while: jmp back to test
 27:    JEQ  0,14(7) 	while: jmp to end
* <- while.
* <- compound
 42:     LD  7,-1(6) 	func: load pc with return address
  5:    LDA  7,37(7) 	func: unconditional jump to next declaration
* -> Function (loop)
* -> Function (main)
 44:     ST  1,-2(5) 	func: store the location of func. entry
* func: unconditional jump to next declaration belongs here
* func: function body starts here
 43:    LDC  1,46(0) 	func: load function location
 46:     ST  0,-1(6) 	func: store return address
* -> compound
* -> assign
* -> Id (i)
 47:    LDC  0,-2(0) 	id: load varOffset
 48:    ADD  0,6,0 	id: calculate the address
 49:    LDA  0,0(0) 	load id address
* <- Id
 50:     ST  0,-3(6) 	assign: push left (address)
* -> Const
 51:    LDC  0,0(0) 	load const
* <- Const
 52:     LD  1,-3(6) 	assign: load left (address)
 53:     ST  0,0(1) 	assign: store value
* <- assign
* -> while.
* while: jump after body comes back here
* -> Op
* -> Id (i)
 54:    LDC  0,-2(0) 	id: load varOffset
 55:    ADD  0,6,0 	id: calculate the address
 56:     LD  0,0(0) 	load id value
* <- Id
 57:     ST  0,-3(6) 	op: push left
* -> Const
 58:    LDC  0,3(0) 	load const
* <- Const
 59:     LD  1,-3(6) 	op: load left
 60:    SUB  0,1,0 	op <
 61:    JLT  0,2(7) 	br if true
 62:    LDC  0,0(0) 	false case
 63:    LDA  7,1(7) 	unconditional jmp
 64:    LDC  0,1(0) 	true case
* <- Op
* while: jump to end belongs here
* -> compound
* -> assign
* -> Id (v)
 66:    LDC  0,0(0) 	id: load varOffset
 67:    ADD  0,5,0 	id: calculate the address
 68:     ST  0,-3(6) 	id: push base address
* -> Id (i)
 69:    LDC  0,-2(0) 	id: load varOffset
 70:    ADD  0,6,0 	id: calculate the address
 71:     LD  0,0(0) 	load id value
* <- Id
 72:     LD  1,-3(6) 	id: pop base address
 73:    SUB  0,1,0 	id: calculate element address with index
 74:    LDA  0,0(0) 	load id address
* <- Id
 75:     ST  0,-3(6) 	assign: push left (address)
* -> Call
 76:     IN  0,0,0 	read integer value
* <- Call
 77:     LD  1,-3(6) 	assign: load left (address)
 78:     ST  0,0(1) 	assign: store value
* <- assign
* -> assign
* -> Id (i)
 79:    LDC  0,-2(0) 	id: load varOffset
 80:    ADD  0,6,0 	id: calculate the address
 81:    LDA  0,0(0) 	load id address
* <- Id
 82:     ST  0,-3(6) 	assign: push left (address)
* -> Op
* -> Id (i)
 83:    LDC  0,-2(0) 	id: load varOffset
 84:    ADD  0,6,0 	id: calculate the address
 85:     LD  0,0(0) 	load id value
* <- Id
 86:     ST  0,-4(6) 	op: push left
* -> Const
 87:    LDC  0,1(0) 	load const
* <- Const
 88:     LD  1,-4(6) 	op: load left
 89:    ADD  0,1,0 	op +
* <- Op
 90:     LD  1,-3(6) 	assign: load left (address)
 91:     ST  0,0(1) 	assign: store value
* <- assign
* <- compound
 92:    LDA  7,-39(7) 	while: jmp back to test
 65:    JEQ  0,27(7) 	while: jmp to end
* <- while.
* -> Call
* -> Id (v)
 93:    LDC  0,0(0) 	id: load varOffset
 94:    ADD  0,5,0 	id: calculate the address
 95:     LD  0,0(0) 	load id value
* <- Id
* -> Const
 96:    LDC  0,3(0) 	load const
* <- Const
 97:     ST  0,-5(6) 	call: push argument
* -> Const
 98:    LDC  0,3(0) 	load const
* <- Const
 99:     ST  0,-6(6) 	call: push argument
100:     ST  6,-3(6) 	call: store current mp
101:    LDA  6,-3(6) 	call: push new frame
102:    LDA  0,1(7) 	call: save return in ac
103:     LD  7,-1(5) 	call: relative jump to function entry
104:     LD  6,0(6) 	call: pop current frame
* <- Call
* <- compound
105:     LD  7,-1(6) 	func: load pc with return address
 45:    LDA  7,60(7) 	func: unconditional jump to next declaration
* -> Function (main)
106:    LDC  0,-5(0) 	init: load globalOffset
107:    ADD  6,6,0 	init: initialize mp with globalOffset
* -> Call
108:     ST  6,0(6) 	call: store current mp
109:    LDA  6,0(6) 	call: push new frame
110:    LDA  0,1(7) 	call: save return in ac
111:    LDC  7,46(0) 	call: unconditional jump to main() entry
112:     LD  6,0(6) 	call: pop current frame
* <- Call
* End of execution.
113:   HALT  0,0,0 	
