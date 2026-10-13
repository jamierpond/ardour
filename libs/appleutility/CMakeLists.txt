# libs/appleutility/wscript. -fvisibility=default: "apple did not write this
# library with full symbol export control".
set(_srcs
        AUOutputBL.cpp
        AUParamInfo.cpp
        CAAudioChannelLayout.cpp
        CAAudioChannelLayoutObject.cpp
        CAAudioUnit.cpp
        CAAUParameter.cpp
        CABufferList.cpp
        CACFDictionary.cpp
        CACFNumber.cpp
        CACFString.cpp
        CAComponent.cpp
        CAComponentDescription.cpp
        CADebugMacros.cpp
        CAStreamBasicDescription.cpp
        CAXException.cpp)
list(TRANSFORM _srcs PREPEND CoreAudio/PublicUtility/)
ardour_target(appleutility SHARED
        SOURCES ${_srcs}
        INCLUDES .
        EXPORT_INCLUDES CoreAudio/PublicUtility
        USELIB AUDIOUNITS OSX
        OPTIONS -fvisibility=default)
