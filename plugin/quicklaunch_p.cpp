/*
 *  SPDX-FileCopyrightText: 2008-2009 Lukas Appelhans <l.appelhans@gmx.de>
 *  SPDX-FileCopyrightText: 2010-2011 Ingomar Wesp <ingomar@wesp.name>
 *  SPDX-FileCopyrightText: 2013 Bhushan Shah <bhush94@gmail.com>
 *  SPDX-FileCopyrightText: 2015 David Rosca <nowrep@gmail.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#include "quicklaunch_p.h"

#include <KIO/OpenUrlJob>
#include <KNotificationJobUiDelegate>

#include <kio/global.h>

QuicklaunchPrivate::QuicklaunchPrivate(QObject *parent)
    : QObject(parent)
{
}

void QuicklaunchPrivate::openUrl(const QUrl &url)
{
    auto *job = new KIO::OpenUrlJob(url);
    job->setUiDelegate(new KNotificationJobUiDelegate(KJobUiDelegate::AutoHandlingEnabled));
    job->setRunExecutables(true);
    job->start();
}
