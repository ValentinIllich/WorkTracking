/****************************************************************************

    Copyright (C) 2021 Dr. Valentin Illich

    This file is part of WorkTracker.

    WorkTracker is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    WorkTracker is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with WorkTracker.  If not, see <http://www.gnu.org/licenses/>.

****************************************************************************/
#ifndef PROGRESSMODEL_H
#define PROGRESSMODEL_H

#include <QMap>
#include <QObject>
#include <QtQuick>

class ProgressItem;

class ProgressEntry
{
public:
  ProgressEntry();
  ProgressEntry(int id, QDateTime timestamp, QString name, QString description, bool active, int currentAccount, QVector<quint64> workInSeconds);
  ProgressEntry(int m_id, QString const &fromString);
  QString toString() const;

  int getId() const;

  bool isRecreationItem() const;

  QDateTime getTimeStamp() const;
  void setTimeStamp(const QDateTime &);

  QDateTime getRecordingStart(const int &) const;
  void setRecordingStart(const int &,const QDateTime &);

  QString getItemName() const;
  void setItemName(const QString &);

  QString getItemDescription() const;
  void setItemDescription(const QString &);

  bool getItemActive() const;
  void setItemActive(const bool &);

  int getItemCurrentAccount() const;
  void setItemCurrentAccount(const int &);

  QVector<quint64> getAllWorkInSeconds() const;
  void addAllWorkInSeconds(const QVector<quint64> &);

  quint64 getWorkInSeconds(const int &) const;
  void setWorkInSeconds(const int &,const quint64 &);
  void addWorkInSeconds(const int &,const qint64 &);

private:
  int m_id                            = 0;
  QDateTime m_timeStamp               = QDateTime::currentDateTime();
  QString m_name                      = "";
  QString m_description               = "";
  bool    m_active                    = false;
  int     m_account                   = 0;
  QVector<quint64> m_workInSeconds    = {0,0};
  QVector<QDateTime> m_recordingStart = { QDateTime(),QDateTime() };
};

class ProgressModel : public QObject
{
  Q_OBJECT

  Q_PROPERTY(QRect geometry READ geometry WRITE setGeometry NOTIFY geometryChanged)
  Q_PROPERTY(QString backgrundColor READ backgrundColor NOTIFY backgrundColorChanged)

  Q_PROPERTY(QDateTime actualDate READ actualDate WRITE setActualDate NOTIFY actualDateChanged)
  Q_PROPERTY(OperatingMode mode READ mode WRITE setMode NOTIFY modeChanged)
  Q_PROPERTY(int currentRecordingAccount READ currentRecordingAccount WRITE setCurrentRecordingAccount NOTIFY currentRecordingAccountChanged)

  Q_PROPERTY(QString title READ title NOTIFY titleChanged)
  Q_PROPERTY(bool isChangeable READ isChangeable NOTIFY isChangeableChanged)
  Q_PROPERTY(bool alwaysShowWork READ alwaysShowWork WRITE setAlwaysShowWork NOTIFY alwaysShowWorkChanged)
  Q_PROPERTY(bool showBreakTimes READ showBreakTimes WRITE setShowBreakTimes NOTIFY showBreakTimesChanged)
  Q_PROPERTY(QQmlListProperty<ProgressItem> itemList READ itemList NOTIFY itemListChanged)

  Q_PROPERTY(bool showSumInPercent READ showSumInPercent NOTIFY showSumInPercentChanged)
  Q_PROPERTY(bool showExportDays READ showExportDays NOTIFY showExportDaysChanged)
  Q_PROPERTY(QString totalTime READ totalTime NOTIFY totalTimeChanged)

public:
  enum OperatingMode
  {
    DisplayYear,
    DisplayMonth,
    DisplayWeek,
    DisplayRecordDay,
  };
  Q_ENUM(OperatingMode)

  explicit ProgressModel(QObject *parent = nullptr);
  virtual ~ProgressModel();

  enum StorageType
  {
    DataStorage,
    DefaultListStorage
  };
  static void setStorageBaseFileName(StorageType type, QString const &filename);
  static QString getStorageBaseFileName(StorageType type);
  static void setStoragePath(QString const &path);
  static void cleanupStorage();

  QRect geometry() const;
  void setGeometry(const QRect &rect);

  QString backgrundColor();

  QDateTime actualDate() const;
  void setActualDate(const QDateTime &);

  OperatingMode mode();
  void setMode(const OperatingMode &);

  int currentRecordingAccount();
  void setCurrentRecordingAccount(const int &);

  QString title();

  bool isChangeable() const;

  bool alwaysShowWork() const;
  void setAlwaysShowWork(const bool &);

  bool showBreakTimes() const;
  void setShowBreakTimes(const bool &);

  QQmlListProperty<ProgressItem> itemList();

  bool showSumInPercent() const;
  void changeLanguage(int language);

  bool showExportDays();
  QString totalTime() const;

  Q_SLOT void itemStateChanged();
  Q_SLOT void itemNameChanged();
  Q_SLOT void itemDescriptionChanged();
  Q_SLOT void itemAccountChanged();
  Q_SLOT void workingTimer();

  Q_SIGNAL void geometryChanged();
  Q_SIGNAL void backgrundColorChanged();
  Q_SIGNAL void actualDateChanged();
  Q_SIGNAL void modeChanged();
  Q_SIGNAL void currentRecordingAccountChanged();

  Q_SIGNAL void titleChanged();
  Q_SIGNAL void isChangeableChanged();
  Q_SIGNAL void alwaysShowWorkChanged();
  Q_SIGNAL void showBreakTimesChanged();
  Q_SIGNAL void itemListChanged();
  Q_SIGNAL void showSumInPercentChanged();
  Q_SIGNAL void showExportDaysChanged();
  Q_SIGNAL void totalTimeChanged();

  Q_SIGNAL void languageChanged();
  Q_SIGNAL void recordingDisabled();
  Q_SIGNAL void recordingStopped();

  Q_INVOKABLE QString getProgramVersion();

  Q_INVOKABLE void previous();
  Q_INVOKABLE void next();
  Q_INVOKABLE void jumpToDay(const int &day,const int &month,const int &year);
  Q_INVOKABLE void enterCheckin(const QString &checkin);
  Q_INVOKABLE void cancelAutoStop();

  Q_INVOKABLE void exportToClipboard(const QString &,const QString &);
  Q_INVOKABLE void changeSummary();

  Q_INVOKABLE QString getItemTitle(ProgressItem *);

  Q_INVOKABLE void append(const QString &name, const QString &description, const int &spentSeconds, int account);
  Q_INVOKABLE void remove(const int &index);
  Q_INVOKABLE void addSeconds(const int &index,const int &diff);

  Q_INVOKABLE void setLanguage(const int &);
  Q_INVOKABLE void createDefaultList();

  Q_INVOKABLE bool getAccountSelected(const int &);
  Q_INVOKABLE void setAccountSelected(const int &, const bool &);

  Q_INVOKABLE bool getWeekdaySelected(const int &);
  Q_INVOKABLE void setWeekdaySelected(const int &, const bool &);

  Q_INVOKABLE void showHelp();

  static void setQmlEngine(QQmlApplicationEngine &engine);

private:
  const int eAccountNone       = 0x0000;
  const int eAccountHomework   = 0x0001;
  const int eAccountOfficeWork = 0x0002;

  void updateItemsList(bool setDaySelectionToDefault = true);
  QString humanReadableMonth(int month);
  QString humanReadableWeekDay(int weekday);
  QString humanReadableDate(QDateTime date);

  ProgressEntry getTotalTime() const;

  quint64 getSummaryWorkInSeconds(ProgressEntry const &entry, bool getTotalSummary = false) const;
  QDateTime getFirstRecordingTime(const ProgressEntry &entry,int account) const;
  QString getSummaryText(ProgressEntry const &entry, QVector<quint64> totalWorkInSeconds, bool clipboardFormat = false) const;

  void saveData(QString const &filename, bool createBackup = false);

  QDateTime m_actualDate;
  QList<ProgressEntry> m_progressEntries;
  QList<ProgressItem*> m_progressItems;

  QMap<int, QList<ProgressEntry> > m_recreationEntries;

  QRect m_windowGeometry                  = QRect(100,100,400,600);

  quint64 m_redAlertLimit                 = 33300; // 9.25 h without break!
  quint64 m_yellowAlertLimit              = 32400; // 9h without break!
  quint64 m_inactivityLimit               = 900; // 15 min

  int m_nextId                            = 12345678;

  OperatingMode m_operatingMode           = DisplayRecordDay;
  bool m_isChangeable                     = true;
  bool m_alwaysShowWork                   = false;
  bool m_showBreakTimes                   = false;
  int m_selectedAccounts                  = eAccountHomework | eAccountOfficeWork;
  int m_currentRecordingAccount           = -1;
  int m_selectedWeeekdays                 = 0x1f;

  QVector<quint64> m_totalWorkSeconds     = { 0,0 };
  bool m_showSummariesInPercent           = false;

  quint64 m_runningSeconds                = 0;
  bool m_dataChanged                      = false;
  quint64 m_lastElapsed                   = 0;

  int m_recordedSeconds                   = 0;
  int m_idleSinceSeconds                  = 0;
  int m_recordingRequestedItem            = -1;

  int m_lastx                             = -1;
  int m_lasty                             = -1;

  quint64 m_lastActivity                  = 0;
  int m_lastRecordingItem                 = -1;
  int m_lastRecordingAccount              = -1;
  quint64 m_lastRecordingSeconds          = 0;
  qint64 m_checkinTime                    = -1;
};

class ProgressItem : public QObject
{
  Q_OBJECT
  Q_PROPERTY(int index READ index WRITE setIndex)
  Q_PROPERTY(QString projectName READ projectName WRITE setProjectName NOTIFY projectNameChanged)
  Q_PROPERTY(QString description READ description WRITE setDescription NOTIFY descriptionChanged)
  Q_PROPERTY(bool isActive READ isActive WRITE setIsActive NOTIFY isActiveChanged)
  Q_PROPERTY(int selectedAccount READ selectedAccount WRITE setSelectedAccount NOTIFY selectedAccountChanged)
  Q_PROPERTY(QDateTime timeStamp READ timeStamp WRITE setTimeStamp NOTIFY timeStampChanged)
  Q_PROPERTY(qint64 workInSeconds READ workInSeconds WRITE setWorkInSeconds NOTIFY workInSecondsChanged)
  Q_PROPERTY(qint64 totalWorkInSeconds READ totalWorkInSeconds WRITE setTotalWorkInSeconds NOTIFY totalWorkInSecondsChanged)
  Q_PROPERTY(QString summary READ summary WRITE setSummary NOTIFY summaryChanged)

public:
  explicit ProgressItem();
  virtual ~ProgressItem();

  int getId() const;
  void setId(const int &);

  int index();
  void setIndex(const int &);

  QString projectName() const;
  void setProjectName(const QString &);

  QString description() const;
  void setDescription(const QString &);

  bool isActive() const;
  void setIsActive(const bool &);

  int selectedAccount() const;
  void setSelectedAccount(const int &);

  QDateTime timeStamp() const;
  void setTimeStamp(const QDateTime &);

  QDateTime getRecordingStart() const;
  void setRecordingStart(const QDateTime &);

  qint64 workInSeconds() const;
  void setWorkInSeconds(const qint64 seconds);

  qint64 totalWorkInSeconds() const;
  void setTotalWorkInSeconds(const qint64 seconds);

  QString summary() const;
  void setSummary(const QString &);

  Q_SIGNAL void projectNameChanged();
  Q_SIGNAL void descriptionChanged();
  Q_SIGNAL void isActiveChanged();
  Q_SIGNAL void selectedAccountChanged();
  Q_SIGNAL void timeStampChanged();
  Q_SIGNAL void workInSecondsChanged();
  Q_SIGNAL void totalWorkInSecondsChanged();
  Q_SIGNAL void summaryChanged();

private:
  int m_id                    = 0;
  int m_index                 = 0;
  QString m_projectName       = "";
  QString m_description       = "";
  bool m_isActive             = false;
  int m_selectedAccount       = 0;
  QDateTime m_timeStamp       = QDateTime::currentDateTime();
  QDateTime m_recording       = QDateTime();
  qint64 m_workInSeconds      = 0;
  qint64 m_totalWorkInSeconds = 0;
  QString m_summaryText       = 0;
};

#endif // PROGRESSMODEL_H
