# Stage 1: Build
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy project files
COPY ["src/LoanApi/LoanApi.csproj", "LoanApi/"]
COPY ["src/LoanApi.Tests/LoanApi.Tests.csproj", "LoanApi.Tests/"]

# Restore dependencies
RUN dotnet restore "LoanApi/LoanApi.csproj"
RUN dotnet restore "LoanApi.Tests/LoanApi.Tests.csproj"

# Copy source code
COPY src/ .

# Run tests
RUN dotnet test "LoanApi.Tests/LoanApi.Tests.csproj" --configuration Release --no-restore --verbosity normal

# Build application
RUN dotnet build "LoanApi/LoanApi.csproj" -c Release -o /app/build --no-restore

# Publish application
RUN dotnet publish "LoanApi/LoanApi.csproj" -c Release -o /app/publish --no-restore

# Stage 2: Runtime
FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine AS final
WORKDIR /app

# Create non-root user
RUN addgroup -g 1000 appuser && \
    adduser -D -u 1000 -G appuser appuser && \
    chown -R appuser:appuser /app

# Copy published application
COPY --from=build --chown=appuser:appuser /app/publish .

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 8080

# Set environment variables
ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Production

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health/live || exit 1

# Entry point
ENTRYPOINT ["dotnet", "LoanApi.dll"]
