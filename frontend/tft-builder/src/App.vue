<template>
  <div class="app-shell d-flex flex-column min-vh-100">
    <PWAInstallPrompt />
    <AppNavbar />
    <main class="flex-grow-1">
      <RouterView />
    </main>
    <AppFooter />
    <ChampionModal />
    <TermsAcceptanceModal ref="termsModal" />
  </div>
</template>

<script setup>
import { onMounted, ref, watch } from 'vue'
import { RouterView, useRouter } from 'vue-router'
import AppNavbar from './components/AppNavbar.vue'
import AppFooter from './components/AppFooter.vue'
import ChampionModal from './components/ChampionModal.vue'
import PWAInstallPrompt from './components/PWAInstallPrompt.vue'
import TermsAcceptanceModal from './components/TermsAcceptanceModal.vue'
import { authStore } from './stores/authStore'

const router = useRouter()
const termsModal = ref(null)

onMounted(() => {
  if (authStore.token) {
    authStore.refreshProfile().catch(() => authStore.logout())
  }
})

// Watch for user changes and check if terms need to be accepted
watch(() => authStore.user, (newUser) => {
  if (newUser && !newUser.termsAccepted && router.currentRoute.value.name !== 'guidelines') {
    // Show terms modal if user hasn't accepted terms
    termsModal.value?.openModal()
  }
}, { deep: true })
</script>

