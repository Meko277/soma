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

  var appData = {
    traneem: { ar: [], en: [] },
    bible: { ar: [], en: [] },
    agpeya: { ar: [], en: [] },
    liturgy: { ar: [], en: [] },
    readings: [],
    design: {
      nameEn: 'Coptic Companion', nameAr: 'الرفيق القبطي',
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

  // ============================================================
  // TRANSLATIONS
  // ============================================================
  var I18N = {
    en: {
      appTitle: 'Coptic Companion', appSubtitle: 'Full App Admin',
      dashboard: 'Dashboard', importExport: 'Import / Export',
      traneem: 'Traneem', bible: 'Bible', agpeya: 'Agpeya',
      liturgy: 'Liturgy', readings: 'Readings', themeDesign: 'Theme & Design',
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
      invalidJson: 'Invalid JSON', idRequired: 'ID required',
      confirmReset: 'Reset all data?', stanzas: 'stanzas', chapters: 'chapters',
      syncing: 'Syncing...', online: 'Online', offline: 'Offline',
      switchLang: 'عربي'
    },
    ar: {
      appTitle: 'الرفيق القبطي', appSubtitle: 'لوحة الإدارة',
      dashboard: 'الرئيسية', importExport: 'استيراد / تصدير',
      traneem: 'الترانيم', bible: 'الكتاب المقدس', agpeya: 'الأجبية',
      liturgy: 'القداس', readings: 'القراءات', themeDesign: 'المظهر',
      preview: 'معاينة', settings: 'الإعدادات',
      overview: 'نظرة عامة على المحتوى.',
      traneemHymns: 'ترانيم', bibleBooks: 'أسفار',
      agpeyaPrayers: 'صلوات', liturgyParts: 'أجزاء القداس',
      copticReadings: 'قراءات', themes: 'مظاهر',
      howToUse: 'كيفية الاستخدام', dataSource: 'مصدر البيانات',
      noData: 'لا توجد بيانات', dataLoaded: 'تم التحميل!',
      help1: 'استيراد: ارفع ملفات.',
      help2: 'تعديل: تصفح الأقسام.',
      help3: 'معاينة: شاهد المحتوى.',
      help4: 'مظهر: خصص الإعدادات.',
      help5: 'تصدير: تحميل ZIP.',
      noDataFound: 'لا توجد بيانات.',
      editHymn: 'تعديل ترنيمة', editBible: 'تعديل سفر', editPrayer: 'تعديل صلاة',
      editLiturgy: 'تعديل قداس', editReading: 'تعديل قراءة',
      jsonData: 'بيانات JSON', livePreview: 'معاينة مباشرة',
      cancel: 'إلغاء', deleteBtn: 'حذف', saveBtn: 'حفظ',
      saved: 'تم الحفظ!', deleted: 'تم الحذف!', imported: 'تم الاستيراد!',
      invalidJson: 'JSON غير صالح', idRequired: 'المعرف مطلوب',
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
      if (raw) appData = JSON.parse(raw);
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
      el.textContent = '🟢 ' + t('online');
      el.className = 'status-online';
    } else {
      el.textContent = '🔴 ' + t('offline');
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
      appData.traneem.ar.length + appData.traneem.en.length;
    if (el('stat-bible')) el('stat-bible').textContent =
      appData.bible.ar.length + appData.bible.en.length;
    if (el('stat-agpeya')) el('stat-agpeya').textContent =
      appData.agpeya.ar.length + appData.agpeya.en.length;
    if (el('stat-liturgy')) el('stat-liturgy').textContent =
      appData.liturgy.ar.length + appData.liturgy.en.length;
    if (el('stat-readings')) el('stat-readings').textContent =
      appData.readings.length;
    if (el('stat-themes')) el('stat-themes').textContent = 1;
    var status = el('data-source-status');
    if (status) {
      status.textContent = hasData() ? t('dataLoaded') : t('noData');
      status.className = hasData() ? 'status-ok' : 'status-warning';
    }
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
    renderDesignForm();
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
      const col = function(name) { return collection(db, name); };
      // Real-time listeners for each collection
      onSnapshot(col('traneem'), function(snap) {
        appData.traneem.ar = []; appData.traneem.en = [];
        snap.forEach(function(d) {
          var data = d.data();
          if (data.lang === 'ar') appData.traneem.ar.push(data);
          else appData.traneem.en.push(data);
        });
        syncLocalFromState('traneem');
        renderTraneemList(); updateStats();
      });
      onSnapshot(col('bible'), function(snap) {
        appData.bible.ar = []; appData.bible.en = [];
        snap.forEach(function(d) {
          var data = d.data();
          if (data.lang === 'ar') appData.bible.ar.push(data);
          else appData.bible.en.push(data);
        });
        renderBibleList(); updateStats();
      });
      onSnapshot(col('agpeya'), function(snap) {
        appData.agpeya.ar = []; appData.agpeya.en = [];
        snap.forEach(function(d) {
          var data = d.data();
          if (data.lang === 'ar') appData.agpeya.ar.push(data);
          else appData.agpeya.en.push(data);
        });
        renderAgpeyaList(); updateStats();
      });
      onSnapshot(col('liturgy'), function(snap) {
        appData.liturgy.ar = []; appData.liturgy.en = [];
        snap.forEach(function(d) {
          var data = d.data();
          if (data.lang === 'ar') appData.liturgy.ar.push(data);
          else appData.liturgy.en.push(data);
        });
        renderLiturgyList(); updateStats();
      });
      onSnapshot(col('readings'), function(snap) {
        appData.readings = [];
        snap.forEach(function(d) { appData.readings.push(d.data()); });
        renderReadingsList(); updateStats();
      });
      onSnapshot(doc(db, 'settings', 'design'), function(snap) {
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
      await setDoc(doc(db, collectionName, docId), data);
    } catch (e) {
      saveLocal();
      showToast('Offline save');
    }
  }

  async function deleteFromFirebase(collectionName, docId) {
    if (!db) return;
    try {
      await deleteDoc(doc(db, collectionName, docId));
    } catch (e) {}
  }

  // Keep local cache in sync for offline use
  function syncLocalFromState() { saveLocal(); }
  // ============================================================
  // RENDER FUNCTIONS
  // ============================================================
  function renderTraneemList() {
    var c = document.getElementById('traneem-list');
    if (!c) return;
    var all = [];
    appData.traneem.ar.forEach(function(h) { all.push({ lang: 'ar', data: h }); });
    appData.traneem.en.forEach(function(h) { all.push({ lang: 'en', data: h }); });
    if (!all.length) { c.innerHTML = '<p class="empty-state">' + t('noDataFound') + '</p>'; return; }
    c.innerHTML = all.map(function(it) {
      var d = it.data; var title = d.title || d.id || 'Untitled';
      var stanzas = (d.stanzas || []).length;
      return '<div class="item-row" onclick="editTraneem(\'' + it.lang + '\',\'' + (d.id || '') + '\')"><div><span class="item-title">' + title + '</span><br><span class="item-meta">' + stanzas + ' ' + t('stanzas') + ' | ' + it.lang.toUpperCase() + '</span></div><span>\u270F\uFE0F</span></div>';
    }).join('');
  }
  function renderBibleList() {
    var c = document.getElementById('bible-list');
    if (!c) return;
    var all = [];
    appData.bible.ar.forEach(function(b) { all.push({ lang: 'ar', data: b }); });
    appData.bible.en.forEach(function(b) { all.push({ lang: 'en', data: b }); });
    if (!all.length) { c.innerHTML = '<p class="empty-state">' + t('noDataFound') + '</p>'; return; }
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
    if (!all.length) { c.innerHTML = '<p class="empty-state">' + t('noDataFound') + '</p>'; return; }
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
    if (!all.length) { c.innerHTML = '<p class="empty-state">' + t('noDataFound') + '</p>'; return; }
    c.innerHTML = all.map(function(it) {
      var d = it.data;
      return '<div class="item-row" onclick="editLiturgy(\'' + it.lang + '\',\'' + (d.id || d.name || '') + '\')"><div><span class="item-title">' + (d.name || d.id || 'Liturgy') + '</span><br><span class="item-meta">' + it.lang.toUpperCase() + '</span></div><span>\u270F\uFE0F</span></div>';
    }).join('');
  }
  function renderReadingsList() {
    var c = document.getElementById('readings-list');
    if (!c) return;
    if (!appData.readings.length) { c.innerHTML = '<p class="empty-state">' + t('noDataFound') + '</p>'; return; }
    c.innerHTML = appData.readings.map(function(r, i) {
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
  // ============================================================
  // EDIT / OPEN MODAL
  // ============================================================
  window.editTraneem = function(lang, id) {
    var list = lang === 'ar' ? appData.traneem.ar : appData.traneem.en;
    var item = list.find(function(h) { return h.id === id; });
    if (!item) return;
    openModal('modal-hymn');
    document.getElementById('hymn-modal-title').textContent = t('editHymn') + ': ' + (item.title || item.id);
    document.getElementById('hymn-json').value = JSON.stringify(item, null, 2);
    document.getElementById('hymn-json').dataset.lang = lang;
    document.getElementById('hymn-json').dataset.id = id;
    document.getElementById('deleteHymnBtn').style.display = 'inline-flex';
  };
  window.editBible = function(lang, id) {
    var list = lang === 'ar' ? appData.bible.ar : appData.bible.en;
    var item = list.find(function(b) { return b.bookId === id; });
    if (!item) return;
    openModal('modal-bible');
    document.getElementById('bible-modal-title').textContent = t('editBible') + ': ' + (item.bookName || item.bookId);
    document.getElementById('bible-json').value = JSON.stringify(item, null, 2);
    document.getElementById('bible-json').dataset.lang = lang;
    document.getElementById('bible-json').dataset.id = id;
    document.getElementById('deleteBibleBtn').style.display = 'inline-flex';
  };
  window.editAgpeya = function(lang, id) {
    var list = lang === 'ar' ? appData.agpeya.ar : appData.agpeya.en;
    var item = list.find(function(p) { return p.id === id; });
    if (!item) return;
    openModal('modal-agpeya');
    document.getElementById('agpeya-modal-title').textContent = t('editPrayer') + ': ' + (item.name || item.englishName || item.id);
    document.getElementById('agpeya-json').value = JSON.stringify(item, null, 2);
    document.getElementById('agpeya-json').dataset.lang = lang;
    document.getElementById('agpeya-json').dataset.id = id;
    document.getElementById('deleteAgpeyaBtn').style.display = 'inline-flex';
  };
  window.editLiturgy = function(lang, id) {
    var list = lang === 'ar' ? appData.liturgy.ar : appData.liturgy.en;
    var item = list.find(function(l) { return (l.id || l.name) === id; });
    if (!item) return;
    openModal('modal-liturgy');
    document.getElementById('liturgy-modal-title').textContent = t('editLiturgy') + ': ' + (item.name || item.id);
    document.getElementById('liturgy-json').value = JSON.stringify(item, null, 2);
    document.getElementById('liturgy-json').dataset.lang = lang;
    document.getElementById('liturgy-json').dataset.id = id;
    document.getElementById('deleteLiturgyBtn').style.display = 'inline-flex';
  };
  window.editReading = function(idx) {
    var item = appData.readings[idx];
    if (!item) return;
    openModal('modal-reading');
    document.getElementById('reading-modal-title').textContent = t('editReading') + ': ' + (item.title || idx);
    document.getElementById('reading-json').value = JSON.stringify(item, null, 2);
    document.getElementById('reading-json').dataset.idx = idx;
    document.getElementById('deleteReadingBtn').style.display = 'inline-flex';
  };
  // ============================================================
  // SAVE / DELETE (WRITE TO FIREBASE)
  // ============================================================
  async function saveHymn() {
    var json = document.getElementById('hymn-json').value;
    var lang = document.getElementById('hymn-json').dataset.lang;
    try {
      var data = JSON.parse(json);
      if (!data.id) { showToast(t('idRequired')); return; }
      data.lang = lang;
      data.updatedAt = new Date().toISOString();
      await saveToFirebase('traneem', data.id + '_' + lang, data);
      saveLocal(); closeModal('modal-hymn'); showToast(t('saved'));
    } catch(e) { showToast(t('invalidJson')); }
  }
  async function deleteHymn() {
    var lang = document.getElementById('hymn-json').dataset.lang;
    var id = document.getElementById('hymn-json').dataset.id;
    if (!id) return;
    var list = lang === 'ar' ? appData.traneem.ar : appData.traneem.en;
    var idx = list.findIndex(function(h) { return h.id === id; });
    if (idx >= 0) list.splice(idx, 1);
    await deleteFromFirebase('traneem', id + '_' + lang);
    saveLocal(); closeModal('modal-hymn'); renderTraneemList(); showToast(t('deleted'));
  }
  async function saveBible() {
    var json = document.getElementById('bible-json').value;
    var lang = document.getElementById('bible-json').dataset.lang;
    try {
      var data = JSON.parse(json);
      if (!data.bookId) { showToast(t('idRequired')); return; }
      data.lang = lang; data.updatedAt = new Date().toISOString();
      await saveToFirebase('bible', data.bookId + '_' + lang, data);
      saveLocal(); closeModal('modal-bible'); showToast(t('saved'));
    } catch(e) { showToast(t('invalidJson')); }
  }
  async function deleteBible() {
    var lang = document.getElementById('bible-json').dataset.lang;
    var id = document.getElementById('bible-json').dataset.id;
    if (!id) return;
    var list = lang === 'ar' ? appData.bible.ar : appData.bible.en;
    var idx = list.findIndex(function(b) { return b.bookId === id; });
    if (idx >= 0) list.splice(idx, 1);
    await deleteFromFirebase('bible', id + '_' + lang);
    saveLocal(); closeModal('modal-bible'); renderBibleList(); showToast(t('deleted'));
  }
  async function saveAgpeya() {
    var json = document.getElementById('agpeya-json').value;
    var lang = document.getElementById('agpeya-json').dataset.lang;
    try {
      var data = JSON.parse(json);
      if (!data.id) { showToast(t('idRequired')); return; }
      data.lang = lang; data.updatedAt = new Date().toISOString();
      await saveToFirebase('agpeya', data.id + '_' + lang, data);
      saveLocal(); closeModal('modal-agpeya'); showToast(t('saved'));
    } catch(e) { showToast(t('invalidJson')); }
  }
  async function deleteAgpeya() {
    var lang = document.getElementById('agpeya-json').dataset.lang;
    var id = document.getElementById('agpeya-json').dataset.id;
    if (!id) return;
    var list = lang === 'ar' ? appData.agpeya.ar : appData.agpeya.en;
    var idx = list.findIndex(function(p) { return p.id === id; });
    if (idx >= 0) list.splice(idx, 1);
    await deleteFromFirebase('agpeya', id + '_' + lang);
    saveLocal(); closeModal('modal-agpeya'); renderAgpeyaList(); showToast(t('deleted'));
  }
  async function saveLiturgy() {
    var json = document.getElementById('liturgy-json').value;
    var lang = document.getElementById('liturgy-json').dataset.lang;
    try {
      var data = JSON.parse(json);
      data.lang = lang; data.updatedAt = new Date().toISOString();
      var docId = (data.id || data.name || 'liturgy') + '_' + lang;
      await saveToFirebase('liturgy', docId, data);
      saveLocal(); closeModal('modal-liturgy'); showToast(t('saved'));
    } catch(e) { showToast(t('invalidJson')); }
  }
  async function deleteLiturgy() {
    var lang = document.getElementById('liturgy-json').dataset.lang;
    var id = document.getElementById('liturgy-json').dataset.id;
    if (!id) return;
    var list = lang === 'ar' ? appData.liturgy.ar : appData.liturgy.en;
    var idx = list.findIndex(function(l) { return (l.id || l.name) === id; });
    if (idx >= 0) list.splice(idx, 1);
    await deleteFromFirebase('liturgy', id + '_' + lang);
    saveLocal(); closeModal('modal-liturgy'); renderLiturgyList(); showToast(t('deleted'));
  }
  async function saveReading() {
    var json = document.getElementById('reading-json').value;
    try {
      var data = JSON.parse(json);
      data.updatedAt = new Date().toISOString();
      var docId = data.id || data.type || 'reading';
      await saveToFirebase('readings', docId, data);
      saveLocal(); closeModal('modal-reading'); showToast(t('saved'));
    } catch(e) { showToast(t('invalidJson')); }
  }
  async function deleteReading() {
    var idx = parseInt(document.getElementById('reading-json').dataset.idx);
    var item = appData.readings[idx];
    if (!item) return;
    var docId = item.id || item.type || 'reading';
    if (!isNaN(idx) && idx >= 0 && idx < appData.readings.length) appData.readings.splice(idx, 1);
    await deleteFromFirebase('readings', docId);
    saveLocal(); closeModal('modal-reading'); renderReadingsList(); showToast(t('deleted'));
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
        data.traneem.ar.forEach(function(item) { saveToFirebase('traneem', (item.id || 'item') + '_ar', item); count++; });
        data.traneem.en.forEach(function(item) { saveToFirebase('traneem', (item.id || 'item') + '_en', item); count++; });
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
    showToast('Sample loaded');
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

    var f = function(id) { return document.getElementById(id); };
    var bind = function(el, ev, fn) { if (el) el.addEventListener(ev, fn); };

    // Navigation
    document.querySelectorAll('.nav-item').forEach(function(btn) {
      bind(btn, 'click', function() { showSection(btn.dataset.section); });
    });

    // Language toggle
    bind(f('langToggle'), 'click', toggleLanguage);

    // Traneem buttons
    bind(f('addHymnBtn'), 'click', function() {
      var sample = { id: 'new_' + Date.now(), title: 'New Hymn', stanzas: [{ title: 'Stanza 1', lines: ['Line 1'] }] };
      openModal('modal-hymn');
      f('hymn-modal-title').textContent = t('editHymn');
      f('hymn-json').value = JSON.stringify(sample, null, 2);
      f('hymn-json').dataset.lang = 'ar'; f('hymn-json').dataset.id = sample.id;
      f('deleteHymnBtn').style.display = 'none';
    });
    bind(f('saveHymnBtn'), 'click', saveHymn);
    bind(f('deleteHymnBtn'), 'click', deleteHymn);

    // Bible buttons
    bind(f('addBibleBookBtn'), 'click', function() {
      var sample = { bookId: 'new_' + Date.now(), bookName: 'New Book', chapters: [{ chapterNumber: 1, verses: [{ number: 1, text: 'Verse 1' }] }] };
      openModal('modal-bible');
      f('bible-modal-title').textContent = t('editBible');
      f('bible-json').value = JSON.stringify(sample, null, 2);
      f('bible-json').dataset.lang = 'ar'; f('bible-json').dataset.id = sample.bookId;
      f('deleteBibleBtn').style.display = 'none';
    });
    bind(f('saveBibleBtn'), 'click', saveBible);
    bind(f('deleteBibleBtn'), 'click', deleteBible);

    // Agpeya buttons
    bind(f('addAgpeyaBtn'), 'click', function() {
      var sample = { id: 'new_' + Date.now(), name: 'New Prayer', englishName: 'New Prayer', opening: { title: 'Introduction', content: ['Opening line'], inline: true } };
      openModal('modal-agpeya');
      f('agpeya-modal-title').textContent = t('editPrayer');
      f('agpeya-json').value = JSON.stringify(sample, null, 2);
      f('agpeya-json').dataset.lang = 'ar'; f('agpeya-json').dataset.id = sample.id;
      f('deleteAgpeyaBtn').style.display = 'none';
    });
    bind(f('saveAgpeyaBtn'), 'click', saveAgpeya);
    bind(f('deleteAgpeyaBtn'), 'click', deleteAgpeya);

    // Liturgy buttons
    bind(f('addLiturgyBtn'), 'click', function() {
      var sample = { id: 'new_' + Date.now(), name: 'New Liturgy', sections: [{ title: 'Section 1', content: ['Content'] }] };
      openModal('modal-liturgy');
      f('liturgy-modal-title').textContent = t('editLiturgy');
      f('liturgy-json').value = JSON.stringify(sample, null, 2);
      f('liturgy-json').dataset.lang = 'ar'; f('liturgy-json').dataset.id = sample.id;
      f('deleteLiturgyBtn').style.display = 'none';
    });
    bind(f('saveLiturgyBtn'), 'click', saveLiturgy);
    bind(f('deleteLiturgyBtn'), 'click', deleteLiturgy);

    // Readings buttons
    bind(f('addReadingBtn'), 'click', function() {
      var sample = { id: 'new_' + Date.now(), type: 'gospel', title: 'New Reading' };
      openModal('modal-reading');
      f('reading-modal-title').textContent = t('editReading');
      f('reading-json').value = JSON.stringify(sample, null, 2);
      f('reading-json').dataset.idx = '-1';
      f('deleteReadingBtn').style.display = 'none';
    });
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
