* C- Compilation to TM Code
* File: output/sort.tm
* Standard prelude:
  0:     LD  5,0(0) 	load gp with maxaddress
  1:    LDA  6,0(5) 	copy gp to mp
  2:     ST  0,0(0) 	clear location 0
* End of standard prelude.
* -> var. decl.
* <- var. decl.
* -> Function (minloc)
  4:     ST  1,-5(5) 	func: store the location of func. entry
* func: unconditional jump to next declaration belongs here
* func: function body starts here
  3:    LDC  1,6(0) 	func: load function location
  6:     ST  0,-1(6) 	func: store return address
* -> param
* a
* <- param
* -> param
* low
* <- param
* -> param
* high
* <- param
* -> compound
* -> assign
* -> Id (k)
  7:    LDC  0,-7(0) 	id: load varOffset
  8:    ADD  0,6,0 	id: calculate the address
* <- Id
  9:     ST  0,-8(6) 	assign: push left (address)
* -> Id (low)
 10:    LDC  0,-3(0) 	id: load varOffset
 11:    ADD  0,6,0 	id: calculate the address
 12:     LD  0,0(0) 	load id value
* <- Id
 13:     LD  1,-8(6) 	assign: load left (address)
 14:     ST  0,0(1) 	assign: store value
* <- assign
* -> assign
* -> Id (x)
 15:    LDC  0,-6(0) 	id: load varOffset
 16:    ADD  0,6,0 	id: calculate the address
* <- Id
 17:     ST  0,-8(6) 	assign: push left (address)
* -> Id (a)
 18:    LDC  0,-2(0) 	id: load varOffset
 19:    ADD  0,6,0 	id: load the memory address of base address of array to ac
 20:     LD  0,0,0 	id: load the base address of array to ac
 21:     ST  0,-9(6) 	id: push base address
* -> Id (low)
 22:    LDC  0,-3(0) 	id: load varOffset
 23:    ADD  0,6,0 	id: calculate the address
 24:     LD  0,0(0) 	load id value
* <- Id
 25:     LD  1,-9(6) 	id: pop base address
 26:    SUB  0,1,0 	id: calculate element address with index
 27:     LD  0,0(0) 	load id value
* <- Id
 28:     LD  1,-8(6) 	assign: load left (address)
 29:     ST  0,0(1) 	assign: store value
* <- assign
* -> assign
* -> Id (i)
 30:    LDC  0,-5(0) 	id: load varOffset
 31:    ADD  0,6,0 	id: calculate the address
* <- Id
 32:     ST  0,-8(6) 	assign: push left (address)
* -> Op
* -> Id (low)
 33:    LDC  0,-3(0) 	id: load varOffset
 34:    ADD  0,6,0 	id: calculate the address
 35:     LD  0,0(0) 	load id value
* <- Id
 36:     ST  0,-9(6) 	op: push left
* -> Const
 37:    LDC  0,1(0) 	load const
* <- Const
 38:     LD  1,-9(6) 	op: load left
 39:    ADD  0,1,0 	op +
* <- Op
 40:     LD  1,-8(6) 	assign: load left (address)
 41:     ST  0,0(1) 	assign: store value
* <- assign
* -> while.
* while: jump after body comes back here
* -> Op
* -> Id (i)
 42:    LDC  0,-5(0) 	id: load varOffset
 43:    ADD  0,6,0 	id: calculate the address
 44:     LD  0,0(0) 	load id value
* <- Id
 45:     ST  0,-8(6) 	op: push left
* -> Id (high)
 46:    LDC  0,-4(0) 	id: load varOffset
 47:    ADD  0,6,0 	id: calculate the address
 48:     LD  0,0(0) 	load id value
* <- Id
 49:     LD  1,-8(6) 	op: load left
 50:    SUB  0,1,0 	op <
 51:    JLT  0,2(7) 	br if true
 52:    LDC  0,0(0) 	false case
 53:    LDA  7,1(7) 	unconditional jmp
 54:    LDC  0,1(0) 	true case
* <- Op
* while: jump to end belongs here
* -> compound
* -> if
* -> Op
* -> Id (a)
 56:    LDC  0,-2(0) 	id: load varOffset
 57:    ADD  0,6,0 	id: load the memory address of base address of array to ac
 58:     LD  0,0,0 	id: load the base address of array to ac
 59:     ST  0,-8(6) 	id: push base address
* -> Id (i)
 60:    LDC  0,-5(0) 	id: load varOffset
 61:    ADD  0,6,0 	id: calculate the address
 62:     LD  0,0(0) 	load id value
* <- Id
 63:     LD  1,-8(6) 	id: pop base address
 64:    SUB  0,1,0 	id: calculate element address with index
 65:     LD  0,0(0) 	load id value
* <- Id
 66:     ST  0,-8(6) 	op: push left
* -> Id (x)
 67:    LDC  0,-6(0) 	id: load varOffset
 68:    ADD  0,6,0 	id: calculate the address
 69:     LD  0,0(0) 	load id value
* <- Id
 70:     LD  1,-8(6) 	op: load left
 71:    SUB  0,1,0 	op <
 72:    JLT  0,2(7) 	br if true
 73:    LDC  0,0(0) 	false case
 74:    LDA  7,1(7) 	unconditional jmp
 75:    LDC  0,1(0) 	true case
* <- Op
* if: jump to else belongs here
* -> compound
* -> assign
* -> Id (x)
 77:    LDC  0,-6(0) 	id: load varOffset
 78:    ADD  0,6,0 	id: calculate the address
* <- Id
 79:     ST  0,-8(6) 	assign: push left (address)
* -> Id (a)
 80:    LDC  0,-2(0) 	id: load varOffset
 81:    ADD  0,6,0 	id: load the memory address of base address of array to ac
 82:     LD  0,0,0 	id: load the base address of array to ac
 83:     ST  0,-9(6) 	id: push base address
* -> Id (i)
 84:    LDC  0,-5(0) 	id: load varOffset
 85:    ADD  0,6,0 	id: calculate the address
 86:     LD  0,0(0) 	load id value
* <- Id
 87:     LD  1,-9(6) 	id: pop base address
 88:    SUB  0,1,0 	id: calculate element address with index
 89:     LD  0,0(0) 	load id value
* <- Id
 90:     LD  1,-8(6) 	assign: load left (address)
 91:     ST  0,0(1) 	assign: store value
* <- assign
* -> assign
* -> Id (k)
 92:    LDC  0,-7(0) 	id: load varOffset
 93:    ADD  0,6,0 	id: calculate the address
* <- Id
 94:     ST  0,-8(6) 	assign: push left (address)
* -> Id (i)
 95:    LDC  0,-5(0) 	id: load varOffset
 96:    ADD  0,6,0 	id: calculate the address
 97:     LD  0,0(0) 	load id value
* <- Id
 98:     LD  1,-8(6) 	assign: load left (address)
 99:     ST  0,0(1) 	assign: store value
* <- assign
* <- compound
* if: jump to end belongs here
 76:    JEQ  0,24(7) 	if: jmp to else
100:    LDA  7,0(7) 	jmp to end
* <- if
* -> assign
* -> Id (i)
101:    LDC  0,-5(0) 	id: load varOffset
102:    ADD  0,6,0 	id: calculate the address
* <- Id
103:     ST  0,-8(6) 	assign: push left (address)
* -> Op
* -> Id (i)
104:    LDC  0,-5(0) 	id: load varOffset
105:    ADD  0,6,0 	id: calculate the address
106:     LD  0,0(0) 	load id value
* <- Id
107:     ST  0,-9(6) 	op: push left
* -> Const
108:    LDC  0,1(0) 	load const
* <- Const
109:     LD  1,-9(6) 	op: load left
110:    ADD  0,1,0 	op +
* <- Op
111:     LD  1,-8(6) 	assign: load left (address)
112:     ST  0,0(1) 	assign: store value
* <- assign
* <- compound
113:    LDA  7,-72(7) 	while: jmp back to test
 55:    JEQ  0,58(7) 	while: jmp to end
* <- while.
* -> return
* -> Id (k)
114:    LDC  0,-7(0) 	id: load varOffset
115:    ADD  0,6,0 	id: calculate the address
116:     LD  0,0(0) 	load id value
* <- Id
117:     LD  7,-1(6) 	return: to caller
* <- return
* <- compound
118:     LD  7,-1(6) 	func: load pc with return address
  5:    LDA  7,113(7) 	func: unconditional jump to next declaration
* <- Function (minloc)
* -> Function (sort)
120:     ST  1,-6(5) 	func: store the location of func. entry
* func: unconditional jump to next declaration belongs here
* func: function body starts here
119:    LDC  1,122(0) 	func: load function location
122:     ST  0,-1(6) 	func: store return address
* -> param
* a
* <- param
* -> param
* low
* <- param
* -> param
* high
* <- param
* -> compound
* -> assign
* -> Id (i)
123:    LDC  0,-5(0) 	id: load varOffset
124:    ADD  0,6,0 	id: calculate the address
* <- Id
125:     ST  0,-8(6) 	assign: push left (address)
* -> Id (low)
126:    LDC  0,-3(0) 	id: load varOffset
127:    ADD  0,6,0 	id: calculate the address
128:     LD  0,0(0) 	load id value
* <- Id
129:     LD  1,-8(6) 	assign: load left (address)
130:     ST  0,0(1) 	assign: store value
* <- assign
* -> while.
* while: jump after body comes back here
* -> Op
* -> Id (i)
131:    LDC  0,-5(0) 	id: load varOffset
132:    ADD  0,6,0 	id: calculate the address
133:     LD  0,0(0) 	load id value
* <- Id
134:     ST  0,-8(6) 	op: push left
* -> Op
* -> Id (high)
135:    LDC  0,-4(0) 	id: load varOffset
136:    ADD  0,6,0 	id: calculate the address
137:     LD  0,0(0) 	load id value
* <- Id
138:     ST  0,-9(6) 	op: push left
* -> Const
139:    LDC  0,1(0) 	load const
* <- Const
140:     LD  1,-9(6) 	op: load left
141:    SUB  0,1,0 	op -
* <- Op
142:     LD  1,-8(6) 	op: load left
143:    SUB  0,1,0 	op <
144:    JLT  0,2(7) 	br if true
145:    LDC  0,0(0) 	false case
146:    LDA  7,1(7) 	unconditional jmp
147:    LDC  0,1(0) 	true case
* <- Op
* while: jump to end belongs here
* -> compound
* -> assign
* -> Id (k)
149:    LDC  0,-6(0) 	id: load varOffset
150:    ADD  0,6,0 	id: calculate the address
* <- Id
151:     ST  0,-8(6) 	assign: push left (address)
* -> Call
* -> Id (a)
152:    LDC  0,-2(0) 	id: load varOffset
153:    ADD  0,6,0 	id: calculate the address
154:     LD  0,0(0) 	load id address value
* <- Id
155:     ST  0,-11(6) 	call: push argument
* -> Id (i)
156:    LDC  0,-5(0) 	id: load varOffset
157:    ADD  0,6,0 	id: calculate the address
158:     LD  0,0(0) 	load id value
* <- Id
159:     ST  0,-12(6) 	call: push argument
* -> Id (high)
160:    LDC  0,-4(0) 	id: load varOffset
161:    ADD  0,6,0 	id: calculate the address
162:     LD  0,0(0) 	load id value
* <- Id
163:     ST  0,-13(6) 	call: push argument
164:     ST  6,-9(6) 	call: store current mp
165:    LDA  6,-9(6) 	call: push new frame
166:    LDA  0,1(7) 	call: save return in ac
167:     LD  7,-5(5) 	call: relative jump to function entry
168:     LD  6,0(6) 	call: pop current frame
* <- Call
169:     LD  1,-8(6) 	assign: load left (address)
170:     ST  0,0(1) 	assign: store value
* <- assign
* -> assign
* -> Id (t)
171:    LDC  0,-7(0) 	id: load varOffset
172:    ADD  0,6,0 	id: calculate the address
* <- Id
173:     ST  0,-8(6) 	assign: push left (address)
* -> Id (a)
174:    LDC  0,-2(0) 	id: load varOffset
175:    ADD  0,6,0 	id: load the memory address of base address of array to ac
176:     LD  0,0,0 	id: load the base address of array to ac
177:     ST  0,-9(6) 	id: push base address
* -> Id (k)
178:    LDC  0,-6(0) 	id: load varOffset
179:    ADD  0,6,0 	id: calculate the address
180:     LD  0,0(0) 	load id value
* <- Id
181:     LD  1,-9(6) 	id: pop base address
182:    SUB  0,1,0 	id: calculate element address with index
183:     LD  0,0(0) 	load id value
* <- Id
184:     LD  1,-8(6) 	assign: load left (address)
185:     ST  0,0(1) 	assign: store value
* <- assign
* -> assign
* -> Id (a)
186:    LDC  0,-2(0) 	id: load varOffset
187:    ADD  0,6,0 	id: load the memory address of base address of array to ac
188:     LD  0,0,0 	id: load the base address of array to ac
189:     ST  0,-8(6) 	id: push base address
* -> Id (k)
190:    LDC  0,-6(0) 	id: load varOffset
191:    ADD  0,6,0 	id: calculate the address
192:     LD  0,0(0) 	load id value
* <- Id
193:     LD  1,-8(6) 	id: pop base address
194:    SUB  0,1,0 	id: calculate element address with index
* <- Id
195:     ST  0,-8(6) 	assign: push left (address)
* -> Id (a)
196:    LDC  0,-2(0) 	id: load varOffset
197:    ADD  0,6,0 	id: load the memory address of base address of array to ac
198:     LD  0,0,0 	id: load the base address of array to ac
199:     ST  0,-9(6) 	id: push base address
* -> Id (i)
200:    LDC  0,-5(0) 	id: load varOffset
201:    ADD  0,6,0 	id: calculate the address
202:     LD  0,0(0) 	load id value
* <- Id
203:     LD  1,-9(6) 	id: pop base address
204:    SUB  0,1,0 	id: calculate element address with index
205:     LD  0,0(0) 	load id value
* <- Id
206:     LD  1,-8(6) 	assign: load left (address)
207:     ST  0,0(1) 	assign: store value
* <- assign
* -> assign
* -> Id (a)
208:    LDC  0,-2(0) 	id: load varOffset
209:    ADD  0,6,0 	id: load the memory address of base address of array to ac
210:     LD  0,0,0 	id: load the base address of array to ac
211:     ST  0,-8(6) 	id: push base address
* -> Id (i)
212:    LDC  0,-5(0) 	id: load varOffset
213:    ADD  0,6,0 	id: calculate the address
214:     LD  0,0(0) 	load id value
* <- Id
215:     LD  1,-8(6) 	id: pop base address
216:    SUB  0,1,0 	id: calculate element address with index
* <- Id
217:     ST  0,-8(6) 	assign: push left (address)
* -> Id (t)
218:    LDC  0,-7(0) 	id: load varOffset
219:    ADD  0,6,0 	id: calculate the address
220:     LD  0,0(0) 	load id value
* <- Id
221:     LD  1,-8(6) 	assign: load left (address)
222:     ST  0,0(1) 	assign: store value
* <- assign
* -> assign
* -> Id (i)
223:    LDC  0,-5(0) 	id: load varOffset
224:    ADD  0,6,0 	id: calculate the address
* <- Id
225:     ST  0,-8(6) 	assign: push left (address)
* -> Op
* -> Id (i)
226:    LDC  0,-5(0) 	id: load varOffset
227:    ADD  0,6,0 	id: calculate the address
228:     LD  0,0(0) 	load id value
* <- Id
229:     ST  0,-9(6) 	op: push left
* -> Const
230:    LDC  0,1(0) 	load const
* <- Const
231:     LD  1,-9(6) 	op: load left
232:    ADD  0,1,0 	op +
* <- Op
233:     LD  1,-8(6) 	assign: load left (address)
234:     ST  0,0(1) 	assign: store value
* <- assign
* <- compound
235:    LDA  7,-105(7) 	while: jmp back to test
148:    JEQ  0,87(7) 	while: jmp to end
* <- while.
* <- compound
236:     LD  7,-1(6) 	func: load pc with return address
121:    LDA  7,115(7) 	func: unconditional jump to next declaration
* <- Function (sort)
* -> Function (main)
238:     ST  1,-7(5) 	func: store the location of func. entry
* func: unconditional jump to next declaration belongs here
* func: function body starts here
237:    LDC  1,240(0) 	func: load function location
240:     ST  0,-1(6) 	func: store return address
* -> compound
* -> assign
* -> Id (i)
241:    LDC  0,-2(0) 	id: load varOffset
242:    ADD  0,6,0 	id: calculate the address
* <- Id
243:     ST  0,-3(6) 	assign: push left (address)
* -> Const
244:    LDC  0,0(0) 	load const
* <- Const
245:     LD  1,-3(6) 	assign: load left (address)
246:     ST  0,0(1) 	assign: store value
* <- assign
* -> while.
* while: jump after body comes back here
* -> Op
* -> Id (i)
247:    LDC  0,-2(0) 	id: load varOffset
248:    ADD  0,6,0 	id: calculate the address
249:     LD  0,0(0) 	load id value
* <- Id
250:     ST  0,-3(6) 	op: push left
* -> Const
251:    LDC  0,5(0) 	load const
* <- Const
252:     LD  1,-3(6) 	op: load left
253:    SUB  0,1,0 	op <
254:    JLT  0,2(7) 	br if true
255:    LDC  0,0(0) 	false case
256:    LDA  7,1(7) 	unconditional jmp
257:    LDC  0,1(0) 	true case
* <- Op
* while: jump to end belongs here
* -> compound
* -> assign
* -> Id (x)
259:    LDC  0,0(0) 	id: load varOffset
260:    ADD  0,5,0 	id: calculate the address
261:     ST  0,-3(6) 	id: push base address
* -> Id (i)
262:    LDC  0,-2(0) 	id: load varOffset
263:    ADD  0,6,0 	id: calculate the address
264:     LD  0,0(0) 	load id value
* <- Id
265:     LD  1,-3(6) 	id: pop base address
266:    SUB  0,1,0 	id: calculate element address with index
267:    LDA  0,0(0) 	load id address
* <- Id
268:     ST  0,-3(6) 	assign: push left (address)
* -> Call
269:     IN  0,0,0 	read integer value
* <- Call
270:     LD  1,-3(6) 	assign: load left (address)
271:     ST  0,0(1) 	assign: store value
* <- assign
* -> assign
* -> Id (i)
272:    LDC  0,-2(0) 	id: load varOffset
273:    ADD  0,6,0 	id: calculate the address
* <- Id
274:     ST  0,-3(6) 	assign: push left (address)
* -> Op
* -> Id (i)
275:    LDC  0,-2(0) 	id: load varOffset
276:    ADD  0,6,0 	id: calculate the address
277:     LD  0,0(0) 	load id value
* <- Id
278:     ST  0,-4(6) 	op: push left
* -> Const
279:    LDC  0,1(0) 	load const
* <- Const
280:     LD  1,-4(6) 	op: load left
281:    ADD  0,1,0 	op +
* <- Op
282:     LD  1,-3(6) 	assign: load left (address)
283:     ST  0,0(1) 	assign: store value
* <- assign
* <- compound
284:    LDA  7,-38(7) 	while: jmp back to test
258:    JEQ  0,26(7) 	while: jmp to end
* <- while.
* -> Call
* -> Id (x)
285:    LDC  0,0(0) 	id: load varOffset
286:    ADD  0,5,0 	id: calculate the address
287:    LDA  0,0(0) 	load id address
* <- Id
288:     ST  0,-5(6) 	call: push argument
* -> Const
289:    LDC  0,0(0) 	load const
* <- Const
290:     ST  0,-6(6) 	call: push argument
* -> Const
291:    LDC  0,5(0) 	load const
* <- Const
292:     ST  0,-7(6) 	call: push argument
293:     ST  6,-3(6) 	call: store current mp
294:    LDA  6,-3(6) 	call: push new frame
295:    LDA  0,1(7) 	call: save return in ac
296:     LD  7,-6(5) 	call: relative jump to function entry
297:     LD  6,0(6) 	call: pop current frame
* <- Call
* -> assign
* -> Id (i)
298:    LDC  0,-2(0) 	id: load varOffset
299:    ADD  0,6,0 	id: calculate the address
* <- Id
300:     ST  0,-3(6) 	assign: push left (address)
* -> Const
301:    LDC  0,0(0) 	load const
* <- Const
302:     LD  1,-3(6) 	assign: load left (address)
303:     ST  0,0(1) 	assign: store value
* <- assign
* -> while.
* while: jump after body comes back here
* -> Op
* -> Id (i)
304:    LDC  0,-2(0) 	id: load varOffset
305:    ADD  0,6,0 	id: calculate the address
306:     LD  0,0(0) 	load id value
* <- Id
307:     ST  0,-3(6) 	op: push left
* -> Const
308:    LDC  0,5(0) 	load const
* <- Const
309:     LD  1,-3(6) 	op: load left
310:    SUB  0,1,0 	op <
311:    JLT  0,2(7) 	br if true
312:    LDC  0,0(0) 	false case
313:    LDA  7,1(7) 	unconditional jmp
314:    LDC  0,1(0) 	true case
* <- Op
* while: jump to end belongs here
* -> compound
* -> Call
* -> Id (x)
316:    LDC  0,0(0) 	id: load varOffset
317:    ADD  0,5,0 	id: calculate the address
318:     ST  0,-3(6) 	id: push base address
* -> Id (i)
319:    LDC  0,-2(0) 	id: load varOffset
320:    ADD  0,6,0 	id: calculate the address
321:     LD  0,0(0) 	load id value
* <- Id
322:     LD  1,-3(6) 	id: pop base address
323:    SUB  0,1,0 	id: calculate element address with index
324:     LD  0,0(0) 	load id value
* <- Id
325:     ST  0,-5(6) 	call: push argument
326:     LD  0,-5(6) 	load arg to ac
327:    OUT  0,0,0 	write ac
* <- Call
* -> assign
* -> Id (i)
328:    LDC  0,-2(0) 	id: load varOffset
329:    ADD  0,6,0 	id: calculate the address
* <- Id
330:     ST  0,-3(6) 	assign: push left (address)
* -> Op
* -> Id (i)
331:    LDC  0,-2(0) 	id: load varOffset
332:    ADD  0,6,0 	id: calculate the address
333:     LD  0,0(0) 	load id value
* <- Id
334:     ST  0,-4(6) 	op: push left
* -> Const
335:    LDC  0,1(0) 	load const
* <- Const
336:     LD  1,-4(6) 	op: load left
337:    ADD  0,1,0 	op +
* <- Op
338:     LD  1,-3(6) 	assign: load left (address)
339:     ST  0,0(1) 	assign: store value
* <- assign
* <- compound
340:    LDA  7,-37(7) 	while: jmp back to test
315:    JEQ  0,25(7) 	while: jmp to end
* <- while.
* <- compound
341:     LD  7,-1(6) 	func: load pc with return address
239:    LDA  7,102(7) 	func: unconditional jump to next declaration
* <- Function (main)
342:    LDC  0,-8(0) 	init: load globalOffset
343:    ADD  6,6,0 	init: initialize mp with globalOffset
* -> Call
344:     ST  6,0(6) 	call: store current mp
345:    LDA  6,0(6) 	call: push new frame
346:    LDA  0,1(7) 	call: save return in ac
347:    LDC  7,240(0) 	call: unconditional jump to main() entry
348:     LD  6,0(6) 	call: pop current frame
* <- Call
* End of execution.
349:   HALT  0,0,0 	
