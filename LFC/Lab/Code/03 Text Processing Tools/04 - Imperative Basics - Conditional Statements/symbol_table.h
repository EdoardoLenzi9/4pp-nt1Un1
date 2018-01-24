typedef int bool;
enum { false, true };

struct Variable {
	int iType;
	union {
		int iValue;
		float fValue;
		bool bValue;
	};
};

struct List {
	struct List * lpPrevious;
	struct List * lpNext;
	char * lpItem;
	struct Variable* lpSymbol;
};

struct SymbolTable {
	struct List ** lpSymbols;
	int iHashTableSize;
	int iHashBase;
};

struct SymbolTable*CreateSymbolTable(int iSize, int iBase);
bool DestroySymbolTable(struct SymbolTable*ctTable, bool bFreeItems);

struct Variable* GetSymbolID(struct SymbolTable*ctTable, char*sSet);
bool SetSymbolID(struct SymbolTable*ctTable, char*lpItem,  struct Variable* lpSymbol);
