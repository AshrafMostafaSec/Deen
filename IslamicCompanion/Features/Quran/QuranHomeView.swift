import SwiftUI

public struct QuranHomeView: View {
    @State private var viewModel = QuranViewModel()
    
    public init() {}
    
    public var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: AppSpacing.spaceLg) {
                // Header & Search
                headerAndSearchSection
                
                // Last Read Bookmark Hero Card
                lastReadHeroCard
                
                // Segmented Filter Tabs (Surahs / Juz / Bookmarks)
                filterTabsSection
                
                // Featured Recitation Card
                featuredAudioCard
                
                // Surah Index List
                surahsListSection
            }
            .padding(.horizontal, AppSpacing.margin)
            .padding(.top, AppSpacing.spaceSm)
            .padding(.bottom, 120)
        }
        .background(AppColor.background.ignoresSafeArea())
    }
    
    // MARK: - Sections
    
    private var headerAndSearchSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.spaceSm) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("The Holy Quran")
                        .font(AppFont.interface(size: 22, weight: .bold))
                        .foregroundColor(AppColor.onSurface)
                    Text("القرآن الكريم • مصحف المدينة المنورة")
                        .font(AppFont.arabicHeading(size: 13))
                        .foregroundColor(AppColor.secondary)
                }
                
                Spacer()
                
                Button {
                    // Reciter selection sheet
                } label: {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 15))
                        .foregroundColor(AppColor.primary)
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(AppColor.surfaceContainerHigh))
                }
                .buttonStyle(.plain)
            }
            
            // Search Bar
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(AppColor.outline)
                    .font(.system(size: 15))
                
                TextField("Search Surah name or number...", text: $viewModel.searchText)
                    .font(AppFont.interface(size: 14))
                    .foregroundColor(AppColor.onSurface)
                
                if !viewModel.searchText.isEmpty {
                    Button {
                        viewModel.searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppColor.outline)
                            .font(.system(size: 14))
                    }
                }
            }
            .padding(.horizontal, AppSpacing.spaceMd)
            .padding(.vertical, 10)
            .background(AppColor.surfaceContainerLow)
            .clipShape(Capsule())
            .overlay {
                Capsule()
                    .strokeBorder(AppColor.hairlineBorder, lineWidth: 1)
            }
        }
        .padding(.top, 8)
    }
    
    private var lastReadHeroCard: some View {
        VStack(spacing: AppSpacing.spaceMd) {
            HStack {
                HStack(spacing: 5) {
                    Image(systemName: "bookmark.fill")
                        .foregroundColor(AppColor.tertiary)
                        .font(.system(size: 12))
                    Text("Last Reading Position • 2 hours ago")
                        .font(AppFont.interfaceLabel(size: 12))
                        .foregroundColor(AppColor.tertiary)
                }
                
                Spacer()
                
                Text("\(viewModel.overallProgressPercentage)% Complete")
                    .font(AppFont.technicalMetric(size: 11, weight: .bold))
                    .foregroundColor(AppColor.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(AppColor.primaryContainer.opacity(0.4))
                    .clipShape(Capsule())
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Text(viewModel.lastReadSurah)
                            .font(AppFont.interface(size: 20, weight: .bold))
                            .foregroundColor(AppColor.onSurface)
                        Text(viewModel.lastReadSurahArabic)
                            .font(AppFont.arabicHeading(size: 16))
                            .foregroundColor(AppColor.secondary)
                    }
                    
                    Text("Page \(viewModel.lastReadPage) • Juz \(viewModel.lastReadJuz) • Ayah \(viewModel.lastReadAyah)")
                        .font(AppFont.interface(size: 12))
                        .foregroundColor(AppColor.onSurfaceVariant)
                }
                
                Spacer()
                
                Button {
                    // Open reader
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "book.fill")
                            .font(.system(size: 12))
                        Text("Resume")
                            .font(AppFont.interfaceLabel(size: 13, weight: .semibold))
                    }
                    .foregroundColor(AppColor.onPrimary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(AppColor.primary))
                }
                .buttonStyle(.plain)
            }
            
            // Progress Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AppColor.surfaceContainerLowest)
                        .frame(height: 6)
                    
                    Capsule()
                        .fill(AppColor.primary)
                        .frame(width: geo.size.width * CGFloat(viewModel.overallProgressPercentage) / 100.0, height: 6)
                }
            }
            .frame(height: 6)
        }
        .padding(AppSpacing.spaceLg)
        .astrolabeGlass(cornerRadius: AppRadius.large, isElevated: true)
    }
    
    private var filterTabsSection: some View {
        HStack(spacing: 8) {
            ForEach(QuranTabFilter.allCases) { filter in
                let isSelected = viewModel.selectedFilter == filter
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                        viewModel.selectedFilter = filter
                    }
                } label: {
                    Text("\(filter.rawValue) (\(filter.arabicName))")
                        .font(AppFont.interfaceLabel(size: 12, weight: isSelected ? .semibold : .regular))
                        .foregroundColor(isSelected ? AppColor.onPrimary : AppColor.secondary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background {
                            Capsule()
                                .fill(isSelected ? AppColor.primary : AppColor.surfaceContainerLow)
                        }
                        .overlay {
                            if !isSelected {
                                Capsule()
                                    .strokeBorder(AppColor.hairlineBorder, lineWidth: 1)
                            }
                        }
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
    }
    
    private var featuredAudioCard: some View {
        HStack(spacing: AppSpacing.spaceMd) {
            ZStack {
                Circle()
                    .fill(AppColor.primaryContainer.opacity(0.7))
                    .frame(width: 44, height: 44)
                Image(systemName: "waveform")
                    .font(.system(size: 18))
                    .foregroundColor(AppColor.primary)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.featuredReciterName)
                    .font(AppFont.interfaceLabel(size: 13, weight: .semibold))
                    .foregroundColor(AppColor.onSurface)
                Text("\(viewModel.featuredSurahName) • HQ Studio Recitation")
                    .font(AppFont.interface(size: 11))
                    .foregroundColor(AppColor.onSurfaceVariant)
            }
            
            Spacer()
            
            Button {
                viewModel.toggleFeaturedAudio()
            } label: {
                ZStack {
                    Circle()
                        .fill(AppColor.primary)
                        .frame(width: 36, height: 36)
                    Image(systemName: viewModel.isFeaturedPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppColor.onPrimary)
                }
            }
            .buttonStyle(.plain)
        }
        .padding(AppSpacing.spaceMd)
        .astrolabeGlass(cornerRadius: AppRadius.card)
    }
    
    private var surahsListSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.spaceSm) {
            HStack {
                Text("Index of Surahs")
                    .font(AppFont.interfaceLabel(size: 15, weight: .semibold))
                    .foregroundColor(AppColor.onSurface)
                Spacer()
                Text("114 Surahs")
                    .font(AppFont.technicalMetric(size: 12))
                    .foregroundColor(AppColor.secondary)
            }
            
            LazyVStack(spacing: 8) {
                ForEach(viewModel.filteredSurahs) { surah in
                    HStack(spacing: AppSpacing.spaceMd) {
                        // Number plate
                        ZStack {
                            Circle()
                                .fill(AppColor.surfaceContainerHighest)
                                .frame(width: 36, height: 36)
                            Text("\(surah.number)")
                                .font(AppFont.technicalMetric(size: 13, weight: .semibold))
                                .foregroundColor(AppColor.primary)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(surah.nameEnglish)
                                .font(AppFont.interfaceLabel(size: 15, weight: .semibold))
                                .foregroundColor(AppColor.onSurface)
                            
                            HStack(spacing: 4) {
                                Text("\(surah.totalAyahs) Ayahs")
                                    .font(AppFont.interface(size: 11))
                                Text("•")
                                    .font(.system(size: 8))
                                Text(surah.revelationType.rawValue)
                                    .font(AppFont.interface(size: 11))
                                Text("•")
                                    .font(.system(size: 8))
                                Text("Page \(surah.startPage)")
                                    .font(AppFont.interface(size: 11))
                            }
                            .foregroundColor(AppColor.onSurfaceVariant)
                        }
                        
                        Spacer()
                        
                        Text(surah.nameArabic)
                            .font(AppFont.quranScripture(size: 19))
                            .foregroundColor(AppColor.secondary)
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(AppColor.outline)
                    }
                    .padding(.horizontal, AppSpacing.spaceMd)
                    .padding(.vertical, 12)
                    .background {
                        RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                            .fill(AppColor.surfaceContainerLow)
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                            .strokeBorder(AppColor.hairlineBorder, lineWidth: 1)
                    }
                }
            }
        }
    }
}
