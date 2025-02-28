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
        property color borderColor: mode ? "#ff9991" : "red"
        property color bgColor: mode ? "white" : "#171716" // Change to be the main bg color
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
        Row{
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: 10
            spacing: 10

            RoundButton {
                width: 50
                height: 50
                text: "Mode"
                radius: 50
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
                radius: 50
                col: root.trashColor
                onClicked: {
                    if(lModel.count > 0) lModel.remove(lModel.count-1)
                }
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
                color: root.bgColor
                radius: 10
            }

            Text {
                text: "Create a task"
                color: root.textColor
                font.pixelSize: 24
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottomMargin: 10
            }

            Column {
                anchors.fill: parent
                anchors.margins: 20
                anchors.topMargin: 50
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
                }

                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    Rectangle {
                        id: dateTimePopupBtn
                        color: root.bgColor
                        width: 100
                        height: taskName.height
                        Text {
                            text: dateTimeSelector.selectedDate != "" ? dateTimeSelector.selectedDate : "No date selected."
                        }

                        MouseArea{
                            anchors.fill: parent
                            onClicked: {
                                dateTimeSelector.open()
                                dateTimeSelector.updateTumblersFromDate()
                                dateTimeSelector.refreshAvailableOptions()
                            }
                        }
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
                            deadline: dateTimeSelector.selectedDate,
                            description: taskDescription.text,
                            priority: taskPriority.currentText,
                            id: lModel.count
                        });

                        taskName.text = ""
                        taskDescription.text = ""
                        taskPriority.currentIndex = 0
                        addButton.enabled = false
                        dateTimeSelector.selectedDate = ""

                        taskPopup.close();
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
            let isValid = taskName.text.length > 0 && taskName.text.length <= 40 && taskDescription.text.length <= 100 && dateTimeSelector.selectedDate != ""
            addButton.enabled = isValid
        }
    }
