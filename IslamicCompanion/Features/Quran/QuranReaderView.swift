import SwiftUI

public struct QuranReaderView: View {
    public let surah: SurahMetadata
    @Environment(\.dismiss) private var dismiss
    @State private var activePlayingAyahIndex: Int? = nil
    @State private var isAudioLoading: Bool = false
    
    // Sample verified ayahs for demonstration and reading
    private let ayahs: [AyahItem]
    
    public init(surah: SurahMetadata) {
        self.surah = surah
        
        // Populate authentic sample dataset based on surah number
        if surah.number == 1 {
            self.ayahs = [
                AyahItem(surahNumber: 1, ayahNumber: 1, textArabic: "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ", textEnglish: "In the name of Allah, the Entirely Merciful, the Especially Merciful.", page: 1, juz: 1),
                AyahItem(surahNumber: 1, ayahNumber: 2, textArabic: "الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ", textEnglish: "[All] praise is [due] to Allah, Lord of the worlds -", page: 1, juz: 1),
                AyahItem(surahNumber: 1, ayahNumber: 3, textArabic: "الرَّحْمَٰنِ الرَّحِيمِ", textEnglish: "The Entirely Merciful, the Especially Merciful,", page: 1, juz: 1),
                AyahItem(surahNumber: 1, ayahNumber: 4, textArabic: "مَالِكِ يَوْمِ الدِّينِ", textEnglish: "Sovereign of the Day of Recompense.", page: 1, juz: 1),
                AyahItem(surahNumber: 1, ayahNumber: 5, textArabic: "إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ", textEnglish: "It is You we worship and You we ask for help.", page: 1, juz: 1),
                AyahItem(surahNumber: 1, ayahNumber: 6, textArabic: "اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ", textEnglish: "Guide us to the straight path -", page: 1, juz: 1),
                AyahItem(surahNumber: 1, ayahNumber: 7, textArabic: "صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ", textEnglish: "The path of those upon whom You have bestowed favor, not of those who have evoked [Your] anger or of those who are astray.", page: 1, juz: 1)
            ]
        } else if surah.number == 112 {
            self.ayahs = [
                AyahItem(surahNumber: 112, ayahNumber: 1, textArabic: "قُلْ هُوَ اللَّهُ أَحَدٌ", textEnglish: "Say, 'He is Allah, [who is] One,", page: 604, juz: 30),
                AyahItem(surahNumber: 112, ayahNumber: 2, textArabic: "اللَّهُ الصَّمَدُ", textEnglish: "Allah, the Eternal Refuge.", page: 604, juz: 30),
                AyahItem(surahNumber: 112, ayahNumber: 3, textArabic: "لَمْ يَلِدْ وَلَمْ يُولَدْ", textEnglish: "He neither begets nor is born,", page: 604, juz: 30),
                AyahItem(surahNumber: 112, ayahNumber: 4, textArabic: "وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ", textEnglish: "Nor is there to Him any equivalent.'", page: 604, juz: 30)
            ]
        } else {
            // General starter ayahs
            self.ayahs = [
                AyahItem(surahNumber: surah.number, ayahNumber: 1, textArabic: "الم", textEnglish: "Alif, Lam, Meem.", page: surah.startPage, juz: surah.juzNumber),
                AyahItem(surahNumber: surah.number, ayahNumber: 2, textArabic: "ذَٰلِكَ الْكِتَابُ لَا رَيْبَ ۛ فِيهِ ۛ هُدًى لِّلْمُتَّقِينَ", textEnglish: "This is the Book about which there is no doubt, a guidance for those conscious of Allah -", page: surah.startPage, juz: surah.juzNumber),
                AyahItem(surahNumber: surah.number, ayahNumber: 3, textArabic: "الَّذِينَ يُؤْمِنُونَ بِالْغَيْبِ وَيُقِيمُونَ الصَّلَاةَ وَمِمَّا رَزَقْنَاهُمْ يُنفِقُونَ", textEnglish: "Who believe in the unseen, establish prayer, and spend out of what We have provided for them,", page: surah.startPage, juz: surah.juzNumber)
            ]
        }
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.spaceLg) {
                    // Surah Header Banner
                    surahHeaderBanner
                    
                    // Basmalah (except for At-Tawbah)
                    if surah.number != 9 {
                        Text("بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ")
                            .font(AppFont.quranScripture(size: 26))
                            .foregroundColor(AppColor.tertiary)
                            .multilineTextAlignment(.center)
                            .padding(.vertical, 8)
                    }
                    
                    // Ayahs List with Tap to Play & Highlighting
                    LazyVStack(spacing: AppSpacing.spaceMd) {
                        ForEach(ayahs) { ayah in
                            let isPlaying = activePlayingAyahIndex == ayah.ayahNumber
                            ayahCard(ayah: ayah, isPlaying: isPlaying)
                        }
                    }
                }
                .padding(.horizontal, AppSpacing.margin)
                .padding(.top, AppSpacing.spaceSm)
                .padding(.bottom, 120)
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
    
    private func ayahCard(ayah: AyahItem, isPlaying: Bool) -> some View {
        VStack(alignment: .trailing, spacing: 10) {
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
        if activePlayingAyahIndex == ayah.ayahNumber && AudioService.shared.isPlaying {
            AudioService.shared.togglePlayPause()
            activePlayingAyahIndex = nil
        } else {
            activePlayingAyahIndex = ayah.ayahNumber
            let sStr = String(format: "%03d", ayah.surahNumber)
            let aStr = String(format: "%03d", ayah.ayahNumber)
            
            // Construct verified EveryAyah MP3 CDN URL
            if let url = URL(string: "https://everyayah.com/data/Alafasy_128kbps/\(sStr)\(aStr).mp3") {
                AudioService.shared.playQuranAudio(
                    surahName: "Surah \(surah.nameEnglish) (\(ayah.ayahNumber))",
                    reciterName: "Mishary Rashid Al-Afasy",
                    audioURL: url,
                    ayahNumber: ayah.ayahNumber
                )
            }
        }
    }
}
