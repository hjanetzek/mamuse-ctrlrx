#ifndef __L_FILE__
#define __L_FILE__

#include "LMemoryBlock.h"

// File is final since JUCE 6.1, so the Lua versions of its methods take the File as their first argument
class LFile
{
	public:
		static void findChildFiles (const File &file, luabind::object const& table, int whatToLookFor, bool searchRecursively, const String wildcardPattern);
		static double getSize(const File &file)
		{
			return ((double)file.getSize());
		}

		static File getSpecialLocation(const File::SpecialLocationType type)
		{
			return (File::getSpecialLocation(type));
		}

		static bool replaceWithData (const File &file, const LMemoryBlock &dataToWrite)
		{
			return (file.replaceWithData (dataToWrite.getData(), (size_t)dataToWrite.getSize()));
		}

		static bool appendData (const File &file, const LMemoryBlock &dataToAppend)
		{
			return (file.appendData (dataToAppend.getData(), (size_t)dataToAppend.getSize()));
		}

		static const String descriptionOfSizeInBytes(const double fileSize)
		{
			return (File::descriptionOfSizeInBytes ((juce::int64)fileSize));
		}

		static bool isValid(const File &file);
		static void wrapForLua (lua_State *L);
};

#endif
