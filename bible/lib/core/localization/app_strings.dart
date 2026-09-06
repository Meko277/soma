import '../preferences/app_preferences.dart';

class AppStrings {
  const AppStrings(this.language);

  final AppLanguage language;

  bool get isArabic => language == AppLanguage.arabic;

  String get home => isArabic ? 'الرئيسية' : 'Home';

  String get bible => isArabic ? 'الكتاب المقدس' : 'Bible';

  String get church => isArabic ? 'الكنيسة' : 'Church';

  String get today => isArabic ? 'اليوم' : 'Today';

  // ----------------------------------------------------------
  // القداس (memorial prayer / the holy liturgy)
  // ----------------------------------------------------------

  String get liturgy => isArabic ? 'القداس' : 'The Liturgy';

  String get liturgyCardTitle =>
      isArabic ? 'القداس الإلهي' : 'The Holy Liturgy';

  String get liturgyDescription => isArabic
      ? 'صلاة الذكرى • القداس الإلهي'
      : 'Memorial prayer • The Holy Liturgy';

  String get moreTodaySubtitle => isArabic
      ? 'قراءات اليوم والقديس والتقويم القبطي'
      : "Today's readings, saint & Coptic calendar";

  String get presentationExitLabel =>
      isArabic ? 'خروج من وضع العرض' : 'Exit presentation';

  // ----------------------------------------------------------
  // Liturgy kinds chooser + section reader labels
  // ----------------------------------------------------------

  String get liturgyChooseTitle =>
      isArabic ? 'اختر نوع القداس' : 'Choose the Liturgy';

  String get liturgyChooseSubtitle => isArabic
      ? 'ثلاثة أقانيم تختارها الكنيسة بحسب المناسبة'
      : 'Three anaphoras chosen according to the season';

  String get basilName =>
      isArabic ? 'قداس الباسيلي' : 'Liturgy of St. Basil';

  String get basilSubtitle => isArabic
      ? 'الأكثر استخدامًا على مدار السنة'
      : 'Used most days of the year';

  String get gregoryName => isArabic
      ? 'قداس الغريغوري'
      : 'Liturgy of St. Gregory';

  String get gregorySubtitle => isArabic
      ? 'في أعياد الرب المقدسة'
      : 'On feasts of our Lord';

  String get cyrilName => isArabic
      ? 'القداس الكيرلسي (القبطي)'
      : 'The Coptic Liturgy of St. Cyril';

  String get cyrilSubtitle => isArabic
      ? 'في الصوم الكبير وصوم نينوى'
      : 'During Great Lent and the Nineveh fast';

  String get readerPriest =>
      isArabic ? 'الكاهن' : 'The Priest';

  String get readerDeacons =>
      isArabic ? 'الشمامسة' : 'The Deacons';

  String get readerPeople =>
      isArabic ? 'الشعب' : 'The Congregation';

  String get readerAll => isArabic ? 'الجميع' : 'Everyone';

  String get readByPrefix =>
      isArabic ? 'يقرؤها' : 'Read by';

  String get audio => isArabic ? 'الصوتيات' : 'Audio';

  String get more => isArabic ? 'المزيد' : 'More';

  String get settings => isArabic ? 'الإعدادات' : 'Settings';

  String get languageTitle => isArabic ? 'اللغة' : 'Language';

  String get appearance => isArabic ? 'المظهر' : 'Appearance';

  String get calendar => isArabic ? 'التقويم القبطي' : 'Coptic Calendar';

  String get dailyReadings => isArabic ? 'قراءات اليوم' : 'Daily readings';

  String get searchBible =>
      isArabic ? 'ابحث في أسفار الكتاب المقدس' : 'Search Bible books';

  String get managedChapters =>
      isArabic ? 'الفصول المُدارة' : 'Managed chapters';

  String get library => isArabic ? 'المكتبة' : 'Library';

  String get readOffline => isArabic
      ? 'اقرأ الكتاب المقدس دون اتصال باللغة التي تختارها.'
      : 'Read Scripture offline in your preferred display language.';

  String get peaceAndBlessing => isArabic ? 'سلام وبركة' : 'Peace and blessing';

  // ----------------------------------------------------------
  // DAILY VERSE (آية اليوم)
  //
  // The verse of the day is ALWAYS Arabic - both the title and
  // the content - regardless of the interface language. The
  // verse text itself comes from DailyVerseRepository.
  // ----------------------------------------------------------

  String get dailyVerse => 'آية اليوم';

  String get quickAccess => isArabic ? 'وصول سريع' : 'Quick access';

  String get bibleDescription => isArabic
      ? 'اقرأ الكتاب المقدس باللغة التي اخترتها'
      : 'Read Scripture in your chosen language';

  String get agpeya => isArabic ? 'الأجبية' : 'Agpeya';

  String get agpeyaDescription =>
      isArabic ? 'صلِّ الساعات القانونية' : 'Pray the canonical hours';

  String get audioDescription =>
      isArabic ? 'تابع الاستماع' : 'Continue listening';

  String get readingsDescription => isArabic
      ? 'مزمور، البولس، الكاثوليكون، الإبركسيس والإنجيل'
      : 'Psalm, Pauline, Catholic, Praxis and Gospel';

  String get calendarDescription =>
      isArabic ? 'اعرض أي تاريخ' : 'View any date';

  String get continueReading =>
      isArabic ? 'متابعة القراءة' : 'Continue reading';

  String get continueReadingSubtitle =>
      isArabic ? 'أكمل من حيث توقفت' : 'Pick up where you left off';

  String get noBooksFound => isArabic ? 'لا توجد أسفار' : 'No books found';

  /// Label under the chapter count number.
  String get chaptersCountLabel => isArabic ? 'أصحاح' : 'Chapters';

  String get copticDateLabel => isArabic ? 'التاريخ القبطي' : 'Coptic Date';

  String get seasonLabel => isArabic ? 'الموسم' : 'Season';

  String get fastLabel => isArabic ? 'الصوم' : 'Fast';

  String get saintLabel => isArabic ? 'القديس' : 'Saint';

  // ----------------------------------------------------------
  // READER ROLES (who reads each part)
  // ----------------------------------------------------------

  String get readByPeople => isArabic ? 'يقرؤها الشعب' : 'Read by the People';

  String get readByDeacons =>
      isArabic ? 'يقرؤها الشمامسة' : 'Read by the Deacons';

  String get readByPriests =>
      isArabic ? 'يقرؤها الكهنة' : 'Read by the Priests';

  // ----------------------------------------------------------
  // NOTIFICATION TIME
  // ----------------------------------------------------------

  String get notificationTimeTitle =>
      isArabic ? 'وقت الإشعار اليومي' : 'Daily Notification Time';

  String get notificationTimeSubtitle => isArabic
      ? 'اختر الوقت الذي تفضل استلام خطة اليوم فيه'
      : 'Choose when to receive your daily plan';

  // ----------------------------------------------------------
  // MORE PAGE
  // ----------------------------------------------------------

  String get moreCalendarSubtitle => isArabic
      ? 'أعياد وأصوام وقديسين وقراءات'
      : 'Feasts, fasts, saints and readings';

  String get moreAppearanceSubtitle =>
      isArabic ? 'بيج، أزرق، ومظهر النظام' : 'Beige, blue, and system themes';

  String get moreLanguageSubtitle =>
      isArabic ? 'لغة الواجهة ولغة المحتوى' : 'Interface and content language';

  String get moreAdminTitle =>
      isArabic ? 'إدارة محتوى الكتاب المقدس' : 'Bible Content Admin';

  String get moreAdminSubtitle => isArabic
      ? 'إدارة أصحاح الكتاب المقدس دون اتصال'
      : 'Manage offline Bible chapters';

  String get moreBookmarksTitle => isArabic ? 'العلامات المرجعية' : 'Bookmarks';

  String get moreBookmarksSubtitle =>
      isArabic ? 'آيات وصلوات ومستندات' : 'Verses, prayers, and documents';

  String get moreSearchTitle => isArabic ? 'البحث' : 'Search';

  String get moreSearchSubtitle =>
      isArabic ? 'ابحث في مكتبتك دون اتصال' : 'Search your offline library';

  // ----------------------------------------------------------
  // COPTIC TRANSLATOR
  // ----------------------------------------------------------

  String get translator => isArabic ? 'المترجم القبطي' : 'Coptic Translator';

  String get translatorSubtitle => isArabic
      ? 'قاموس قبطي – عربي كامل مع لوحة مفاتيح قبطية'
      : 'Full Coptic–Arabic dictionary with a Coptic keyboard';

  String get translateHintCoptic =>
      isArabic ? 'اكتب باللغة القبطية…' : 'Type in Coptic…';

  String get translateHintArabic =>
      isArabic ? 'اكتب بالعربية…' : 'Type in Arabic…';

  String get copticKeyboard =>
      isArabic ? 'لوحة المفاتيح القبطية' : 'Coptic Keyboard';

  String get translateResultTitle => isArabic ? 'الترجمة' : 'Translation';

  String get notInDictionary =>
      isArabic ? 'غير موجودة في القاموس' : 'Not in dictionary';

  String get spaceKey => isArabic ? 'مسافة' : 'space';

  String get translatorLoading =>
      isArabic ? 'جارٍ الترجمة…' : 'Translating…';

  String get translatorEmptyHint => isArabic
      ? 'اكتب كلمة أو عبارة للترجمة'
      : 'Type a word or phrase to translate';

  String get translatorSourceOffline => isArabic
      ? 'القاموس المحلي (يعمل دون اتصال)'
      : 'Offline dictionary (works offline)';

  String get translatorSourceOnline =>
      isArabic ? 'خدمة الترجمة عبر الإنترنت' : 'Online translation service';

  String get translatorErrorNetwork => isArabic
      ? 'تعذّر الوصول إلى خدمة الترجمة. تحقّق من اتصالك بالإنترنت وحاول مجددًا.'
      : 'Could not reach the translation service. Check your connection and try again.';

  String get translatorRetry => isArabic ? 'إعادة المحاولة' : 'Retry';

  // ----------------------------------------------------------
  // READING DISPLAY MODES
  // ----------------------------------------------------------

  String get readingDisplayTitle =>
      isArabic ? 'عرض القراءة' : 'Reading Display';

  String get displaySingleLabel => isArabic
      ? 'لغة واحدة (حسب إعدادات المحتوى)'
      : 'One language (content setting)';

  String get displayEnAr =>
      isArabic ? 'English ثم العربية' : 'English + العربية';

  String get displayArEn =>
      isArabic ? 'العربية ثم English' : 'العربية + English';

  String get displayCoptAr =>
      isArabic ? 'القبطية ثم العربية' : 'Ⲙⲉⲧⲣⲉⲙ̀ⲛⲭⲏⲙⲓ + العربية';

  String get displayCoptEn =>
      isArabic ? 'القبطية ثم English' : 'Ⲙⲉⲧⲣⲉⲙ̀ⲛⲭⲏⲙⲓ + English';

  String get displayAllLabel =>
      isArabic ? 'الكل: عربي + إنجليزي + قبطي' : 'All: EN + AR + Coptic';

  String get copticNotAvailable => isArabic
      ? 'النص القبطي غير متوفر بعد — سيُضاف قريبًا'
      : 'Coptic text not added yet — coming soon';

  // ----------------------------------------------------------
  // PRESENTATION MODE
  // ----------------------------------------------------------

  String get presentationModeTitle =>
      isArabic ? 'وضع العرض التقديمي' : 'Presentation Mode';

  String get presentationModeSubtitle => isArabic
      ? 'في الوضع الأفقي: خلفية سوداء وآية واحدة في كل شاشة، واسحب للتنقل'
      : 'In landscape: black background, one verse per screen — swipe to navigate';

  String get versionLabelEnglish => isArabic ? 'الإنجليزية' : 'English';

  String get versionLabelArabic => isArabic ? 'العربية' : 'Arabic';

  String get versionLabelCoptic => isArabic ? 'القبطية' : 'Coptic';

  // ----------------------------------------------------------
  // TODAY PAGE
  // ----------------------------------------------------------

  String get todayGuideTitle => isArabic ? 'دليل اليوم' : 'Daily guide';

  String get openCalendar => isArabic ? 'افتح التقويم' : 'Open calendar';

  String get chooseDifferentDay =>
      isArabic ? 'اختر يومًا آخر' : 'Choose a different day';

  // ----------------------------------------------------------
  // CALENDAR PAGE
  // ----------------------------------------------------------

  String get gregorianDateLabel =>
      isArabic ? 'التاريخ الميلادي' : 'Gregorian date';

  String get readingsLabel => isArabic ? 'القراءات' : 'Readings';

  /// Localizes a [LiturgicalSeason]-like enum value.
  String localizedSeasonName(String seasonToString) {
    switch (seasonToString) {
      case 'LiturgicalSeason.nativityFast':
        return isArabic ? 'صوم الميلاد' : 'Nativity Fast';

      case 'LiturgicalSeason.greatFast':
        return isArabic ? 'الصوم الكبير' : 'Great Fast';

      case 'LiturgicalSeason.holyWeek':
        return isArabic ? 'أسبوع الآلام' : 'Holy Week';

      case 'LiturgicalSeason.pentecost':
        return isArabic ? 'العنصرة' : 'Pentecost';

      default:
        return isArabic ? 'السنوي' : 'Annual';
    }
  }

  /// Localizes known fast names coming from the calendar
  /// service (English data), falling back to the input.
  String localizedFastName(String? fastName) {
    if (fastName == null || fastName.isEmpty) {
      return '';
    }

    switch (fastName) {
      case 'Nativity Fast':
        return isArabic ? 'صوم الميلاد' : fastName;

      case 'Great Fast':
        return isArabic ? 'الصوم الكبير' : fastName;

      case 'Holy Week Fast':
      case 'Holy Week':
        return isArabic ? 'صوم أسبوع الآلام' : fastName;

      case 'Apostles Fast':
        return isArabic ? 'صوم الرسل' : fastName;

      case 'Jonah Fast':
        return isArabic ? 'صوم نينوى' : fastName;

      default:
        return fastName;
    }
  }


  // ----------------------------------------------------------
  // TRANEEM (الترانيم)
  // ----------------------------------------------------------

  String get traneem => isArabic ? 'الترانيم' : 'Traneem';

  String get traneemHeading => isArabic ? 'الترانيم' : 'Traneem';

  String get traneemSubtitle => isArabic
      ? 'ألحان وكلمات ترانيم للقراءة دون اتصال'
      : 'Hymn lyrics and words for offline reading';

  String get searchTraneem =>
      isArabic ? 'ابحث في الترانيم…' : 'Search hymns…';

  String get noHymnsFound =>
      isArabic ? 'لا توجد ترانيم مطابقة' : 'No hymns match your search';

  String get hymnNotAvailable => isArabic
      ? 'هذا الترنيم غير متوفر بعد دون اتصال.'
      : 'This hymn is not available offline yet.';

  String get hymnNotFound => isArabic ? 'الترنيم غير موجود' : 'Hymn not found';

  String get backToTraneem => isArabic ? 'عودة إلى الترانيم' : 'Back to Traneem';

  // ----------------------------------------------------------
  // SAVED / BOOKMARKS (المحفوظات / العلامات المرجعية)
  // ----------------------------------------------------------

  String get savedTitle => isArabic ? 'المحفوظات' : 'Saved';

  String get savedEmptyTitle =>
      isArabic ? 'لا توجد عناصر محفوظة' : 'No saved items yet';

  String get savedEmptyBody => isArabic
      ? 'اضغط زر الحفظ أثناء القراءة لإضافة صفحة أو محتوى إلى المحفوظات.'
      : 'Tap the save button while reading to add a page or content to your saved items.';

  String get savedRemove => isArabic ? 'إزالة' : 'Remove';

  String get savedSaved => isArabic ? 'تم الحفظ' : 'Saved';

  String get savedSave => isArabic ? 'حفظ' : 'Save';

  String get savedUnsave => isArabic ? 'إلغاء الحفظ' : 'Unsave';

  // ----------------------------------------------------------
  // DAILY VERSE NOTIFICATION (آية اليوم)
  // ----------------------------------------------------------

  String get dailyVerseNotificationTitle => isArabic
      ? 'تنبيه آية اليوم'
      : 'Daily Verse Notification';

  String get dailyVerseNotificationSubtitle => isArabic
      ? 'أرسل آية اليوم يوميًا في وقتك المفضل'
      : 'Deliver the verse of the day daily at your preferred time';

  String get dailyVerseNotificationOffSubtitle => isArabic
      ? 'التنبيه اليومي لآية اليوم متوقف'
      : 'Daily verse notification is off';

  String get dailyVerseNotificationError => isArabic
      ? 'تعذّر تفعيل التنبيه — قد تحتاج إلى منح إذن الإشعارات'
      : 'Could not enable the notification — you may need to grant notification permission';


  // ----------------------------------------------------------
  // AUDIO PAGE
  // ----------------------------------------------------------

  String get audioIntro => isArabic
      ? 'الكتاب المقدس والصلوات والألحان والعظات والاستماع المحمّل.'
      : 'Bible, prayers, hymns, sermons, and downloaded listening.';

  String get continueListening =>
      isArabic ? 'متابعة الاستماع' : 'Continue listening';

  String get noAudioPlaying =>
      isArabic ? 'لا يوجد صوت قيد التشغيل' : 'No audio is currently playing';

  String get downloadedAudio =>
      isArabic ? 'الصوتيات المحمَّلة' : 'Downloaded audio';

  String get availableOffline =>
      isArabic ? 'متاح دون اتصال' : 'Available offline';

  String get playlists => isArabic ? 'قوائم التشغيل' : 'Playlists';

  String get playlistsSubtitle =>
      isArabic ? 'نظِّم استماعك الروحي' : 'Organize your spiritual listening';

  // ----------------------------------------------------------
  // LANGUAGE SETTINGS PAGE
  // ----------------------------------------------------------

  String get interfaceLanguageHeading =>
      isArabic ? 'لغة الواجهة' : 'Interface language';

  String get contentLanguageHeading =>
      isArabic ? 'لغة المحتوى' : 'Content language';

  // ----------------------------------------------------------
  // APPEARANCE SETTINGS PAGE
  // ----------------------------------------------------------

  String get themeHeading => isArabic ? 'المظهر' : 'Theme';

  String get themeBeige => isArabic ? 'بيج' : 'Beige';

  String get themeBeigeSubtitle => isArabic
      ? 'دفء الرقوق مع النبيتي والذهبي'
      : 'Warm parchment, burgundy, and gold';

  String get themeBlue => isArabic ? 'أزرق' : 'Blue';

  String get themeBlueSubtitle => isArabic
      ? 'كحلي غامق بنفس المكوّنات وأيقونات الهوية'
      : 'Deep navy with the same components and icon identity';

  String get themeSystem => isArabic ? 'حسب النظام' : 'System';

  String get themeSystemSubtitle =>
      isArabic ? 'يتبع مظهر الجهاز' : 'Follow device appearance';

  // ----------------------------------------------------------
  // LIBRARY / DOCUMENT READER / CHURCH
  // ----------------------------------------------------------

  String get documentNotAvailable => isArabic
      ? 'هذا المستند غير متوفر دون اتصال.'
      : 'This document is not available offline.';

  String get contentPacksTitle => isArabic ? 'حزم المحتوى' : 'Content packs';

  String get contentPacksBody => isArabic
      ? 'كتالوج البداية هذا جاهز لحزم محتوى الكتاب المقدس والأجبية والطقوس والألحان المعتمدة.'
      : 'This offline starter catalogue is ready for approved Bible, Agpeya, liturgy, and hymn content packs.';

  String get churchDescription => isArabic
      ? 'صلاة وعبادة وألحان وقديسين وطقوس وأسرار.'
      : 'Prayer, worship, hymns, saints, rites, and sacraments.';

  // ----------------------------------------------------------
  // BIBLE READER ERROR STATES
  // ----------------------------------------------------------

  String get unableToLoadChapter =>
      isArabic ? 'تعذَّر تحميل هذا الأصحاح.' : 'Unable to load this chapter.';

  String get bookNotFoundLabel =>
      isArabic ? 'لم يتم العثور على السفر' : 'Book not found';

  /// e.g. "تكوين ٣ لم يُضف بعد." / "Genesis 3 has not been added yet."
  String chapterNotAddedYet(String name, int number) => isArabic
      ? '$name $number لم يُضف بعد.'
      : '$name $number has not been added yet.';
}
