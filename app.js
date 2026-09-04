// Coptic Companion Admin - Main Application JavaScript
(function() {
  'use strict';

  const STORAGE_KEYS = {
    traneem: 'cc_traneem',
    bible: 'cc_bible',
    agpeya: 'cc_agpeya',
    liturgy: 'cc_liturgy',
    readings: 'cc_readings',
    lexicon: 'cc_lexicon',
    design: 'cc_design',
    settings: 'cc_settings',
    activity: 'cc_activity'
  };

  const DEFAULTS = {
    traneem: [
      { id: 'trisagion', category: 'hymn', titleEn: 'Trisagion (Holy God)', titleAr: 'قدوس الله', lyricsEn: ['Holy God, Holy Mighty, Holy Immortal', 'Have mercy on us.'], lyricsAr: ['قدوس الله، قدوس القوي، قدوس الذي لا يموت', 'ارحمنا'], coptic: 'Ⲁⲅⲓⲟⲥ ⲟ Ⲑⲉⲟⲥ', notes: 'Opening hymn' },
      { id: 'kurielaison', category: 'response', titleEn: 'Lord Have Mercy', titleAr: 'كيرياليسون', lyricsEn: ['Lord, have mercy.'], lyricsAr: ['يارب ارحم.'], coptic: 'Ⲕⲩⲣⲓⲉ ⲉⲗⲉⲓⲥⲟⲛ', notes: '' }
    ],
    bible: [
      { id: 'genesis', order: 1, nameEn: 'Genesis', nameAr: 'التكوين', chapters: 50, testament: 'old', content: {} },
      { id: 'matthew', order: 40, nameEn: 'Matthew', nameAr: 'متى', chapters: 28, testament: 'new', content: {} }
    ],
    agpeya: [
      { id: 'prime', hour: 1, nameEn: 'First Hour (Prime)', nameAr: 'الساعة الأولى', sections: [] },
      { id: 'terce', hour: 3, nameEn: 'Third Hour', nameAr: 'الساعة الثالثة', sections: [] },
      { id: 'sexte', hour: 6, nameEn: 'Sixth Hour', nameAr: 'الساعة السادسة', sections: [] },
      { id: 'none', hour: 9, nameEn: 'Ninth Hour', nameAr: 'الساعة التاسعة', sections: [] },
      { id: 'vespers', hour: 12, nameEn: 'Vespers', nameAr: 'عشية', sections: [] },
      { id: 'compline', hour: 15, nameEn: 'Compline', nameAr: 'النوم', sections: [] },
      { id: 'midnight', hour: 0, nameEn: 'Midnight Prayer', nameAr: 'صلاة نصف الليل', sections: [] }
    ],
    liturgy: [
      { id: 'anaphora', order: 1, nameEn: 'The Anaphora', nameAr: 'الأنافورا', sections: [] },
      { id: 'fraction', order: 2, nameEn: 'The Fraction', nameAr: 'التجزئة', sections: [] }
    ],
    readings: [
      { id: 'morning-gospel', type: 'gospel', nameEn: 'Morning Gospel', nameAr: 'إنجيل باكر', date: '', content: {} },
      { id: 'pauline', type: 'pauline', nameEn: 'Pauline Epistle', nameAr: 'رسالة بولس', date: '', content: {} }
    ],
    lexicon: [
      { id: '1', coptic: 'ⲛⲟⲩϯ', arabic: 'الله', english: 'God', type: 'word' },
      { id: '2', coptic: 'Ⲡⲭⲥ', arabic: 'المسيح', english: 'Christ', type: 'word' },
      { id: '3', coptic: 'ⲉⲓⲣⲏⲛⲏ', arabic: 'سلام', english: 'Peace', type: 'word' },
      { id: '4', coptic: 'ⲁⲅⲁⲡⲏ', arabic: 'محبة', english: 'Love', type: 'word' },
      { id: '5', coptic: 'ⲛⲁⲓ ⲛⲁⲕ', arabic: 'ارحمني', english: 'Have mercy on me', type: 'phrase' }
    ],
    design: {
      nameEn: 'Coptic Companion', nameAr: 'الرفيق القبطي',
      descEn: 'A comprehensive Coptic Orthodox companion app', descAr: 'تطبيق قبطي أرثوذكسي شامل',
      version: '1.0.0',
      colors: { primary: '#8B4513', secondary: '#D4AF37', bgLight: '#FFFBF0', bgDark: '#1A1A2E', textLight: '#2C1810', textDark: '#F5F5DC' },
      font: { primary: 'Roboto', size: 16 }, logoUrl: ''
    },
    settings: { repo: 'Meko277/soma', branch: 'main', token: '' },
    activity: []
  };

  function loadData(key) {
    try {
      const raw = localStorage.getItem(STORAGE_KEYS[key]);
      if (raw) return JSON.parse(raw);
    } catch (e) { console.warn('Failed to load', key, e); }
    return DEFAULTS[key] || null;
  }

  function saveData(key, data) {
    try {
      localStorage.setItem(STORAGE_KEYS[key], JSON.stringify(data));
      addActivity('Updated ' + key);
      updateStats();
      return true;
    } catch (e) {
      showToast('Failed to save: ' + e.message);
      return false;
    }
  }

  function addActivity(message) {
    const log = loadData('activity') || [];
    log.unshift({ message, time: new Date().toLocaleString() });
    if (log.length > 50) log.length = 50;
    localStorage.setItem(STORAGE_KEYS.activity, JSON.stringify(log));
    renderActivityLog();
  }

  function showSection(sectionId) {
    document.querySelectorAll('.content-section').forEach(function(s) { s.classList.remove('active'); });
    document.querySelectorAll('.nav-item').forEach(function(n) { n.classList.remove('active'); });
    var section = document.getElementById(sectionId);
    if (section) section.classList.add('active');
    var navBtn = document.querySelector('.nav-item[data-section="' + sectionId + '"]');
    if (navBtn) navBtn.classList.add('active');
  }

  window.closeModal = function(id) {
    var modal = document.getElementById(id);
    if (modal) modal.style.display = 'none';
  };

  window.showSection = showSection;

  function showToast(message) {
    var toast = document.getElementById('toast');
    var msg = document.getElementById('toast-message');
    if (toast && msg) {
      msg.textContent = message;
      toast.style.display = 'block';
      setTimeout(function() { toast.style.display = 'none'; }, 3000);
    }
  }

  function updateStats() {
    var traneem = loadData('traneem') || [];
    var bible = loadData('bible') || [];
    var agpeya = loadData('agpeya') || [];
    var liturgy = loadData('liturgy') || [];
    var lexicon = loadData('lexicon') || [];
    var readings = loadData('readings') || [];
    var el = function(id) { return document.getElementById(id); };
    if (el('stat-traneem')) el('stat-traneem').textContent = traneem.length;
    if (el('stat-bible')) el('stat-bible').textContent = bible.length;
    if (el('stat-agpeya')) el('stat-agpeya').textContent = agpeya.length;
    if (el('stat-liturgy')) el('stat-liturgy').textContent = liturgy.length;
    if (el('stat-lexicon')) el('stat-lexicon').textContent = lexicon.length;
    if (el('stat-readings')) el('stat-readings').textContent = readings.length;
    var totalSize = 0;
    Object.values(STORAGE_KEYS).forEach(function(k) {
      var v = localStorage.getItem(k);
      if (v) totalSize += v.length;
    });
    if (el('data-size')) el('data-size').textContent = (totalSize / 1024).toFixed(1) + ' KB';
    if (el('last-updated')) el('last-updated').textContent = new Date().toLocaleString();
  }

  function renderActivityLog() {
    var log = loadData('activity') || [];
    var container = document.getElementById('activity-log');
    if (!container) return;
    if (log.length === 0) {
      container.innerHTML = '<p class="empty-state">No recent activity</p>';
      return;
    }
    container.innerHTML = log.slice(0, 10).map(function(a) {
      return '<div class="activity-item"><span>' + a.message + '</span><br><span class="activity-time">' + a.time + '</span></div>';
    }).join('');
  }

  function renderTraneemList() {
    var data = loadData('traneem') || [];
    var container = document.getElementById('traneem-list');
    if (!container) return;
    var search = (document.getElementById('traneemSearch') || {}).value || '';
    search = search.toLowerCase();
    var filtered = data.filter(function(h) {
      return (h.titleEn || '').toLowerCase().indexOf(search) !== -1 ||
             (h.titleAr || '').indexOf(search) !== -1 ||
             (h.id || '').toLowerCase().indexOf(search) !== -1;
    });
    if (filtered.length === 0) { container.innerHTML = '<p class="empty-state">No hymns found</p>'; return; }
    container.innerHTML = filtered.map(function(h) {
      return '<div class="item-row" onclick="editHymn(\'' + h.id + '\')"><div><span class="item-title">' + (h.titleEn || h.id) + '</span><br><span class="item-meta">' + (h.titleAr || '') + ' &bull; ' + (h.category || 'hymn') + '</span></div><span>&#9998;&#65039;</span></div>';
    }).join('');
  }

  function renderBibleList() {
    var data = loadData('bible') || [];
    var container = document.getElementById('bible-list');
    if (!container) return;
    var search = (document.getElementById('bibleSearch') || {}).value || '';
    search = search.toLowerCase();
    var filtered = data.filter(function(b) {
      return (b.nameEn || '').toLowerCase().indexOf(search) !== -1 ||
             (b.nameAr || '').indexOf(search) !== -1 ||
             (b.id || '').toLowerCase().indexOf(search) !== -1;
    });
    if (filtered.length === 0) { container.innerHTML = '<p class="empty-state">No books found</p>'; return; }
    container.innerHTML = filtered.map(function(b) {
      return '<div class="item-row" onclick="editBibleBook(\'' + b.id + '\')"><div><span class="item-title">' + (b.nameEn || b.id) + '</span><br><span class="item-meta">' + (b.nameAr || '') + ' &bull; ' + b.chapters + ' ch &bull; ' + b.testament + '</span></div><span>&#9998;&#65039;</span></div>';
    }).join('');
  }

  function renderAgpeyaList() {
    var data = loadData('agpeya') || [];
    var container = document.getElementById('agpeya-list');
    if (!container) return;
    if (data.length === 0) { container.innerHTML = '<p class="empty-state">No prayers found</p>'; return; }
    container.innerHTML = data.map(function(p) {
      return '<div class="item-row" onclick="editAgpeya(\'' + p.id + '\')"><div><span class="item-title">' + (p.nameEn || p.id) + '</span><br><span class="item-meta">' + (p.nameAr || '') + ' &bull; Hour ' + p.hour + '</span></div><span>&#9998;&#65039;</span></div>';
    }).join('');
  }

  function renderLiturgyList() {
    var data = loadData('liturgy') || [];
    var container = document.getElementById('liturgy-list');
    if (!container) return;
    if (data.length === 0) { container.innerHTML = '<p class="empty-state">No liturgy parts found</p>'; return; }
    container.innerHTML = data.map(function(l) {
      return '<div class="item-row" onclick="editLiturgy(\'' + l.id + '\')"><div><span class="item-title">' + (l.nameEn || l.id) + '</span><br><span class="item-meta">' + (l.nameAr || '') + ' &bull; Order ' + l.order + '</span></div><span>&#9998;&#65039;</span></div>';
    }).join('');
  }

  function renderReadingsList() {
    var data = loadData('readings') || [];
    var container = document.getElementById('readings-list');
    if (!container) return;
    if (data.length === 0) { container.innerHTML = '<p class="empty-state">No readings found</p>'; return; }
    container.innerHTML = data.map(function(r) {
      return '<div class="item-row" onclick="editReading(\'' + r.id + '\')"><div><span class="item-title">' + (r.nameEn || r.id) + '</span><br><span class="item-meta">' + (r.nameAr || '') + ' &bull; ' + r.type + '</span></div><span>&#9998;&#65039;</span></div>';
    }).join('');
  }

  function renderLexiconList() {
    var data = loadData('lexicon') || [];
    var container = document.getElementById('lexicon-list');
    if (!container) return;
    var search = (document.getElementById('lexiconSearch') || {}).value || '';
    search = search.toLowerCase();
    var filtered = data.filter(function(e) {
      return (e.coptic || '').toLowerCase().indexOf(search) !== -1 ||
             (e.arabic || '').indexOf(search) !== -1 ||
             (e.english || '').toLowerCase().indexOf(search) !== -1;
    });
    if (filtered.length === 0) { container.innerHTML = '<p class="empty-state">No entries found</p>'; return; }
    container.innerHTML = filtered.map(function(e) {
      return '<div class="item-row" onclick="editLexicon(\'' + e.id + '\')"><div><span class="item-title">' + e.coptic + '</span><br><span class="item-meta">' + e.arabic + ' &bull; ' + e.english + ' &bull; ' + e.type + '</span></div><span>&#9998;&#65039;</span></div>';
    }).join('');
  }

  window.editHymn = function(id) {
    var data = loadData('traneem') || [];
    var hymn = data.find(function(h) { return h.id === id; });
    if (!hymn) return;
    document.getElementById('hymn-id').value = hymn.id;
    document.getElementById('hymn-category').value = hymn.category || 'hymn';
    document.getElementById('hymn-title-en').value = hymn.titleEn || '';
    document.getElementById('hymn-title-ar').value = hymn.titleAr || '';
    document.getElementById('hymn-lyrics-en').value = (hymn.lyricsEn || []).join('\n');
    document.getElementById('hymn-lyrics-ar').value = (hymn.lyricsAr || []).join('\n');
    document.getElementById('hymn-coptic').value = hymn.coptic || '';
    document.getElementById('hymn-notes').value = hymn.notes || '';
    document.getElementById('hymn-editor-title').textContent = 'Edit: ' + (hymn.titleEn || hymn.id);
    document.getElementById('deleteHymnBtn').style.display = 'inline-flex';
    openModal('hymn-editor');
  };

  window.newHymn = function() {
    document.getElementById('hymn-id').value = '';
    document.getElementById('hymn-category').value = 'hymn';
    document.getElementById('hymn-title-en').value = '';
    document.getElementById('hymn-title-ar').value = '';
    document.getElementById('hymn-lyrics-en').value = '';
    document.getElementById('hymn-lyrics-ar').value = '';
    document.getElementById('hymn-coptic').value = '';
    document.getElementById('hymn-notes').value = '';
    document.getElementById('hymn-editor-title').textContent = 'New Hymn';
    document.getElementById('deleteHymnBtn').style.display = 'none';
    openModal('hymn-editor');
  };

  function saveHymn() {
    var id = document.getElementById('hymn-id').value.trim();
    if (!id) { showToast('Hymn ID is required'); return; }
    var data = loadData('traneem') || [];
    var idx = data.findIndex(function(h) { return h.id === id; });
    var hymn = {
      id: id,
      category: document.getElementById('hymn-category').value,
      titleEn: document.getElementById('hymn-title-en').value,
      titleAr: document.getElementById('hymn-title-ar').value,
      lyricsEn: document.getElementById('hymn-lyrics-en').value.split('\n'),
      lyricsAr: document.getElementById('hymn-lyrics-ar').value.split('\n'),
      coptic: document.getElementById('hymn-coptic').value,
      notes: document.getElementById('hymn-notes').value
    };
    if (idx >= 0) { data[idx] = hymn; } else { data.push(hymn); }
    saveData('traneem', data);
    closeModal('hymn-editor');
    renderTraneemList();
    showToast('Hymn saved');
  }

  function deleteHymn() {
    var id = document.getElementById('hymn-id').value.trim();
    if (!id) return;
    var data = loadData('traneem') || [];
    data = data.filter(function(h) { return h.id !== id; });
    saveData('traneem', data);
    closeModal('hymn-editor');
    renderTraneemList();
    showToast('Hymn deleted');
  }

  // ============================================================
  // BIBLE EDITOR
  // ============================================================

  window.editBibleBook = function(id) {
    var data = loadData('bible') || [];
    var book = data.find(function(b) { return b.id === id; });
    if (!book) return;
    document.getElementById('bible-book-id').value = book.id;
    document.getElementById('bible-book-order').value = book.order || 1;
    document.getElementById('bible-name-en').value = book.nameEn || '';
    document.getElementById('bible-name-ar').value = book.nameAr || '';
    document.getElementById('bible-chapters').value = book.chapters || 1;
    document.getElementById('bible-testament').value = book.testament || 'old';
    document.getElementById('bible-content').value = JSON.stringify(book.content || {}, null, 2);
    document.getElementById('bible-editor-title').textContent = 'Edit: ' + (book.nameEn || book.id);
    document.getElementById('deleteBibleBtn').style.display = 'inline-flex';
    openModal('bible-editor');
  };

  window.newBibleBook = function() {
    document.getElementById('bible-book-id').value = '';
    document.getElementById('bible-book-order').value = '1';
    document.getElementById('bible-name-en').value = '';
    document.getElementById('bible-name-ar').value = '';
    document.getElementById('bible-chapters').value = '1';
    document.getElementById('bible-testament').value = 'old';
    document.getElementById('bible-content').value = '{}';
    document.getElementById('bible-editor-title').textContent = 'New Bible Book';
    document.getElementById('deleteBibleBtn').style.display = 'none';
    openModal('bible-editor');
  };

  function saveBibleBook() {
    var id = document.getElementById('bible-book-id').value.trim();
    if (!id) { showToast('Book ID is required'); return; }
    var contentStr = document.getElementById('bible-content').value;
    var content = {};
    try { content = JSON.parse(contentStr); } catch(e) { showToast('Invalid JSON in content'); return; }
    var data = loadData('bible') || [];
    var idx = data.findIndex(function(b) { return b.id === id; });
    var book = {
      id: id,
      order: parseInt(document.getElementById('bible-book-order').value) || 1,
      nameEn: document.getElementById('bible-name-en').value,
      nameAr: document.getElementById('bible-name-ar').value,
      chapters: parseInt(document.getElementById('bible-chapters').value) || 1,
      testament: document.getElementById('bible-testament').value,
      content: content
    };
    if (idx >= 0) { data[idx] = book; } else { data.push(book); }
    saveData('bible', data);
    closeModal('bible-editor');
    renderBibleList();
    showToast('Bible book saved');
  }

  function deleteBibleBook() {
    var id = document.getElementById('bible-book-id').value.trim();
    if (!id) return;
    var data = loadData('bible') || [];
    data = data.filter(function(b) { return b.id !== id; });
    saveData('bible', data);
    closeModal('bible-editor');
    renderBibleList();
    showToast('Book deleted');
  }

  // ============================================================
  // AGPEYA EDITOR
  // ============================================================

  window.editAgpeya = function(id) {
    var data = loadData('agpeya') || [];
    var prayer = data.find(function(p) { return p.id === id; });
    if (!prayer) return;
    document.getElementById('agpeya-id').value = prayer.id;
    document.getElementById('agpeya-hour').value = prayer.hour || 1;
    document.getElementById('agpeya-name-en').value = prayer.nameEn || '';
    document.getElementById('agpeya-name-ar').value = prayer.nameAr || '';
    document.getElementById('agpeya-content').value = JSON.stringify(prayer.sections || [], null, 2);
    document.getElementById('agpeya-editor-title').textContent = 'Edit: ' + (prayer.nameEn || prayer.id);
    document.getElementById('deleteAgpeyaBtn').style.display = 'inline-flex';
    openModal('agpeya-editor');
  };

  window.newAgpeya = function() {
    document.getElementById('agpeya-id').value = '';
    document.getElementById('agpeya-hour').value = '1';
    document.getElementById('agpeya-name-en').value = '';
    document.getElementById('agpeya-name-ar').value = '';
    document.getElementById('agpeya-content').value = '[]';
    document.getElementById('agpeya-editor-title').textContent = 'New Prayer';
    document.getElementById('deleteAgpeyaBtn').style.display = 'none';
    openModal('agpeya-editor');
  };

  function saveAgpeya() {
    var id = document.getElementById('agpeya-id').value.trim();
    if (!id) { showToast('Prayer ID is required'); return; }
    var contentStr = document.getElementById('agpeya-content').value;
    var sections = [];
    try { sections = JSON.parse(contentStr); } catch(e) { showToast('Invalid JSON'); return; }
    var data = loadData('agpeya') || [];
    var idx = data.findIndex(function(p) { return p.id === id; });
    var prayer = {
      id: id,
      hour: parseInt(document.getElementById('agpeya-hour').value) || 1,
      nameEn: document.getElementById('agpeya-name-en').value,
      nameAr: document.getElementById('agpeya-name-ar').value,
      sections: sections
    };
    if (idx >= 0) { data[idx] = prayer; } else { data.push(prayer); }
    saveData('agpeya', data);
    closeModal('agpeya-editor');
    renderAgpeyaList();
    showToast('Prayer saved');
  }

  function deleteAgpeya() {
    var id = document.getElementById('agpeya-id').value.trim();
    if (!id) return;
    var data = loadData('agpeya') || [];
    data = data.filter(function(p) { return p.id !== id; });
    saveData('agpeya', data);
    closeModal('agpeya-editor');
    renderAgpeyaList();
    showToast('Prayer deleted');
  }

  // ============================================================
  // LITURGY EDITOR
  // ============================================================

  window.editLiturgy = function(id) {
    var data = loadData('liturgy') || [];
    var part = data.find(function(l) { return l.id === id; });
    if (!part) return;
    document.getElementById('liturgy-id').value = part.id;
    document.getElementById('liturgy-order').value = part.order || 1;
    document.getElementById('liturgy-name-en').value = part.nameEn || '';
    document.getElementById('liturgy-name-ar').value = part.nameAr || '';
    document.getElementById('liturgy-content').value = JSON.stringify(part.sections || [], null, 2);
    document.getElementById('liturgy-editor-title').textContent = 'Edit: ' + (part.nameEn || part.id);
    document.getElementById('deleteLiturgyBtn').style.display = 'inline-flex';
    openModal('liturgy-editor');
  };

  window.newLiturgy = function() {
    document.getElementById('liturgy-id').value = '';
    document.getElementById('liturgy-order').value = '1';
    document.getElementById('liturgy-name-en').value = '';
    document.getElementById('liturgy-name-ar').value = '';
    document.getElementById('liturgy-content').value = '[]';
    document.getElementById('liturgy-editor-title').textContent = 'New Liturgy Part';
    document.getElementById('deleteLiturgyBtn').style.display = 'none';
    openModal('liturgy-editor');
  };

  function saveLiturgy() {
    var id = document.getElementById('liturgy-id').value.trim();
    if (!id) { showToast('Part ID is required'); return; }
    var contentStr = document.getElementById('liturgy-content').value;
    var sections = [];
    try { sections = JSON.parse(contentStr); } catch(e) { showToast('Invalid JSON'); return; }
    var data = loadData('liturgy') || [];
    var idx = data.findIndex(function(l) { return l.id === id; });
    var part = {
      id: id,
      order: parseInt(document.getElementById('liturgy-order').value) || 1,
      nameEn: document.getElementById('liturgy-name-en').value,
      nameAr: document.getElementById('liturgy-name-ar').value,
      sections: sections
    };
    if (idx >= 0) { data[idx] = part; } else { data.push(part); }
    saveData('liturgy', data);
    closeModal('liturgy-editor');
    renderLiturgyList();
    showToast('Liturgy part saved');
  }

  function deleteLiturgy() {
    var id = document.getElementById('liturgy-id').value.trim();
    if (!id) return;
    var data = loadData('liturgy') || [];
    data = data.filter(function(l) { return l.id !== id; });
    saveData('liturgy', data);
    closeModal('liturgy-editor');
    renderLiturgyList();
    showToast('Part deleted');
  }

  // ============================================================
  // READINGS EDITOR
  // ============================================================

  window.editReading = function(id) {
    var data = loadData('readings') || [];
    var reading = data.find(function(r) { return r.id === id; });
    if (!reading) return;
    document.getElementById('reading-id').value = reading.id;
    document.getElementById('reading-type').value = reading.type || 'gospel';
    document.getElementById('reading-name-en').value = reading.nameEn || '';
    document.getElementById('reading-name-ar').value = reading.nameAr || '';
    document.getElementById('reading-date').value = reading.date || '';
    document.getElementById('reading-content').value = JSON.stringify(reading.content || {}, null, 2);
    document.getElementById('reading-editor-title').textContent = 'Edit: ' + (reading.nameEn || reading.id);
    document.getElementById('deleteReadingBtn').style.display = 'inline-flex';
    openModal('reading-editor');
  };

  window.newReading = function() {
    document.getElementById('reading-id').value = '';
    document.getElementById('reading-type').value = 'gospel';
    document.getElementById('reading-name-en').value = '';
    document.getElementById('reading-name-ar').value = '';
    document.getElementById('reading-date').value = '';
    document.getElementById('reading-content').value = '{}';
    document.getElementById('reading-editor-title').textContent = 'New Reading';
    document.getElementById('deleteReadingBtn').style.display = 'none';
    openModal('reading-editor');
  };

  function saveReading() {
    var id = document.getElementById('reading-id').value.trim();
    if (!id) { showToast('Reading ID is required'); return; }
    var contentStr = document.getElementById('reading-content').value;
    var content = {};
    try { content = JSON.parse(contentStr); } catch(e) { showToast('Invalid JSON'); return; }
    var data = loadData('readings') || [];
    var idx = data.findIndex(function(r) { return r.id === id; });
    var reading = {
      id: id,
      type: document.getElementById('reading-type').value,
      nameEn: document.getElementById('reading-name-en').value,
      nameAr: document.getElementById('reading-name-ar').value,
      date: document.getElementById('reading-date').value,
      content: content
    };
    if (idx >= 0) { data[idx] = reading; } else { data.push(reading); }
    saveData('readings', data);
    closeModal('reading-editor');
    renderReadingsList();
    showToast('Reading saved');
  }

  function deleteReading() {
    var id = document.getElementById('reading-id').value.trim();
    if (!id) return;
    var data = loadData('readings') || [];
    data = data.filter(function(r) { return r.id !== id; });
    saveData('readings', data);
    closeModal('reading-editor');
    renderReadingsList();
    showToast('Reading deleted');
  }

  // ============================================================
  // LEXICON EDITOR
  // ============================================================

  window.editLexicon = function(id) {
    var data = loadData('lexicon') || [];
    var entry = data.find(function(e) { return e.id === id; });
    if (!entry) return;
    document.getElementById('lexicon-coptic').value = entry.coptic || '';
    document.getElementById('lexicon-arabic').value = entry.arabic || '';
    document.getElementById('lexicon-english').value = entry.english || '';
    document.getElementById('lexicon-type').value = entry.type || 'word';
    document.getElementById('lexicon-editor-title').textContent = 'Edit: ' + (entry.coptic || id);
    document.getElementById('deleteLexiconBtn').style.display = 'inline-flex';
    document.getElementById('deleteLexiconBtn').dataset.id = id;
    openModal('lexicon-editor');
  };

  window.newLexicon = function() {
    document.getElementById('lexicon-coptic').value = '';
    document.getElementById('lexicon-arabic').value = '';
    document.getElementById('lexicon-english').value = '';
    document.getElementById('lexicon-type').value = 'word';
    document.getElementById('lexicon-editor-title').textContent = 'New Lexicon Entry';
    document.getElementById('deleteLexiconBtn').style.display = 'none';
    openModal('lexicon-editor');
  };

  function saveLexicon() {
    var coptic = document.getElementById('lexicon-coptic').value.trim();
    if (!coptic) { showToast('Coptic word is required'); return; }
    var data = loadData('lexicon') || [];
    var id = document.getElementById('deleteLexiconBtn').dataset.id || Date.now().toString();
    var idx = data.findIndex(function(e) { return e.id === id; });
    var entry = {
      id: id,
      coptic: coptic,
      arabic: document.getElementById('lexicon-arabic').value,
      english: document.getElementById('lexicon-english').value,
      type: document.getElementById('lexicon-type').value
    };
    if (idx >= 0) { data[idx] = entry; } else { data.push(entry); }
    saveData('lexicon', data);
    closeModal('lexicon-editor');
    renderLexiconList();
    showToast('Lexicon entry saved');
  }

  function deleteLexicon() {
    var id = document.getElementById('deleteLexiconBtn').dataset.id;
    if (!id) return;
    var data = loadData('lexicon') || [];
    data = data.filter(function(e) { return e.id !== id; });
    saveData('lexicon', data);
    closeModal('lexicon-editor');
    renderLexiconList();
    showToast('Entry deleted');
  }

  // ============================================================
  // DESIGN FORM
  // ============================================================

  function renderDesignForm() {
    var d = loadData('design') || DEFAULTS.design;
    var el = function(id) { return document.getElementById(id); };
    if (el('app-name-en')) el('app-name-en').value = d.nameEn || '';
    if (el('app-name-ar')) el('app-name-ar').value = d.nameAr || '';
    if (el('app-desc-en')) el('app-desc-en').value = d.descEn || '';
    if (el('app-desc-ar')) el('app-desc-ar').value = d.descAr || '';
    if (el('app-version')) el('app-version').value = d.version || '';
    if (el('color-primary')) el('color-primary').value = (d.colors || {}).primary || '#8B4513';
    if (el('color-secondary')) el('color-secondary').value = (d.colors || {}).secondary || '#D4AF37';
    if (el('color-bg-light')) el('color-bg-light').value = (d.colors || {}).bgLight || '#FFFBF0';
    if (el('color-bg-dark')) el('color-bg-dark').value = (d.colors || {}).bgDark || '#1A1A2E';
    if (el('color-text-light')) el('color-text-light').value = (d.colors || {}).textLight || '#2C1810';
    if (el('color-text-dark')) el('color-text-dark').value = (d.colors || {}).textDark || '#F5F5DC';
    if (el('font-primary')) el('font-primary').value = (d.font || {}).primary || 'Roboto';
    if (el('font-size-base')) el('font-size-base').value = (d.font || {}).size || 16;
    if (el('app-logo-url')) el('app-logo-url').value = d.logoUrl || '';
    var preview = el('logo-preview');
    if (preview && d.logoUrl) {
      preview.innerHTML = '<img src="' + d.logoUrl + '" alt="Logo">';
    }
  }

  function saveDesign() {
    var el = function(id) { return document.getElementById(id); };
    var design = {
      nameEn: el('app-name-en').value,
      nameAr: el('app-name-ar').value,
      descEn: el('app-desc-en').value,
      descAr: el('app-desc-ar').value,
      version: el('app-version').value,
      colors: {
        primary: el('color-primary').value,
        secondary: el('color-secondary').value,
        bgLight: el('color-bg-light').value,
        bgDark: el('color-bg-dark').value,
        textLight: el('color-text-light').value,
        textDark: el('color-text-dark').value
      },
      font: {
        primary: el('font-primary').value,
        size: parseInt(el('font-size-base').value) || 16
      },
      logoUrl: el('app-logo-url').value
    };
    saveData('design', design);
    showToast('Design settings saved');
  }

  // ============================================================
  // IMPORT / EXPORT
  // ============================================================

  function exportAllData() {
    var data = {};
    Object.keys(STORAGE_KEYS).forEach(function(key) {
      data[key] = loadData(key);
    });
    var blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' });
    var url = URL.createObjectURL(blob);
    var a = document.createElement('a');
    a.href = url;
    a.download = 'coptic-companion-data-' + new Date().toISOString().slice(0,10) + '.json';
    a.click();
    URL.revokeObjectURL(url);
    showToast('Data exported');
  }

  function importAllData(file) {
    var reader = new FileReader();
    reader.onload = function(e) {
      try {
        var data = JSON.parse(e.target.result);
        Object.keys(STORAGE_KEYS).forEach(function(key) {
          if (data[key] !== undefined) {
            localStorage.setItem(STORAGE_KEYS[key], JSON.stringify(data[key]));
          }
        });
        addActivity('Imported all data');
        refreshAll();
        showToast('Data imported successfully');
      } catch(err) {
        showToast('Failed to import: ' + err.message);
      }
    };
    reader.readAsText(file);
  }

  function resetAllData() {
    if (!confirm('Are you sure you want to reset ALL data? This cannot be undone.')) return;
    Object.values(STORAGE_KEYS).forEach(function(key) {
      localStorage.removeItem(key);
    });
    addActivity('Reset all data');
    refreshAll();
    showToast('All data reset');
  }

  // ============================================================
  // REFRESH ALL
  // ============================================================

  function refreshAll() {
    updateStats();
    renderActivityLog();
    renderTraneemList();
    renderBibleList();
    renderAgpeyaList();
    renderLiturgyList();
    renderReadingsList();
    renderLexiconList();
    renderDesignForm();
  }

  document.addEventListener('DOMContentLoaded', function() {
    document.querySelectorAll('.nav-item').forEach(function(btn) {
      btn.addEventListener('click', function() { showSection(btn.dataset.section); });
    });
    var f = function(id) { return document.getElementById(id); };
    var bind = function(el, evt, fn) { if (el) el.addEventListener(evt, fn); };
    bind(f('addHymnBtn'), 'click', newHymn);
    bind(f('saveHymnBtn'), 'click', saveHymn);
    bind(f('deleteHymnBtn'), 'click', deleteHymn);
    bind(f('traneemSearch'), 'input', renderTraneemList);
    bind(f('addBibleBookBtn'), 'click', newBibleBook);
    bind(f('saveBibleBtn'), 'click', saveBibleBook);
    bind(f('deleteBibleBtn'), 'click', deleteBibleBook);
    bind(f('bibleSearch'), 'input', renderBibleList);
    bind(f('addAgpeyaBtn'), 'click', newAgpeya);
    bind(f('saveAgpeyaBtn'), 'click', saveAgpeya);
    bind(f('deleteAgpeyaBtn'), 'click', deleteAgpeya);
    bind(f('agpeyaSearch'), 'input', renderAgpeyaList);
    bind(f('addLiturgyBtn'), 'click', newLiturgy);
    bind(f('saveLiturgyBtn'), 'click', saveLiturgy);
    bind(f('deleteLiturgyBtn'), 'click', deleteLiturgy);
    bind(f('liturgySearch'), 'input', renderLiturgyList);
    bind(f('addReadingBtn'), 'click', newReading);
    bind(f('saveReadingBtn'), 'click', saveReading);
    bind(f('deleteReadingBtn'), 'click', deleteReading);
    bind(f('readingsSearch'), 'input', renderReadingsList);
    bind(f('addLexiconBtn'), 'click', newLexicon);
    bind(f('saveLexiconBtn'), 'click', saveLexicon);
    bind(f('deleteLexiconBtn'), 'click', deleteLexicon);
    bind(f('lexiconSearch'), 'input', renderLexiconList);
    bind(f('saveDesignBtn'), 'click', saveDesign);

    // Export/Import
    bind(f('exportBtn'), 'click', exportAllData);
    var importFile = f('importFile');
    if (f('importBtn') && importFile) {
      f('importBtn').addEventListener('click', function() { importFile.click(); });
      importFile.addEventListener('change', function(e) {
        if (e.target.files.length > 0) importAllData(e.target.files[0]);
      });
    }
    bind(f('exportAllBtn'), 'click', exportAllData);
    var importAllFile = f('importAllFile');
    if (f('importAllBtn') && importAllFile) {
      f('importAllBtn').addEventListener('click', function() { importAllFile.click(); });
      importAllFile.addEventListener('change', function(e) {
        if (e.target.files.length > 0) importAllData(e.target.files[0]);
      });
    }
    bind(f('resetAllBtn'), 'click', resetAllData);

    // GitHub sync
    var syncBtn = f('syncGithubBtn');
    if (syncBtn) {
      syncBtn.addEventListener('click', function() {
        var repo = f('github-repo').value;
        var token = f('github-token').value;
        if (!token) { showToast('GitHub token required. Export and push manually.'); return; }
        showToast('Syncing with ' + repo + '...');
      });
    }

    // Logo upload
    var logoUpload = f('app-logo-upload');
    if (logoUpload) {
      logoUpload.addEventListener('change', function(e) {
        var file = e.target.files[0];
        if (!file) return;
        var reader = new FileReader();
        reader.onload = function(ev) {
          var preview = f('logo-preview');
          if (preview) preview.innerHTML = '<img src="' + ev.target.result + '" alt="Logo">';
          if (f('app-logo-url')) f('app-logo-url').value = ev.target.result;
        };
        reader.readAsDataURL(file);
      });
    }

    refreshAll();
  });

})();