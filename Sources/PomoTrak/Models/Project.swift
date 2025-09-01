import Foundation

enum ProjectStatus: String, Codable, CaseIterable {
    case active = "Active"
    case inactive = "Inactive"
    case completed = "Completed"
}

struct Client: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var name: String
    var email: String
    var phone: String?
    var company: String?
    var billingAddress: String?
    var taxId: String?
    var paymentTerms: String?
    var notes: String?
    var isActive: Bool
    var createdAt: Date
    var updatedAt: Date
    
    init(id: UUID = UUID(),
         name: String,
         email: String,
         phone: String? = nil,
         company: String? = nil,
         billingAddress: String? = nil,
         taxId: String? = nil,
         paymentTerms: String? = nil,
         notes: String? = nil,
         isActive: Bool = true,
         createdAt: Date = Date(),
         updatedAt: Date = Date()) {
        self.id = id
        self.name = name
        self.email = email
        self.phone = phone
        self.company = company
        self.billingAddress = billingAddress
        self.taxId = taxId
        self.paymentTerms = paymentTerms
        self.notes = notes
        self.isActive = isActive
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    mutating func update(name: String? = nil,
                        email: String? = nil,
                        phone: String? = nil,
                        company: String? = nil,
                        billingAddress: String? = nil,
                        taxId: String? = nil,
                        paymentTerms: String? = nil,
                        notes: String? = nil,
                        isActive: Bool? = nil) -> Client {
        if let name = name { self.name = name }
        if let email = email { self.email = email }
        if let phone = phone { self.phone = phone }
        if let company = company { self.company = company }
        if let billingAddress = billingAddress { self.billingAddress = billingAddress }
        if let taxId = taxId { self.taxId = taxId }
        if let paymentTerms = paymentTerms { self.paymentTerms = paymentTerms }
        if let notes = notes { self.notes = notes }
        if let isActive = isActive { self.isActive = isActive }
        self.updatedAt = Date()
        return self
    }
}

struct Project: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var name: String
    var client: Client
    var hourlyRate: Double
    var description: String
    var tags: [String]
    var status: ProjectStatus
    var createdAt: Date
    var updatedAt: Date
    
    init(id: UUID = UUID(),
         name: String,
         client: Client,
         hourlyRate: Double = 0.0,
         description: String = "",
         tags: [String] = [],
         status: ProjectStatus = .active,
         createdAt: Date = Date(),
         updatedAt: Date = Date()) {
        self.id = id
        self.name = name
        self.client = client
        self.hourlyRate = hourlyRate
        self.description = description
        self.tags = tags
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    mutating func update(name: String? = nil,
                        client: Client? = nil,
                        hourlyRate: Double? = nil,
                        description: String? = nil,
                        tags: [String]? = nil,
                        status: ProjectStatus? = nil) -> Project {
        if let name = name { self.name = name }
        if let client = client { self.client = client }
        if let hourlyRate = hourlyRate { self.hourlyRate = hourlyRate }
        if let description = description { self.description = description }
        if let tags = tags { self.tags = tags }
        if let status = status { self.status = status }
        self.updatedAt = Date()
        return self
    }
}
