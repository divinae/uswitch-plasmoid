/*
 *  SPDX-FileCopyrightText: 2026 Jakub Lipiński <lipinski.j@pm.me>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "appsmodel.h"

#include <QCollator>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>

#include <KApplicationTrader>
#include <KIO/ApplicationLauncherJob>
#include <KNotificationJobUiDelegate>
#include <KSycoca>

AppsModel::AppsModel(QObject *parent)
    : QAbstractListModel(parent)
{
    connect(KSycoca::self(), &KSycoca::databaseChanged, this, &AppsModel::reload);
}

QString AppsModel::appList() const
{
    return m_appList;
}

void AppsModel::setAppList(const QString &appList)
{
    if (m_appList == appList) {
        return;
    }
    m_appList = appList;
    Q_EMIT appListChanged();
    reload();
}

bool AppsModel::allApplications() const
{
    return m_allApplications;
}

void AppsModel::setAllApplications(bool allApplications)
{
    if (m_allApplications == allApplications) {
        return;
    }
    m_allApplications = allApplications;
    Q_EMIT allApplicationsChanged();
    reload();
}

void AppsModel::reload()
{
    const int oldCount = m_entries.count();

    beginResetModel();
    m_entries.clear();

    if (m_allApplications) {
        const KService::List services = KApplicationTrader::query([](const KService::Ptr &service) {
            return !service->noDisplay();
        });
        for (const KService::Ptr &service : services) {
            m_entries.append({service->menuId(), service->icon(), service});
        }

        QCollator collator;
        collator.setCaseSensitivity(Qt::CaseInsensitive);
        std::sort(m_entries.begin(), m_entries.end(), [&collator](const Entry &a, const Entry &b) {
            return collator.compare(a.service->name(), b.service->name()) < 0;
        });
    } else {
        const QJsonArray apps = QJsonDocument::fromJson(m_appList.toUtf8()).array();
        for (const QJsonValue &app : apps) {
            const QJsonArray pair = app.toArray();
            const QString menuId = pair.at(0).toString();
            if (menuId.isEmpty()) {
                continue;
            }
            // Missing applications are kept so that the configuration survives an uninstall.
            const KService::Ptr service = KService::serviceByStorageId(menuId);
            QString iconName = pair.at(1).toObject().value(QLatin1String("iconName")).toString();
            if (iconName.isEmpty() && service) {
                iconName = service->icon();
            }
            m_entries.append({menuId, iconName, service});
        }
    }

    endResetModel();

    if (oldCount != m_entries.count()) {
        Q_EMIT countChanged();
    }
}

int AppsModel::rowCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : m_entries.count();
}

QVariant AppsModel::data(const QModelIndex &index, int role) const
{
    if (!checkIndex(index, CheckIndexOption::IndexIsValid | CheckIndexOption::ParentIsInvalid)) {
        return {};
    }

    const Entry &entry = m_entries.at(index.row());
    switch (role) {
    case Qt::DisplayRole:
    case NameRole:
        return entry.service ? entry.service->name() : entry.menuId;
    case MenuIdRole:
        return entry.menuId;
    case IconNameRole:
        return entry.iconName;
    case DefaultIconNameRole:
        return entry.service ? entry.service->icon() : QString();
    case AvailableRole:
        return bool(entry.service);
    }
    return {};
}

QHash<int, QByteArray> AppsModel::roleNames() const
{
    return {
        {MenuIdRole, "menuId"},
        {NameRole, "name"},
        {IconNameRole, "iconName"},
        {DefaultIconNameRole, "defaultIconName"},
        {AvailableRole, "available"},
    };
}

QVariantMap AppsModel::get(int row) const
{
    QVariantMap result;
    const QModelIndex idx = index(row, 0);
    if (!idx.isValid()) {
        return result;
    }

    const auto roles = roleNames();
    for (auto it = roles.cbegin(); it != roles.cend(); ++it) {
        result.insert(QString::fromUtf8(it.value()), data(idx, it.key()));
    }
    return result;
}

void AppsModel::launch(int row) const
{
    if (row < 0 || row >= m_entries.count() || !m_entries.at(row).service) {
        return;
    }

    auto *job = new KIO::ApplicationLauncherJob(m_entries.at(row).service);
    job->setUiDelegate(new KNotificationJobUiDelegate(KJobUiDelegate::AutoHandlingEnabled));
    job->start();
}
