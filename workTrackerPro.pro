TEMPLATE = app
TARGET = workTracking
CONFIG += sdk_no_version_check

QT += quick widgets

SOURCES += main.cpp \
  progressmodel.cpp \
  ../backup/Utilities.cpp

TRANSLATIONS = \
    translations/workTracking_de.ts \
    translations/workTracking_fr.ts

RESOURCES += qml.qrc

HEADERS += \
  progressmodel.h \
  ../backup/Utilities.h

win32 {
    RCC_DIR = c:/tmp/backup_$${BUILD}_obj
    RC_FILE = ressources/workTracking.rc
}
macx {
    ICON = ressources/workTracking.icns
    QMAKE_INFO_PLIST = ressources/Info_mac.plist
#    LIBS += -framework Security
}
linux {
}

OTHER_FILES += \
    ressources/workTracking.rc \
    ressources/Info_mac.plist \
    ressources/version.inc

DISTFILES += \
  README.md
