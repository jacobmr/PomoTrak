import Foundation
import Combine
import AppKit

@MainActor
final class TimerManager: ObservableObject {
    static let shared = TimerManager()
    
    @Published private(set) var currentSession: Session?
    @Published private(set) var timeRemaining: TimeInterval = 0
    @Published private(set) var timerState: TimerState = .stopped
    
    private var timer: Timer?
    private var activity: NSObjectProtocol?
    
    var isRunning: Bool {
        timerState == .running
    }
    
    var isPaused: Bool {
        timerState == .paused
    }
    
    init() {}
    
    @MainActor
    func startNewSession(projectId: UUID? = nil, description: String, taskDescription: String = "", plannedDuration: TimeInterval = 1500, isBillable: Bool = true, tags: [String] = []) async {
        // End any existing session
        await endCurrentSession()
        
        // Create and start new session
        currentSession = Session(
            projectId: projectId,
            description: description,
            taskDescription: taskDescription,
            plannedDuration: plannedDuration,
            isBillable: isBillable,
            tags: tags
        )
        
        timeRemaining = plannedDuration
        startTimer()
        
        // Set up app nap prevention
        activity = ProcessInfo.processInfo.beginActivity(
            options: [.userInitiated, .idleSystemSleepDisabled, .automaticTerminationDisabled],
            reason: "Tracking work session"
        )
    }
    
    @MainActor
    func togglePause() {
        guard var session = currentSession else { return }
        
        if timerState == .running {
            pauseTimer()
            session.pauseTime = Date()
            session.sessionState = .paused
            currentSession = session
        } else if timerState == .paused {
            if let pauseTime = session.pauseTime {
                // Adjust start time for the pause duration
                let pauseDuration = Date().timeIntervalSince(pauseTime)
                session.startTime = session.startTime.addingTimeInterval(pauseDuration)
            }
            session.pauseTime = nil
            session.sessionState = .started
            currentSession = session
            startTimer()
        }
    }
    
    @MainActor
    func endCurrentSession() async {
        timer?.invalidate()
        timer = nil
        
        if var session = currentSession {
            session.endTime = Date()
            session.sessionState = .completed
            currentSession = session
            
            // Save the completed session
            Task {
                await saveCurrentSession()
                
                await MainActor.run {
                    self.currentSession = nil
                    self.timerState = .stopped
                    
                    // End app nap prevention
                    if let activity = self.activity {
                        ProcessInfo.processInfo.endActivity(activity)
                        self.activity = nil
                    }
                }
            }
        } else {
            timerState = .stopped
        }
    }
    
    private func saveCurrentSession() async {
        guard let session = currentSession else { return }
        var sessions = await DataManager.shared.loadSessions()
        sessions.append(session)
        await DataManager.shared.saveSessions(sessions)
    }
    
    private func startTimer() {
        timer?.invalidate()
        timerState = .running
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    await self.endCurrentSession()
                    NSSound.beep()
                }
            }
        }
    }
    
    private func pauseTimer() {
        timer?.invalidate()
        timer = nil
        timerState = .paused
    }
    
    var formattedTimeRemaining: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

enum TimerState {
    case stopped
    case running
    case paused
}
