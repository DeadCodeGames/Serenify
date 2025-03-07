import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Popup {
    id: dateTimePicker
    width: 300
    height: 400

    // Set minimum date to current time
    property date minimumDate: new Date()
    property date userSelectedDate: new Date(minimumDate.getTime() + 60000) // Current time + 1 minute
    property string selectedDate: ""
    property int updateInterval: 10000 // Update every 10 seconds
    property bool ignoreChanges: false // Flag to prevent circular update triggers

    // Month names array
    property var monthNames: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

    // Timer to periodically update the minimum date
    Timer {
        id: timeUpdateTimer
        interval: updateInterval
        running: dateTimePicker.visible
        repeat: true
        onTriggered: {
            let oldMinimumDate = minimumDate;
            minimumDate = new Date(); // Update to current time

            // Only update tumblers if userSelectedDate is now invalid
            if (userSelectedDate < minimumDate) {
                // Set userSelectedDate to minimum valid time (now + 1 minute)
                userSelectedDate = new Date(minimumDate.getTime() + 60000);
                updateTumblersFromDate();
            } else {
                // Just refresh available options without changing selection
                refreshAvailableOptions();
            }
        }
    }

    function isLeapYear(year) {
        return (year % 4 === 0 && year % 100 !== 0) || (year % 400 === 0);
    }

    // Get days in month (handles leap years)
    function getDaysInMonth(year, month) {
        return [31, isLeapYear(year) ? 29 : 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][month];
    }

    // Update all tumbler models based on current minimum date
    function refreshAvailableOptions() {
        ignoreChanges = true;

        // Update year model
        let currentYearIndex = yearTumbler.currentIndex;
        let selectedYear = getSelectedYear();
        updateYearModel();
        yearTumbler.currentIndex = yearTumbler.model.indexOf(selectedYear);

        // Update month model
        let currentMonthIndex = monthTumbler.currentIndex;
        let selectedMonth = userSelectedDate.getMonth();
        updateMonthModel();
        setMonthTumblerFromDate();

        // Update day model
        let selectedDay = userSelectedDate.getDate();
        updateDayModel();
        setDayTumblerFromDate();

        // Update hour model
        let selectedHour = userSelectedDate.getHours();
        updateHourModel();
        setHourTumblerFromDate();

        // Update minute model
        let selectedMinute = userSelectedDate.getMinutes();
        updateMinuteModel();
        setMinuteTumblerFromDate();

        ignoreChanges = false;
    }

    // Update tumbler positions based on userSelectedDate
    function updateTumblersFromDate() {
        ignoreChanges = true;

        // Make sure models are up to date
        updateYearModel();
        updateMonthModel();
        updateDayModel();
        updateHourModel();
        updateMinuteModel();

        // Set tumbler positions
        setYearTumblerFromDate();
        setMonthTumblerFromDate();
        setDayTumblerFromDate();
        setHourTumblerFromDate();
        setMinuteTumblerFromDate();

        ignoreChanges = false;
    }

    // Helper functions to set individual tumblers
    function setYearTumblerFromDate() {
        let year = userSelectedDate.getFullYear();
        let index = yearTumbler.model.indexOf(year);
        if (index >= 0) {
            yearTumbler.currentIndex = index;
        } else {
            // If year not found (should not happen), use first available
            yearTumbler.currentIndex = 0;
            // Update userSelectedDate year
            userSelectedDate.setFullYear(yearTumbler.model[0]);
        }
    }

    function setMonthTumblerFromDate() {
        let month = userSelectedDate.getMonth();
        let year = userSelectedDate.getFullYear();
        let minYear = minimumDate.getFullYear();
        let minMonth = minimumDate.getMonth();

        if (year === minYear) {
            // Current year - month index is offset by minimum month
            let relativeMonthIndex = month - minMonth;
            if (relativeMonthIndex >= 0 && relativeMonthIndex < monthTumbler.model.length) {
                monthTumbler.currentIndex = relativeMonthIndex;
            } else {
                // If month is before minimum month, set to first available
                monthTumbler.currentIndex = 0;
                // Update userSelectedDate month
                userSelectedDate.setMonth(minMonth);
            }
        } else {
            // Future year - can select any month
            if (month < monthTumbler.model.length) {
                monthTumbler.currentIndex = month;
            } else {
                monthTumbler.currentIndex = 0;
                userSelectedDate.setMonth(0);
            }
        }
    }

    function setDayTumblerFromDate() {
        let day = userSelectedDate.getDate();
        let year = userSelectedDate.getFullYear();
        let month = userSelectedDate.getMonth();
        let minYear = minimumDate.getFullYear();
        let minMonth = minimumDate.getMonth();
        let minDay = minimumDate.getDate();

        if (year === minYear && month === minMonth) {
            // Current month - day index is offset by minimum day
            let relativeDayIndex = day - minDay;
            if (relativeDayIndex >= 0 && relativeDayIndex < dayTumbler.model.length) {
                dayTumbler.currentIndex = relativeDayIndex;
            } else {
                // If day is before minimum day, set to first available
                dayTumbler.currentIndex = 0;
                // Update userSelectedDate day
                userSelectedDate.setDate(minDay);
            }
        } else {
            // Future month - can select any day
            let maxDays = getDaysInMonth(year, month);
            let adjustedDay = Math.min(day, maxDays);
            let dayIndex = dayTumbler.model.indexOf(adjustedDay);
            if (dayIndex >= 0) {
                dayTumbler.currentIndex = dayIndex;
            } else {
                dayTumbler.currentIndex = 0;
                userSelectedDate.setDate(1);
            }
        }
    }

    function setHourTumblerFromDate() {
        let hour = userSelectedDate.getHours();
        let year = userSelectedDate.getFullYear();
        let month = userSelectedDate.getMonth();
        let day = userSelectedDate.getDate();
        let minYear = minimumDate.getFullYear();
        let minMonth = minimumDate.getMonth();
        let minDay = minimumDate.getDate();
        let minHour = minimumDate.getHours();

        if (year === minYear && month === minMonth && day === minDay) {
            // Current day - hour index is offset by minimum hour
            let relativeHourIndex = hour - minHour;
            if (relativeHourIndex >= 0 && relativeHourIndex < hourTumbler.model.length) {
                hourTumbler.currentIndex = relativeHourIndex;
            } else {
                // If hour is before minimum hour, set to first available
                hourTumbler.currentIndex = 0;
                // Update userSelectedDate hour
                userSelectedDate.setHours(minHour);
            }
        } else {
            // Future day - can select any hour
            let hourIndex = hourTumbler.model.indexOf(hour);
            if (hourIndex >= 0) {
                hourTumbler.currentIndex = hourIndex;
            } else {
                hourTumbler.currentIndex = 0;
                userSelectedDate.setHours(0);
            }
        }
    }

    function setMinuteTumblerFromDate() {
        let minute = userSelectedDate.getMinutes();
        let year = userSelectedDate.getFullYear();
        let month = userSelectedDate.getMonth();
        let day = userSelectedDate.getDate();
        let hour = userSelectedDate.getHours();
        let minYear = minimumDate.getFullYear();
        let minMonth = minimumDate.getMonth();
        let minDay = minimumDate.getDate();
        let minHour = minimumDate.getHours();
        let minMinute = minimumDate.getMinutes() + 1; // Add 1 to disallow current minute

        if (year === minYear && month === minMonth && day === minDay && hour === minHour) {
            // Current hour - minute index is offset by minimum minute + 1
            let relativeMinuteIndex = minute - minMinute;
            if (relativeMinuteIndex >= 0 && relativeMinuteIndex < minuteTumbler.model.length) {
                minuteTumbler.currentIndex = relativeMinuteIndex;
            } else {
                // If minute is before minimum minute, set to first available
                minuteTumbler.currentIndex = 0;
                // Update userSelectedDate minute
                userSelectedDate.setMinutes(minMinute);
            }
        } else {
            // Future hour - can select any minute
            let minuteIndex = minuteTumbler.model.indexOf(minute);
            if (minuteIndex >= 0) {
                minuteTumbler.currentIndex = minuteIndex;
            } else {
                minuteTumbler.currentIndex = 0;
                userSelectedDate.setMinutes(0);
            }
        }
    }

    // Update models
    function updateYearModel() {
        let minYear = minimumDate.getFullYear();
        yearTumbler.model = Array.from({ length: 100 }, (_, i) => minYear + i);
    }

    function updateMonthModel() {
        let minYear = minimumDate.getFullYear();
        let minMonth = minimumDate.getMonth();
        let selectedYear = getSelectedYear();

        if (selectedYear === minYear) {
            // Only current and future months for current year
            let availableMonths = [];
            for (let i = minMonth; i < 12; i++) {
                availableMonths.push(monthNames[i]);
            }
            monthTumbler.model = availableMonths;
        } else {
            // All months for future years
            monthTumbler.model = monthNames;
        }
    }

    function updateDayModel() {
        let minYear = minimumDate.getFullYear();
        let minMonth = minimumDate.getMonth();
        let minDay = minimumDate.getDate();

        let selectedYear = getSelectedYear();
        let selectedMonth = getSelectedMonth();

        // Get total days in the selected month
        let maxDays = getDaysInMonth(selectedYear, selectedMonth);

        // For current year and month, only show days from today onwards
        if (selectedYear === minYear && selectedMonth === minMonth) {
            let availableDays = [];
            for (let i = minDay; i <= maxDays; i++) {
                availableDays.push(i);
            }
            dayTumbler.model = availableDays;
        } else {
            // All days for future months
            dayTumbler.model = Array.from({ length: maxDays }, (_, i) => i + 1);
        }
    }

    function updateHourModel() {
        let minYear = minimumDate.getFullYear();
        let minMonth = minimumDate.getMonth();
        let minDay = minimumDate.getDate();
        let minHour = minimumDate.getHours();

        let selectedYear = getSelectedYear();
        let selectedMonth = getSelectedMonth();
        let selectedDay = getSelectedDay();

        // For current day, only show hours from current hour onwards
        if (selectedYear === minYear && selectedMonth === minMonth && selectedDay === minDay) {
            let availableHours = [];
            for (let i = minHour; i < 24; i++) {
                availableHours.push(i);
            }
            hourTumbler.model = availableHours;
        } else {
            // All hours for future days
            hourTumbler.model = Array.from({ length: 24 }, (_, i) => i);
        }
    }

    function updateMinuteModel() {
        let minYear = minimumDate.getFullYear();
        let minMonth = minimumDate.getMonth();
        let minDay = minimumDate.getDate();
        let minHour = minimumDate.getHours();
        let minMinute = minimumDate.getMinutes() + 1; // Add 1 to disallow current minute

        let selectedYear = getSelectedYear();
        let selectedMonth = getSelectedMonth();
        let selectedDay = getSelectedDay();
        let selectedHour = getSelectedHour();

        // For current hour of current day, only show minutes from next minute onwards
        if (selectedYear === minYear && selectedMonth === minMonth &&
            selectedDay === minDay && selectedHour === minHour) {
            let availableMinutes = [];
            for (let i = minMinute; i < 60; i++) {
                availableMinutes.push(i);
            }
            minuteTumbler.model = availableMinutes;
        } else {
            // All minutes for future hours
            minuteTumbler.model = Array.from({ length: 60 }, (_, i) => i);
        }
    }

    // Helper functions to get values from tumblers
    function getSelectedYear() {
        if (yearTumbler.model.length > 0 && yearTumbler.currentIndex >= 0) {
            return yearTumbler.model[yearTumbler.currentIndex];
        }
        return minimumDate.getFullYear();
    }

    function getSelectedMonth() {
        let minYear = minimumDate.getFullYear();
        let minMonth = minimumDate.getMonth();
        let selectedYear = getSelectedYear();

        if (selectedYear === minYear) {
            // In current year, the index is offset by minMonth
            return minMonth + monthTumbler.currentIndex;
        } else {
            return monthTumbler.currentIndex;
        }
    }

    function getSelectedDay() {
        if (dayTumbler.model.length > 0 && dayTumbler.currentIndex >= 0) {
            return dayTumbler.model[dayTumbler.currentIndex];
        }
        return 1;
    }

    function getSelectedHour() {
        if (hourTumbler.model.length > 0 && hourTumbler.currentIndex >= 0) {
            return hourTumbler.model[hourTumbler.currentIndex];
        }
        return 0;
    }

    function getSelectedMinute() {
        if (minuteTumbler.model.length > 0 && minuteTumbler.currentIndex >= 0) {
            return minuteTumbler.model[minuteTumbler.currentIndex];
        }
        return 0;
    }

    // Update userSelectedDate from tumbler values
    function updateDateFromTumblers() {
        if (ignoreChanges) return;

        let year = getSelectedYear();
        let month = getSelectedMonth();
        let day = getSelectedDay();
        let hour = getSelectedHour();
        let minute = getSelectedMinute();

        // Create new date object with selected values
        let newDate = new Date(year, month, day, hour, minute);

        // Ensure the new date is valid (not before minimum)
        if (newDate >= minimumDate) {
            userSelectedDate = newDate;
        } else {
            // If invalid, reset to minimum + 1 minute
            userSelectedDate = new Date(minimumDate.getTime() + 60000);
            // Update tumblers to match
            updateTumblersFromDate();
        }
    }

    function formatDateTime() {
        let day = String(userSelectedDate.getDate()).padStart(2, '0');
        let month = String(userSelectedDate.getMonth() + 1).padStart(2, '0');
        let year = String(userSelectedDate.getFullYear());
        let hours = String(userSelectedDate.getHours()).padStart(2, '0');
        let minutes = String(userSelectedDate.getMinutes()).padStart(2, '0');

        return day + "-" + month + "-" + year + " " + hours + ":" + minutes;
    }

    background: Rectangle {
        radius: 10
        color: root.bgColor
    }

    ColumnLayout {
        spacing: 20
        anchors.centerIn: parent

        Text {
            text: "Pick a deadline date"
            color: root.textColor
            font.pixelSize: 24
            Layout.alignment: Qt.AlignHCenter
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 30

            RowLayout {
                Layout.alignment: Qt.AlignHCenter

                Tumbler {
                    id: yearTumbler
                    model: []
                    palette.text: root.textColor
                    onCurrentIndexChanged: {
                        if (!ignoreChanges) {
                            updateMonthModel();
                            updateDayModel();
                            updateHourModel();
                            updateMinuteModel();
                            updateDateFromTumblers();
                        }
                    }
                    Layout.preferredHeight: 100
                }

                Tumbler {
                    id: monthTumbler
                    model: []
                    palette.text: root.textColor
                    onCurrentIndexChanged: {
                        if (!ignoreChanges) {
                            updateDayModel();
                            updateHourModel();
                            updateMinuteModel();
                            updateDateFromTumblers();
                        }
                    }
                    Layout.preferredHeight: 100
                }

                Tumbler {
                    id: dayTumbler
                    model: []
                    palette.text: root.textColor
                    onCurrentIndexChanged: {
                        if (!ignoreChanges) {
                            updateHourModel();
                            updateMinuteModel();
                            updateDateFromTumblers();
                        }
                    }
                    Layout.preferredHeight: 100
                }
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter

                Tumbler {
                    id: hourTumbler
                    model: []
                    palette.text: root.textColor
                    onCurrentIndexChanged: {
                        if (!ignoreChanges) {
                            updateMinuteModel();
                            updateDateFromTumblers();
                        }
                    }
                    Layout.preferredHeight: 100
                }

                Tumbler {
                    id: minuteTumbler
                    model: []
                    palette.text: root.textColor
                    onCurrentIndexChanged: {
                        if (!ignoreChanges) {
                            updateDateFromTumblers();
                        }
                    }
                    Layout.preferredHeight: 100
                }
            }

            RowLayout {
                spacing: 10
                Button {
                    id: cancelBtn
                    Layout.preferredWidth: 133
                    implicitHeight: 40
                    background: Rectangle {
                        color: mode ? "#e0e0e0" : "#303030"
                        radius: 6
                        Text {
                            anchors.centerIn: parent
                            text: "Cancel"
                            color: root.textColor
                        }

                        Rectangle {
                            anchors.fill: parent
                            radius: 6
                            color: cancelBtn.pressed ? (mode ? "#c0c0c0" : "#404040") : "transparent"
                        }
                    }
                    onClicked: dateTimePicker.close()
                }
                Button {
                    id: okBtn
                    Layout.preferredWidth: 133
                    implicitHeight: 40
                    background: Rectangle {
                        color: mode ? "#e0e0e0" : "#303030"
                        radius: 6
                        Text {
                            anchors.centerIn: parent
                            text: "Ok"
                            color: root.textColor
                        }
                        Rectangle {
                            anchors.fill: parent
                            radius: 6
                            color: okBtn.pressed ? (mode ? "#c0c0c0" : "#404040") : "transparent"
                        }
                    }
                    onClicked: {
                        dateTimePicker.selectedDate = dateTimePicker.formatDateTime();
                        dateTimePicker.close();
                        root.validateInput();
                    }
                }
            }
        }
    }

    // When the popup opens, initialize everything
    onVisibleChanged: {
        if (visible) {
            minimumDate = new Date(); // Set to current time
            userSelectedDate = new Date(minimumDate.getTime() + 60000); // Current time + 1 minute
            updateTumblersFromDate();
            timeUpdateTimer.restart(); // Start the update timer
        } else {
            timeUpdateTimer.stop(); // Stop the timer when popup is closed
        }
    }

    Component.onCompleted: {
        updateTumblersFromDate();
    }
}
