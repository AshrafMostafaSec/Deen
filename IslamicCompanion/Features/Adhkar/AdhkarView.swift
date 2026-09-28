import SwiftUI

public struct AdhkarView: View {
    @State private var viewModel = AdhkarViewModel()
    
    public init() {}
    
    public var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: AppSpacing.spaceLg) {
                // Header & Daily Progress Overview
                overviewProgressSection
                
                // Four Primary Adhkar Cards Grid
                categoriesGridSection
                
                // Focused Interactive Dhikr / Tasbeeh Pad
                focusedTasbeehSection
                
                // Spiritual Ayah
                ayahSection
            }
            .padding(.horizontal, AppSpacing.margin)
            .padding(.top, AppSpacing.spaceSm)
            .padding(.bottom, 120)
        }
        .background(AppColor.background.ignoresSafeArea())
    }
    
    // MARK: - Sections
    
    private var overviewProgressSection: some View {
        VStack(spacing: AppSpacing.spaceMd) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Daily Adhkar & Fortress")
                        .font(AppFont.interface(size: 20, weight: .bold))
                        .foregroundColor(AppColor.onSurface)
                    Text("حصن المسلم • الورد اليومي للسكينة")
                        .font(AppFont.arabicHeading(size: 13))
                        .foregroundColor(AppColor.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 5) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 13))
                    Text("\(viewModel.completionPercentage)% Done")
                        .font(AppFont.technicalMetric(size: 12, weight: .bold))
                }
                .foregroundColor(AppColor.primary)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(AppColor.primaryContainer.opacity(0.4))
                .clipShape(Capsule())
            }
            
            VStack(spacing: 6) {
                HStack {
                    Text("\(viewModel.totalCompleted) of \(viewModel.totalCount) items completed today")
                        .font(AppFont.interfaceLabel(size: 12))
                        .foregroundColor(AppColor.primary)
                    Spacer()
                    Text("Remaining: \(viewModel.totalCount - viewModel.totalCompleted)")
                        .font(AppFont.interfaceLabel(size: 11))
                        .foregroundColor(AppColor.onSurfaceVariant)
                }
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(AppColor.surfaceContainerLowest)
                            .frame(height: 7)
                        
                        Capsule()
                            .fill(AppColor.primary)
                            .frame(width: geo.size.width * CGFloat(viewModel.completionPercentage) / 100.0, height: 7)
                    }
                }
                .frame(height: 7)
            }
        }
        .padding(AppSpacing.spaceLg)
        .astrolabeGlass(cornerRadius: AppRadius.large, isElevated: true)
    }
    
    private var categoriesGridSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.spaceSm) {
            HStack {
                Text("Adhkar Collections")
                    .font(AppFont.interfaceLabel(size: 15, weight: .semibold))
                    .foregroundColor(AppColor.onSurface)
                Spacer()
                Text("View All")
                    .font(AppFont.interfaceLabel(size: 12))
                    .foregroundColor(AppColor.secondary)
            }
            
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                ForEach(viewModel.categories) { cat in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(cat.isReady ? AppColor.primaryContainer : AppColor.surfaceContainerHighest)
                                    .frame(width: 36, height: 36)
                                Image(systemName: cat.iconName)
                                    .font(.system(size: 16))
                                    .foregroundColor(cat.isReady ? AppColor.primary : AppColor.secondary)
                            }
                            Spacer()
                            if cat.isReady {
                                Text("NOW")
                                    .font(AppFont.technicalMetric(size: 9, weight: .bold))
                                    .foregroundColor(AppColor.primary)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(AppColor.primaryContainer.opacity(0.5))
                                    .clipShape(Capsule())
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(cat.titleEnglish)
                                .font(AppFont.interfaceLabel(size: 14, weight: .semibold))
                                .foregroundColor(AppColor.onSurface)
                            Text(cat.titleArabic)
                                .font(AppFont.arabicHeading(size: 13))
                                .foregroundColor(AppColor.secondary)
                        }
                        
                        Text(cat.countText)
                            .font(AppFont.interface(size: 10))
                            .foregroundColor(AppColor.onSurfaceVariant)
                            .lineLimit(1)
                    }
                    .padding(AppSpacing.spaceMd)
                    .background {
                        RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                            .fill(AppColor.surfaceContainerLow)
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                            .strokeBorder(cat.isReady ? AppColor.primary.opacity(0.4) : AppColor.hairlineBorder, lineWidth: 1)
                    }
                }
            }
        }
    }
    
    private var focusedTasbeehSection: some View {
        VStack(spacing: AppSpacing.spaceMd) {
            // Header
            HStack {
                HStack(spacing: 5) {
                    Image(systemName: "hand.tap.fill")
                        .foregroundColor(AppColor.primary)
                        .font(.system(size: 13))
                    Text("Focused Dhikr & Tasbeeh")
                        .font(AppFont.interfaceLabel(size: 13, weight: .semibold))
                        .foregroundColor(AppColor.onSurface)
                }
                
                Spacer()
                
                // Haptic Toggle Button
                Button {
                    viewModel.toggleHaptic()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: viewModel.isHapticEnabled ? "iphone.radiowaves.left.and.right" : "iphone.slash")
                            .font(.system(size: 12))
                        Text(viewModel.isHapticEnabled ? "Haptic On" : "Haptic Off")
                            .font(AppFont.interfaceLabel(size: 11))
                    }
                    .foregroundColor(viewModel.isHapticEnabled ? AppColor.primary : AppColor.outline)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppColor.surfaceContainerHigh)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                
                // Reset Button
                Button {
                    viewModel.resetTasbeeh()
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(AppColor.secondary)
                        .frame(width: 28, height: 28)
                        .background(Circle().fill(AppColor.surfaceContainerHigh))
                }
                .buttonStyle(.plain)
            }
            
            // Dhikr text
            VStack(spacing: 4) {
                Text(viewModel.currentDhikrText)
                    .font(AppFont.quranScripture(size: 20))
                    .foregroundColor(AppColor.onSurface)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
                
                Text(viewModel.currentDhikrVirtue)
                    .font(AppFont.interface(size: 11))
                    .foregroundColor(AppColor.tertiary)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, 6)
            
            // Circular Interactive Pad
            ZStack {
                Circle()
                    .strokeBorder(AppColor.surfaceContainerLowest, lineWidth: 10)
                    .frame(width: 170, height: 170)
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(viewModel.currentTasbeehCount) / CGFloat(viewModel.maxTasbeehCount))
                    .stroke(
                        LinearGradient(
                            colors: [AppColor.primaryContainer, AppColor.primary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 170, height: 170)
                    .animation(.spring(response: 0.25, dampingFraction: 0.7), value: viewModel.currentTasbeehCount)
                
                VStack(spacing: 2) {
                    Text("\(viewModel.currentTasbeehCount)")
                        .font(AppFont.celestialDisplay(size: 46))
                        .foregroundColor(AppColor.primary)
                    
                    Text("of \(viewModel.maxTasbeehCount)")
                        .font(AppFont.technicalMetric(size: 12))
                        .foregroundColor(AppColor.secondary)
                    
                    Text("Tap to Count")
                        .font(AppFont.interfaceLabel(size: 10))
                        .foregroundColor(AppColor.onSurfaceVariant)
                        .padding(.top, 2)
                }
            }
            .padding(.vertical, AppSpacing.spaceSm)
            .contentShape(Circle())
            .onTapGesture {
                viewModel.incrementTasbeeh()
            }
        }
        .padding(AppSpacing.spaceLg)
        .astrolabeGlass(cornerRadius: AppRadius.large, isElevated: true)
    }
    
    private var ayahSection: some View {
        VStack(spacing: 4) {
            Text("« أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ »")
                .font(AppFont.quranScripture(size: 19))
                .foregroundColor(AppColor.tertiary)
                .multilineTextAlignment(.center)
            
            Text("Surah Ar-Ra'd • Ayah 28")
                .font(AppFont.interface(size: 11))
                .foregroundColor(AppColor.onSurfaceVariant)
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.spaceMd)
        .astrolabeGlass(cornerRadius: AppRadius.card)
    }
}
