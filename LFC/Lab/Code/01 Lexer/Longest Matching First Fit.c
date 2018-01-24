
/* Let lpszInput be the input buffer. */
char*lpszInput = NULL;

/* Hypothesis: a DFA properly constructed does exists and the access to its transition function happens through function
	Delta(,).
 */

/* Check the existence of a matching applying longest matching first fit. */
int PatternMatch(char*lpszInput, int*iReadCharacters) {
	/* Set up a stack of states of the DFA. */
	stack<int> sStateStack;
	/* Assume the match will fail. */
	int iMatch = NO_MATCH;
	/* DUMMY_FINAL_STATE is a fake state which is final: it serves the purpose to stop the last cycle. */
	sStateStack.push( DUMMY_FINAL_STATE );
	/* Start the matching from the initial state. */
	int iState = LEXER_START_STATE;
	/* Consider the 0-th symbol of the input. */
	int iSymbol = lpszInput[*iReadCharacters];
	/* If symbol read is '\0' we reached EOF. Return it. */
	if (iSymbol == '\0') {
		iMatch = EOF_SYMBOL;
	} else {
		/* The matching can stop only in one case:
				The i-th symbol of the input can not be used to walk on an outgoing edge of the current state.
			
			Since it is impossible to walk on an edge by EOF, when the end of file is reached matching stops.
		*/
		while(true) {
			/* If in state iState by symbol iSymbol no destination is set (UNDEFINED) break the loop. */
			if ( Delta(iState, iSymbol) != UNDEFINED ) {
				/* If a destination is defined, it will be the new state on which we work. */
				iState = Delta( iState, iSymbol );
				/* Keep track of the state on the stack.*/
				sStateStack.push( iState );
				/* Copy the current symbol in yytext. */
				yytext[iReadCharacters] = iSymbol;
				
				iReadCharacters++;
				/* Read next character. */
				iSymbol = lpszInput[iReadCharacters];
			} else { break; }
		}
		/* If i reached this line, i was in a state, say, S and i read a symbol, say, T such that
			Delta(S, T) = UNDEFINED. No transition exists.
			
			Now, i need to backtrack, deleting every NON FINAL state on the top of the stack.
		*/
		while ( ! IsFinalState( sStateStack.top() )  ) {
			sStateStack.pop();
			/* When i pop a state which was non final i must delete the symbol that brought me there. */
			iReadCharacters--;
			yytext[iReadCharacters]='\0';
		}
		/* When i reach this line, two situations could occur:
			1. I matched something, i popped zero or more states and i found a final state different from DUMMY_FINAL_STATE.
			2. The word is not in the language, i matched nothing and the loop was broken by DUMMY_FINAL_STATE.
		*/
		iMatch =
			sStateStack.top() == DUMMY_FINAL_STATE
			?
				/* If i got here having DUMMY_FINAL_STATE on the top i leave the returned value untouched: NO_MATCH.*/
				NO_MATCH
			:
				/* If i got here having a final state on the top of the stack i get the symbol/(regular expression) associated with it. */
				GetRegularExpressionAssociatedWith( sStateStack.top() );
	}
	return iMatch;
}
