workspace "HeartAuth Context" "C1 System Context" {

    model {
        user_admin = person "Admin User" "Manages and monitors the system"
        user_auth = person "User" "Signs in to tenant apps via HeartAuth and manages their account."

        tenant_system = softwareSystem "HeartAuth Tenant Systems" "External tenant apps/services that delegate 2FA with ECG to HeartAuth Core."
        fcm_system = softwareSystem "Firebase Cloud Messaging" "External notification service for sending push notifications"
       
        mobile = softwareSystem "HeartAuth Mobile" "Mobile authenticator application"
        watch = softwareSystem "HeartAuth Wear OS" "Wear Os ECG Sampler application"

        hearthauth_core = softwareSystem "HeartAuth Core" "Multi-tenant 2FA with ECG service, verifies user given their ECG data."
        user_admin -> hearthauth_core "Administers tenants & settings"
        user_auth -> watch "Uses watch to collect ECG data"
        user_auth -> mobile "Uses mobile to scan QR, to orchestrate watch application"
        user_auth -> tenant_system "Uses system to insert login credentials and trigger 2FA"
        mobile -> hearthauth_core "uses Mobile API"
        mobile -> watch "requests ECG Data read"
        tenant_system -> hearthauth_core "Delegates 2FA to HeartAuth Core"
        hearthauth_core -> fcm_system "Sends push notifications"
        fcm_system -> mobile "Delivers notifications to mobile device"
    }

    views {
        systemContext hearthauth_core "c1-view" {
            include *
            include tenant_system
            include fcm_system
            include user_admin
            include user_auth
            include watch
            include mobile
            autolayout tb
            title "System Context for HeartAuth"
            description "User interact with HeartAuth; tenant systems delegate 2FA authentication; Core uses FCM for push notifications."
        }

        theme default
    }
}
