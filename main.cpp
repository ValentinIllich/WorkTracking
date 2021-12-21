/****************************************************************************

    Copyright (C) 2021 Dr. Valentin Illich

    This file is part of WorkTracker.

    WorkTracker is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    WorkTracker is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with WorkTracker.  If not, see <http://www.gnu.org/licenses/>.

****************************************************************************/
#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include "progressmodel.h"

int main(int argc, char *argv[])
{
    for( int idx=1; idx<(argc-1); idx +=2 )
    {
      if( std::string(argv[idx])=="-f" )
      {
        ProgressModel::setStorageBaseFileName(ProgressModel::DataStorage,argv[idx+1]);
        ProgressModel::setStorageBaseFileName(ProgressModel::DefaultListStorage,QString(argv[idx+1])+"-default");
      }
      if( std::string(argv[idx])=="-p" )
      {
        ProgressModel::setStoragePath(argv[idx+1]);
      }
    }

    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);
#if defined(Q_OS_WIN32)
    app.setFont(QFont("SanSerif",9)); // Win 10
#else
    app.setFont(QFont("SanSerif",12)); // Mac
#endif

    qmlRegisterType<ProgressModel>("ProjectsData", 1,0, "ProgressModel");
    qmlRegisterType<ProgressItem>("ProjectsData", 1,0, "ProgressItem");
    qmlRegisterUncreatableType<ProgressModel>("ProjectsData", 1, 0, "OperatingMode", "Access to enums & flags only");

    QQmlApplicationEngine engine;
    ProgressModel::setQmlEngine(engine);
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    int ret = app.exec();

    ProgressModel::cleanupStorage();
    return ret;
}
