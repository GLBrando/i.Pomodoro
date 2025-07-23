import SwiftUI
import UserNotifications
import AppKit

// Classe per condividere lo stato del timer
class TimerState: ObservableObject {
    @Published var timeRemaining = 25 * 60
    @Published var isRunning = false
    @Published var currentMode: PomodoroMode = .work
    
    enum PomodoroMode: Equatable {
        case work, shortBreak, longBreak
        
        var title: String {
            switch self {
            case .work: return "🍅 Lavoro"
            case .shortBreak: return "☕ Pausa Breve"
            case .longBreak: return "🛋️ Pausa Lunga"
            }
        }
        
        var color: Color {
            switch self {
            case .work: return .red
            case .shortBreak: return .green
            case .longBreak: return .blue
            }
        }
    }
    
    func formatTime() -> String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct ContentView: View {
    @EnvironmentObject var timerState: TimerState
    @State private var timer: Timer?
    @AppStorage("workDuration") private var workDuration = 25
    @AppStorage("shortBreakDuration") private var shortBreakDuration = 5
    @AppStorage("longBreakDuration") private var longBreakDuration = 15
    @State private var showSettings = false
    @State private var selectedSound = "Ping"
    @State private var totalTime = 25 * 60
    
    var body: some View {
        ZStack {
            // Sfondo dark senza gradiente
            Color(red: 0.12, green: 0.12, blue: 0.15)
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Header moderno
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(timerState.currentMode.title)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [timerState.currentMode.color, timerState.currentMode.color.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("Tecnica Pomodoro")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .fontWeight(.medium)
                    }
                    
                    Spacer()
                    
                    Button(action: { showSettings.toggle() }) {
                        Image(systemName: "gear")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [timerState.currentMode.color, timerState.currentMode.color.opacity(0.8)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .shadow(color: timerState.currentMode.color.opacity(0.4), radius: 8, x: 0, y: 4)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .scaleEffect(showSettings ? 0.95 : 1.0)
                    .animation(.spring(response: 0.3), value: showSettings)
                }
                .padding(.horizontal, 20)
                
                // Timer circolare moderno dark
                ZStack {
                    // Sfondo del cerchio con effetto glassmorphism dark
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.05),
                                    Color.black.opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.15), Color.clear],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                        .shadow(color: .black.opacity(0.4), radius: 25, x: 0, y: 12)
                        .shadow(color: timerState.currentMode.color.opacity(0.2), radius: 15, x: 0, y: 0)
                    
                    // Traccia di sfondo
                    Circle()
                        .stroke(
                            timerState.currentMode.color.opacity(0.2),
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .frame(width: 220, height: 220)
                    
                    // Progresso animato
                    Circle()
                        .trim(from: 0.0, to: CGFloat(min(Double(totalTime - timerState.timeRemaining) / Double(totalTime), 1.0)))
                        .stroke(
                            LinearGradient(
                                colors: [timerState.currentMode.color, timerState.currentMode.color.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .frame(width: 220, height: 220)
                        .rotationEffect(Angle(degrees: 270.0))
                        .animation(.easeInOut(duration: 1.0), value: timerState.timeRemaining)
                        .shadow(color: timerState.currentMode.color.opacity(0.5), radius: 8, x: 0, y: 0)
                    
                    // Tempo centrale
                    VStack(spacing: 8) {
                        Text(timerState.formatTime())
                            .font(.system(size: 52, weight: .ultraLight, design: .monospaced))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: timerState.isRunning ? [timerState.currentMode.color, timerState.currentMode.color.opacity(0.7)] : [.white, .white.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .scaleEffect(timerState.isRunning ? 1.05 : 1.0)
                            .animation(.easeInOut(duration: 0.3), value: timerState.isRunning)
                            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                        
                        Text(timerState.isRunning ? "In corso..." : "Pronto")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                            .fontWeight(.medium)
                            .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                    }
                }
                .frame(width: 260, height: 260)
                
                // Controlli principali moderni
                HStack(spacing: 20) {
                    ModernButton(
                        title: "▶️ Start",
                        color: .green,
                        isDisabled: timerState.isRunning,
                        action: start
                    )
                    
                    ModernButton(
                        title: "⏸️ Pause",
                        color: .orange,
                        isDisabled: !timerState.isRunning,
                        action: pause
                    )
                    
                    ModernButton(
                        title: "🔄 Reset",
                        color: .red,
                        isDisabled: false,
                        action: reset
                    )
                }
                
                // Selezione modalità moderna
                VStack(spacing: 15) {
                    Text("Modalità")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 15) {
                        ModeButton(
                            title: "🍅 Lavoro",
                            mode: TimerState.PomodoroMode.work,
                            currentMode: timerState.currentMode,
                            isDisabled: timerState.isRunning,
                            action: { switchToMode(.work) }
                        )
                        
                        ModeButton(
                            title: "☕ Breve",
                            mode: TimerState.PomodoroMode.shortBreak,
                            currentMode: timerState.currentMode,
                            isDisabled: timerState.isRunning,
                            action: { switchToMode(.shortBreak) }
                        )
                        
                        ModeButton(
                            title: "🛋️ Lunga",
                            mode: TimerState.PomodoroMode.longBreak,
                            currentMode: timerState.currentMode,
                            isDisabled: timerState.isRunning,
                            action: { switchToMode(.longBreak) }
                        )
                    }
                }
            }
            .padding(40)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(workDuration: $workDuration, 
                        shortBreakDuration: $shortBreakDuration, 
                        longBreakDuration: $longBreakDuration,
                        selectedSound: $selectedSound,
                        availableSounds: getAvailableSounds())
        }
        .onAppear {
            requestNotificationPermission()
            updateTimeRemaining()
        }
    }
    
    func start() {
        timerState.isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timerState.timeRemaining > 0 {
                timerState.timeRemaining -= 1
            } else {
                pause()
                sendNotification()
            }
        }
    }
    
    func pause() {
        timerState.isRunning = false
        timer?.invalidate()
    }
    
    func reset() {
        pause()
        updateTimeRemaining()
    }
    
    func switchToMode(_ mode: TimerState.PomodoroMode) {
        timerState.currentMode = mode
        updateTimeRemaining()
    }
    
    func updateTimeRemaining() {
        switch timerState.currentMode {
        case .work:
            timerState.timeRemaining = workDuration * 60
            totalTime = workDuration * 60
        case .shortBreak:
            timerState.timeRemaining = shortBreakDuration * 60
            totalTime = shortBreakDuration * 60
        case .longBreak:
            timerState.timeRemaining = longBreakDuration * 60
            totalTime = longBreakDuration * 60
        }
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }
    
    func sendNotification() {
        let content = UNMutableNotificationContent()
        content.title = timerState.currentMode.title + " Completato!"
        content.body = getNotificationMessage()
        
        // Usa il suono selezionato
        let soundName = getSoundFileName(for: selectedSound)
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: soundName))
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
        
        // Suono di sistema aggiuntivo se selezionato
        if selectedSound == "Beep" {
            NSSound.beep()
        } else {
            // Riproduci il suono personalizzato
            if let sound = NSSound(named: soundName) {
                sound.play()
            } else {
                NSSound.beep() // Fallback
            }
        }
    }
    
    func getSoundFileName(for soundName: String) -> String {
        switch soundName {
        case "Ping":
            return "Ping.aiff"
        case "Glass":
            return "Glass.aiff"
        case "Hero":
            return "Hero.aiff"
        case "Submarine":
            return "Submarine.aiff"
        case "Blow":
            return "Blow.aiff"
        case "Bottle":
            return "Bottle.aiff"
        case "Frog":
            return "Frog.aiff"
        case "Funk":
            return "Funk.aiff"
        case "Pop":
            return "Pop.aiff"
        case "Purr":
            return "Purr.aiff"
        case "Sosumi":
            return "Sosumi.aiff"
        case "Tink":
            return "Tink.aiff"
        case "Beep":
            return "Beep" // Speciale per NSSound.beep()
        default:
            return "Ping.aiff"
        }
    }
    
    func getAvailableSounds() -> [String] {
        return ["Ping", "Glass", "Hero", "Submarine", "Blow", "Bottle", "Frog", "Funk", "Pop", "Purr", "Sosumi", "Tink", "Beep"]
    }
    
    func getNotificationMessage() -> String {
        switch timerState.currentMode {
        case .work:
            return "Tempo per una pausa! 🎉"
        case .shortBreak, .longBreak:
            return "Pausa finita, torna al lavoro! 💪"
        }
    }
    

}

// Componente ModernButton
struct ModernButton: View {
    let title: String
    let color: Color
    let isDisabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(isDisabled ? .white.opacity(0.4) : .white)
                .frame(width: 100, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: isDisabled ? 
                                    [Color.white.opacity(0.1), Color.black.opacity(0.2)] : 
                                    [color, color.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.2), Color.clear],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                        .shadow(
                            color: isDisabled ? .clear : color.opacity(0.4),
                            radius: 8,
                            x: 0,
                            y: 4
                        )
                )
        }
        .disabled(isDisabled)
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isDisabled ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isDisabled)
    }
}

// Componente ModeButton
struct ModeButton: View {
    let title: String
    let mode: TimerState.PomodoroMode
    let currentMode: TimerState.PomodoroMode
    let isDisabled: Bool
    let action: () -> Void
    
    private var isSelected: Bool {
        mode == currentMode
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(isSelected ? .white : (isDisabled ? .white.opacity(0.3) : .white.opacity(0.8)))
                .frame(width: 90, height: 36)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(
                            isSelected ?
                                LinearGradient(
                                    colors: [mode.color, mode.color.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) :
                                LinearGradient(
                                    colors: isDisabled ? 
                                        [Color.white.opacity(0.05), Color.black.opacity(0.2)] :
                                        [Color.white.opacity(0.1), Color.black.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(
                                    LinearGradient(
                                        colors: isSelected ? 
                                            [mode.color.opacity(0.8), mode.color.opacity(0.4)] :
                                            [Color.white.opacity(0.2), Color.clear],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                        .shadow(
                            color: isSelected ? mode.color.opacity(0.4) : .clear,
                            radius: 10,
                            x: 0,
                            y: 5
                        )
                )
        }
        .disabled(isDisabled)
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.05 : (isDisabled ? 0.95 : 1.0))
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        .animation(.easeInOut(duration: 0.2), value: isDisabled)
    }
}

struct SettingsView: View {
    @Binding var workDuration: Int
    @Binding var shortBreakDuration: Int
    @Binding var longBreakDuration: Int
    @Binding var selectedSound: String
    let availableSounds: [String]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header in stile Apple
            HStack {
                Text("Impostazioni")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button("Fatto") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.regular)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(.regularMaterial, in: Rectangle())
            
            // Content scrollabile
            ScrollView {
                LazyVStack(spacing: 0, pinnedViews: []) {
                    // Sezione Timer
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "timer")
                                .foregroundColor(.blue)
                                .font(.title3)
                            Text("Durata Sessioni")
                                .font(.headline)
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        VStack(spacing: 12) {
                            AppleSettingRow(icon: "🍅", title: "Lavoro", value: $workDuration, range: 1...60, unit: "min", color: .red)
                            AppleSettingRow(icon: "☕", title: "Pausa Breve", value: $shortBreakDuration, range: 1...30, unit: "min", color: .green)
                            AppleSettingRow(icon: "🛋️", title: "Pausa Lunga", value: $longBreakDuration, range: 1...60, unit: "min", color: .blue)
                        }
                        .padding(.horizontal, 20)
                    }
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    // Sezione Audio
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "speaker.wave.2")
                                .foregroundColor(.purple)
                                .font(.title3)
                            Text("Audio")
                                .font(.headline)
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        HStack {
                            Text("Suono notifica")
                                .font(.body)
                            
                            Spacer()
                            
                            Menu {
                                ForEach(availableSounds, id: \.self) { sound in
                                    Button(action: {
                                        selectedSound = sound
                                        testSound(sound)
                                    }) {
                                        HStack {
                                            Text(sound)
                                            if selectedSound == sound {
                                                Image(systemName: "checkmark")
                                                    .foregroundColor(.blue)
                                            }
                                        }
                                    }
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Text(selectedSound)
                                        .foregroundColor(.secondary)
                                    Image(systemName: "chevron.up.chevron.down")
                                        .foregroundColor(.secondary)
                                        .font(.caption2)
                                }
                            }
                            .menuStyle(.borderlessButton)
                            
                            Button(action: {
                                testSound(selectedSound)
                            }) {
                                Image(systemName: "play.circle.fill")
                                    .foregroundColor(.purple)
                                    .font(.title3)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    
                    // Sezione Informazioni
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                                .font(.title3)
                            Text("Informazioni")
                                .font(.headline)
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("🎯 App Pomodoro per macOS")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text("La Tecnica Pomodoro prevede sessioni di 25 minuti di lavoro seguite da pause di 5 minuti per massimizzare la produttività.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Text("Benefici:")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .padding(.top, 8)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("• Migliora concentrazione e focus")
                                Text("• Riduce la procrastinazione")
                                Text("• Aumenta la produttività")
                                Text("• Previene il burnout")
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                            
                            Text("Come usare:")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .padding(.top, 8)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("1. Scegli la modalità")
                                Text("2. Premi Start")
                                Text("3. Lavora fino alla notifica")
                                Text("4. Fai una pausa")
                                Text("5. Ripeti il ciclo")
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 20)
                }
            }
        }
        .frame(width: 600, height: 650)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
    }
    
    func testSound(_ soundName: String) {
        if soundName == "Beep" {
            NSSound.beep()
        } else {
            let fileName = getSoundFileName(for: soundName)
            if let sound = NSSound(named: fileName) {
                sound.play()
            } else {
                NSSound.beep()
            }
        }
    }
    
    func getSoundFileName(for soundName: String) -> String {
        switch soundName {
        case "Ping":
            return "Ping.aiff"
        case "Glass":
            return "Glass.aiff"
        case "Hero":
            return "Hero.aiff"
        case "Submarine":
            return "Submarine.aiff"
        case "Blow":
            return "Blow.aiff"
        case "Bottle":
            return "Bottle.aiff"
        case "Frog":
            return "Frog.aiff"
        case "Funk":
            return "Funk.aiff"
        case "Pop":
            return "Pop.aiff"
        case "Purr":
            return "Purr.aiff"
        case "Sosumi":
            return "Sosumi.aiff"
        case "Tink":
            return "Tink.aiff"
        case "Beep":
            return "Beep"
        default:
            return "Ping.aiff"
        }
    }
}

struct AppleSettingRow: View {
    let icon: String
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    let unit: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            // Icona con sfondo colorato in stile Apple
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 32, height: 32)
                
                Text(icon)
                    .font(.body)
            }
            
            Text(title)
                .font(.body)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Controlli in stile Apple
            HStack(spacing: 8) {
                Button(action: {
                    if value > range.lowerBound {
                        value -= 1
                    }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title3)
                        .foregroundColor(value <= range.lowerBound ? .secondary : color)
                }
                .disabled(value <= range.lowerBound)
                .buttonStyle(.plain)
                
                Text("\(value) \(unit)")
                    .font(.body.monospacedDigit())
                    .fontWeight(.medium)
                    .frame(minWidth: 60)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
                
                Button(action: {
                    if value < range.upperBound {
                        value += 1
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundColor(value >= range.upperBound ? .secondary : color)
                }
                .disabled(value >= range.upperBound)
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 10))
    }
}

struct SettingRow: View {
    let icon: String
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    let unit: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 20) {
            // Icona con sfondo colorato
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.2), color.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 45, height: 45)
                
                Text(icon)
                    .font(.title2)
            }
            
            Text(title)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
            
            // Controlli con design moderno
            HStack(spacing: 12) {
                Button(action: {
                    if value > range.lowerBound {
                        value -= 1
                    }
                }) {
                    Image(systemName: "minus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: value <= range.lowerBound ? [.gray.opacity(0.5)] : [color, color.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .shadow(color: color.opacity(0.3), radius: 2, x: 0, y: 1)
                }
                .disabled(value <= range.lowerBound)
                .buttonStyle(PlainButtonStyle())
                
                Text("\(value) \(unit)")
                    .font(.body.monospacedDigit())
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 70)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(color.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(color.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                
                Button(action: {
                    if value < range.upperBound {
                        value += 1
                    }
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: value >= range.upperBound ? [.gray.opacity(0.5)] : [color, color.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .shadow(color: color.opacity(0.3), radius: 2, x: 0, y: 1)
                }
                .disabled(value >= range.upperBound)
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.08), Color.black.opacity(0.15)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
        )
    }
}
