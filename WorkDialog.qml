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

import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.11
import QtQuick.Window 2.11

import ProjectsData 1.0

Dialog {
    id: workDialog
    title: qsTr("Add new Work")
    modal: true

    property ProgressModel workDataModel

    function sizeFromHoursModel() {
        return 9
    }
    function formatNumberFromHoursModel(number) {
        var label = [ "0", "1", "2", "3", "4", "5", "6", "7", "8" ]
        return label[number]
    }
    function hoursFromHoursModel(number) {
        var hours = [ 0,1,2,3,4,5,6,7,8 ]
        return hours[number]
    }

    function sizeFromMinutesModel() {
        return 7
    }
    function formatNumberFromMinutesModel(number) {
        var label = [ "0", "5", "15", "20", "30", "40", "45" ]
        return label[number]
    }
    function minutesFromMinutesModel(number) {
        var minutes = [ 0,5,15,20,30,40,45 ]
        return minutes[number]
    }

    onOpened: {
        projectTitle.text = ""
        hoursTumbler.currentIndex = 0
        minutesTumbler.currentIndex = 0
    }
    onAccepted: {
        workDataModel.append(projectTitle.text,"",hoursFromHoursModel(hoursTumbler.currentIndex)*3600+minutesFromMinutesModel(minutesTumbler.currentIndex)*60,newWorkType.currentIndex)
    }
    onRejected: workDialog.close()

    contentItem: ColumnLayout {

        ComboBox {
            id: newWorkType
            Layout.fillWidth: true
            Component.onCompleted: currentIndex = 0
            model: {
                [ qsTr("working at home"), qsTr("working in office") ]
            }
        }
        RowLayout {
            id: description

            Label {
                id: gfhgfhs
                text: qsTr("title")
            }

            TextField {
                id: projectTitle
                text: ""
            }
        }

        RowLayout {
            id: rowTumbler

            Label {
                text: qsTr("time spent")
            }
            Tumbler {
                id: hoursTumbler
                model: sizeFromHoursModel()
                delegate: TumblerDelegate {
                    text: formatNumberFromHoursModel(modelData)
                }
            }
            Tumbler {
                id: minutesTumbler
                model: sizeFromMinutesModel()
                delegate: TumblerDelegate {
                    text: formatNumberFromMinutesModel(modelData)
                }
            }
        }

        RowLayout {
            Button {
                text: qsTr("Cancel")
                onClicked: close()
            }
            Item {
                Layout.fillWidth: true
            }
            Button {
                text: qsTr("OK")
                onClicked: accept()
            }
        }
    }
}
