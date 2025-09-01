import Foundation

@globalActor
actor DataManagerActor {
    static let shared = DataManagerActor()
    private init() {}
    
    private let fileManager = FileManager.default
    private let queue = DispatchQueue(label: "com.pomotrak.datamanager", qos: .userInitiated)
    
    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("PomoTrak", isDirectory: true)
    }
    
    private func ensureDirectoryExists() throws {
        if !fileManager.fileExists(atPath: documentsDirectory.path) {
            try fileManager.createDirectory(
                at: documentsDirectory,
                withIntermediateDirectories: true
            )
        }
    }
    
    func save<T: Encodable>(_ data: T, to filename: String) async {
        let directory = documentsDirectory
        
        do {
            let url = directory.appendingPathComponent(filename)
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(data)
            try ensureDirectoryExists()
            try data.write(to: url)
        } catch {
            print("Error saving data: \(error)")
        }
    }
    
    func load<T: Decodable>(_ type: T.Type, from filename: String) async -> T? {
        let url = documentsDirectory.appendingPathComponent(filename)
        
        guard fileManager.fileExists(atPath: url.path) else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(type, from: data)
        } catch {
            print("Error loading data: \(error)")
            return nil
        }
    }
}

@MainActor
class DataManager {
    static let shared = DataManager()
    
    private let sessionsFile = "sessions.json"
    private let projectsFile = "projects.json"
    private let clientsFile = "clients.json"
    
    private let actor = DataManagerActor.shared
    
    private init() {}
    
    // MARK: - Sessions
    
    func saveSessions(_ sessions: [Session]) async {
        await actor.save(sessions, to: sessionsFile)
    }
    
    func loadSessions() async -> [Session] {
        await actor.load([Session].self, from: sessionsFile) ?? []
    }
    
    // MARK: - Projects
    
    func saveProjects(_ projects: [Project]) async {
        await actor.save(projects, to: projectsFile)
    }
    
    func loadProjects() async -> [Project] {
        await actor.load([Project].self, from: projectsFile) ?? []
    }
    
    // MARK: - Clients
    
    func saveClients(_ clients: [Client]) async {
        await actor.save(clients, to: clientsFile)
    }
    
    func loadClients() async -> [Client] {
        await actor.load([Client].self, from: clientsFile) ?? []
    }
    
    // MARK: - Private Helpers
}

// MARK: - DataManagerActor

extension DataManagerActor {
    func save<T: Encodable>(_ data: T, to filename: String) {
        let url = documentsDirectory.appendingPathComponent(filename)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            let data = try encoder.encode(data)
            try data.write(to: url)
        } catch {
            print("Error saving data: \(error)")
        }
    }
    
    private func load<T: Decodable>(_ type: T.Type, from filename: String) -> T? {
        let url = documentsDirectory.appendingPathComponent(filename)
        
        guard fileManager.fileExists(atPath: url.path) else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(type, from: data)
        } catch {
            print("Error loading data: \(error)")
            return nil
        }
    }
}
