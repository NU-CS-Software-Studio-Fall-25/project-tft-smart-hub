<template>
  <div v-if="showInstallPrompt" class="pwa-install-banner">
    <div class="container-fluid">
      <div class="row align-items-center py-2">
        <div class="col-auto">
          <i class="bi bi-phone text-warning"></i>
        </div>
        <div class="col">
          <small class="text-white">Install TFT Team Lab on your device for quick access!</small>
        </div>
        <div class="col-auto">
          <button @click="installPWA" class="btn btn-sm btn-warning me-2">
            <i class="bi bi-download"></i> Install
          </button>
          <button @click="dismissPrompt" class="btn btn-sm btn-outline-secondary text-white">
            <i class="bi bi-x"></i>
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, onMounted } from 'vue'

export default {
  name: 'PWAInstallPrompt',
  setup() {
    const showInstallPrompt = ref(false)
    let deferredPrompt = null

    onMounted(() => {
      // Check if user already dismissed the prompt
      const dismissed = localStorage.getItem('pwa-install-dismissed')
      
      window.addEventListener('beforeinstallprompt', (e) => {
        e.preventDefault()
        deferredPrompt = e
        
        // Show the install prompt if not dismissed
        if (!dismissed) {
          showInstallPrompt.value = true
        }
      })

      // Hide prompt if app is already installed
      window.addEventListener('appinstalled', () => {
        showInstallPrompt.value = false
        deferredPrompt = null
      })
    })

    const installPWA = async () => {
      if (!deferredPrompt) return
      
      deferredPrompt.prompt()
      const { outcome } = await deferredPrompt.userChoice
      
      console.log(`User response to install prompt: ${outcome}`)
      
      showInstallPrompt.value = false
      deferredPrompt = null
    }

    const dismissPrompt = () => {
      showInstallPrompt.value = false
      localStorage.setItem('pwa-install-dismissed', 'true')
    }

    return {
      showInstallPrompt,
      installPWA,
      dismissPrompt
    }
  }
}
</script>

<style scoped>
.pwa-install-banner {
  background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
  border-bottom: 2px solid #ffc107;
  position: sticky;
  top: 0;
  z-index: 1050;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
}
</style>
