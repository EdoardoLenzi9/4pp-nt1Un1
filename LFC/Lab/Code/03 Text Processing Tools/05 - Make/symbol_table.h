
#include "data_structure.h"
typedef int bool;
enum { false, true };

struct TombStone {
	int iChildren;
	int iCurrentChild;
	union {
		struct RuleNode* lpRule;
		char*lpszReferenceValue;
	};
};

struct List {
	struct List * lpPrevious;
	struct List * lpNext;
	char * lpItem;
	struct TombStone* lpSymbol;
};

struct SymbolTable {
	struct List ** lpSymbols;
	int iHashTableSize;
	int iHashBase;
};

struct SymbolTable*CreateSymbolTable(int iSize, int iBase);
bool DestroySymbolTable(struct SymbolTable*ctTable, bool bFreeItems);

struct TombStone* GetSymbolID(struct SymbolTable*ctTable, char*sSet);
bool SetSymbolID(struct SymbolTable*ctTable, char*lpItem,  struct TombStone* lpSymbol);
