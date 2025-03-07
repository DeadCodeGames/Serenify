#ifndef TASK_H
#define TASK_H

#include <QObject>

class Task : public QObject {
    Q_OBJECT
    Q_PROPERTY(int id READ id WRITE setId NOTIFY idChanged)
    Q_PROPERTY(QString taskName READ taskName WRITE setTaskName NOTIFY taskNameChanged)
    Q_PROPERTY(QString taskDescription READ taskDescription WRITE setTaskDescription NOTIFY taskDescriptionChanged)
    Q_PROPERTY(QString dateDeadline READ dateDeadline WRITE setDateDeadline NOTIFY dateDeadlineChanged)
    Q_PROPERTY(QString taskImportance READ taskImportance WRITE setTaskImportance NOTIFY taskImportanceChanged)
    Q_PROPERTY(int taskStateFinished READ taskStateFinished WRITE setTaskStateFinished NOTIFY taskStateFinishedChanged)

public:
    explicit Task(int id, const QString &taskName, const QString &taskDescription, const QString &dateDeadline, const QString taskImportance, int taskStateFinished, QObject *parent = nullptr)
        : QObject(parent), m_id(id), m_taskName(taskName), m_taskDescription(taskDescription),
        m_dateDeadline(dateDeadline), m_taskImportance(taskImportance), m_taskStateFinished(taskStateFinished) {}

    // getters
    int id() const { return m_id; }
    QString taskName() const { return m_taskName; }
    QString taskDescription() const { return m_taskDescription; }
    QString dateDeadline() const { return m_dateDeadline; }
    QString taskImportance() const { return m_taskImportance; }
    int taskStateFinished() const { return m_taskStateFinished; }

    //setters

    void setId(int id) {  // Setter
        if (m_id != id) {
            m_id = id;
            emit idChanged();
        }
    }

    void setTaskName(const QString &taskName) {
        if (m_taskName != taskName) {
            m_taskName = taskName;
            emit taskNameChanged();
        }
    }

    void setTaskDescription(const QString &taskDescription) {
        if (m_taskDescription != taskDescription) {
            m_taskDescription = taskDescription;
            emit taskDescriptionChanged();
        }
    }

    void setDateDeadline(const QString &dateDeadline) {
        if (m_dateDeadline != dateDeadline) {
            m_dateDeadline = dateDeadline;
            emit dateDeadlineChanged();
        }
    }

    void setTaskImportance(const QString &taskImportance) {
        if (m_taskImportance != taskImportance) {
            m_taskImportance = taskImportance;
            emit taskImportanceChanged();
        }
    }

    void setTaskStateFinished(int taskStateFinished) {
        if (m_taskStateFinished != taskStateFinished) {
            m_taskStateFinished = taskStateFinished;
            emit taskStateFinishedChanged();
        }
    }

signals:
    void idChanged();
    void taskNameChanged();
    void taskDescriptionChanged();
    void dateDeadlineChanged();
    void taskImportanceChanged();
    void taskStateFinishedChanged();

private:
    int m_id;
    QString m_taskName;
    QString m_taskDescription;
    QString m_dateDeadline;
    QString m_taskImportance;
    int m_taskStateFinished;
};

#endif // TASK_H
