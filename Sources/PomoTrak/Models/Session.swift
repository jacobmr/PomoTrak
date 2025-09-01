import Foundation

enum SessionState: String, Codable, CaseIterable {
    case started = "Started"
    case paused = "Paused"
    case completed = "Completed"
}

struct Session: Identifiable, Codable, Hashable {
    let id: UUID
    var projectId: UUID?
    var startTime: Date
    var endTime: Date?
    var pauseTime: Date?
    var description: String
    var taskDescription: String
    let plannedDuration: TimeInterval // in seconds
    var sessionState: SessionState
    var isBillable: Bool
    var tags: [String]
    
    init(id: UUID = UUID(),
         projectId: UUID? = nil,
         description: String,
         taskDescription: String = "",
         plannedDuration: TimeInterval = 1500, // 25 minutes by default
         isBillable: Bool = true,
         tags: [String] = []) {
        self.id = id
        self.projectId = projectId
        self.startTime = Date()
        self.description = description
        self.taskDescription = taskDescription
        self.plannedDuration = plannedDuration
        self.sessionState = .started
        self.isBillable = isBillable
        self.tags = tags
    }
    
    var duration: TimeInterval {
        if let endTime = endTime {
            return endTime.timeIntervalSince(startTime)
        } else if let pauseTime = pauseTime {
            return pauseTime.timeIntervalSince(startTime)
        }
        return Date().timeIntervalSince(startTime)
    }
    
    var formattedDuration: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: duration) ?? "0s"
    }
    
    var formattedStartTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: startTime)
    }
}
