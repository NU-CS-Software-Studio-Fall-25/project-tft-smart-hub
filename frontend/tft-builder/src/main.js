import { createApp } from 'vue'
import App from './App.vue'
import router from './router'
import { registerServiceWorker, promptPWAInstall } from './registerServiceWorker'

import 'bootstrap/dist/css/bootstrap.min.css'
import 'bootstrap-icons/font/bootstrap-icons.css'
import 'bootstrap'
import './style.css'

createApp(App).use(router).mount('#app')

// Register Service Worker for PWA
registerServiceWorker()

// Setup PWA install prompt
promptPWAInstall()
