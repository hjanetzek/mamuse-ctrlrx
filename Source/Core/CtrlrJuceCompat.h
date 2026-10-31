#pragma once

// What differs between the JUCE 6 that CtrlrX comes with and later versions

#if JUCE_MAJOR_VERSION >= 7
// thread priorities are 0 to 10 in JUCE 6, an enum since JUCE 7
inline Thread::Priority ctrlrThreadPriority (int priority)
{
	if (priority >= 9)
		return Thread::Priority::highest;
	if (priority >= 7)
		return Thread::Priority::high;
	if (priority >= 4)
		return Thread::Priority::normal;
	if (priority >= 2)
		return Thread::Priority::low;
	return Thread::Priority::background;
}
#else
inline int ctrlrThreadPriority (int priority)
{
	return priority;
}
#endif
