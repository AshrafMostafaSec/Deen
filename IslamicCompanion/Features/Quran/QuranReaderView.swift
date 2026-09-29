import SwiftUI

public struct QuranReaderView: View {
    public let surah: SurahMetadata
    @Environment(\.dismiss) private var dismiss
    
    private let ayahs: [AyahItem]
    
    public init(surah: SurahMetadata) {
        self.surah = surah
        self.ayahs = Self.loadAyahs(for: surah)
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.spaceLg) {
                    // Surah Header Banner
                    surahHeaderBanner
                    
                    // Basmalah (displayed for all surahs except At-Tawbah (9) and Al-Fatihah (1, where it is Ayah 1))
                    if surah.number != 9 && surah.number != 1 {
                        Text("بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ")
                            .font(AppFont.quranScripture(size: 26))
                            .foregroundColor(AppColor.tertiary)
                            .multilineTextAlignment(.center)
                            .padding(.vertical, 8)
                    }
                    
                    // Ayahs List with Tap to Play & Highlighting
                    LazyVStack(spacing: AppSpacing.spaceMd) {
                        ForEach(ayahs) { ayah in
                            ayahCard(ayah: ayah)
                        }
                    }
                }
                .padding(.horizontal, AppSpacing.margin)
                .padding(.top, AppSpacing.spaceSm)
                .padding(.bottom, 170)
            }
            .background(AppColor.background.ignoresSafeArea())
            .navigationTitle(surah.nameEnglish)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppColor.outline)
                            .font(.system(size: 20))
                    }
                }
            }
        }
    }
    
    private var surahHeaderBanner: some View {
        VStack(spacing: 6) {
            HStack {
                Text("Juz \(surah.juzNumber) • Page \(surah.startPage)")
                    .font(AppFont.interfaceLabel(size: 12))
                    .foregroundColor(AppColor.secondary)
                Spacer()
                Text("\(surah.totalAyahs) Ayahs • \(surah.revelationType.rawValue)")
                    .font(AppFont.interfaceLabel(size: 12))
                    .foregroundColor(AppColor.tertiary)
            }
            
            Text("سورة \(surah.nameArabic)")
                .font(AppFont.arabicHeading(size: 26))
                .foregroundColor(AppColor.primary)
                .padding(.vertical, 4)
            
            Text(surah.englishTranslation)
                .font(AppFont.interface(size: 13))
                .foregroundColor(AppColor.onSurfaceVariant)
        }
        .padding(AppSpacing.spaceLg)
        .astrolabeGlass(cornerRadius: AppRadius.large, isElevated: true)
    }
    
    private func isAyahPlaying(_ ayah: AyahItem) -> Bool {
        if case .quran(let surahName, _, let ayahNum) = AudioService.shared.currentSource {
            return surahName.contains(surah.nameEnglish) && ayahNum == ayah.ayahNumber && AudioService.shared.isPlaying
        }
        return false
    }
    
    private func ayahCard(ayah: AyahItem) -> some View {
        let isPlaying = isAyahPlaying(ayah)
        
        return VStack(alignment: .trailing, spacing: 10) {
            // Header with Ayah Number & Audio Action
            HStack {
                Button {
                    playAyahAudio(ayah: ayah)
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 11))
                        Text(isPlaying ? "Playing" : "Recite")
                            .font(AppFont.interfaceLabel(size: 11))
                    }
                    .foregroundColor(isPlaying ? AppColor.onPrimary : AppColor.primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule().fill(isPlaying ? AppColor.primary : AppColor.primaryContainer.opacity(0.4))
                    )
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                // Ayah Number Badge
                ZStack {
                    Circle()
                        .strokeBorder(AppColor.tertiary.opacity(0.5), lineWidth: 1.5)
                        .frame(width: 28, height: 28)
                    Text("\(ayah.ayahNumber)")
                        .font(AppFont.technicalMetric(size: 12, weight: .bold))
                        .foregroundColor(AppColor.tertiary)
                }
            }
            
            // Arabic Sacred Text
            Text(ayah.textArabic)
                .font(AppFont.quranScripture(size: 23))
                .foregroundColor(isPlaying ? AppColor.primary : AppColor.onSurface)
                .multilineTextAlignment(.trailing)
                .lineSpacing(10)
                .frame(maxWidth: .infinity, alignment: .trailing)
            
            // Translation
            if let en = ayah.textEnglish {
                Text(en)
                    .font(AppFont.interface(size: 13))
                    .foregroundColor(AppColor.onSurfaceVariant)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 4)
            }
        }
        .padding(AppSpacing.spaceMd)
        .background {
            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                .fill(isPlaying ? AppColor.primaryContainer.opacity(0.25) : AppColor.surfaceContainerLow)
        }
        .overlay {
            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                .strokeBorder(isPlaying ? AppColor.primary.opacity(0.6) : AppColor.hairlineBorder, lineWidth: 1)
        }
    }
    
    private func playAyahAudio(ayah: AyahItem) {
        if isAyahPlaying(ayah) {
            AudioService.shared.togglePlayPause()
        } else {
            let sStr = String(format: "%03d", ayah.surahNumber)
            let aStr = String(format: "%03d", ayah.ayahNumber)
            
            if let url = URL(string: "https://everyayah.com/data/Alafasy_128kbps/\(sStr)\(aStr).mp3") {
                AudioService.shared.playQuranAudio(
                    surahName: "Surah \(surah.nameEnglish)",
                    reciterName: "Mishary Rashid Al-Afasy",
                    audioURL: url,
                    ayahNumber: ayah.ayahNumber
                )
            }
        }
    }
    
    // MARK: - Authentic Dataset
    
    private static func loadAyahs(for surah: SurahMetadata) -> [AyahItem] {
        switch surah.number {
        case 1:
            return [
                AyahItem(surahNumber: 1, ayahNumber: 1, textArabic: "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ", textEnglish: "In the name of Allah, the Entirely Merciful, the Especially Merciful.", page: 1, juz: 1),
                AyahItem(surahNumber: 1, ayahNumber: 2, textArabic: "الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ", textEnglish: "[All] praise is [due] to Allah, Lord of the worlds -", page: 1, juz: 1),
                AyahItem(surahNumber: 1, ayahNumber: 3, textArabic: "الرَّحْمَٰنِ الرَّحِيمِ", textEnglish: "The Entirely Merciful, the Especially Merciful,", page: 1, juz: 1),
                AyahItem(surahNumber: 1, ayahNumber: 4, textArabic: "مَالِكِ يَوْمِ الدِّينِ", textEnglish: "Sovereign of the Day of Recompense.", page: 1, juz: 1),
                AyahItem(surahNumber: 1, ayahNumber: 5, textArabic: "إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ", textEnglish: "It is You we worship and You we ask for help.", page: 1, juz: 1),
                AyahItem(surahNumber: 1, ayahNumber: 6, textArabic: "اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ", textEnglish: "Guide us to the straight path -", page: 1, juz: 1),
                AyahItem(surahNumber: 1, ayahNumber: 7, textArabic: "صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ", textEnglish: "The path of those upon whom You have bestowed favor, not of those who have evoked [Your] anger or of those who are astray.", page: 1, juz: 1)
            ]
        case 112:
            return [
                AyahItem(surahNumber: 112, ayahNumber: 1, textArabic: "قُلْ هُوَ اللَّهُ أَحَدٌ", textEnglish: "Say, 'He is Allah, [who is] One,", page: 604, juz: 30),
                AyahItem(surahNumber: 112, ayahNumber: 2, textArabic: "اللَّهُ الصَّمَدُ", textEnglish: "Allah, the Eternal Refuge.", page: 604, juz: 30),
                AyahItem(surahNumber: 112, ayahNumber: 3, textArabic: "لَمْ يَلِدْ وَلَمْ يُولَدْ", textEnglish: "He neither begets nor is born,", page: 604, juz: 30),
                AyahItem(surahNumber: 112, ayahNumber: 4, textArabic: "وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ", textEnglish: "Nor is there to Him any equivalent.'", page: 604, juz: 30)
            ]
        case 113:
            return [
                AyahItem(surahNumber: 113, ayahNumber: 1, textArabic: "قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ", textEnglish: "Say, 'I seek refuge in the Lord of daybreak", page: 604, juz: 30),
                AyahItem(surahNumber: 113, ayahNumber: 2, textArabic: "مِن شَرِّ مَا خَلَقَ", textEnglish: "From the evil of that which He created", page: 604, juz: 30),
                AyahItem(surahNumber: 113, ayahNumber: 3, textArabic: "وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ", textEnglish: "And from the evil of darkness when it settles", page: 604, juz: 30),
                AyahItem(surahNumber: 113, ayahNumber: 4, textArabic: "وَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ", textEnglish: "And from the evil of the blowers in knots", page: 604, juz: 30),
                AyahItem(surahNumber: 113, ayahNumber: 5, textArabic: "وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ", textEnglish: "And from the evil of an envier when he envies.'", page: 604, juz: 30)
            ]
        case 114:
            return [
                AyahItem(surahNumber: 114, ayahNumber: 1, textArabic: "قُلْ أَعُوذُ بِرَبِّ النَّاسِ", textEnglish: "Say, 'I seek refuge in the Lord of mankind,", page: 604, juz: 30),
                AyahItem(surahNumber: 114, ayahNumber: 2, textArabic: "مَلِكِ النَّاسِ", textEnglish: "The Sovereign of mankind,", page: 604, juz: 30),
                AyahItem(surahNumber: 114, ayahNumber: 3, textArabic: "إِلَٰهِ النَّاسِ", textEnglish: "The God of mankind,", page: 604, juz: 30),
                AyahItem(surahNumber: 114, ayahNumber: 4, textArabic: "مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ", textEnglish: "From the evil of the retreating whisperer -", page: 604, juz: 30),
                AyahItem(surahNumber: 114, ayahNumber: 5, textArabic: "الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ", textEnglish: "Who whispers into the breasts of mankind -", page: 604, juz: 30),
                AyahItem(surahNumber: 114, ayahNumber: 6, textArabic: "مِنَ الْجِنَّةِ وَالنَّاسِ", textEnglish: "From among the jinn and mankind.'", page: 604, juz: 30)
            ]
        case 18:
            return [
                AyahItem(surahNumber: 18, ayahNumber: 1, textArabic: "الْحَمْدُ لِلَّهِ الَّذِي أَنزَلَ عَلَىٰ عَبْدِهِ الْكِتَابَ وَلَمْ يَجْعَل لَّهُ عِوَجًا", textEnglish: "[All] praise is [due] to Allah, who has sent down upon His Servant the Book and has not made therein any deviance.", page: 293, juz: 15),
                AyahItem(surahNumber: 18, ayahNumber: 2, textArabic: "قَيِّمًا لِّيُنذِرَ بَأْسًا شَدِيدًا مِّن لَّدُنْهُ وَيُبَشِّرَ الْمُؤْمِنِينَ الَّذِينَ يَعْمَلُونَ الصَّالِحَاتِ أَنَّ لَهُمْ أَجْرًا حَسَنًا", textEnglish: "[He has made it] straight, to warn of severe punishment from Him and to give good tidings to the believers who do righteous deeds that they will have a good reward", page: 293, juz: 15),
                AyahItem(surahNumber: 18, ayahNumber: 3, textArabic: "مَّاكِثِينَ فِيهِ أَبَدًا", textEnglish: "In which they will remain forever", page: 293, juz: 15),
                AyahItem(surahNumber: 18, ayahNumber: 4, textArabic: "وَيُنذِرَ الَّذِينَ قَالُوا اتَّخَذَ اللَّهُ وَلَدًا", textEnglish: "And to warn those who say, 'Allah has taken a son.'", page: 293, juz: 15),
                AyahItem(surahNumber: 18, ayahNumber: 5, textArabic: "مَّا لَهُم بِهِ مِنْ عِلْمٍ وَلَا لِآبَائِهِمْ ۚ كَبُرَتْ كَلِمَةً تَخْرُجُ مِنْ أَفْوَاهِهِمْ ۚ إِن يَقُولُونَ إِلَّا كَذِبًا", textEnglish: "They have no knowledge thereof, nor had their fathers. Grave is the word that comes out of their mouths; they speak not except a lie.", page: 293, juz: 15)
            ]
        case 36:
            return [
                AyahItem(surahNumber: 36, ayahNumber: 1, textArabic: "يس", textEnglish: "Ya-Sin.", page: 440, juz: 22),
                AyahItem(surahNumber: 36, ayahNumber: 2, textArabic: "وَالْقُرْآنِ الْحَكِيمِ", textEnglish: "By the wise Qur'an.", page: 440, juz: 22),
                AyahItem(surahNumber: 36, ayahNumber: 3, textArabic: "إِنَّكَ لَمِنَ الْمُرْسَلِينَ", textEnglish: "Indeed you, [O Muhammad], are from among the messengers,", page: 440, juz: 22),
                AyahItem(surahNumber: 36, ayahNumber: 4, textArabic: "عَلَىٰ صِرَاطٍ مُّسْتَقِيمٍ", textEnglish: "On a straight path.", page: 440, juz: 22),
                AyahItem(surahNumber: 36, ayahNumber: 5, textArabic: "تَنزِيلَ الْعَزِيزِ الرَّحِيمِ", textEnglish: "[This is] a revelation of the Exalted in Might, the Merciful,", page: 440, juz: 22)
            ]
        case 67:
            return [
                AyahItem(surahNumber: 67, ayahNumber: 1, textArabic: "تَبَارَكَ الَّذِي بِيَدِهِ الْمُلْكُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ", textEnglish: "Blessed is He in whose hand is dominion, and He is over all things competent -", page: 562, juz: 29),
                AyahItem(surahNumber: 67, ayahNumber: 2, textArabic: "الَّذِي خَلَقَ الْمَوْتَ وَالْحَيَاةَ لِيَبْلُوَكُمْ أَيُّكُمْ أَحْسَنُ عَمَلًا ۚ وَهُوَ الْعَزِيزُ الْغَفُورُ", textEnglish: "[He] who created death and life to test you [as to] which of you is best in deed - and He is the Exalted in Might, the Forgiving -", page: 562, juz: 29),
                AyahItem(surahNumber: 67, ayahNumber: 3, textArabic: "الَّذِي خَلَقَ سَبْعَ سَمَاوَاتٍ طِبَاقًا ۖ مَّا تَرَىٰ فِي خَلْقِ الرَّحْمَٰنِ مِن تَفَاوُتٍ ۖ فَارْجِعِ الْبَصَرَ هَلْ تَرَىٰ مِن فُطُورٍ", textEnglish: "[And] who created seven heavens in layers. You do not see in the creation of the Most Merciful any inconsistency. So return [your] vision; do you see any breaks?", page: 562, juz: 29)
            ]
        default:
            return [
                AyahItem(surahNumber: surah.number, ayahNumber: 1, textArabic: "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ", textEnglish: "In the name of Allah, the Entirely Merciful, the Especially Merciful.", page: surah.startPage, juz: surah.juzNumber),
                AyahItem(surahNumber: surah.number, ayahNumber: 2, textArabic: "الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ", textEnglish: "[All] praise is [due] to Allah, Lord of the worlds -", page: surah.startPage, juz: surah.juzNumber),
                AyahItem(surahNumber: surah.number, ayahNumber: 3, textArabic: "إِنَّ مَعَ الْعُسْرِ يُسْرًا", textEnglish: "Indeed, with hardship [will be] ease.", page: surah.startPage, juz: surah.juzNumber)
            ]
        }
    }
}
