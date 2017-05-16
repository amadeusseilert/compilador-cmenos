/****************************************************/
/* File: cgen.c                                     */
/* The code generator implementation                */
/* for the TINY compiler                            */
/* (generates code for the TM machine)              */
/* Compiler Construction: Principles and Practice   */
/* Kenneth C. Louden                                */
/****************************************************/

#include "globals.h"
#include "symtab.h"
#include "code.h"
#include "cgen.h"

static char buffer[1000];

#define ofpFO 0
#define retFO -1
#define initFO -2

static int globalOffset = 0;
static int localOffset = initFO;

/* nParams is the number of parameters in current frame */
static int nParams = 0;

/* inFunc is the flag that shows if current node
   is in a function block. This flag is used when
   calculating localOffset of a function declaration.
*/
static int inFunc = FALSE;

/* mainLoc is the location of main() function */
static int mainLoc = 0;

/* prototype for internal recursive code generator */
static void cGen (TreeNode * tree);

/* Function getBlockOffset returns the offset for
 * temp variables in the block where list is */
static int getBlockOffset(TreeNode * list) {
	int offset = 0;

	if (list != NULL) {
		if (list->nodekind == DeclK){
			TreeNode * node = list;
			while (node != NULL) {
				switch (node->kind.decl) {
					case VarK:
						if (node->idtype == Array) {
							offset += node->val;
						} else {
							++offset;
						}
						break;
					case ParamK:
						++offset;
						break;
					default:
						break;
				}
				node = node->sibling;
			}
		}

	}

	return offset;
}

/* Procedure genStmt generates code at a statement node */
static void genStmt( TreeNode * tree){
	TreeNode * p1, * p2, * p3;

  	int loc1, loc2, currentLoc;
  	int offset;

  	switch (tree->kind.stmt) {
		case CmpdK:
			if (TraceCode) emitComment("-> compound");

			p1 = tree->child[0];
			p2 = tree->child[1];

			/* update localOffset with the offset derived from declarations */
			offset = getBlockOffset(p1);
			localOffset -= offset;

			/* push scope */
			sc_push(sc_find(tree->enclosingFunction->name));

			/* generate code for body */
			cGen(p2);

			/* pop scope */
			sc_pop();

			/* restore localOffset */
			localOffset -= offset;

			if (TraceCode) emitComment("<- compound");
			break;
		case IfK:
			if (TraceCode) emitComment("-> if");

			p1 = tree->child[0];
			p2 = tree->child[1];
			p3 = tree->child[2];

			/* generate code for test expression */
			cGen(p1);

			loc1 = emitSkip(1);
			emitComment("if: jump to else belongs here");

			/* recurse on then part */
			cGen(p2);

			loc2 = emitSkip(1);
			emitComment("if: jump to end belongs here");

			currentLoc = emitSkip(0);
			emitBackup(loc1);
			emitRM_Abs("JEQ", ac, currentLoc, "if: jmp to else");
			emitRestore();
			/* recurse on else part */
			cGen(p3);
			currentLoc = emitSkip(0);
			emitBackup(loc2);
			emitRM_Abs("LDA",pc,currentLoc,"jmp to end");
			emitRestore();
			if (TraceCode)  emitComment("<- if");
			break;
		case WhileK:
			if (TraceCode) emitComment("-> while.");

	        p1 = tree->child[0];
	        p2 = tree->child[1];

	        loc1 = emitSkip(0);
	        emitComment("while: jump after body comes back here");

	        /* generate code for test expression */
	        cGen(p1);

	        loc2 = emitSkip(1);
	        emitComment("while: jump to end belongs here");

	        /* generate code for body */
	        cGen(p2);
	        emitRM_Abs("LDA", pc, loc1, "while: jmp back to test");
	        /* backpatch */
	        currentLoc = emitSkip(0);
	        emitBackup(loc2);
	        emitRM_Abs("JEQ", ac, currentLoc, "while: jmp to end");
	        emitRestore();

	        if (TraceCode)  emitComment("<- while.");
			break;

		case ReturnK:
			if (TraceCode) emitComment("-> return");

			p1 = tree->child[0];

			/* generate code for expression */
			cGen(p1);
			emitRM("LD", pc, retFO, mp, "return: to caller");

			if (TraceCode) emitComment("<- return");
			break;
		default:
			break;
	}
} /* genStmt */

/* Procedure genExp generates code at an expression node */
static void genExp( TreeNode * tree, int isAddr){
	TreeNode * p1, * p2;

	int loc;
  	int varOffset;
	int nArgs;

  	switch (tree->kind.exp) {
    	case OpK:
	  		if (TraceCode) emitComment("-> Op");

	  		p1 = tree->child[0];
	  		p2 = tree->child[1];

		  	/* gen code for ac = left arg */
		  	cGen(p1);
		  	/* gen code to push left operand */
		  	emitRM("ST", ac, localOffset--, mp, "op: push left");

		  	/* gen code for ac = right operand */
		  	cGen(p2);
		  	/* now load left operand */
		  	emitRM("LD", ac1, ++localOffset, mp, "op: load left");

	  		switch (tree->op) {
	    		case PLUS:
	      			emitRO("ADD", ac, ac1, ac, "op +");
	      			break;
	    		case MINUS:
	      			emitRO("SUB", ac, ac1, ac, "op -");
	      			break;
	    		case TIMES:
	      			emitRO("MUL", ac, ac1, ac, "op *");
	      			break;
	    		case OVER:
	      			emitRO("DIV", ac, ac1, ac, "op /");
	      			break;
			    case LT:
					emitRO("SUB", ac, ac1, ac, "op <");
					emitRM("JLT", ac, 2, pc, "br if true");
					emitRM("LDC", ac, 0, ac, "false case");
					emitRM("LDA", pc, 1, pc, "unconditional jmp");
					emitRM("LDC", ac, 1, ac, "true case");
					break;
				case LTE:
					emitRO("SUB", ac, ac1, ac, "op <=");
					emitRM("JLE", ac, 2, pc, "br if true");
					emitRM("LDC", ac, 0, ac, "false case");
					emitRM("LDA", pc, 1, pc, "unconditional jmp");
					emitRM("LDC", ac, 1, ac, "true case");
					break;
				case GT:
					emitRO("SUB", ac, ac1, ac, "op >");
					emitRM("JGT", ac, 2, pc, "br if true");
					emitRM("LDC", ac, 0, ac, "false case");
					emitRM("LDA", pc, 1, pc, "unconditional jmp");
					emitRM("LDC", ac, 1, ac, "true case");
					break;
				case GTE:
					emitRO("SUB", ac, ac1, ac, "op >=");
					emitRM("JGE", ac, 2, pc, "br if true");
					emitRM("LDC", ac, 0, ac, "false case");
					emitRM("LDA", pc, 1, pc, "unconditional jmp");
					emitRM("LDC", ac, 1, ac, "true case");
					break;
				case EQ:
					emitRO("SUB", ac, ac1, ac, "op ==");
					emitRM("JEQ", ac, 2, pc, "br if true");
					emitRM("LDC", ac, 0, ac, "false case");
					emitRM("LDA", pc, 1, pc, "unconditional jmp");
					emitRM("LDC", ac, 1, ac, "true case");
					break;
				case DIF:
					emitRO("SUB", ac, ac1, ac, "op !=");
					emitRM("JNE", ac, 2, pc, "br if true");
					emitRM("LDC", ac, 0, ac, "false case");
					emitRM("LDA", pc, 1, pc, "unconditional jmp");
					emitRM("LDC", ac, 1, ac, "true case");
					break;
				default:
					emitComment("BUG: Unknown operator");
					break;
			} /* case op */

			if (TraceCode)  emitComment("<- Op");
			break; /* OpK */

		case ConstK:
			if (TraceCode) emitComment("-> Const") ;
			/* gen code to load integer constant using LDC */
			emitRM("LDC", ac, tree->val, 0, "load const");
			if (TraceCode)  emitComment("<- Const") ;
			break; /* ConstK */

		case IdK:
			if (TraceCode) {
			  sprintf(buffer, "-> Id (%s)", tree->name);
			  emitComment(buffer);
			}

			loc = st_lookup_top(tree->name);
			if (loc >= 0)
				varOffset = initFO - loc;
			else
				varOffset = -(st_lookup(tree->name));

			/* generate code to load varOffset */
			emitRM("LDC", ac, varOffset, 0, "id: load varOffset");

			if (tree->idtype == Array) {
				/* kind of node is for array id */

				if (loc >= 0 && loc < nParams) {

				  /* generate code to push address */
				  emitRO("ADD", ac, mp, ac, "id: load the memory address of base address of array to ac");
				  emitRO("LD", ac, 0, ac, "id: load the base address of array to ac");
				} else {
				 	/* global or local variable */

				  	/* generate code for address */
				  	if (loc >= 0)
				    	/* symbol found in current frame */
				    	emitRO("ADD", ac, mp, ac, "id: calculate the address");
				  	else
					    /* symbol found in global scope */
					    emitRO("ADD", ac, gp, ac, "id: calculate the address");
				}

				/* generate code to push localOffset */
				emitRM("ST", ac, localOffset--, mp, "id: push base address");

				/* generate code for index expression */
				p1 = tree->child[0];
				cGen(p1);
				/* gen code to get correct varOffset */
				emitRM("LD", ac1, ++localOffset, mp, "id: pop base address");
				emitRO("SUB", ac, ac1, ac, "id: calculate element address with index");
			} else {
				/* kind of node is for non-array id */

				/* generate code for address */
				if (loc >= 0)
				  	/* symbol found in current frame */
					emitRO("ADD", ac, mp, ac, "id: calculate the address");
				else
				  	/* symbol found in global scope */
					emitRO("ADD", ac, gp, ac, "id: calculate the address");
			}

			if (isAddr) {
				emitRM("LDA", ac, 0, ac, "load id address");
			} else {
				emitRM("LD", ac, 0, ac, "load id value");
			}

			if (TraceCode)  emitComment("<- Id");

			break; /* IdK */
		case AssignK:
			if (TraceCode) emitComment("-> assign");

			p1 = tree->child[0];
			p2 = tree->child[1];

			/* generate code for ac = address of lhs */
			genExp(p1, TRUE);
			/* generate code to push lhs */
			emitRM("ST", ac, localOffset--, mp, "assign: push left (address)");

			/* generate code for ac = rhs */
			cGen(p2);
			/* now load lhs */
			emitRM("LD", ac1, ++localOffset, mp, "assign: load left (address)");

			emitRM("ST", ac, 0, ac1, "assign: store value");

			if (TraceCode) emitComment("<- assign");
			break; /* assign_k */
		case CallK:
			if (TraceCode) emitComment("-> Call");

			/* init */
			nArgs = 0;

			p1 = tree->child[0];

			/* for each argument */
			while (p1 != NULL) {
				/* generate code for argument expression */
				// if (p1->idtype == Array)
				//   	genExp(p1, TRUE);
				// else
				//   	genExp(p1, FALSE);

				cGen(p1);

				/* generate code to push argument value */
				emitRM("ST", ac, localOffset + initFO - (nArgs++), mp, "call: push argument");

				p1 = p1->sibling;
			}

			if (strcmp(tree->name, "input") == 0) {
				/* generate code for input() function */
				emitRO("IN",ac,0,0,"read integer value");
			} else if (strcmp(tree->name, "output") == 0) {
				/* generate code for output(arg) function */
				/* generate code for value to write */
				emitRM("LD", ac, localOffset + initFO, mp, "load arg to ac");
				/* now output it */
				emitRO("OUT", ac, 0, 0, "write ac");
			} else {
				/* generate code to store current mp */
				emitRM("ST", mp, localOffset + ofpFO, mp, "call: store current mp");
				/* generate code to push new frame */
				emitRM("LDA", mp, localOffset, mp, "call: push new frame");
				/* generate code to save return in ac */
				emitRM("LDA", ac, 1, pc, "call: save return in ac");

				/* generate code to relative-jump to function entry */
				loc = -(st_lookup(tree->name));
				emitRM("LD", pc, loc, gp, "call: relative jump to function entry");

				/* generate code to pop current frame */
				emitRM("LD", mp, ofpFO, mp, "call: pop current frame");
			}

			if (TraceCode)  emitComment("<- Call");
			break;
		default:
			break;
	}
} /* genExp */

/* Procedure genDecl generates code at a declaration node */
static void genDecl( TreeNode * tree){
	TreeNode * p1, * p2;

  	int loc, loadFuncLoc, jmpLoc, funcBodyLoc, nextDeclLoc;
  	int size;

  	switch (tree->kind.decl) {
  		case FunK:
    		if (TraceCode) {
      			sprintf(buffer, "-> Function (%s)", tree->name);
      			emitComment(buffer);
    		}

		    p1 = tree->child[0];
		    p2 = tree->child[1];

		    inFunc = TRUE;

		    /* generate code to store the location of func. entry */
		    loc = -(st_lookup(tree->name));
		    loadFuncLoc = emitSkip(1);
		    emitRM("ST", ac1, loc, gp, "func: store the location of func. entry");
		    /* decrease global offset by 1 */
		    --globalOffset;

		    /* generate code to unconditionally jump to next declaration */
		    jmpLoc = emitSkip(1);
		    emitComment(
		        "func: unconditional jump to next declaration belongs here");

		    /* skip code generation to allow jump to here
		       when the function was called */
		    funcBodyLoc = emitSkip(0);
		    emitComment("func: function body starts here");

		    /* backpatch */
		    emitBackup(loadFuncLoc);
		    emitRM("LDC", ac1, funcBodyLoc, 0, "func: load function location");
		    emitRestore();

		    /* generate code to store return address */
		    emitRM("ST", ac, retFO, mp, "func: store return address");

		    /* calculate localOffset and nParams */
		    localOffset = initFO;
		    nParams = 0;
		    cGen(p1);

		    /* generate code for function body */
		    if (strcmp(tree->name, "main") == 0)
		      mainLoc = funcBodyLoc;

		    cGen(p2);

		    /* generate code to load pc with return address */
		    emitRM("LD", pc, retFO, mp, "func: load pc with return address");

		    /* backpatch */
		    nextDeclLoc = emitSkip(0);
		    emitBackup(jmpLoc);
		    emitRM_Abs("LDA", pc, nextDeclLoc,
		        "func: unconditional jump to next declaration");
		    emitRestore();

		    inFunc = FALSE;

		    if (TraceCode) {
		      	sprintf(buffer, "-> Function (%s)", tree->name);
		      	emitComment(buffer);
		    }

    		break;

  		case VarK:
    		if (TraceCode) emitComment("-> var. decl.");

		    if (tree->idtype == Array)
		      	size = tree->val;
		    else
		      	size = 1;

    		if (inFunc == TRUE)
      			localOffset -= size;
    		else
      			globalOffset -= size;

    		if (TraceCode) emitComment("<- var. decl.");
    		break;
		case ParamK:
			if (TraceCode) emitComment("-> param");
			emitComment(tree->name);

			--localOffset;
			++nParams;

			if (TraceCode) emitComment("<- param");

			break;

  		default:
     		break;
  	}
} /* genDecl */

/* Procedure cGen recursively generates code by
 * tree traversal
 */
static void cGen( TreeNode * tree){
	if (tree != NULL) {
		switch (tree->nodekind) {
      		case StmtK:
        		genStmt(tree);
        		break;
			case ExpK:
				genExp(tree, FALSE);
				break;
			case DeclK:
				genDecl(tree);
				break;
			default:
				break;
		}
		cGen(tree->sibling);
  	}
}

void genMainCall() {
	emitRM("LDC", ac, globalOffset, 0, "init: load globalOffset");
	emitRO("ADD", mp, mp, ac, "init: initialize mp with globalOffset");

	if (TraceCode) emitComment("-> Call");

	/* generate code to store current mp */
	emitRM("ST", mp, ofpFO, mp, "call: store current mp");
	/* generate code to push new frame */
	emitRM("LDA", mp, 0, mp, "call: push new frame");
	/* generate code to save return in ac */
	emitRM("LDA", ac, 1, pc, "call: save return in ac");

	/* generate code for unconditional jump to function entry */
	emitRM("LDC", pc, mainLoc, 0, "call: unconditional jump to main() entry");

	/* generate code to pop current frame */
	emitRM("LD", mp, ofpFO, mp, "call: pop current frame");

	if (TraceCode) emitComment("<- Call");
}

/**********************************************/
/* the primary function of the code generator */
/**********************************************/
/* Procedure codeGen generates code to a code
 * file by traversal of the syntax tree. The
 * second parameter (codefile) is the file name
 * of the code file, and is used to print the
 * file name as a comment in the code file
 */
void codeGen(TreeNode * syntaxTree, char * codefile) {
	char * s = malloc(strlen(codefile) + 7);
   	strcpy(s, "File: ");
   	strcat(s, codefile);
   	emitComment("C- Compilation to TM Code");
   	emitComment(s);
   	/* generate standard prelude */
   	emitComment("Standard prelude:");
   	emitRM("LD", gp, 0, ac, "load gp with maxaddress");
   	emitRM("LDA", mp, 0, gp, "copy gp to mp");
   	emitRM("ST", ac, 0, ac, "clear location 0");
   	emitComment("End of standard prelude.");
   	/* push global scope */
   	sc_push(globalScope);
   	/* generate code for TINY program */
   	cGen(syntaxTree);
   	/* pop global scope */
   	sc_pop();
   	/* call main() function */
   	genMainCall();
   	/* finish */
   	emitComment("End of execution.");
   	emitRO("HALT", 0, 0, 0, "");
}
