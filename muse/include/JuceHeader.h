// The JuceHeader.h of ctrlrLib, in place of the one the Projucer generates for the CtrlrX application

#pragma once

#include <juce_audio_basics/juce_audio_basics.h>
#include <juce_audio_devices/juce_audio_devices.h>
#include <juce_audio_formats/juce_audio_formats.h>
#include <juce_audio_processors/juce_audio_processors.h>
#include <juce_audio_utils/juce_audio_utils.h>
#include <juce_core/juce_core.h>
#include <juce_cryptography/juce_cryptography.h>
#include <juce_data_structures/juce_data_structures.h>
#include <juce_events/juce_events.h>
#include <juce_graphics/juce_graphics.h>
#include <juce_gui_basics/juce_gui_basics.h>
#include <juce_gui_extra/juce_gui_extra.h>
#include <juce_product_unlocking/juce_product_unlocking.h>

#include "BinaryData.h"

using namespace juce;

// the plugin's settings that CtrlrX reads. The plugin around it has its own
#define JucePlugin_Build_AAX 0
#define JucePlugin_Build_Standalone 0
#define JucePlugin_IsSynth 1
#define JucePlugin_IsMidiEffect 0
#define JucePlugin_WantsMidiInput 1
#define JucePlugin_ProducesMidiOutput 1
#define JucePlugin_VersionString CTRLR_VERSION_STRING

namespace ProjectInfo
{
	const char* const projectName = "CtrlrX";
	const char* const companyName = "CtrlrX";
	const char* const versionString = CTRLR_VERSION_STRING;
}
