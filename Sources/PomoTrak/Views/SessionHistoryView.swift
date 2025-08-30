import SwiftUI

struct SessionHistoryView: View {
    @State private var sessions: [Session] = []
    @State private var selectedPeriod: TimePeriod = .week
    @State private var searchText = ""
    
    private var filteredSessions: [Session] {
        let filtered = sessions.filter { session in
            guard let endTime = session.endTime else { return false }
            
            let calendar = Calendar.current
            let now = Date()
            let components: DateComponents
            
            switch selectedPeriod {
            case .day:
                components = calendar.dateComponents([.day], from: endTime, to: now)
                return components.day == 0
            case .week:
                components = calendar.dateComponents([.weekOfYear], from: endTime, to: now)
                return components.weekOfYear == 0
            case .month:
                components = calendar.dateComponents([.month], from: endTime, to: now)
                return components.month == 0
            case .all:
                return true
            }
        }
        
        if !searchText.isEmpty {
            return filtered.filter {
                $0.description.localizedCaseInsensitiveContains(searchText) ||
                $0.taskDescription.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered
    }
    
    private var totalDuration: TimeInterval {
        filteredSessions.reduce(0) { $0 + $1.duration }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Session History")
                    .font(.headline)
                Spacer()
                Picker("", selection: $selectedPeriod) {
                    ForEach(TimePeriod.allCases, id: \.self) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
                .frame(width: 100)
                .pickerStyle(MenuPickerStyle())
            }
            .padding()
            
            // Search
            TextField("Search sessions...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            // Summary
            HStack {
                VStack(alignment: .leading) {
                    Text("\(filteredSessions.count) sessions")
                        .font(.subheadline)
                    Text(formatDuration(totalDuration))
                        .font(.headline)
                }
                Spacer()
                
                let billableHours = filteredSessions
                    .filter { $0.isBillable }
                    .reduce(0) { $0 + $1.duration }
                
                VStack(alignment: .trailing) {
                    Text("Billable")
                        .font(.subheadline)
                    Text(formatDuration(billableHours))
                        .font(.headline)
                        .foregroundColor(.green)
                }
            }
            .padding()
            
            Divider()
            
            // Session List
            List {
                ForEach(groupedSessions, id: \.key) { date, sessions in
                    Section(header: Text(date, style: .date)) {
                        ForEach(sessions) { session in
                            SessionRow(session: session)
                        }
                    }
                }
            }
            .listStyle(PlainListStyle())
        }
        .frame(width: 500, height: 500)
        .onAppear {
            loadSessions()
        }
    }
    
    private var groupedSessions: [(key: Date, value: [Session])] {
        let grouped = Dictionary(grouping: filteredSessions) { session in
            guard let endTime = session.endTime else { return Date() }
            return Calendar.current.startOfDay(for: endTime)
        }
        
        return grouped.sorted { $0.key > $1.key }
    }
    
    private func loadSessions() {
        Task {
            sessions = await DataManager.shared.loadSessions()
                .sorted { $0.startTime > $1.startTime }
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: duration) ?? "0m"
    }
}

struct SessionRow: View {
    let session: Session
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(session.description)
                    .font(.headline)
                Spacer()
                Text(formatDuration(session.duration))
                    .font(.subheadline.monospacedDigit())
            }
            
            if !session.taskDescription.isEmpty {
                Text(session.taskDescription)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            HStack {
                if let projectId = session.projectId {
                    // In a real app, you'd look up the project name
                    Text("Project: \(projectId.uuidString.prefix(6))...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if session.isBillable {
                    Text("Billable")
                        .font(.caption2)
                        .padding(2)
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(3)
                }
                
                Spacer()
                
                Text(session.startTime, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: duration) ?? "0s"
    }
}

enum TimePeriod: String, CaseIterable {
    case day = "Today"
    case week = "This Week"
    case month = "This Month"
    case all = "All Time"
}

#Preview {
    SessionHistoryView()
}
