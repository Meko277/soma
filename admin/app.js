// Coptic Companion - Bilingual Admin Panel
(function() {
  'use strict';
  var STORAGE_KEY = 'coptic_admin_data';
  var LANG_KEY = 'admin_lang';
  var currentLang = localStorage.getItem(LANG_KEY) || 'en';
  var appData = {
    traneem: { ar: [], en: [] },
    bible: { ar: [], en: [] },
    agpeya: { ar: [], en: [] },
    liturgy: { ar: [], en: [] },
    readings: [],
    design: {
      nameEn: 'Coptic Companion', nameAr: 'Ø§Ù„Ø±ÙÙŠÙ‚ Ø§Ù„Ù‚Ø¨Ø·ÙŠ',
      developer: '', version: '1.0.0', descEn: '', descAr: '',
      colors: { primary: '#8B2332', secondary: '#D4AF37', bgLight: '#FDF8F0', bgDark: '#1A0F0A', textLight: '#2C1810', textDark: '#E8D5A3', card: '#FFFFFF', border: '#E0D5C5' },
      fonts: { body: 'Cairo', arabic: 'Amiri', sizeBase: 16, sizeHeading: 24 },
      logoUrl: '', iconUrl: '', bgLightUrl: '', bgDarkUrl: ''
    }
  };
  var I18N = {
    en: { appTitle:"Coptic Companion",appSubtitle:"Full App Admin",dashboard:"Dashboard",importExport:"Import / Export",traneem:"Traneem",bible:"Bible",agpeya:"Agpeya",liturgy:"Liturgy",readings:"Readings",themeDesign:"Theme & Design",preview:"Preview",settings:"Settings",overview:"Overview of all app content.",traneemHymns:"Traneem Hymns",bibleBooks:"Bible Books",agpeyaPrayers:"Agpeya Prayers",liturgyParts:"Liturgy Parts",copticReadings:"Coptic Readings",themes:"Themes",howToUse:"How to Use",dataSource:"Data Source",noData:"No data loaded. Import to begin.",dataLoaded:"Data loaded!",help1:"Import: Upload assets or JSON.",help2:"Edit: Navigate sections.",help3:"Preview: See content in app view.",help4:"Theme: Customize appearance.",help5:"Export: Download ZIP for Flutter.",importData:"Import Data",uploadZip:"Upload ZIP",uploadJson:"Upload JSON",pasteJson:"Paste JSON",importPaste:"Import",sampleData:"Load Sample Data",exportZip:"Export ZIP for Flutter",exportFlutter:"Export for Flutter",importBtn:"Import",traneemDesc:"Manage hymns.",addHymn:"Add Hymn",searchHymns:"Search hymns...",bibleDesc:"Manage Bible books.",addBook:"Add Book",searchBooks:"Search books...",agpeyaDesc:"Manage prayers.",addPrayer:"Add Prayer",searchPrayers:"Search...",liturgyDesc:"Manage liturgy.",addLiturgy:"Add Part",searchLiturgy:"Search...",readingsDesc:"Manage readings.",addReading:"Add Reading",searchReadings:"Search...",themeDesc:"Customize appearance.",appIdentity:"App Identity",appNameEn:"Name (EN)",appNameAr:"Name (AR)",developer:"Developer",version:"Version",descEn:"Description (EN)",descAr:"Description (AR)",themeColors:"Colors",primary:"Primary",secondary:"Secondary",bgLight:"BG Light",bgDark:"BG Dark",textLight:"Text Light",textDark:"Text Dark",cardBg:"Card BG",borderColor:"Border",backgroundImage:"Background",noBackground:"No background",logoIcons:"Logo & Icons",appLogo:"Logo",appIcon:"Icon",logoUrl:"Logo URL",iconUrl:"Icon URL",noLogo:"No logo",fontSettings:"Fonts",bodyFont:"Body Font",arabicFont:"Arabic Font",baseSize:"Base Size",headingSize:"Heading Size",saveTheme:"Save Theme",previewDesc:"Preview content.",lightMode:"Light",darkMode:"Dark",arabicLang:"Arabic",englishLang:"English",importToPreview:"Import data to preview",repo:"Repository",token:"Token",syncBtn:"Sync",dataManagement:"Data Management",resetAll:"Reset All",saved:"Saved!",deleted:"Deleted!",imported:"Imported!",invalidJson:"Invalid JSON",idRequired:"ID required",confirmReset:"Reset all data?",noDataFound:"No data found.",stanzas:"stanzas",chapters:"chapters",switchLang:"Ø¹Ø±Ø¨ÙŠ" },
    ar: { appTitle:"Ø§Ù„Ø±ÙÙŠÙ‚ Ø§Ù„Ù‚Ø¨Ø·ÙŠ",appSubtitle:"Ù„ÙˆØ­Ø© Ø§Ù„Ø¥Ø¯Ø§Ø±Ø©",dashboard:"Ø§Ù„Ø±Ø¦ÙŠØ³ÙŠØ©",importExport:"Ø§Ø³ØªÙŠØ±Ø§Ø¯ / ØªØµØ¯ÙŠØ±",traneem:"Ø§Ù„ØªØ±Ø§Ù†ÙŠÙ…",bible:"Ø§Ù„ÙƒØªØ§Ø¨ Ø§Ù„Ù…Ù‚Ø¯Ø³",agpeya:"Ø§Ù„Ø£Ø¬Ø¨ÙŠØ©",liturgy:"Ø§Ù„Ù‚Ø¯Ø§Ø³",readings:"Ø§Ù„Ù‚Ø±Ø§Ø¡Ø§Øª",themeDesign:"Ø§Ù„Ù…Ø¸Ù‡Ø±",preview:"Ù…Ø¹Ø§ÙŠÙ†Ø©",settings:"Ø§Ù„Ø¥Ø¹Ø¯Ø§Ø¯Ø§Øª",overview:"Ù†Ø¸Ø±Ø© Ø¹Ø§Ù…Ø©.",traneemHymns:"ØªØ±Ø§Ù†ÙŠÙ…",bibleBooks:"Ø£Ø³ÙØ§Ø±",agpeyaPrayers:"ØµÙ„ÙˆØ§Øª",liturgyParts:"Ø£Ø¬Ø²Ø§Ø¡",copticReadings:"Ù‚Ø±Ø§Ø¡Ø§Øª",themes:"Ù…Ø¸Ø§Ù‡Ø±",howToUse:"ÙƒÙŠÙÙŠØ© Ø§Ù„Ø§Ø³ØªØ®Ø¯Ø§Ù…",dataSource:"Ù…ØµØ¯Ø± Ø§Ù„Ø¨ÙŠØ§Ù†Ø§Øª",noData:"Ù„Ø§ ØªÙˆØ¬Ø¯ Ø¨ÙŠØ§Ù†Ø§Øª",dataLoaded:"ØªÙ… Ø§Ù„ØªØ­Ù…ÙŠÙ„!",help1:"Ø§Ø³ØªÙŠØ±Ø§Ø¯: Ø§Ø±ÙØ¹ Ù…Ù„ÙØ§Øª.",help2:"ØªØ¹Ø¯ÙŠÙ„: ØªØµÙØ­ Ø§Ù„Ø£Ù‚Ø³Ø§Ù….",help3:"Ù…Ø¹Ø§ÙŠÙ†Ø©: Ø´Ø§Ù‡Ø¯ Ø§Ù„Ù…Ø­ØªÙˆÙ‰.",help4:"Ù…Ø¸Ù‡Ø±: Ø®ØµØµ Ø§Ù„Ø¥Ø¹Ø¯Ø§Ø¯Ø§Øª.",help5:"ØªØµØ¯ÙŠØ±: ØªØ­Ù…ÙŠÙ„ ZIP.",importData:"Ø§Ø³ØªÙŠØ±Ø§Ø¯",uploadZip:"Ø±ÙØ¹ ZIP",uploadJson:"Ø±ÙØ¹ JSON",pasteJson:"Ù„ØµÙ‚ JSON",importPaste:"Ø§Ø³ØªÙŠØ±Ø§Ø¯",sampleData:"Ø¨ÙŠØ§Ù†Ø§Øª Ù†Ù…ÙˆØ°Ø¬ÙŠØ©",exportZip:"ØªØµØ¯ÙŠØ± ZIP",exportFlutter:"ØªØµØ¯ÙŠØ±",importBtn:"Ø§Ø³ØªÙŠØ±Ø§Ø¯",traneemDesc:"Ø¥Ø¯Ø§Ø±Ø© Ø§Ù„ØªØ±Ø§Ù†ÙŠÙ….",addHymn:"Ø¥Ø¶Ø§ÙØ© ØªØ±Ù†ÙŠÙ…Ø©",searchHymns:"Ø¨Ø­Ø«...",bibleDesc:"Ø¥Ø¯Ø§Ø±Ø© Ø§Ù„Ø£Ø³ÙØ§Ø±.",addBook:"Ø¥Ø¶Ø§ÙØ© Ø³ÙØ±",searchBooks:"Ø¨Ø­Ø«...",agpeyaDesc:"Ø¥Ø¯Ø§Ø±Ø© Ø§Ù„ØµÙ„ÙˆØ§Øª.",addPrayer:"Ø¥Ø¶Ø§ÙØ© ØµÙ„Ø§Ø©",searchPrayers:"Ø¨Ø­Ø«...",liturgyDesc:"Ø¥Ø¯Ø§Ø±Ø© Ø§Ù„Ù‚Ø¯Ø§Ø³.",addLiturgy:"Ø¥Ø¶Ø§ÙØ© Ø¬Ø²Ø¡",searchLiturgy:"Ø¨Ø­Ø«...",readingsDesc:"Ø¥Ø¯Ø§Ø±Ø© Ø§Ù„Ù‚Ø±Ø§Ø¡Ø§Øª.",addReading:"Ø¥Ø¶Ø§ÙØ© Ù‚Ø±Ø§Ø¡Ø©",searchReadings:"Ø¨Ø­Ø«...",themeDesc:"ØªØ®ØµÙŠØµ Ø§Ù„Ù…Ø¸Ù‡Ø±.",appIdentity:"Ù‡ÙˆÙŠØ© Ø§Ù„ØªØ·Ø¨ÙŠÙ‚",appNameEn:"Ø§Ù„Ø§Ø³Ù… (Ø¥Ù†Ø¬Ù„ÙŠØ²ÙŠ)",appNameAr:"Ø§Ù„Ø§Ø³Ù… (Ø¹Ø±Ø¨ÙŠ)",developer:"Ø§Ù„Ù…Ø·ÙˆØ±",version:"Ø§Ù„Ø¥ØµØ¯Ø§Ø±",descEn:"Ø§Ù„ÙˆØµÙ (Ø¥Ù†Ø¬Ù„ÙŠØ²ÙŠ)",descAr:"Ø§Ù„ÙˆØµÙ (Ø¹Ø±Ø¨ÙŠ)",themeColors:"Ø§Ù„Ø£Ù„ÙˆØ§Ù†",primary:"Ø£Ø³Ø§Ø³ÙŠ",secondary:"Ø«Ø§Ù†ÙˆÙŠ",bgLight:"Ø®Ù„ÙÙŠØ© ÙØ§ØªØ­Ø©",bgDark:"Ø®Ù„ÙÙŠØ© Ø¯Ø§ÙƒÙ†Ø©",textLight:"Ù†Øµ ÙØ§ØªØ­",textDark:"Ù†Øµ Ø¯Ø§ÙƒÙ†",cardBg:"Ø®Ù„ÙÙŠØ© Ø§Ù„Ø¨Ø·Ø§Ù‚Ø©",borderColor:"Ø­Ø¯ÙˆØ¯",backgroundImage:"ØµÙˆØ±Ø© Ø®Ù„ÙÙŠØ©",noBackground:"Ù„Ø§ ØªÙˆØ¬Ø¯ ØµÙˆØ±Ø©",logoIcons:"Ø§Ù„Ø´Ø¹Ø§Ø±Ø§Øª",appLogo:"Ø´Ø¹Ø§Ø±",appIcon:"Ø£ÙŠÙ‚ÙˆÙ†Ø©",logoUrl:"Ø±Ø§Ø¨Ø· Ø§Ù„Ø´Ø¹Ø§Ø±",iconUrl:"Ø±Ø§Ø¨Ø· Ø§Ù„Ø£ÙŠÙ‚ÙˆÙ†Ø©",noLogo:"Ù„Ø§ ÙŠÙˆØ¬Ø¯ Ø´Ø¹Ø§Ø±",fontSettings:"Ø§Ù„Ø®Ø·ÙˆØ·",bodyFont:"Ø®Ø· Ø§Ù„Ù†Øµ",arabicFont:"Ø®Ø· Ø¹Ø±Ø¨ÙŠ",baseSize:"Ø§Ù„Ø­Ø¬Ù… Ø§Ù„Ø£Ø³Ø§Ø³ÙŠ",headingSize:"Ø­Ø¬Ù… Ø§Ù„Ø¹Ù†ÙˆØ§Ù†",saveTheme:"Ø­ÙØ¸",previewDesc:"Ù…Ø¹Ø§ÙŠÙ†Ø© Ø§Ù„Ù…Ø­ØªÙˆÙ‰.",lightMode:"ÙØ§ØªØ­",darkMode:"Ø¯Ø§ÙƒÙ†",arabicLang:"Ø¹Ø±Ø¨ÙŠ",englishLang:"Ø¥Ù†Ø¬Ù„ÙŠØ²ÙŠ",importToPreview:"Ø§Ø³ØªÙˆØ±Ø¯ Ø¨ÙŠØ§Ù†Ø§Øª",repo:"Ø§Ù„Ù…Ø³ØªÙˆØ¯Ø¹",token:"Ø§Ù„Ø±Ù…Ø²",syncBtn:"Ù…Ø²Ø§Ù…Ù†Ø©",dataManagement:"Ø¥Ø¯Ø§Ø±Ø© Ø§Ù„Ø¨ÙŠØ§Ù†Ø§Øª",resetAll:"Ø¥Ø¹Ø§Ø¯Ø© ØªØ¹ÙŠÙŠÙ†",saved:"ØªÙ… Ø§Ù„Ø­ÙØ¸!",deleted:"ØªÙ… Ø§Ù„Ø­Ø°Ù!",imported:"ØªÙ… Ø§Ù„Ø§Ø³ØªÙŠØ±Ø§Ø¯!",invalidJson:"JSON ØºÙŠØ± ØµØ§Ù„Ø­",idRequired:"Ø§Ù„Ù…Ø¹Ø±Ù Ù…Ø·Ù„ÙˆØ¨",confirmReset:"Ø¥Ø¹Ø§Ø¯Ø© ØªØ¹ÙŠÙŠÙ† Ø¬Ù…ÙŠØ¹ Ø§Ù„Ø¨ÙŠØ§Ù†Ø§ØªØŸ",noDataFound:"Ù„Ø§ ØªÙˆØ¬Ø¯ Ø¨ÙŠØ§Ù†Ø§Øª.",stanzas:"Ù…Ù‚Ø§Ø·Ø¹",chapters:"Ø£ØµØ­Ø§Ø­Ø§Øª",switchLang:"English" }
  };
  function t(k) { return (I18N[currentLang] && I18N[currentLang][k]) || (I18N.en[k] || k); }

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
      status.textContent = 'âœ… Data loaded - ' + getDataSummary();
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
      return '<div class="item-row" onclick="editTraneem(\'' + item.lang + '\',\'' + (d.id || '') + '\')"><div><span class="item-title">' + title + '</span><br><span class="item-meta">' + subtitle + ' â€¢ ' + stanzas + ' stanzas â€¢ ' + item.lang.toUpperCase() + '</span></div><span>âœï¸</span></div>';
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
    var sample = { id: 'new-hymn', title: 'New Hymn', arabicTitle: 'ØªØ±Ù†ÙŠÙ…Ø© Ø¬Ø¯ÙŠØ¯Ø©', category: 'Liturgical', categoryAr: 'Ø·Ù‚Ø³ÙŠØ©', stanzas: [{ title: 'Stanza 1', lines: ['Line 1', 'Line 2'] }] };
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
      return '<div class="item-row" onclick="editBible(\'' + item.lang + '\',\'' + (d.bookId || '') + '\')"><div><span class="item-title">' + (d.bookName || d.bookId) + '</span><br><span class="item-meta">' + (d.bookId || '') + ' â€¢ ' + chCount + ' chapters â€¢ ' + item.lang.toUpperCase() + '</span></div><span>âœï¸</span></div>';
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

// Coptic Companion Admin - Firebase-powered Bilingual Panel
(function() {
  'use strict';
  
  var STORAGE_KEY = 'coptic_admin_data';
  var LANG_KEY = 'admin_lang';
  var currentLang = localStorage.getItem(LANG_KEY) || 'en';
  var db = null;
  var unsubscribers = [];
  
  var appData = {
    traneem: { ar: [], en: [] },
    bible: { ar: [], en: [] },
    agpeya: { ar: [], en: [] },
    liturgy: { ar: [], en: [] },
    readings: [],
    design: {
      nameEn: "Coptic Companion", nameAr: "الرفيق القبطي",
      developer: "", version: "1.0.0", descEn: "", descAr: "",
      colors: { primary: "#8B2332", secondary: "#D4AF37", bgLight: "#FDF8F0", bgDark: "#1A0F0A", textLight: "#2C1810", textDark: "#E8D5A3", card: "#FFFFFF", border: "#E0D5C5" },
      fonts: { body: "Cairo", arabic: "Amiri", sizeBase: 16, sizeHeading: 24 },
      logoUrl: "", iconUrl: "", bgLightUrl: "", bgDarkUrl: ""
    }
  };

  // Translations
  var I18N = {
    en: { appTitle:"Coptic Companion",appSubtitle:"Full App Admin",dashboard:"Dashboard",importExport:"Import / Export",traneem:"Traneem",bible:"Bible",agpeya:"Agpeya",liturgy:"Liturgy",readings:"Readings",themeDesign:"Theme & Design",preview:"Preview",settings:"Settings",overview:"Overview of all app content.",traneemHymns:"Traneem Hymns",bibleBooks:"Bible Books",agpeyaPrayers:"Agpeya Prayers",liturgyParts:"Liturgy Parts",copticReadings:"Coptic Readings",themes:"Themes",howToUse:"How to Use",dataSource:"Data Source",noData:"No data loaded.",dataLoaded:"Data loaded!",help1:"Import: Upload assets or JSON.",help2:"Edit: Navigate sections.",help3:"Preview: See content in app view.",help4:"Theme: Customize appearance.",help5:"Export: Download ZIP for Flutter.",importData:"Import Data",uploadZip:"Upload ZIP",uploadJson:"Upload JSON",pasteJson:"Paste JSON",importPaste:"Import",sampleData:"Load Sample Data",exportZip:"Export ZIP for Flutter",exportFlutter:"Export for Flutter",importBtn:"Import",traneemDesc:"Manage hymns.",addHymn:"Add Hymn",searchHymns:"Search hymns...",bibleDesc:"Manage Bible books.",addBook:"Add Book",searchBooks:"Search books...",agpeyaDesc:"Manage prayers.",addPrayer:"Add Prayer",searchPrayers:"Search...",liturgyDesc:"Manage liturgy.",addLiturgy:"Add Part",searchLiturgy:"Search...",readingsDesc:"Manage readings.",addReading:"Add Reading",searchReadings:"Search...",themeDesc:"Customize appearance.",appIdentity:"App Identity",appNameEn:"Name (EN)",appNameAr:"Name (AR)",developer:"Developer",version:"Version",descEn:"Description (EN)",descAr:"Description (AR)",themeColors:"Colors",primary:"Primary",secondary:"Secondary",bgLight:"BG Light",bgDark:"BG Dark",textLight:"Text Light",textDark:"Text Dark",cardBg:"Card BG",borderColor:"Border",backgroundImage:"Background",noBackground:"No background",logoIcons:"Logo & Icons",appLogo:"Logo",appIcon:"Icon",logoUrl:"Logo URL",iconUrl:"Icon URL",noLogo:"No logo",fontSettings:"Fonts",bodyFont:"Body Font",arabicFont:"Arabic Font",baseSize:"Base Size",headingSize:"Heading Size",saveTheme:"Save Theme",previewDesc:"Preview content.",lightMode:"Light",darkMode:"Dark",arabicLang:"Arabic",englishLang:"English",importToPreview:"Import data to preview",repo:"Repository",token:"Token",syncBtn:"Sync",dataManagement:"Data Management",resetAll:"Reset All",editHymn:"Edit Hymn",editBible:"Edit Book",editPrayer:"Edit Prayer",editLiturgy:"Edit Liturgy",editReading:"Edit Reading",jsonData:"JSON Data",livePreview:"Live Preview",cancel:"Cancel",deleteBtn:"Delete",saveBtn:"Save",fieldTitle:"Title",fieldTitleAr:"Title (Arabic)",fieldId:"ID",fieldCategory:"Category",fieldCategoryAr:"Category (Arabic)",fieldBookId:"Book ID",fieldBookName:"Book Name",fieldChapters:"Chapters",fieldStanzas:"Stanzas",fieldLines:"Lines",fieldVerse:"Verse",fieldText:"Text",fieldType:"Type",addLine:"Add Line",addStanza:"Add Stanza",addVerse:"Add Verse",addChapter:"Add Chapter",saved:"Saved!",deleted:"Deleted!",imported:"Imported!",invalidJson:"Invalid JSON",idRequired:"ID required",confirmReset:"Reset all data?",noDataFound:"No data found.",stanzas:"stanzas",chapters:"chapters",verses:"verses",switchLang:"عربي",syncing:"Syncing...",synced:"Synced!",offline:"Offline mode",online:"Online" },
    ar: { appTitle:"الرفيق القبطي",appSubtitle:"لوحة الإدارة",dashboard:"الرئيسية",importExport:"استيراد / تصدير",traneem:"الترانيم",bible:"الكتاب المقدس",agpeya:"الأجبية",liturgy:"القداس",readings:"القراءات",themeDesign:"المظهر",preview:"معاينة",settings:"الإعدادات",overview:"نظرة عامة.",traneemHymns:"ترانيم",bibleBooks:"أسفار",agpeyaPrayers:"صلوات",liturgyParts:"أجزاء",copticReadings:"قراءات",themes:"مظاهر",howToUse:"كيفية الاستخدام",dataSource:"مصدر البيانات",noData:"لا توجد بيانات",dataLoaded:"تم التحميل!",help1:"استيراد: ارفع ملفات.",help2:"تعديل: تصفح الأقسام.",help3:"معاينة: شاهد المحتوى.",help4:"مظهر: خصص الإعدادات.",help5:"تصدير: تحميل ZIP.",importData:"استيراد",uploadZip:"رفع ZIP",uploadJson:"رفع JSON",pasteJson:"لصق JSON",importPaste:"استيراد",sampleData:"بيانات نموذجية",exportZip:"تصدير ZIP",exportFlutter:"تصدير",importBtn:"استيراد",traneemDesc:"إدارة الترانيم.",addHymn:"إضافة ترنيمة",searchHymns:"بحث...",bibleDesc:"إدارة الأسفار.",addBook:"إضافة سفر",searchBooks:"بحث...",agpeyaDesc:"إدارة الصلوات.",addPrayer:"إضافة صلاة",searchPrayers:"بحث...",liturgyDesc:"إدارة القداس.",addLiturgy:"إضافة جزء",searchLiturgy:"بحث...",readingsDesc:"إدارة القراءات.",addReading:"إضافة قراءة",searchReadings:"بحث...",themeDesc:"تخصيص المظهر.",appIdentity:"هوية التطبيق",appNameEn:"الاسم (إنجليزي)",appNameAr:"الاسم (عربي)",developer:"المطور",version:"الإصدار",descEn:"الوصف (إنجليزي)",descAr:"الوصف (عربي)",themeColors:"الألوان",primary:"أساسي",secondary:"ثانوي",bgLight:"خلفية فاتحة",bgDark:"خلفية داكنة",textLight:"نص فاتح",textDark:"نص داكن",cardBg:"خلفية البطاقة",borderColor:"حدود",backgroundImage:"صورة خلفية",noBackground:"لا توجد صورة",logoIcons:"الشعارات",appLogo:"شعار",appIcon:"أيقونة",logoUrl:"رابط الشعار",iconUrl:"رابط الأيقونة",noLogo:"لا يوجد شعار",fontSettings:"الخطوط",bodyFont:"خط النص",arabicFont:"خط عربي",baseSize:"الحجم الأساسي",headingSize:"حجم العنوان",saveTheme:"حفظ",previewDesc:"معاينة المحتوى.",lightMode:"فاتح",darkMode:"داكن",arabicLang:"عربي",englishLang:"إنجليزي",importToPreview:"استورد بيانات",repo:"المستودع",token:"الرمز",syncBtn:"مزامنة",dataManagement:"إدارة البيانات",resetAll:"إعادة تعيين",editHymn:"تعديل ترنيمة",editBible:"تعديل سفر",editPrayer:"تعديل صلاة",editLiturgy:"تعديل قداس",editReading:"تعديل قراءة",jsonData:"بيانات JSON",livePreview:"معاينة مباشرة",cancel:"إلغاء",deleteBtn:"حذف",saveBtn:"حفظ",fieldTitle:"العنوان",fieldTitleAr:"العنوان (عربي)",fieldId:"المعرف",fieldCategory:"الفئة",fieldCategoryAr:"الفئة (عربي)",fieldBookId:"معرف السفر",fieldBookName:"اسم السفر",fieldChapters:"الأصحاحات",fieldStanzas:"المقاطع",fieldLines:"الأسطر",fieldVerse:"آية",fieldText:"النص",fieldType:"النوع",addLine:"إضافة سطر",addStanza:"إضافة مقطع",addVerse:"إضافة آية",addChapter:"إضافة أصحاح",saved:"تم الحفظ!",deleted:"تم الحذف!",imported:"تم الاستيراد!",invalidJson:"JSON غير صالح",idRequired:"المعرف مطلوب",confirmReset:"إعادة تعيين جميع البيانات؟",noDataFound:"لا توجد بيانات.",stanzas:"مقاطع",chapters:"أصحاحات",verses:"آيات",switchLang:"English",syncing:"جاري المزامنة...",synced:"تمت المزامنة!",offline:"وضع عدم الاتصال",online:"متصل" }
  };
  function t(k) { return (I18N[currentLang] && I18N[currentLang][k]) || (I18N.en[k] || k); }
  // ============================================================
  // FIREBASE FUNCTIONS
  // ============================================================
  
  // Load data from Firebase with real-time updates
  function setupFirebaseListeners() {
    if (!window.firebaseDB) {
      console.warn('Firebase not available, using localStorage');
      loadFromLocalStorage();
      return;
    }
    
    db = window.firebaseDB;
    
    // Listen to traneem collection
    var traneemUnsub = onSnapshot(collection(db, 'traneem'), function(snapshot) {
      appData.traneem.ar = [];
      appData.traneem.en = [];
      snapshot.forEach(function(doc) {
        var data = doc.data();
        if (data.lang === 'ar') appData.traneem.ar.push(data);
        else appData.traneem.en.push(data);
      });
      refreshAll();
    }, function(err) {
      console.warn('Traneem listener error, using cache:', err);
    });
    unsubscribers.push(traneemUnsub);
    
    // Listen to bible collection
    var bibleUnsub = onSnapshot(collection(db, 'bible'), function(snapshot) {
      appData.bible.ar = [];
      appData.bible.en = [];
      snapshot.forEach(function(doc) {
        var data = doc.data();
        if (data.lang === 'ar') appData.bible.ar.push(data);
        else appData.bible.en.push(data);
      });
      refreshAll();
    });
    unsubscribers.push(bibleUnsub);
    
    // Listen to agpeya collection
    var agpeyaUnsub = onSnapshot(collection(db, 'agpeya'), function(snapshot) {
      appData.agpeya.ar = [];
      appData.agpeya.en = [];
      snapshot.forEach(function(doc) {
        var data = doc.data();
        if (data.lang === 'ar') appData.agpeya.ar.push(data);
        else appData.agpeya.en.push(data);
      });
      refreshAll();
    });
    unsubscribers.push(agpeyaUnsub);
    
    // Listen to liturgy collection
    var liturgyUnsub = onSnapshot(collection(db, 'liturgy'), function(snapshot) {
      appData.liturgy.ar = [];
      appData.liturgy.en = [];
      snapshot.forEach(function(doc) {
        var data = doc.data();
        if (data.lang === 'ar') appData.liturgy.ar.push(data);
        else appData.liturgy.en.push(data);
      });
      refreshAll();
    });
    unsubscribers.push(liturgyUnsub);
    
    // Listen to readings collection
    var readingsUnsub = onSnapshot(collection(db, 'readings'), function(snapshot) {
      appData.readings = [];
      snapshot.forEach(function(doc) {
        appData.readings.push(doc.data());
      });
      refreshAll();
    });
    unsubscribers.push(readingsUnsub);
    
    // Listen to design document
    var designUnsub = onSnapshot(doc(db, 'settings', 'design'), function(docSnap) {
      if (docSnap.exists()) {
        appData.design = docSnap.data();
        refreshAll();
      }
    });
    unsubscribers.push(designUnsub);
    
    // Update connection status
    updateConnectionStatus();
  }
  
  // Save to Firebase
  async function saveToFirebase(collectionName, docId, data) {
    if (!window.firebaseDB) return saveToLocalStorage();
    try {
      await setDoc(doc(window.firebaseDB, collectionName, docId), data);
      return true;
    } catch(e) {
      console.error('Firebase save error:', e);
      return false;
    }
  }
  
  // Delete from Firebase
  async function deleteFromFirebase(collectionName, docId) {
    if (!window.firebaseDB) return;
    try {
      await deleteDoc(doc(window.firebaseDB, collectionName, docId));
      return true;
    } catch(e) {
      console.error('Firebase delete error:', e);
      return false;
    }
  }
  
  // Local storage fallback
  function loadFromLocalStorage() {
    try {
      var raw = localStorage.getItem(STORAGE_KEY);
      if (raw) appData = JSON.parse(raw);
    } catch(e) {}
    refreshAll();
  }
  
  function saveToLocalStorage() {
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(appData));
    } catch(e) {}
  }
  
  // Update connection status indicator
  function updateConnectionStatus() {
    var statusEl = document.getElementById('connectionStatus');
    if (!statusEl) return;
    if (navigator.onLine) {
      statusEl.textContent = t('online');
      statusEl.className = 'status-online';
    } else {
      statusEl.textContent = t('offline');
      statusEl.className = 'status-offline';
    }
  }
  // ============================================================
  // CORE FUNCTIONS
  // ============================================================
  function showSection(id) {
    document.querySelectorAll('.content-section').forEach(function(s) { s.classList.remove('active'); });
    document.querySelectorAll('.nav-item').forEach(function(n) { n.classList.remove('active'); });
    var el = document.getElementById(id); if (el) el.classList.add('active');
    var nav = document.querySelector('.nav-item[data-section="' + id + '"]'); if (nav) nav.classList.add('active');
  }
  window.closeModal = function(id) { var m = document.getElementById(id); if (m) m.style.display = 'none'; };
  window.showSection = showSection;
  function showToast(msg) {
    var t = document.getElementById('toast'); var m = document.getElementById('toast-message');
    if (t && m) { m.textContent = msg; t.style.display = 'block'; setTimeout(function() { t.style.display = 'none'; }, 3000); }
  }
  function toggleLanguage() {
    currentLang = currentLang === 'en' ? 'ar' : 'en';
    localStorage.setItem(LANG_KEY, currentLang);
    document.documentElement.setAttribute('dir', currentLang === 'ar' ? 'rtl' : 'ltr');
    document.documentElement.setAttribute('lang', currentLang);
    applyTranslations();
    refreshAll();
  }
  window.toggleLanguage = toggleLanguage;
  function applyTranslations() {
    document.querySelectorAll('[data-t]').forEach(function(el) {
      var key = el.getAttribute('data-t');
      el.textContent = t(key);
    });
    var lbtn = document.getElementById('langToggle');
    if (lbtn) lbtn.textContent = t('switchLang');
  }
  function updateStats() {
    var el = function(id) { return document.getElementById(id); };
    if (el('stat-traneem')) el('stat-traneem').textContent = appData.traneem.ar.length + appData.traneem.en.length;
    if (el('stat-bible')) el('stat-bible').textContent = appData.bible.ar.length + appData.bible.en.length;
    if (el('stat-agpeya')) el('stat-agpeya').textContent = appData.agpeya.ar.length + appData.agpeya.en.length;
    if (el('stat-liturgy')) el('stat-liturgy').textContent = appData.liturgy.ar.length + appData.liturgy.en.length;
    if (el('stat-readings')) el('stat-readings').textContent = appData.readings.length;
    if (el('stat-themes')) el('stat-themes').textContent = 1;
  }
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
      return '<div class="item-row" onclick="editTraneem(\'' + it.lang + '\',\'' + (d.id || '') + '\')"><div><span class="item-title">' + title + '</span><br><span class="item-meta">' + stanzas + ' ' + t('stanzas') + ' | ' + it.lang.toUpperCase() + '</span></div><span>✏️</span></div>';
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
      return '<div class="item-row" onclick="editBible(\'' + it.lang + '\',\'' + (d.bookId || '') + '\')"><div><span class="item-title">' + (d.bookName || d.bookId) + '</span><br><span class="item-meta">' + (d.bookId || '') + ' | ' + chCount + ' ' + t('chapters') + ' | ' + it.lang.toUpperCase() + '</span></div><span>✏️</span></div>';
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
      return '<div class="item-row" onclick="editAgpeya(\'' + it.lang + '\',\'' + (d.id || '') + '\')"><div><span class="item-title">' + name + '</span><br><span class="item-meta">' + (d.id || '') + ' | ' + it.lang.toUpperCase() + '</span></div><span>✏️</span></div>';
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
      return '<div class="item-row" onclick="editLiturgy(\'' + it.lang + '\',\'' + (d.id || d.name || '') + '\')"><div><span class="item-title">' + (d.name || d.id || 'Liturgy') + '</span><br><span class="item-meta">' + it.lang.toUpperCase() + '</span></div><span>✏️</span></div>';
    }).join('');
  }
  function renderReadingsList() {
    var c = document.getElementById('readings-list');
    if (!c) return;
    if (!appData.readings.length) { c.innerHTML = '<p class="empty-state">' + t('noDataFound') + '</p>'; return; }
    c.innerHTML = appData.readings.map(function(r, i) {
      return '<div class="item-row" onclick="editReading(' + i + ')"><div><span class="item-title">' + (r.title || r.type || 'Reading') + '</span><br><span class="item-meta">' + (r.type || '') + '</span></div><span>✏️</span></div>';
    }).join('');
  }
  function renderDesignForm() {
    var d = appData.design;
    var s = function(id, val) { var e = document.getElementById(id); if (e) e.value = val; };
    s('app-name-en', d.nameEn || '');
    s('app-name-ar', d.nameAr || '');
    s('app-developer', d.developer || '');
    s('app-version', d.version || '1.0.0');
    s('app-desc-en', d.descEn || '');
    s('app-desc-ar', d.descAr || '');
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
    s('logo-url', d.logoUrl || '');
    s('icon-url', d.iconUrl || '');
    s('bg-light-url', d.bgLightUrl || '');
    s('bg-dark-url', d.bgDarkUrl || '');
  }
  // ============================================================
  // EDITOR FUNCTIONS
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
  
  // Save functions - write to Firebase
  async function saveHymn() {
    var json = document.getElementById('hymn-json').value;
    var lang = document.getElementById('hymn-json').dataset.lang;
    try {
      var data = JSON.parse(json);
      if (!data.id) { showToast(t('idRequired')); return; }
      data.lang = lang;
      data.updatedAt = new Date().toISOString();
      await saveToFirebase('traneem', data.id + '_' + lang, data);
      closeModal('modal-hymn'); showToast(t('saved'));
    } catch(e) { showToast(t('invalidJson')); }
  }
  async function deleteHymn() {
    var lang = document.getElementById('hymn-json').dataset.lang;
    var id = document.getElementById('hymn-json').dataset.id;
    if (!id) return;
    await deleteFromFirebase('traneem', id + '_' + lang);
    closeModal('modal-hymn'); showToast(t('deleted'));
  }
  async function saveBible() {
    var json = document.getElementById('bible-json').value;
    var lang = document.getElementById('bible-json').dataset.lang;
    try {
      var data = JSON.parse(json);
      if (!data.bookId) { showToast(t('idRequired')); return; }
      data.lang = lang;
      data.updatedAt = new Date().toISOString();
      await saveToFirebase('bible', data.bookId + '_' + lang, data);
      closeModal('modal-bible'); showToast(t('saved'));
    } catch(e) { showToast(t('invalidJson')); }
  }
  async function deleteBible() {
    var lang = document.getElementById('bible-json').dataset.lang;
    var id = document.getElementById('bible-json').dataset.id;
    if (!id) return;
    await deleteFromFirebase('bible', id + '_' + lang);
    closeModal('modal-bible'); showToast(t('deleted'));
  }
  async function saveAgpeya() {
    var json = document.getElementById('agpeya-json').value;
    var lang = document.getElementById('agpeya-json').dataset.lang;
    try {
      var data = JSON.parse(json);
      if (!data.id) { showToast(t('idRequired')); return; }
      data.lang = lang;
      data.updatedAt = new Date().toISOString();
      await saveToFirebase('agpeya', data.id + '_' + lang, data);
      closeModal('modal-agpeya'); showToast(t('saved'));
    } catch(e) { showToast(t('invalidJson')); }
  }
  async function deleteAgpeya() {
    var lang = document.getElementById('agpeya-json').dataset.lang;
    var id = document.getElementById('agpeya-json').dataset.id;
    if (!id) return;
    await deleteFromFirebase('agpeya', id + '_' + lang);
    closeModal('modal-agpeya'); showToast(t('deleted'));
  }
  async function saveLiturgy() {
    var json = document.getElementById('liturgy-json').value;
    var lang = document.getElementById('liturgy-json').dataset.lang;
    try {
      var data = JSON.parse(json);
      data.lang = lang;
      data.updatedAt = new Date().toISOString();
      var docId = (data.id || data.name || 'liturgy') + '_' + lang;
      await saveToFirebase('liturgy', docId, data);
      closeModal('modal-liturgy'); showToast(t('saved'));
    } catch(e) { showToast(t('invalidJson')); }
  }
  async function deleteLiturgy() {
    var lang = document.getElementById('liturgy-json').dataset.lang;
    var id = document.getElementById('liturgy-json').dataset.id;
    if (!id) return;
    await deleteFromFirebase('liturgy', id + '_' + lang);
    closeModal('modal-liturgy'); showToast(t('deleted'));
  }
  async function saveReading() {
    var json = document.getElementById('reading-json').value;
    var idx = parseInt(document.getElementById('reading-json').dataset.idx);
    try {
      var data = JSON.parse(json);
      data.updatedAt = new Date().toISOString();
      var docId = data.id || data.type || ('reading_' + idx);
      await saveToFirebase('readings', docId, data);
      closeModal('modal-reading'); showToast(t('saved'));
    } catch(e) { showToast(t('invalidJson')); }
  }
  async function deleteReading() {
    var idx = parseInt(document.getElementById('reading-json').dataset.idx);
    var item = appData.readings[idx];
    if (!item) return;
    var docId = item.id || item.type || ('reading_' + idx);
    await deleteFromFirebase('readings', docId);
    closeModal('modal-reading'); showToast(t('deleted'));
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
    showToast(t('saved'));
  }
  // ============================================================
  // INITIALIZATION
  // ============================================================
  document.addEventListener('DOMContentLoaded', function() {
    // Set initial language direction
    document.documentElement.setAttribute('dir', currentLang === 'ar' ? 'rtl' : 'ltr');
    document.documentElement.setAttribute('lang', currentLang);
    
    var f = function(id) { return document.getElementById(id); };
    var bind = function(el, ev, fn) { if (el) el.addEventListener(ev, fn); };
    
    // Navigation
    document.querySelectorAll('.nav-item').forEach(function(btn) {
      btn.addEventListener('click', function() { showSection(btn.dataset.section); });
    });
    
    // Language toggle
    bind(f('langToggle'), 'click', toggleLanguage);
    
    // Traneem
    bind(f('addHymnBtn'), 'click', function() {
      var sample = { id: 'new_' + Date.now(), title: 'New Hymn', arabicTitle: 'ترنيمة جديدة', category: 'Liturgical', categoryAr: 'طقسية', stanzas: [{ title: 'Stanza 1', lines: ['Line 1'] }] };
      openModal('modal-hymn');
      document.getElementById('hymn-modal-title').textContent = t('editHymn');
      document.getElementById('hymn-json').value = JSON.stringify(sample, null, 2);
      document.getElementById('hymn-json').dataset.lang = 'ar';
      document.getElementById('hymn-json').dataset.id = sample.id;
      document.getElementById('deleteHymnBtn').style.display = 'none';
    });
    bind(f('saveHymnBtn'), 'click', saveHymn);
    bind(f('deleteHymnBtn'), 'click', deleteHymn);
    bind(f('traneemSearch'), 'input', renderTraneemList);
    
    // Bible
    bind(f('addBibleBookBtn'), 'click', function() {
      var sample = { bookId: 'new_' + Date.now(), bookName: 'New Book', chapters: [{ chapterNumber: 1, verses: [{ number: 1, text: 'Verse 1' }] }] };
      openModal('modal-bible');
      document.getElementById('bible-modal-title').textContent = t('editBible');
      document.getElementById('bible-json').value = JSON.stringify(sample, null, 2);
      document.getElementById('bible-json').dataset.lang = 'ar';
      document.getElementById('bible-json').dataset.id = sample.bookId;
      document.getElementById('deleteBibleBtn').style.display = 'none';
    });
    bind(f('saveBibleBtn'), 'click', saveBible);
    bind(f('deleteBibleBtn'), 'click', deleteBible);
    bind(f('bibleSearch'), 'input', renderBibleList);
    
    // Agpeya
    bind(f('addAgpeyaBtn'), 'click', function() {
      var sample = { id: 'new_' + Date.now(), name: 'New Prayer', englishName: 'New Prayer', opening: { title: 'Introduction', content: ['Opening line'], inline: true } };
      openModal('modal-agpeya');
      document.getElementById('agpeya-modal-title').textContent = t('editPrayer');
      document.getElementById('agpeya-json').value = JSON.stringify(sample, null, 2);
      document.getElementById('agpeya-json').dataset.lang = 'ar';
      document.getElementById('agpeya-json').dataset.id = sample.id;
      document.getElementById('deleteAgpeyaBtn').style.display = 'none';
    });
    bind(f('saveAgpeyaBtn'), 'click', saveAgpeya);
    bind(f('deleteAgpeyaBtn'), 'click', deleteAgpeya);
    bind(f('agpeyaSearch'), 'input', renderAgpeyaList);
    
    // Liturgy
    bind(f('addLiturgyBtn'), 'click', function() {
      var sample = { id: 'new_' + Date.now(), name: 'New Liturgy', sections: [{ title: 'Section 1', content: ['Content line'] }] };
      openModal('modal-liturgy');
      document.getElementById('liturgy-modal-title').textContent = t('editLiturgy');
      document.getElementById('liturgy-json').value = JSON.stringify(sample, null, 2);
      document.getElementById('liturgy-json').dataset.lang = 'ar';
      document.getElementById('liturgy-json').dataset.id = sample.id;
      document.getElementById('deleteLiturgyBtn').style.display = 'none';
    });
    bind(f('saveLiturgyBtn'), 'click', saveLiturgy);
    bind(f('deleteLiturgyBtn'), 'click', deleteLiturgy);
    bind(f('liturgySearch'), 'input', renderLiturgyList);
    
    // Readings
    bind(f('addReadingBtn'), 'click', function() {
      var sample = { id: 'new_' + Date.now(), type: 'gospel', title: 'New Reading', reference: 'John 1:1-14', text: 'In the beginning...' };
      openModal('modal-reading');
      document.getElementById('reading-modal-title').textContent = t('editReading');
      document.getElementById('reading-json').value = JSON.stringify(sample, null, 2);
      document.getElementById('reading-json').dataset.idx = '-1';
      document.getElementById('deleteReadingBtn').style.display = 'none';
    });
    bind(f('saveReadingBtn'), 'click', saveReading);
    bind(f('deleteReadingBtn'), 'click', deleteReading);
    bind(f('readingsSearch'), 'input', renderReadingsList);
    
    // Design
    bind(f('saveDesignBtn'), 'click', saveDesign);
    
    // Import/Export
    bind(f('exportAllBtn'), 'click', function() {
      downloadJSON(JSON.stringify(appData, null, 2), 'coptic-data-backup.json');
    });
    bind(f('importBtn'), 'click', function() { f('importFile').click(); });
    bind(f('importFile'), 'change', function(e) {
      if (e.target.files.length > 0) {
        var reader = new FileReader();
        reader.onload = function(ev) { importJSON(ev.target.result); };
        reader.readAsText(e.target.files[0]);
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
    bind(f('loadSampleTraneem'), 'click', function() {
      saveToFirebase('traneem', 'trisagion_ar', { id: 'trisagion', title: 'Trisagion', arabicTitle: 'القداس المقدس', category: 'Liturgical', categoryAr: 'طقسية', stanzas: [{ title: 'التقديس', lines: ['قدوس الله قدوس القوي', 'ارحمنا يا رب'] }, { title: 'المجد', lines: ['المجد للآب والابن والروح القدس'] }], lang: 'ar', updatedAt: new Date().toISOString() });
      saveToFirebase('traneem', 'trisagion_en', { id: 'trisagion', title: 'Holy God', category: 'Liturgical', stanzas: [{ title: 'The Sanctus', lines: ['Holy God, Holy Mighty, Holy Immortal', 'Have mercy on us'] }, { title: 'Glory', lines: ['Glory be to the Father, Son, and Holy Spirit'] }], lang: 'en', updatedAt: new Date().toISOString() });
      showToast('Sample loaded');
    });
    bind(f('loadSampleBible'), 'click', function() {
      saveToFirebase('bible', 'genesis_ar', { bookId: 'genesis', bookName: 'التكوين', chapters: [{ chapterNumber: 1, verses: [{ number: 1, text: 'في البدء خلق الله السموات والأرض' }, { number: 2, text: 'وكانت الأرض خربة وخالية' }] }], lang: 'ar', updatedAt: new Date().toISOString() });
      saveToFirebase('bible', 'genesis_en', { bookId: 'genesis', bookName: 'Genesis', chapters: [{ chapterNumber: 1, verses: [{ number: 1, text: 'In the beginning God created the heavens and the earth.' }, { number: 2, text: 'Now the earth was formless and empty.' }] }], lang: 'en', updatedAt: new Date().toISOString() });
      showToast('Sample loaded');
    });
    bind(f('loadSampleAgpeya'), 'click', function() {
      saveToFirebase('agpeya', 'prime_ar', { id: 'prime', name: 'باكر', englishName: 'Morning Prayer', opening: { title: 'مقدمة كل ساعة', content: ['باسم الآب والابن والروح القدس', 'يا رب ارحم'], inline: true }, lang: 'ar', updatedAt: new Date().toISOString() });
      saveToFirebase('agpeya', 'prime_en', { id: 'prime', name: 'Morning', englishName: 'Morning Prayer', opening: { title: 'Introduction', content: ['In the name of the Father, Son, and Holy Spirit', 'Lord have mercy'], inline: true }, lang: 'en', updatedAt: new Date().toISOString() });
      showToast('Sample loaded');
    });
    bind(f('loadSampleLiturgy'), 'click', function() {
      saveToFirebase('liturgy', 'anaphora_ar', { id: 'anaphora', name: 'الأنافورا', sections: [{ title: 'الأنافورا', content: ['يا رب ارحمنا', 'يا رب اغفر لنا'] }], lang: 'ar', updatedAt: new Date().toISOString() });
      saveToFirebase('liturgy', 'anaphora_en', { id: 'anaphora', name: 'The Anaphora', sections: [{ title: 'The Anaphora', content: ['O Lord have mercy', 'O Lord forgive us'] }], lang: 'en', updatedAt: new Date().toISOString() });
      showToast('Sample loaded');
    });
    
    // Logo upload
    bind(f('logo-upload'), 'change', function(e) {
      var file = e.target.files[0]; if (!file) return;
      var reader = new FileReader();
      reader.onload = function(ev) {
        appData.design.logoUrl = ev.target.result;
        f('logo-url').value = ev.target.result;
        var prev = f('logo-preview');
        if (prev) prev.innerHTML = '<img src="' + ev.target.result + '" alt="Logo">';
        saveDesign();
      };
      reader.readAsDataURL(file);
    });
    bind(f('bg-light-upload'), 'change', function(e) {
      var file = e.target.files[0]; if (!file) return;
      var reader = new FileReader();
      reader.onload = function(ev) {
        appData.design.bgLightUrl = ev.target.result;
        f('bg-light-url').value = ev.target.result;
        saveDesign();
      };
      reader.readAsDataURL(file);
    });
    bind(f('icon-upload'), 'change', function(e) {
      var file = e.target.files[0]; if (!file) return;
      var reader = new FileReader();
      reader.onload = function(ev) {
        appData.design.iconUrl = ev.target.result;
        f('icon-url').value = ev.target.result;
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
    
    // Online/offline detection
    window.addEventListener('online', updateConnectionStatus);
    window.addEventListener('offline', updateConnectionStatus);
    
    // Setup Firebase listeners (real-time sync)
    setupFirebaseListeners();
    
    // Apply translations
    applyTranslations();
  });
  
  function importJSON(jsonStr) {
    try {
      var data = JSON.parse(jsonStr);
      if (data.traneem) {
        data.traneem.ar.forEach(function(item) { saveToFirebase('traneem', (item.id || 'item') + '_ar', item); });
        data.traneem.en.forEach(function(item) { saveToFirebase('traneem', (item.id || 'item') + '_en', item); });
      }
      if (data.bible) {
        data.bible.ar.forEach(function(item) { saveToFirebase('bible', (item.bookId || 'book') + '_ar', item); });
        data.bible.en.forEach(function(item) { saveToFirebase('bible', (item.bookId || 'book') + '_en', item); });
      }
      if (data.agpeya) {
        data.agpeya.ar.forEach(function(item) { saveToFirebase('agpeya', (item.id || 'prayer') + '_ar', item); });
        data.agpeya.en.forEach(function(item) { saveToFirebase('agpeya', (item.id || 'prayer') + '_en', item); });
      }
      if (data.liturgy) {
        data.liturgy.ar.forEach(function(item) { saveToFirebase('liturgy', (item.id || item.name || 'liturgy') + '_ar', item); });
        data.liturgy.en.forEach(function(item) { saveToFirebase('liturgy', (item.id || item.name || 'liturgy') + '_en', item); });
      }
      if (data.readings) {
        data.readings.forEach(function(item) { saveToFirebase('readings', item.id || item.type || 'reading', item); });
      }
      if (data.design) {
        saveToFirebase('settings', 'design', data.design);
      }
      showToast(t('imported'));
    } catch(e) { showToast(t('invalidJson')); }
  }
  
  function downloadJSON(data, filename) {
    var blob = new Blob([data], { type: 'application/json' });
    var url = URL.createObjectURL(blob);
    var a = document.createElement('a'); a.href = url; a.download = filename; a.click();
    URL.revokeObjectURL(url);
  }
})();
