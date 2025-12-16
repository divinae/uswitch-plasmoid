/*
 *  SPDX-FileCopyrightText: 2015 David Rosca <nowrep@gmail.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#ifndef QUICKLAUNCH_P_H
#define QUICKLAUNCH_P_H

#include <QObject>
#include <QUrl>

class QuicklaunchPrivate : public QObject
{
    Q_OBJECT

public:
    explicit QuicklaunchPrivate(QObject *parent = nullptr);

    Q_INVOKABLE void openUrl(const QUrl &url);
};

#endif // QUICKLAUNCH_P_H
