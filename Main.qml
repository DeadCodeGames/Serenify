import QtQuick
import QtQuick.Controls.Basic 2.15

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
                TextField {
                    id: taskName
                    placeholderText: "Task Name (Max 40 chars)"
                    onTextChanged: root.validateInput()
                    background: Rectangle {
                        color: "transparent"
                        border.color: taskName.text.length === 0 || taskName.text.length > 40 ? "red" : "green"
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
                TextField {
                    id: taskDeadline
                    color: root.textColor
                    placeholderText: "Deadline (YYYY-MM-DD)"
                    onTextChanged: root.validateInput()
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

            TextField {
                id: taskDescription
                placeholderText: "Description (Optional)"
                color: root.textColor
            }

            ComboBox {
                id: taskPriority
                model: ["Low", "Medium", "High"]
            }

            Button {
                id: addButton
                text: "Add Task"
                enabled: false
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
        let isValid = taskName.text.length > 0 && taskName.text.length <= 40 && taskDeadline.text.length > 0
        addButton.enabled = isValid
    }
}
