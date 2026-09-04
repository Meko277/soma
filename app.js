// Coptic Companion - Full Admin Panel JavaScript
(function() {
  'use strict';

  const STORAGE_KEY = 'coptic_admin_data';
  const THEME_KEY = 'coptic_admin_theme';

  // Data structure matching Flutter app assets
  let appData = {
    traneem: { ar: [], en: [] },
    bible: { ar: [], en: [] },
    agpeya: { ar: [], en: [] },
    liturgy: { ar: [], en: [] },
    readings: [],
    design: {
      nameEn: 'Coptic Companion', nameAr: 'الرفيق القبطي',
      developer: '', version: '1.0.0',
      descEn: '', descAr: '',
      colors: { primary: '#8B4513', secondary: '#D4AF37', bgLight: '#FFFBF0', bgDark: '#1A1A2E', textLight: '#2C1810', textDark: '#F5F5DC', card: '#FFFFFF', border: '#E0D5C5' },
      fonts: { body: 'Roboto', arabic: 'Noto Sans Arabic', sizeBase: 16, sizeHeading: 24 },
      logoUrl: '', iconUrl: '', bgLightUrl: '', bgDarkUrl: ''
    }
  };

  function loadAll() {
    try {
      const raw = localStorage.getItem(STORAGE_KEY);
      if (raw) appData = JSON.parse(raw);
    } catch(e) { console.warn('Failed to load data', e); }
    try {
      const theme = localStorage.getItem(THEME_KEY);
      if (theme) appData.design = JSON.parse(theme);
    } catch(e) { console.warn('Failed to load theme', e); }
  }

  function saveAll() {
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(appData));
      localStorage.setItem(THEME_KEY, JSON.stringify(appData.design));
      updateStats();
      return true;
    } catch(e) {
      showToast('Failed to save: ' + e.message);
      return false;
    }
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  function showSection(id) {
    document.querySelectorAll('.content-section').forEach(function(s) { s.classList.remove('active'); });
    document.querySelectorAll('.nav-item').forEach(function(n) { n.classList.remove('active'); });
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

  function showToast(msg) {
    var t = document.getElementById('toast');
    var m = document.getElementById('toast-message');
    if (t && m) {
      m.textContent = msg;
      t.style.display = 'block';
      setTimeout(function() { t.style.display = 'none'; }, 3000);
    }
  }

  // ============================================================
  // STATS & RENDERING
  // ============================================================

  function updateStats() {
    var el = function(id) { return document.getElementById(id); };
    if (el('stat-traneem')) el('stat-traneem').textContent = appData.traneem.ar.length + appData.traneem.en.length;
    if (el('stat-bible')) el('stat-bible').textContent = appData.bible.ar.length + appData.bible.en.length;
    if (el('stat-agpeya')) el('stat-agpeya').textContent = appData.agpeya.ar.length + appData.agpeya.en.length;
    if (el('stat-liturgy')) el('stat-liturgy').textContent = appData.liturgy.ar.length + appData.liturgy.en.length;
    if (el('stat-readings')) el('stat-readings').textContent = appData.readings.length;
    if (el('stat-themes')) el('stat-themes').textContent = 1;
    var status = el('data-source-status');
    if (status && hasData()) {
      status.className = 'status-ok';
      status.textContent = '✅ Data loaded - ' + getDataSummary();
    }
  }

  function hasData() {
    return appData.traneem.ar.length > 0 || appData.bible.ar.length > 0 || appData.agpeya.ar.length > 0 || appData.liturgy.ar.length > 0 || appData.readings.length > 0;
  }

  function getDataSummary() {
    var parts = [];
    if (appData.traneem.ar.length) parts.push(appData.traneem.ar.length + ' traneem');
    if (appData.bible.ar.length) parts.push(appData.bible.ar.length + ' bible books');
    if (appData.agpeya.ar.length) parts.push(appData.agpeya.ar.length + ' agpeya prayers');
    if (appData.liturgy.ar.length) parts.push(appData.liturgy.ar.length + ' liturgy parts');
    if (appData.readings.length) parts.push(appData.readings.length + ' readings');
    return parts.join(', ') || 'No data';
  }

  // ============================================================
  // TRANEEM
  // ============================================================

  function renderTraneemList() {
    var container = document.getElementById('traneem-list');
    if (!container) return;
    var search = (document.getElementById('traneemSearch') || {}).value || '';
    search = search.toLowerCase();
    var all = [];
    appData.traneem.ar.forEach(function(h) { all.push({ lang: 'ar', data: h }); });
    appData.traneem.en.forEach(function(h) { all.push({ lang: 'en', data: h }); });
    var filtered = all.filter(function(item) {
      var d = item.data;
      return (d.title || '').toLowerCase().indexOf(search) !== -1 ||
             (d.id || '').toLowerCase().indexOf(search) !== -1 ||
             (d.category || '').toLowerCase().indexOf(search) !== -1 ||
             (d.arabicTitle || '').indexOf(search) !== -1;
    });
    if (filtered.length === 0) { container.innerHTML = '<p class="empty-state">No hymns found. Import data or add new hymns.</p>'; return; }
    container.innerHTML = filtered.map(function(item) {
      var d = item.data;
      var title = item.lang === 'ar' ? (d.title || d.id) : (d.title || d.id);
      var subtitle = item.lang === 'ar' ? (d.categoryAr || d.category || '') : (d.category || '');
      var stanzas = (d.stanzas || []).length;
      return '<div class="item-row" onclick="editTraneem(\'' + item.lang + '\',\'' + (d.id || '') + '\')"><div><span class="item-title">' + title + '</span><br><span class="item-meta">' + subtitle + ' • ' + stanzas + ' stanzas • ' + item.lang.toUpperCase() + '</span></div><span>✏️</span></div>';
    }).join('');
  }

  window.editTraneem = function(lang, id) {
    var list = lang === 'ar' ? appData.traneem.ar : appData.traneem.en;
    var item = list.find(function(h) { return h.id === id; });
    if (!item) return;
    document.getElementById('hymn-modal-title').textContent = 'Edit: ' + (item.title || item.id);
    document.getElementById('hymn-json').value = JSON.stringify(item, null, 2);
    document.getElementById('hymn-json').dataset.lang = lang;
    document.getElementById('hymn-json').dataset.id = id;
    document.getElementById('deleteHymnBtn').style.display = 'inline-flex';
    renderTraneemPreview(item);
    openModal('modal-hymn');
  };

  window.newTraneem = function(lang) {
    var sample = { id: 'new-hymn', title: 'New Hymn', arabicTitle: 'ترنيمة جديدة', category: 'Liturgical', categoryAr: 'طقسية', stanzas: [{ title: 'Stanza 1', lines: ['Line 1', 'Line 2'] }] };
    document.getElementById('hymn-modal-title').textContent = 'New Hymn';
    document.getElementById('hymn-json').value = JSON.stringify(sample, null, 2);
    document.getElementById('hymn-json').dataset.lang = lang || 'ar';
    document.getElementById('hymn-json').dataset.id = '';
    document.getElementById('deleteHymnBtn').style.display = 'none';
    renderTraneemPreview(sample);
    openModal('modal-hymn');
  };

  function renderTraneemPreview(data) {
    var pane = document.getElementById('hymn-preview');
    if (!pane) return;
    if (!data) { pane.innerHTML = '<p class="empty-state">No data</p>'; return; }
    var html = '<div class="preview-item"><div class="preview-title">' + (data.title || '') + '</div>';
    if (data.arabicTitle) html += '<div class="preview-title" dir="rtl">' + data.arabicTitle + '</div>';
    html += '<div style="color:#884;font-size:0.8rem;margin:4px 0">' + (data.category || '') + (data.categoryAr ? ' | ' + data.categoryAr : '') + '</div>';
    (data.stanzas || []).forEach(function(s) {
      html += '<div class="preview-stanza"><div class="stanza-title">' + (s.title || '') + '</div>';
      (s.lines || []).forEach(function(l) { html += '<div class="stanza-line">' + l + '</div>'; });
      html += '</div>';
    });
    html += '</div>';
    pane.innerHTML = html;
  }

  function saveTraneem() {
    var json = document.getElementById('hymn-json').value;
    var lang = document.getElementById('hymn-json').dataset.lang;
    var id = document.getElementById('hymn-json').dataset.id;
    try {
      var data = JSON.parse(json);
      if (!data.id) { showToast('ID is required'); return; }
      var list = lang === 'ar' ? appData.traneem.ar : appData.traneem.en;
      var idx = list.findIndex(function(h) { return h.id === data.id; });
      if (idx >= 0) { list[idx] = data; } else { list.push(data); }
      saveAll();
      closeModal('modal-hymn');
      renderTraneemList();
      showToast('Hymn saved');
    } catch(e) {
      showToast('Invalid JSON: ' + e.message);
    }
  }

  function deleteTraneem() {
    var lang = document.getElementById('hymn-json').dataset.lang;
    var id = document.getElementById('hymn-json').dataset.id;
    if (!id) return;
    var list = lang === 'ar' ? appData.traneem.ar : appData.traneem.en;
    var idx = list.findIndex(function(h) { return h.id === id; });
    if (idx >= 0) { list.splice(idx, 1); }
    saveAll();
    closeModal('modal-hymn');
    renderTraneemList();
    showToast('Hymn deleted');
  }

  // ============================================================
  // BIBLE
  // ============================================================

  function renderBibleList() {
    var container = document.getElementById('bible-list');
    if (!container) return;
    var search = (document.getElementById('bibleSearch') || {}).value || '';
    search = search.toLowerCase();
    var all = [];
    appData.bible.ar.forEach(function(b) { all.push({ lang: 'ar', data: b }); });
    appData.bible.en.forEach(function(b) { all.push({ lang: 'en', data: b }); });
    var filtered = all.filter(function(item) {
      var d = item.data;
      return (d.bookId || '').toLowerCase().indexOf(search) !== -1 ||
             (d.bookName || '').toLowerCase().indexOf(search) !== -1;
    });
    if (filtered.length === 0) { container.innerHTML = '<p class="empty-state">No Bible books found.</p>'; return; }
    container.innerHTML = filtered.map(function(item) {
      var d = item.data;
      var chCount = (d.chapters || []).length;
      return '<div class="item-row" onclick="editBible(\'' + item.lang + '\',\'' + (d.bookId || '') + '\')"><div><span class="item-title">' + (d.bookName || d.bookId) + '</span><br><span class="item-meta">' + (d.bookId || '') + ' • ' + chCount + ' chapters • ' + item.lang.toUpperCase() + '</span></div><span>✏️</span></div>';
    }).join('');
  }

  window.editBible = function(lang, id) {
    var list = lang === 'ar' ? appData.bible.ar : appData.bible.en;
    var item = list.find(function(b) { return b.bookId === id; });
    if (!item) return;
    document.getElementById('bible-modal-title').textContent = 'Edit: ' + (item.bookName || item.bookId);
    document.getElementById('bible-json').value = JSON.stringify(item, null, 2);
    document.getElementById('bible-json').dataset.lang = lang;
    document.getElementById('bible-json').dataset.id = id;
    document.getElementById('deleteBibleBtn').style.display = 'inline-flex';
    renderBiblePreview(item);
    openModal('modal-bible');
  };

  window.newBible = function(lang) {
    var sample = { bookId: 'new-book', bookName: 'New Book', chapters: [{ chapterNumber: 1, verses: [{ number: 1, text: 'Verse 1 text...' }] }] };
    document.getElementById('bible-modal-title').textContent = 'New Bible Book';
    document.getElementById('bible-json').value = JSON.stringify(sample, null, 2);
    document.getElementById('bible-json').dataset.lang = lang || 'ar';
    document.getElementById('bible-json').dataset.id = '';
    document.getElementById('deleteBibleBtn').style.display = 'none';
    renderBiblePreview(sample);
    openModal('modal-bible');
  };

  function renderBiblePreview(data) {
    var pane = document.getElementById('bible-preview');
    if (!pane) return;
    if (!data) { pane.innerHTML = '<p class="empty-state">No data</p>'; return; }
    var html = '<div class="preview-item"><div class="preview-title">' + (data.bookName || data.bookId) + '</div>';
    var ch = (data.chapters || [])[0];
    if (ch) {
      html += '<div style="color:#884;font-size:0.8rem;margin:4px 0">Chapter ' + ch.chapterNumber + '</div>';
      (ch.verses || []).slice(0, 5).forEach(function(v) {
        html += '<div class="preview-verse"><span class="verse-num">' + v.number + '</span> ' + v.text + '</div>';
      });
      if ((ch.verses || []).length > 5) html += '<p style="color:#888;font-size:0.8rem">... and ' + (ch.verses.length - 5) + ' more verses</p>';
    }
    html += '</div>';
    pane.innerHTML = html;
  }

  function saveBible() {
    var json = document.getElementById('bible-json').value;
    var lang = document.getElementById('bible-json').dataset.lang;
    try {
      var data = JSON.parse(json);
      if (!data.bookId) { showToast('Book ID is required'); return; }
      var list = lang === 'ar' ? appData.bible.ar : appData.bible.en;
      var idx = list.findIndex(function(b) { return b.bookId === data.bookId; });
      if (idx >= 0) { list[idx] = data; } else { list.push(data); }
      saveAll();
      closeModal('modal-bible');
      renderBibleList();
      showToast('Bible book saved');
    } catch(e) { showToast('Invalid JSON: ' + e.message); }
  }

  function deleteBible() {
    var lang = document.getElementById('bible-json').dataset.lang;
    var id = document.getElementById('bible-json').dataset.id;
    if (!id) return;
    var list = lang === 'ar' ? appData.bible.ar : appData.bible.en;
    var idx = list.findIndex(function(b) { return b.bookId === id; });
    if (idx >= 0) { list.splice(idx, 1); }
    saveAll();
    closeModal('modal-bible');
    renderBibleList();
    showToast('Book deleted');
  }  function renderAgpeyaList() {
    var c = document.getElementById('agpeya-list');
    if (!c) return;
    var all = [];
    appData.agpeya.ar.forEach(function(p) { all.push({ lang: 'ar', data: p }); });
    appData.agpeya.en.forEach(function(p) { all.push({ lang: 'en', data: p }); });
    if (!all.length) { c.innerHTML = '<p class="empty-state">No prayers found.</p>'; return; }
    c.innerHTML = all.map(function(it) {
      var d = it.data; var n = it.lang === 'ar' ? (d.name || d.id) : (d.englishName || d.id);
      return '<div class="item-row" onclick="editAgpeya(\'' + it.lang + '\',\'' + (d.id || '') + '\')"><div><span class="item-title">' + n + '</span><br><span class="item-meta">' + (d.id || '') + ' \u2022 ' + it.lang.toUpperCase() + '</span></div><span>\u270F\uFE0F</span></div>';
    }).join('');
  }
  window.editAgpeya = function(lang, id) {
    var list = lang === 'ar' ? appData.agpeya.ar : appData.agpeya.en;
    var item = list.find(function(p) { return p.id === id; });
    if (!item) return;
    document.getElementById('agpeya-modal-title').textContent = 'Edit: ' + (item.name || item.englishName || item.id);
    document.getElementById('agpeya-json').value = JSON.stringify(item, null, 2);
    document.getElementById('agpeya-json').dataset.lang = lang;
    document.getElementById('agpeya-json').dataset.id = id;
    document.getElementById('deleteAgpeyaBtn').style.display = 'inline-flex';
    openModal('modal-agpeya');
  };
  function saveAgpeya() {
    var json = document.getElementById('agpeya-json').value;
    var lang = document.getElementById('agpeya-json').dataset.lang;
    try {
      var data = JSON.parse(json);
      if (!data.id) { showToast('ID required'); return; }
      var list = lang === 'ar' ? appData.agpeya.ar : appData.agpeya.en;
      var idx = list.findIndex(function(p) { return p.id === data.id; });
      if (idx >= 0) list[idx] = data; else list.push(data);
      saveAll(); closeModal('modal-agpeya'); renderAgpeyaList(); showToast('Saved');
    } catch(e) { showToast('Invalid JSON: ' + e.message); }
  }
  function deleteAgpeya() {
    var lang = document.getElementById('agpeya-json').dataset.lang;
    var id = document.getElementById('agpeya-json').dataset.id;
    if (!id) return;
    var list = lang === 'ar' ? appData.agpeya.ar : appData.agpeya.en;
    var idx = list.findIndex(function(p) { return p.id === id; });
    if (idx >= 0) list.splice(idx, 1);
    saveAll(); closeModal('modal-agpeya'); renderAgpeyaList(); showToast('Deleted');
  }
  function renderLiturgyList() {
    var c = document.getElementById('liturgy-list');
    if (!c) return;
    var all = [];
    appData.liturgy.ar.forEach(function(l) { all.push({ lang: 'ar', data: l }); });
    appData.liturgy.en.forEach(function(l) { all.push({ lang: 'en', data: l }); });
    if (!all.length) { c.innerHTML = '<p class="empty-state">No liturgy found.</p>'; return; }
    c.innerHTML = all.map(function(it) {
      var d = it.data;
      return '<div class="item-row" onclick="editLiturgy(\'' + it.lang + '\',\'' + (d.id || d.name || '') + '\')"><div><span class="item-title">' + (d.name || d.id || 'Liturgy') + '</span><br><span class="item-meta">' + it.lang.toUpperCase() + '</span></div><span>\u270F\uFE0F</span></div>';
    }).join('');
  }
  window.editLiturgy = function(lang, id) {
    var list = lang === 'ar' ? appData.liturgy.ar : appData.liturgy.en;
    var item = list.find(function(l) { return (l.id || l.name) === id; });
    if (!item) return;
    document.getElementById('liturgy-modal-title').textContent = 'Edit: ' + (item.name || item.id);
    document.getElementById('liturgy-json').value = JSON.stringify(item, null, 2);
    document.getElementById('liturgy-json').dataset.lang = lang;
    document.getElementById('liturgy-json').dataset.id = id;
    document.getElementById('deleteLiturgyBtn').style.display = 'inline-flex';
    openModal('modal-liturgy');
  };
  function saveLiturgy() {
    var json = document.getElementById('liturgy-json').value;
    var lang = document.getElementById('liturgy-json').dataset.lang;
    try {
      var data = JSON.parse(json);
      var list = lang === 'ar' ? appData.liturgy.ar : appData.liturgy.en;
      var id = data.id || data.name;
      var idx = list.findIndex(function(l) { return (l.id || l.name) === id; });
      if (idx >= 0) list[idx] = data; else list.push(data);
      saveAll(); closeModal('modal-liturgy'); renderLiturgyList(); showToast('Saved');
    } catch(e) { showToast('Invalid JSON: ' + e.message); }
  }
  function deleteLiturgy() {
    var lang = document.getElementById('liturgy-json').dataset.lang;
    var id = document.getElementById('liturgy-json').dataset.id;
    if (!id) return;
    var list = lang === 'ar' ? appData.liturgy.ar : appData.liturgy.en;
    var idx = list.findIndex(function(l) { return (l.id || l.name) === id; });
    if (idx >= 0) list.splice(idx, 1);
    saveAll(); closeModal('modal-liturgy'); renderLiturgyList(); showToast('Deleted');
  }
  function renderReadingsList() {
    var c = document.getElementById('readings-list');
    if (!c) return;
    if (!appData.readings.length) { c.innerHTML = '<p class="empty-state">No readings found.</p>'; return; }
    c.innerHTML = appData.readings.map(function(r, i) {
      return '<div class="item-row" onclick="editReading(' + i + ')"><div><span class="item-title">' + (r.title || r.type || 'Reading') + '</span><br><span class="item-meta">' + (r.type || '') + '</span></div><span>\u270F\uFE0F</span></div>';
    }).join('');
  }
  window.editReading = function(idx) {
    var item = appData.readings[idx];
    if (!item) return;
    document.getElementById('reading-modal-title').textContent = 'Edit: ' + (item.title || idx);
    document.getElementById('reading-json').value = JSON.stringify(item, null, 2);
    document.getElementById('reading-json').dataset.idx = idx;
    document.getElementById('deleteReadingBtn').style.display = 'inline-flex';
    openModal('modal-reading');
  };
  function saveReading() {
    var json = document.getElementById('reading-json').value;
    var idx = parseInt(document.getElementById('reading-json').dataset.idx);
    try {
      var data = JSON.parse(json);
      if (!isNaN(idx) && idx >= 0 && idx < appData.readings.length) appData.readings[idx] = data;
      else appData.readings.push(data);
      saveAll(); closeModal('modal-reading'); renderReadingsList(); showToast('Saved');
    } catch(e) { showToast('Invalid JSON: ' + e.message); }
  }
  function deleteReading() {
    var idx = parseInt(document.getElementById('reading-json').dataset.idx);
    if (isNaN(idx) || idx < 0 || idx >= appData.readings.length) return;
    appData.readings.splice(idx, 1);
    saveAll(); closeModal('modal-reading'); renderReadingsList(); showToast('Deleted');
  }
  // ============================================================
  // DESIGN / THEME
  // ============================================================
  function renderDesignForm() {
    var d = appData.design;
    var f = function(id) { var e = document.getElementById(id); return e ? e.value : ''; };
    var s = function(id, val) { var e = document.getElementById(id); if (e) e.value = val; };
    s('app-name-en', d.nameEn || '');
    s('app-name-ar', d.nameAr || '');
    s('app-developer', d.developer || '');
    s('app-version', d.version || '1.0.0');
    s('app-desc-en', d.descEn || '');
    s('app-desc-ar', d.descAr || '');
    s('color-primary', (d.colors || {}).primary || '#8B4513');
    s('color-secondary', (d.colors || {}).secondary || '#D4AF37');
    s('color-bg-light', (d.colors || {}).bgLight || '#FFFBF0');
    s('color-bg-dark', (d.colors || {}).bgDark || '#1A1A2E');
    s('color-text-light', (d.colors || {}).textLight || '#2C1810');
    s('color-text-dark', (d.colors || {}).textDark || '#F5F5DC');
    s('color-card', (d.colors || {}).card || '#FFFFFF');
    s('color-border', (d.colors || {}).border || '#E0D5C5');
    s('font-body', (d.fonts || {}).body || 'Roboto');
    s('font-arabic', (d.fonts || {}).arabic || 'Noto Sans Arabic');
    s('font-size-base', (d.fonts || {}).sizeBase || 16);
    s('font-size-heading', (d.fonts || {}).sizeHeading || 24);
    s('logo-url', d.logoUrl || '');
    s('icon-url', d.iconUrl || '');
    s('bg-light-url', d.bgLightUrl || '');
    s('bg-dark-url', d.bgDarkUrl || '');
    var lp = document.getElementById('logo-preview');
    if (lp && d.logoUrl) lp.innerHTML = '<img src="' + d.logoUrl + '" alt="Logo">';
    var bp = document.getElementById('bg-preview');
    if (bp && d.bgLightUrl) bp.style.backgroundImage = 'url(' + d.bgLightUrl + ')';
  }
  function saveDesign() {
    var d = appData.design;
    var s = function(id) { var e = document.getElementById(id); return e ? e.value : ''; };
    d.nameEn = s('app-name-en');
    d.nameAr = s('app-name-ar');
    d.developer = s('app-developer');
    d.version = s('app-version');
    d.descEn = s('app-desc-en');
    d.descAr = s('app-desc-ar');
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
    d.logoUrl = s('logo-url');
    d.iconUrl = s('icon-url');
    d.bgLightUrl = s('bg-light-url');
    d.bgDarkUrl = s('bg-dark-url');
    saveAll();
    showToast('Theme saved');
  }
  // ============================================================
  // IMPORT / EXPORT
  // ============================================================
  function importJSON(jsonStr, target) {
    try {
      var data = JSON.parse(jsonStr);
      if (Array.isArray(data)) {
        data.forEach(function(item) { importSingleItem(item, target); });
      } else {
        importSingleItem(data, target);
      }
      saveAll(); refreshAll(); showToast('Imported successfully');
    } catch(e) { showToast('Import failed: ' + e.message); }
  }
  function importSingleItem(item, target) {
    if (item.stanzas) {
      var lang = item.arabicTitle || item.titleAr ? 'ar' : 'en';
      var list = lang === 'ar' ? appData.traneem.ar : appData.traneem.en;
      var idx = list.findIndex(function(h) { return h.id === item.id; });
      if (idx >= 0) list[idx] = item; else list.push(item);
    } else if (item.chapters) {
      var lang = (item.bookName || '').match(/[\u0600-\u06FF]/) ? 'ar' : 'en';
      var list = lang === 'ar' ? appData.bible.ar : appData.bible.en;
      var idx = list.findIndex(function(b) { return b.bookId === item.bookId; });
      if (idx >= 0) list[idx] = item; else list.push(item);
    } else if (item.psalms || item.sections || item.opening) {
      var lang = item.name ? 'ar' : 'en';
      var list = lang === 'ar' ? appData.agpeya.ar : appData.agpeya.en;
      var idx = list.findIndex(function(p) { return p.id === item.id; });
      if (idx >= 0) list[idx] = item; else list.push(item);
    } else if (item.anaphora || item.fraction || item.communion) {
      var lang = (item.name || '').match(/[\u0600-\u06FF]/) ? 'ar' : 'en';
      var list = lang === 'ar' ? appData.liturgy.ar : appData.liturgy.en;
      list.push(item);
    } else {
      appData.readings.push(item);
    }
  }
  function exportAllJSON() {
    return JSON.stringify(appData, null, 2);
  }
  function downloadJSON(data, filename) {
    var blob = new Blob([data], { type: 'application/json' });
    var url = URL.createObjectURL(blob);
    var a = document.createElement('a');
    a.href = url; a.download = filename; a.click();
    URL.revokeObjectURL(url);
  }
  function downloadBlob(blob, filename) {
    var url = URL.createObjectURL(blob);
    var a = document.createElement('a');
    a.href = url; a.download = filename; a.click();
    URL.revokeObjectURL(url);
  }
  async function exportZIP() {
    if (typeof JSZip === 'undefined') { showToast('JSZip not loaded'); return; }
    var zip = new JSZip();
    var traneemAr = zip.folder('assets/traneem/ar');
    var traneemEn = zip.folder('assets/traneem/en');
    appData.traneem.ar.forEach(function(h) { traneemAr.file((h.id || 'hymn') + '.json', JSON.stringify(h, null, 2)); });
    appData.traneem.en.forEach(function(h) { traneemEn.file((h.id || 'hymn') + '.json', JSON.stringify(h, null, 2)); });
    var bibleAr = zip.folder('assets/bible/ar');
    var bibleEn = zip.folder('assets/bible/en');
    appData.bible.ar.forEach(function(b) { bibleAr.file((b.bookId || 'book') + '.json', JSON.stringify(b, null, 2)); });
    appData.bible.en.forEach(function(b) { bibleEn.file((b.bookId || 'book') + '.json', JSON.stringify(b, null, 2)); });
    var agpeyaAr = zip.folder('assets/agpeya/arabic');
    var agpeyaEn = zip.folder('assets/agpeya/en');
    appData.agpeya.ar.forEach(function(p) { agpeyaAr.file((p.id || 'prayer') + '.json', JSON.stringify(p, null, 2)); });
    appData.agpeya.en.forEach(function(p) { agpeyaEn.file((p.id || 'prayer') + '.json', JSON.stringify(p, null, 2)); });
    var litAr = zip.folder('assets/liturgy/ar');
    var litEn = zip.folder('assets/liturgy/en');
    appData.liturgy.ar.forEach(function(l) { litAr.file((l.id || l.name || 'liturgy') + '.json', JSON.stringify(l, null, 2)); });
    appData.liturgy.en.forEach(function(l) { litEn.file((l.id || l.name || 'liturgy') + '.json', JSON.stringify(l, null, 2)); });
    zip.file('theme.json', JSON.stringify(appData.design, null, 2));
    var blob = await zip.generateAsync({ type: 'blob' });
    downloadBlob(blob, 'coptic-companion-assets.zip');
    showToast('ZIP exported');
  }
  // ============================================================
  // SAMPLE DATA
  // ============================================================
  function loadSampleTraneem() {
    appData.traneem.ar.push({ id: 'trisagion', title: '\u0642\u062F\u0648\u0633 \u0642\u062F\u0648\u0633 \u0642\u062F\u0648\u0633 (\u0627\u0644\u062A\u0642\u062F\u064A\u0633)', arabicTitle: '\u0627\u0644\u062B\u0644\u0627\u062B\u064A \u0627\u0644\u0642\u062F\u0648\u0633', category: 'Liturgical', categoryAr: '\u0637\u0642\u0633\u064A\u0629', stanzas: [{ title: '\u0627\u0644\u062A\u0642\u062F\u064A\u0633', lines: ['\u0642\u062F\u0648\u0633 \u0627\u0644\u0644\u0647\u060C \u0642\u062F\u0648\u0633 \u0627\u0644\u0642\u0648\u064A\u060C \u0642\u062F\u0648\u0633 \u0627\u0644\u062D\u064A \u0627\u0644\u0630\u064A \u0644\u0627 \u064A\u0645\u0648\u062A', '\u0627\u0631\u062D\u0645\u0646\u0627 \u064A\u0627 \u0631\u0628'] }, { title: '\u0627\u0644\u0645\u062C\u062F', lines: ['\u0627\u0644\u0645\u062C\u062F \u0644\u0644\u0622\u0628 \u0648\u0627\u0644\u0627\u0628\u0646 \u0648\u0627\u0644\u0631\u0648\u062D \u0627\u0644\u0642\u062F\u0633'] }] });
    appData.traneem.en.push({ id: 'trisagion', title: 'Holy God (Trisagion)', category: 'Liturgical', stanzas: [{ title: 'The Sanctus', lines: ['Holy God, Holy Mighty, Holy Immortal', 'Have mercy on us'] }, { title: 'Glory', lines: ['Glory be to the Father, Son, and Holy Spirit'] }] });
    saveAll(); refreshAll(); showToast('Sample traneem loaded');
  }
  function loadSampleBible() {
    appData.bible.ar.push({ bookId: 'genesis', bookName: '\u0627\u0644\u062A\u0643\u0648\u064A\u0646', chapters: [{ chapterNumber: 1, verses: [{ number: 1, text: '\u0641\u064A \u0627\u0644\u0628\u062F\u0621 \u062E\u0644\u0642 \u0627\u0644\u0644\u0647 \u0627\u0644\u0633\u0645\u0627\u0648\u0627\u062A \u0648\u0627\u0644\u0623\u0631\u0636' }, { number: 2, text: '\u0648\u0643\u0627\u0646\u062A \u0627\u0644\u0623\u0631\u0636 \u062E\u0631\u064A\u0628\u0629 \u0648\u062E\u0627\u0644\u064A\u0629' }, { number: 3, text: '\u0648\u0642\u0627\u0644 \u0627\u0644\u0644\u0647: \u0644\u064A\u0643\u0646 \u0646\u0648\u0631\u060C \u0641\u0643\u0627\u0646 \u0646\u0648\u0631' }] }] });
    appData.bible.en.push({ bookId: 'genesis', bookName: 'Genesis', chapters: [{ chapterNumber: 1, verses: [{ number: 1, text: 'In the beginning God created the heavens and the earth.' }, { number: 2, text: 'Now the earth was formless and empty.' }, { number: 3, text: 'And God said, Let there be light, and there was light.' }] }] });
    saveAll(); refreshAll(); showToast('Sample Bible loaded');
  }
  function loadSampleAgpeya() {
    appData.agpeya.ar.push({ id: 'prime', name: '\u0628\u0627\u0643\u0631', englishName: 'Morning Prayer', traditionalTime: '6:00 AM', introduction: '\u0635\u0644\u0627\u0629 \u0627\u0644\u0628\u0627\u0643\u0631', opening: { title: '\u0645\u0642\u062F\u0645\u0629', content: ['\u0628\u0627\u0633\u0645 \u0627\u0644\u0622\u0628 \u0648\u0627\u0644\u0627\u0628\u0646 \u0648\u0627\u0644\u0631\u0648\u062D \u0627\u0644\u0642\u062F\u0633'], inline: true } });
    appData.agpeya.en.push({ id: 'prime', name: 'Morning', englishName: 'Morning Prayer (First Hour)', traditionalTime: '6:00 AM', introduction: 'The morning prayer', opening: { title: 'Introduction', content: ['In the name of the Father, Son, and Holy Spirit'], inline: true } });
    saveAll(); refreshAll(); showToast('Sample Agpeya loaded');
  }
  function loadSampleLiturgy() {
    appData.liturgy.ar.push({ id: 'anaphora', name: '\u0627\u0644\u0623\u0646\u0627\u0641\u0648\u0631\u0627', anaphora: [{ title: '\u0627\u0644\u0623\u0646\u0627\u0641\u0648\u0631\u0627', content: ['\u064A\u0627 \u0631\u0628 \u0627\u0631\u062D\u0645\u0646\u0627'] }] });
    appData.liturgy.en.push({ id: 'anaphora', name: 'The Anaphora', anaphora: [{ title: 'The Anaphora', content: ['O Lord have mercy on us'] }] });
    saveAll(); refreshAll(); showToast('Sample Liturgy loaded');
  }
  // ============================================================
  // REFRESH ALL
  // ============================================================
  function refreshAll() {
    updateStats();
    renderTraneemList();
    renderBibleList();
    renderAgpeyaList();
    renderLiturgyList();
    renderReadingsList();
    renderDesignForm();
  }

  // ============================================================
  // INITIALIZATION
  // ============================================================
  document.addEventListener('DOMContentLoaded', function() {
    loadAll();
    var f = function(id) { return document.getElementById(id); };
    var bind = function(el, ev, fn) { if (el) el.addEventListener(ev, fn); };
    // Navigation
    document.querySelectorAll('.nav-item').forEach(function(btn) {
      btn.addEventListener('click', function() { showSection(btn.dataset.section); });
    });
    // Traneem
    bind(f('addHymnBtn'), 'click', function() { newTraneem('ar'); });
    bind(f('saveHymnBtn'), 'click', saveTraneem);
    bind(f('deleteHymnBtn'), 'click', deleteTraneem);
    bind(f('traneemSearch'), 'input', renderTraneemList);
    // Bible
    bind(f('addBibleBookBtn'), 'click', function() { newBible('ar'); });
    bind(f('saveBibleBtn'), 'click', saveBible);
    bind(f('deleteBibleBtn'), 'click', deleteBible);
    bind(f('bibleSearch'), 'input', renderBibleList);
    // Agpeya
    bind(f('addAgpeyaBtn'), 'click', function() { showSection('agpeya'); });
    bind(f('saveAgpeyaBtn'), 'click', saveAgpeya);
    bind(f('deleteAgpeyaBtn'), 'click', deleteAgpeya);
    bind(f('agpeyaSearch'), 'input', renderAgpeyaList);
    // Liturgy
    bind(f('addLiturgyBtn'), 'click', function() { showSection('liturgy'); });
    bind(f('saveLiturgyBtn'), 'click', saveLiturgy);
    bind(f('deleteLiturgyBtn'), 'click', deleteLiturgy);
    bind(f('liturgySearch'), 'input', renderLiturgyList);
    // Readings
    bind(f('addReadingBtn'), 'click', function() { showSection('readings'); });
    bind(f('saveReadingBtn'), 'click', saveReading);
    bind(f('deleteReadingBtn'), 'click', deleteReading);
    bind(f('readingsSearch'), 'input', renderReadingsList);
    // Design
    bind(f('saveDesignBtn'), 'click', saveDesign);
    // Import/Export
    bind(f('exportAllBtn'), 'click', function() { downloadJSON(exportAllJSON(), 'coptic-companion-data.json'); });
    bind(f('exportZipBtn'), 'click', exportZIP);
    bind(f('importBtn'), 'click', function() { f('importFile').click(); });
    bind(f('importFile'), 'change', function(e) {
      if (e.target.files.length > 0) {
        var file = e.target.files[0];
        var reader = new FileReader();
        reader.onload = function(ev) { importJSON(ev.target.result); };
        reader.readAsText(file);
      }
    });
    bind(f('importPasteBtn'), 'click', function() {
      var val = f('importPaste').value;
      if (val) importJSON(val);
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
    // Logo upload
    bind(f('logo-upload'), 'change', function(e) {
      var file = e.target.files[0];
      if (!file) return;
      var reader = new FileReader();
      reader.onload = function(ev) {
        appData.design.logoUrl = ev.target.result;
        var prev = f('logo-preview');
        if (prev) prev.innerHTML = '<img src="' + ev.target.result + '" alt="Logo">';
        if (f('logo-url')) f('logo-url').value = ev.target.result;
        saveAll();
      };
      reader.readAsDataURL(file);
    });
    // Background upload
    bind(f('bg-light-upload'), 'change', function(e) {
      var file = e.target.files[0];
      if (!file) return;
      var reader = new FileReader();
      reader.onload = function(ev) {
        appData.design.bgLightUrl = ev.target.result;
        var prev = f('bg-preview');
        if (prev) { prev.style.backgroundImage = 'url(' + ev.target.result + ')'; prev.innerHTML = ''; }
        if (f('bg-light-url')) f('bg-light-url').value = ev.target.result;
        saveAll();
      };
      reader.readAsDataURL(file);
    });
    bind(f('bg-dark-upload'), 'change', function(e) {
      var file = e.target.files[0];
      if (!file) return;
      var reader = new FileReader();
      reader.onload = function(ev) {
        appData.design.bgDarkUrl = ev.target.result;
        if (f('bg-dark-url')) f('bg-dark-url').value = ev.target.result;
        saveAll();
      };
      reader.readAsDataURL(file);
    });
    // Icon upload
    bind(f('icon-upload'), 'change', function(e) {
      var file = e.target.files[0];
      if (!file) return;
      var reader = new FileReader();
      reader.onload = function(ev) {
        appData.design.iconUrl = ev.target.result;
        if (f('icon-url')) f('icon-url').value = ev.target.result;
        saveAll();
      };
      reader.readAsDataURL(file);
    });
    // Reset
    bind(f('resetAllBtn'), 'click', function() {
      if (confirm('Reset ALL data? This cannot be undone.')) {
        localStorage.removeItem(STORAGE_KEY);
        localStorage.removeItem(THEME_KEY);
        location.reload();
      }
    });
    // Live preview for JSON editors
    var setupLivePreview = function(textareaId, previewId, renderFn) {
      var ta = f(textareaId);
      if (ta) {
        ta.addEventListener('input', function() {
          try {
            var data = JSON.parse(ta.value);
            renderFn(data);
          } catch(e) {}
        });
      }
    };
    setupLivePreview('hymn-json', 'hymn-preview', renderTraneemPreview);
    setupLivePreview('bible-json', 'bible-preview', renderBiblePreview);
    // Initial render
    refreshAll();
  });
})();
