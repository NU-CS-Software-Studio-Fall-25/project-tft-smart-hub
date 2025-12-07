<template>
  <div class="page-white">
    <div class="container py-5">
      <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="h2 fw-bold mb-0">
          <i class="bi bi-star-fill text-warning me-2"></i>
          My Favorites
        </h1>
        <RouterLink to="/teams" class="btn btn-outline-primary">
          <i class="bi bi-arrow-left me-1"></i>
          Back to Teams
        </RouterLink>
      </div>

      <div v-if="loading" class="py-5 text-center">
        <div class="spinner-border"></div>
        <div class="mt-3 text-body-secondary">Loading favorites...</div>
      </div>

      <div v-else-if="favorites.length === 0" class="alert alert-info">
        <i class="bi bi-info-circle me-2"></i>
        You haven't favorited any team compositions yet. 
        Browse <RouterLink to="/teams">team comps</RouterLink> and click the star icon to save your favorites.
      </div>

      <div v-else class="row g-4">
        <div v-for="team in favorites" :key="team.id" class="col-12 col-lg-6">
          <div class="card h-100 shadow-sm border-0 favorite-card">
            <div class="card-body">
              <div class="d-flex justify-content-between align-items-start mb-3">
                <div class="flex-grow-1 pe-3">
                  <h3 class="h5 fw-semibold mb-2">{{ team.name }}</h3>
                  <p class="text-body-secondary small mb-0">
                    {{ team.description || 'No description available' }}
                  </p>
                </div>
                <span v-if="team.isSystemTeam" class="badge bg-success-subtle text-success-emphasis">
                  System
                </span>
                <span v-else class="badge bg-primary-subtle text-primary-emphasis">
                  User
                </span>
              </div>

              <div class="champions-row d-flex flex-wrap gap-2 mb-3">
                <div
                  v-for="card in team.cards.slice(0, 8)"
                  :key="`${team.id}-${card.id}`"
                  class="champion-mini"
                  :title="card.name"
                >
                  <SpriteImage
                    :sprite="card.sprite"
                    :image-url="card.imageUrl"
                    :alt="card.name"
                    :size="56"
                  />
                </div>
                <div v-if="team.cards.length > 8" class="more-badge">
                  <span class="badge bg-secondary">+{{ team.cards.length - 8 }}</span>
                </div>
              </div>

              <div class="d-flex align-items-center gap-3 small text-body-secondary mb-3">
                <span v-if="team.winRate">
                  <i class="bi bi-trophy"></i> {{ percentage(team.winRate) }} win
                </span>
                <span v-if="team.playRate">
                  <i class="bi bi-people"></i> {{ percentage(team.playRate) }} play
                </span>
                <span>
                  <i class="bi bi-grid-3x3-gap"></i> {{ team.championCount || team.cards.length }} units
                </span>
                <span v-if="team.userName">
                  <i class="bi bi-person-circle"></i> {{ team.userName }}
                </span>
              </div>

              <div class="d-flex align-items-center gap-2">
                <button 
                  class="btn btn-sm btn-outline-warning active" 
                  @click="toggleFavorite(team)"
                  title="Remove from favorites"
                >
                  <i class="bi bi-star-fill"></i>
                  {{ team.favoritesCount || 0 }}
                </button>
                <button 
                  class="btn btn-sm btn-outline-danger" 
                  :class="{ 'active': team.isLiked }"
                  @click="toggleLike(team)"
                >
                  <i class="bi" :class="team.isLiked ? 'bi-heart-fill' : 'bi-heart'"></i>
                  {{ team.likesCount || 0 }}
                </button>
                <RouterLink
                  class="btn btn-sm btn-outline-secondary"
                  :to="{ name: 'team-detail', params: { id: team.id } }"
                  title="View comments"
                >
                  <i class="bi bi-chat"></i>
                  {{ team.commentsCount || 0 }}
                </RouterLink>
                <RouterLink
                  class="btn btn-sm btn-primary ms-auto"
                  :to="{ name: 'team-detail', params: { id: team.id } }"
                >
                  <i class="bi bi-eye me-1"></i>
                  View Details
                </RouterLink>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { RouterLink, useRouter } from 'vue-router'
import SpriteImage from '../components/SpriteImage.vue'
import { fetchFavorites, unfavoriteTeam, likeTeam, unlikeTeam } from '../services/api'
import { authStore } from '../stores/authStore'

const router = useRouter()
const loading = ref(true)
const favorites = ref([])
const isAuthenticated = computed(() => authStore.isAuthenticated())

const loadFavorites = async () => {
  loading.value = true
  try {
    const data = await fetchFavorites()
    favorites.value = data.favorites || []
    console.log('[FavoritesPage] Loaded favorites:', favorites.value.length)
  } catch (error) {
    console.error('[FavoritesPage] Failed to load favorites:', error)
    alert('Failed to load favorites')
  } finally {
    loading.value = false
  }
}

const toggleFavorite = async (team) => {
  if (!isAuthenticated.value) {
    router.push({ name: 'login', query: { redirect: router.currentRoute.value.fullPath } })
    return
  }
  try {
    await unfavoriteTeam(team.id)
    const index = favorites.value.findIndex(t => t.id === team.id)
    if (index !== -1) {
      favorites.value.splice(index, 1)
    }
  } catch (error) {
    console.error('[FavoritesPage] Failed to unfavorite:', error)
    alert('Failed to remove favorite')
  }
}

const toggleLike = async (team) => {
  if (!isAuthenticated.value) {
    router.push({ name: 'login', query: { redirect: router.currentRoute.value.fullPath } })
    return
  }
  try {
    if (team.isLiked) {
      const result = await unlikeTeam(team.id)
      Object.assign(team, { isLiked: result.liked, likesCount: result.likesCount })
    } else {
      const result = await likeTeam(team.id)
      Object.assign(team, { isLiked: result.liked, likesCount: result.likesCount })
    }
  } catch (error) {
    console.error('[FavoritesPage] Failed to toggle like:', error)
    alert('Failed to update like status')
  }
}

const percentage = (value) => {
  if (value === null || value === undefined) return 'N/A'
  return (value * 100).toFixed(1) + '%'
}

onMounted(() => {
  loadFavorites()
})
</script>

<style scoped>
.favorite-card {
  transition: transform 0.2s, box-shadow 0.2s;
}

.favorite-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.1) !important;
}

.champions-row {
  min-height: 60px;
}

.champion-mini {
  width: 56px;
  height: 56px;
  border-radius: 8px;
  overflow: hidden;
  border: 2px solid rgba(0, 0, 0, 0.1);
  transition: transform 0.2s;
}

.champion-mini:hover {
  transform: scale(1.1);
  z-index: 10;
}

.more-badge {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 56px;
  height: 56px;
}

.btn-outline-danger.active {
  background-color: #dc3545;
  color: white;
  border-color: #dc3545;
}

.btn-outline-warning.active {
  background-color: #ffc107;
  color: #000;
  border-color: #ffc107;
}
</style>
