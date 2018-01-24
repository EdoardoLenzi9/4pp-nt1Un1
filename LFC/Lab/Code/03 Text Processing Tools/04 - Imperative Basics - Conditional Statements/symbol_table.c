#include <stdio.h>
#include <stdlib.h>

#include "Symbol_Table.h"

void ListInit(struct List*lList) {
	if (lList!=NULL) {
		lList->lpPrevious = NULL;
		lList->lpNext = NULL;
		lList->lpItem = NULL;
		lList->lpSymbol = NULL;
	}
	return;
}

struct SymbolTable*CreateSymbolTable(int iSize, int iBase) {
	struct SymbolTable*ctTable = ((struct SymbolTable*)calloc(sizeof(struct SymbolTable), sizeof(char)));
	if (ctTable != NULL) {
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
						free(lpIthHead->lpSymbol);
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

bool Append(struct List*lpList, char*lpAppended, struct Variable* lpSymbol) {
	bool bSuccess = false;
	if (lpList != NULL) {
		struct List *lpNextList = calloc(sizeof(struct List), sizeof(char));
		if (lpNextList != NULL) {
			lpNextList->lpItem = lpAppended;
			lpNextList->lpSymbol = lpSymbol;

			lpList->lpNext = lpNextList;
			lpNextList->lpPrevious = lpList;
			bSuccess = true;
		}
	}
	return bSuccess;
}

int ComputeSymbolHash(struct SymbolTable *ctTable, char*lpItem) {
	int iResult = 0;
	if (ctTable != NULL && lpItem != NULL) {
		for (int i = 0; lpItem[i] != L'\0'; i++) {
			iResult += lpItem[i];
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

struct Variable* GetSymbolID(struct SymbolTable*ctTable, char*lpItem) {
	struct Variable* iReturnedClosure = NULL;
	if (ctTable != NULL && lpItem != NULL) {
		if (ctTable->lpSymbols != NULL) {
			int iSearchedHash = ComputeSymbolHash(ctTable, lpItem);

			struct List*lpSearchedList = ctTable->lpSymbols[iSearchedHash];
			if (lpSearchedList != NULL) {
				struct List*lpLast = NULL; bool bFound = false;
				while (lpSearchedList != NULL) {
					char*wTestedChar = lpSearchedList->lpItem;
					if (wTestedChar != NULL && IsSameSymbol(lpItem, wTestedChar)) {
						bFound = true;
						iReturnedClosure = lpSearchedList->lpSymbol;
						break;
					}
					lpLast = lpSearchedList;
					lpSearchedList = lpSearchedList->lpNext;
				}
				if (!bFound) {
					iReturnedClosure = NULL;
				}
			}
		}
	}
	return iReturnedClosure;
}

bool SetSymbolID(struct SymbolTable*ctTable, char*lpItem, struct Variable* lpSymbol) {
	bool bSuccess = false;
	if (ctTable != NULL && lpItem != NULL) {
		if (ctTable->lpSymbols != NULL) {
			int iSearchedHash = ComputeSymbolHash(ctTable, lpItem);

			struct List*lpSearchedList = ctTable->lpSymbols[iSearchedHash];
			if (lpSearchedList == NULL) {
				struct List*lpListHead = calloc(sizeof(struct List), sizeof(char));
				lpListHead->lpItem = lpItem;
				lpListHead->lpSymbol = lpSymbol;
				ctTable->lpSymbols[iSearchedHash] = lpListHead;
				bSuccess = true;
			} else {
				struct List*lpLast = NULL; bool bFound = false;
				while (lpSearchedList != NULL) {
					char*wTestedChar = lpSearchedList->lpItem;
					if (wTestedChar != NULL && IsSameSymbol(lpItem, wTestedChar)) {
						bFound = true; bSuccess = true;
						break;
					}
					lpLast = lpSearchedList;
					lpSearchedList = lpSearchedList->lpNext;
				}
				if (!bFound) {
					bSuccess = Append(lpLast, lpItem, lpSymbol);
				}
			}
		}
	}
	return bSuccess;
}
