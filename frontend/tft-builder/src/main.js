import { createApp } from 'vue'
import App from './App.vue'
import router from './router'

import 'bootstrap/dist/css/bootstrap.min.css'
import 'bootstrap-icons/font/bootstrap-icons.css'
import 'bootstrap'
import './style.css'

// Clear any service worker cache on load
if ('serviceWorker' in navigator) {
  navigator.serviceWorker.getRegistrations().then(registrations => {
    registrations.forEach(registration => registration.unregister())
  })
}

// Add version check and force reload if needed
const APP_VERSION = Date.now().toString()
const STORED_VERSION = localStorage.getItem('app_version')

if (STORED_VERSION && STORED_VERSION !== APP_VERSION) {
  console.log('New version detected, clearing cache...')
  // Clear all caches
  if ('caches' in window) {
    caches.keys().then(names => {
      names.forEach(name => caches.delete(name))
    })
  }
}
localStorage.setItem('app_version', APP_VERSION)

createApp(App).use(router).mount('#app')
