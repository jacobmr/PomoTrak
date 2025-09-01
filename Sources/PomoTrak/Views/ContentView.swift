import SwiftUI

struct ContentView: View {
    @StateObject private var timerManager = TimerManager.shared
    @State private var selectedProject: Project?
    @State private var sessionDescription: String = ""
    @State private var taskDescription: String = ""
    @State private var showingProjectSelector = false
    @State private var showingSessionHistory = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Project Selection
            HStack {
                Button(action: { showingProjectSelector = true }) {
                    HStack {
                        Image(systemName: "folder")
                        Text(selectedProject?.name ?? "Select Project")
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)
                .popover(isPresented: $showingProjectSelector) {
                    ProjectSelectorView(selectedProject: $selectedProject)
                }
                
                if selectedProject != nil {
                    Button(action: { selectedProject = nil }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            Divider()
            
            // Timer Display
            Text(timerManager.formattedTimeRemaining)
                .font(.system(size: 48, weight: .light, design: .monospaced))
                .foregroundColor(timerManager.isRunning ? .primary : .secondary)
            
            // Session Description
            TextField("What are you working on?", text: $sessionDescription)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            // Task Description
            TextField("Task details (optional)", text: $taskDescription)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            // Timer Controls
            HStack(spacing: 20) {
                if timerManager.isRunning || timerManager.isPaused {
                    Button(action: {
                        Task { @MainActor in
                            await timerManager.endCurrentSession()
                        }
                    }) {
                        Image(systemName: "stop.fill")
                            .font(.title2)
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.red)
                }
                
                Button(action: {
                    Task { @MainActor in
                        if timerManager.isRunning || timerManager.isPaused {
                            timerManager.togglePause()
                        } else {
                            await timerManager.startNewSession(
                                projectId: selectedProject?.id,
                                description: sessionDescription,
                                taskDescription: taskDescription
                            )
                        }
                    }
                }) {
                    ZStack {
                        Circle()
                            .stroke(lineWidth: 2)
                            .frame(width: 60, height: 60)
                        
                        if timerManager.isRunning || timerManager.isPaused {
                            Image(systemName: "pause.fill")
                                .font(.title)
                        } else {
                            Image(systemName: "play.fill")
                                .font(.title)
                        }
                    }
                }
                .buttonStyle(.plain)
                .frame(width: 60, height: 60)
                
                if timerManager.isRunning || timerManager.isPaused {
                    Button(action: {
                    timerManager.togglePause()
                }) {
                        Text(timerManager.isPaused ? "Resume" : "Pause")
                            .font(.headline)
                    }
                }
            }
            .padding(.vertical, 8)
            
            Divider()
            
            // Session History
            Button(action: { showingSessionHistory = true }) {
                HStack {
                    Image(systemName: "clock")
                    Text("Session History")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .buttonStyle(.plain)
            .popover(isPresented: $showingSessionHistory) {
                SessionHistoryView()
            }
        }
        .frame(width: 300, height: 400)
        .padding(.bottom, 8)
    }
}

#Preview {
    ContentView()
}
