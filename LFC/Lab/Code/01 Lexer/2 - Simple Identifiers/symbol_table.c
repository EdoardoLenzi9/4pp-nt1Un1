#include <stdio.h>
#include <stdlib.h>

#include "symbol_table.h"

/* Initialize element list. */
void ListInit(struct List*lList) {
	if (lList!=NULL) {
		lList->lpPrevious = NULL;
		lList->lpNext = NULL;
		lList->lpItem = NULL;
		lList->iSymbolID = -1;
	}
	return;
}

/* Create the hash table. */
struct SymbolTable*CreateSymbolTable(int iSize, int iBase) {
	struct SymbolTable*ctTable = ((struct SymbolTable*)calloc(sizeof(struct SymbolTable), sizeof(char)));
	if (ctTable != NULL) {
		/* If number is even, i pick an odd number.*/
		ctTable->iHashTableSize = !(iSize & 1) ? 23 : iSize;
		ctTable->iHashBase = iBase <= 1 ? 2 : iBase;
		ctTable->lpSymbols = calloc(ctTable->iHashTableSize, sizeof(struct List));
		for (int i = 0; i < ctTable->iHashTableSize; i++) {
			ctTable->lpSymbols[i] = NULL;
		}
	}
	return ctTable;
}

bool DestroySymbolTable(struct SymbolTable*ctTable, bool bFreeItems) {
	bool bSuccess = false;
	if (ctTable->lpSymbols != NULL) {
		for (int i = 0; i < ctTable->iHashTableSize; i++) {
			struct List*lpIthHead = ctTable->lpSymbols[i];
			if (lpIthHead != NULL) {
				while (lpIthHead != NULL) {
					if (bFreeItems) {
						free(lpIthHead->lpItem);
					}
					struct List*lpNext = lpIthHead->lpNext;
					free(lpIthHead);
					lpIthHead = lpNext;
				}
			}
		}
		free(ctTable->lpSymbols);
		free(ctTable);
	}
	return bSuccess;
}

bool Append(struct List*lpList, char*lpAppended, int iSymbolID) {
	bool bSuccess = false;
	if (lpList != NULL) {
		struct List *lpNextList = calloc(sizeof(struct List), sizeof(char));
		if (lpNextList != NULL) {
			lpNextList->lpItem = lpAppended;
			lpNextList->iSymbolID = iSymbolID;

			lpList->lpNext = lpNextList;
			lpNextList->lpPrevious = lpList;
			bSuccess = true;
		}
	}
	return bSuccess;
}

int ComputeSymbolHash(struct SymbolTable *ctTable, char*lpszIdentifier) {
	int iResult = 0;
	if (ctTable != NULL && lpszIdentifier != NULL) {
		for (int i = 0; lpszIdentifier[i] != L'\0'; i++) {
			iResult += lpszIdentifier[i];
			iResult *= ctTable->iHashBase;
			iResult %= ctTable->iHashTableSize;
		}
	}
	return iResult;
}

bool IsSameSymbol(char* lpLeftSymbol, char*lpRightSymbol) {
	bool bSuccess = true;
	if (lpLeftSymbol != NULL && lpRightSymbol != NULL) {
		for (int i = 0; lpLeftSymbol[i] != L'\0' && lpRightSymbol[i] != L'\0'; i++) {
			if (lpLeftSymbol[i] != lpRightSymbol[i]) { bSuccess = false; break; }
		}
	}
	return bSuccess;
}

int GetIdentifier(struct SymbolTable*ctTable, char*lpszIdentifier, int iIdentifierID, char**lpRetrievedElement) {
	int iReturnedSymbolID = -1;
	if (ctTable != NULL && lpszIdentifier != NULL) {
		if (ctTable->lpSymbols != NULL) {
			int iSearchedHash = ComputeSymbolHash(ctTable, lpszIdentifier);

			struct List*lpSearchedList = ctTable->lpSymbols[iSearchedHash];
			if (lpSearchedList == NULL) {
				struct List*lpListHead = calloc(sizeof(struct List), sizeof(char));
				lpListHead->lpItem = lpszIdentifier;
				lpListHead->iSymbolID = iIdentifierID;
				ctTable->lpSymbols[iSearchedHash] = lpListHead;
				iReturnedSymbolID = -1;
			} else {
				struct List*lpLast = NULL; bool bFound = false;
				while (lpSearchedList != NULL) {
					char*wTestedChar = lpSearchedList->lpItem;
					if (wTestedChar != NULL && IsSameSymbol(lpszIdentifier, wTestedChar)) {
						bFound = true;
						iReturnedSymbolID = lpSearchedList->iSymbolID;
						if (lpRetrievedElement != NULL) {
							*lpRetrievedElement = lpSearchedList->lpItem;
						}
						break;
					}
					lpLast = lpSearchedList;
					lpSearchedList = lpSearchedList->lpNext;
				}
				if (!bFound) {
					Append(lpLast, lpszIdentifier, iIdentifierID);
					iReturnedSymbolID = -1;
				}
			}
		}
	}
	return iReturnedSymbolID;
}
