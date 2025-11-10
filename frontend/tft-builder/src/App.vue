<template>
  <div class="app-shell d-flex flex-column min-vh-100">
    <PWAInstallPrompt />
    <AppNavbar />
    <main class="flex-grow-1">
      <router-view />
    </main>
    <AppFooter />
    <ChampionModal />
  </div>
</template>

<script setup>
import { onMounted } from 'vue'
import AppNavbar from './components/AppNavbar.vue'
import AppFooter from './components/AppFooter.vue'
import ChampionModal from './components/ChampionModal.vue'
import PWAInstallPrompt from './components/PWAInstallPrompt.vue'
import { authStore } from './stores/authStore'

onMounted(() => {
  if (authStore.token) {
    authStore.refreshProfile().catch(() => authStore.logout())
  }
})
</script>

