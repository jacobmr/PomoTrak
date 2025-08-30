import SwiftUI

struct ProjectSelectorView: View {
    @Binding var selectedProject: Project?
    @State private var projects: [Project] = []
    @State private var showingNewProjectSheet = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Select Project")
                    .font(.headline)
                Spacer()
                Button(action: { showingNewProjectSheet = true }) {
                    Image(systemName: "plus")
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // Project List
            List(projects, id: \.id) { project in
                Button(action: {
                    selectedProject = project
                }) {
                    HStack {
                        Circle()
                            .fill(colorForProject(project))
                            .frame(width: 12, height: 12)
                        Text(project.name)
                            .foregroundColor(.primary)
                        Spacer()
                        if project.id == selectedProject?.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
            }
            .listStyle(PlainListStyle())
        }
        .frame(width: 250, height: 300)
        .onAppear {
            loadProjects()
        }
        .sheet(isPresented: $showingNewProjectSheet) {
            NewProjectView { [self] newProject in
                projects.append(newProject)
                selectedProject = newProject
                Task {
                    var currentProjects = await DataManager.shared.loadProjects()
                    currentProjects.append(newProject)
                    await DataManager.shared.saveProjects(currentProjects)
                }
            }
        }
    }
    
    @MainActor
    private func loadProjects() {
        Task {
            projects = await DataManager.shared.loadProjects()
        }
    }
    
    private func colorForProject(_ project: Project) -> Color {
        // This is a simple hash-based color generation
        // In a real app, you might want to store a color with each project
        let hash = project.id.uuidString.hashValue
        let colors: [Color] = [.red, .green, .blue, .orange, .purple, .pink, .yellow, .mint]
        return colors[abs(hash) % colors.count]
    }
}

struct NewProjectView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var name = ""
    @State private var clientName = ""
    @State private var hourlyRate = ""
    @State private var description = ""
    
    var onSave: (Project) -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text("New Project")
                .font(.headline)
                .padding(.top)
            
            Form {
                TextField("Project Name", text: $name)
                TextField("Client Name", text: $clientName)
                TextField("Hourly Rate", text: $hourlyRate)
                    #if os(iOS)
                    .keyboardType(.decimalPad)
                    #endif
                TextField("Description (optional)", text: $description)
            }
            .padding()
            
            HStack {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Spacer()
                
                Button("Save") {
                    let client = Client(name: clientName, email: "")
                    let project = Project(
                        name: name,
                        client: client,
                        hourlyRate: Double(hourlyRate) ?? 0,
                        description: description
                    )
                    onSave(project)
                    presentationMode.wrappedValue.dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(name.isEmpty || clientName.isEmpty)
            }
            .padding()
        }
        .frame(width: 400)
        .padding()
    }
}

#Preview {
    ProjectSelectorView(selectedProject: .constant(nil))
}
