#include "progressmodel.h"

QQmlEngine *m_qmlEngine;

ProgressEntry::ProgressEntry(int id, QDateTime timestamp, QString name, QString description, bool active, bool doneHome, quint64 workInSeconds)
  : m_id(id)
  , m_timeStamp(timestamp)
  , m_name(name)
  , m_description(description)
  , m_active(active)
  , m_doneHome(doneHome)
  , m_workInSeconds(workInSeconds)

{
}

ProgressEntry::ProgressEntry(int itemId, const QString &fromString)
{
  QStringList properties = fromString.split(";");
  if( properties[0].contains("=") )
  {
    for( const auto &item : qAsConst(properties) )
    {
      if( item.contains("itmid=") )
        m_id = (itemId==-1 ? item.midRef(6).toInt() : itemId);
      if( item.contains("title=") )
        m_name = item.mid(6);
      if( item.contains("descr=") )
        m_description = item.mid(6);
      if( item.contains("creat=") )
        m_timeStamp = QDateTime::fromSecsSinceEpoch(item.mid(6).toLongLong());;
      if( item.contains("spent=") )
        m_workInSeconds = item.midRef(6).toULongLong();
    }
    m_active = false;
    m_doneHome = false;
  }
  else
  {
    QDateTime time = QDateTime::fromSecsSinceEpoch(properties[3].toLongLong());
    m_id = (itemId==-1 ? properties[0].toInt() : itemId),
        m_timeStamp = time;
    m_name = properties[1];
    m_description = properties[2];
    m_active = false;
    m_doneHome = properties.count()==6 ? (properties[5]=="h") : true;
    m_workInSeconds = properties[4].toULongLong();
  }
}

QString ProgressEntry::toString() const
{
  return    "itmid=" +    QString::number(m_id) + ";"
          + "title=" +                    m_name + ";"
          + "descr=" +                    m_description + ";"
          + "creat=" +    QString::number(m_timeStamp.toSecsSinceEpoch()) + ";"
          + "spent=" +    QString::number(m_workInSeconds);// + ";"
           //"" +                   (m_doneHome ? "h" : "o");
}

int ProgressEntry::getId() const
{
  return m_id;
}

QDateTime ProgressEntry::getTimeStamp() const
{
  return m_timeStamp;
}

void ProgressEntry::setTimeStamp(const QDateTime &time)
{
  m_timeStamp = time;
}

QString ProgressEntry::getItemName() const
{
  return m_name;
}

void ProgressEntry::setItemName(const QString &name)
{
  m_name = name;
}

QString ProgressEntry::getItemDescription() const
{
  return m_description;
}

void ProgressEntry::setItemDescription(const QString &descr)
{
  m_description = descr;
}

bool ProgressEntry::getItemActive() const
{
  return m_active;
}

void ProgressEntry::setItemActive(const bool &active)
{
  m_active = active;
}

bool ProgressEntry::getItemDoneHome() const
{
  return m_doneHome;
}

void ProgressEntry::setItemDoneHome(const bool &done)
{
  m_doneHome = done;
}

quint64 ProgressEntry::getWorkInSeconds() const
{
  return m_workInSeconds;
}

void ProgressEntry::setWorkInSeconds(const quint64 &work)
{
  m_workInSeconds = work;
}

void ProgressEntry::addWorkInSeconds(const quint64 &work)
{
  m_workInSeconds += work;
}

ProgressModel::ProgressModel(QObject *parent) : QObject(parent)
{
  saveData("workingOnProjects", true);

  connect(this,SIGNAL(languageChanged()),m_qmlEngine,SLOT(retranslate()));

  QSettings settings("VISolutions","project-tracker");
  if( settings.contains("language-id") )
    changeLanguage(settings.value("language-id").toInt());

  m_actualDate = QDateTime::currentDateTime();
  //m_operatingMode = DisplayRecordDay;
  //m_isChangeable = true;

  QTimer *timer = new QTimer(this);
  connect(timer, SIGNAL(timeout()), this, SLOT(workingTimer()));
  timer->start(1000);

  bool todayListIsEmpty = true;
  QFile file("workingOnProjects.csv");
  file.open(QFile::ReadOnly);
  QTextStream s(&file);
  while( !s.atEnd() )
  {
    m_progressEntries <<  ProgressEntry(-1,s.readLine());
    m_nextId = m_progressEntries.last().getId();
    if( m_progressEntries.last().getTimeStamp().date()==m_actualDate.date() )
      todayListIsEmpty = false;
  }
  m_nextId++;

  if( todayListIsEmpty )
  {
    QDateTime timeStamp = QDateTime::currentDateTime();
    timeStamp.time().setHMS(0,0,0);
    m_progressEntries << ProgressEntry(m_nextId++,"0;Wideband;;"+QString::number(timeStamp.toSecsSinceEpoch())+";0;h");
    m_progressEntries << ProgressEntry{m_nextId++,"0;NRPxP;;"+QString::number(timeStamp.toSecsSinceEpoch())+";0;h"};
    m_progressEntries << ProgressEntry{m_nextId++,"0;NRX Pflege;;"+QString::number(timeStamp.toSecsSinceEpoch())+";0;h"};
    m_progressEntries << ProgressEntry{m_nextId++,"0;NRP Pflege;;"+QString::number(timeStamp.toSecsSinceEpoch())+";0;h"};
    m_progressEntries << ProgressEntry{m_nextId++,"0;Audio;;"+QString::number(timeStamp.toSecsSinceEpoch())+";0;h"};
    m_progressEntries << ProgressEntry{m_nextId++,"0;NRPM;;"+QString::number(timeStamp.toSecsSinceEpoch())+";0;h"};
    m_progressEntries << ProgressEntry{m_nextId++,"0;Allgemein;;"+QString::number(timeStamp.toSecsSinceEpoch())+";0;h"};
  }
  updateItemsList();
}

ProgressModel::~ProgressModel()
{
  if( m_dataChanged )
    saveData("workingOnProjects", false);
}

QDateTime ProgressModel::actualDate() const
{
  return m_actualDate;
}

void ProgressModel::setActualDate(const QDateTime &date)
{
  m_actualDate = date;
}

ProgressModel::OperatingMode ProgressModel::mode()
{
  return m_operatingMode;
}

void ProgressModel::setMode(const ProgressModel::OperatingMode &mode)
{
  m_operatingMode = mode;

  updateItemsList();
  emit titleChanged();
  emit totalTimeChanged();
}

void ProgressModel::exportToClipboard(const QString &additionalMinutes,const QString &thresholdHours)
{
  // this will ensure that m_totalWorkSeconds is correct
  updateItemsList();


  QClipboard *clipboard = QGuiApplication::clipboard();
  QString data;

  for( auto item : qAsConst(m_progressItems) )
  {
    if( m_showSummariesInPercent )
    {
      quint64 timespent = item->workInSeconds();
      double percent = double(timespent)*100.0/double(m_totalWorkSeconds);
      data += item->projectName() + "\t" + QString::asprintf("%1.3f",percent).replace(".",",") + "\n";

      qDebug(" export %s,%1.3f\n",item->projectName().toLatin1().data(),percent);
    }
    else
    {
      quint64 timespent = item->workInSeconds();
      if( timespent>(thresholdHours.toULong()*3600) )
        timespent += additionalMinutes.toULong()*60;

      qDebug(" export %s,%lld\n",item->projectName().toLatin1().data(),timespent);

      timespent += 150; // round in range of 5 minutes
      timespent = (timespent / 300) * 300;

      QDateTime startDateTime = QDateTime::currentDateTime();
      QTime startTime = startDateTime.time();
      startTime.setHMS(8,0,0);
      QTime endTime = startTime.addSecs(timespent);

      data += item->projectName() + "\t" + "08:00" + "\t" + endTime.toString("hh:mm") + "\n";
    }
  }

  clipboard->setText(data);
}

QString ProgressModel::humanReadableMonth(int month)
{
  const QString s_months[] = {
    tr("January"),tr("February"),tr("March"),tr("April"),tr("May"),tr("June"),
    tr("July"),tr("August"),tr("September"),tr("October"),tr("November"),tr("December")
  };
  return s_months[month];
  //return QCoreApplication::translate("mainTranslation", s_months[month].toLatin1().data());
}
QString ProgressModel::humanReadableWeekDay(int weekday)
{
  const QString s_days[] = {
    tr("Monday"),tr("Tuesday"),tr("Wednesday"),tr("Thursday"),tr("Friday"),tr("Saturday"),tr("Sunday")
  };
  return s_days[weekday];
  //return QCoreApplication::translate("mainTranslation", s_days[weekday].toLatin1().data());
}

QString ProgressModel::title()
{
  switch( m_operatingMode )
  {
  case DisplayYear:
    return QString::number(m_actualDate.date().year());
    break;
  case DisplayMonth:
    return humanReadableMonth(m_actualDate.date().month()-1);
    break;
  case DisplayWeek:
    return tr("week") +" " + QString::number(m_actualDate.date().weekNumber()) + " " + tr("of year");
    break;
  case DisplayRecordDay:
    return humanReadableWeekDay(m_actualDate.date().dayOfWeek()-1) + m_actualDate.toString(" dd-MM-yyyy");
    break;
  }

  return "";
}

bool ProgressModel::isChangeable() const
{
  return m_operatingMode==DisplayRecordDay;
}

bool ProgressModel::alwaysShowWork() const
{
  return m_alwaysShowWork;
}

void ProgressModel::setAlwaysShowWork(const bool &alwaysWork)
{
  m_alwaysShowWork = alwaysWork;
  updateItemsList();
  emit alwaysShowWorkChanged();
}

bool ProgressModel::showHomeWorkOnly() const
{
  return m_showHomeWorkOnly;
}

void ProgressModel::setShowHomeWorkOnly(const bool &homeWorkOnly)
{
  qDebug("++++\n");
  m_showHomeWorkOnly = homeWorkOnly;
  updateItemsList();
  emit showHomeWorkOnlyChanged();
}

QQmlListProperty<ProgressItem> ProgressModel::itemList()
{
  return QQmlListProperty<ProgressItem>(this, m_progressItems);
}

bool ProgressModel::showSumInPercent() const
{
  return m_showSummariesInPercent;
}

void ProgressModel::changeLanguage(int language)
{
  static QTranslator translator;
  bool loaded = false;

  QCoreApplication::removeTranslator(&translator);

  // 0 - english, just remove translation

  // 1 - german
  if( language==1 )
    loaded = translator.load(":/translations/projects_de.qm");

  // 2 - french
  if( language==2 )
    loaded = translator.load(":/translations/projects_fr.qm");

  if ( loaded )
    QCoreApplication::installTranslator(&translator);
}

QString ProgressModel::totalTime() const
{
  ProgressEntry summary;
  summary.setItemActive(false);
  summary.setWorkInSeconds(0);
  switch( m_operatingMode )
  {
  case DisplayYear:
  case DisplayMonth:
  case DisplayWeek:
    summary.setWorkInSeconds(m_totalWorkSeconds);
    break;
  case DisplayRecordDay:
    for( int i=0; i<m_progressEntries.size(); i++ )
    {
      for( int j=0; j<m_progressItems.size(); j++ )
      {
        if( m_progressItems.at(j)->getId()==m_progressEntries[i].getId() )
          summary.addWorkInSeconds(m_progressEntries[i].getWorkInSeconds());
      }
    }
    break;
  }

  return getSummary(summary,0);
}

void ProgressModel::itemStateChanged()
{
  ProgressItem *item = static_cast<ProgressItem*>(sender());
  for( int i=0; i<m_progressEntries.size(); i++ )
  {
    if( m_progressEntries[i].getId()==item->getId() )
    {
      m_dataChanged = true;
      m_progressEntries[i].setItemActive(item->isActive());
      item->setSummary(getSummary(m_progressEntries[i],m_totalWorkSeconds));
    }
  }
}

void ProgressModel::itemNameChanged()
{
  ProgressItem *item = static_cast<ProgressItem*>(sender());
  for( int i=0; i<m_progressEntries.size(); i++ )
  {
    m_dataChanged = true;
    if( m_progressEntries[i].getId()==item->getId() )
      m_progressEntries[i].setItemName(item->projectName());
  }
}

void ProgressModel::itemDescriptionChanged()
{
  ProgressItem *item = static_cast<ProgressItem*>(sender());
  for( int i=0; i<m_progressEntries.size(); i++ )
  {
    m_dataChanged = true;
    if( m_progressEntries[i].getId()==item->getId() )
      m_progressEntries[i].setItemDescription(item->description());
  }
}

void ProgressModel::itemDoneHomeChanged()
{
  ProgressItem *item = static_cast<ProgressItem*>(sender());
  for( int i=0; i<m_progressEntries.size(); i++ )
  {
    m_dataChanged = true;
    if( m_progressEntries[i].getId()==item->getId() )
      m_progressEntries[i].setItemDoneHome(item->isDoneHome());
  }
}

void ProgressModel::itemWorkInSecondsChanged()
{
  qDebug("+++thats it\n");
  ProgressItem *item = static_cast<ProgressItem*>(sender());
  for( int i=0; i<m_progressEntries.size(); i++ )
  {
    if( m_progressEntries[i].getId()==item->getId() )
    {
      m_dataChanged = true;
      m_progressEntries[i].setWorkInSeconds(item->workInSeconds());
      for( int j=0; j<m_progressItems.size(); j++ )
      {
        if( m_progressItems.at(j)->getId()==m_progressEntries[i].getId() )
          m_progressItems.at(j)->setSummary(getSummary(m_progressEntries[i],0));
      }
    }
  }

  emit totalTimeChanged();
}

void ProgressModel::workingTimer()
{
  for( int i=0; i<m_progressEntries.size(); i++ )
  {
    if( m_progressEntries[i].getItemActive() )
    {
      m_dataChanged = true;
      m_progressEntries[i].addWorkInSeconds(1);
      for( int j=0; j<m_progressItems.size(); j++ )
      {
        if( m_progressItems.at(j)->getId()==m_progressEntries[i].getId() )
          m_progressItems.at(j)->setSummary(getSummary(m_progressEntries[i],m_totalWorkSeconds));
      }
    }
  }

  m_runningSeconds++;
  if( (m_runningSeconds % 300) == 0)
  {
    if( m_dataChanged )
    {
      saveData("workingOnProjects", false);
      m_dataChanged = false;
    }
  }

  emit totalTimeChanged();
}

void ProgressModel::previous()
{
  switch( m_operatingMode )
  {
  case DisplayYear:
    m_actualDate = m_actualDate.addYears(-1);
    break;
  case DisplayMonth:
    m_actualDate = m_actualDate.addMonths(-1);
    break;
  case DisplayWeek:
    m_actualDate = m_actualDate.addDays(-7);
    break;
  case DisplayRecordDay:
    m_actualDate = m_actualDate.addDays(-1);
    break;
  }

  updateItemsList();
  emit totalTimeChanged();
  emit actualDateChanged();
  emit titleChanged();
}

void ProgressModel::next()
{
  switch( m_operatingMode )
  {
  case DisplayYear:
    m_actualDate = m_actualDate.addYears(1);
    break;
  case DisplayMonth:
    m_actualDate = m_actualDate.addMonths(1);
    break;
  case DisplayWeek:
    m_actualDate = m_actualDate.addDays(7);
    break;
  case DisplayRecordDay:
    m_actualDate = m_actualDate.addDays(1);
    break;
  }

  updateItemsList();
  emit actualDateChanged();
  emit titleChanged();
  emit totalTimeChanged();
}

void ProgressModel::changeSummary()
{
  m_showSummariesInPercent = !m_showSummariesInPercent;
  updateItemsList();
  emit showSumInPercentChanged();
}

QString ProgressModel::getItemTitle(ProgressItem *item)
{
  return item->projectName();
}

void ProgressModel::append(const QString &name, const QString &description, const QDateTime &timeSpent)
{
  QDateTime newTimeStamp = m_actualDate;
  newTimeStamp.setTime(timeSpent.time());

  ProgressEntry item {m_nextId++,newTimeStamp,name,description,true,true,0};

  item.setWorkInSeconds(timeSpent.time().hour()*3600 + timeSpent.time().minute()*60);
  m_progressEntries << item;

  updateItemsList();
  emit totalTimeChanged();
}

void ProgressModel::remove(const int &index)
{
  int id = m_progressItems.at(index)->getId();

  QList<ProgressEntry>::iterator item = m_progressEntries.begin();
  while( item!=m_progressEntries.end() )
  {
    if( item->getId()==id )
      item = m_progressEntries.erase(item);
    else
      ++item;
  }

  updateItemsList();
  emit totalTimeChanged();
}

void ProgressModel::setLanguage(const int &lang)
{
  QSettings settings("VISolutions","project-tracker");

  changeLanguage(lang);
  settings.setValue("language-id",lang);

  updateItemsList();
  emit languageChanged();
}

void ProgressModel::setQmlEngine(QQmlApplicationEngine &engine)
{
  m_qmlEngine = &engine;
}

void ProgressModel::updateItemsList()
{
  m_progressItems.clear();

  QMap<QString,ProgressEntry> projectsMap;
  QMap<int,ProgressEntry> monthsMap;
  QMap<int,ProgressEntry> weekDayMap;
  QList<ProgressEntry> dayList;

  m_totalWorkSeconds = 0;
  for( const auto &item : qAsConst(m_progressEntries) )
  {
    switch( m_operatingMode )
    {
    case DisplayYear:
      if( item.getTimeStamp().date().year()!=m_actualDate.date().year() )
        continue;
      if( m_showHomeWorkOnly && !item.getItemDoneHome() )
        continue;
      if( m_alwaysShowWork )
      {
        if( !projectsMap.contains(item.getItemName()) )
          projectsMap[item.getItemName()] = ProgressEntry{0,item.getTimeStamp(), item.getItemName(),item.getItemDescription(),false,false,0};
        projectsMap[item.getItemName()].addWorkInSeconds(item.getWorkInSeconds());
      }
      else
      {
        if( !monthsMap.contains(item.getTimeStamp().date().month()) )
          monthsMap[item.getTimeStamp().date().month()] = ProgressEntry{0,item.getTimeStamp(), item.getItemName(),item.getItemDescription(),false,false,0};
        monthsMap[item.getTimeStamp().date().month()].addWorkInSeconds(item.getWorkInSeconds());
      }
      break;
    case DisplayMonth:
      if( item.getTimeStamp().date().month()!=m_actualDate.date().month() )
        continue;
      if( m_showHomeWorkOnly && !item.getItemDoneHome() )
        continue;
      if( !projectsMap.contains(item.getItemName()) )
        projectsMap[item.getItemName()] = ProgressEntry{0,item.getTimeStamp(), item.getItemName(),item.getItemDescription(),false,false,0};
      projectsMap[item.getItemName()].addWorkInSeconds(item.getWorkInSeconds());
      break;
    case DisplayWeek:
      if( item.getTimeStamp().date().weekNumber()!=m_actualDate.date().weekNumber())
        continue;
      if( m_showHomeWorkOnly && !item.getItemDoneHome() )
        continue;
      if( m_alwaysShowWork )
      {
        if( !projectsMap.contains(item.getItemName()) )
          projectsMap[item.getItemName()] = ProgressEntry{0,item.getTimeStamp(), item.getItemName(),item.getItemDescription(),false,false,0};
        projectsMap[item.getItemName()].addWorkInSeconds(item.getWorkInSeconds());
      }
      else
      {
        if( !weekDayMap.contains(item.getTimeStamp().date().dayOfWeek()) )
          weekDayMap[item.getTimeStamp().date().dayOfWeek()] = ProgressEntry{0,item.getTimeStamp(), item.getItemName(),item.getItemDescription(),false,false,0};
        weekDayMap[item.getTimeStamp().date().dayOfWeek()].addWorkInSeconds(item.getWorkInSeconds());
      }
      break;
    case DisplayRecordDay:
      if( item.getTimeStamp().date()!=m_actualDate.date() )
        continue;
      if( m_showHomeWorkOnly && !item.getItemDoneHome() )
        continue;
      dayList << ProgressEntry{item.getId(),item.getTimeStamp(), item.getItemName(),item.getItemDescription(),item.getItemActive(),item.getItemDoneHome(),item.getWorkInSeconds()};
      break;
    }
    m_totalWorkSeconds += item.getWorkInSeconds();
  }

  if( projectsMap.size()>0 )
  {
    QList<QString> keys = projectsMap.keys();
    for( const auto &key : qAsConst(keys) )
    {
      ProgressEntry &item = projectsMap[key];
      ProgressItem *entry = new ProgressItem();
      entry->setId(item.getId());
      entry->setProjectName(key);// item.m_projectName;
      //entry->m_description = item.m_description;
      //entry->m_isActive = item.m_active;
      //entry->m_timeStamp = item.m_timeStamp;
      entry->setWorkInSeconds(item.getWorkInSeconds());
      entry->setSummary(getSummary(item,m_totalWorkSeconds));

      entry->connect(entry,SIGNAL(isActiveChanged()),this,SLOT(itemStateChanged()));
      entry->connect(entry,SIGNAL(projectNameChanged()),this,SLOT(itemNameChanged()));
      entry->connect(entry,SIGNAL(descriptionChanged()),this,SLOT(itemDescriptionChanged()));
      m_progressItems << entry;
    }
  }
  if( monthsMap.size()>0 )
  {
    for( int month=0; month<12; month++ )
    {
      if( monthsMap.contains(month+1) )
      {
        ProgressEntry &item = monthsMap[month+1];

        ProgressItem *entry = new ProgressItem();
        entry->setId(item.getId());
        entry->setProjectName(humanReadableMonth(month));
        //entry->m_description = "";
        //entry->m_isActive = false;
        entry->setTimeStamp(item.getTimeStamp());
        entry->setWorkInSeconds(item.getWorkInSeconds());
        entry->setSummary(getSummary(item,m_totalWorkSeconds));

        m_progressItems << entry;
      }
    }
  }
  if( weekDayMap.size()>0 )
  {
    for( int day=0; day<7; day++ )
    {
      if( weekDayMap.contains(day+1) )
      {
        ProgressEntry &item = weekDayMap[day+1];

        ProgressItem *entry = new ProgressItem();
        entry->setId(item.getId());
        entry->setProjectName(humanReadableWeekDay(day));
        //entry->m_description = "";
        //entry->m_isActive = false;
        entry->setTimeStamp(item.getTimeStamp());
        entry->setWorkInSeconds(item.getWorkInSeconds());
        entry->setSummary(getSummary(item,m_totalWorkSeconds));

        m_progressItems << entry;
      }
    }
  }
  if( dayList.size()>0 )
  {
    for( const auto &item : qAsConst(dayList) )
    {
      ProgressItem *entry = new ProgressItem();
      entry->setId(item.getId());
      entry->setProjectName(item.getItemName());
      entry->setDescription(item.getItemDescription());
      entry->setIsActive(item.getItemActive());
      entry->setIsDoneHome(item.getItemDoneHome());
      entry->setTimeStamp(item.getTimeStamp());
      entry->setWorkInSeconds(item.getWorkInSeconds());
      entry->setSummary(getSummary(item,m_totalWorkSeconds));

      entry->connect(entry,SIGNAL(isActiveChanged()),this,SLOT(itemStateChanged()));
      entry->connect(entry,SIGNAL(projectNameChanged()),this,SLOT(itemNameChanged()));
      entry->connect(entry,SIGNAL(descriptionChanged()),this,SLOT(itemDescriptionChanged()));
      entry->connect(entry,SIGNAL(isDoneHomeChanged()),this,SLOT(itemDoneHomeChanged()));
      entry->connect(entry,SIGNAL(workInSecondsChanged()),this,SLOT(itemWorkInSecondsChanged()));
      m_progressItems << entry;
    }
  }

  emit itemListChanged();
}

QString ProgressModel::getSummary(const ProgressEntry &entry, quint64 totalWorkInSeconds) const
{
  double percent = 0.0;
  QString infotext;

  if( totalWorkInSeconds>0 )
    percent = (double)entry.getWorkInSeconds()*100.0/(double)totalWorkInSeconds;
  bool showinPercent = m_showSummariesInPercent && (totalWorkInSeconds>0);

  quint64 value = entry.getWorkInSeconds();
  int seconds = value % 60; value /= 60;
  int minutes = value % 60; value /= 60;
  int hours = value;

  switch( m_operatingMode )
  {
  case DisplayYear:
    //break;
  case DisplayMonth:
    infotext = showinPercent ? QString::asprintf("%.0f %%",percent) : QString::asprintf("%4d,%02d h",hours,minutes*10/6);
    break;
  case DisplayWeek:
    infotext = showinPercent ? QString::asprintf("%.1f %%",percent) : QString::asprintf("%02d:%02d",hours,minutes);
    break;
  case DisplayRecordDay:
    if( entry.getItemActive() )
      infotext = QString::asprintf("%02d:%02d:%02d",hours,minutes,seconds);
    else
      infotext = QString::asprintf("%02d:%02d",hours,minutes);
    break;
  }

  return infotext;
}

void ProgressModel::saveData(const QString &filename, bool createBackup)
{
  QString dataFile = filename+".csv";
  QString dataBackup = filename+"-backup.csv";

  if( createBackup )
  {
    QFileInfo fi(dataBackup);
    if( !fi.exists() || fi.lastModified().daysTo(QDateTime::currentDateTime())>=1 )
    {
      QFile file(dataBackup);
      if( !file.rename(filename+"-"+QDateTime::currentDateTime().toString("yyyyMMdd-hhmmss")+".csv"))
        ;
      QFile file2(dataFile);
      if( !file2.copy(dataBackup) )
        ;
    }
  }
  else
  {
    QFile file(dataFile);
    file.open(QFile::WriteOnly);
    QTextStream s(&file);
    for( const auto &entry : qAsConst(m_progressEntries) )
    {
      s << entry.toString() << "\n";
    }
  }
}

ProgressItem::ProgressItem()
{
}

//ProgressItem::ProgressItem(const ProgressItem &src) : QObject()
//{
//    m_projectName = src.m_projectName;
//    m_isActive = src.m_isActive;
//    m_timeStamp = src.m_timeStamp;
//    m_summaryText = "";
//}

ProgressItem::~ProgressItem()
{
}

int ProgressItem::getId() const
{
  return m_id;
}

void ProgressItem::setId(const int &id)
{
  m_id = id;
}

QString ProgressItem::projectName() const
{
  return m_projectName;
}

void ProgressItem::setProjectName(const QString &name)
{
  m_projectName = name;
  emit projectNameChanged();
  qDebug("++++setProjectName called!");
}

QString ProgressItem::description() const
{
  return m_description;
}

void ProgressItem::setDescription(const QString &description)
{
  m_description = description;
  emit descriptionChanged();
}

bool ProgressItem::isActive() const
{
  return m_isActive;
}

void ProgressItem::setIsActive(const bool &active)
{
  m_isActive = active;
  emit isActiveChanged();
  qDebug("++++active called!");
}

bool ProgressItem::isDoneHome() const
{
  return m_doneAtHome;
}

void ProgressItem::setIsDoneHome(const bool &home)
{
  m_doneAtHome = home;
  emit isDoneHomeChanged();
}

QDateTime ProgressItem::timeStamp() const
{
  return m_timeStamp;
}

void ProgressItem::setTimeStamp(const QDateTime &time)
{
  m_timeStamp = time;
  emit timeStampChanged();
}

qint64 ProgressItem::workInSeconds() const
{
  return m_workInSeconds;
}

void ProgressItem::setWorkInSeconds(const qint64 seconds)
{
  if( seconds>=0 )
    m_workInSeconds = seconds;
  else
    m_workInSeconds = 0;
  emit workInSecondsChanged();
}

QString ProgressItem::summary() const
{
  return m_summaryText;
}

void ProgressItem::setSummary(const QString &text)
{
  m_summaryText = text;
  emit summaryChanged();
}
