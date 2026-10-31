#ifndef L_FONT
#define L_FONT

extern  "C"
{
	#include "lua.h"
}

// Font is final since JUCE 6.1
class LFont
{
	public:
		static void wrapForLua (lua_State *L);
};

#endif
