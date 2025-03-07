import QtQuick
import QtQuick.Layouts
import QtQuick.Controls 2.15


Popup {
    id: taskPopup
    width: 340
    height: 520

    signal updateTask(int id, string name, string description, string deadline, string priority)

    property alias taskName: taskName
    property alias taskDescription: taskDescription
    property alias taskNameError: taskNameError
    property alias dateError: dateError
    property alias addButton: addButton

    property string startName: ""
    property string startDesc: ""
    property string startPriority: ""
    property int currentId: -1
    property bool isEditing: false

    onOpened: {
        if (isEditing) {
            taskName.text = startName
            taskDescription.text = startDesc
            taskPriority.currentIndex = startPriority === "Low" ? 0 :
                                       startPriority === "Medium" ? 1 : 2
        } else {
            taskName.text = ""
            taskDescription.text = ""
            taskPriority.currentIndex = 0
        }
    }

    onClosed: {
        isEditing = false
    }

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
                placeholderText: isEditing ? "" : "Enter task name (required)"
                color: root.textColor
                placeholderTextColor: root.phTextColor
                onTextChanged: root.validateInput()
                maximumLength: 30

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
                      taskName.text.length > 30 ? "Maximum 30 characters allowed" : ""
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
                placeholderText: isEditing ? "" : "Add details about your task"
                color: root.textColor
                placeholderTextColor: root.phTextColor
                onTextChanged: root.validateInput()
                maximumLength: 100

                background: Rectangle {
                    color: mode ? "#f5f5f5" : "#252525"
                    border.color: inputBorderNormal
                    border.width: 1
                    radius: 6
                }
            }

            Text {
                id: charCounter
                text: taskDescription.text.length + "/100"
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
                currentIndex: taskPopup.startPriority === "Low" || !taskPopup.isEditing ? 0 : taskPopup.startPriority === "Medium" ? 1 : 2
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
                    text: isEditing ? "Update" : "Add Task"
                    color: root.textColor
                    font.pixelSize: 14
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    if(!isEditing){
                        lModel.append({
                            name: taskName.text,
                            description: taskDescription.text,
                            deadline: dateTimeSelector.selectedDate,
                            priority: taskPriority.currentText,
                            id: root.taskCounter++             
                        });
                        taskManager.insertToTable(root.taskCounter, taskName.text, taskDescription.text, dateTimeSelector.selectedDate, taskPriority.currentText)

                        taskName.text = ""
                        taskDescription.text = ""
                        taskPriority.currentIndex = 0
                        dateTimeSelector.selectedDate = ""
                    }
                    else{
                        for(let i = 0; i < lModel.count; ++i){
                            if(lModel.get(i).id === taskPopup.currentId){
                                lModel.get(i).name = taskName.text
                                lModel.get(i).description = taskDescription.text
                                lModel.get(i).deadline = dateTimeSelector.selectedDate
                                lModel.get(i).priority = taskPriority.currentText
                                taskManager.updateTaskDB(taskPopup.currentId, taskName.text, taskDescription.text, dateTimeSelector.selectedDate, taskPriority.currentText);
                                break;
                            }
                        }
                    }
                    taskPopup.close();
                    root.sortTasks();
                }
            }
        }
    }
}
