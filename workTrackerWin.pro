TEMPLATE = app

QT += quick

SOURCES += main.cpp \
    progressmodel.cpp

TRANSLATIONS = \
    translations/projects_de.ts \
    translations/projects_fr.ts

RESOURCES += qml.qrc

HEADERS += \
    progressmodel.h
