/* Define booleans for my comfort. */
typedef int bool;
enum { false, true };

/* A linked list of elements each one unique by name associated with an ID. */
struct List {
	struct List * lpPrevious;
	struct List * lpNext;
	char * lpItem;
	int iSymbolID;
};

/* The symbol table is an hash table with a vector of lists. */
struct SymbolTable {
	struct List ** lpSymbols;
	int iHashTableSize;
	int iHashBase;
};

/*
	Function CreateSymbolTable requires two parameters:
		iBase can be any integer less than iSize, greater than 1.
		iSize HAS TO be a prime number far away from any power of 2.
	If it isn't the hash table will work: with very poor performances.

	Hint: "If you expect the hash table to contain a million elements iBase should be at least one million."
*/
struct SymbolTable*CreateSymbolTable(int iSize, int iBase);
int GetIdentifier(struct SymbolTable*ctTable, char*sSet, int iSymbolID, char**lpRetrieve);
bool DestroySymbolTable(struct SymbolTable*ctTable, bool bFreeItems);
