#ifndef TASKMANAGER_H
#define TASKMANAGER_H

#include <QObject>
#include <QString>
#include <QList>
#include <sqlite3.h> // Include SQLite3 for database interaction
#include "Task.h"

class TaskManager : public QObject {
    Q_OBJECT

public:
    explicit TaskManager(QObject *parent = nullptr);
    ~TaskManager();

    Q_INVOKABLE void insertToTable(int id, const QString &taskName, const QString &taskDescription, const QString &taskDeadline, const QString taskPriority);
    Q_INVOKABLE QList<QObject*> getTasks(); // Fetch tasks from the database
    Q_INVOKABLE bool removeTaskDB(int id);
    Q_INVOKABLE void loadTasksDB();
    Q_INVOKABLE bool updateTaskDB(int taskId, const QString &taskName, const QString &taskDescription, const QString &taskDeadline, const QString &taskPriority);
    void cleanupBeforeExit();  // Function to run on exit

signals:
    void taskLoaded(int id, QString taskName, QString taskDescription, QString taskDeadline, QString taskImportance);


private:
    QList<Task*> m_tasks; // Store tasks
    sqlite3* m_db; // Database connection

    // Helper method to open database connection
    bool openDatabase();
    void closeDatabase();

    void loadTasks();
};

#endif // TASKMANAGER_H
