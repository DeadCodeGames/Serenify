import QtQuick 2.15
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
    property bool isDeleting: false

    // Colors here
    property bool mode: true // False = dark mode, True = light mode
    property color trashColor: mode ? "red" : "#850900"
    property color trashDeletingColor: mode ? "#ff6a00" : "#ab4700"
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
    property color taskFinished: mode ? "#37cc12": "#219404"

    color: bgColor

    Timer {
        id: isTaskDue
        interval: 60000
        repeat: true
        running: true
        onTriggered: {
            currentDate = new Date();
            stringDate = formatDateTime();
            console.log(currentDate)
            // Finish when sorting functions are created
        }
    }

    function formatDateTime() {
        let day = String(currentDate.getDate()).padStart(2, '0');
        let month = String(currentDate.getMonth() + 1).padStart(2, '0');
        let year = String(currentDate.getFullYear());
        let hours = String(currentDate.getHours()).padStart(2, '0');
        let minutes = String(currentDate.getMinutes()).padStart(2, '0');

        return day + "-" + month + "-" + year + " " + hours + ":" + minutes;
    }

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

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                }
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
            col: root.isDeleting ? root.trashDeletingColor : root.trashColor
            onClicked: {
                root.isDeleting = !root.isDeleting
            }
        }

    }

    TaskCreator {
        id: taskPopup
        modal: true
        focus: true
        anchors.centerIn: parent
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    }


    TimeDateSelector {
        id: dateTimeSelector
        modal: true
        focus: true
        anchors.centerIn: parent
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    }

    function validateInput() {
        let isValidName = taskPopup.taskName.text.length > 0 && taskPopup.taskName.text.length <= 30
        let isValidDesc = taskPopup.taskDescription.text.length <= 500
        let isValidDate = dateTimeSelector.selectedDate !== ""

        taskPopup.addButton.enabled = isValidName && isValidDesc && isValidDate

        taskPopup.taskNameError.text = !isValidName ?
            (taskPopup.taskName.text.length === 0 ? "Task name is required" : "Maximum 30 characters allowed") : ""
        taskPopup.dateError.text = !isValidDate ? "Deadline is required" : ""
    }

    function sortTasks() {
        if(lModel.count<2) return;
        let tasks = [];
        for (let i = 0; i < lModel.count; i++) {
            let task = lModel.get(i);
            tasks.push({
                priority: task.priority,
                deadline: task.deadline,
                name: task.name,
                description: task.description,
                id: task.id,
                finished: task.finished
            });
        }

        const priorityValue = {
            "High": 0,
            "Medium": 1,
            "Low": 2
        };

        tasks.sort(function(a, b) {
            const finishDiff = a.finished - b.finished;
            if(finishDiff !== 0) return finishDiff;
            const priorityDiff = priorityValue[a.priority] - priorityValue[b.priority];
            if (priorityDiff !== 0) return priorityDiff;
            const dateA = parseDeadline(a.deadline);
            const dateB = parseDeadline(b.deadline);
            return dateA - dateB;
        });
        lModel.clear();
        for (let j = 0; j < tasks.length; j++) {
            lModel.append({
                priority: tasks[j].priority,
                deadline: tasks[j].deadline,
                name: tasks[j].name,
                description: tasks[j].description,
                id: tasks[j].id,
                finished: tasks[j].finished
            });
        }
    }

    function parseDeadline(deadlineStr) {
        const parts = deadlineStr.split(" ");
        const dateParts = parts[0].split("-");
        const timeParts = parts[1].split(":");

        const day = parseInt(dateParts[0], 10);
        const month = parseInt(dateParts[1], 10) - 1;
        const year = parseInt(dateParts[2], 10);
        const hours = parseInt(timeParts[0], 10);
        const minutes = parseInt(timeParts[1], 10);

        return new Date(year, month, day, hours, minutes);
    }

    function appendTaskToModel(id, taskName, taskDeadline, taskDescription, taskImportance, finished) {
        console.log("Appending task to model:", id, taskName, taskDeadline, taskDescription, taskImportance, finished);
        if(id >= root.taskCounter) root.taskCounter = id+1
        lModel.append({
            name: taskName,
            description: taskDescription,
            deadline: taskDeadline,
            priority: taskImportance,
            id: id,
            finished: finished
        });
        sortTasks();
    }

    Component.onCompleted: {
        console.log("Component completed, delaying database load...");
        loadTimer.start();
    }

    Connections {
        target: taskManager
        function onTaskLoaded(id, taskName, taskDeadline, taskDescription, taskImportance, finished) {
            console.log("Task loaded signal received:", id, taskName);

            // Ensure the model exists
            if (lModel) {
                appendTaskToModel(id, taskName, taskDescription, taskDeadline, taskImportance, finished);
            } else {
                console.error("ListModel not available when trying to append task");
            }
        }
    }

    Timer {
        id: loadTimer
        interval: 100 // Short delay to ensure everything is initialized
        repeat: false
        running: false
        onTriggered: {
            console.log("Loading from database...");
            taskManager.loadTasksDB();
        }
    }
}
