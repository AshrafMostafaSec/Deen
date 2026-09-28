import json
import os

surahs_data = [
    (1, "الفاتحة", "Al-Fatihah", "The Opening", 7, "Makki", 1, 1),
    (2, "البقرة", "Al-Baqarah", "The Cow", 286, "Madani", 2, 1),
    (3, "آل عمران", "Ali 'Imran", "Family of Imran", 200, "Madani", 50, 3),
    (4, "النساء", "An-Nisa", "The Women", 176, "Madani", 77, 4),
    (5, "المائدة", "Al-Ma'idah", "The Table Spread", 120, "Madani", 106, 6),
    (6, "الأنعام", "Al-An'am", "The Cattle", 165, "Makki", 128, 7),
    (7, "الأعراف", "Al-A'raf", "The Heights", 206, "Makki", 151, 8),
    (8, "الأنفال", "Al-Anfal", "The Spoils of War", 75, "Madani", 177, 9),
    (9, "التوبة", "At-Tawbah", "The Repentance", 129, "Madani", 187, 10),
    (10, "يونس", "Yunus", "Jonah", 109, "Makki", 208, 11),
    (11, "هود", "Hud", "Hud", 123, "Makki", 221, 11),
    (12, "يوسف", "Yusuf", "Joseph", 111, "Makki", 235, 12),
    (13, "الرعد", "Ar-Ra'd", "The Thunder", 43, "Madani", 249, 13),
    (14, "إبراهيم", "Ibrahim", "Abraham", 52, "Makki", 255, 13),
    (15, "الحجر", "Al-Hijr", "The Rocky Tract", 99, "Makki", 262, 14),
    (16, "النحل", "An-Nahl", "The Bee", 128, "Makki", 267, 14),
    (17, "الإسراء", "Al-Isra", "The Night Journey", 111, "Makki", 282, 15),
    (18, "الكهف", "Al-Kahf", "The Cave", 110, "Makki", 293, 15),
    (19, "مريم", "Maryam", "Mary", 98, "Makki", 305, 16),
    (20, "طه", "Taha", "Ta-Ha", 135, "Makki", 312, 16),
    (21, "الأنبياء", "Al-Anbiya", "The Prophets", 112, "Makki", 322, 17),
    (22, "الحج", "Al-Hajj", "The Pilgrimage", 78, "Madani", 332, 17),
    (23, "المؤمنون", "Al-Mu'minun", "The Believers", 118, "Makki", 342, 18),
    (24, "النور", "An-Nur", "The Light", 64, "Madani", 350, 18),
    (25, "الفرقان", "Al-Furqan", "The Criterion", 77, "Makki", 359, 18),
    (26, "الشعراء", "Ash-Shu'ara", "The Poets", 227, "Makki", 367, 19),
    (27, "النمل", "An-Naml", "The Ant", 93, "Makki", 377, 19),
    (28, "القصص", "Al-Qasas", "The Stories", 88, "Makki", 385, 20),
    (29, "العنكبوت", "Al-'Ankabut", "The Spider", 69, "Makki", 396, 20),
    (30, "الروم", "Ar-Rum", "The Romans", 60, "Makki", 404, 21),
    (31, "لقمان", "Luqman", "Luqman", 34, "Makki", 411, 21),
    (32, "السجدة", "As-Sajdah", "The Prostration", 30, "Makki", 415, 21),
    (33, "الأحزاب", "Al-Ahzab", "The Combined Forces", 73, "Madani", 418, 21),
    (34, "سبأ", "Saba", "Sheba", 54, "Makki", 428, 22),
    (35, "فاطر", "Fatir", "Originator", 45, "Makki", 434, 22),
    (36, "يس", "Ya-Sin", "Ya-Sin", 83, "Makki", 440, 22),
    (37, "الصافات", "As-Saffat", "Those Who Set The Ranks", 182, "Makki", 446, 23),
    (38, "ص", "Sad", "The Letter Sad", 88, "Makki", 453, 23),
    (39, "الزمر", "Az-Zumar", "The Troops", 75, "Makki", 458, 23),
    (40, "غافر", "Ghafir", "The Forgiver", 85, "Makki", 467, 24),
    (41, "فصلت", "Fussilat", "Explained In Detail", 54, "Makki", 477, 24),
    (42, "الشورى", "Ash-Shura", "The Consultation", 53, "Makki", 483, 25),
    (43, "الزخرف", "Az-Zukhruf", "The Ornaments Of Gold", 89, "Makki", 489, 25),
    (44, "الدخان", "Ad-Dukhan", "The Smoke", 59, "Makki", 496, 25),
    (45, "الجاثية", "Al-Jathiyah", "The Crouching", 37, "Makki", 499, 25),
    (46, "الأحقاف", "Al-Ahqaf", "The Wind-Curved Sandhills", 35, "Makki", 502, 26),
    (47, "محمد", "Muhammad", "Muhammad", 38, "Madani", 507, 26),
    (48, "الفتح", "Al-Fath", "The Victory", 29, "Madani", 511, 26),
    (49, "الحجرات", "Al-Hujurat", "The Rooms", 18, "Madani", 515, 26),
    (50, "ق", "Qaf", "The Letter Qaf", 45, "Makki", 518, 26),
    (51, "الذاريات", "Adh-Dhariyat", "The Winnowing Winds", 60, "Makki", 520, 26),
    (52, "الطور", "At-Tur", "The Mount", 49, "Makki", 523, 27),
    (53, "النجم", "An-Najm", "The Star", 62, "Makki", 526, 27),
    (54, "القمر", "Al-Qamar", "The Moon", 55, "Makki", 528, 27),
    (55, "الرحمن", "Ar-Rahman", "The Beneficent", 78, "Madani", 531, 27),
    (56, "الواقعة", "Al-Waqi'ah", "The Inevitable", 96, "Makki", 534, 27),
    (57, "الحديد", "Al-Hadid", "The Iron", 29, "Madani", 537, 27),
    (58, "المجادلة", "Al-Mujadila", "The Pleading Woman", 22, "Madani", 542, 28),
    (59, "الحشر", "Al-Hashr", "The Exile", 24, "Madani", 545, 28),
    (60, "الممتحنة", "Al-Mumtahanah", "She That Is To Be Examined", 13, "Madani", 549, 28),
    (61, "الصف", "As-Saff", "The Ranks", 14, "Madani", 551, 28),
    (62, "الجمعة", "Al-Jumu'ah", "Friday", 11, "Madani", 553, 28),
    (63, "المنافقون", "Al-Munafiqun", "The Hypocrites", 11, "Madani", 554, 28),
    (64, "التغابن", "At-Taghabun", "The Mutual Disillusion", 18, "Madani", 556, 28),
    (65, "الطلاق", "At-Talaq", "The Divorce", 12, "Madani", 558, 28),
    (66, "التحريم", "At-Tahrim", "The Prohibition", 12, "Madani", 560, 28),
    (67, "الملك", "Al-Mulk", "The Sovereignty", 30, "Makki", 562, 29),
    (68, "القلم", "Al-Qalam", "The Pen", 52, "Makki", 564, 29),
    (69, "الحاقة", "Al-Haqqah", "The Reality", 52, "Makki", 566, 29),
    (70, "المعارج", "Al-Ma'arij", "The Ascending Stairways", 44, "Makki", 568, 29),
    (71, "نوح", "Nuh", "Noah", 28, "Makki", 570, 29),
    (72, "الجن", "Al-Jinn", "The Jinn", 28, "Makki", 572, 29),
    (73, "المزمل", "Al-Muzzammil", "The Enshrouded One", 20, "Makki", 574, 29),
    (74, "المدثر", "Al-Muddaththir", "The Cloaked One", 56, "Makki", 575, 29),
    (75, "القيامة", "Al-Qiyamah", "The Resurrection", 40, "Makki", 577, 29),
    (76, "الإنسان", "Al-Insan", "Man", 31, "Madani", 578, 29),
    (77, "المرسلات", "Al-Mursalat", "The Emissaries", 50, "Makki", 580, 29),
    (78, "النبأ", "An-Naba", "The Tidings", 40, "Makki", 582, 30),
    (79, "النازعات", "An-Nazi'at", "Those Who Drag Forth", 46, "Makki", 583, 30),
    (80, "عبس", "'Abasa", "He Frowned", 42, "Makki", 585, 30),
    (81, "التكوير", "At-Takwir", "The Overthrowing", 29, "Makki", 586, 30),
    (82, "الانفطار", "Al-Infitar", "The Cleaving", 19, "Makki", 587, 30),
    (83, "المطففين", "Al-Mutaffifin", "Defrauding", 36, "Makki", 587, 30),
    (84, "الانشقاق", "Al-Inshiqaq", "The Splitting Open", 25, "Makki", 589, 30),
    (85, "البروج", "Al-Buruj", "The Constellations", 22, "Makki", 590, 30),
    (86, "الطارق", "At-Tariq", "The Nightcomer", 17, "Makki", 591, 30),
    (87, "الأعلى", "Al-A'la", "The Most High", 19, "Makki", 591, 30),
    (88, "الغاشية", "Al-Ghashiyah", "The Overwhelming", 26, "Makki", 592, 30),
    (89, "الفجر", "Al-Fajr", "The Dawn", 30, "Makki", 593, 30),
    (90, "البلد", "Al-Balad", "The City", 20, "Makki", 594, 30),
    (91, "الشمس", "Ash-Shams", "The Sun", 15, "Makki", 595, 30),
    (92, "الليل", "Al-Layl", "The Night", 21, "Makki", 595, 30),
    (93, "الضحى", "Ad-Duha", "The Morning Hours", 11, "Makki", 596, 30),
    (94, "الشرح", "Ash-Sharh", "The Relief", 8, "Makki", 596, 30),
    (95, "التين", "At-Tin", "The Fig", 8, "Makki", 597, 30),
    (96, "العلق", "Al-'Alaq", "The Clot", 19, "Makki", 597, 30),
    (97, "القدر", "Al-Qadr", "The Power", 5, "Makki", 598, 30),
    (98, "البينة", "Al-Bayyinah", "The Clear Proof", 8, "Madani", 598, 30),
    (99, "الزلزلة", "Az-Zalzalah", "The Earthquake", 8, "Madani", 599, 30),
    (100, "العاديات", "Al-'Adiyat", "The Courser", 11, "Makki", 599, 30),
    (101, "القارعة", "Al-Qari'ah", "The Calamity", 11, "Makki", 600, 30),
    (102, "التكاثر", "At-Takathur", "The Rivalry in World Increase", 8, "Makki", 600, 30),
    (103, "العصر", "Al-'Asr", "The Declining Day", 3, "Makki", 601, 30),
    (104, "الهمزة", "Al-Humazah", "The Traducer", 9, "Makki", 601, 30),
    (105, "الفيل", "Al-Fil", "The Elephant", 5, "Makki", 601, 30),
    (106, "قريش", "Quraysh", "Quraysh", 4, "Makki", 602, 30),
    (107, "الماعون", "Al-Ma'un", "The Small Kindnesses", 7, "Makki", 602, 30),
    (108, "الكوثر", "Al-Kawthar", "Abundance", 3, "Makki", 602, 30),
    (109, "الكافرون", "Al-Kafirun", "The Disbelievers", 6, "Makki", 603, 30),
    (110, "النصر", "An-Nasr", "The Divine Support", 3, "Madani", 603, 30),
    (111, "المسد", "Al-Masad", "The Palm Fiber", 5, "Makki", 603, 30),
    (112, "الإخلاص", "Al-Ikhlas", "Sincerity", 4, "Makki", 604, 30),
    (113, "الفلق", "Al-Falaq", "Daybreak", 5, "Makki", 604, 30),
    (114, "الناس", "An-Nas", "Mankind", 6, "Makki", 604, 30)
]

surahs_json = []
for s in surahs_data:
    surahs_json.append({
        "number": s[0],
        "nameArabic": s[1],
        "nameEnglish": s[2],
        "englishTranslation": s[3],
        "totalAyahs": s[4],
        "revelationType": s[5],
        "startPage": s[6],
        "juzNumber": s[7]
    })

os.makedirs("IslamicCompanion/Resources/Quran", exist_ok=True)
with open("IslamicCompanion/Resources/Quran/surahs_114.json", "w", encoding="utf-8") as f:
    json.dump(surahs_json, f, ensure_ascii=False, indent=2)

print(f"Generated complete 114 surahs catalog: {len(surahs_json)} entries")

# Adhkar Catalog
adhkar_catalog = {
    "morning": [
        {
            "id": "m1",
            "textArabic": "أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لاَ إِلَـهَ إِلاَّ اللهُ وَحْدَهُ لاَ شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ",
            "textEnglish": "We have entered a new morning and with it all dominion belongs to Allah. Praise is to Allah. None has the right to be worshipped except Allah alone, without partner.",
            "targetCount": 1,
            "reference": "Sahih Muslim"
        },
        {
            "id": "m2",
            "textArabic": "اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ وَإِلَيْكَ النُّشُورُ",
            "textEnglish": "O Allah, by You we enter the morning and by You we enter the evening, by You we live and by You we die, and to You is the resurrection.",
            "targetCount": 1,
            "reference": "At-Tirmidhi"
        },
        {
            "id": "m3",
            "textArabic": "اللَّهُمَّ أَنْتَ رَبِّي لاَ إِلَهَ إِلاَّ أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ بِذَنْبِي فَاغْفِرْ لِي فَإِنَّهُ لاَ يَغْفِرُ الذُّنُوبَ إِلاَّ أَنْتَ",
            "textEnglish": "Sayyid al-Istighfar (The Master Supplication for Forgiveness): O Allah, You are my Lord, none has the right to be worshipped but You. You created me and I am Your servant...",
            "targetCount": 1,
            "reference": "Sahih al-Bukhari"
        },
        {
            "id": "m4",
            "textArabic": "بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ",
            "textEnglish": "In the name of Allah, with whose name nothing on earth or in the sky can cause harm, and He is the All-Hearing, All-Knowing.",
            "targetCount": 3,
            "reference": "Abu Dawood & At-Tirmidhi"
        },
        {
            "id": "m5",
            "textArabic": "رَضِيتُ بِاللَّهِ رَبًّا، وَبِالْإِسْلَامِ دِينًا، وَبِمُحَمَّدٍ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ نَبِيًّا",
            "textEnglish": "I am pleased with Allah as my Lord, with Islam as my religion, and with Muhammad (pbuh) as my Prophet.",
            "targetCount": 3,
            "reference": "Abu Dawood & Ahmad"
        },
        {
            "id": "m6",
            "textArabic": "يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيثُ، أَصْلِحْ لِي شَأْنِي كُلَّهُ، وَلَا تَكِلْنِي إِلَى نَفْسِي طَرْفَةَ عَيْنٍ",
            "textEnglish": "O Ever Living One, O Self-Existing One, by Your mercy I seek assistance. Rectify for me all my affairs, and do not leave me to myself even for the blink of an eye.",
            "targetCount": 1,
            "reference": "Al-Hakim"
        },
        {
            "id": "m7",
            "textArabic": "سُبْحَانَ اللَّهِ وَبِحَمْدِهِ",
            "textEnglish": "Glory is to Allah and praise is to Him. (Whoever says this 100 times in the morning and evening, his sins will be forgiven even if they are like the foam of the sea).",
            "targetCount": 100,
            "reference": "Sahih Muslim"
        }
    ],
    "evening": [
        {
            "id": "e1",
            "textArabic": "أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لاَ إِلَـهَ إِلاَّ اللهُ وَحْدَهُ لاَ شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ",
            "textEnglish": "We have entered the evening and with it all dominion belongs to Allah. Praise is to Allah. None has the right to be worshipped except Allah alone.",
            "targetCount": 1,
            "reference": "Sahih Muslim"
        },
        {
            "id": "e2",
            "textArabic": "اللَّهُمَّ بِكَ أَمْسَيْنَا، وَبِكَ أَصْبَحْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ وَإِلَيْكَ الْمَصِيرُ",
            "textEnglish": "O Allah, by You we enter the evening and by You we enter the morning, by You we live and by You we die, and to You is the final return.",
            "targetCount": 1,
            "reference": "At-Tirmidhi"
        },
        {
            "id": "e3",
            "textArabic": "أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ",
            "textEnglish": "I seek refuge in the perfect words of Allah from the evil of what He has created.",
            "targetCount": 3,
            "reference": "Sahih Muslim"
        },
        {
            "id": "e4",
            "textArabic": "بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ",
            "textEnglish": "In the name of Allah, with whose name nothing on earth or in the sky can cause harm.",
            "targetCount": 3,
            "reference": "Abu Dawood"
        },
        {
            "id": "e5",
            "textArabic": "سُبْحَانَ اللَّهِ وَبِحَمْدِهِ",
            "textEnglish": "Glory is to Allah and praise is to Him (100 times).",
            "targetCount": 100,
            "reference": "Sahih Muslim"
        }
    ],
    "post_prayer": [
        {
            "id": "p1",
            "textArabic": "أَسْتَغْفِرُ اللَّهَ ، أَسْتَغْفِرُ اللَّهَ ، أَسْتَغْفِرُ اللَّهَ",
            "textEnglish": "I seek forgiveness from Allah (3 times).",
            "targetCount": 3,
            "reference": "Sahih Muslim"
        },
        {
            "id": "p2",
            "textArabic": "اللَّهُمَّ أَنْتَ السَّلاَمُ وَمِنْكَ السَّلاَمُ تَبَارَكْتَ يَا ذَا الْجَلاَلِ وَالإِكْرَامِ",
            "textEnglish": "O Allah, You are Peace and from You comes peace. Blessed are You, O Possessor of majesty and honor.",
            "targetCount": 1,
            "reference": "Sahih Muslim"
        },
        {
            "id": "p3",
            "textArabic": "سُبْحَانَ اللَّهِ",
            "textEnglish": "Glory be to Allah (33 times).",
            "targetCount": 33,
            "reference": "Sahih al-Bukhari"
        },
        {
            "id": "p4",
            "textArabic": "الْحَمْدُ لِلَّهِ",
            "textEnglish": "Praise be to Allah (33 times).",
            "targetCount": 33,
            "reference": "Sahih al-Bukhari"
        },
        {
            "id": "p5",
            "textArabic": "اللَّهُ أَكْبَرُ",
            "textEnglish": "Allah is Most Great (33 times).",
            "targetCount": 33,
            "reference": "Sahih al-Bukhari"
        },
        {
            "id": "p6",
            "textArabic": "لاَ إِلَـهَ إِلاَّ اللهُ وَحْدَهُ لاَ شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ",
            "textEnglish": "None has the right to be worshipped except Allah alone, without partner (To complete the hundred).",
            "targetCount": 1,
            "reference": "Sahih Muslim"
        }
    ],
    "sleep": [
        {
            "id": "s1",
            "textArabic": "بِاسْمِكَ رَبِّي وَضَعْتُ جَنْبِي وَبِكَ أَرْفَعُهُ، إِنْ أَمْسَكْتَ نَفْسِي فَارْحَمْهَا، وَإِنْ أَرْسَلْتَهَا فَاحْفَظْهَا بِمَا تَحْفَظُ بِهِ عِبَادَكَ الصَّالِحِينَ",
            "textEnglish": "In Your name my Lord, I lie down and in Your name I arise. If You keep my soul, have mercy upon it, and if You send it back, protect it as You protect Your righteous slaves.",
            "targetCount": 1,
            "reference": "Sahih al-Bukhari"
        },
        {
            "id": "s2",
            "textArabic": "اللَّهُمَّ بِاسْمِكَ أَمُوتُ وَأَحْيَا",
            "textEnglish": "O Allah, in Your name I die and I live.",
            "targetCount": 1,
            "reference": "Sahih al-Bukhari"
        },
        {
            "id": "s3",
            "textArabic": "سُبْحَانَ اللَّهِ (33) ، وَالْحَمْدُ لِلَّهِ (33) ، وَاللَّهُ أَكْبَرُ (34)",
            "textEnglish": "The Tasbeeh of Fatimah: SubhanAllah (33), Alhamdulillah (33), Allahu Akbar (34).",
            "targetCount": 1,
            "reference": "Sahih al-Bukhari"
        }
    ]
}

os.makedirs("IslamicCompanion/Resources/Adhkar", exist_ok=True)
with open("IslamicCompanion/Resources/Adhkar/adhkar_fortress.json", "w", encoding="utf-8") as f:
    json.dump(adhkar_catalog, f, ensure_ascii=False, indent=2)

print("Generated comprehensive Adhkar Fortress catalog successfully!")
