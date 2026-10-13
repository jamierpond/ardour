# Port of libs/appleutility/wscript.

ardour_add_library(appleutility SHARED)

target_sources(appleutility PRIVATE
        CoreAudio/PublicUtility/AUOutputBL.cpp
        CoreAudio/PublicUtility/AUParamInfo.cpp
        CoreAudio/PublicUtility/CAAudioChannelLayout.cpp
        CoreAudio/PublicUtility/CAAudioChannelLayoutObject.cpp
        CoreAudio/PublicUtility/CAAudioUnit.cpp
        CoreAudio/PublicUtility/CAAUParameter.cpp
        CoreAudio/PublicUtility/CABufferList.cpp
        CoreAudio/PublicUtility/CACFDictionary.cpp
        CoreAudio/PublicUtility/CACFNumber.cpp
        CoreAudio/PublicUtility/CACFString.cpp
        CoreAudio/PublicUtility/CAComponent.cpp
        CoreAudio/PublicUtility/CAComponentDescription.cpp
        CoreAudio/PublicUtility/CADebugMacros.cpp
        CoreAudio/PublicUtility/CAStreamBasicDescription.cpp
        CoreAudio/PublicUtility/CAXException.cpp)

ardour_includes(appleutility PRIVATE . INTERFACE CoreAudio/PublicUtility)
ardour_uselib(appleutility AUDIOUNITS OSX)

# "apple did not write this library with full symbol export control so we
# need to override any visibility default."
target_compile_options(appleutility PRIVATE -fvisibility=default)
