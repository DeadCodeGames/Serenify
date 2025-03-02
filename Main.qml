import QtQuick
import QtQuick.Controls.Basic 2.15
import QtQuick.Layouts

Window {
    width: 400
    height: 600
    minimumWidth: 400
    minimumHeight: 600
    maximumHeight: 600
    maximumWidth: 400
    visible: true
    title: qsTr("Serenify")
    id: root

    // Variables
    property int taskCounter: 0

    // Colors here
    property bool mode: true // False = dark mode, True = light mode
    property color trashColor: mode ? "red" : "#850900"
    property color plusColor: mode ? "blue" : "#03076b"
    property color borderColor: mode ? "#ff9991" : "red"
    property color bgColor: mode ? "white" : "#171716"
    property color textColor: mode ? "black" : "white"
    property color phTextColor: mode ? "#797979" : "#a6a6a6"
    property color greenBtn: mode ? "#54ff22" : "#3ebf19"
    property color greenBtnHover: mode ? "#3aff00" : "#31d600"
    property color greenBtnDisabled: mode ? "#98ff7a" : "#7ac165"
    property color inputBorderNormal: mode ? "#b3b3b3" : "#4d4d4d"
    property color inputBorderError: mode ? "#ff5555" : "#ff3333"
    property color inputBorderValid: mode ? "#55aa55" : "#33aa33"

    color: bgColor

    ListModel {
        id: lModel
    }

    ListView {
        id: lView
        model: lModel
        width: parent.width
        height: parent.height - 70
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        clip: true

        addDisplaced: Transition {
            NumberAnimation {
                properties: "x,y";
                duration: 400;
                easing.type: Easing.OutQuad
            }
        }

        removeDisplaced: Transition {
            NumberAnimation {
                properties: "x,y";
                duration: 400;
                easing.type: Easing.OutQuad
            }
        }

        add: Transition {
            NumberAnimation {
                property: "opacity";
                from: 0;
                to: 1.0;
                duration: 400
            }
            NumberAnimation {
                property: "scale";
                from: 0.5;
                to: 1.0;
                duration: 400
            }
        }

        remove: Transition {
            NumberAnimation {
                property: "opacity";
                to: 0;
                duration: 400
            }
        }
        delegate: Task {

        }
    }

    Row {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 10
        spacing: 10

        RoundButton {
            width: 50
            height: 50
            text: mode ? "🌙" : "☀️"
            font.pixelSize: 25
            radius: 25
            background: Rectangle {
                radius: 25
                color: mode ? "#e0e0e0" : "#303030"
                border.width: 1
                border.color: mode ? "#c0c0c0" : "#505050"
            }
            onClicked: {
                root.mode = !root.mode
            }
        }

        PlusButton {
            radius: 30
            col: root.plusColor
            onClicked: {
                taskPopup.open()
            }
        }

        TrashButton {
            radius: 25
            col: root.trashColor
            onClicked: {
                if(lModel.count > 0) lModel.remove(lModel.count-1)
            }
        }
    }

    Popup {
        id: taskPopup
        width: 340
        height: 520
        modal: true
        focus: true
        anchors.centerIn: parent
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            id: popupBackground
            color: root.bgColor
            radius: 15
            border.width: 1
            border.color: mode ? "#d0d0d0" : "#404040"
        }

        Rectangle {
            id: headerRect
            width: parent.width
            height: 60
            color: mode ? "#f0f0f0" : "#252525"
            radius: 15

            Text {
                text: "Create a New Task"
                color: root.textColor
                font.pixelSize: 22
                font.weight: Font.Medium
                anchors.centerIn: parent
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            anchors.topMargin: 70
            spacing: 15

            // Task Name Input
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Text {
                    text: "Task Name"
                    color: root.textColor
                    font.pixelSize: 14
                    Layout.fillWidth: true
                }

                TextField {
                    id: taskName
                    Layout.fillWidth: true
                    implicitHeight: 36
                    placeholderText: "Enter task name (required)"
                    color: root.textColor
                    placeholderTextColor: root.phTextColor
                    onTextChanged: root.validateInput()
                    maximumLength: 40

                    background: Rectangle {
                        color: mode ? "#f5f5f5" : "#252525"
                        border.color: taskName.text.length === 0 ? inputBorderError :
                                     (taskName.text.length > 0 ? inputBorderValid : inputBorderNormal)
                        border.width: 1
                        radius: 6
                    }
                }

                Text {
                    id: taskNameError
                    text: taskName.text.length === 0 ? "Task name is required" :
                          taskName.text.length > 40 ? "Maximum 40 characters allowed" : ""
                    color: inputBorderError
                    font.pixelSize: 12
                    visible: text !== ""
                    Layout.fillWidth: true
                }
            }

            // Description Input
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Text {
                    text: "Description (optional)"
                    color: root.textColor
                    font.pixelSize: 14
                    Layout.fillWidth: true
                }

                TextField {
                    id: taskDescription
                    Layout.fillWidth: true
                    implicitHeight: 36
                    placeholderText: "Add details about your task"
                    color: root.textColor
                    placeholderTextColor: root.phTextColor
                    onTextChanged: root.validateInput()
                    maximumLength: 150

                    background: Rectangle {
                        color: mode ? "#f5f5f5" : "#252525"
                        border.color: inputBorderNormal
                        border.width: 1
                        radius: 6
                    }
                }

                Text {
                    id: charCounter
                    text: taskDescription.text.length + "/150"
                    color: root.textColor
                    opacity: 0.7
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignRight
                    Layout.alignment: Qt.AlignRight
                }
            }

            // Date Selection
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Text {
                    text: "Deadline"
                    color: root.textColor
                    font.pixelSize: 14
                    Layout.fillWidth: true
                }

                Rectangle {
                    id: dateTimePopupBtn
                    Layout.fillWidth: true
                    implicitHeight: 36
                    color: mode ? "#f5f5f5" : "#252525"
                    border.width: 1
                    border.color: dateTimeSelector.selectedDate === "" ? inputBorderError : inputBorderValid
                    radius: 6

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 8

                        Text {
                            Layout.fillWidth: true
                            color: dateTimeSelector.selectedDate === "" ? root.phTextColor : root.textColor
                            text: dateTimeSelector.selectedDate === "" ? "Select a deadline" : dateTimeSelector.selectedDate
                            font.pixelSize: 14
                        }

                        Text {
                            text: "📅"
                            font.pixelSize: 16
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            dateTimeSelector.open()
                            dateTimeSelector.updateTumblersFromDate()
                            dateTimeSelector.refreshAvailableOptions()
                        }
                    }
                }

                Text {
                    id: dateError
                    text: dateTimeSelector.selectedDate === "" ? "Deadline is required" : ""
                    color: inputBorderError
                    font.pixelSize: 12
                    visible: text !== ""
                    Layout.fillWidth: true
                }
            }

            // Priority Selection
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Text {
                    text: "Priority"
                    color: root.textColor
                    font.pixelSize: 14
                    Layout.fillWidth: true
                }

                ComboBox {
                    id: taskPriority
                    Layout.fillWidth: true
                    implicitHeight: 36
                    model: ["Low", "Medium", "High"]

                    background: Rectangle {
                        color: mode ? "#f5f5f5" : "#252525"
                        border.width: 1
                        border.color: inputBorderNormal
                        radius: 6
                    }

                    contentItem: Text {
                        leftPadding: 8
                        text: taskPriority.displayText
                        color: root.textColor
                        font.pixelSize: 14
                        verticalAlignment: Text.AlignVCenter
                    }

                    popup: Popup {
                        y: taskPriority.height
                        width: taskPriority.width
                        implicitHeight: contentItem.implicitHeight
                        padding: 1

                        contentItem: ListView {
                            clip: true
                            implicitHeight: contentHeight
                            model: taskPriority.popup.visible ? taskPriority.delegateModel : null

                            currentIndex: taskPriority.highlightedIndex

                            ScrollIndicator.vertical: ScrollIndicator { }
                        }

                        background: Rectangle {
                            color: root.bgColor
                            border.color: inputBorderNormal
                            radius: 6
                        }
                    }
                }
            }

            Item {
                Layout.fillHeight: true
            }

            // Action Buttons
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Button {
                    id: cancelButton
                    Layout.preferredWidth: 133
                    implicitHeight: 40
                    text: "Cancel"

                    background: Rectangle {
                        color: mode ? "#e0e0e0" : "#303030"
                        radius: 6

                        Rectangle {
                            anchors.fill: parent
                            radius: 6
                            color: cancelButton.pressed ? (mode ? "#c0c0c0" : "#404040") : "transparent"
                        }
                    }

                    contentItem: Text {
                        text: cancelButton.text
                        color: root.textColor
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        taskName.text = ""
                        taskDescription.text = ""
                        taskPriority.currentIndex = 0
                        dateTimeSelector.selectedDate = ""
                        taskPopup.close()
                    }
                }

                Button {
                    id: addButton
                    Layout.preferredWidth: 133
                    implicitHeight: 40
                    enabled: taskName.text.length > 0 && dateTimeSelector.selectedDate !== ""

                    background: Rectangle {
                        color: addButton.enabled ? (addButton.pressed ? root.greenBtnHover : root.greenBtn) : root.greenBtnDisabled
                        radius: 6
                    }

                    contentItem: Text {
                        text: "Add Task"
                        color: root.textColor
                        font.pixelSize: 14
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        lModel.append({
                            name: taskName.text,
                            deadline: dateTimeSelector.selectedDate,
                            description: taskDescription.text,
                            priority: taskPriority.currentText,
                            id: root.taskCounter++
                        });

                        taskName.text = ""
                        taskDescription.text = ""
                        taskPriority.currentIndex = 0
                        dateTimeSelector.selectedDate = ""

                        taskPopup.close();
                    }
                }
            }
        }
    }

    TimeDateSelector {
        id: dateTimeSelector
        modal: true
        focus: true
        anchors.centerIn: parent
    }

    function validateInput() {
        let isValidName = taskName.text.length > 0 && taskName.text.length <= 40
        let isValidDesc = taskDescription.text.length <= 150
        let isValidDate = dateTimeSelector.selectedDate !== ""

        addButton.enabled = isValidName && isValidDesc && isValidDate

        taskNameError.text = !isValidName ?
            (taskName.text.length === 0 ? "Task name is required" : "Maximum 40 characters allowed") : ""
        dateError.text = !isValidDate ? "Deadline is required" : ""
    }
}
