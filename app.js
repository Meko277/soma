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
      nameEn: 'Coptic Companion', nameAr: 'Ã˜Â§Ã™â€žÃ˜Â±Ã™ÂÃ™Å Ã™â€š Ã˜Â§Ã™â€žÃ™â€šÃ˜Â¨Ã˜Â·Ã™Å ',
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
      switchLang: 'Ã˜Â¹Ã˜Â±Ã˜Â¨Ã™Å '
    },
    ar: {
      appTitle: 'Ã˜Â§Ã™â€žÃ˜Â±Ã™ÂÃ™Å Ã™â€š Ã˜Â§Ã™â€žÃ™â€šÃ˜Â¨Ã˜Â·Ã™Å ', appSubtitle: 'Ã™â€žÃ™Ë†Ã˜Â­Ã˜Â© Ã˜Â§Ã™â€žÃ˜Â¥Ã˜Â¯Ã˜Â§Ã˜Â±Ã˜Â©',
      dashboard: 'Ã˜Â§Ã™â€žÃ˜Â±Ã˜Â¦Ã™Å Ã˜Â³Ã™Å Ã˜Â©', importExport: 'Ã˜Â§Ã˜Â³Ã˜ÂªÃ™Å Ã˜Â±Ã˜Â§Ã˜Â¯ / Ã˜ÂªÃ˜ÂµÃ˜Â¯Ã™Å Ã˜Â±',
      traneem: 'Ã˜Â§Ã™â€žÃ˜ÂªÃ˜Â±Ã˜Â§Ã™â€ Ã™Å Ã™â€¦', bible: 'Ã˜Â§Ã™â€žÃ™Æ’Ã˜ÂªÃ˜Â§Ã˜Â¨ Ã˜Â§Ã™â€žÃ™â€¦Ã™â€šÃ˜Â¯Ã˜Â³', agpeya: 'Ã˜Â§Ã™â€žÃ˜Â£Ã˜Â¬Ã˜Â¨Ã™Å Ã˜Â©',
      liturgy: 'Ã˜Â§Ã™â€žÃ™â€šÃ˜Â¯Ã˜Â§Ã˜Â³', readings: 'Ã˜Â§Ã™â€žÃ™â€šÃ˜Â±Ã˜Â§Ã˜Â¡Ã˜Â§Ã˜Âª', themeDesign: 'Ã˜Â§Ã™â€žÃ™â€¦Ã˜Â¸Ã™â€¡Ã˜Â±',
      preview: 'Ã™â€¦Ã˜Â¹Ã˜Â§Ã™Å Ã™â€ Ã˜Â©', settings: 'Ã˜Â§Ã™â€žÃ˜Â¥Ã˜Â¹Ã˜Â¯Ã˜Â§Ã˜Â¯Ã˜Â§Ã˜Âª',
      overview: 'Ã™â€ Ã˜Â¸Ã˜Â±Ã˜Â© Ã˜Â¹Ã˜Â§Ã™â€¦Ã˜Â© Ã˜Â¹Ã™â€žÃ™â€° Ã˜Â§Ã™â€žÃ™â€¦Ã˜Â­Ã˜ÂªÃ™Ë†Ã™â€°.',
      traneemHymns: 'Ã˜ÂªÃ˜Â±Ã˜Â§Ã™â€ Ã™Å Ã™â€¦', bibleBooks: 'Ã˜Â£Ã˜Â³Ã™ÂÃ˜Â§Ã˜Â±',
      agpeyaPrayers: 'Ã˜ÂµÃ™â€žÃ™Ë†Ã˜Â§Ã˜Âª', liturgyParts: 'Ã˜Â£Ã˜Â¬Ã˜Â²Ã˜Â§Ã˜Â¡ Ã˜Â§Ã™â€žÃ™â€šÃ˜Â¯Ã˜Â§Ã˜Â³',
      copticReadings: 'Ã™â€šÃ˜Â±Ã˜Â§Ã˜Â¡Ã˜Â§Ã˜Âª', themes: 'Ã™â€¦Ã˜Â¸Ã˜Â§Ã™â€¡Ã˜Â±',
      howToUse: 'Ã™Æ’Ã™Å Ã™ÂÃ™Å Ã˜Â© Ã˜Â§Ã™â€žÃ˜Â§Ã˜Â³Ã˜ÂªÃ˜Â®Ã˜Â¯Ã˜Â§Ã™â€¦', dataSource: 'Ã™â€¦Ã˜ÂµÃ˜Â¯Ã˜Â± Ã˜Â§Ã™â€žÃ˜Â¨Ã™Å Ã˜Â§Ã™â€ Ã˜Â§Ã˜Âª',
      noData: 'Ã™â€žÃ˜Â§ Ã˜ÂªÃ™Ë†Ã˜Â¬Ã˜Â¯ Ã˜Â¨Ã™Å Ã˜Â§Ã™â€ Ã˜Â§Ã˜Âª', dataLoaded: 'Ã˜ÂªÃ™â€¦ Ã˜Â§Ã™â€žÃ˜ÂªÃ˜Â­Ã™â€¦Ã™Å Ã™â€ž!',
      help1: 'Ã˜Â§Ã˜Â³Ã˜ÂªÃ™Å Ã˜Â±Ã˜Â§Ã˜Â¯: Ã˜Â§Ã˜Â±Ã™ÂÃ˜Â¹ Ã™â€¦Ã™â€žÃ™ÂÃ˜Â§Ã˜Âª.',
      help2: 'Ã˜ÂªÃ˜Â¹Ã˜Â¯Ã™Å Ã™â€ž: Ã˜ÂªÃ˜ÂµÃ™ÂÃ˜Â­ Ã˜Â§Ã™â€žÃ˜Â£Ã™â€šÃ˜Â³Ã˜Â§Ã™â€¦.',
      help3: 'Ã™â€¦Ã˜Â¹Ã˜Â§Ã™Å Ã™â€ Ã˜Â©: Ã˜Â´Ã˜Â§Ã™â€¡Ã˜Â¯ Ã˜Â§Ã™â€žÃ™â€¦Ã˜Â­Ã˜ÂªÃ™Ë†Ã™â€°.',
      help4: 'Ã™â€¦Ã˜Â¸Ã™â€¡Ã˜Â±: Ã˜Â®Ã˜ÂµÃ˜Âµ Ã˜Â§Ã™â€žÃ˜Â¥Ã˜Â¹Ã˜Â¯Ã˜Â§Ã˜Â¯Ã˜Â§Ã˜Âª.',
      help5: 'Ã˜ÂªÃ˜ÂµÃ˜Â¯Ã™Å Ã˜Â±: Ã˜ÂªÃ˜Â­Ã™â€¦Ã™Å Ã™â€ž ZIP.',
      noDataFound: 'Ã™â€žÃ˜Â§ Ã˜ÂªÃ™Ë†Ã˜Â¬Ã˜Â¯ Ã˜Â¨Ã™Å Ã˜Â§Ã™â€ Ã˜Â§Ã˜Âª.',
      editHymn: 'Ã˜ÂªÃ˜Â¹Ã˜Â¯Ã™Å Ã™â€ž Ã˜ÂªÃ˜Â±Ã™â€ Ã™Å Ã™â€¦Ã˜Â©', editBible: 'Ã˜ÂªÃ˜Â¹Ã˜Â¯Ã™Å Ã™â€ž Ã˜Â³Ã™ÂÃ˜Â±', editPrayer: 'Ã˜ÂªÃ˜Â¹Ã˜Â¯Ã™Å Ã™â€ž Ã˜ÂµÃ™â€žÃ˜Â§Ã˜Â©',
      editLiturgy: 'Ã˜ÂªÃ˜Â¹Ã˜Â¯Ã™Å Ã™â€ž Ã™â€šÃ˜Â¯Ã˜Â§Ã˜Â³', editReading: 'Ã˜ÂªÃ˜Â¹Ã˜Â¯Ã™Å Ã™â€ž Ã™â€šÃ˜Â±Ã˜Â§Ã˜Â¡Ã˜Â©',
      jsonData: 'Ã˜Â¨Ã™Å Ã˜Â§Ã™â€ Ã˜Â§Ã˜Âª JSON', livePreview: 'Ã™â€¦Ã˜Â¹Ã˜Â§Ã™Å Ã™â€ Ã˜Â© Ã™â€¦Ã˜Â¨Ã˜Â§Ã˜Â´Ã˜Â±Ã˜Â©',
      cancel: 'Ã˜Â¥Ã™â€žÃ˜ÂºÃ˜Â§Ã˜Â¡', deleteBtn: 'Ã˜Â­Ã˜Â°Ã™Â', saveBtn: 'Ã˜Â­Ã™ÂÃ˜Â¸',
      saved: 'Ã˜ÂªÃ™â€¦ Ã˜Â§Ã™â€žÃ˜Â­Ã™ÂÃ˜Â¸!', deleted: 'Ã˜ÂªÃ™â€¦ Ã˜Â§Ã™â€žÃ˜Â­Ã˜Â°Ã™Â!', imported: 'Ã˜ÂªÃ™â€¦ Ã˜Â§Ã™â€žÃ˜Â§Ã˜Â³Ã˜ÂªÃ™Å Ã˜Â±Ã˜Â§Ã˜Â¯!',
      invalidJson: 'JSON Ã˜ÂºÃ™Å Ã˜Â± Ã˜ÂµÃ˜Â§Ã™â€žÃ˜Â­', idRequired: 'Ã˜Â§Ã™â€žÃ™â€¦Ã˜Â¹Ã˜Â±Ã™Â Ã™â€¦Ã˜Â·Ã™â€žÃ™Ë†Ã˜Â¨',
      confirmReset: 'Ã˜Â¥Ã˜Â¹Ã˜Â§Ã˜Â¯Ã˜Â© Ã˜ÂªÃ˜Â¹Ã™Å Ã™Å Ã™â€  Ã˜Â¬Ã™â€¦Ã™Å Ã˜Â¹ Ã˜Â§Ã™â€žÃ˜Â¨Ã™Å Ã˜Â§Ã™â€ Ã˜Â§Ã˜ÂªÃ˜Å¸', stanzas: 'Ã™â€¦Ã™â€šÃ˜Â§Ã˜Â·Ã˜Â¹', chapters: 'Ã˜Â£Ã˜ÂµÃ˜Â­Ã˜Â§Ã˜Â­Ã˜Â§Ã˜Âª',
      syncing: 'Ã˜Â¬Ã˜Â§Ã˜Â±Ã™Å  Ã˜Â§Ã™â€žÃ™â€¦Ã˜Â²Ã˜Â§Ã™â€¦Ã™â€ Ã˜Â©...', online: 'Ã™â€¦Ã˜ÂªÃ˜ÂµÃ™â€ž', offline: 'Ã˜ÂºÃ™Å Ã˜Â± Ã™â€¦Ã˜ÂªÃ˜ÂµÃ™â€ž',
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
      el.textContent = 'Ã°Å¸Å¸Â¢ ' + t('online');
      el.className = 'status-online';
    } else {
      el.textContent = 'Ã°Å¸â€Â´ ' + t('offline');
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
    var h = '<h3 style="color:var(--coptic-burgundy);margin-bottom:12px">' + esc(data.title || data.arabicTitle || '') + '</h3>';
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
    document.getElementById('hymn-modal-title').textContent = t('editHymn') + ': ' + (item.title || item.id);
    fs('hymn-lang', lang); fs('hymn-orig-id', id);
    editOriginal = item;
    fs('hymn-id-field', item.id || '');
    fs('hymn-title-field', item.title || item.titleEn || '');
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
    fs('hymn-id-field', ''); fs('hymn-title-field', ''); fs('hymn-arabic-title-field', '');
    fs('hymn-coptic-title-field', ''); fs('hymn-category-field', ''); fs('hymn-categoryar-field', '');
    renderHymnStanzas([{ title: '', lines: [''] }]);
    renderHymnPreview({ title: '' });
    document.getElementById('deleteHymnBtn').style.display = 'none';
  };
  async function saveHymn() {
    var lang = fv('hymn-lang');
    var id = (fv('hymn-id-field') || '').trim();
    if (!id) { showToast(t('idRequired')); return; }
    var data = editOriginal || {};
    data.id = id; data.title = fv('hymn-title-field'); data.lang = lang;
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
  function renderLiturgyPreview() {
    var p = document.getElementById('liturgy-preview'); if (!p) return;
    var name = fv('liturgy-name') || 'Liturgy';
    var sections = editLiturgyBuffer.sections || [];
    var h = '<h3 style="color:var(--coptic-burgundy);margin-bottom:12px">' + esc(name) + '</h3>';
    h += sections.map(function(s) {
      return '<div class="preview-stanza"><div class="stanza-title">' + esc(s.title || '') + '</div>' + (s.content || []).map(function(l) { return '<div class="stanza-line">' + esc(l) + '</div>'; }).join('') + '</div>';
    }).join('');
    p.innerHTML = h;
  }
  function renderLiturgySections(sections) {
    editLiturgyBuffer.sections = sections || [];
    var wrap = document.getElementById('liturgy-sections'); if (!wrap) return;
    if (!editLiturgyBuffer.sections.length) { wrap.innerHTML = '<p class="empty-state">No sections</p>'; return; }
    wrap.innerHTML = editLiturgyBuffer.sections.map(function(s, i) {
      var lines = (s.content || []).map(function(l) { return esc(l); }).join('\n');
      return '<div class="editor-block"><div class="editor-block-head"><input type="text" class="form-control editor-title-input" placeholder="Section title" value="' + esc(s.title || '') + '" oninput="editLiturgySectionTitle(' + i + ',this.value)"><button type="button" class="btn btn-danger btn-sm" onclick="removeLiturgySection(' + i + ')">&times;</button></div><textarea class="form-control editor-content" rows="3" placeholder="One paragraph per line" oninput="editLiturgySectionContent(' + i + ',this.value)">' + esc(lines) + '</textarea></div>';
    }).join('');
  }
  window.addLiturgySection = function() { editLiturgyBuffer.sections.push({ title: '', content: [''] }); renderLiturgySections(editLiturgyBuffer.sections); renderLiturgyPreview(); };
  window.removeLiturgySection = function(i) { editLiturgyBuffer.sections.splice(i, 1); renderLiturgySections(editLiturgyBuffer.sections); renderLiturgyPreview(); };
  window.editLiturgySectionTitle = function(i, v) { if (editLiturgyBuffer.sections[i]) editLiturgyBuffer.sections[i].title = v; renderLiturgyPreview(); };
  window.editLiturgySectionContent = function(i, v) { if (editLiturgyBuffer.sections[i]) editLiturgyBuffer.sections[i].content = v.split('\n'); renderLiturgyPreview(); };
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
