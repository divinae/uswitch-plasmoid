/*
 *  SPDX-FileCopyrightText: 2026 Jakub Lipiński <lipinski.j@pm.me>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

#pragma once

#include <QAbstractListModel>
#include <QQmlEngine>

#include <KService>

/**
 * List of applications backed by KService.
 *
 * By default it exposes the applications stored in @c appList, a JSON string in
 * the plasmoid configuration format: [["foo.desktop", {"iconName": "bar"}], ...].
 * With @c allApplications set it lists every installed, visible application instead.
 */
class AppsModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QString appList READ appList WRITE setAppList NOTIFY appListChanged)
    Q_PROPERTY(bool allApplications READ allApplications WRITE setAllApplications NOTIFY allApplicationsChanged)
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    enum Roles {
        MenuIdRole = Qt::UserRole + 1,
        NameRole,
        IconNameRole,
        DefaultIconNameRole,
        AvailableRole,
    };
    Q_ENUM(Roles)

    explicit AppsModel(QObject *parent = nullptr);

    QString appList() const;
    void setAppList(const QString &appList);

    bool allApplications() const;
    void setAllApplications(bool allApplications);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    /// Returns all roles of the given row as a map, suitable for ListModel.append().
    Q_INVOKABLE QVariantMap get(int row) const;
    Q_INVOKABLE void launch(int row) const;

Q_SIGNALS:
    void appListChanged();
    void allApplicationsChanged();
    void countChanged();

private:
    struct Entry {
        QString menuId;
        QString iconName;
        KService::Ptr service;
    };

    void reload();

    QString m_appList;
    bool m_allApplications = false;
    QList<Entry> m_entries;
};
