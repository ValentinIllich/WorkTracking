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
import QtQuick.Controls.Material 2.4
import QtQuick.Layouts 1.11
import QtQuick.Window 2.11
import QtQuick.Dialogs 1.1
import Qt.labs.settings 1.0
import Qt.labs.calendar 1.0

import ProjectsData 1.0

ApplicationWindow {
    property int windowx: projectData.geometry.x
    property int windowy: projectData.geometry.y
    property int windowWidth: projectData.geometry.width
    property int windowHeight: projectData.geometry.height

    property color textColor: Material.foreground

    id: window
    x: windowx
    y: windowy
    width: windowWidth
    height: windowHeight
    visible: true
    title: qsTr("Project Work ") + projectData.getProgramVersion()

    onXChanged: projectData.geometry = Qt.rect(x, y, width, height)
    onYChanged: projectData.geometry = Qt.rect(x, y, width, height)
    onWidthChanged: projectData.geometry = Qt.rect(x, y, width, height)
    onHeightChanged: projectData.geometry = Qt.rect(x, y, width, height)

    ProgressModel {
        id: projectData
        onRecordingDisabled: jumpmenu.open()
    }

    RoundButton {
        id: currentDate
        text: projectData.title
        anchors.top: parent.top
        anchors.topMargin: 8
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: Qt.application.font.pixelSize * 2
        font.capitalization: Font.MixedCase
        onClicked: jumpmenu.open()
        ToolTip.delay: 2000
        ToolTip.timeout: 10000
        ToolTip.visible: hovered
        ToolTip.text: qsTr("Navigation menu")
    }

    ListView {
        id: workListView
        anchors.topMargin: currentDate.height + 2*8
        anchors.bottomMargin: addAlarmButton.height
        anchors.fill: parent
        model: projectData.itemList
        delegate: WorkDelegate {}
    }

    RoundButton {
        id: prevButton
        text: "<"
        anchors.left: parent.left
        anchors.leftMargin: 8
        anchors.top: parent.top
        anchors.topMargin: 8
        onClicked: projectData.previous()
        ToolTip.delay: 2000
        ToolTip.timeout: 10000
        ToolTip.visible: hovered
        ToolTip.text: qsTr("select previous time period")
    }

    RoundButton {
        id: nextButton
        text: ">"
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.top: parent.top
        anchors.topMargin: 8
        onClicked: projectData.next()
        ToolTip.delay: 2000
        ToolTip.timeout: 10000
        ToolTip.visible: hovered
        ToolTip.text: qsTr("select next time period")
    }

    RoundButton {
        id: modeButton
        text: "..."
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 8
        anchors.left: parent.left
        anchors.leftMargin: 8
        onClicked: displaymenu.open()
        onPressAndHold: configmenu.open()
        ToolTip.delay: 2000
        ToolTip.timeout: 10000
        ToolTip.visible: hovered
        ToolTip.text: qsTr("short press: display menu\nlong presas: config menu")
    }

    RoundButton {
        id: addAlarmButton
        text: "+"
        visible: projectData.isChangeable
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 8
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: -helpButton.width / 2
        onClicked: workDialog.open()
        ToolTip.delay: 2000
        ToolTip.timeout: 10000
        ToolTip.visible: hovered
        ToolTip.text: qsTr("add a new work item")
    }

    RoundButton {
        id: helpButton
        text: "?"
        visible: projectData.isChangeable
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 8
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: addAlarmButton.width / 2
        onClicked: projectData.showHelp()
        ToolTip.delay: 2000
        ToolTip.timeout: 10000
        ToolTip.visible: hovered
        ToolTip.text: qsTr("open documentation")
    }

    RoundButton {
        id: sumButton
        text: projectData.totalTime
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 8
        anchors.right: parent.right
        anchors.rightMargin: 8
        onClicked: projectData.changeSummary()
        ToolTip.delay: 2000
        ToolTip.timeout: 10000
        ToolTip.visible: hovered
        ToolTip.text: qsTr("switch between hours and percent\n(but not in day view)")
    }

    function jumpToDay(day,month,year) {
        projectData.jumpToDay(day,month,year)
        jumpmenu.close()
    }

    Menu {
        id: jumpmenu
        width: windowWidth
        y: currentDate.height+8
        MenuItem {
            width: windowWidth // needed for language changes
            Material.foreground: (projectData.currentRecordingAccount == 0) ? Material.accent : textColor
            text: qsTr("Recording at home")
            onTriggered: projectData.currentRecordingAccount = 0
        }
        MenuItem {
            width: windowWidth // needed for language changes
            Material.foreground: projectData.currentRecordingAccount == 1 ? Material.accent : textColor
            text: qsTr("Recording in office")
            onTriggered: projectData.currentRecordingAccount = 1
        }
        MenuSeparator {
            width: windowWidth // needed for language changes
        }
        MenuItem {
            width: windowWidth // needed for language changes
            text: qsTr("Show current day")
            onTriggered: jumpToDay(0,0,0)
        }
        MenuSeparator {
            width: windowWidth // needed for language changes
        }
        RowLayout
        {
            RoundButton {
                id: jumpTo
                Layout.leftMargin: 8
                text: qsTr("Show day:")
                onClicked: jumpToDay(parseInt(jumpday.text),parseInt(jumpmonth.text),parseInt(jumpyear.text))
            }

            Item {
                Layout.fillWidth: true
            }
        }
        RowLayout
        {
            width: windowWidth // needed for language changes

            TextField {
                id: jumpday
                placeholderText: qsTr("Day")
                Layout.leftMargin: jumpTo.x+8
            }
            TextField {
                id: jumpmonth
                placeholderText: qsTr("Month")
            }
            TextField {
                id: jumpyear
                placeholderText: qsTr("Year")
            }
            Item {
                Layout.fillWidth: true
            }
        }
    }

    Menu {
        id: configmenu
        width: windowWidth
        y: modeButton.y-implicitHeight
        MenuItem {
            width: windowWidth // needed for language changes
            text: qsTr("Create default from list")
            onTriggered: projectData.createDefaultList()
        }
        MenuSeparator {
            width: windowWidth // needed for language changes
        }
        MenuItem {
            width: windowWidth // needed for language changes
            enabled: false
            text: qsTr("Select Language")
        }
        MenuItem {
            width: windowWidth // needed for language changes
            text: qsTr("English")
            onTriggered: projectData.setLanguage(0)
        }
        MenuItem {
            width: windowWidth // needed for language changes
            text: qsTr("German")
            onTriggered: projectData.setLanguage(1)
        }
        MenuItem {
            width: windowWidth // needed for language changes
            text: qsTr("French")
            onTriggered: projectData.setLanguage(2)
        }
    }

    function changeVisibleAccounts() {
        displaymenu.close()
    }

    function changeRecordingAccount(account) {
        projectData.currentRecordingAccount = account
        displaymenu.close()
    }

    Menu {
        id: displaymenu
        width: windowWidth
        y: modeButton.y-implicitHeight
        onOpened: showwork.checked = projectData.alwaysShowWork
        MenuItem {
            width: windowWidth // needed for language changes (win10)
            text: qsTr("Overview of year")
            Material.foreground: projectData.mode == 0 ? Material.accent : textColor
            onTriggered: projectData.mode = OperatingMode.DisplayYear
        }
        MenuItem {
            width: windowWidth // needed for language changes (win10)
            text: qsTr("Overview of month")
            Material.foreground: projectData.mode == 1 ? Material.accent : textColor
            onTriggered: projectData.mode = OperatingMode.DisplayMonth
        }
        MenuItem {
            width: windowWidth // needed for language changes (win10)
            text: qsTr("Overview of week")
            Material.foreground: projectData.mode == 2 ? Material.accent : textColor
            onTriggered: projectData.mode = OperatingMode.DisplayWeek
        }
        MenuItem {
            width: windowWidth // needed for language changes (win10)
            text: qsTr("Overview of day")
            Material.foreground: projectData.mode == 3 ? Material.accent : textColor
            onTriggered: projectData.mode = OperatingMode.DisplayRecordDay
        }
        MenuSeparator {
            width: windowWidth // needed for language changes (win10)
        }
        MenuItem {
            width: windowWidth // needed for language changes
            enabled: false
            text: qsTr("Overview using accounts")
        }
        RowLayout
        {
            RoundButton {
                text: qsTr("Home")
                checked: projectData.getAccountSelected(0)
                checkable: true
                Material.background: checked ? Material.accent : "transparent"
                onToggled: projectData.setAccountSelected(0,checked)
            }
            RoundButton {
                text: qsTr("Office")
                id: officework
                checked: projectData.getAccountSelected(1)
                checkable: true
                Material.background: checked ? Material.accent : "transparent"
                onToggled: projectData.setAccountSelected(1,checked)
            }
//            RoundButton {
//                text: "Travel"
//                enabled: false
//                Component.onCompleted: checked = projectData.getAccountSelected(2)
//                checkable: true
//                Material.background: checked ? Material.accent : "transparent"
//                onToggled: projectData.setAccountSelected(2,checked)
//            }
            RoundButton {
                text: "OK"
                onClicked: changeVisibleAccounts()
            }
            Item {
                Layout.fillWidth: true
            }
        }
        MenuItem {
            id: showwork
            width: windowWidth // needed for language changes (win10)
            text: qsTr("always show work items")
            checkable: true
            checked: projectData.alwaysShowWork
            onTriggered: projectData.alwaysShowWork = checked
        }
        MenuItem {
            id: showbreaks
            width: windowWidth // needed for language changes (win10)
            text: qsTr("show break times")
            checkable: true
            checked: projectData.showBreakTimes
            onTriggered: projectData.showBreakTimes = checked
        }
        MenuSeparator {
            width: windowWidth // needed for language changes (win10)
        }
        MenuItem {
            width: windowWidth // needed for language changes
            text: qsTr("copy to clipboard...")
            onTriggered: exportpopup.open()
        }
    }

    function saveClipboard(minutes,beginning) {
        projectData.exportToClipboard(minutes,beginning)
        exportpopup.close()
    }

    Popup {
        id: exportpopup
        //anchors.centerIn: parent
        y: sumButton.y-implicitHeight
        width: parent.width

        ColumnLayout {
                width: windowWidth
                //anchors.fill: parent
                Label {
                    text: qsTr("copy to clipboard...")
                }
                RowLayout {
                    visible: projectData.showExportDays
                    Label {
                        text: qsTr("including recreation time of")
                        visible: projectData.showExportDays
                    }
                    TextField {
                      id: additionalminutes
                      placeholderText: qsTr("minutes of rest")
                      visible: projectData.showExportDays
                      cursorVisible: true
                      text: ""
                    }
                }
                RowLayout {
                    visible: projectData.showExportDays
                    Label {
                        text: qsTr("beginning after")
                        visible: projectData.showExportDays
                    }
                    TextField {
                      id: thresholdofrest
                      placeholderText: qsTr("hours")
                      visible: projectData.showExportDays
                      cursorVisible: true
                      text: ""
                    }
                }
                RowLayout
                {
                    visible: projectData.showExportDays
                    RoundButton {
                        text: qsTr("Mo")
                        visible: projectData.showExportDays
                        checked: projectData.getWeekdaySelected(0)
                        checkable: true
                        Material.background: checked ? Material.accent : "transparent"
                        onClicked: projectData.setWeekdaySelected(0,checked)
                        onVisibleChanged: checked = projectData.getWeekdaySelected(0)
                    }
                    RoundButton {
                        text: qsTr("Tu")
                        visible: projectData.showExportDays
                        checked: projectData.getWeekdaySelected(1)
                        checkable: true
                        Material.background: checked ? Material.accent : "transparent"
                        onClicked: projectData.setWeekdaySelected(1,checked)
                        onVisibleChanged: checked = projectData.getWeekdaySelected(1)
                    }
                    RoundButton {
                        text: qsTr("We")
                        visible: projectData.showExportDays
                        checked: projectData.getWeekdaySelected(2)
                        checkable: true
                        Material.background: checked ? Material.accent : "transparent"
                        onClicked: projectData.setWeekdaySelected(2,checked)
                        onVisibleChanged: checked = projectData.getWeekdaySelected(2)
                    }
                    RoundButton {
                        text: qsTr("Th")
                        visible: projectData.showExportDays
                        checked: projectData.getWeekdaySelected(3)
                        checkable: true
                        Material.background: checked ? Material.accent : "transparent"
                        onClicked: projectData.setWeekdaySelected(3,checked)
                        onVisibleChanged: checked = projectData.getWeekdaySelected(3)
                    }
                    RoundButton {
                        text: qsTr("Fr")
                        visible: projectData.showExportDays
                        checked: projectData.getWeekdaySelected(4)
                        checkable: true
                        Material.background: checked ? Material.accent : "transparent"
                        onClicked: projectData.setWeekdaySelected(4,checked)
                        onVisibleChanged: checked = projectData.getWeekdaySelected(4)
                    }
                }
//                RowLayout
//                {
//                    RoundButton {
//                        text: qsTr("Sa")
//                        checked: projectData.getWeekdaySelected(5)
//                        checkable: true
//                        Material.background: checked ? Material.accent : "transparent"
//                        onToggled: projectData.setWeekdaySelected(5,checked)
//                    }
//                    RoundButton {
//                        text: qsTr("Su")
//                        checked: projectData.getWeekdaySelected(6)
//                        checkable: true
//                        Material.background: checked ? Material.accent : "transparent"
//                        onToggled: projectData.setWeekdaySelected(6,checked)
//                    }
//                }
                RowLayout {
                    Button {
                      text: qsTr("Cancel")
                      onClicked: exportpopup.close()
                    }
                    Button {
                      text: qsTr("OK")
                      onClicked: saveClipboard(additionalminutes.text,thresholdofrest.text)
                    }
                }
        }
    }

    WorkDialog {
        id: workDialog
        x: Math.round((windowWidth - implicitWidth) / 2)
        y: Math.round((windowHeight - implicitHeight) / 2)
        workDataModel: projectData
    }
}
