TEMPLATE = app
TARGET = workTracking
QT += quick

SOURCES += main.cpp \
    progressmodel.cpp

TRANSLATIONS = \
    translations/projects_de.ts \
    translations/projects_fr.ts

RESOURCES += qml.qrc

HEADERS += \
    progressmodel.h

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
