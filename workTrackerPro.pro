TEMPLATE = app

QT += quick

CONFIG += sdk_no_version_check

SOURCES += main.cpp \
  progressmodel.cpp

TRANSLATIONS = \
    translations/workTracking_de.ts \
    translations/workTracking_fr.ts

RESOURCES += qml.qrc

HEADERS += \
  progressmodel.h
