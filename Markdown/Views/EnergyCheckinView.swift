import SwiftUI

struct EnergyCheckinView: View {
    @Binding var selectedEnergy: EnergyLevel?

    var body: some View {
        VStack {
            Text("How's your energy right now?")
                .font(.headline)
            
            Picker("Current Energy", selection: $selectedEnergy) {
                Text("Select Energy Level").tag(EnergyLevel?.none)
                
                ForEach(EnergyLevel.allCases, id: \.self) { level in
                    // ✅ We use the emoji in the Text and the SF Symbol name for the systemImage
                    Label("\(energyEmoji(for: level)) \(level.rawValue)", systemImage: energyIcon(for: level))
                        .tag(EnergyLevel?.some(level))
                }
            }
            .pickerStyle(.menu)
//            .tint(.primary)
            .buttonStyle(.borderedProminent)
        }
    }
    
    // This helper function now returns valid SF Symbol names.
    private func energyIcon(for level: EnergyLevel) -> String {
        switch level {
        case .deep:
            return "bolt.fill" // A lightning bolt for high energy
        case .shallow:
            return "brain.head.profile" // A brain for medium energy/focus
        case .recharge:
            return "battery.100.bolt" // A battery for recharge
        }
    }

    // A new helper to provide the emoji for the label text.
    private func energyEmoji(for level: EnergyLevel) -> String {
//        switch level {
//        case .deep:
//            return ""
//        case .shallow:
//            return "🧠"
//        case .recharge:
//            return "🧘"
//        }
        return ""
    }
}
