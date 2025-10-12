<template>
  <div class="app-shell d-flex flex-column min-vh-100">
    <AppNavbar />
    <main class="flex-grow-1">
      <RouterView />
    </main>
    <AppFooter />
    <ChampionModal />
  </div>
</template>

<script setup>
import { RouterView } from 'vue-router'
import AppNavbar from './components/AppNavbar.vue'
import AppFooter from './components/AppFooter.vue'
import ChampionModal from './components/ChampionModal.vue'
</script>
