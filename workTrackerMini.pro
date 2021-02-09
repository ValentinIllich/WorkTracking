TEMPLATE = app

QT += quick

SOURCES += main.cpp \
    projectmodel.cpp

RESOURCES += qml.qrc

target.path = $$[QT_INSTALL_EXAMPLES]/demos/alarms
INSTALLS += target

HEADERS += \
    projectmodel.h
