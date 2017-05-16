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
  4:     ST  1,-1(5) 	func: store the location of func. entry
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
  9:    LDA  0,0(0) 	load id address
* <- Id
 10:     ST  0,-8(6) 	assign: push left (address)
* -> Id (low)
 11:    LDC  0,-3(0) 	id: load varOffset
 12:    ADD  0,6,0 	id: calculate the address
 13:     LD  0,0(0) 	load id value
* <- Id
 14:     LD  1,-8(6) 	assign: load left (address)
 15:     ST  0,0(1) 	assign: store value
* <- assign
* -> assign
* -> Id (x)
 16:    LDC  0,-6(0) 	id: load varOffset
 17:    ADD  0,6,0 	id: calculate the address
 18:    LDA  0,0(0) 	load id address
* <- Id
 19:     ST  0,-8(6) 	assign: push left (address)
* -> Id (a)
 20:    LDC  0,-2(0) 	id: load varOffset
 21:    ADD  0,6,0 	id: load the memory address of base address of array to ac
 22:     LD  0,0,0 	id: load the base address of array to ac
 23:     ST  0,-9(6) 	id: push base address
* -> Id (low)
 24:    LDC  0,-3(0) 	id: load varOffset
 25:    ADD  0,6,0 	id: calculate the address
 26:     LD  0,0(0) 	load id value
* <- Id
 27:     LD  1,-9(6) 	id: pop base address
 28:    SUB  0,1,0 	id: calculate element address with index
 29:     LD  0,0(0) 	load id value
* <- Id
 30:     LD  1,-8(6) 	assign: load left (address)
 31:     ST  0,0(1) 	assign: store value
* <- assign
* -> assign
* -> Id (i)
 32:    LDC  0,-5(0) 	id: load varOffset
 33:    ADD  0,6,0 	id: calculate the address
 34:    LDA  0,0(0) 	load id address
* <- Id
 35:     ST  0,-8(6) 	assign: push left (address)
* -> Op
* -> Id (low)
 36:    LDC  0,-3(0) 	id: load varOffset
 37:    ADD  0,6,0 	id: calculate the address
 38:     LD  0,0(0) 	load id value
* <- Id
 39:     ST  0,-9(6) 	op: push left
* -> Const
 40:    LDC  0,1(0) 	load const
* <- Const
 41:     LD  1,-9(6) 	op: load left
 42:    ADD  0,1,0 	op +
* <- Op
 43:     LD  1,-8(6) 	assign: load left (address)
 44:     ST  0,0(1) 	assign: store value
* <- assign
* -> while.
* while: jump after body comes back here
* -> Op
* -> Id (i)
 45:    LDC  0,-5(0) 	id: load varOffset
 46:    ADD  0,6,0 	id: calculate the address
 47:     LD  0,0(0) 	load id value
* <- Id
 48:     ST  0,-8(6) 	op: push left
* -> Id (high)
 49:    LDC  0,-4(0) 	id: load varOffset
 50:    ADD  0,6,0 	id: calculate the address
 51:     LD  0,0(0) 	load id value
* <- Id
 52:     LD  1,-8(6) 	op: load left
 53:    SUB  0,1,0 	op <
 54:    JLT  0,2(7) 	br if true
 55:    LDC  0,0(0) 	false case
 56:    LDA  7,1(7) 	unconditional jmp
 57:    LDC  0,1(0) 	true case
* <- Op
* while: jump to end belongs here
* -> compound
* -> if
* -> Op
* -> Id (a)
 59:    LDC  0,-2(0) 	id: load varOffset
 60:    ADD  0,6,0 	id: load the memory address of base address of array to ac
 61:     LD  0,0,0 	id: load the base address of array to ac
 62:     ST  0,-8(6) 	id: push base address
* -> Id (i)
 63:    LDC  0,-5(0) 	id: load varOffset
 64:    ADD  0,6,0 	id: calculate the address
 65:     LD  0,0(0) 	load id value
* <- Id
 66:     LD  1,-8(6) 	id: pop base address
 67:    SUB  0,1,0 	id: calculate element address with index
 68:     LD  0,0(0) 	load id value
* <- Id
 69:     ST  0,-8(6) 	op: push left
* -> Id (x)
 70:    LDC  0,-6(0) 	id: load varOffset
 71:    ADD  0,6,0 	id: calculate the address
 72:     LD  0,0(0) 	load id value
* <- Id
 73:     LD  1,-8(6) 	op: load left
 74:    SUB  0,1,0 	op <
 75:    JLT  0,2(7) 	br if true
 76:    LDC  0,0(0) 	false case
 77:    LDA  7,1(7) 	unconditional jmp
 78:    LDC  0,1(0) 	true case
* <- Op
* if: jump to else belongs here
* -> compound
* -> assign
* -> Id (x)
 80:    LDC  0,-6(0) 	id: load varOffset
 81:    ADD  0,6,0 	id: calculate the address
 82:    LDA  0,0(0) 	load id address
* <- Id
 83:     ST  0,-8(6) 	assign: push left (address)
* -> Id (a)
 84:    LDC  0,-2(0) 	id: load varOffset
 85:    ADD  0,6,0 	id: load the memory address of base address of array to ac
 86:     LD  0,0,0 	id: load the base address of array to ac
 87:     ST  0,-9(6) 	id: push base address
* -> Id (i)
 88:    LDC  0,-5(0) 	id: load varOffset
 89:    ADD  0,6,0 	id: calculate the address
 90:     LD  0,0(0) 	load id value
* <- Id
 91:     LD  1,-9(6) 	id: pop base address
 92:    SUB  0,1,0 	id: calculate element address with index
 93:     LD  0,0(0) 	load id value
* <- Id
 94:     LD  1,-8(6) 	assign: load left (address)
 95:     ST  0,0(1) 	assign: store value
* <- assign
* -> assign
* -> Id (k)
 96:    LDC  0,-7(0) 	id: load varOffset
 97:    ADD  0,6,0 	id: calculate the address
 98:    LDA  0,0(0) 	load id address
* <- Id
 99:     ST  0,-8(6) 	assign: push left (address)
* -> Id (i)
100:    LDC  0,-5(0) 	id: load varOffset
101:    ADD  0,6,0 	id: calculate the address
102:     LD  0,0(0) 	load id value
* <- Id
103:     LD  1,-8(6) 	assign: load left (address)
104:     ST  0,0(1) 	assign: store value
* <- assign
* <- compound
* if: jump to end belongs here
 79:    JEQ  0,26(7) 	if: jmp to else
105:    LDA  7,0(7) 	jmp to end
* <- if
* -> assign
* -> Id (i)
106:    LDC  0,-5(0) 	id: load varOffset
107:    ADD  0,6,0 	id: calculate the address
108:    LDA  0,0(0) 	load id address
* <- Id
109:     ST  0,-8(6) 	assign: push left (address)
* -> Op
* -> Id (i)
110:    LDC  0,-5(0) 	id: load varOffset
111:    ADD  0,6,0 	id: calculate the address
112:     LD  0,0(0) 	load id value
* <- Id
113:     ST  0,-9(6) 	op: push left
* -> Const
114:    LDC  0,1(0) 	load const
* <- Const
115:     LD  1,-9(6) 	op: load left
116:    ADD  0,1,0 	op +
* <- Op
117:     LD  1,-8(6) 	assign: load left (address)
118:     ST  0,0(1) 	assign: store value
* <- assign
* <- compound
119:    LDA  7,-75(7) 	while: jmp back to test
 58:    JEQ  0,61(7) 	while: jmp to end
* <- while.
* -> return
* -> Id (k)
120:    LDC  0,-7(0) 	id: load varOffset
121:    ADD  0,6,0 	id: calculate the address
122:     LD  0,0(0) 	load id value
* <- Id
123:     LD  7,-1(6) 	return: to caller
* <- return
* <- compound
124:     LD  7,-1(6) 	func: load pc with return address
  5:    LDA  7,119(7) 	func: unconditional jump to next declaration
* -> Function (minloc)
* -> Function (sort)
126:     ST  1,-2(5) 	func: store the location of func. entry
* func: unconditional jump to next declaration belongs here
* func: function body starts here
125:    LDC  1,128(0) 	func: load function location
128:     ST  0,-1(6) 	func: store return address
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
129:    LDC  0,-5(0) 	id: load varOffset
130:    ADD  0,6,0 	id: calculate the address
131:    LDA  0,0(0) 	load id address
* <- Id
132:     ST  0,-8(6) 	assign: push left (address)
* -> Id (low)
133:    LDC  0,-3(0) 	id: load varOffset
134:    ADD  0,6,0 	id: calculate the address
135:     LD  0,0(0) 	load id value
* <- Id
136:     LD  1,-8(6) 	assign: load left (address)
137:     ST  0,0(1) 	assign: store value
* <- assign
* -> while.
* while: jump after body comes back here
* -> Op
* -> Id (i)
138:    LDC  0,-5(0) 	id: load varOffset
139:    ADD  0,6,0 	id: calculate the address
140:     LD  0,0(0) 	load id value
* <- Id
141:     ST  0,-8(6) 	op: push left
* -> Op
* -> Id (high)
142:    LDC  0,-4(0) 	id: load varOffset
143:    ADD  0,6,0 	id: calculate the address
144:     LD  0,0(0) 	load id value
* <- Id
145:     ST  0,-9(6) 	op: push left
* -> Const
146:    LDC  0,1(0) 	load const
* <- Const
147:     LD  1,-9(6) 	op: load left
148:    SUB  0,1,0 	op -
* <- Op
149:     LD  1,-8(6) 	op: load left
150:    SUB  0,1,0 	op <
151:    JLT  0,2(7) 	br if true
152:    LDC  0,0(0) 	false case
153:    LDA  7,1(7) 	unconditional jmp
154:    LDC  0,1(0) 	true case
* <- Op
* while: jump to end belongs here
* -> compound
* -> assign
* -> Id (k)
156:    LDC  0,-6(0) 	id: load varOffset
157:    ADD  0,6,0 	id: calculate the address
158:    LDA  0,0(0) 	load id address
* <- Id
159:     ST  0,-8(6) 	assign: push left (address)
* -> Call
* -> Id (a)
160:    LDC  0,-2(0) 	id: load varOffset
161:    ADD  0,6,0 	id: calculate the address
162:     LD  0,0(0) 	load id value
* <- Id
* -> Id (i)
163:    LDC  0,-5(0) 	id: load varOffset
164:    ADD  0,6,0 	id: calculate the address
165:     LD  0,0(0) 	load id value
* <- Id
* -> Id (high)
166:    LDC  0,-4(0) 	id: load varOffset
167:    ADD  0,6,0 	id: calculate the address
168:     LD  0,0(0) 	load id value
* <- Id
169:     ST  0,-11(6) 	call: push argument
* -> Id (i)
170:    LDC  0,-5(0) 	id: load varOffset
171:    ADD  0,6,0 	id: calculate the address
172:     LD  0,0(0) 	load id value
* <- Id
* -> Id (high)
173:    LDC  0,-4(0) 	id: load varOffset
174:    ADD  0,6,0 	id: calculate the address
175:     LD  0,0(0) 	load id value
* <- Id
176:     ST  0,-12(6) 	call: push argument
* -> Id (high)
177:    LDC  0,-4(0) 	id: load varOffset
178:    ADD  0,6,0 	id: calculate the address
179:     LD  0,0(0) 	load id value
* <- Id
180:     ST  0,-13(6) 	call: push argument
181:     ST  6,-9(6) 	call: store current mp
182:    LDA  6,-9(6) 	call: push new frame
183:    LDA  0,1(7) 	call: save return in ac
184:     LD  7,-1(5) 	call: relative jump to function entry
185:     LD  6,0(6) 	call: pop current frame
* <- Call
186:     LD  1,-8(6) 	assign: load left (address)
187:     ST  0,0(1) 	assign: store value
* <- assign
* -> assign
* -> Id (t)
188:    LDC  0,-7(0) 	id: load varOffset
189:    ADD  0,6,0 	id: calculate the address
190:    LDA  0,0(0) 	load id address
* <- Id
191:     ST  0,-8(6) 	assign: push left (address)
* -> Id (a)
192:    LDC  0,-2(0) 	id: load varOffset
193:    ADD  0,6,0 	id: load the memory address of base address of array to ac
194:     LD  0,0,0 	id: load the base address of array to ac
195:     ST  0,-9(6) 	id: push base address
* -> Id (k)
196:    LDC  0,-6(0) 	id: load varOffset
197:    ADD  0,6,0 	id: calculate the address
198:     LD  0,0(0) 	load id value
* <- Id
199:     LD  1,-9(6) 	id: pop base address
200:    SUB  0,1,0 	id: calculate element address with index
201:     LD  0,0(0) 	load id value
* <- Id
202:     LD  1,-8(6) 	assign: load left (address)
203:     ST  0,0(1) 	assign: store value
* <- assign
* -> assign
* -> Id (a)
204:    LDC  0,-2(0) 	id: load varOffset
205:    ADD  0,6,0 	id: load the memory address of base address of array to ac
206:     LD  0,0,0 	id: load the base address of array to ac
207:     ST  0,-8(6) 	id: push base address
* -> Id (k)
208:    LDC  0,-6(0) 	id: load varOffset
209:    ADD  0,6,0 	id: calculate the address
210:     LD  0,0(0) 	load id value
* <- Id
211:     LD  1,-8(6) 	id: pop base address
212:    SUB  0,1,0 	id: calculate element address with index
213:    LDA  0,0(0) 	load id address
* <- Id
214:     ST  0,-8(6) 	assign: push left (address)
* -> Id (a)
215:    LDC  0,-2(0) 	id: load varOffset
216:    ADD  0,6,0 	id: load the memory address of base address of array to ac
217:     LD  0,0,0 	id: load the base address of array to ac
218:     ST  0,-9(6) 	id: push base address
* -> Id (i)
219:    LDC  0,-5(0) 	id: load varOffset
220:    ADD  0,6,0 	id: calculate the address
221:     LD  0,0(0) 	load id value
* <- Id
222:     LD  1,-9(6) 	id: pop base address
223:    SUB  0,1,0 	id: calculate element address with index
224:     LD  0,0(0) 	load id value
* <- Id
225:     LD  1,-8(6) 	assign: load left (address)
226:     ST  0,0(1) 	assign: store value
* <- assign
* -> assign
* -> Id (a)
227:    LDC  0,-2(0) 	id: load varOffset
228:    ADD  0,6,0 	id: load the memory address of base address of array to ac
229:     LD  0,0,0 	id: load the base address of array to ac
230:     ST  0,-8(6) 	id: push base address
* -> Id (i)
231:    LDC  0,-5(0) 	id: load varOffset
232:    ADD  0,6,0 	id: calculate the address
233:     LD  0,0(0) 	load id value
* <- Id
234:     LD  1,-8(6) 	id: pop base address
235:    SUB  0,1,0 	id: calculate element address with index
236:    LDA  0,0(0) 	load id address
* <- Id
237:     ST  0,-8(6) 	assign: push left (address)
* -> Id (t)
238:    LDC  0,-7(0) 	id: load varOffset
239:    ADD  0,6,0 	id: calculate the address
240:     LD  0,0(0) 	load id value
* <- Id
241:     LD  1,-8(6) 	assign: load left (address)
242:     ST  0,0(1) 	assign: store value
* <- assign
* -> assign
* -> Id (i)
243:    LDC  0,-5(0) 	id: load varOffset
244:    ADD  0,6,0 	id: calculate the address
245:    LDA  0,0(0) 	load id address
* <- Id
246:     ST  0,-8(6) 	assign: push left (address)
* -> Op
* -> Id (i)
247:    LDC  0,-5(0) 	id: load varOffset
248:    ADD  0,6,0 	id: calculate the address
249:     LD  0,0(0) 	load id value
* <- Id
250:     ST  0,-9(6) 	op: push left
* -> Const
251:    LDC  0,1(0) 	load const
* <- Const
252:     LD  1,-9(6) 	op: load left
253:    ADD  0,1,0 	op +
* <- Op
254:     LD  1,-8(6) 	assign: load left (address)
255:     ST  0,0(1) 	assign: store value
* <- assign
* <- compound
256:    LDA  7,-119(7) 	while: jmp back to test
155:    JEQ  0,101(7) 	while: jmp to end
* <- while.
* <- compound
257:     LD  7,-1(6) 	func: load pc with return address
127:    LDA  7,130(7) 	func: unconditional jump to next declaration
* -> Function (sort)
* -> Function (main)
259:     ST  1,-3(5) 	func: store the location of func. entry
* func: unconditional jump to next declaration belongs here
* func: function body starts here
258:    LDC  1,261(0) 	func: load function location
261:     ST  0,-1(6) 	func: store return address
* -> compound
* -> assign
* -> Id (i)
262:    LDC  0,-2(0) 	id: load varOffset
263:    ADD  0,6,0 	id: calculate the address
264:    LDA  0,0(0) 	load id address
* <- Id
265:     ST  0,-3(6) 	assign: push left (address)
* -> Const
266:    LDC  0,0(0) 	load const
* <- Const
267:     LD  1,-3(6) 	assign: load left (address)
268:     ST  0,0(1) 	assign: store value
* <- assign
* -> while.
* while: jump after body comes back here
* -> Op
* -> Id (i)
269:    LDC  0,-2(0) 	id: load varOffset
270:    ADD  0,6,0 	id: calculate the address
271:     LD  0,0(0) 	load id value
* <- Id
272:     ST  0,-3(6) 	op: push left
* -> Const
273:    LDC  0,10(0) 	load const
* <- Const
274:     LD  1,-3(6) 	op: load left
275:    SUB  0,1,0 	op <
276:    JLT  0,2(7) 	br if true
277:    LDC  0,0(0) 	false case
278:    LDA  7,1(7) 	unconditional jmp
279:    LDC  0,1(0) 	true case
* <- Op
* while: jump to end belongs here
* -> compound
* -> assign
* -> Id (x)
281:    LDC  0,0(0) 	id: load varOffset
282:    ADD  0,5,0 	id: calculate the address
283:     ST  0,-3(6) 	id: push base address
* -> Id (i)
284:    LDC  0,-2(0) 	id: load varOffset
285:    ADD  0,6,0 	id: calculate the address
286:     LD  0,0(0) 	load id value
* <- Id
287:     LD  1,-3(6) 	id: pop base address
288:    SUB  0,1,0 	id: calculate element address with index
289:    LDA  0,0(0) 	load id address
* <- Id
290:     ST  0,-3(6) 	assign: push left (address)
* -> Call
291:     IN  0,0,0 	read integer value
* <- Call
292:     LD  1,-3(6) 	assign: load left (address)
293:     ST  0,0(1) 	assign: store value
* <- assign
* -> assign
* -> Id (i)
294:    LDC  0,-2(0) 	id: load varOffset
295:    ADD  0,6,0 	id: calculate the address
296:    LDA  0,0(0) 	load id address
* <- Id
297:     ST  0,-3(6) 	assign: push left (address)
* -> Op
* -> Id (i)
298:    LDC  0,-2(0) 	id: load varOffset
299:    ADD  0,6,0 	id: calculate the address
300:     LD  0,0(0) 	load id value
* <- Id
301:     ST  0,-4(6) 	op: push left
* -> Const
302:    LDC  0,1(0) 	load const
* <- Const
303:     LD  1,-4(6) 	op: load left
304:    ADD  0,1,0 	op +
* <- Op
305:     LD  1,-3(6) 	assign: load left (address)
306:     ST  0,0(1) 	assign: store value
* <- assign
* <- compound
307:    LDA  7,-39(7) 	while: jmp back to test
280:    JEQ  0,27(7) 	while: jmp to end
* <- while.
* -> Call
* -> Id (x)
308:    LDC  0,0(0) 	id: load varOffset
309:    ADD  0,5,0 	id: calculate the address
310:     LD  0,0(0) 	load id value
* <- Id
* -> Const
311:    LDC  0,0(0) 	load const
* <- Const
* -> Const
312:    LDC  0,10(0) 	load const
* <- Const
313:     ST  0,-5(6) 	call: push argument
* -> Const
314:    LDC  0,0(0) 	load const
* <- Const
* -> Const
315:    LDC  0,10(0) 	load const
* <- Const
316:     ST  0,-6(6) 	call: push argument
* -> Const
317:    LDC  0,10(0) 	load const
* <- Const
318:     ST  0,-7(6) 	call: push argument
319:     ST  6,-3(6) 	call: store current mp
320:    LDA  6,-3(6) 	call: push new frame
321:    LDA  0,1(7) 	call: save return in ac
322:     LD  7,-2(5) 	call: relative jump to function entry
323:     LD  6,0(6) 	call: pop current frame
* <- Call
* -> assign
* -> Id (i)
324:    LDC  0,-2(0) 	id: load varOffset
325:    ADD  0,6,0 	id: calculate the address
326:    LDA  0,0(0) 	load id address
* <- Id
327:     ST  0,-3(6) 	assign: push left (address)
* -> Const
328:    LDC  0,0(0) 	load const
* <- Const
329:     LD  1,-3(6) 	assign: load left (address)
330:     ST  0,0(1) 	assign: store value
* <- assign
* -> while.
* while: jump after body comes back here
* -> Op
* -> Id (i)
331:    LDC  0,-2(0) 	id: load varOffset
332:    ADD  0,6,0 	id: calculate the address
333:     LD  0,0(0) 	load id value
* <- Id
334:     ST  0,-3(6) 	op: push left
* -> Const
335:    LDC  0,10(0) 	load const
* <- Const
336:     LD  1,-3(6) 	op: load left
337:    SUB  0,1,0 	op <
338:    JLT  0,2(7) 	br if true
339:    LDC  0,0(0) 	false case
340:    LDA  7,1(7) 	unconditional jmp
341:    LDC  0,1(0) 	true case
* <- Op
* while: jump to end belongs here
* -> compound
* -> Call
* -> Id (x)
343:    LDC  0,0(0) 	id: load varOffset
344:    ADD  0,5,0 	id: calculate the address
345:     ST  0,-3(6) 	id: push base address
* -> Id (i)
346:    LDC  0,-2(0) 	id: load varOffset
347:    ADD  0,6,0 	id: calculate the address
348:     LD  0,0(0) 	load id value
* <- Id
349:     LD  1,-3(6) 	id: pop base address
350:    SUB  0,1,0 	id: calculate element address with index
351:     LD  0,0(0) 	load id value
* <- Id
352:     ST  0,-5(6) 	call: push argument
353:     LD  0,-5(6) 	load arg to ac
354:    OUT  0,0,0 	write ac
* <- Call
* -> assign
* -> Id (i)
355:    LDC  0,-2(0) 	id: load varOffset
356:    ADD  0,6,0 	id: calculate the address
357:    LDA  0,0(0) 	load id address
* <- Id
358:     ST  0,-3(6) 	assign: push left (address)
* -> Op
* -> Id (i)
359:    LDC  0,-2(0) 	id: load varOffset
360:    ADD  0,6,0 	id: calculate the address
361:     LD  0,0(0) 	load id value
* <- Id
362:     ST  0,-4(6) 	op: push left
* -> Const
363:    LDC  0,1(0) 	load const
* <- Const
364:     LD  1,-4(6) 	op: load left
365:    ADD  0,1,0 	op +
* <- Op
366:     LD  1,-3(6) 	assign: load left (address)
367:     ST  0,0(1) 	assign: store value
* <- assign
* <- compound
368:    LDA  7,-38(7) 	while: jmp back to test
342:    JEQ  0,26(7) 	while: jmp to end
* <- while.
* <- compound
369:     LD  7,-1(6) 	func: load pc with return address
260:    LDA  7,109(7) 	func: unconditional jump to next declaration
* -> Function (main)
370:    LDC  0,-13(0) 	init: load globalOffset
371:    ADD  6,6,0 	init: initialize mp with globalOffset
* -> Call
372:     ST  6,0(6) 	call: store current mp
373:    LDA  6,0(6) 	call: push new frame
374:    LDA  0,1(7) 	call: save return in ac
375:    LDC  7,261(0) 	call: unconditional jump to main() entry
376:     LD  6,0(6) 	call: pop current frame
* <- Call
* End of execution.
377:   HALT  0,0,0 	
