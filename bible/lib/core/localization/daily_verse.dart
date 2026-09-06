// ================================================================
// DAILY VERSE (آية اليوم)
//
// The verse of the day is ALWAYS shown in ARABIC and titled
// "آية اليوم" regardless of the interface language - this is a
// deliberate product decision (the Arabic Van Dyke text is the
// most widely used version in our community).
//
// A different verse is selected every day by rotating through
// the list below using the day of the year, so the selection is:
//   - stable for the whole day,
//   - different on consecutive days,
//   - deterministic (no randomness -> same verse on all devices).
// ================================================================

class DailyVerse {
  const DailyVerse({required this.text, required this.reference});

  /// Arabic verse text (Van Dyke translation).
  final String text;

  /// Arabic reference, e.g. 'مزمور ٢٣: ١'.
  final String reference;
}

class DailyVerseRepository {
  const DailyVerseRepository._();

  static const List<DailyVerse> _verses = [
    DailyVerse(
      text:
          '«لأنّه هكذا أحبّ الله العالم حتّى بذل ابنه الوحيد، لكي لا يهلك كلّ من يؤمن به، بلّ تكون له الحياة الأبدية.»',
      reference: 'يوحنا ٣: ١٦',
    ),
    DailyVerse(
      text: '«الربّ راعيَّ فلا يعوزني شيء.»',
      reference: 'مزمور ٢٣: ١',
    ),
    DailyVerse(
      text: '«سراجًا لرجلي كلامك ونورًا لسبيلي.»',
      reference: 'مزمور ١١٩: ١٠٥',
    ),
    DailyVerse(
      text: '«توكّل على الرحمن بكلّ قلبك، وعلى فهمك لا تعتمّد.»',
      reference: 'أمثال ٣: ٥',
    ),
    DailyVerse(
      text:
          '«لا تخفْ لأنّي معك، لا تتلفّتْ لأنّي إلهك. قد أياستك، وقد أعنتك، وأعتمدك بيمين برّي.»',
      reference: 'إشعياء ٤١: ١٠',
    ),
    DailyVerse(
      text: '«أستطيع كلّ شيء في المسيح الذي يقويّني.»',
      reference: 'فيلبي ٤: ١٣',
    ),
    DailyVerse(
      text: '«تعالوا إليّ يا جميع المتعبين والثقيلي الأحمال وأنا أُريحكم.»',
      reference: 'متى ١١: ٢٨',
    ),
    DailyVerse(
      text: '«الله ملجأنا وقوّتنا. عونًا في الضنوك وجدنا سرًّا.»',
      reference: 'مزمور ٤٦: ٢',
    ),
    DailyVerse(
      text:
          '«ألمْ أوصكْ؟ فتقوىّ وتتشجّعْ. لا ترهَبْ ولا تنجُزْ لأنّ الربّ إلهك معك حيثما حللتْ.»',
      reference: 'يوشع ١: ٩',
    ),
    DailyVerse(
      text: '«ونحن نعلم أنّ كلّ الأشياء تعمل معًا للخير للذين يحبّون الله.»',
      reference: 'رومية ٨: ٢٨',
    ),
    DailyVerse(
      text: '«في جميع طرقك اعرفه، وهو يقوم سبلك.»',
      reference: 'أمثال ٣: ٦',
    ),
    DailyVerse(
      text:
          '«لأني أعرف الأفكار التي أنا مفكّرٌ بها عنكم، قال الرحمن، أفكار سلامٍ لا شرّ، لأعطيكم آخرًا وأملًا.»',
      reference: 'إرميا ٢٩: ١١',
    ),
    DailyVerse(
      text: '«الربّ نوري وخلاصي، ممّن أخاف؟»',
      reference: 'مزمور ٢٧: ١',
    ),
    DailyVerse(
      text:
          '«وأما المنتظرون الربّ فيجدّدون قوّتهم، يرفعون أجنحة كالنسور، يجرون ولا يتعبون، يسيرون ولا يعياون.»',
      reference: 'إشعياء ٤٠: ٣١',
    ),
    DailyVerse(
      text: '«ولكن اطلبوا أوّلًا ملكوت الله وبرّه، وهذه كلّها تزاد لكم.»',
      reference: 'متى ٦: ٣٣',
    ),
    DailyVerse(
      text:
          '«لأنّه بالنّعمة أنتم مخلّوصين، بواسطة الإيمان. وذلك ليس منكم، بلّ عطيّة الله.»',
      reference: 'أفسس ٢: ٨',
    ),
    DailyVerse(
      text: '«سلّم للرحمن طريقك وارتجّ إليه وهو يتمّم.»',
      reference: 'مزمور ٣٧: ٥',
    ),
    DailyVerse(
      text:
          '«أمّا الآن فيثبت الإيمان والرجاء والمحبة، هذه الثلاثة، ولكنّ أعظمهنّ المحبة.»',
      reference: '١كورنثوس ١٣: ١٣',
    ),
    DailyVerse(
      text: '«هذا هو اليوم الذي صنعه الربّ. فلننفرحْ ونتهلّلْ فيه.»',
      reference: 'مزمور ١١٨: ٢٤',
    ),
    DailyVerse(text: '«يومٌ خائفٌ أنا فيك أتوكّل.»', reference: 'مزمور ٥٦: ٤'),
    DailyVerse(
      text:
          '«المتمسّك بالفكّرة متوكِّلًا عليك تحفظه سلامًا سلامًا لأنّه اتكّل عليك.»',
      reference: 'إشعياء ٢٦: ٣',
    ),
    DailyVerse(
      text: '«ذوقوا وانظروا ما أطيبَ الرحمن! طوبى للرجل المتوكّل عليه.»',
      reference: 'مزمور ٣٤: ٩',
    ),
    DailyVerse(
      text: '«قلبًا نقيًا اخلق فيّ يا الله، وروحًا مستقيمًا جدّده في أحشائي.»',
      reference: 'مزمور ٥٠: ١٢',
    ),
    DailyVerse(
      text:
          '«أرفع عينيّ إلى الجبال، من أين يأتي عوني؟ العون من عند الرحمن الذي صنع السماء والأرض.»',
      reference: 'مزمور ١٢٠: ١',
    ),
    DailyVerse(
      text: '«في قلبي أخبيتْ قولك حتى لا أخطئ إليك.»',
      reference: 'مزمور ١١٨: ١١',
    ),
    DailyVerse(
      text:
          '«فليضئْ نوركم هكذا قدّام الناس، لكي يروا أعمالكم الحسنة، ويمجّدوا أباكم الذي في السماء.»',
      reference: 'متى ٥: ١٦',
    ),
    DailyVerse(
      text:
          '«ولا تشابهوا مع هذا الدهر، بلّ تبدّلوا بتجديد ذهنكم، لتُجرِّبوا ما هي مشيئة الله، الصالحة المرضيّة الكاملة.»',
      reference: 'رومية ١٢: ٢',
    ),
    DailyVerse(
      text:
          '«والإيمان هو الأساس للأشياء المرجوّة والدليل للأشياء غير المنظورة.»',
      reference: 'عبرانيين ١١: ١',
    ),
    DailyVerse(
      text:
          '«وإن كان أحدكم ينقص حكمةً فليطلبْ من الله الذي يعطي الجميع بساطة ولا يعيّر، فيُعطى له.»',
      reference: 'يعقوب ١: ٥',
    ),
    DailyVerse(
      text: '«طرحًا كلّ همّكم عليه لأنّه هو يعتني بكم.»',
      reference: '١بطرس ٥: ٧',
    ),
    DailyVerse(
      text:
          '«الساكن في ستر العليّ في ظلّ القدير يبيت. أقول للرحمن: ملجإي وحصني، إلهي فأتوكّل عليه.»',
      reference: 'مزمور ٩٠: ١',
    ),
    DailyVerse(
      text: '«اضطرِع أعمالك إلى الربّ فتثبت مشاريعك.»',
      reference: 'أمثال ١٦: ٣',
    ),
    DailyVerse(
      text: '«لا بقدرة ولا بقوّة، بل بروحي قال ربّ الجنود.»',
      reference: 'زكريا ٤: ٦',
    ),
    DailyVerse(
      text: '«البكاء يدوم سهرًا، والفرح يصبح.»',
      reference: 'مزمور ٢٩: ٦',
    ),
    DailyVerse(
      text: '«ألقِ على الربّ ما يعطيك، وهو يعضدك.»',
      reference: 'مزمور ٥٤: ٢٣',
    ),
    DailyVerse(
      text: '«لا تخفْ فإني فديتك، دعوتك باسمك، أنت لي.»',
      reference: 'إشعياء ٤٣: ١',
    ),
    DailyVerse(
      text: '«طوبى من له إله يعقوب عونًا، رجاؤه على الرحمن إلهه.»',
      reference: 'مزمور ١٤٥: ٥',
    ),
    DailyVerse(
      text: '«إنّ المحبة من عند الله، وكلّ محبٍّ ولد من الله ويعرف الله.»',
      reference: '١يوحنا ٤: ٧',
    ),
  ];

  /// Number of verses in the rotation.
  static int get count => _verses.length;

  /// Returns the verse for [date] (defaults to today).
  ///
  /// The same date always returns the same verse, and
  /// consecutive days move forward in the rotation.
  static DailyVerse forDate([DateTime? date]) {
    final effective = date ?? DateTime.now();

    final dayOfYear = DateTime(
      effective.year,
      effective.month,
      effective.day,
    ).difference(DateTime(effective.year)).inDays;

    return _verses[dayOfYear % _verses.length];
  }

  /// Today's verse.
  static DailyVerse get today => forDate();
}
