import FluentProvider

extension Config {
    public func setup() throws {
        // allow fuzzy conversions for these types
        // (add your own types here)
        Node.fuzzy = [Row.self, JSON.self, Node.self]

        try setupProviders()
        try setupPreparations()
    }
    
    /// Configure providers
    private func setupProviders() throws {
        try addProvider(FluentProvider.Provider.self)
    }
    
    /// Add all models that should have their
    /// schemas prepared before the app boots
    private func setupPreparations() throws {
        let newPreparations: [Preparation.Type] = [User.self, SavedGame.self, CharacterAssignment.self, GameAssignments.self, UserAction.self, UserActionCollection.self, Pivot<UserAction, User>.self]

        preparations.append(contentsOf: newPreparations)
    }
}
