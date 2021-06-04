/****************************************************************************
**
** Copyright (C) 2018 The Qt Company Ltd.
** Contact: https://www.qt.io/licensing/
**
** This file is part of the examples of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:BSD$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see https://www.qt.io/terms-conditions. For further
** information use the contact form at https://www.qt.io/contact-us.
**
** BSD License Usage
** Alternatively, you may use this file under the terms of the BSD license
** as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of The Qt Company Ltd nor the names of its
**     contributors may be used to endorse or promote products derived
**     from this software without specific prior written permission.
**
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
**
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Controls.Material 2.4
import QtQuick.Layouts 1.11
import QtQuick.Window 2.11
import QtQuick.Dialogs 1.0
import Qt.labs.calendar 1.0

import ProjectsData 1.0

ApplicationWindow {
    property int windowWidth: 400
    property int windowHeight: 600

    id: window
    width: windowWidth
    height: windowHeight
    visible: true
    title: qsTr("Project Work")

    ProgressModel {
        id: projectData
    }

    Label {
        id: currentDate
        anchors.top: parent.top
        anchors.topMargin: 8
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: Qt.application.font.pixelSize * 2
        text: projectData.title
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
        onClicked: workDialog.open()
        ToolTip.delay: 2000
        ToolTip.timeout: 10000
        ToolTip.visible: hovered
        ToolTip.text: qsTr("add a new work item")
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

    Menu {
        id: displaymenu
        width: windowWidth
        y: modeButton.y-implicitHeight
        onOpened: showwork.checked = projectData.alwaysShowWork
        MenuItem {
            width: windowWidth // needed for language changes (win10)
            text: qsTr("Overview of year")
            onTriggered: projectData.setMode(OperatingMode.DisplayYear)
        }
        MenuItem {
            width: windowWidth // needed for language changes (win10)
            text: qsTr("Overview of month")
            onTriggered: projectData.setMode(OperatingMode.DisplayMonth)
        }
        MenuItem {
            width: windowWidth // needed for language changes (win10)
            text: qsTr("Overview of week")
            onTriggered: projectData.setMode(OperatingMode.DisplayWeek)
        }
        MenuItem {
            width: windowWidth // needed for language changes (win10)
            text: qsTr("Overview of day")
            onTriggered: projectData.setMode(OperatingMode.DisplayRecordDay)
        }
        MenuSeparator {
            width: windowWidth // needed for language changes (win10)
        }
//        ComboBox {
//            width: windowWidth // needed for language changes
//            onActivated: accountChanged(currentIndex)
//            Component.onCompleted: currentIndex = 0
//            model: {
//                [ qsTr("working at home"), qsTr("working in office") ]
//            }
//        }
        MenuItem {
            width: windowWidth // needed for language changes
            enabled: false
            text: qsTr("Overview accounts")
        }
        RowLayout
        {
            RoundButton {
                text: "Home"
                checked: projectData.getAccountSelected(0)
                checkable: true
                Material.background: checked ? Material.accent : "transparent"
                onToggled: projectData.setAccountSelected(0,checked)
            }
            RoundButton {
                text: "Office"
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
            anchors.fill: parent
                Label {
                    text: qsTr("copy to clipboard...")
                    visible: !projectData.showSumInPercent
                }
                Label {
                    text: qsTr("including recreation time of")
                    visible: !projectData.showSumInPercent
                }
                TextField {
                  id: additionalminutes
                  placeholderText: qsTr("minutes of rest")
                  visible: !projectData.showSumInPercent
                  cursorVisible: true
                  text: ""
                }
                Label {
                    text: qsTr("beginning after")
                    visible: !projectData.showSumInPercent
                }
                TextField {
                  id: thresholdofrest
                  placeholderText: qsTr("hours")
                  visible: !projectData.showSumInPercent
                  cursorVisible: true
                  text: ""
                }
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
