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

import ProjectsData 1.0

ItemDelegate {
    id: root
    width: parent.width
    checkable: true

    function sizeFromModel() {
        return 7
    }
    function formatNumberFromModel(number) {
        var label = [ "-30", "-15", "-5", "0", "5", "15", "30" ]
        return label[number]
    }
    function secondsFromModel(number) {
        var seconds = [ -30,-15,-5, 0, 5,15,30 ]
        return seconds[number]*60
    }

    function itemTitle(projectName,summary)
    {
        switch(projectData.mode)
        {
        case OperatingMode.DisplayYear:
                return projectName
        case OperatingMode.DisplayMonth:
            return projectName
        case OperatingMode.DisplayWeek:
                return projectName.replace("\t"," ")
        case OperatingMode.DisplayRecordDay:
            return summary + " " + projectName
        }

    }

    function itemDescription(isActive,description)
    {
        if( isActive )
        {
            var prefix = [ qsTr("(currently at home)"),qsTr("(currently in office)") ]
            return prefix[projectData.currentRecordingAccount] + " " + description
        }
        else
            return description
    }

    function currentAccount()
    {
        return model.selectedAccount
    }

    function accountChanged(account)
    {
        model.selectedAccount = account
    }

    function checkVisibility(title)
    {
        if( title === "dffeerfe" )
            return false
        else
            return true
    }

    contentItem: ColumnLayout {
        spacing: 0
        visible: checkVisibility(model.projectName)
        ToolTip.delay: 1000
        ToolTip.timeout: 2000
        ToolTip.visible: hovered && !root.checked && projectData.isChangeable
        ToolTip.text: qsTr("click to open")

        RowLayout {
            ColumnLayout {
                id: workColumn

                Label {
                    id: timeLabel
                    font.pixelSize: Qt.application.font.pixelSize * 2
                    text: itemTitle(model.projectName,model.summary)
                    color: model.isActive ? Material.accent : Material.foreground
                }
                Label {
                    id: projectAbout
                    text: itemDescription(model.isActive,model.description)
                    visible: itemDescription(model.isActive,model.description).length
                }
            }
            Item {
                Layout.fillWidth: true
            }
            Switch {
                visible: projectData.isChangeable
                checked: model.isActive
                Layout.alignment: Qt.AlignCenter
                onClicked: model.isActive = checked
            }
            Label {
                text: model.summary
                font.pixelSize: Qt.application.font.pixelSize * 2
                Layout.alignment: Qt.AlignCenter
                visible: !projectData.isChangeable
            }
        }

        ComboBox {
            Layout.fillWidth: true
            visible: root.checked && projectData.isChangeable
            onActivated: accountChanged(currentIndex)
            currentIndex: currentAccount()
            model: {
                [ qsTr("time correction for home"), qsTr("time correction for office") ]
            }
        }

        RowLayout {
            id: editFields
            ColumnLayout {
                id: projectproperties

                TextField {
                    id: nameTextField
                    placeholderText: qsTr("Enter name here")
                    cursorVisible: true
                    visible: root.checked && projectData.isChangeable
                    text: model.projectName
                    onTextEdited: model.projectName = text
                }
                TextField {
                    id: descriptionTextField
                    placeholderText: qsTr("Enter description here")
                    cursorVisible: true
                    visible: root.checked && projectData.isChangeable
                    text: model.description
                    onTextEdited: model.description = text
                }
                Button {
                    id: deleteButton
                    text: qsTr("Delete")
                    width: 40
                    height: 40
                    visible: root.checked && projectData.isChangeable
                    onClicked: projectData.remove(model.index)
                }
            }

            Item {
                Layout.fillWidth: true
            }

            RowLayout {
                id: workCorrection

                Button {
                    text: qsTr("Add")
                    visible: root.checked && projectData.isChangeable
                    onClicked: projectData.addSeconds(model.index,secondsFromModel(correctionTumbler.currentIndex))
                }
                Tumbler {
                    id: correctionTumbler
                    model: sizeFromModel()
                    delegate: TumblerDelegate {
                        text: formatNumberFromModel(modelData)
                    }
                    currentIndex: 3
                    visible: root.checked && projectData.isChangeable
                }
                Label {
                    text: qsTr("min")
                    visible: root.checked && projectData.isChangeable
                }
            }
        }
    }
}
