import Fluent
import FluentPostgresDriver
import NIOSSL
import Vapor

public func configure(_ app: Application) async throws {
    try app.databases.use(DatabaseConfigurationFactory.postgres(configuration: .init(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database",
        tls: .prefer(.init(configuration: .clientDefault))
    )), as: .psql)

    app.migrations.add(CreateUsers())
    app.migrations.add(CreateTokens())

    app.migrations.add(CreateBooks())
    app.migrations.add(CreateAudioBooks())

    app.migrations.add(CreateReadingProgress())
    app.migrations.add(CreateQuotes())
    app.migrations.add(CreateReview())

    app.migrations.add(CreateNews())

    try routes(app)
}
