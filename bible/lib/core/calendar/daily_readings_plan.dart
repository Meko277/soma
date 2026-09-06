import '../../models/daily_reading.dart';

// ================================================================
// DAILY READINGS PLAN
//
// Deterministic per-day rotation so EVERY day has its own
// set of readings (Psalm, Pauline, Catholic, Praxis, Gospel).
//
// Each passage carries the book id + chapter so tapping it
// opens the actual chapter in the Bible reader.
// ================================================================

/// A single openable scripture passage.
class Passage {
  const Passage({
    required this.bookId,
    required this.chapter,
    required this.reference,
    this.excerpt = '',
    this.excerptAr,
  });

  final String bookId;
  final int chapter;
  final String reference;
  final String excerpt;
  final String? excerptAr;
}

/// Well-known psalm openings (by psalm number).
const Map<int, (String, String)> _famousPsalms = {
  1: (
    'Blessed is the man who walks not in the counsel of the wicked.',
    'طوبى للرجل الذي لم يسلك في مشورة الأشرار.',
  ),
  23: (
    'The Lord is my shepherd; I shall not want.',
    'الرب راعيَّ فلا يعوزني شيء.',
  ),
  27: (
    'The Lord is my light and my salvation; whom shall I fear?',
    'الرب نوري وخلاصي ممن أخاف؟',
  ),
  46: (
    'God is our refuge and strength, a very present help in trouble.',
    'الله لنا ملجأ وقوة، عونًا في الشدات وجدًا.',
  ),
  51: (
    'Have mercy on me, O God, according to your steadfast love.',
    'ارحمني يا الله حسب رحمتك الكثيرة.',
  ),
  91: (
    'He who dwells in the shelter of the Most High will abide in his shadow.',
    'الساكن في ستر العليّ في ظل القدير يبيت.',
  ),
  103: (
    'Bless the Lord, O my soul, and forget not all his benefits.',
    'باركي يا نفسي الرب وكل ما في داخلي اسم قدوسه.',
  ),
  121: (
    'I lift up my eyes to the hills; from where does my help come?',
    'رفعت عينيّ إلى الجبال، من أين يأتي عوني؟',
  ),
  119: (
    'Your word is a lamp to my feet and a light to my path.',
    'سراج لرجلي كلامك ونور لسبيلي.',
  ),
};

/// Pauline epistle passages (cycled daily).
const List<Passage> paulinePassages = [
  Passage(
    bookId: 'romans',
    chapter: 8,
    reference: 'Romans 8:28-39',
    excerpt:
        'All things work together for good to those who love God.',
    excerptAr: 'كل الأشياء تعمل معًا للخير للذين يحبون الله.',
  ),
  Passage(
    bookId: '1-corinthians',
    chapter: 13,
    reference: '1 Corinthians 13:1-13',
    excerpt: 'Love is patient, love is kind.',
    excerptAr: 'المحبة تتأنى وترفق.',
  ),
  Passage(
    bookId: '2-corinthians',
    chapter: 4,
    reference: '2 Corinthians 4:16-18',
    excerpt: 'Our light momentary affliction prepares an eternal weight of glory.',
    excerptAr: 'شدتنا الخفيفة الحاضرة تُعدّ لنا مجدًا أزليًا.',
  ),
  Passage(
    bookId: 'galatians',
    chapter: 5,
    reference: 'Galatians 5:22-26',
    excerpt: 'The fruit of the Spirit is love, joy, peace.',
    excerptAr: 'أما ثمر الروح فهو محبة وفرح وسلام.',
  ),
  Passage(
    bookId: 'ephesians',
    chapter: 6,
    reference: 'Ephesians 6:10-18',
    excerpt: 'Be strong in the Lord and in the strength of his might.',
    excerptAr: 'تقووا في الرب وفي قوة عظمته.',
  ),
  Passage(
    bookId: 'philippians',
    chapter: 4,
    reference: 'Philippians 4:4-9',
    excerpt: 'Rejoice in the Lord always; again I will say, rejoice.',
    excerptAr: 'افرحوا في الرب كل حين. وأيضًا أقول افرحوا.',
  ),
  Passage(
    bookId: 'colossians',
    chapter: 3,
    reference: 'Colossians 3:12-17',
    excerpt:
        'Put on then, as chosen ones of God, compassion and kindness.',
    excerptAr: 'البسوا إذن كمختاري الله أحشاء الرحمة ولطفًا.',
  ),
  Passage(
    bookId: '1-thessalonians',
    chapter: 5,
    reference: '1 Thessalonians 5:16-24',
    excerpt: 'Rejoice always, pray without ceasing.',
    excerptAr: 'افرحوا كل حين. صلوا بلا انقطاع.',
  ),
  Passage(
    bookId: '2-thessalonians',
    chapter: 3,
    reference: '2 Thessalonians 3:3-5',
    excerpt: 'The Lord is faithful; he will strengthen you.',
    excerptAr: 'أما الرب فهو أمين، سيقويكم ويحرسكم.',
  ),
  Passage(
    bookId: '1-timothy',
    chapter: 6,
    reference: '1 Timothy 6:11-16',
    excerpt: 'Fight the good fight of the faith.',
    excerptAr: 'جاهد الجهد الجميل للإيمان.',
  ),
  Passage(
    bookId: '2-timothy',
    chapter: 1,
    reference: '2 Timothy 1:6-14',
    excerpt: 'Fan into flame the gift of God which is in you.',
    excerptAr: 'أوقِد نار موهبة الله التي فيك.',
  ),
  Passage(
    bookId: 'titus',
    chapter: 2,
    reference: 'Titus 2:11-14',
    excerpt: 'The grace of God has appeared, bringing salvation.',
    excerptAr: 'لقد ظهرت نعمة الله الخلاصة للجميع.',
  ),
  Passage(
    bookId: 'philemon',
    chapter: 1,
    reference: 'Philemon 1:4-7',
    excerpt: 'I thank my God always when I remember you in my prayers.',
    excerptAr: 'أشكر إلهي كلما ذكرتك في صلواتي.',
  ),
  Passage(
    bookId: 'hebrews',
    chapter: 11,
    reference: 'Hebrews 11:1-6',
    excerpt: 'Faith is the assurance of things hoped for.',
    excerptAr: 'الإيمان هو وقاية الأمور المنتظرة.',
  ),
  Passage(
    bookId: 'hebrews',
    chapter: 12,
    reference: 'Hebrews 12:1-3',
    excerpt: 'Let us run with endurance the race set before us.',
    excerptAr: 'فلنجري بمثابرة السباق الموضوع أمامنا.',
  ),
];

/// Catholic epistle passages (cycled daily).
const List<Passage> catholicPassages = [
  Passage(
    bookId: 'james',
    chapter: 1,
    reference: 'James 1:2-8',
    excerpt: 'Count it all joy when you meet trials.',
    excerptAr: 'احسبوه فرحًا كلما وقعتم في تجارب.',
  ),
  Passage(
    bookId: 'james',
    chapter: 3,
    reference: 'James 3:13-18',
    excerpt: 'The wisdom from above is first pure, then peaceable.',
    excerptAr: 'الحكمة النازلة من فوق أولًا نقية ثم مسالمة.',
  ),
  Passage(
    bookId: '1-peter',
    chapter: 1,
    reference: '1 Peter 1:13-25',
    excerpt: 'Be holy in all your conduct.',
    excerptAr: 'كونوا قديسين في جميع التسلك.',
  ),
  Passage(
    bookId: '1-peter',
    chapter: 4,
    reference: '1 Peter 4:7-11',
    excerpt: 'Above all, keep loving one another earnestly.',
    excerptAr: 'وأولًا من كل شيء، احتفظوا بمحبتكم لبعضكم البعض بجد.',
  ),
  Passage(
    bookId: '2-peter',
    chapter: 1,
    reference: '2 Peter 1:2-11',
    excerpt: 'His divine power has granted us all things for life and godliness.',
    excerptAr: 'قدرته الإلهية قد وهبتنا كل ما يخص الحياة والتقوى.',
  ),
  Passage(
    bookId: '1-john',
    chapter: 1,
    reference: '1 John 1:5-10',
    excerpt: 'God is light, and in him is no darkness at all.',
    excerptAr: 'الله نور وفيه لا يوجد ظلمة على الإطلاق.',
  ),
  Passage(
    bookId: '1-john',
    chapter: 4,
    reference: '1 John 4:7-12',
    excerpt: 'Beloved, let us love one another, for love is from God.',
    excerptAr: 'أيها الأحباء، لنحب بعضنا بعضًا لأن المحبة هي من الله.',
  ),
  Passage(
    bookId: '2-john',
    chapter: 1,
    reference: '2 John 1:4-6',
    excerpt: 'Walk according to his commandments; this is love.',
    excerptAr: 'أن تسلكوا بحسب وصاياه؛ هذه هي المحبة.',
  ),
  Passage(
    bookId: '3-john',
    chapter: 1,
    reference: '3 John 1:2-4',
    excerpt: 'Beloved, I pray that you may prosper in health.',
    excerptAr: 'يا أيها الحبيب، أصلي أن تنجح في كل شيء وتصح.',
  ),
  Passage(
    bookId: 'jude',
    chapter: 1,
    reference: 'Jude 1:20-25',
    excerpt: 'Build yourselves up in your most holy faith.',
    excerptAr: 'ابنوا أنفسكم على إيمانكم الأقدس.',
  ),
];

/// Gospel passages (cycled daily).
const List<Passage> gospelPassages = [
  Passage(
    bookId: 'matthew',
    chapter: 5,
    reference: 'Matthew 5:1-16',
    excerpt: 'Blessed are the poor in spirit, for theirs is the kingdom.',
    excerptAr: 'طوبى للمساكين بالروح، لأن لهم ملكوت السماوات.',
  ),
  Passage(
    bookId: 'matthew',
    chapter: 6,
    reference: 'Matthew 6:25-34',
    excerpt: 'Do not be anxious about tomorrow.',
    excerptAr: 'لا تهتموا لحياتكم بما تأكلون... ولا للغد.',
  ),
  Passage(
    bookId: 'matthew',
    chapter: 11,
    reference: 'Matthew 11:28-30',
    excerpt: 'Come to me, all who labor and are heavy laden.',
    excerptAr: 'تعالوا إليّ يا جميع المتعبين والثقيلي الأحمال.',
  ),
  Passage(
    bookId: 'matthew',
    chapter: 25,
    reference: 'Matthew 25:31-46',
    excerpt: 'As you did it to one of the least of these, you did it to me.',
    excerptAr: 'ما فعلتموه بأحد إخوتي هؤلاء الصغار فقد فعلتموه بي.',
  ),
  Passage(
    bookId: 'mark',
    chapter: 4,
    reference: 'Mark 4:35-41',
    excerpt: 'Peace! Be still! And the wind ceased.',
    excerptAr: 'اسكت! اخرس! وسكن الريح.',
  ),
  Passage(
    bookId: 'mark',
    chapter: 10,
    reference: 'Mark 10:46-52',
    excerpt: 'Jesus said, "Go your way; your faith has made you well."',
    excerptAr: 'قال له يسوع: اذهب، إيمانك قد شفاك.',
  ),
  Passage(
    bookId: 'luke',
    chapter: 10,
    reference: 'Luke 10:25-37',
    excerpt: 'Go and do likewise (the Good Samaritan).',
    excerptAr: 'اذهب وأنت افعل مثل ذلك (السامري الصالح).',
  ),
  Passage(
    bookId: 'luke',
    chapter: 15,
    reference: 'Luke 15:11-24',
    excerpt: 'This my son was dead, and is alive again.',
    excerptAr: 'هذا ابني كان ميتًا وقد عاش.',
  ),
  Passage(
    bookId: 'luke',
    chapter: 18,
    reference: 'Luke 18:35-43',
    excerpt: 'Receive your sight; your faith has made you well.',
    excerptAr: 'استبصر، إيمانك قد شفاك.',
  ),
  Passage(
    bookId: 'luke',
    chapter: 24,
    reference: 'Luke 24:13-35',
    excerpt: 'Did not our hearts burn within us on the road?',
    excerptAr: 'ألم يكن قلبانا متوقدًا فينا في الطريق؟',
  ),
  Passage(
    bookId: 'john',
    chapter: 1,
    reference: 'John 1:1-14',
    excerpt: 'In the beginning was the Word.',
    excerptAr: 'في البدء كان الكلمة.',
  ),
  Passage(
    bookId: 'john',
    chapter: 3,
    reference: 'John 3:16-21',
    excerpt: 'For God so loved the world that he gave his only Son.',
    excerptAr: 'لأنه هكذا أحب الله العالم حتى بذل ابنه الوحيد.',
  ),
  Passage(
    bookId: 'john',
    chapter: 6,
    reference: 'John 6:35-40',
    excerpt: 'I am the bread of life.',
    excerptAr: 'أنا هو خبز الحياة.',
  ),
  Passage(
    bookId: 'john',
    chapter: 10,
    reference: 'John 10:11-18',
    excerpt: 'I am the good shepherd; I lay down my life for the sheep.',
    excerptAr: 'أنا هو الراعي الصالح، وأبذل نفسي من أجل الخروفان.',
  ),
  Passage(
    bookId: 'john',
    chapter: 14,
    reference: 'John 14:1-6',
    excerpt: 'I am the way, and the truth, and the life.',
    excerptAr: 'أنا هو الطريق والحقيقة والحياة.',
  ),
  Passage(
    bookId: 'john',
    chapter: 15,
    reference: 'John 15:1-8',
    excerpt: 'I am the vine; you are the branches.',
    excerptAr: 'أنا هو الكرمة وأنتم الأغصان.',
  ),
];

/// Builds the five readings for [date]. The selection is
/// deterministic per calendar day, so every day gets its
/// own unique plan.
List<DailyReading> buildDailyReadings(DateTime date) {
  final dayOfYear =
      date.difference(DateTime(date.year, 1, 1)).inDays;

  // ------------------------------------------------------------
  // PSALM - cycles through all 150 psalms.
  // ------------------------------------------------------------

  final psalmNumber = (dayOfYear % 150) + 1;

  final famousPsalm = _famousPsalms[psalmNumber];

  // ------------------------------------------------------------
  // PAULINE / CATHOLIC / GOSPEL - curated rotations.
  // ------------------------------------------------------------

  final pauline =
      paulinePassages[dayOfYear % paulinePassages.length];

  final catholic = catholicPassages[
      dayOfYear % catholicPassages.length];

  final gospel =
      gospelPassages[dayOfYear % gospelPassages.length];

  // ------------------------------------------------------------
  // PRAXIS - cycles through the whole book of Acts.
  // ------------------------------------------------------------

  final actsChapter = (dayOfYear % 28) + 1;

  return [
    // Psalm - sung by THE PEOPLE.
    DailyReading(
      title: 'Psalm',
      titleAr: 'المزمور',
      reference: 'Psalm $psalmNumber',
      excerpt: famousPsalm?.$1 ?? '',
      excerptAr: famousPsalm?.$2,
      bookId: 'psalms',
      chapter: psalmNumber,
      readBy: ReadingRole.people,
    ),

    // Pauline Epistle - read by THE DEACONS.
    DailyReading(
      title: 'Pauline Epistle',
      titleAr: 'البولس',
      reference: pauline.reference,
      excerpt: pauline.excerpt,
      excerptAr: pauline.excerptAr,
      bookId: pauline.bookId,
      chapter: pauline.chapter,
      readBy: ReadingRole.deacons,
    ),

    // Catholic Epistle - read by THE DEACONS.
    DailyReading(
      title: 'Catholic Epistle',
      titleAr: 'الكاثوليكون',
      reference: catholic.reference,
      excerpt: catholic.excerpt,
      excerptAr: catholic.excerptAr,
      bookId: catholic.bookId,
      chapter: catholic.chapter,
      readBy: ReadingRole.deacons,
    ),

    // Praxis (Acts) - read by THE DEACONS.
    DailyReading(
      title: 'Praxis',
      titleAr: 'الإبركسيس',
      reference: 'Acts $actsChapter',
      bookId: 'acts',
      chapter: actsChapter,
      readBy: ReadingRole.deacons,
    ),

    // Gospel - read by THE PRIESTS.
    DailyReading(
      title: 'Gospel',
      titleAr: 'الإنجيل',
      reference: gospel.reference,
      excerpt: gospel.excerpt,
      excerptAr: gospel.excerptAr,
      bookId: gospel.bookId,
      chapter: gospel.chapter,
      readBy: ReadingRole.priests,
    ),
  ];
}
