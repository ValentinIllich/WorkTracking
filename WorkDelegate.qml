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
                    color: model.isActive ? "lightgreen" : "white"
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
