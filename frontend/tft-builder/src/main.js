import { createApp } from 'vue'
import App from './App.vue'
import router from './router'
import { registerServiceWorker, promptPWAInstall } from './registerServiceWorker'

import 'bootstrap/dist/css/bootstrap.min.css'
import 'bootstrap-icons/font/bootstrap-icons.css'
import 'bootstrap'
import './style.css'

// Force cache busting in development
if (import.meta.env.DEV) {
  const timestamp = Date.now()
  console.log(`🚀 TFT Team Builder v${timestamp} - Development Mode`)
  
  // Aggressive cache clearing on startup
  if ('caches' in window) {
    caches.keys().then(names => {
      names.forEach(name => caches.delete(name))
    })
  }
  
  // Disable service worker in development
  if ('serviceWorker' in navigator) {
    navigator.serviceWorker.getRegistrations().then(registrations => {
      registrations.forEach(registration => registration.unregister())
    })
  }
  
  // Clear all localStorage/sessionStorage
  try {
    localStorage.clear()
    sessionStorage.clear()
  } catch (e) {
    console.warn('Could not clear storage:', e)
  }

  // Add global cache clearing function
  window.clearTFTCache = () => {
    console.log('🧹 Clearing all caches...')
    localStorage.clear()
    sessionStorage.clear()
    if ('caches' in window) {
      caches.keys().then(names => {
        names.forEach(name => caches.delete(name))
      })
    }
    console.log('✅ Cache cleared! Reloading...')
    window.location.reload(true)
  }

  console.log('💡 Dev Mode: All caches disabled. Run clearTFTCache() to force reload.')
}

createApp(App).use(router).mount('#app')

// Register Service Worker for PWA
registerServiceWorker()

// Setup PWA install prompt
promptPWAInstall()
