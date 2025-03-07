#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "TaskManager.h"
#include "Task.h"
#include <iostream>
#include <sqlite3.h>
#include <QDebug>

using namespace std;

// Callback function to print query results
static int callback(void* NotUsed, int argc, char** argv, char** colName) {
    for (int i = 0; i < argc; i++) {
        qDebug() << colName[i] << ": " << (argv[i] ? argv[i] : "NULL");
    }
    qDebug() << "--------------------------" << "\n";
    return 0;
}

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    TaskManager taskManager;
    qmlRegisterType<Task>("TaskImport", 1, 0, "Task");  // Register Task class in QML
    engine.rootContext()->setContextProperty("taskManager", &taskManager);

    QObject::connect(&app, &QCoreApplication::aboutToQuit, &taskManager, &TaskManager::cleanupBeforeExit);

    // SEPERATOR

    sqlite3* db;
    char* errorMessage = nullptr;

    // Open (or create) database
    if (sqlite3_open("tasks.db", &db)) {
        cerr << "Error opening database: " << sqlite3_errmsg(db) << endl;
        return 1;
    }
    qDebug() << "Database opened successfully!\n";

    // Create table
    const char* createTableSQL =
        "CREATE TABLE IF NOT EXISTS tasks ("
        "id INTEGER PRIMARY KEY, "
        "taskName TEXT NOT NULL, "
        "taskDescription TEXT,"
        "taskDeadline DATE NOT NULL,"
        "taskImportance TEXT NOT NULL)";

    if (sqlite3_exec(db, createTableSQL, nullptr, 0, &errorMessage) != SQLITE_OK) {
        cerr << "Error creating table: " << errorMessage << endl;
        sqlite3_free(errorMessage);
    }
    else {
        qDebug() << "Table created successfully!\n";
    }

    sqlite3_stmt* stmt;
    const char* checkEmptySQL = "SELECT COUNT(*) FROM tasks;";

    int taskCount = 0;
    if (sqlite3_prepare_v2(db, checkEmptySQL, -1, &stmt, nullptr) == SQLITE_OK) {
        if (sqlite3_step(stmt) == SQLITE_ROW) {
            taskCount = sqlite3_column_int(stmt, 0);
        }
    }
    sqlite3_finalize(stmt);

    // If empty, add an example task
    // If empty, add an example task
    if (taskCount == 0) {
        qDebug() << "No tasks found. Adding example task...";

        const char* insertSQL =
            "INSERT INTO tasks (id, taskName, taskDescription, taskDeadline, taskImportance) "
            "VALUES ('1', 'Example Task', 'This is a sample task.', '2025-12-31 00:00:00', 'high');";

        if (sqlite3_exec(db, insertSQL, nullptr, 0, &errorMessage) != SQLITE_OK) {
            qDebug() << "Error inserting example task: " << errorMessage;
            sqlite3_free(errorMessage);
        } else {
            qDebug() << "Example task added successfully.";
        }

        // Reload tasks after adding the example task
        //taskManager.loadTasksDB(); // Make sure to reload the tasks to get the newly added task.
    }



    // Retrieve data
    const char* selectSQL = "SELECT * FROM tasks;";

    if (sqlite3_exec(db, selectSQL, callback, nullptr, &errorMessage) != SQLITE_OK) {
        cerr << "Error selecting data: " << errorMessage << endl;
        sqlite3_free(errorMessage);
    }

    // SEPERATOR

    // Connect to the completed signal to ensure the engine is fully initialized

    QObject::connect(&taskManager, &TaskManager::taskLoaded, &engine, [&engine](int id, QString taskName, QString taskDescription, QString taskDeadline, QString taskImportance) {
        QObject *rootObject = engine.rootObjects().first();
        if (rootObject) {
            // Now invoke the method on the root object
            /*QMetaObject::invokeMethod(rootObject, "appendTaskToModel",
                                      Q_ARG(QVariant, QVariant::fromValue(id)),
                                      Q_ARG(QVariant, QVariant::fromValue(taskName)),
                                      Q_ARG(QVariant, QVariant::fromValue(taskDescription)),
                                      Q_ARG(QVariant, QVariant::fromValue(taskDeadline)),
                                      Q_ARG(QVariant, QVariant::fromValue(taskImportance)));*/

            QMetaObject::invokeMethod(rootObject, "appendTaskToModel",
                                    Q_ARG(int, id),
                                    Q_ARG(QString, taskName),
                                    Q_ARG(QString, taskDescription),
                                    Q_ARG(QString, taskDeadline),
                                    Q_ARG(QString, taskImportance));
        } else {
            qWarning() << "Root object is null!";
        }
    });


    // Load the QML file
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *object, const QUrl &objUrl) {
                         if (!object) {
                             qWarning() << "Error loading QML object from" << objUrl;
                         }
                     }, Qt::QueuedConnection);

    engine.load(QUrl::fromLocalFile(QStringLiteral("Serenify/Main.qml")));
    if (engine.rootObjects().isEmpty()) return -1;

    return app.exec();
}
