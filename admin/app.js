// Coptic Companion - Full Admin Panel (Firebase + Offline)
// - Bilingual (English / Arabic) with language toggle
// - All content stored in Firebase Firestore
// - Offline persistence via localStorage cache
// - Real-time updates via Firestore listeners
(function() {
  'use strict';

  var STORAGE_KEY = 'coptic_admin_data';
  var LANG_KEY = 'admin_lang';
  var currentLang = localStorage.getItem(LANG_KEY) || 'en';
  var db = null;
  var previewLang = 'ar'; // preview language: ar, en, co
  var previewTheme = 'light';

  var appData = {
    traneem: { ar: [], en: [] },
    bible: { ar: [], en: [] },
    agpeya: { ar: [], en: [] },
    liturgy: { ar: [], en: [] },
    readings: [],
    content: [],
    churches: [],
    design: {
      nameEn: 'Coptic Companion', nameAr: 'مرافق القبطي',
      developer: '', version: '1.0.0', descEn: '', descAr: '',
      colors: {
        primary: '#8B2332', secondary: '#D4AF37',
        bgLight: '#FDF8F0', bgDark: '#1A0F0A',
        textLight: '#2C1810', textDark: '#E8D5A3',
        card: '#FFFFFF', border: '#E0D5C5'
      },
      fonts: { body: 'Cairo', arabic: 'Amiri', sizeBase: 16, sizeHeading: 24 },
      logoUrl: '', iconUrl: '', bgLightUrl: '', bgDarkUrl: ''
    }
  };

  function ensureBundledTraneemCatalog() {
    var catalog = [
      { id: 'doxology', title: 'Glory Be (Doxology)', arabicTitle: 'المجد للإله', category: 'Liturgical', categoryAr: 'طقسية' },
      { id: 'lords-prayer', title: "Our Father (The Lord's Prayer)", arabicTitle: 'أبانا الذي في السموات', category: 'Prayer', categoryAr: 'صلاة' },
      { id: 'trisagion', title: 'Holy God (Trisagion)', arabicTitle: 'التقديس المقدس (الثلاثي قدوس)', category: 'Liturgical', categoryAr: 'طقسية' }
    ];
    ['ar', 'en'].forEach(function(lang) {
      var list = lang === 'ar' ? appData.traneem.ar : appData.traneem.en;
      catalog.forEach(function(meta) {
        if (!list.some(function(item) { return item.id === meta.id; })) {
          list.push(Object.assign({}, meta, { lang: lang, bundled: true, stanzas: [] }));
        }
      });
    });
  }

  // ============================================================
  // TRANSLATIONS
  // ============================================================
  var I18N = {
    en: {
      appTitle: 'Coptic Companion', appSubtitle: 'Full App Admin',
      dashboard: 'Dashboard', importExport: 'Import / Export',
      traneem: 'Traneem', bible: 'Bible', agpeya: 'Agpeya',
      liturgy: 'Liturgy', readings: 'Readings', themeDesign: 'Theme & Design',
      appContent: 'App Content',
      preview: 'Preview', settings: 'Settings',
      overview: 'Overview of all app content.',
      traneemHymns: 'Traneem Hymns', bibleBooks: 'Bible Books',
      agpeyaPrayers: 'Agpeya Prayers', liturgyParts: 'Liturgy Parts',
      copticReadings: 'Coptic Readings', themes: 'Themes',
      howToUse: 'How to Use', dataSource: 'Data Source',
      noData: 'No data loaded. Import to begin.', dataLoaded: 'Data loaded!',
      help1: 'Import: Upload assets or JSON.',
      help2: 'Edit: Navigate sections.',
      help3: 'Preview: See content in app view.',
      help4: 'Theme: Customize appearance.',
      help5: 'Export: Download ZIP for Flutter.',
      noDataFound: 'No data found.',
      editHymn: 'Edit Hymn', editBible: 'Edit Book', editPrayer: 'Edit Prayer',
      editLiturgy: 'Edit Liturgy', editReading: 'Edit Reading',
      jsonData: 'JSON Data', livePreview: 'Live Preview',
      cancel: 'Cancel', deleteBtn: 'Delete', saveBtn: 'Save',
      saved: 'Saved!', deleted: 'Deleted!', imported: 'Imported!',
      invalidJson: 'Invalid JSON', idRequired: 'ID required', nameRequired: 'Name required',
      confirmReset: 'Reset all data?', stanzas: 'stanzas', chapters: 'chapters',
      syncing: 'Syncing...', online: 'Online', offline: 'Offline',
      switchLang: 'عربي'
    },
    ar: {
      appTitle: 'مرافق القبطي', appSubtitle: 'لوحة الإدارة الكاملة',
      dashboard: 'لوحة القيادة', importExport: 'استيراد / تصدير',
      traneem: 'الترانيم', bible: 'الكتاب المقدس', agpeya: 'الأجبية',
      liturgy: 'القداسات', readings: 'القراءات', themeDesign: 'المظهر والتصميم',
      appContent: 'محتوى التطبيق',
      preview: 'معاينة', settings: 'الإعدادات',
      overview: 'نظرة عامة على جميع محتويات التطبيق.',
      traneemHymns: 'ترانيم الألحان', bibleBooks: 'أسفار الكتاب المقدس',
      agpeyaPrayers: 'صلوات الأجبية', liturgyParts: 'أجزاء القداس',
      copticReadings: 'القراءات القبطية', themes: 'المظاهر',
      howToUse: 'كيفية الاستخدام', dataSource: 'مصدر البيانات',
      noData: 'لا توجد بيانات. استيراد للبدء.', dataLoaded: 'تم تحميل البيانات!',
      help1: 'استيراد: رفع الملفات أو JSON.',
      help2: 'تحرير: تصفح الأقسام.',
      help3: 'معاينة: رؤية المحتوى.',
      help4: 'المظهر: تخصيص الإعدادات.',
      help5: 'تصدير: تحميل ZIP.',
      noDataFound: 'لا توجد بيانات.',
      editHymn: 'تحرير ترنيمة', editBible: 'تحرير سفر', editPrayer: 'تحرير صلاة',
      editLiturgy: 'تحرير قداس', editReading: 'تحرير قراءة',
      jsonData: 'بيانات JSON', livePreview: 'معاينة مباشرة',
      cancel: 'إلغاء', deleteBtn: 'حذف', saveBtn: 'حفظ',
      saved: 'تم الحفظ!', deleted: 'تم الحذف!', imported: 'تم الاستيراد!',
      invalidJson: 'JSON غير صالح', idRequired: 'المعرف مطلوب', nameRequired: 'الاسم مطلوب',
      confirmReset: 'إعادة تعيين جميع البيانات؟', stanzas: 'مقاطع', chapters: 'أصحاحات',
      syncing: 'جاري المزامنة...', online: 'متصل', offline: 'غير متصل',
      switchLang: 'English'
    }
  };

  // ============================================================
  // CORE HELPERS
  // ============================================================

  function t(k) {
    return (I18N[currentLang] && I18N[currentLang][k]) || (I18N.en[k] || k);
  }

  function loadLocal() {
    try {
      var raw = localStorage.getItem(STORAGE_KEY);
      if (raw) appData = Object.assign(appData, JSON.parse(raw));
      appData.content = Array.isArray(appData.content) ? appData.content : [];
      ensureBundledTraneemCatalog();
    } catch (e) {}
  }

  function saveLocal() {
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(appData));
    } catch (e) {}
  }

  function showSection(id) {
    var sections = document.querySelectorAll('.content-section');
    for (var i = 0; i < sections.length; i++) sections[i].classList.remove('active');
    var navs = document.querySelectorAll('.nav-item');
    for (var j = 0; j < navs.length; j++) navs[j].classList.remove('active');
    var el = document.getElementById(id);
    if (el) el.classList.add('active');
    var nav = document.querySelector('.nav-item[data-section="' + id + '"]');
    if (nav) nav.classList.add('active');
  }

  window.closeModal = function(id) {
    var m = document.getElementById(id);
    if (m) m.style.display = 'none';
  };

  window.showSection = showSection;

  function openModal(id) {
    var m = document.getElementById(id);
    if (m) m.style.display = 'flex';
  }

  function showToast(msg) {
    var t = document.getElementById('toast');
    var m = document.getElementById('toast-message');
    if (t && m) {
      m.textContent = msg;
      t.style.display = 'block';
      setTimeout(function() { t.style.display = 'none'; }, 3000);
    }
  }

  function updateConnectionStatus() {
    var el = document.getElementById('connectionStatus');
    if (!el) return;
    if (navigator.onLine) {
      el.textContent = 'ПŸ¢ ' + t('online');
      el.className = 'status-online';
    } else {
      el.textContent = 'П´ ' + t('offline');
      el.className = 'status-offline';
    }
  }

  function toggleLanguage() {
    currentLang = currentLang === 'en' ? 'ar' : 'en';
    localStorage.setItem(LANG_KEY, currentLang);
    var html = document.documentElement;
    html.setAttribute('dir', currentLang === 'ar' ? 'rtl' : 'ltr');
    html.setAttribute('lang', currentLang);
    applyTranslations();
    refreshAll();
  }

  window.toggleLanguage = toggleLanguage;

  function applyTranslations() {
    var els = document.querySelectorAll('[data-t]');
    for (var i = 0; i < els.length; i++) {
      var key = els[i].getAttribute('data-t');
      els[i].textContent = t(key);
    }
    var lbtn = document.getElementById('langToggle');
    if (lbtn) lbtn.textContent = t('switchLang');
    updateConnectionStatus();
  }

  function updateStats() {
    var el = function(id) { return document.getElementById(id); };
    if (el('stat-traneem')) el('stat-traneem').textContent =
      uniqueTraneemIds().length;
    if (el('stat-bible')) el('stat-bible').textContent =
      appData.bible.ar.length + appData.bible.en.length;
    if (el('stat-agpeya')) el('stat-agpeya').textContent =
      appData.agpeya.ar.length + appData.agpeya.en.length;
    if (el('stat-liturgy')) el('stat-liturgy').textContent =
      appData.liturgy.ar.length + appData.liturgy.en.length;
    if (el('stat-readings')) el('stat-readings').textContent =
      appData.readings.length;
    if (el('stat-content')) el('stat-content').textContent =
      appData.content.length;
    if (el('stat-themes')) el('stat-themes').textContent = 1;
    var status = el('data-source-status');
    if (status) {
      status.textContent = hasData() ? t('dataLoaded') : t('noData');
      status.className = hasData() ? 'status-ok' : 'status-warning';
    }
  }

  function uniqueTraneemIds() {
    var ids = {};
    appData.traneem.ar.concat(appData.traneem.en).forEach(function(item) {
      if (item && item.id) ids[item.id] = true;
    });
    return Object.keys(ids);
  }

  function hasData() {
    return appData.traneem.ar.length > 0 ||
      appData.bible.ar.length > 0 ||
      appData.agpeya.ar.length > 0 ||
      appData.liturgy.ar.length > 0 ||
      appData.readings.length > 0;
  }

  function refreshAll() {
    if (!document.getElementById('traneem-list')) return;
    updateStats();
    renderTraneemList();
    renderBibleList();
    renderAgpeyaList();
    renderLiturgyList();
    renderReadingsList();
    renderContentList();
    renderDesignForm();
    renderPreviewContent();
  }  // ============================================================
  // FIREBASE
  // ============================================================
  function setupFirebase() {
    if (!window.firebaseDB) {
      displayFirebase(false);
      return false;
    }
    db = window.firebaseDB;
    try {
      // Real-time listeners for each collection (Firebase compat / v8 API)
      db.collection('traneem').onSnapshot(function(snap) {
        if (snap.empty) {
          ensureBundledTraneemCatalog();
          renderTraneemList(); updateStats();
          return;
        }
        appData.traneem.ar = []; appData.traneem.en = [];
        snap.forEach(function(d) {
          var data = d.data();
          if (data.lang === 'ar') appData.traneem.ar.push(data);
          else appData.traneem.en.push(data);
        });
        syncLocalFromState('traneem');
        renderTraneemList(); updateStats();
      });
      db.collection('bible').onSnapshot(function(snap) {
        appData.bible.ar = []; appData.bible.en = [];
        snap.forEach(function(d) {
          var data = d.data();
          if (data.lang === 'ar') appData.bible.ar.push(data);
          else appData.bible.en.push(data);
        });
        renderBibleList(); updateStats();
      });
      db.collection('agpeya').onSnapshot(function(snap) {
        appData.agpeya.ar = []; appData.agpeya.en = [];
        snap.forEach(function(d) {
          var data = d.data();
          if (data.lang === 'ar') appData.agpeya.ar.push(data);
          else appData.agpeya.en.push(data);
        });
        renderAgpeyaList(); updateStats();
      });
      db.collection('liturgy').onSnapshot(function(snap) {
        appData.liturgy.ar = []; appData.liturgy.en = [];
        snap.forEach(function(d) {
          var data = d.data();
          if (data.lang === 'ar') appData.liturgy.ar.push(data);
          else appData.liturgy.en.push(data);
        });
        renderLiturgyList(); updateStats();
      });
      db.collection('readings').onSnapshot(function(snap) {
        appData.readings = [];
        snap.forEach(function(d) { appData.readings.push(d.data()); });
        renderReadingsList(); updateStats();
      });
      db.collection('content').onSnapshot(function(snap) {
        appData.content = [];
        snap.forEach(function(d) { appData.content.push(d.data()); });
        syncLocalFromState('content');
        renderContentList(); updateStats();
      });
      db.doc('settings/design').onSnapshot(function(snap) {
        if (snap.exists()) appData.design = snap.data();
        renderDesignForm();
      });
      displayFirebase(true);
      return true;
    } catch (e) {
      displayFirebase(false);
      return false;
    }
  }

  function displayFirebase(ok) {
    var el = document.getElementById('data-source-status');
    if (!el) return;
    if (ok) {
      el.textContent = '\uD83D\uDFE2 Firebase connected - real-time sync active';
      el.className = 'status-ok';
    } else {
      el.textContent = '\u26A0\uFE0F Using offline cache (Firebase unavailable)';
      el.className = 'status-warning';
    }
  }

  async function saveToFirebase(collectionName, docId, data) {
    if (!db) { saveLocal(); return; }
    try {
      await db.collection(collectionName).doc(docId).set(data);
    } catch (e) {
      saveLocal();
      showToast('Offline save');
    }
  }

  async function deleteFromFirebase(collectionName, docId) {
    if (!db) return;
    try {
      await db.collection(collectionName).doc(docId).delete();
    } catch (e) {}
  }

  // Keep local cache in sync for offline use
  function syncLocalFromState() { saveLocal(); }
  // ============================================================
  // SEARCH (live filtering of <section>Search inputs)
  // ============================================================
  var searchFilter = { traneem: '', bible: '', agpeya: '', liturgy: '', readings: '' };
  function searchMatches(itemData, term) {
    if (!term) return true;
    var hay = [];
    var walk = function(v) {
      if (v === null || v === undefined) return;
      if (typeof v === 'string') hay.push(v.toLowerCase());
      else if (typeof v === 'number') hay.push(String(v));
      else if (Array.isArray(v)) v.forEach(walk);
      else if (typeof v === 'object') Object.keys(v).forEach(function(k) { walk(v[k]); });
    };
    walk(itemData);
    return hay.join(' ').indexOf(term) >= 0;
  }
  window.setSearch = function(section, value) {
    searchFilter[section] = (value || '').trim().toLowerCase();
    if (section === 'traneem') renderTraneemList();
    else if (section === 'bible') renderBibleList();
    else if (section === 'agpeya') renderAgpeyaList();
    else if (section === 'liturgy') renderLiturgyList();
    else if (section === 'readings') renderReadingsList();
    else if (section === 'churches') { /* map is initialized via showSection override */ }
  };
  // ============================================================
  // RENDER FUNCTIONS
  // ============================================================
  function renderTraneemList() {
    var c = document.getElementById('traneem-list');
    if (!c) return;
    var grouped = {};
    appData.traneem.ar.forEach(function(h) {
      grouped[h.id] = grouped[h.id] || {};
      grouped[h.id].ar = h;
    });
    appData.traneem.en.forEach(function(h) {
      grouped[h.id] = grouped[h.id] || {};
      grouped[h.id].en = h;
    });
    var all = Object.keys(grouped).map(function(id) {
      return { id: id, ar: grouped[id].ar, en: grouped[id].en };
    });
    var term = searchFilter.traneem;
    if (term) all = all.filter(function(it) {
      return searchMatches(it.ar || {}, term) || searchMatches(it.en || {}, term);
    });
    if (!all.length) { c.innerHTML = '<p class="empty-state">' + (term ? 'No matches found' : t('noDataFound')) + '</p>'; return; }
    c.innerHTML = all.map(function(it) {
      var d = it.en || it.ar || {};
      var title = d.name || d.title || d.arabicTitle || it.id || 'Untitled';
      var arButton = it.ar
        ? '<button class="btn btn-secondary btn-sm" onclick="event.stopPropagation();editTraneem(\'ar\',\'' + it.id + '\')">AR</button>'
        : '<span class="item-meta">AR missing</span>';
      var enButton = it.en
        ? '<button class="btn btn-secondary btn-sm" onclick="event.stopPropagation();editTraneem(\'en\',\'' + it.id + '\')">EN</button>'
        : '<span class="item-meta">EN missing</span>';
      return '<div class="item-row"><div><span class="item-title">' + esc(title) + '</span><br><span class="item-meta">' + it.id + ' | one hymn, available languages: ' + (it.ar ? 'AR ' : '') + (it.en ? 'EN' : '') + '</span></div><div>' + arButton + ' ' + enButton + '</div></div>';
    }).join('');
  }
  function renderBibleList() {
    var c = document.getElementById('bible-list');
    if (!c) return;
    var all = [];
    appData.bible.ar.forEach(function(b) { all.push({ lang: 'ar', data: b }); });
    appData.bible.en.forEach(function(b) { all.push({ lang: 'en', data: b }); });
    var term = searchFilter.bible;
    if (term) all = all.filter(function(it) { return searchMatches(it.data, term); });
    if (!all.length) { c.innerHTML = '<p class="empty-state">' + (term ? 'No matches found' : t('noDataFound')) + '</p>'; return; }
    c.innerHTML = all.map(function(it) {
      var d = it.data; var chCount = (d.chapters || []).length;
      return '<div class="item-row" onclick="editBible(\'' + it.lang + '\',\'' + (d.bookId || '') + '\')"><div><span class="item-title">' + (d.bookName || d.bookId) + '</span><br><span class="item-meta">' + chCount + ' ' + t('chapters') + ' | ' + it.lang.toUpperCase() + '</span></div><span>\u270F\uFE0F</span></div>';
    }).join('');
  }
  function renderAgpeyaList() {
    var c = document.getElementById('agpeya-list');
    if (!c) return;
    var all = [];
    appData.agpeya.ar.forEach(function(p) { all.push({ lang: 'ar', data: p }); });
    appData.agpeya.en.forEach(function(p) { all.push({ lang: 'en', data: p }); });
    var term = searchFilter.agpeya;
    if (term) all = all.filter(function(it) { return searchMatches(it.data, term); });
    if (!all.length) { c.innerHTML = '<p class="empty-state">' + (term ? 'No matches found' : t('noDataFound')) + '</p>'; return; }
    c.innerHTML = all.map(function(it) {
      var d = it.data; var name = d.name || d.englishName || d.id;
      return '<div class="item-row" onclick="editAgpeya(\'' + it.lang + '\',\'' + (d.id || '') + '\')"><div><span class="item-title">' + name + '</span><br><span class="item-meta">' + (d.id || '') + ' | ' + it.lang.toUpperCase() + '</span></div><span>\u270F\uFE0F</span></div>';
    }).join('');
  }
  function renderLiturgyList() {
    var c = document.getElementById('liturgy-list');
    if (!c) return;
    var all = [];
    appData.liturgy.ar.forEach(function(l) { all.push({ lang: 'ar', data: l }); });
    appData.liturgy.en.forEach(function(l) { all.push({ lang: 'en', data: l }); });
    var term = searchFilter.liturgy;
    if (term) all = all.filter(function(it) { return searchMatches(it.data, term); });
    if (!all.length) { c.innerHTML = '<p class="empty-state">' + (term ? 'No matches found' : t('noDataFound')) + '</p>'; return; }
    c.innerHTML = all.map(function(it) {
      var d = it.data;
      var readingBadge = (d.sections || []).filter(function(s) { return s.readingType; }).length;
      var badgeHtml = readingBadge > 0 ? '<span class="reading-badge">' + readingBadge + ' ' + (currentLang === 'ar' ? 'قراءات' : 'readings') + '</span>' : '';
      return '<div class="item-row" onclick="editLiturgy(\'' + it.lang + '\',\'' + (d.id || d.name || '') + '\')"><div><span class="item-title">' + (d.name || d.id || 'Liturgy') + '</span> ' + badgeHtml + '<br><span class="item-meta">' + it.lang.toUpperCase() + (d.sections ? ' \u2022 ' + d.sections.length + ' ' + (currentLang === 'ar' ? 'أقسام' : 'sections') : '') + '</span></div><span>\u270F\uFE0F</span></div>';
    }).join('');
  }
  function renderReadingsList() {
    var c = document.getElementById('readings-list');
    if (!c) return;
    var term = searchFilter.readings;
    var list = [];
    for (var i = 0; i < appData.readings.length; i++) {
      if (!term || searchMatches(appData.readings[i], term)) list.push({ idx: i, data: appData.readings[i] });
    }
    if (!list.length) { c.innerHTML = '<p class="empty-state">' + (term ? 'No matches found' : t('noDataFound')) + '</p>'; return; }
    c.innerHTML = list.map(function(item) {
      var r = item.data; var i = item.idx;
      return '<div class="item-row" onclick="editReading(' + i + ')"><div><span class="item-title">' + (r.title || r.type || 'Reading') + '</span><br><span class="item-meta">' + (r.type || '') + '</span></div><span>\u270F\uFE0F</span></div>';
    }).join('');
  }
  function renderDesignForm() {
    var d = appData.design;
    var s = function(id, val) { var e = document.getElementById(id); if (e) e.value = val; };
    s('app-name-en', d.nameEn || ''); s('app-name-ar', d.nameAr || '');
    s('app-developer', d.developer || ''); s('app-version', d.version || '1.0.0');
    s('app-desc-en', d.descEn || ''); s('app-desc-ar', d.descAr || '');
    s('color-primary', (d.colors || {}).primary || '#8B2332');
    s('color-secondary', (d.colors || {}).secondary || '#D4AF37');
    s('color-bg-light', (d.colors || {}).bgLight || '#FDF8F0');
    s('color-bg-dark', (d.colors || {}).bgDark || '#1A0F0A');
    s('color-text-light', (d.colors || {}).textLight || '#2C1810');
    s('color-text-dark', (d.colors || {}).textDark || '#E8D5A3');
    s('color-card', (d.colors || {}).card || '#FFFFFF');
    s('color-border', (d.colors || {}).border || '#E0D5C5');
    s('font-body', (d.fonts || {}).body || 'Cairo');
    s('font-arabic', (d.fonts || {}).arabic || 'Amiri');
    s('font-size-base', (d.fonts || {}).sizeBase || 16);
    s('font-size-heading', (d.fonts || {}).sizeHeading || 24);
    s('logo-url', d.logoUrl || ''); s('icon-url', d.iconUrl || '');
    s('bg-light-url', d.bgLightUrl || ''); s('bg-dark-url', d.bgDarkUrl || '');
  }
  // Render preview content based on selected language
  function renderPreviewContent() {
    var pc = document.getElementById('preview-content'); if (!pc) return;
    var container = document.getElementById('preview-container'); if (container) {
      container.className = 'preview-container' + (previewTheme === 'dark' ? ' preview-dark' : '');
    }
    var lang = previewLang;
    var hasData = appData.traneem.ar.length + appData.traneem.en.length +
                  appData.bible.ar.length + appData.bible.en.length +
                  appData.agpeya.ar.length + appData.agpeya.en.length +
                  appData.liturgy.ar.length + appData.liturgy.en.length +
                  appData.readings.length > 0;
    if (!hasData) { pc.innerHTML = '<p class=empty-state>Import data to see preview</p>'; return; }
    var litList = lang === 'ar' ? appData.liturgy.ar : appData.liturgy.en;
    var html = '';
    // Liturgy Preview
    if (litList.length) {
      litList.forEach(function(lit) {
        var langLabel = lang === 'ar' ? 'عربي' : (lang === 'co' ? 'ϯⲙⲉⲧⲣⲉⲙⲛ̀ⲭⲏⲙⲓ' : 'English');
        html += '<div class="preview-section"><h3 style="color:var(--coptic-burgundy)">' + esc(lit.name || lit.id) + ' <span style="font-size:0.7em;color:#888">(' + langLabel + ')</span></h3>';
        if (lit.introduction) html += '<p class="preview-intro">' + esc(lit.introduction) + '</p>';
        if (lit.sections) {
          lit.sections.forEach(function(s) {
            var lines = resolveReadingPlaceholders(s.content || [], lang);
            var rt = s.readingType ? '<span class="reading-badge">' + esc(getReadingTypeLabel(s.readingType)) + '</span>' : '';
            html += '<div class="preview-stanza"><div class="stanza-title">' + esc(s.title || '') + rt + '</div>' + lines.map(function(line) { return '<div class="stanza-line">' + esc(line) + '</div>'; }).join('') + '</div>';
          });
        }
        html += '</div>';
      });
    }
    // Readings Preview
    if (appData.readings.length) {
      html += '<div class="preview-section"><h3 style="color:var(--coptic-burgundy)">' + (lang === 'ar' ? 'القراءات' : (lang === 'co' ? 'Ⲛⲓⲱⲓⲙⲓ' : 'Readings')) + '</h3>';
      appData.readings.forEach(function(r) {
        var content = r.content || r.reads || r.verses || [];
        var contentStr = Array.isArray(content) ? content.join('<br>') : content;
        html += '<div class="preview-stanza"><div class="stanza-title">' + esc(r.title || r.type || 'Reading') + '</div><div class="stanza-line">' + esc(contentStr) + '</div></div>';
      });
      html += '</div>';
    }
    if (!html) html = '<p class=empty-state>' + (lang === 'ar' ? 'لا يوجد محتوى باللغة المختارة' : (lang === 'co' ? 'Ⲙⲉⲧⲣⲉⲙⲛ̀ⲭⲏⲙⲓ ⲁⲛ' : 'No content in selected language')) + '</p>';
    pc.innerHTML = html;
  }
  // ============================================================
  // EDIT / OPEN MODAL (VISUAL FORM EDITORS)
  // ============================================================
  function fv(id) { var e = document.getElementById(id); return e ? e.value : ''; }
  function fs(id, v) { var e = document.getElementById(id); if (e) e.value = (v == null ? '' : v); }
  function esc(s) { return String(s == null ? '' : s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;').replace(/'/g,'&#39;'); }

  var editHymnBuffer = { stanzas: [] };
  var editBibleBuffer = { chapters: [], chapterIdx: 0 };
  var editAgpeyaBuffer = { sections: [] };
  var editLiturgyBuffer = { sections: [] };
  var editReadingData = null;

  var editOriginal = null;
  var editAgpeyaSectionKeys = [];
  function deepClone(o) { return o ? JSON.parse(JSON.stringify(o)) : {}; }
  function txtLines(s) { return String(s == null ? '' : s).split('\n').map(function(x) { return x.replace(/\r$/, ''); }).filter(function(x) { return x.trim() !== ''; }); }

  // ================== HYMN EDITOR ================
  function renderHymnPreview(data) {
    var p = document.getElementById('hymn-preview');
    if (!p) return;
    data = data || {};
    var stanzas = data.stanzas || editHymnBuffer.stanzas || [];
    var h = '<h3 style="color:var(--coptic-burgundy);margin-bottom:12px">' + esc(data.name || data.title || data.arabicTitle || '') + '</h3>';
    h += stanzas.map(function(s) {
      return '<div class="preview-stanza"><div class="stanza-title">' + esc(s.title || '') + '</div>' + (s.lines || []).map(function(l) { return '<div class="stanza-line">' + esc(l) + '</div>'; }).join('') + '</div>';
    }).join('');
    p.innerHTML = h;
  }
  function renderHymnStanzas(stanzas) {
    editHymnBuffer.stanzas = stanzas || [];
    var wrap = document.getElementById('hymn-stanzas');
    if (!wrap) return;
    if (!editHymnBuffer.stanzas.length) { wrap.innerHTML = '<p class="empty-state">No stanzas</p>'; return; }
    var html = editHymnBuffer.stanzas.map(function(s, i) {
      var lines = (s.lines || []).map(function(l, j) {
        return '<div class="editor-line-row"><input type="text" class="form-control" value="' + esc(l) + '" oninput="editHymnLine(' + i + ',' + j + ',this.value)"><button type="button" class="btn btn-danger btn-sm" onclick="removeHymnLine(' + i + ',' + j + ')">&times;</button></div>';
      }).join('');
      return '<div class="editor-block"><div class="editor-block-head"><input type="text" class="form-control editor-title-input" placeholder="Stanza title" value="' + esc(s.title || '') + '" oninput="editHymnStanzaTitle(' + i + ',this.value)"><button type="button" class="btn btn-danger btn-sm" onclick="removeHymnStanza(' + i + ')">&times; Stanza</button></div><div class="editor-lines">' + lines + '</div><button type="button" class="btn btn-secondary btn-sm" onclick="addHymnLine(' + i + ')">+ Line</button></div>';
    }).join('');
    wrap.innerHTML = html;
  }
  window.addHymnStanza = function() { editHymnBuffer.stanzas.push({ title: '', lines: [''] }); renderHymnStanzas(editHymnBuffer.stanzas); };
  window.removeHymnStanza = function(i) { editHymnBuffer.stanzas.splice(i, 1); renderHymnStanzas(editHymnBuffer.stanzas); renderHymnPreview(); };
  window.editHymnStanzaTitle = function(i, v) { if (editHymnBuffer.stanzas[i]) editHymnBuffer.stanzas[i].title = v; renderHymnPreview(); };
  window.addHymnLine = function(i) { editHymnBuffer.stanzas[i].lines.push(''); renderHymnStanzas(editHymnBuffer.stanzas); };
  window.removeHymnLine = function(i, j) { editHymnBuffer.stanzas[i].lines.splice(j, 1); renderHymnStanzas(editHymnBuffer.stanzas); };
  window.editHymnLine = function(i, j, v) { if (editHymnBuffer.stanzas[i]) editHymnBuffer.stanzas[i].lines[j] = v; renderHymnPreview(); };  window.editTraneem = function(lang, id) {
    var list = lang === 'ar' ? appData.traneem.ar : appData.traneem.en;
    var item = list.find(function(h) { return h.id === id; });
    if (!item) return;
    openModal('modal-hymn');
    document.getElementById('hymn-modal-title').textContent = t('editHymn') + ': ' + (item.name || item.title || item.id);
    fs('hymn-lang', lang); fs('hymn-orig-id', id);
    editOriginal = item;
    fs('hymn-name-field', item.name || item.title || item.titleEn || '');
    fs('hymn-text-field', item.text || '');
    fs('hymn-arabic-title-field', item.arabicTitle || item.titleAr || '');
    fs('hymn-coptic-title-field', item.copticTitle || item.titleCo || '');
    fs('hymn-category-field', item.category || '');
    fs('hymn-categoryar-field', item.categoryAr || '');
    renderHymnStanzas(item.stanzas || []);
    renderHymnPreview(item);
    document.getElementById('deleteHymnBtn').style.display = 'inline-flex';
  };
  window.newTraneem = function() {
    openModal('modal-hymn');
    document.getElementById('hymn-modal-title').textContent = t('editHymn');
    fs('hymn-lang', 'ar'); fs('hymn-orig-id', '');
    editOriginal = null;
    fs('hymn-name-field', ''); fs('hymn-text-field', ''); fs('hymn-arabic-title-field', '');
    fs('hymn-coptic-title-field', ''); fs('hymn-category-field', ''); fs('hymn-categoryar-field', '');
    renderHymnStanzas([{ title: '', lines: [''] }]);
    renderHymnPreview({ name: '' });
    document.getElementById('deleteHymnBtn').style.display = 'none';
  };
  async function saveHymn() {
    var lang = fv('hymn-lang');
    var name = (fv('hymn-name-field') || '').trim(); var id = (editOriginal && editOriginal.id) || (name.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '') || 'hymn') + '-' + Date.now().toString(36);
    if (!name) { showToast(t('nameRequired')); return; }
    var data = editOriginal || {};
    data.id = id; data.name = name; data.lang = lang; if (fv('hymn-text-field')) data.text = fv('hymn-text-field'); else delete data.text;
    if (fv('hymn-arabic-title-field')) data.arabicTitle = fv('hymn-arabic-title-field'); else delete data.arabicTitle;
    if (fv('hymn-coptic-title-field')) data.copticTitle = fv('hymn-coptic-title-field'); else delete data.copticTitle;
    if (fv('hymn-category-field')) data.category = fv('hymn-category-field'); else delete data.category;
    if (fv('hymn-categoryar-field')) data.categoryAr = fv('hymn-categoryar-field'); else delete data.categoryAr;
    data.stanzas = editHymnBuffer.stanzas || [];
    data.updatedAt = new Date().toISOString();
    await saveToFirebase('traneem', id + '_' + lang, data);
    saveLocal(); closeModal('modal-hymn'); showToast(t('saved'));
  }
  async function deleteHymn() {
    var lang = fv('hymn-lang'); var id = fv('hymn-orig-id');
    if (!id) return;
    var list = lang === 'ar' ? appData.traneem.ar : appData.traneem.en;
    var idx = list.findIndex(function(h) { return h.id === id; });
    if (idx >= 0) list.splice(idx, 1);
    await deleteFromFirebase('traneem', id + '_' + lang);
    saveLocal(); closeModal('modal-hymn'); renderTraneemList(); showToast(t('deleted'));
  }
  // ================= BIBLE EDITOR =================
  function renderBiblePreview(data) {
    var p = document.getElementById('bible-preview'); if (!p) return;
    var name = (data && data.bookName) || fv('bible-book-name') || 'Bible';
    var ch = editBibleBuffer.chapters[editBibleBuffer.chapterIdx] || { verses: [] };
    var verses = (ch.verses || []);
    var h = '<h3 style="color:var(--coptic-burgundy);margin-bottom:8px">' + esc(name) + '</h3>';
    h += '<p style="color:#888;font-size:0.85rem">Chapter ' + (editBibleBuffer.chapterIdx + 1) + ' of ' + editBibleBuffer.chapters.length + ' &middot; ' + verses.length + ' verses</p>';
    h += verses.slice(0, 5).map(function(v, i) {
      var text = (typeof v === 'string') ? v : (v.text || '');
      return '<div style="margin-bottom:6px"><span style="color:var(--coptic-gold);font-weight:600;margin-right:6px">' + (i + 1) + '.</span>' + esc(text) + '</div>';
    }).join('');
    if (!verses.length) h += '<p class="empty-state">No verses yet</p>';
    p.innerHTML = h;
  }
  function renderBibleChapters(chapters) {
    editBibleBuffer.chapters = chapters || [];
    editBibleBuffer.chapterIdx = 0;
    var sel = document.getElementById('bible-chapter-select');
    if (!sel) return;
    sel.innerHTML = editBibleBuffer.chapters.map(function(_, i) { return '<option value="' + i + '">Chapter ' + (i + 1) + '</option>'; }).join('');
    showBibleChapter(0);
  }
  function showBibleChapter(idx) {
    editBibleBuffer.chapterIdx = idx;
    var ta = document.getElementById('bible-verses');
    var ch = editBibleBuffer.chapters[idx] || { verses: [] };
    var text = (ch.verses || []).map(function(v) { return (typeof v === 'string') ? v : v.text; }).join('\n');
    if (ta) ta.value = text;
    renderBiblePreview();
  }
  function collectBibleChapter() {
    var ta = document.getElementById('bible-verses'); if (!ta) return;
    var lines = ta.value.split('\n');
    var verses = [];
    for (var k = 0; k < lines.length; k++) {
      var txt = lines[k].replace(/\r$/, '');
      if (txt.trim() !== '') verses.push({ number: k + 1, text: txt });
    }
    editBibleBuffer.chapters[editBibleBuffer.chapterIdx] = { chapterNumber: editBibleBuffer.chapterIdx + 1, verses: verses };
  }
  window.selectBibleChapter = function() {
    var sel = document.getElementById('bible-chapter-select'); if (!sel) return;
    collectBibleChapter();
    showBibleChapter(parseInt(sel.value) || 0);
  };
  window.addBibleChapter = function() {
    collectBibleChapter();
    editBibleBuffer.chapters.push({ chapterNumber: editBibleBuffer.chapters.length + 1, verses: [] });
    renderBibleChapters(editBibleBuffer.chapters);
    var sel = document.getElementById('bible-chapter-select');
    if (sel) { sel.value = editBibleBuffer.chapters.length - 1; showBibleChapter(parseInt(sel.value)); }
  };
  window.removeBibleChapter = function() {
    if (editBibleBuffer.chapters.length <= 1) return;
    collectBibleChapter();
    editBibleBuffer.chapters.splice(editBibleBuffer.chapterIdx, 1);
    renderBibleChapters(editBibleBuffer.chapters);
  };
  window.editBible = function(lang, id) {
    var list = lang === 'ar' ? appData.bible.ar : appData.bible.en;
    var item = list.find(function(b) { return b.bookId === id; });
    if (!item) return;
    openModal('modal-bible');
    document.getElementById('bible-modal-title').textContent = t('editBible') + ': ' + (item.bookName || item.bookId);
    fs('bible-lang', lang); fs('bible-orig-id', id);
    editOriginal = item;
    fs('bible-book-id', item.bookId || ''); fs('bible-book-name', item.bookName || '');
    renderBibleChapters(item.chapters || []);
    document.getElementById('deleteBibleBtn').style.display = 'inline-flex';
  };
  window.newBible = function() {
    openModal('modal-bible');
    document.getElementById('bible-modal-title').textContent = t('editBible');
    editOriginal = null;
    fs('bible-lang', 'ar'); fs('bible-orig-id', '');
    fs('bible-book-id', ''); fs('bible-book-name', '');
    renderBibleChapters([{ chapterNumber: 1, verses: [] }]);
    document.getElementById('deleteBibleBtn').style.display = 'none';
  };
  async function saveBible() {
    var lang = fv('bible-lang');
    var id = (fv('bible-book-id') || '').trim();
    if (!id) { showToast(t('idRequired')); return; }
    collectBibleChapter();
    var data = editOriginal || {};
    data.bookId = id; data.bookName = fv('bible-book-name') || id; data.lang = lang; data.chapters = editBibleBuffer.chapters;
    data.updatedAt = new Date().toISOString();
    await saveToFirebase('bible', id + '_' + lang, data);
    saveLocal(); closeModal('modal-bible'); showToast(t('saved'));
  }
  async function deleteBible() {
    var lang = fv('bible-lang'); var id = fv('bible-orig-id');
    if (!id) return;
    var list = lang === 'ar' ? appData.bible.ar : appData.bible.en;
    var idx = list.findIndex(function(b) { return b.bookId === id; });
    if (idx >= 0) list.splice(idx, 1);
    await deleteFromFirebase('bible', id + '_' + lang);
    saveLocal(); closeModal('modal-bible'); renderBibleList(); showToast(t('deleted'));
  }
  // ================= AGPEYA EDITOR =================
  function renderAgpeyaPreview(data) {
    var p = document.getElementById('agpeya-preview'); if (!p) return;
    data = data || {};
    var sections = editAgpeyaBuffer.sections || [];
    var name = fv('agpeya-name') || data.name || data.englishName || 'Prayer';
    var h = '<h3 style="color:var(--coptic-burgundy);margin-bottom:12px">' + esc(name) + '</h3>';
    h += sections.map(function(s) {
      return '<div class="preview-stanza"><div class="stanza-title">' + esc(s.title || s.key || '') + '</div>' + (s.content || []).map(function(l) { return '<div class="stanza-line">' + esc(l) + '</div>'; }).join('') + '</div>';
    }).join('');
    p.innerHTML = h;
  }
  function renderAgpeyaSections(sections) {
    editAgpeyaBuffer.sections = sections || [];
    var wrap = document.getElementById('agpeya-sections'); if (!wrap) return;
    if (!editAgpeyaBuffer.sections.length) { wrap.innerHTML = '<p class="empty-state">No sections</p>'; return; }
    wrap.innerHTML = editAgpeyaBuffer.sections.map(function(s, i) {
      var lines = (s.content || []).map(function(l) { return esc(l); }).join('\n');
      return '<div class="editor-block"><div class="editor-block-head"><span class="editor-key">' + esc(s.key || 'section') + '</span><input type="text" class="form-control editor-title-input" placeholder="Section title" value="' + esc(s.title || '') + '" oninput="editAgpeyaSectionTitle(' + i + ',this.value)"><button type="button" class="btn btn-danger btn-sm" onclick="removeAgpeyaSection(' + i + ')">&times;</button></div><textarea class="form-control editor-content" rows="3" placeholder="One paragraph per line" oninput="editAgpeyaSectionContent(' + i + ',this.value)">' + esc(lines) + '</textarea></div>';
    }).join('');
  }
  window.addAgpeyaSection = function() { editAgpeyaBuffer.sections.push({ key: 'section', title: '', content: [''] }); renderAgpeyaSections(editAgpeyaBuffer.sections); renderAgpeyaPreview(); };
  window.removeAgpeyaSection = function(i) { editAgpeyaBuffer.sections.splice(i, 1); renderAgpeyaSections(editAgpeyaBuffer.sections); renderAgpeyaPreview(); };
  window.editAgpeyaSectionTitle = function(i, v) { if (editAgpeyaBuffer.sections[i]) editAgpeyaBuffer.sections[i].title = v; renderAgpeyaPreview(); };
  window.editAgpeyaSectionContent = function(i, v) { if (editAgpeyaBuffer.sections[i]) editAgpeyaBuffer.sections[i].content = v.split('\n'); renderAgpeyaPreview(); };
  window.editAgpeya = function(lang, id) {
    var list = lang === 'ar' ? appData.agpeya.ar : appData.agpeya.en;
    var item = list.find(function(p) { return p.id === id; });
    if (!item) return;
    openModal('modal-agpeya');
    document.getElementById('agpeya-modal-title').textContent = t('editPrayer') + ': ' + (item.name || item.englishName || item.id);
    fs('agpeya-lang', lang); fs('agpeya-orig-id', id);
    editOriginal = item;
    fs('agpeya-id', item.id || ''); fs('agpeya-name', item.name || '');
    fs('agpeya-english-name', item.englishName || ''); fs('agpeya-traditional-time', item.traditionalTime || '');
    fs('agpeya-introduction', item.introduction || '');
    editAgpeyaSectionKeys = [];
    var sections = [];
    for (var k in item) {
      var v = item[k];
      if (k !== 'id' && v && typeof v === 'object' && !Array.isArray(v) && (v.content || v.title)) {
        sections.push({ key: k, title: v.title || '', content: v.content || [], inline: !!v.inline });
        editAgpeyaSectionKeys.push(k);
      }
    }
    renderAgpeyaSections(sections);
    renderAgpeyaPreview(item);
    document.getElementById('deleteAgpeyaBtn').style.display = 'inline-flex';
  };
  window.newAgpeya = function() {
    openModal('modal-agpeya');
    document.getElementById('agpeya-modal-title').textContent = t('editPrayer');
    editOriginal = null;
    fs('agpeya-lang', 'ar'); fs('agpeya-orig-id', '');
    fs('agpeya-id', ''); fs('agpeya-name', ''); fs('agpeya-english-name', ''); fs('agpeya-traditional-time', '');
    fs('agpeya-introduction', '');
    renderAgpeyaSections([{ key: 'opening', title: '', content: [''], inline: true }]);
    renderAgpeyaPreview();
    document.getElementById('deleteAgpeyaBtn').style.display = 'none';
  };
  async function saveAgpeya() {
    var lang = fv('agpeya-lang');
    var id = (fv('agpeya-id') || '').trim();
    if (!id) { showToast(t('idRequired')); return; }
    var data = editOriginal || {};
    data.id = id; data.name = fv('agpeya-name'); data.englishName = fv('agpeya-english-name'); data.lang = lang;
    var intro = fv('agpeya-introduction'); if (intro) data.introduction = intro;
    var ttime = fv('agpeya-traditional-time'); if (ttime) data.traditionalTime = ttime;
    var i;
    var currentKeys = [];
    for (i = 0; i < editAgpeyaBuffer.sections.length; i++) {
      var s = editAgpeyaBuffer.sections[i];
      var sk = s.key || ('section' + i);
      currentKeys.push(sk);
      data[sk] = { title: s.title || '', content: s.content || [], inline: !!s.inline };
    }
    for (i = 0; i < editAgpeyaSectionKeys.length; i++) {
      if (currentKeys.indexOf(editAgpeyaSectionKeys[i]) < 0) delete data[editAgpeyaSectionKeys[i]];
    }
    data.updatedAt = new Date().toISOString();
    await saveToFirebase('agpeya', id + '_' + lang, data);
    saveLocal(); closeModal('modal-agpeya'); showToast(t('saved'));
  }
  async function deleteAgpeya() {
    var lang = fv('agpeya-lang'); var id = fv('agpeya-orig-id');
    if (!id) return;
    var list = lang === 'ar' ? appData.agpeya.ar : appData.agpeya.en;
    var idx = list.findIndex(function(p) { return p.id === id; });
    if (idx >= 0) list.splice(idx, 1);
    await deleteFromFirebase('agpeya', id + '_' + lang);
    saveLocal(); closeModal('modal-agpeya'); renderAgpeyaList(); showToast(t('deleted'));
  }
  // ================= LITURGY EDITOR =================
  // Available reading types for liturgy sections
  var READING_TYPES = [
    { value: '', label: '— None —', labelAr: '— بدون قراءة —' },
    { value: 'pauline', label: 'Pauline Epistle (البولس)', labelAr: 'الرسالة البولسية (البولس)' },
    { value: 'catholic', label: 'Catholic Epistle (الكاثوليكون)', labelAr: 'الرسالة الجامعة (الكاثوليكون)' },
    { value: 'acts', label: 'Acts (الأعمال)', labelAr: 'أعمال الرسل (الإبركسيس)' },
    { value: 'synaxar', label: 'Synaxarium (السنكسار)', labelAr: 'السنكسار' },
    { value: 'psalm', label: 'Psalm (المزمور)', labelAr: 'المزمور' },
    { value: 'gospel', label: 'Gospel (الإنجيل)', labelAr: 'الإنجيل المقدس' },
    { value: 'prophecy', label: 'Prophetie (النبوات)', labelAr: 'القراءات النبوية' }
  ];
  function getReadingTypeLabel(val) {
    var rt = READING_TYPES.find(function(r) { return r.value === val; });
    return rt ? (currentLang === 'ar' ? rt.labelAr : rt.label) : '';
  }
  // Find reading content from appData.readings by type
  function findReadingContent(type, lang) {
    if (!type || !appData.readings || !appData.readings.length) return null;
    var r = appData.readings.find(function(rd) { return rd.type === type || rd.id === type; });
    if (!r) return null;
    var content = r.content || r.reads || r.verses || [];
    if (typeof content === 'string') return content;
    if (Array.isArray(content)) return content.join('\n');
    return null;
  }
  // Resolve {READING:type} placeholders in content
  function resolveReadingPlaceholders(lines, lang) {
    var result = [];
    lines.forEach(function(line) {
      var m = line.match(/^\{READING:(\w+)\}$/);
      if (m) {
        var type = m[1];
        var readingContent = findReadingContent(type, lang);
        if (readingContent) {
          result.push('━━━━━━━━━━━━━━━━━━━━');
          result.push('📖 ' + getReadingTypeLabel(type));
          result.push('━━━━━━━━━━━━━━━━━━━━');
          result.push(readingContent);
        } else {
          result.push('[' + getReadingTypeLabel(type) + ' — ' + (currentLang === 'ar' ? 'سيتم إدراج القراءة هنا' : 'Reading will be inserted here') + ']');
        }
      } else {
        result.push(line);
      }
    });
    return result;
  }
  function renderLiturgyPreview() {
    var p = document.getElementById('liturgy-preview'); if (!p) return;
    var name = fv('liturgy-name') || 'Liturgy';
    var sections = editLiturgyBuffer.sections || [];
    var h = '<h3 style="color:var(--coptic-burgundy);margin-bottom:12px">' + esc(name) + '</h3>';
    h += sections.map(function(s) {
      var lines = resolveReadingPlaceholders(s.content || [], previewLang);
      var rt = s.readingType ? '<span class="reading-badge">' + esc(getReadingTypeLabel(s.readingType)) + '</span>' : '';
      return '<div class="preview-stanza"><div class="stanza-title">' + esc(s.title || '') + rt + '</div>' + lines.map(function(l) { return '<div class="stanza-line">' + esc(l) + '</div>'; }).join('') + '</div>';
    }).join('');
    p.innerHTML = h;
  }
  function renderLiturgySections(sections) {
    editLiturgyBuffer.sections = sections || [];
    var wrap = document.getElementById('liturgy-sections'); if (!wrap) return;
    if (!editLiturgyBuffer.sections.length) { wrap.innerHTML = '<p class="empty-state">No sections</p>'; return; }
    var rtOptions = READING_TYPES.map(function(rt) {
      return '<option value="' + rt.value + '">' + (currentLang === 'ar' ? esc(rt.labelAr) : esc(rt.label)) + '</option>';
    }).join('');
    wrap.innerHTML = editLiturgyBuffer.sections.map(function(s, i) {
      var lines = (s.content || []).map(function(l) { return esc(l); }).join('\n');
      var rtSelect = '<select class="form-control reading-type-select" onchange="editLiturgySectionReadingType(' + i + ',this.value)" style="min-width:180px">' + rtOptions.replace('value="' + (s.readingType || '') + '"', 'value="' + (s.readingType || '') + '" selected') + '</select>';
      return '<div class="editor-block"><div class="editor-block-head"><input type="text" class="form-control editor-title-input" placeholder="Section title" value="' + esc(s.title || '') + '" oninput="editLiturgySectionTitle(' + i + ',this.value)"><button type="button" class="btn btn-danger btn-sm" onclick="removeLiturgySection(' + i + ')">&times;</button></div><div class="editor-block-head" style="margin-bottom:6px"><label style="font-size:0.7rem;color:var(--coptic-burgundy);white-space:nowrap">' + (currentLang === 'ar' ? 'نوع القراءة:' : 'Reading Type:') + '</label>' + rtSelect + '<button type="button" class="btn btn-secondary btn-sm" onclick="insertReadingPlaceholder(' + i + ')" title="Insert reading placeholder">+ {READING}</button></div><textarea class="form-control editor-content" rows="3" placeholder="One paragraph per line. Use {READING:type} to insert actual reading text." oninput="editLiturgySectionContent(' + i + ',this.value)">' + esc(lines) + '</textarea></div>';
    }).join('');
  }
  window.addLiturgySection = function() { editLiturgyBuffer.sections.push({ title: '', content: [''] }); renderLiturgySections(editLiturgyBuffer.sections); renderLiturgyPreview(); };
  window.removeLiturgySection = function(i) { editLiturgyBuffer.sections.splice(i, 1); renderLiturgySections(editLiturgyBuffer.sections); renderLiturgyPreview(); };
  window.editLiturgySectionTitle = function(i, v) { if (editLiturgyBuffer.sections[i]) editLiturgyBuffer.sections[i].title = v; renderLiturgyPreview(); };
  window.editLiturgySectionContent = function(i, v) { if (editLiturgyBuffer.sections[i]) editLiturgyBuffer.sections[i].content = v.split('\n'); renderLiturgyPreview(); };
  window.editLiturgySectionReadingType = function(i, v) { if (editLiturgyBuffer.sections[i]) editLiturgyBuffer.sections[i].readingType = v; renderLiturgyPreview(); };
  window.insertReadingPlaceholder = function(i) {
    var s = editLiturgyBuffer.sections[i]; if (!s) return;
    var type = s.readingType || 'pauline';
    s.content = s.content || [];
    s.content.push('{READING:' + type + '}');
    renderLiturgySections(editLiturgyBuffer.sections);
    renderLiturgyPreview();
  };
  window.editLiturgy = function(lang, id) {
    var list = lang === 'ar' ? appData.liturgy.ar : appData.liturgy.en;
    var item = list.find(function(l) { return (l.id || l.name) === id; });
    if (!item) return;
    openModal('modal-liturgy');
    document.getElementById('liturgy-modal-title').textContent = t('editLiturgy') + ': ' + (item.name || item.id);
    fs('liturgy-lang', lang); fs('liturgy-orig-id', id);
    editOriginal = item;
    fs('liturgy-id', item.id || ''); fs('liturgy-name', item.name || '');
    renderLiturgySections(item.sections || []);
    renderLiturgyPreview();
    document.getElementById('deleteLiturgyBtn').style.display = 'inline-flex';
  };
  window.newLiturgy = function() {
    openModal('modal-liturgy');
    document.getElementById('liturgy-modal-title').textContent = t('editLiturgy');
    editOriginal = null;
    fs('liturgy-lang', 'ar'); fs('liturgy-orig-id', '');
    fs('liturgy-id', ''); fs('liturgy-name', '');
    renderLiturgySections([{ title: '', content: [''] }]);
    renderLiturgyPreview();
    document.getElementById('deleteLiturgyBtn').style.display = 'none';
  };
  async function saveLiturgy() {
    var lang = fv('liturgy-lang');
    var id = (fv('liturgy-id') || '').trim();
    if (!id) { showToast(t('idRequired')); return; }
    var data = editOriginal || {};
    data.id = id; data.name = fv('liturgy-name') || id; data.lang = lang; data.sections = editLiturgyBuffer.sections || [];
    data.updatedAt = new Date().toISOString();
    await saveToFirebase('liturgy', id + '_' + lang, data);
    saveLocal(); closeModal('modal-liturgy'); showToast(t('saved'));
  }
  async function deleteLiturgy() {
    var lang = fv('liturgy-lang'); var id = fv('liturgy-orig-id');
    if (!id) return;
    var list = lang === 'ar' ? appData.liturgy.ar : appData.liturgy.en;
    var idx = list.findIndex(function(l) { return (l.id || l.name) === id; });
    if (idx >= 0) list.splice(idx, 1);
    await deleteFromFirebase('liturgy', id + '_' + lang);
    saveLocal(); closeModal('modal-liturgy'); renderLiturgyList(); showToast(t('deleted'));
  }
  // ================= READING EDITOR =================
  function renderReadingPreview() {
    var p = document.getElementById('reading-preview'); if (!p) return;
    var title = fv('reading-title') || 'Reading';
    var lines = (fv('reading-content') || '').split('\n').filter(function(x) { return x.trim() !== ''; });
    var h = '<h3 style="color:var(--coptic-burgundy);margin-bottom:12px">' + esc(title) + '</h3>';
    h += lines.map(function(l) { return '<div class="stanza-line">' + esc(l) + '</div>'; }).join('');
    p.innerHTML = h;
  }
  window.editReading = function(idx) {
    var item = appData.readings[idx];
    if (!item) return;
    editReadingData = item;
    editOriginal = item;
    openModal('modal-reading');
    document.getElementById('reading-modal-title').textContent = t('editReading') + ': ' + (item.title || idx);
    fs('reading-id', item.id || ''); fs('reading-type', item.type || '');
    fs('reading-title', item.title || '');
    var arr = item.content || item.reads || item.verses || [];
    var txt = arr.map(function(x) { return (typeof x === 'string') ? x : (x.text || ''); }).join('\n');
    fs('reading-content', txt);
    renderReadingPreview();
    document.getElementById('deleteReadingBtn').style.display = 'inline-flex';
  };
  window.newReading = function() {
    editReadingData = null;
    editOriginal = null;
    openModal('modal-reading');
    document.getElementById('reading-modal-title').textContent = t('editReading');
    fs('reading-id', ''); fs('reading-type', 'gospel'); fs('reading-title', ''); fs('reading-content', '');
    renderReadingPreview();
    document.getElementById('deleteReadingBtn').style.display = 'none';
  };
  async function saveReading() {
    var id = (fv('reading-id') || '').trim();
    if (!id) { showToast(t('idRequired')); return; }
    var data = editReadingData || {};
    data.id = id; data.type = fv('reading-type') || data.type || 'reading'; data.title = fv('reading-title') || id;
    var lines = (fv('reading-content') || '').split('\n').map(function(x) { return x.replace(/\r$/, ''); }).filter(function(x) { return x.trim() !== ''; });
    data.content = lines;
    data.updatedAt = new Date().toISOString();
    await saveToFirebase('readings', id, data);
    saveLocal(); closeModal('modal-reading'); showToast(t('saved'));
  }
  async function deleteReading() {
    var id = (fv('reading-id') || '').trim();
    if (!id && editReadingData) id = editReadingData.id;
    if (!id) return;
    var idx = appData.readings.findIndex(function(r) { return r.id === id; });
    if (idx >= 0) appData.readings.splice(idx, 1);
    await deleteFromFirebase('readings', id);
    saveLocal(); closeModal('modal-reading'); renderReadingsList(); showToast(t('deleted'));
  }
  // ================= APP CONTENT EDITOR =================
  function renderContentList() {
    var c = document.getElementById('content-list');
    if (!c) return;
    if (!appData.content.length) {
      c.innerHTML = '<p class="empty-state">' + t('noDataFound') + '</p>';
      return;
    }
    c.innerHTML = appData.content.map(function(item, index) {
      var title = item.titleAr || item.titleEn || item.id || 'Content';
      var category = item.category || 'library';
      return '<div class="item-row" onclick="editContent(' + index + ')">' +
        '<div><span class="item-title">' + esc(title) + '</span><br>' +
        '<span class="item-meta">' + esc(category) + ' | ' + esc(item.id || '') + '</span></div>' +
        '<span>✏️</span></div>';
    }).join('');
  }
  var editContentData = null;
  window.editContent = function(index) {
    var item = appData.content[index];
    if (!item) return;
    editContentData = item;
    fs('content-id', item.id || '');
    fs('content-category', item.category || 'library');
    fs('content-title-en', item.titleEn || '');
    fs('content-title-ar', item.titleAr || '');
    fs('content-title-co', item.titleCo || '');
    fs('content-body-en', item.bodyEn || '');
    fs('content-body-ar', item.bodyAr || '');
    fs('content-body-co', item.bodyCo || '');
    document.getElementById('deleteContentBtn').style.display = 'inline-flex';
    openModal('modal-content');
  };
  window.newContent = function() {
    editContentData = null;
    ['content-id','content-category','content-title-en','content-title-ar','content-title-co','content-body-en','content-body-ar','content-body-co']
      .forEach(function(id) { fs(id, ''); });
    fs('content-category', 'library');
    document.getElementById('deleteContentBtn').style.display = 'none';
    openModal('modal-content');
  };
  async function saveContent() {
    var id = (fv('content-id') || '').trim();
    if (!id) { showToast(t('idRequired')); return; }
    var data = editContentData || {};
    data.id = id;
    data.category = fv('content-category') || 'library';
    data.titleEn = fv('content-title-en') || '';
    data.titleAr = fv('content-title-ar') || '';
    data.titleCo = fv('content-title-co') || '';
    data.bodyEn = fv('content-body-en') || '';
    data.bodyAr = fv('content-body-ar') || '';
    data.bodyCo = fv('content-body-co') || '';
    data.updatedAt = new Date().toISOString();
    var existing = appData.content.findIndex(function(item) { return item.id === id; });
    if (existing < 0) appData.content.push(data);
    await saveToFirebase('content', id, data);
    saveLocal(); closeModal('modal-content'); renderContentList(); updateStats(); showToast(t('saved'));
  }
  async function deleteContent() {
    var id = (fv('content-id') || '').trim();
    if (!id) return;
    appData.content = appData.content.filter(function(item) { return item.id !== id; });
    await deleteFromFirebase('content', id);
    saveLocal(); closeModal('modal-content'); renderContentList(); updateStats(); showToast(t('deleted'));
  }
  async function saveDesign() {
    var d = appData.design;
    var s = function(id) { var e = document.getElementById(id); return e ? e.value : ''; };
    d.nameEn = s('app-name-en'); d.nameAr = s('app-name-ar');
    d.developer = s('app-developer'); d.version = s('app-version');
    d.descEn = s('app-desc-en'); d.descAr = s('app-desc-ar');
    d.colors = {
      primary: s('color-primary'), secondary: s('color-secondary'),
      bgLight: s('color-bg-light'), bgDark: s('color-bg-dark'),
      textLight: s('color-text-light'), textDark: s('color-text-dark'),
      card: s('color-card'), border: s('color-border')
    };
    d.fonts = {
      body: s('font-body'), arabic: s('font-arabic'),
      sizeBase: parseInt(s('font-size-base')) || 16,
      sizeHeading: parseInt(s('font-size-heading')) || 24
    };
    d.logoUrl = s('logo-url'); d.iconUrl = s('icon-url');
    d.bgLightUrl = s('bg-light-url'); d.bgDarkUrl = s('bg-dark-url');
    d.updatedAt = new Date().toISOString();
    await saveToFirebase('settings', 'design', d);
    saveLocal(); showToast(t('saved'));
  }
  // ============================================================
  // IMPORT / EXPORT
  // ============================================================
  function importJSON(jsonStr) {
    try {
      var data = JSON.parse(jsonStr);
      var count = 0;
      if (data.traneem) {
        data.traneem.ar.forEach(function(item) { saveToFirebase('traneem', (item.id || item.name || 'hymn') + '_ar', item); count++; });
        data.traneem.en.forEach(function(item) { saveToFirebase('traneem', (item.id || item.name || 'hymn') + '_en', item); count++; });
      }
      if (data.bible) {
        data.bible.ar.forEach(function(item) { saveToFirebase('bible', (item.bookId || 'book') + '_ar', item); count++; });
        data.bible.en.forEach(function(item) { saveToFirebase('bible', (item.bookId || 'book') + '_en', item); count++; });
      }
      if (data.agpeya) {
        data.agpeya.ar.forEach(function(item) { saveToFirebase('agpeya', (item.id || 'prayer') + '_ar', item); count++; });
        data.agpeya.en.forEach(function(item) { saveToFirebase('agpeya', (item.id || 'prayer') + '_en', item); count++; });
      }
      if (data.liturgy) {
        data.liturgy.ar.forEach(function(item) { saveToFirebase('liturgy', (item.id || item.name || 'liturgy') + '_ar', item); count++; });
        data.liturgy.en.forEach(function(item) { saveToFirebase('liturgy', (item.id || item.name || 'liturgy') + '_en', item); count++; });
      }
      if (data.readings) {
        data.readings.forEach(function(item) { saveToFirebase('readings', item.id || item.type || 'reading', item); count++; });
      }
      if (data.content) {
        data.content.forEach(function(item) {
          saveToFirebase('content', item.id || item.titleEn || 'content', item);
          count++;
        });
      }
      if (data.design) saveToFirebase('settings', 'design', data.design);
      showToast(t('imported') + ' (' + count + ')');
    } catch(e) { showToast(t('invalidJson')); }
  }

  function downloadJSON(data, filename) {
    var blob = new Blob([data], { type: 'application/json' });
    var url = URL.createObjectURL(blob);
    var a = document.createElement('a');
    a.href = url; a.download = filename; a.click();
    URL.revokeObjectURL(url);
  }

  function exportAllJSON() {
    return JSON.stringify(appData, null, 2);
  }

  async function importBundledTraneem() {
    var ids = ['doxology', 'lords-prayer', 'trisagion'];
    var languages = ['ar', 'en'];
    var imported = 0;
    try {
      for (var li = 0; li < languages.length; li++) {
        for (var hi = 0; hi < ids.length; hi++) {
          var response = await fetch('../bible/assets/traneem/' + languages[li] + '/' + ids[hi] + '.json');
          if (!response.ok) throw new Error('Bundled hymn asset not found');
          var item = await response.json();
          item.lang = languages[li];
          var list = languages[li] === 'ar' ? appData.traneem.ar : appData.traneem.en;
          var existing = list.findIndex(function(hymn) { return hymn.id === item.id; });
          if (existing >= 0) list[existing] = item;
          else list.push(item);
          await saveToFirebase('traneem', item.id + '_' + languages[li], item);
          imported++;
        }
      }
      saveLocal();
      renderTraneemList();
      updateStats();
      showToast('Imported ' + imported + ' bundled hymn records');
    } catch (error) {
      showToast('Run admin from the workspace server, then try again');
    }
  }

  function installContentAdminUI() {
    if (document.getElementById('content-list')) return;
    var nav = document.querySelector('.sidebar-nav');
    if (nav) {
      var navButton = document.createElement('button');
      navButton.className = 'nav-item';
      navButton.dataset.section = 'content';
      navButton.innerHTML = '<span class="nav-icon">🧩</span><span>' + t('appContent') + '</span>';
      navButton.addEventListener('click', function() { showSection('content'); });
      nav.appendChild(navButton);
    }
    var main = document.querySelector('.main-content');
    if (!main) return;
    var section = document.createElement('section');
    section.id = 'content';
    section.className = 'content-section';
    section.innerHTML = '<h2>' + t('appContent') + '</h2>' +
      '<p class="section-desc">Edit library titles and full text in Arabic, English, and Coptic.</p>' +
      '<div class="section-header"><button class="btn btn-primary" id="addContentBtn">➕ Add App Content</button></div>' +
      '<div id="content-list" class="items-list"></div>';
    main.appendChild(section);

    var modal = document.createElement('div');
    modal.id = 'modal-content';
    modal.className = 'modal';
    modal.style.display = 'none';
    modal.innerHTML = '<div class="modal-content modal-large">' +
      '<div class="modal-header"><h3>App Content</h3><button class="btn-close" onclick="closeModal(\'modal-content\')">X</button></div>' +
      '<div class="modal-body">' +
      '<div class="form-row"><div class="form-group"><label>ID</label><input id="content-id" class="form-control"></div><div class="form-group"><label>Category</label><input id="content-category" class="form-control" placeholder="library, readings, rites..."></div></div>' +
      '<h4>Titles</h4><div class="form-row"><div class="form-group"><label>English</label><input id="content-title-en" class="form-control"></div><div class="form-group"><label>Arabic</label><input id="content-title-ar" class="form-control" dir="rtl"></div><div class="form-group"><label>Coptic</label><input id="content-title-co" class="form-control"></div></div>' +
      '<h4>Full Text</h4><div class="form-group"><label>English</label><textarea id="content-body-en" class="form-control" rows="7"></textarea></div>' +
      '<div class="form-group"><label>Arabic</label><textarea id="content-body-ar" class="form-control" rows="7" dir="rtl"></textarea></div>' +
      '<div class="form-group"><label>Coptic</label><textarea id="content-body-co" class="form-control" rows="7"></textarea></div>' +
      '</div><div class="modal-footer"><button class="btn btn-secondary" onclick="closeModal(\'modal-content\')">Cancel</button><button class="btn btn-danger" id="deleteContentBtn">Delete</button><button class="btn btn-primary" id="saveContentBtn">Save</button></div></div>';
    document.body.appendChild(modal);
    document.getElementById('addContentBtn').addEventListener('click', window.newContent);
    document.getElementById('saveContentBtn').addEventListener('click', saveContent);
    document.getElementById('deleteContentBtn').addEventListener('click', deleteContent);
    renderContentList();
  }
  // ============================================================
  // SAMPLE DATA LOADERS
  // ============================================================
  function loadSampleTraneem() {
    saveToFirebase('traneem', 'trisagion_ar', { id: 'trisagion', title: 'Trisagion', arabicTitle: '\u0627\u0644\u0642\u062F\u0648\u0633', category: 'Liturgical', categoryAr: '\u0637\u0642\u0633\u064A\u0629', stanzas: [{ title: '\u0627\u0644\u062A\u0642\u062F\u064A\u0633', lines: ['\u0642\u062F\u0648\u0633 \u0627\u0644\u0644\u0647\u060C \u0642\u062F\u0648\u0633 \u0627\u0644\u0642\u0648\u064A\u060C \u0642\u062F\u0648\u0633 \u0627\u0644\u062D\u064A \u0627\u0644\u0630\u064A \u0644\u0627 \u064A\u0645\u0648\u062A', '\u0627\u0631\u062D\u0645\u0646\u0627'] }], lang: 'ar', updatedAt: new Date().toISOString() });
    saveToFirebase('traneem', 'trisagion_en', { id: 'trisagion', title: 'Holy God', category: 'Liturgical', stanzas: [{ title: 'The Sanctus', lines: ['Holy God, Holy Mighty, Holy Immortal', 'Have mercy on us'] }], lang: 'en', updatedAt: new Date().toISOString() });
    showToast('Sample loaded');
  }
  function loadSampleBible() {
    saveToFirebase('bible', 'genesis_ar', { bookId: 'genesis', bookName: '\u0627\u0644\u062A\u0643\u0648\u064A\u0646', chapters: [{ chapterNumber: 1, verses: [{ number: 1, text: '\u0641\u064A \u0627\u0644\u0628\u062F\u0621 \u062E\u0644\u0642 \u0627\u0644\u0644\u0647 \u0627\u0644\u0633\u0645\u0627\u0648\u0627\u062A \u0648\u0627\u0644\u0623\u0631\u0636' }, { number: 2, text: '\u0648\u0643\u0627\u0646\u062A \u0627\u0644\u0623\u0631\u0636 \u062E\u0631\u0628\u0629 \u0648\u062E\u0627\u0644\u064A\u0629' }] }], lang: 'ar', updatedAt: new Date().toISOString() });
    saveToFirebase('bible', 'genesis_en', { bookId: 'genesis', bookName: 'Genesis', chapters: [{ chapterNumber: 1, verses: [{ number: 1, text: 'In the beginning God created the heavens and the earth.' }, { number: 2, text: 'Now the earth was formless and empty.' }] }], lang: 'en', updatedAt: new Date().toISOString() });
    showToast('Sample loaded');
  }
  function loadSampleAgpeya() {
    saveToFirebase('agpeya', 'prime_ar', { id: 'prime', name: '\u0628\u0627\u0643\u0631', englishName: 'Morning Prayer', opening: { title: '\u0645\u0642\u062F\u0645\u0629', content: ['\u0628\u0627\u0633\u0645 \u0627\u0644\u0622\u0628 \u0648\u0627\u0644\u0627\u0628\u0646 \u0648\u0627\u0644\u0631\u0648\u062D \u0627\u0644\u0642\u062F\u0633'], inline: true }, lang: 'ar', updatedAt: new Date().toISOString() });
    saveToFirebase('agpeya', 'prime_en', { id: 'prime', name: 'Morning', englishName: 'Morning Prayer', opening: { title: 'Introduction', content: ['In the name of the Father, Son, and Holy Spirit'], inline: true }, lang: 'en', updatedAt: new Date().toISOString() });
    showToast('Sample loaded');
  }
  function loadSampleLiturgy() {
    saveToFirebase('liturgy', 'anaphora_ar', { id: 'anaphora', name: '\u0627\u0644\u0623\u0646\u0627\u0641\u0648\u0631\u0627', sections: [{ title: '\u0627\u0644\u0623\u0646\u0627\u0641\u0648\u0631\u0627', content: ['\u064A\u0627 \u0631\u0628 \u0627\u0631\u062D\u0645\u0646\u0627'] }], lang: 'ar', updatedAt: new Date().toISOString() });
    saveToFirebase('liturgy', 'anaphora_en', { id: 'anaphora', name: 'The Anaphora', sections: [{ title: 'The Anaphora', content: ['O Lord have mercy'] }], lang: 'en', updatedAt: new Date().toISOString() });
    loadSampleReadings();
    showToast('Sample loaded');
  }
  function loadSampleReadings() {
    saveToFirebase('readings', 'pauline', { id: 'pauline', type: 'pauline', title: 'Romans 1:1-7', content: ['Paul, a servant of Christ Jesus, called to be an apostle and set apart for the gospel of God, the gospel he promised beforehand through his prophets in the Holy Scriptures regarding his Son, who as to his earthly life was a descendant of David, and who through the Spirit of holiness was appointed the Son of God in power by his resurrection from the dead: Jesus Christ our Lord. Through him we received grace and apostleship to call all the Gentiles to the obedience that comes from faith for his name sake. And you also are among those Gentiles who are called to belong to Jesus Christ. To all in Rome who are loved by God and called to be his saints: Grace and peace to you from God our Father and from the Lord Jesus Christ.'], updatedAt: new Date().toISOString() });
    saveToFirebase('readings', 'catholic', { id: 'catholic', type: 'catholic', title: '\u0627\u0644\u0631\u0633\u0627\u0644\u0629 \u0627\u0644\u062C\u0627\u0645\u0639\u0629 - \u0628\u0637\u0631\u0633 \u0627\u0644\u0623\u0648\u0644 1:1-2', content: ['\u0628\u0637\u0631\u0633 \u0631\u0633\u0648\u0644 \u064A\u0633\u0648\u0639 \u0627\u0644\u0645\u0633\u064A\u062D \u0625\u0644\u0649 \u0627\u0644\u063A\u0631\u0628\u0627\u0621 \u0627\u0644\u0645\u062A\u0634\u062A\u062A\u064A\u0646 \u0641\u064A \u0628\u0646\u062A\u0648\u0633\u064A\u0627 \u0648\u063A\u0644\u0627\u0637\u064A\u0629 \u0648\u0643\u0628\u0627\u062F\u0648\u0643\u064A\u0627 \u0648\u0623\u0633\u064A\u0627 \u0648\u0628\u064A\u062B\u064A\u0646\u064A\u0627\u060C \u0627\u0644\u0630\u064A\u0646 \u0627\u062E\u062A\u0627\u0631\u0647\u0645 \u0627\u0644\u0644\u0647 \u0627\u0644\u0622\u0628 \u062D\u0633\u0628 \u0633\u0628\u0642 \u0639\u0644\u0645\u0647\u060C \u0648\u0628\u0627\u0644\u0631\u0648\u062D \u0627\u0644\u0642\u062F\u0633 \u0627\u0644\u0645\u0631\u0633\u0644\u064A\u0646 \u0644\u0637\u0627\u0639\u0629 \u064A\u0633\u0648\u0639 \u0627\u0644\u0645\u0633\u064A\u062D \u0648\u0631\u0634 \u062F\u0645\u0647. \u0644\u0643\u0645 \u0631\u062D\u0645\u0629 \u0648\u0633\u0644\u0627\u0645 \u0645\u0636\u0627\u0639\u0641\u064A\u0646.'], updatedAt: new Date().toISOString() });
    saveToFirebase('readings', 'acts', { id: 'acts', type: 'acts', title: '\u0623\u0639\u0645\u0627\u0644 \u0627\u0644\u0631\u0633\u0644 1:1-8', content: ['\u0627\u0644\u0643\u062A\u0627\u0628 \u0627\u0644\u0623\u0648\u0644 \u062A\u0644\u0642\u064A\u062A \u064A\u0627 \u062A\u0627\u0648\u0641\u064A\u0644\u0648\u0633 \u0639\u0646 \u0643\u0644 \u0645\u0627 \u0628\u062F\u0623 \u064A\u0633\u0648\u0639 \u064A\u0635\u0646\u0639 \u0648\u064A\u0639\u0644\u0645. \u0623\u0645\u0631\u0647\u0645 \u0623\u0644\u0627 \u064A\u063A\u0627\u062F\u0631\u0648\u0627 \u0623\u0648\u0631\u0634\u0644\u064A\u0645 \u0641\u0633\u062A\u0646\u0627\u0644\u0648\u0646 \u0642\u0648\u0629 \u0628\u0645\u062C\u064A\u0621 \u0627\u0644\u0631\u0648\u062D \u0627\u0644\u0642\u062F\u0633 \u0639\u0644\u064A\u0643\u0645 \u0648\u062A\u0643\u0648\u0646\u0648\u0646 \u0644\u064A \u0634\u0647\u0648\u062F\u0627 \u0641\u064A \u0623\u0648\u0631\u0634\u0644\u064A\u0645 \u0648\u0643\u0644 \u0627\u0644\u064A\u0647\u0648\u062F\u064A\u0629 \u0648\u0627\u0644\u0633\u0627\u0645\u0631\u0629 \u0648\u0623\u0642\u0635\u0649 \u0627\u0644\u0623\u0631\u0636.'], updatedAt: new Date().toISOString() });
    saveToFirebase('readings', 'synaxar', { id: 'synaxar', type: 'synaxar', title: '\u0627\u0644\u0633\u0646\u0643\u0633\u0627\u0631 - \u0627\u0644\u0642\u062F\u064A\u0633 \u0645\u0631\u0642\u0633', content: ['\u0641\u064A \u0647\u0630\u0627 \u0627\u0644\u064A\u0648\u0645 \u062A\u0630\u0643\u0631 \u0627\u0644\u0643\u0646\u064A\u0633\u0629 \u0627\u0644\u0642\u0628\u0637\u064A\u0629 \u0633\u064A\u0631\u0629 \u0627\u0644\u0642\u062F\u064A\u0633 \u0645\u0631\u0642\u0633 \u0631\u0633\u0648\u0644 \u0627\u0644\u0645\u0633\u064A\u062D. \u0648\u0644\u062F \u0641\u064A \u0646\u0627\u0632\u0627\u0631\u064A\u0627 \u0648\u0627\u0646\u062A\u062E\u0628\u0647 \u0627\u0644\u0631\u0628 \u0631\u0633\u0648\u0644\u0627 \u0623\u062D\u062F \u0627\u0644\u0627\u062B\u0646\u064A \u0639\u0634\u0631 \u0631\u0633\u0648\u0644\u0627. \u0628\u0634\u0631 \u0627\u0644\u0645\u0645\u0644\u0643\u0629 \u0641\u064A \u0627\u0644\u064A\u0647\u0648\u062F\u064A\u0629 \u0648\u0623\u0646\u0637\u0627\u0643\u064A\u0629 \u0648\u0623\u0633\u0633 \u0643\u0646\u064A\u0633\u0629 \u0627\u0644\u0625\u0633\u0643\u0646\u062F\u0631\u064A\u0629. \u062A\u0646\u064A\u062D \u0628\u0627\u0644\u0633\u0644\u0627\u0645 \u0645\u0639 \u0631\u0628\u0646\u0627 \u064A\u0633\u0648\u0639 \u0627\u0644\u0645\u0633\u064A\u062D.'], updatedAt: new Date().toISOString() });
    saveToFirebase('readings', 'psalm', { id: 'psalm', type: 'psalm', title: '\u0627\u0644\u0645\u0632\u0645\u0648\u0631 150', content: ['\u0647\u0644\u0644\u0648\u064A\u0627! \u0633\u0628\u062D\u0648\u0627 \u0627\u0644\u0644\u0647 \u0641\u064A \u0642\u062F\u0633\u0647\u060C \u0633\u0628\u062D\u0648\u0647 \u0641\u064A \u062C\u0644\u062F \u0642\u0648\u062A\u0647. \u0633\u0628\u062D\u0648\u0647 \u0644\u0623\u062C\u0644 \u0623\u0641\u0639\u0627\u0644\u0647 \u0627\u0644\u0639\u0638\u0627\u0645\u060C \u0633\u0628\u062D\u0648\u0647 \u0628\u062D\u0633\u0628 \u0643\u062B\u0631\u0629 \u0639\u0638\u0645\u062A\u0647. \u0643\u0644 \u0646\u0633\u0645\u0629 \u062A\u0633\u0628\u062D \u0627\u0633\u0645 \u0627\u0644\u0631\u0628 \u0627\u0644\u0642\u062F\u0648\u0633. \u0647\u0644\u0644\u0648\u064A\u0627!'], updatedAt: new Date().toISOString() });
    saveToFirebase('readings', 'gospel', { id: 'gospel', type: 'gospel', title: '\u0627\u0644\u0625\u0646\u062C\u064A\u0644 - \u064A\u0648\u062D\u0646\u0627 1:1-5', content: ['\u0641\u064A \u0627\u0644\u0628\u062F\u0621 \u0643\u0627\u0646 \u0627\u0644\u0643\u0644\u0645\u0629\u060C \u0648\u0643\u0627\u0646 \u0627\u0644\u0643\u0644\u0645\u0629 \u0639\u0646\u062F \u0627\u0644\u0644\u0647\u060C \u0648\u0643\u0627\u0646 \u0627\u0644\u0643\u0644\u0645\u0629 \u0647\u0648 \u0627\u0644\u0644\u0647. \u0643\u0644 \u0628\u0647 \u0643\u0627\u0646\u060C \u0648\u0628\u062F\u0648\u0646\u0647 \u0645\u0627 \u0643\u0627\u0646 \u0634\u064A\u0621 \u0645\u0645\u0627 \u0643\u0627\u0646. \u0641\u064A\u0647 \u0643\u0627\u0646\u062A \u062D\u064A\u0627\u0629\u060C \u0648\u0627\u0644\u062D\u064A\u0627\u0629 \u0643\u0627\u0646\u062A \u0646\u0648\u0631 \u0627\u0644\u0646\u0627\u0633. \u0627\u0644\u0645\u062C\u062F \u0644\u0644\u0644\u0647 \u0625\u0644\u0649 \u0627\u0644\u0623\u0628\u062F. \u0622\u0645\u064A\u0646.'], updatedAt: new Date().toISOString() });
  }
  // ============================================================
  // INITIALIZATION
  // ============================================================
  document.addEventListener('DOMContentLoaded', function() {
    // Apply saved language
    var html = document.documentElement;
    html.setAttribute('dir', currentLang === 'ar' ? 'rtl' : 'ltr');
    html.setAttribute('lang', currentLang);

    loadLocal();
    installContentAdminUI();

    var hymnSection = document.getElementById('traneem');
    var hymnHeader = hymnSection && hymnSection.querySelector('.section-header');
    if (hymnHeader && !document.getElementById('importBundledTraneemBtn')) {
      var importHymns = document.createElement('button');
      importHymns.id = 'importBundledTraneemBtn';
      importHymns.className = 'btn btn-secondary';
      importHymns.textContent = 'Import bundled app hymns';
      importHymns.addEventListener('click', importBundledTraneem);
      hymnHeader.appendChild(importHymns);
    }

    var f = function(id) { return document.getElementById(id); };
    var bind = function(el, ev, fn) { if (el) el.addEventListener(ev, fn); };

    // Navigation
    document.querySelectorAll('.nav-item').forEach(function(btn) {
      bind(btn, 'click', function() { showSection(btn.dataset.section); });
    });

    // Language toggle
    bind(f('langToggle'), 'click', toggleLanguage);

    // Traneem buttons
    // Traneem buttons
    bind(f('addHymnBtn'), 'click', window.newTraneem);

    bind(f('saveHymnBtn'), 'click', saveHymn);
    bind(f('deleteHymnBtn'), 'click', deleteHymn);

    // Bible buttons
    bind(f('addBibleBookBtn'), 'click', window.newBible);

    bind(f('saveBibleBtn'), 'click', saveBible);
    bind(f('deleteBibleBtn'), 'click', deleteBible);

    // Agpeya buttons
    bind(f('addAgpeyaBtn'), 'click', window.newAgpeya);

    bind(f('saveAgpeyaBtn'), 'click', saveAgpeya);
    bind(f('deleteAgpeyaBtn'), 'click', deleteAgpeya);

    // Liturgy buttons
    bind(f('addLiturgyBtn'), 'click', window.newLiturgy);

    bind(f('saveLiturgyBtn'), 'click', saveLiturgy);
    bind(f('deleteLiturgyBtn'), 'click', deleteLiturgy);

    // Readings buttons
    bind(f('addReadingBtn'), 'click', window.newReading);

    bind(f('saveReadingBtn'), 'click', saveReading);
    bind(f('deleteReadingBtn'), 'click', deleteReading);
    bind(f('saveReadingBtn'), 'click', saveReading);
    bind(f('deleteReadingBtn'), 'click', deleteReading);

    // Design
    bind(f('saveDesignBtn'), 'click', saveDesign);
    // Import / Export
    bind(f('exportAllBtn'), 'click', function() { downloadJSON(exportAllJSON(), 'coptic-data.json'); });
    bind(f('importBtn'), 'click', function() { if (f('importFile')) f('importFile').click(); });
    bind(f('importFile'), 'change', function(e) {
      if (e.target.files.length > 0) {
        var reader = new FileReader();
        reader.onload = function(ev) { importJSON(ev.target.result); };
        reader.readAsText(e.target.files[0]);
      }
    });
    bind(f('importPasteBtn'), 'click', function() {
      if (f('importPaste') && f('importPaste').value) importJSON(f('importPaste').value);
    });
    bind(f('importJson'), 'change', function(e) {
      if (e.target.files.length > 0) {
        var reader = new FileReader();
        reader.onload = function(ev) { importJSON(ev.target.result); };
        reader.readAsText(e.target.files[0]);
      }
    });

    // Sample data
    bind(f('loadSampleTraneem'), 'click', loadSampleTraneem);
    bind(f('loadSampleBible'), 'click', loadSampleBible);
    bind(f('loadSampleAgpeya'), 'click', loadSampleAgpeya);
    bind(f('loadSampleLiturgy'), 'click', loadSampleLiturgy);
    bind(f('loadSampleReadings'), 'click', loadSampleReadings);

    // Preview language radio buttons
    var previewLangRadios = document.querySelectorAll('input[name=previewLang]');
    previewLangRadios.forEach(function(radio) {
      radio.addEventListener('change', function() {
        if (this.checked) {
          previewLang = this.value;
          renderPreviewContent();
          renderLiturgyPreview();
        }
      });
    });
    // Preview mode buttons
    bind(f('previewModeLight'), 'click', function() { previewTheme = 'light'; renderPreviewContent(); });
    bind(f('previewModeDark'), 'click', function() { previewTheme = 'dark'; renderPreviewContent(); });

    // ================= CHURCH MAP SEARCH =================
    var churchMap = null;
    var churchMarkers = [];
    var churchData = appData.churches || [];
    var tempMarker = null;

    function initChurchMap() {
      var mapEl = document.getElementById('churchMap');
      if (!mapEl || churchMap) return;
      churchMap = L.map('churchMap').setView([30.0444, 31.2357], 5);
      L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', { attribution: '© OpenStreetMap', maxZoom: 19 }).addTo(churchMap);
      churchMap.on('click', function(e) {
        var lat = e.latlng.lat.toFixed(6);
        var lng = e.latlng.lng.toFixed(6);
        if (f('churchAddLat')) f('churchAddLat').value = lat;
        if (f('churchAddLng')) f('churchAddLng').value = lng;
        if (tempMarker) churchMap.removeLayer(tempMarker);
        tempMarker = L.marker([e.latlng.lat, e.latlng.lng]).addTo(churchMap).bindPopup('Selected: ' + lat + ', ' + lng).openPopup();
        showToast('Location set: ' + lat + ', ' + lng);
      });
      renderChurchMarkers();
    }

    function renderChurchMarkers() {
      if (!churchMap) return;
      churchMarkers.forEach(function(m) { churchMap.removeLayer(m); });
      churchMarkers = [];
      churchData.forEach(function(ch) {
        if (ch.lat && ch.lng) {
          var marker = L.marker([ch.lat, ch.lng]).addTo(churchMap).bindPopup('<b>' + esc(ch.name || 'Church') + '</b><br>' + esc(ch.location || ''));
          churchMarkers.push(marker);
        }
      });
    }

    window.searchChurches = function() {
      var query = (f('churchSearchInput') || '').trim();
      var country = f('churchCountryFilter') || '';
      if (!query && !country) { showToast('Please enter a search term'); return; }
      showToast('Searching...');
      fetch('https://nominatim.openstreetmap.org/search?format=json&q=' + encodeURIComponent(query + ' church') + '&limit=15')
        .then(function(r) { return r.json(); })
        .then(function(data) {
          var resultsEl = document.getElementById('churchResults');
          var countEl = document.getElementById('churchResultCount');
          churchMarkers.forEach(function(m) { if (m !== tempMarker) churchMap.removeLayer(m); });
          churchMarkers = [];
          if (!data.length) { resultsEl.innerHTML = '<p class="empty-state">No churches found</p>'; if (countEl) countEl.textContent = '(0)'; return; }
          if (countEl) countEl.textContent = '(' + data.length + ' found)';
          var html = ''; var bounds = [];
          data.forEach(function(r) {
            var lat = parseFloat(r.lat); var lng = parseFloat(r.lon);
            var marker = L.marker([lat, lng]).addTo(churchMap).bindPopup('<b>' + esc(r.display_name || 'Church') + '</b>');
            churchMarkers.push(marker); bounds.push([lat, lng]);
            html += '<div class="church-result-item" onclick="focusChurch(' + lat + ',' + lng + ')"><b>' + esc(r.display_name || 'Church') + '</b><br><span style="color:#888;font-size:0.8em">' + lat.toFixed(4) + ', ' + lng.toFixed(4) + '</span></div>';
          });
          resultsEl.innerHTML = html;
          if (bounds.length) churchMap.fitBounds(bounds, { padding: [50, 50], maxZoom: 14 });
        })
        .catch(function() { showToast('Search failed'); });
    };

    window.focusChurch = function(lat, lng) { if (churchMap) churchMap.setView([lat, lng], 16); };

    window.locateUserChurches = function() {
      if (!navigator.geolocation) { showToast('Geolocation not supported'); return; }
      navigator.geolocation.getCurrentPosition(function(pos) {
        churchMap.setView([pos.coords.latitude, pos.coords.longitude], 13);
        if (tempMarker) churchMap.removeLayer(tempMarker);
        tempMarker = L.marker([pos.coords.latitude, pos.coords.longitude]).addTo(churchMap).bindPopup('You are here').openPopup();
        window.searchChurches();
      }, function() { showToast('Could not get location'); });
    };

    window.addChurchToDatabase = function() {
      var name = (f('churchAddName') || '').trim();
      var location = (f('churchAddLocation') || '').trim();
      var lat = parseFloat(f('churchAddLat')) || 0;
      var lng = parseFloat(f('churchAddLng')) || 0;
      var denom = f('churchAddDenom') || 'coptic';
      var notes = f('churchAddNotes') || '';
      if (!name) { showToast('Church name required'); return; }
      if (!lat || !lng) { showToast('Select location on map'); return; }
      var church = { id: 'church_' + Date.now(), name: name, location: location, lat: lat, lng: lng, denom: denom, notes: notes, updatedAt: new Date().toISOString() };
      churchData.push(church);
      appData.churches = churchData;
      saveToFirebase('settings', 'churches', churchData);
      saveLocal();
      renderChurchMarkers();
      showToast('Church added: ' + name);
      f('churchAddName', ''); f('churchAddLocation', ''); f('churchAddLat', ''); f('churchAddLng', ''); f('churchAddNotes', '');
    };

    var churchSearchBtn = f('churchSearchBtn');
    if (churchSearchBtn) churchSearchBtn.addEventListener('click', window.searchChurches);
    var churchLocateBtn = f('churchLocateBtn');
    if (churchLocateBtn) churchLocateBtn.addEventListener('click', window.locateUserChurches);
    var churchAddBtn = f('churchAddBtn');
    if (churchAddBtn) churchAddBtn.addEventListener('click', window.addChurchToDatabase);

    var origShowSection = showSection;
    showSection = function(section) {
      origShowSection(section);
      if (section === 'churches') { setTimeout(initChurchMap, 100); }
    };

    // Logo & backgrounds
    bind(f('logo-upload'), 'change', function(e) {
      var file = e.target.files[0]; if (!file) return;
      var reader = new FileReader();
      reader.onload = function(ev) {
        appData.design.logoUrl = ev.target.result;
        if (f('logo-url')) f('logo-url').value = ev.target.result;
        saveDesign();
      };
      reader.readAsDataURL(file);
    });
    bind(f('bg-light-upload'), 'change', function(e) {
      var file = e.target.files[0]; if (!file) return;
      var reader = new FileReader();
      reader.onload = function(ev) {
        appData.design.bgLightUrl = ev.target.result;
        if (f('bg-light-url')) f('bg-light-url').value = ev.target.result;
        saveDesign();
      };
      reader.readAsDataURL(file);
    });
    bind(f('bg-dark-upload'), 'change', function(e) {
      var file = e.target.files[0]; if (!file) return;
      var reader = new FileReader();
      reader.onload = function(ev) {
        appData.design.bgDarkUrl = ev.target.result;
        if (f('bg-dark-url')) f('bg-dark-url').value = ev.target.result;
        saveDesign();
      };
      reader.readAsDataURL(file);
    });
    bind(f('icon-upload'), 'change', function(e) {
      var file = e.target.files[0]; if (!file) return;
      var reader = new FileReader();
      reader.onload = function(ev) {
        appData.design.iconUrl = ev.target.result;
        if (f('icon-url')) f('icon-url').value = ev.target.result;
        saveDesign();
      };
      reader.readAsDataURL(file);
    });

    // Reset
    bind(f('resetAllBtn'), 'click', function() {
      if (confirm(t('confirmReset'))) {
        localStorage.removeItem(STORAGE_KEY);
        location.reload();
      }
    });

    // Online / offline detection
    bind(window, 'online', updateConnectionStatus);
    bind(window, 'offline', updateConnectionStatus);

    // Setup Firebase real-time listeners
    setupFirebase();

    // Initial render
    refreshAll();
    applyTranslations();
  });
})();
