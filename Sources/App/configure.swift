import FluentPostgreSQL
import Vapor
import Authentication

public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
    ) throws {
    // 2
    try services.register(FluentPostgreSQLProvider())
    let serverConfigure = NIOServerConfig.default(hostname: "192.168.0.13", port: 8080)
    services.register(serverConfigure)
    
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
    
    
    var middlewares = MiddlewareConfig()
    middlewares.use(ErrorMiddleware.self)
    services.register(middlewares)
    
    var databases = DatabasesConfig()
    // 3
    
    let databaseConfig = PostgreSQLDatabaseConfig(
        hostname: "localhost",
        port: 5432,
        username: "vapor",
        database: "vapor",
        password: "password",
        transport: .cleartext)
    
    let database = PostgreSQLDatabase(config: databaseConfig)
    databases.add(database: database, as: .psql)
    services.register(databases)
    var migrations = MigrationConfig()
    // 4
    migrations.add(model: Court.self, database: .psql)
    migrations.add(model: User.self, database: .psql)
    migrations.add(model: Token.self, database: .psql)
    migrations.add(migration: AdminUser.self, database: .psql)
    services.register(migrations)
    
    
    var commandConfig = CommandConfig.default()
    commandConfig.useFluentCommands()
    services.register(commandConfig)
    
    try services.register(AuthenticationProvider())
    
    
}

