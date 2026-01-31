import SwiftUI
import SwiftData

struct PrayerHistoryView: View {
    @Query(sort: \PrayerEvent.timestamp, order: .reverse) private var events: [PrayerEvent]

    var body: some View {
        ZStack {
            SelahBackground()
            List(events) { event in
                VStack(alignment: .leading, spacing: 6) {
                    SelahTag(event.mood.capitalized, tint: SelahPalette.mint)
                    Text(event.timestamp.formatted(date: .abbreviated, time: .shortened))
                        .font(.selahBody(15))
                        .foregroundStyle(SelahPalette.ink.opacity(0.7))
                    Text(event.templateId)
                        .font(.selahLabel(12))
                        .foregroundStyle(SelahPalette.ink.opacity(0.5))
                }
                .padding(.vertical, 6)
                .listRowBackground(SelahRowBackground())
            }
            .scrollContentBackground(.hidden)
            .listStyle(.insetGrouped)
        }
        .navigationTitle("Prayer History")
    }
}
