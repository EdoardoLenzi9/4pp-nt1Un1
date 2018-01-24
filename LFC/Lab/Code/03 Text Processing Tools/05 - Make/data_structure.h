
struct FatherChildCouple {
    char*lpszFatherName;
    char*lpszChildName;
};

struct RuleDependency {
    struct FatherChildCouple**fccDependency;
    int iDependencies;
    int iUsedDependencies;
};

struct CommandNode {
    struct CommandNode*lpLeftCommand;
    struct CommandNode*lpRightCommand;
    char*lpszReference;
    char*lpszSequence;
};
struct RuleNode {
    struct CommandNode*lpCommand;
    char*lpszRuleName;
    struct RuleNode**vorChildren;
    int iChildren;
};
