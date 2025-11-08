workspace "HeartAuth Tenant" "C2 Container Diagram" {

    model {
        user_auth = person "User" "Signs in to tenant apps via HeartAuth and manages their account."

        hearthauth_core = softwareSystem "HeartAuth Core" "External multi-tenant 2FA with ECG service (verifies user given their ECG data)."

        tenant_system = softwareSystem "HeartAuth Tenant Application" "Tenant web application which uses Keycloak for identity and delegates 2FA to HeartAuth Core." {

            nextjs_frontend = container "Next.js Frontend" "Web frontend that users interact with (SSR/SPA) and initiates authentication flows." "Next.js"
            keycloak = container "Keycloak Identity Provider" "Open-source identity and access management server. Handles OIDC/OAuth2 and delegates 2FA to HeartAuth Core." "Keycloak (Quarkus/WildFly)"
            keycloak_postgres = container "Keycloak PostgreSQL" "Persistent store for Keycloak realms, users, sessions and tokens." "PostgreSQL"
        }

        user_auth -> nextjs_frontend "Uses / signs in to the tenant application"
        nextjs_frontend -> keycloak "Performs authentication (OIDC/OAuth2) and token exchange"
        keycloak -> keycloak_postgres "Reads/writes user/realm/session data"
        keycloak -> hearthauth_core "Delegates 2FA (ECG-based) and pairing requests to HeartAuth Core"
        hearthauth_core -> keycloak "Returns 2FA verification results and pairing results"

    }

    views {
        container tenant_system "tenant-container-view" {
            include *
            include hearthauth_core
            include user_auth
            autolayout lr
            title "C2 HeartAuth Tenant"
        }

        theme default
    }
}
