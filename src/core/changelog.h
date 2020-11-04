/***************************************************************************
  changelog.h - Changelog

 ---------------------
 begin                : Nov 2020
 copyright            : (C) 2020 by Ivan Ivanov
 email                : ivan@opengis.ch
 ***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/
#ifndef CHANGELOG_H
#define CHANGELOG_H

#include <QObject>

class Changelog : public QObject
{
    Q_OBJECT

  public:
    Changelog( QObject *parent = nullptr );

    QString markdown();

  signals:
    void releaseChangelogFetched();

  private:
    QList<int> parseVersion( const QString version );

    QString mMarkdown;
};

#endif // CHANGELOG_H
