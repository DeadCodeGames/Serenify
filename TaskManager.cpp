#include <iostream>
#include <sqlite3.h>
#include <ctime>
#include <TaskManager.h>
#include <QVariantMap>
#include <QDebug>

using namespace std;

TaskManager::TaskManager(QObject *parent) : QObject(parent) {}

TaskManager::~TaskManager(){}

void TaskManager::loadTasksDB() {
    sqlite3* db;
    sqlite3_stmt* stmt;

    if (sqlite3_open("tasks.db", &db) != SQLITE_OK) {
        qDebug() << "Error opening database: " << sqlite3_errmsg(db);
        return;
    }

    const char* sql = "SELECT id, taskName, taskDescription, taskDeadline, taskImportance, taskStateFinished FROM tasks;";
    if (sqlite3_prepare_v2(db, sql, -1, &stmt, nullptr) != SQLITE_OK) {
        qDebug() << "Error preparing statement: " << sqlite3_errmsg(db);
        sqlite3_close(db);
        return;
    }

    bool hasTasks = false; // Track if tasks exist
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        hasTasks = true;

        int id = sqlite3_column_int(stmt, 0);
        QString taskName = QString::fromUtf8(reinterpret_cast<const char*>(sqlite3_column_text(stmt, 1)));
        QString taskDescription = QString::fromUtf8(reinterpret_cast<const char*>(sqlite3_column_text(stmt, 2)));
        QString taskDeadline = QString::fromUtf8(reinterpret_cast<const char*>(sqlite3_column_text(stmt, 3)));
        QString taskImportance = QString::fromUtf8(reinterpret_cast<const char*>(sqlite3_column_text(stmt, 4)));
        int taskStateFinished = sqlite3_column_int(stmt, 5);

        qDebug() << "data is: " << id << taskName << taskDescription << taskDeadline << taskImportance << taskStateFinished;
        emit taskLoaded(id, taskName, taskDescription, taskDeadline, taskImportance, taskStateFinished);
    }

    sqlite3_finalize(stmt);
    sqlite3_close(db);

    if (!hasTasks) {
        qDebug() << "No tasks were loaded!";
    }
}

bool TaskManager::removeTaskDB(int id)
{
    sqlite3* db;
    sqlite3_stmt* stmt;

    // Open the database
    if (sqlite3_open("tasks.db", &db) != SQLITE_OK) {
        qDebug() << "Error opening database: " << sqlite3_errmsg(db);
        return false;
    }

    // Prepare the SQL DELETE statement
    const char* sql = "DELETE FROM tasks WHERE id = ?;";

    // Prepare the statement for execution
    if (sqlite3_prepare_v2(db, sql, -1, &stmt, nullptr) != SQLITE_OK) {
        qDebug() << "Error preparing statement: " << sqlite3_errmsg(db);
        sqlite3_close(db);
        return false;
    }

    // Bind the dateCreated value to the SQL query
    sqlite3_bind_int(stmt, 1, id);

    // Execute the DELETE statement
    int result = sqlite3_step(stmt);

    if (result != SQLITE_DONE) {
        qDebug() << "Error executing delete: " << sqlite3_errmsg(db);
        sqlite3_finalize(stmt);
        sqlite3_close(db);
        return false;
    }

    qDebug() << "Task successfully deleted with id:" << to_string(id);

    // Finalize the statement and close the database
    sqlite3_finalize(stmt);
    sqlite3_close(db);

    int rowsAffected = sqlite3_changes(db);
    if (rowsAffected == 0) {
        qDebug() << "No tasks were deleted. Task ID may not exist:" << id;
    } else {
        qDebug() << rowsAffected << "task(s) successfully deleted with id:" << id;
    }

    return true;
}

void TaskManager::cleanupBeforeExit() {
    qDebug() << "Application is closing. Performing cleanup...";

    // Example: Log to console or save data before exit
    sqlite3* db;
    if (sqlite3_open("tasks.db", &db) == SQLITE_OK) {
        const char* sql = "UPDATE tasks SET taskImportance = 0 WHERE taskImportance IS NULL;";
        char* errorMessage = nullptr;

        if (sqlite3_exec(db, sql, nullptr, 0, &errorMessage) != SQLITE_OK) {
            qDebug() << "Error updating database on exit:" << errorMessage;
            sqlite3_free(errorMessage);
        } else {
            qDebug() << "Database updated successfully before exit.";
        }

        sqlite3_close(db);
    } else {
        qDebug() << "Failed to open database on exit.";
    }
}

bool TaskManager::updateTaskDB(int id, const QString &name, const QString &description, const QString &deadline, const QString &priority, int taskStateFinished) {
    sqlite3* db;
    sqlite3_stmt* stmt;

    if (sqlite3_open("tasks.db", &db) != SQLITE_OK) {
        qDebug() << "Error opening database: " << sqlite3_errmsg(db);
        return false;
    }

    const char* sql = "UPDATE tasks SET taskName = ?, taskDescription = ?, taskDeadline = ?, taskImportance = ?, taskStateFinished = ? WHERE id = ?;";
    if (sqlite3_prepare_v2(db, sql, -1, &stmt, nullptr) != SQLITE_OK) {
        qDebug() << "Error preparing update statement: " << sqlite3_errmsg(db);
        sqlite3_close(db);
        return false;
    }

    sqlite3_bind_text(stmt, 1, name.toUtf8().constData(), -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(stmt, 2, description.toUtf8().constData(), -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(stmt, 3, deadline.toUtf8().constData(), -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(stmt, 4, priority.toUtf8().constData(), -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(stmt, 5, taskStateFinished);
    sqlite3_bind_int(stmt, 6, id);

    int result = sqlite3_step(stmt);

    if (result != SQLITE_DONE) {
        qDebug() << "Error updating task: " << sqlite3_errmsg(db);
        sqlite3_finalize(stmt);
        sqlite3_close(db);
        return false;
    }

    qDebug() << "Task updated successfully with ID:" << id;

    sqlite3_finalize(stmt);
    sqlite3_close(db);
    return true;
}

QList<QObject*> TaskManager::getTasks() {
    QList<QObject*> taskList;
    sqlite3* db;
    sqlite3_stmt* stmt;

    if (sqlite3_open("tasks.db", &db)) {
        std::cerr << "Error opening database: " << sqlite3_errmsg(db) << std::endl;
        return taskList;
    }

    const char* sql = "SELECT id, taskName, taskDescription, taskDeadline, taskImportance, taskStateFinished FROM tasks;";
    if (sqlite3_prepare_v2(db, sql, -1, &stmt, nullptr) == SQLITE_OK) {
        while (sqlite3_step(stmt) == SQLITE_ROW) {

            //probably gonna fuck something up
            int id = sqlite3_column_int(stmt, 0);
            QString taskName = QString::fromUtf8(reinterpret_cast<const char*>(sqlite3_column_text(stmt, 1)));
            QString taskDescription = QString::fromUtf8(reinterpret_cast<const char*>(sqlite3_column_text(stmt, 2)));
            QString taskDeadline = QString::fromUtf8(reinterpret_cast<const char*>(sqlite3_column_text(stmt, 3)));
            QString taskImportance = QString::fromUtf8(reinterpret_cast<const char*>(sqlite3_column_text(stmt, 4)));
            int taskStateFinished = sqlite3_column_int(stmt, 5);

            Task* task = new Task(id, taskName, taskDescription, taskDeadline, taskImportance, taskStateFinished);
            taskList.append(task);
        }
    } else {
        std::cerr << "Error preparing statement: " << sqlite3_errmsg(db) << std::endl;
    }

    sqlite3_finalize(stmt);
    sqlite3_close(db);

    return taskList;
}

void TaskManager::insertToTable(int id, const QString &taskName, const QString &taskDescription, const QString &taskDeadline, const QString taskPriority, int taskStateFinished) {
    sqlite3* db;
    sqlite3_stmt* stmt;

    if (sqlite3_open("tasks.db", &db) != SQLITE_OK) {
        qDebug() << "Error opening database: " << sqlite3_errmsg(db);
        return;
    }

    const char* sql = "INSERT INTO tasks (id, taskName, taskDescription, taskDeadline, taskImportance, taskStateFinished) VALUES (?, ?, ?, ?, ?, ?);";

    if (sqlite3_prepare_v2(db, sql, -1, &stmt, nullptr) != SQLITE_OK) {
        qDebug() << "Error preparing statement: " << sqlite3_errmsg(db);
        sqlite3_close(db);
        return;
    }

    // gets current time
    time_t now = time(nullptr);
    tm localTime;
    localtime_s(&localTime, &now);
    char buffer[100];
    strftime(buffer, sizeof(buffer), "%Y-%m-%d %H:%M:%S", &localTime);
    string currentTime = buffer;

    // Bind values
    sqlite3_bind_int(stmt, 1, id);
    sqlite3_bind_text(stmt, 2, taskName.toStdString().c_str(), -1, SQLITE_STATIC);
    sqlite3_bind_text(stmt, 3, taskDescription.toStdString().c_str(), -1, SQLITE_STATIC);
    sqlite3_bind_text(stmt, 4, taskDeadline.toStdString().c_str(), -1, SQLITE_STATIC);
    sqlite3_bind_text(stmt, 5, taskPriority.toStdString().c_str(), -1, SQLITE_STATIC);
    sqlite3_bind_int(stmt, 6, taskStateFinished);

    // Execute the statement
    if (sqlite3_step(stmt) != SQLITE_DONE) {
        qDebug() << "Error inserting data: " << sqlite3_errmsg(db);
    } else {
        qDebug() << "Task inserted successfully!";
    }

    sqlite3_finalize(stmt);
    sqlite3_close(db);
}
