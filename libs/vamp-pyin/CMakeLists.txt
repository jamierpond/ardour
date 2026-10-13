# libs/vamp-pyin/wscript
ardour_target(ardourvamppyin SHARED GLOB
        INCLUDES .
        EXPORT_INCLUDES .
        USELIB VAMPSDK
        OPTIONS -fvisibility=default)
