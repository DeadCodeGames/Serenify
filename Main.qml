import QtQuick
import QtQuick.Controls.Basic 2.15
import QtQuick.Layouts

Window {
    width: 400
    height: 600
    minimumWidth: 400
    minimumHeight: 600
    visible: true
    title: qsTr("Serenify")
    id: root

    property bool mode: true // False = dark mode, True = light mode
    property color trashColor: mode ? "red" : "#850900"
    property color plusColor: mode ? "blue" : "#03076b"
    property color taskBorderColor: mode ? "#ff9991" : "red"
    property color taskBgColor: mode ? "white" : "#171716"
    property color textColor: mode ? "black" : "white"

    color: mode ? "white" : "#171716"

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
        delegate: Task {

        }
    }

    PlusButton {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 10
        radius: 30
        col: root.plusColor
        onClicked: {
            taskPopup.open()
        }
    }

    TrashButton {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.bottomMargin: 10
        anchors.rightMargin: 10
        radius: 50
        col: root.trashColor
        onClicked: {
            if(lModel.count > 0) lModel.remove(lModel.count-1)
        }
    }

    RoundButton {
        width: 50
        height: 50
        text: "Mode"
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.bottomMargin: 10
        anchors.leftMargin: 10
        radius: 50
        onClicked: {
            root.mode = !root.mode
        }
    }

    Popup {
        id: taskPopup
        width: 320
        height: 300
        modal: true
        focus: true
        anchors.centerIn: parent
        background: Rectangle {
            color: root.taskBgColor
            radius: 10
            border.color: root.taskBorderColor
        }

        Column {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 10

            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                TextField {
                    id: taskName
                    placeholderText: "Task Name (Max 40 chars)"
                    onTextChanged: root.validateInput()
                    maximumLength: 40
                    clip: true
                    width: 200
                    background: Rectangle {
                        color: "transparent"
                        border.color: taskName.text.length === 0 ? "red" : "green"
                        border.width: 1
                        radius: 5
                    }
                }
                Text {
                    text: taskName.text.length > 40 ? "Task name too long!" : (taskName.text.length === 0 ? "Task name required!" : "")
                    color: "red"
                    font.pixelSize: 10
                    visible: taskName.text.length === 0 || taskName.text.length > 40
                }
            }

            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                TextField {
                    id: taskDeadline
                    color: root.textColor
                    placeholderText: "Deadline (YYYY-MM-DD)"
                    onTextChanged: root.validateInput()
                    maximumLength: 100
                    clip: true
                    width: 200
                    background: Rectangle {
                        color: "transparent"
                        border.color: taskDeadline.text.length === 0 ? "red" : "green"
                        border.width: 1
                        radius: 5
                    }
                }
                Text {
                    text: taskDeadline.text.length === 0 ? "Deadline required!" : ""
                    color: "red"
                    font.pixelSize: 10
                    visible: taskDeadline.text.length === 0
                }
            }

            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                TextField {
                    id: taskDescription
                    color: root.textColor
                    placeholderText: "Description (optional)"
                    onTextChanged: root.validateInput()
                    maximumLength: 100
                    clip: true
                    width: 200
                    background: Rectangle {
                        color: "transparent"
                        border.color: taskDescription.text.length > 0 ? "green" : "black"
                        border.width: 1
                        radius: 5
                    }
                }
                Text {
                    text: taskDeadline.text.length >= 100 ? "Description too long!" : ""
                    color: "red"
                    font.pixelSize: 10
                    visible: taskDeadline.text.length === 0
                }
            }

            ComboBox {
                anchors.horizontalCenter: parent.horizontalCenter
                id: taskPriority
                model: ["Low", "Medium", "High"]
                width: 100
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                id: addButton
                text: "Add Task"
                enabled: false
                width: 100
                onClicked: {
                    lModel.append({
                        name: taskName.text,
                        deadline: taskDeadline.text,
                        description: taskDescription.text,
                        priority: taskPriority.currentText
                    });

                    taskName.text = ""
                    taskDeadline.text = ""
                    taskDescription.text = ""
                    taskPriority.currentIndex = 0
                    addButton.enabled = false

                    taskPopup.close();
                }
            }
        }
    }

    function validateInput() {
        let isValid = taskName.text.length > 0 && taskName.text.length <= 40 && taskDeadline.text.length > 0 && taskDescription.text.length <= 100
        addButton.enabled = isValid
    }
}
