import { initializeApp } from 'https://www.gstatic.com/firebasejs/11.5.0/firebase-app.js';
import { getFirestore, collection, doc, setDoc, deleteDoc, onSnapshot } from 'https://www.gstatic.com/firebasejs/11.5.0/firebase-firestore.js';

const firebaseConfig = {
  apiKey: 'AIzaSyBdRoE9E_Th7TDvReGyv9HqaczlU7wuLE0',
  authDomain: 'bible-62ac2.firebaseapp.com',
  projectId: 'bible-62ac2',
  storageBucket: 'bible-62ac2.firebasestorage.app',
  messagingSenderId: '62919950123',
  appId: '1:62919950123:web:d97d54353d0cb02df90f6e',
};

const db = getFirestore(initializeApp(firebaseConfig));
const chaptersCollection = collection(db, 'bibleChapters');
const form = document.querySelector('#chapter-form');
const list = document.querySelector('#chapter-list');
const empty = document.querySelector('#empty');
let chapters = [];

onSnapshot(chaptersCollection, (snapshot) => {
  chapters = snapshot.docs.map((item) => ({id: item.id, ...item.data()}));
  render();
}, (error) => { empty.hidden = false; empty.textContent = `Firebase error: ${error.message}`; });

function render() {
  chapters.sort((a, b) => a.book.localeCompare(b.book) || a.chapter - b.chapter);
  empty.hidden = chapters.length > 0;
  empty.textContent = 'No chapters have been saved.';
  list.innerHTML = chapters.map((chapter) => `<article class="chapter"><div><strong>${escapeHtml(chapter.book)} ${chapter.chapter}</strong><p>${label(chapter.language)} · ${chapter.text.length} characters</p></div><button class="secondary delete" data-id="${chapter.id}">Delete</button></article>`).join('');
  document.querySelectorAll('.delete').forEach((button) => button.addEventListener('click', async () => deleteDoc(doc(db, 'bibleChapters', button.dataset.id))));
}
form.addEventListener('submit', async (event) => { event.preventDefault(); const book = document.querySelector('#book').value.trim(); const chapter = Number(document.querySelector('#chapter').value); const language = document.querySelector('#language').value; const text = document.querySelector('#reading').value.trim(); const id = `${book.toLowerCase().replaceAll(' ', '-')}-${chapter}-${language}`; await setDoc(doc(db, 'bibleChapters', id), {book, chapter, language, text}); form.reset(); });
document.querySelector('#clear').addEventListener('click', () => alert('For safety, delete chapters individually. Bulk deletion should be an authenticated server operation.'));
document.querySelector('#export').addEventListener('click', () => { const blob = new Blob([JSON.stringify(chapters, null, 2)], {type:'application/json'}); const link = Object.assign(document.createElement('a'), {href:URL.createObjectURL(blob), download:'soma-bible-chapters.json'}); link.click(); URL.revokeObjectURL(link.href); });
const label = (language) => ({english:'English', arabic:'العربية', coptic:'Ⲙⲉⲧⲣⲉⲙⲛ̀ⲭⲏⲙⲓ', copticInArabic:'القبطية'})[language] || language;
const escapeHtml = (text) => text.replace(/[&<>'"]/g, (char) => ({'&':'&amp;','<':'&lt;','>':'&gt;',"'":'&#39;','"':'&quot;'}[char]));
