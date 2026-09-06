#!/usr/bin/env python3
"""
Downloads the 66-book Arabic Smith-Van Dyck (SVD) and English KJV datasets
from the public-domain midvash/bible-data repository and converts them into
the exact JSON schema expected by this Flutter project.

Run from the Flutter project root:
    python setup_bible_data.py

It creates:
    assets/bible/ar/<bookId>.json
    assets/bible/en/<bookId>.json
"""
from pathlib import Path
import json
import urllib.request
import ssl

BOOKS = [('genesis', 'Genesis', 'التكوين', 'Gen', 'old', 50), ('exodus', 'Exodus', 'الخروج', 'Exod', 'old', 40), ('leviticus', 'Leviticus', 'اللاويين', 'Lev', 'old', 27), ('numbers', 'Numbers', 'العدد', 'Num', 'old', 36), ('deuteronomy', 'Deuteronomy', 'التثنية', 'Deut', 'old', 34), ('joshua', 'Joshua', 'يشوع', 'Josh', 'old', 24), ('judges', 'Judges', 'القضاة', 'Judg', 'old', 21), ('ruth', 'Ruth', 'راعوث', 'Ruth', 'old', 4), ('1-samuel', '1 Samuel', 'صموئيل الأول', '1Sam', 'old', 31), ('2-samuel', '2 Samuel', 'صموئيل الثاني', '2Sam', 'old', 24), ('1-kings', '1 Kings', 'الملوك الأول', '1Kgs', 'old', 22), ('2-kings', '2 Kings', 'الملوك الثاني', '2Kgs', 'old', 25), ('1-chronicles', '1 Chronicles', 'أخبار الأيام الأول', '1Chr', 'old', 29), ('2-chronicles', '2 Chronicles', 'أخبار الأيام الثاني', '2Chr', 'old', 36), ('ezra', 'Ezra', 'عزرا', 'Ezra', 'old', 10), ('nehemiah', 'Nehemiah', 'نحميا', 'Neh', 'old', 13), ('esther', 'Esther', 'أستير', 'Esth', 'old', 10), ('job', 'Job', 'أيوب', 'Job', 'old', 42), ('psalms', 'Psalms', 'المزامير', 'Ps', 'old', 150), ('proverbs', 'Proverbs', 'الأمثال', 'Prov', 'old', 31), ('ecclesiastes', 'Ecclesiastes', 'الجامعة', 'Eccl', 'old', 12), ('song-of-solomon', 'Song of Solomon', 'نشيد الأنشاد', 'Song', 'old', 8), ('isaiah', 'Isaiah', 'إشعياء', 'Isa', 'old', 66), ('jeremiah', 'Jeremiah', 'إرميا', 'Jer', 'old', 52), ('lamentations', 'Lamentations', 'مراثي إرميا', 'Lam', 'old', 5), ('ezekiel', 'Ezekiel', 'حزقيال', 'Ezek', 'old', 48), ('daniel', 'Daniel', 'دانيال', 'Dan', 'old', 12), ('hosea', 'Hosea', 'هوشع', 'Hos', 'old', 14), ('joel', 'Joel', 'يوئيل', 'Joel', 'old', 3), ('amos', 'Amos', 'عاموس', 'Amos', 'old', 9), ('obadiah', 'Obadiah', 'عوبديا', 'Obad', 'old', 1), ('jonah', 'Jonah', 'يونان', 'Jonah', 'old', 4), ('micah', 'Micah', 'ميخا', 'Mic', 'old', 7), ('nahum', 'Nahum', 'ناحوم', 'Nah', 'old', 3), ('habakkuk', 'Habakkuk', 'حبقوق', 'Hab', 'old', 3), ('zephaniah', 'Zephaniah', 'صفنيا', 'Zeph', 'old', 3), ('haggai', 'Haggai', 'حجي', 'Hag', 'old', 2), ('zechariah', 'Zechariah', 'زكريا', 'Zech', 'old', 14), ('malachi', 'Malachi', 'ملاخي', 'Mal', 'old', 4), ('matthew', 'Matthew', 'متى', 'Matt', 'newTestament', 28), ('mark', 'Mark', 'مرقس', 'Mark', 'newTestament', 16), ('luke', 'Luke', 'لوقا', 'Luke', 'newTestament', 24), ('john', 'John', 'يوحنا', 'John', 'newTestament', 21), ('acts', 'Acts', 'أعمال الرسل', 'Acts', 'newTestament', 28), ('romans', 'Romans', 'رومية', 'Rom', 'newTestament', 16), ('1-corinthians', '1 Corinthians', 'كورنثوس الأولى', '1Cor', 'newTestament', 16), ('2-corinthians', '2 Corinthians', 'كورنثوس الثانية', '2Cor', 'newTestament', 13), ('galatians', 'Galatians', 'غلاطية', 'Gal', 'newTestament', 6), ('ephesians', 'Ephesians', 'أفسس', 'Eph', 'newTestament', 6), ('philippians', 'Philippians', 'فيلبي', 'Phil', 'newTestament', 4), ('colossians', 'Colossians', 'كولوسي', 'Col', 'newTestament', 4), ('1-thessalonians', '1 Thessalonians', 'تسالونيكي الأولى', '1Thess', 'newTestament', 5), ('2-thessalonians', '2 Thessalonians', 'تسالونيكي الثانية', '2Thess', 'newTestament', 3), ('1-timothy', '1 Timothy', 'تيموثاوس الأولى', '1Tim', 'newTestament', 6), ('2-timothy', '2 Timothy', 'تيموثاوس الثانية', '2Tim', 'newTestament', 4), ('titus', 'Titus', 'تيطس', 'Titus', 'newTestament', 3), ('philemon', 'Philemon', 'فليمون', 'Phlm', 'newTestament', 1), ('hebrews', 'Hebrews', 'العبرانيين', 'Heb', 'newTestament', 13), ('james', 'James', 'يعقوب', 'Jas', 'newTestament', 5), ('1-peter', '1 Peter', 'بطرس الأولى', '1Pet', 'newTestament', 5), ('2-peter', '2 Peter', 'بطرس الثانية', '2Pet', 'newTestament', 3), ('1-john', '1 John', 'يوحنا الأولى', '1John', 'newTestament', 5), ('2-john', '2 John', 'يوحنا الثانية', '2John', 'newTestament', 1), ('3-john', '3 John', 'يوحنا الثالثة', '3John', 'newTestament', 1), ('jude', 'Jude', 'يهوذا', 'Jude', 'newTestament', 1), ('revelation', 'Revelation', 'رؤيا يوحنا اللاهوتي', 'Rev', 'newTestament', 22)]

BASE = "https://raw.githubusercontent.com/midvash/bible-data/main/versions"
ROOT = Path(__file__).resolve().parent
def download(url):
    request = urllib.request.Request(
        url,
        headers={
            "User-Agent": "Mozilla/5.0"
        }
    )

    # MSYS2 Python may not have the Windows CA certificates configured.
    ssl_context = ssl._create_unverified_context()

    with urllib.request.urlopen(
        request,
        timeout=60,
        context=ssl_context,
    ) as response:
        return json.loads(
            response.read().decode("utf-8")
        )
def convert(source, book_id, arabic_name):
    chapters = []
    for ch in source.get("chapters", []):
        verses = []
        for verse in ch.get("verses", []):
            verses.append({
                "number": int(verse["number"]),
                "text": verse.get("text", "")
            })
        chapters.append({
            "chapterNumber": int(ch["chapter"]),
            "verses": verses
        })

    return {
        "bookId": book_id,
        "bookName": arabic_name,
        "chapters": chapters
    }

def main():
    for lang in ("ar", "en"):
        out_dir = ROOT / "assets" / "bible" / lang
        out_dir.mkdir(parents=True, exist_ok=True)

        version = "svd" if lang == "ar" else "kjv"

        for book_id, english_name, arabic_name, osis, testament, count in BOOKS:
            url = f"{BASE}/{lang}/{version}/books/{osis}.json"
            print(f"Downloading {lang}: {english_name} ...")
            source = download(url)

            result = convert(source, book_id, arabic_name)
            target = out_dir / f"{book_id}.json"
            target.write_text(
                json.dumps(result, ensure_ascii=False, indent=2),
                encoding="utf-8"
            )

            actual = len(result["chapters"])
            if actual != count:
                print(f"WARNING: {book_id}: expected {count}, got {actual}")

    print("\nDone. 132 Bible JSON files were generated.")

if __name__ == "__main__":
    main()
