workspace "HeartAuth Core" "C1 System Context" {

    model {
        user_admin = person "Admin User" "Manages and monitors the system"
        user_auth = person "Authenticated User" "Signs in to tenant apps via HeartAuth and manages their account."

        tenant_system = softwareSystem "HeartAuth Tenant Systems" "External tenant apps/services that delegate 2FA with ECG to HeartAuth Core."

        fcm_system = softwareSystem "Firebase Cloud Messaging" "External notification service for sending push notifications"

        hearthauth_core = softwareSystem "HeartAuth Core" "Multi-tenant 2FA with ECG service, verifies user given their ECG data."


        user_admin -> hearthauth_core "Administers tenants & settings"
        user_auth -> hearthauth_core "Uses Mobile APIs to complete flows"
        tenant_system -> hearthauth_core "Delegates 2FA to HeartAuth Core"
        hearthauth_core -> fcm_system "Sends push notifications"
        fcm_system -> user_auth "Delivers notifications to mobile device"
    }

    views {
        systemContext hearthauth_core "c1-view" {
            include *
            include tenant_system
            include fcm_system
            include user_admin
            include user_auth
            autolayout lr
            title "System Context for HeartAuth Platform"
            description "Admins and authenticated users interact with HeartAuth Platform; tenant systems delegate 2FA authentication; Core uses FCM for push notifications."
        }

        theme default
    }
}
