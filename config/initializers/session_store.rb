# Be sure to restart your server when you modify this file.

DrwhoAdmin::Application.config.session_store :cookie_store, :key => '_drwho_admin_session', :expire_after => 120.minutes

#DrwhoAdmin::Application.config.session_store ActionDispatch::Session::CacheStore, :expire_after => 120.minutes
