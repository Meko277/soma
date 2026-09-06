// ================================================================
// COPTIC ⇄ ARABIC LEXICON
//
// A curated, offline dictionary of well-attested Coptic
// (Sahidic/Bohairic) words and liturgical phrases with
// Arabic meanings. Powers the built-in translator:
//
//   - Exact phrase matches win first.
//   - Otherwise word-by-word lookup.
//
// Extend the lists freely — everything is data-driven.
// ================================================================

/// One dictionary entry.
class CopticEntry {
  const CopticEntry({
    required this.coptic,
    required this.arabic,
    required this.english,
  });

  final String coptic;
  final String arabic;
  final String english;
}

// ---------------------------------------------------------------
// FULL-PHRASE MATCHES (checked before word lookups)
// ---------------------------------------------------------------

const List<CopticEntry> copticPhrases = [
  CopticEntry(
    coptic: 'ⲡⲉⲛⲓⲱⲧ ⲉⲧⲟⲛϩ',
    arabic: 'أبانا الذي بالسماء',
    english: 'Our Father who (is in heaven)',
  ),
  CopticEntry(
    coptic: 'ⲙⲁⲣⲉϥⲥⲙⲟⲩ ⲉⲣⲟϥ',
    arabic: 'فليكن مباركًا',
    english: 'Blessed be He',
  ),
  CopticEntry(
    coptic: 'ϩⲁⲙⲏⲛ',
    arabic: 'آمين',
    english: 'Amen',
  ),
  CopticEntry(
    coptic: 'ⲕⲩⲣⲓⲉ ⲉⲗⲉⲏⲥⲟⲛ',
    arabic: 'يا رب ارحم',
    english: 'Lord have mercy',
  ),
  CopticEntry(
    coptic: 'ⲫⲛⲟⲩϯ ⲛ̀ⲁⲅⲁⲑⲟⲥ',
    arabic: 'الله الصالح',
    english: 'The good God',
  ),
];

// ---------------------------------------------------------------
// WORD DICTIONARY
// ---------------------------------------------------------------

const List<CopticEntry> copticLexicon = [
  // ------------------------------------------------------------
  // GOD / SPIRITUAL
  // ------------------------------------------------------------

  CopticEntry(coptic: 'ⲛⲟⲩϯ', arabic: 'الله / إله', english: 'God'),
  CopticEntry(coptic: 'ⲛⲟⲩⲧⲉ', arabic: 'الله / إله', english: 'God'),
  CopticEntry(coptic: 'ϫⲟⲉⲓⲥ', arabic: 'رب / سيّد', english: 'Lord'),
  CopticEntry(coptic: 'ⲭⲣⲓⲥⲧⲟⲥ', arabic: 'المسيح', english: 'Christ'),
  CopticEntry(coptic: 'ⲡⲛⲁ', arabic: 'روح', english: 'Spirit'),
  CopticEntry(coptic: 'ⲡⲛⲉⲩⲙⲁ', arabic: 'روح القدس / روح', english: 'Spirit'),
  CopticEntry(coptic: 'ⲁⲅⲅⲉⲗⲟⲥ', arabic: 'ملاك', english: 'Angel'),
  CopticEntry(coptic: 'ⲁⲣⲭⲁⲅⲅⲉⲗⲟⲥ', arabic: 'رئيس الملائكة', english: 'Archangel'),
  CopticEntry(coptic: 'ϩⲁⲅⲓⲟⲥ', arabic: 'قديس', english: 'Saint'),
  CopticEntry(coptic: 'ⲥⲁⲣⲝ', arabic: 'جسد / لحم', english: 'Flesh'),
  CopticEntry(coptic: 'ⲥⲱⲙⲁ', arabic: 'جسد', english: 'Body'),
  CopticEntry(coptic: 'ⲛⲓϣϯ', arabic: 'عظيم', english: 'Great'),
  CopticEntry(coptic: 'ⲙⲉⲧⲟⲩⲣⲟ', arabic: 'ملكوت', english: 'Kingdom'),
  CopticEntry(coptic: 'ⲟⲩⲣⲟ', arabic: 'ملك', english: 'King'),
  CopticEntry(coptic: 'ⲥⲱⲧⲏⲣ', arabic: 'مخلّص', english: 'Savior'),
  CopticEntry(coptic: 'ⲡⲣⲟⲥⲉⲩⲭⲏ', arabic: 'صلاة', english: 'Prayer'),
  CopticEntry(coptic: 'ϣⲗⲏⲗ', arabic: 'صلوة / صلاة', english: 'Prayer'),
  CopticEntry(coptic: 'ⲉⲕⲕⲗⲏⲥⲓⲁ', arabic: 'كنيسة', english: 'Church'),
  CopticEntry(coptic: 'ⲙⲟⲛⲁⲭⲟⲥ', arabic: 'راهب', english: 'Monk'),
  CopticEntry(coptic: 'ⲇⲓⲁⲕⲱⲛ', arabic: 'شمّاس', english: 'Deacon'),
  CopticEntry(coptic: 'ⲡⲣⲉⲥⲃⲩⲧⲉⲣⲟⲥ', arabic: 'قس / كهنوت', english: 'Priest'),
  CopticEntry(coptic: 'ⲡⲁⲡⲁ', arabic: 'البابا / الأبا', english: 'Pope / Father'),
  CopticEntry(coptic: 'ⲙⲁⲣⲧⲩⲣⲟⲥ', arabic: 'شهيد', english: 'Martyr'),
  CopticEntry(coptic: 'ⲁⲅⲁⲡⲏ', arabic: 'محبة', english: 'Love'),
  CopticEntry(coptic: 'ⲉⲓⲣⲏⲛⲏ', arabic: 'سلام', english: 'Peace'),
  CopticEntry(coptic: 'ϩⲩⲡⲟⲙⲟⲛⲏ', arabic: 'صبر', english: 'Patience'),
  CopticEntry(coptic: 'ⲙⲉⲧⲁⲗⲏⲑⲏ', arabic: 'حقيقة', english: 'Truth'),
  CopticEntry(coptic: 'ⲛⲟⲃⲉ', arabic: 'خطية', english: 'Sin'),
  CopticEntry(coptic: 'ⲟⲩϫⲁⲓ', arabic: 'سلام / خلاص لك', english: 'Salutation of health'),

  // ------------------------------------------------------------
  // PEOPLE & FAMILY
  // ------------------------------------------------------------

  CopticEntry(coptic: 'ⲣⲱⲙⲓ', arabic: 'إنسان / رجل', english: 'Man / person'),
  CopticEntry(coptic: 'ⲣⲱⲙⲉ', arabic: 'إنسان', english: 'Person'),
  CopticEntry(coptic: 'ⲉⲓⲱⲧ', arabic: 'أب', english: 'Father'),
  CopticEntry(coptic: 'ⲙⲁⲁⲩ', arabic: 'أم', english: 'Mother'),
  CopticEntry(coptic: 'ⲥⲟⲛ', arabic: 'أخ', english: 'Brother'),
  CopticEntry(coptic: 'ⲥⲱⲛⲉ', arabic: 'إخوة', english: 'Brothers'),
  CopticEntry(coptic: 'ⲥⲱⲛⲓ', arabic: 'أخت', english: 'Sister'),
  CopticEntry(coptic: 'ϣⲏⲣⲉ', arabic: 'طفل / ابن', english: 'Child / son'),
  CopticEntry(coptic: 'ϣⲏⲣⲓ', arabic: 'طفل / ابنة', english: 'Child / daughter'),

  // ------------------------------------------------------------
  // NATURE & THINGS
  // ------------------------------------------------------------

  CopticEntry(coptic: 'ⲡⲕⲟⲥⲙⲟⲥ', arabic: 'العالم', english: 'The world'),
  CopticEntry(coptic: 'ⲕⲟⲥⲙⲟⲥ', arabic: 'عالم / كون', english: 'World'),
  CopticEntry(coptic: 'ⲡⲕⲁϩ', arabic: 'الأرض', english: 'The earth'),
  CopticEntry(coptic: 'ⲕⲁϩ', arabic: 'أرض / تراب', english: 'Earth'),
  CopticEntry(coptic: 'ⲡⲉⲥⲏⲧ', arabic: 'السماء', english: 'The sky / heaven'),
  CopticEntry(coptic: 'ϩⲟⲉⲓⲛⲉ', arabic: 'شمس', english: 'Sun'),
  CopticEntry(coptic: 'ⲙⲟⲟⲩ', arabic: 'ماء', english: 'Water'),
  CopticEntry(coptic: 'ⲉⲓⲟⲣ', arabic: 'نهر', english: 'River'),
  CopticEntry(coptic: 'ⲧⲟⲟⲩ', arabic: 'جبل', english: 'Mountain'),
  CopticEntry(coptic: 'ⲥⲟϥ', arabic: 'نار', english: 'Fire'),
  CopticEntry(coptic: 'ϩⲓⲱⲧⲉ', arabic: 'دم', english: 'Blood'),
  CopticEntry(coptic: 'ⲱⲓⲕ', arabic: 'خبز', english: 'Bread'),
  CopticEntry(coptic: 'ϩⲏⲏⲧⲉ', arabic: 'قلب', english: 'Heart'),
  CopticEntry(coptic: 'ϩⲏⲧ', arabic: 'قلب / وسط', english: 'Heart / middle'),
  CopticEntry(coptic: 'ⲙⲟⲩ', arabic: 'موت', english: 'Death'),
  CopticEntry(coptic: 'ⲱⲛϩ', arabic: 'حياة', english: 'Life'),
  CopticEntry(coptic: 'ϣⲙⲏⲛ', arabic: 'برية / صحراء', english: 'Desert'),
  CopticEntry(coptic: 'ⲙⲏⲧⲉ', arabic: 'طريق', english: 'Road / way'),
  CopticEntry(coptic: 'ⲡⲟⲗⲓⲥ', arabic: 'مدينة', english: 'City'),

  // ------------------------------------------------------------
  // TIME
  // ------------------------------------------------------------

  CopticEntry(coptic: 'ϩⲟⲟⲩ', arabic: 'يوم', english: 'Day'),
  CopticEntry(coptic: 'ⲟⲩϩⲟⲟⲩ', arabic: 'اليوم', english: 'Today'),
  CopticEntry(coptic: 'ⲣⲟⲙⲡⲉ', arabic: 'سنة', english: 'Year'),
  CopticEntry(coptic: 'ϣⲟⲣⲡ', arabic: 'أولًا / أول', english: 'First'),

  // ------------------------------------------------------------
  // ADJECTIVES
  // ------------------------------------------------------------

  CopticEntry(coptic: 'ⲛⲁⲛⲟⲩϥ', arabic: 'جيد / طيب', english: 'Good'),
  CopticEntry(coptic: 'ⲁⲅⲁⲑⲟⲛ', arabic: 'صالح / جيد', english: 'Good'),
  CopticEntry(coptic: 'ⲭⲁⲕⲟⲛ', arabic: 'شرير / سيء', english: 'Evil'),
  CopticEntry(coptic: 'ϣⲱⲛⲉ', arabic: 'مريض / مرض', english: 'Sick / sickness'),

  // ------------------------------------------------------------
  // VERBS (infinitive forms)
  // ------------------------------------------------------------

  CopticEntry(coptic: 'ⲙⲉⲩⲓ', arabic: 'يحب', english: 'To love'),
  CopticEntry(coptic: 'ϣⲓⲛⲉ', arabic: 'يبحث / يطلب', english: 'To seek'),
  CopticEntry(coptic: 'ⲥⲱⲧⲙ', arabic: 'يسمع', english: 'To hear'),
  CopticEntry(coptic: 'ⲛⲁⲩ', arabic: 'يرى', english: 'To see'),
  CopticEntry(coptic: 'ⲉⲓⲣⲉ', arabic: 'يفعل', english: 'To do / make'),
  CopticEntry(coptic: 'ϫⲱⲕ', arabic: 'يأخذ', english: 'To take'),
  CopticEntry(coptic: 'ⲧⲁⲕⲟ', arabic: 'يهلك', english: 'To perish'),
  CopticEntry(coptic: 'ϣⲱⲡⲉ', arabic: 'يحدث / يصير', english: 'To happen'),
  CopticEntry(coptic: 'ϣⲁϫⲉ', arabic: 'كلمة / يقول', english: 'Word / to say'),
  CopticEntry(coptic: 'ⲙⲟϣⲓ', arabic: 'يمشي / يسير', english: 'To walk / go'),
  CopticEntry(coptic: 'ϩⲉ', arabic: 'يجد', english: 'To find'),
  CopticEntry(coptic: 'ϯ', arabic: 'يعطي', english: 'To give'),
  CopticEntry(coptic: 'ⲉⲓ', arabic: 'يأتي', english: 'To come'),
  CopticEntry(coptic: 'ⲥⲙⲟⲩ', arabic: 'يبارك', english: 'To bless'),
  CopticEntry(coptic: 'ϣⲓⲥⲉ', arabic: 'يسبح / يمجد', english: 'To praise'),
  CopticEntry(coptic: 'ⲟⲩⲱϣⲉ', arabic: 'يريد', english: 'To want'),

  // ------------------------------------------------------------
  // PRONOUNS & SMALL WORDS
  // ------------------------------------------------------------

  CopticEntry(coptic: 'ⲁⲛⲟⲕ', arabic: 'أنا', english: 'I'),
  CopticEntry(coptic: 'ⲛⲧⲟⲕ', arabic: 'أنتَ', english: 'You (m)'),
  CopticEntry(coptic: 'ⲛⲧⲟⲥ', arabic: 'أنتِ', english: 'You (f)'),
  CopticEntry(coptic: 'ⲛⲧⲱⲧⲛ', arabic: 'أنتم', english: 'You (pl)'),
  CopticEntry(coptic: 'ⲡⲉⲛ', arabic: 'ـنا (خاصتنا)', english: 'Our'),
  CopticEntry(coptic: 'ⲡⲉ', arabic: 'ـه', english: 'His'),
  CopticEntry(coptic: 'ⲧⲉ', arabic: 'ـها', english: 'Her'),

  // ------------------------------------------------------------
  // GREEK LOANS COMMON IN THE LITURGY
  // ------------------------------------------------------------

  CopticEntry(coptic: 'ⲑⲉⲟⲥ', arabic: 'الإله', english: 'God (Theos)'),
  CopticEntry(coptic: 'ⲕⲩⲣⲓⲟⲥ', arabic: 'الرب', english: 'Lord (Kyrios)'),
  CopticEntry(coptic: 'ⲇⲟⲝⲁ', arabic: 'مجد', english: 'Glory (Doxa)'),
  CopticEntry(coptic: 'ⲥⲟⲫⲓⲁ', arabic: 'حكمة', english: 'Wisdom (Sophia)'),
  CopticEntry(coptic: 'ⲇⲩⲛⲁⲙⲓⲥ', arabic: 'قوة', english: 'Power (Dynamis)'),
];
