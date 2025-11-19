<template>
  <div class="page-white">
    <div class="container py-5">
      <!-- Single row with all controls -->
      <div class="d-flex flex-wrap align-items-center gap-3 mb-4">
        <div class="flex-grow-1" style="min-width: 250px; max-width: 400px;">
          <div class="input-group shadow-sm">
            <span class="input-group-text bg-white text-secondary">
              <i class="bi bi-search"></i>
            </span>
            <input
              v-model="searchTerm"
              class="form-control"
              type="search"
              placeholder="Search teams..."
            />
          </div>
        </div>
        <div class="btn-group" role="group" aria-label="Team type selection">
          <input type="radio" class="btn-check" id="system-teams" v-model="teamType" value="system" autocomplete="off">
          <label class="btn btn-outline-primary" for="system-teams">System Teams</label>
          <input type="radio" class="btn-check" id="user-teams" v-model="teamType" value="user" autocomplete="off">
          <label class="btn btn-outline-primary" for="user-teams">User Teams</label>
        </div>
        <RouterLink class="btn btn-primary ms-auto" :to="createRoute">
          <i class="bi bi-plus-circle me-1"></i>
          Add Team
        </RouterLink>
      </div>

      <!-- Stats row -->
      <div class="d-flex justify-content-between align-items-center mb-4">
        <div class="text-body-secondary small">
          Showing {{ displayedCount }} of {{ totalCount }} team comps
        </div>
      </div>

      <div v-if="loading && !teams.length" class="py-5 text-center">
        <div class="spinner-border"></div>
        <div class="mt-3 text-body-secondary">Loading team compositions...</div>
      </div>

      <div v-else>
        <div v-if="teams.length === 0" class="alert alert-info">
          <template v-if="searchActive">
            No team compositions match "{{ searchTerm }}". Try different keywords or traits.
          </template>
          <template v-else>
            No team compositions saved yet. Create your first comp via the
            <RouterLink to="/teams/new">team builder</RouterLink>.
          </template>
        </div>

        <div v-else>
          <!-- System Teams Layout: Grid -->
          <div v-if="teamType === 'system'" class="system-teams-layout">
            <div class="row g-4 row-cols-1 row-cols-lg-2 mb-4">
              <div v-for="team in paginatedTeams" :key="team.id" class="col">
                <div class="system-team-card card h-100 shadow-sm border-0">
                  <div class="card-body d-flex flex-column">
                    <div class="system-team-header d-flex justify-content-between align-items-start mb-3">
                      <div class="pe-3 flex-grow-1">
                        <h2 class="h4 fw-semibold mb-2">{{ team.name }}</h2>
                      </div>
                      <span class="badge bg-success-subtle text-success-emphasis fs-6 win-pill" v-if="team.winRate">
                        Win {{ percentage(team.winRate) }}
                      </span>
                    </div>

                    <div class="system-champions-strip d-flex gap-3 pb-2 mb-3">
                      <div
                        v-for="card in team.cards"
                        :key="`${team.id}-${card.id}`"
                        class="system-mini-card"
                        :title="card.name"
                      >
                        <SpriteImage
                          :sprite="card.sprite"
                          :image-url="card.imageUrl"
                          :alt="card.name"
                          :size="72"
                          class-name="system-card-img"
                        />
                      </div>
                    </div>

                    <div class="system-meta-row d-flex flex-wrap gap-3 align-items-center mt-auto small text-body-secondary">
                      <div class="meta-item">
                        <i class="bi bi-people"></i>
                        <div>
                          <div class="meta-label">Play rate</div>
                          <div class="meta-value">{{ percentage(team.playRate) }}</div>
                        </div>
                      </div>
                      <div class="meta-item">
                        <i class="bi bi-grid-3x3-gap"></i>
                        <div>
                          <div class="meta-label">Board size</div>
                          <div class="meta-value">{{ unitCount(team) }} units</div>
                        </div>
                      </div>
                      <div v-if="avgPlacement(team)" class="meta-item">
                        <i class="bi bi-trophy"></i>
                        <div>
                          <div class="meta-label">Avg placement</div>
                          <div class="meta-value">{{ avgPlacement(team) }}</div>
                        </div>
                      </div>
                      <div v-if="playCount(team)" class="meta-item">
                        <i class="bi bi-controller"></i>
                        <div>
                          <div class="meta-label">Games tracked</div>
                          <div class="meta-value">{{ playCount(team) }}</div>
                        </div>
                      </div>
                    </div>
                  </div>
                  <div class="card-footer bg-white d-flex justify-content-between align-items-center gap-2">
                    <div class="d-flex gap-2">
                      <button 
                        class="btn btn-sm btn-outline-danger" 
                        :class="{ 'active': team.isLiked }"
                        @click.stop="toggleLike(team)"
                      >
                        <i class="bi" :class="team.isLiked ? 'bi-heart-fill' : 'bi-heart'"></i>
                        {{ team.likesCount || 0 }}
                      </button>
                      <button 
                        class="btn btn-sm btn-outline-warning" 
                        :class="{ 'active': team.isFavorited }"
                        @click.stop="toggleFavorite(team)"
                      >
                        <i class="bi" :class="team.isFavorited ? 'bi-star-fill' : 'bi-star'"></i>
                        {{ team.favoritesCount || 0 }}
                      </button>
                      <span class="btn btn-sm btn-outline-secondary disabled">
                        <i class="bi bi-chat"></i>
                        {{ team.commentsCount || 0 }}
                      </span>
                    </div>
                    <div class="d-flex gap-2 ms-auto">
                      <RouterLink
                        class="btn btn-sm btn-outline-primary"
                        :to="{ name: 'team-detail', params: { id: team.id } }"
                      >
                        View details
                      </RouterLink>
                      <button v-if="isAdmin" class="btn btn-sm btn-outline-danger" @click="removeTeam(team.id)" :disabled="deletingTeamId === team.id">
                        <span v-if="deletingTeamId === team.id" class="spinner-border spinner-border-sm"></span>
                        <i v-else class="bi bi-trash"></i>
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- User Teams Layout: List -->
          <div v-else class="user-teams-layout">
            <div class="user-teams-list">
              <div v-for="team in paginatedTeams" :key="team.id" class="user-team-row card mb-3 shadow-sm border-0">
                <div class="card-body p-3">
                  <div class="d-flex align-items-center gap-3">
                    <div class="user-team-info flex-grow-1">
                      <div class="d-flex align-items-center gap-2 mb-2">
                        <h3 class="h5 fw-semibold mb-0">{{ team.name }}</h3>
                        <span class="badge bg-primary-subtle text-primary-emphasis">User</span>
                      </div>
                      <p class="text-body-secondary small mb-2 user-description">
                        {{ summarize(team.description, 100) }}
                      </p>
                      <div class="user-team-meta d-flex gap-3 small text-body-secondary">
                        <span v-if="team.userName" class="text-primary"><i class="bi bi-person-circle"></i> {{ team.userName }}</span>
                        <span v-if="team.set"><i class="bi bi-box"></i> {{ formatSet(team.set) }}</span>
                        <span><i class="bi bi-grid-3x3-gap"></i> {{ unitCount(team) }} units</span>
                        <span v-if="team.createdAt"><i class="bi bi-calendar"></i> {{ formatDate(team.createdAt) }}</span>
                      </div>
                    </div>
                    <div class="user-team-icons d-flex gap-2">
                      <div
                        v-for="card in team.cards.slice(0, 5)"
                        :key="`${team.id}-${card.id}`"
                        class="user-mini-card"
                        :title="card.name"
                      >
                        <SpriteImage
                          :sprite="card.sprite"
                          :image-url="card.imageUrl"
                          :alt="card.name"
                          :size="48"
                          class-name="user-card-img"
                        />
                      </div>
                      <div v-if="team.cards.length > 5" class="more-indicator">
                        <span class="badge bg-secondary">+{{ team.cards.length - 5 }}</span>
                      </div>
                    </div>
                    <div class="user-team-actions d-flex gap-2 align-items-start">
                      <div class="d-flex flex-column gap-2">
                        <button 
                          class="btn btn-sm btn-outline-danger" 
                          :class="{ 'active': team.isLiked }"
                          @click.stop="toggleLike(team)"
                        >
                          <i class="bi" :class="team.isLiked ? 'bi-heart-fill' : 'bi-heart'"></i>
                          {{ team.likesCount || 0 }}
                        </button>
                        <button 
                          class="btn btn-sm btn-outline-warning" 
                          :class="{ 'active': team.isFavorited }"
                          @click.stop="toggleFavorite(team)"
                        >
                          <i class="bi" :class="team.isFavorited ? 'bi-star-fill' : 'bi-star'"></i>
                          {{ team.favoritesCount || 0 }}
                        </button>
                      </div>
                      <div class="d-flex flex-column gap-2">
                        <RouterLink
                          class="btn btn-sm btn-outline-primary"
                          :to="{ name: 'team-detail', params: { id: team.id } }"
                        >
                          View
                        </RouterLink>
                        <button v-if="canEditTeam(team)" class="btn btn-sm btn-outline-secondary" @click="editTeam(team.id)">
                          <i class="bi bi-pencil"></i>
                        </button>
                        <button v-if="canDeleteTeam(team)" class="btn btn-sm btn-outline-danger" @click="removeTeam(team.id)" :disabled="deletingTeamId === team.id">
                          <span v-if="deletingTeamId === team.id" class="spinner-border spinner-border-sm"></span>
                          <i v-else class="bi bi-trash"></i>
                        </button>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <Pagination
            :current-page="currentPage"
            :total-items="teams.length"
            :items-per-page="itemsPerPage"
            @page-changed="handlePageChange"
          />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, onMounted, ref, watch, onActivated } from 'vue'
import { RouterLink, useRouter, useRoute } from 'vue-router'
import SpriteImage from '../components/SpriteImage.vue'
import Pagination from '../components/Pagination.vue'
import { authStore } from '../stores/authStore'
import { store as selectionStore } from '../stores/selectionStore'
import { fetchTeamComps, fetchTeamComp, deleteTeamComp, likeTeam, unlikeTeam, favoriteTeam, unfavoriteTeam } from '../services/api'
import { teamStore } from '../stores/teamStore'
import { extractDescriptionSegments } from '../utils/descriptionUtils'

const router = useRouter()
const route = useRoute()

const loading = ref(false)
const searchTerm = ref('')
const currentPage = ref(1)
const hasMounted = ref(false)
const teamType = ref('system')
const deletingTeamId = ref(null)

const itemsPerPage = computed(() => teamType.value === 'system' ? 6 : 10)

const allTeams = computed(() => teamStore.list)

const filteredTeams = computed(() => {
  if (!searchTerm.value.trim()) {
    return allTeams.value
  }
  const query = searchTerm.value.trim().toLowerCase()
  return allTeams.value.filter((team) => {
    const matchesName = team.name?.toLowerCase().includes(query)
    const matchesDescription = team.description?.toLowerCase().includes(query)
    const matchesChampions = team.championNames?.some((name) => name.toLowerCase().includes(query))
    return matchesName || matchesDescription || matchesChampions
  })
})

const teams = computed(() => filteredTeams.value)

const paginatedTeams = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return teams.value.slice(start, end)
})

const totalCount = computed(() => teams.value.length)
const displayedCount = computed(() => paginatedTeams.value.length)
const isAuthenticated = computed(() => authStore.isAuthenticated())
const isLoggedIn = computed(() => authStore.isAuthenticated())
const isAdmin = computed(() => authStore.isAdmin())
const createRoute = computed(() => (
  isAuthenticated.value ? { name: 'team-create' } : { name: 'login', query: { redirect: '/teams/new' } }
))
const searchActive = computed(() => searchTerm.value.trim().length > 0)

const handlePageChange = (page) => {
  currentPage.value = page
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

const numberFormatter = new Intl.NumberFormat()

const percentage = (value) => {
  if (value === null || value === undefined) return 'N/A'
  return (value * 100).toFixed(1) + '%'
}

const summarize = (text, limit = 160) => {
  if (!text) return ''
  if (text.length <= limit) return text

  // Find a good break point, preferring word boundaries and line breaks
  let breakPoint = limit
  const breakChars = [' ', '\n', '.', ',', ';', ':', '!', '?']

  for (let i = limit; i > limit - 20 && i > 0; i--) {
    if (breakChars.includes(text[i])) {
      breakPoint = i + 1
      break
    }
  }

  return text.slice(0, breakPoint) + '...'
}

const formatSet = (set) => {
  if (!set) return ''
  const match = String(set).match(/TFT(\d+)/i)
  return match ? `Set ${match[1]}` : set
}

const unitCount = (team) => {
  if (!team) return 0
  return team.size || team.championNames?.length || team.cards?.length || 0
}

const avgPlacement = (team) => {
  const value = team?.meta?.avgPlacement
  if (value === undefined || value === null) return null
  const numeric = Number(value)
  if (Number.isNaN(numeric)) return null
  return numeric.toFixed(2)
}

const playCount = (team) => {
  const value = team?.meta?.playCount
  if (!value) return null
  return numberFormatter.format(value)
}

const descriptionSegments = (team) => {
  if (!team) return []
  return extractDescriptionSegments(team.description).slice(0, 2)
}

const formatDate = (dateString) => {
  if (!dateString) return ''
  const date = new Date(dateString)
  return date.toLocaleDateString()
}

const loadInitial = async () => {
  loading.value = true
  console.log('[TeamListPage] Loading teams, type:', teamType.value)
  try {
    const { teams: newTeams, meta } = await fetchTeamComps({ page: 1, per: 100, type: teamType.value })
    console.log('[TeamListPage] Loaded teams:', newTeams.length, 'teams')
    teamStore.setTeams(newTeams, meta)
    console.log('[TeamListPage] Team store updated, total:', teamStore.list.length)
  } catch (error) {
    console.error('[TeamListPage] Failed to load teams:', error)
    alert('Failed to load teams. Please refresh the page.')
  } finally {
    loading.value = false
    hasMounted.value = true
  }
}

const canEditTeam = (team) => {
  if (!team) return false
  if (authStore.isAdmin()) return true
  return !team.isSystemTeam && team.userId === authStore.user?.id
}

const canDeleteTeam = (team) => {
  if (!team) return false
  if (authStore.isAdmin()) return true
  return !team.isSystemTeam && team.userId === authStore.user?.id
}

const removeTeam = async (id) => {
  console.log('[TeamListPage] Attempting to delete team:', id)
  const team = teamStore.getById(id)
  console.log('[TeamListPage] Team to delete:', team)
  
  if (!canDeleteTeam(team)) {
    console.warn('[TeamListPage] User does not have permission to delete this team')
    alert('You do not have permission to delete this team.')
    return
  }

  const confirmed = window.confirm('Remove this team from your library?')
  if (!confirmed) {
    console.log('[TeamListPage] Delete cancelled by user')
    return
  }

  deletingTeamId.value = id
  console.log('[TeamListPage] Deleting team...')
  try {
    await deleteTeamComp(id)
    console.log('[TeamListPage] Team deleted successfully from API')
    teamStore.remove(id)
    console.log('[TeamListPage] Team removed from store')
    // 刷新列表以确保同步
    await loadInitial()
    console.log('[TeamListPage] Teams list refreshed after deletion')
  } catch (error) {
    console.error('[TeamListPage] Failed to delete team:', error)
    alert('Failed to delete team: ' + (error.message || 'Unknown error'))
    // 如果失败，重新加载以确保数据一致性
    await loadInitial()
  } finally {
    deletingTeamId.value = null
    console.log('[TeamListPage] Delete operation completed')
  }
}

const toggleLike = async (team) => {
  if (!isLoggedIn.value) {
    alert('Please login to like teams')
    router.push({ name: 'login', query: { redirect: route.fullPath } })
    return
  }

  try {
    if (team.isLiked) {
      const result = await unlikeTeam(team.id)
      team.isLiked = result.liked
      team.likesCount = result.likesCount
    } else {
      const result = await likeTeam(team.id)
      team.isLiked = result.liked
      team.likesCount = result.likesCount
    }
  } catch (error) {
    console.error('[TeamListPage] Failed to toggle like:', error)
    
    // Handle 422 error (already liked)
    if (error.response?.status === 422) {
      // If we get 422, it means the like already exists
      // Update the UI to reflect the actual state
      team.isLiked = true
      // Optionally reload the team to get the correct count
      try {
        const updatedTeam = await fetchTeamComp(team.id)
        team.likesCount = updatedTeam.likesCount
      } catch (e) {
        console.error('[TeamListPage] Failed to reload team:', e)
      }
    } else {
      alert('Failed to update like status: ' + (error.response?.data?.error || error.message))
    }
  }
}

const toggleFavorite = async (team) => {
  if (!isLoggedIn.value) {
    alert('Please login to favorite teams')
    router.push({ name: 'login', query: { redirect: route.fullPath } })
    return
  }

  try {
    if (team.isFavorited) {
      const result = await unfavoriteTeam(team.id)
      team.isFavorited = result.favorited
      team.favoritesCount = result.favoritesCount
    } else {
      const result = await favoriteTeam(team.id)
      team.isFavorited = result.favorited
      team.favoritesCount = result.favoritesCount
    }
  } catch (error) {
    console.error('[TeamListPage] Failed to toggle favorite:', error)
    
    // Handle 422 error (already favorited)
    if (error.response?.status === 422) {
      // If we get 422, it means the favorite already exists
      // Update the UI to reflect the actual state
      team.isFavorited = true
      // Optionally reload the team to get the correct count
      try {
        const updatedTeam = await fetchTeamComp(team.id)
        team.favoritesCount = updatedTeam.favoritesCount
      } catch (e) {
        console.error('[TeamListPage] Failed to reload team:', e)
      }
    } else {
      alert('Failed to update favorite status: ' + (error.response?.data?.error || error.message))
    }
  }
}


const editTeam = (id) => {
  router.push({ name: 'team-edit', params: { id } })
}

watch(
  () => searchTerm.value,
  () => {
    if (!hasMounted.value) return
    currentPage.value = 1
  }
)

watch(
  () => teamType.value,
  async (newType, oldType) => {
    if (!hasMounted.value) return
    console.log('[TeamListPage] Team type changed from', oldType, 'to', newType)
    currentPage.value = 1
    await loadInitial()
  }
)

onMounted(async () => {
  console.log('[TeamListPage] Component mounted')
  await loadInitial()
})

// 当页面重新激活时（从创建页面返回）刷新数据
onActivated(async () => {
  console.log('[TeamListPage] Component activated (returned from another page)')
  await loadInitial()
})

// 监听路由查询参数变化，自动切换团队类型
watch(
  () => route.query.type,
  (newType) => {
    console.log('[TeamListPage] Route query type changed to:', newType)
    if (newType && (newType === 'system' || newType === 'user')) {
      console.log('[TeamListPage] Switching to', newType, 'teams')
      teamType.value = newType
    }
  },
  { immediate: true }
)
</script>

<style scoped>
/* System Teams Grid Layout */
.system-teams-layout {
  width: 100%;
}

.system-team-card {
  min-height: 320px;
  max-height: 400px;
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.system-team-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.15) !important;
}

.system-team-card .card-body {
  display: flex;
  flex-direction: column;
}

.system-team-header {
  min-height: 60px;
  max-height: 80px;
  overflow: hidden;
}

.system-champions-strip {
  min-height: 80px;
  max-height: 110px;
  flex-shrink: 0;
  overflow-x: auto;
  overflow-y: hidden;
  -webkit-overflow-scrolling: touch;
}

.system-mini-card {
  width: 72px;
  height: 72px;
  border-radius: 14px;
  overflow: hidden;
  flex: 0 0 auto;
}

.system-card-img {
  width: 72px;
  height: 72px;
  border-radius: 14px;
  border: 3px solid rgba(184, 155, 94, 0.65);
  box-shadow: 0 4px 10px rgba(15, 23, 42, 0.35);
}

.system-meta-row {
  border-top: 1px solid rgba(15, 23, 42, 0.08);
  padding-top: 0.75rem;
}

.win-pill {
  white-space: nowrap;
}

.meta-item {
  display: flex;
  align-items: flex-start;
  gap: 0.5rem;
}

.meta-item i {
  font-size: 1.1rem;
  color: #6c7385;
  margin-top: 0.1rem;
}

.meta-label {
  font-size: 0.65rem;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  color: #6c7585;
}

.meta-value {
  font-weight: 600;
  color: #212529;
}

/* User Teams List Layout */
.user-teams-layout {
  width: 100%;
}

.user-teams-list {
  max-width: 100%;
}

.user-team-row {
  transition: all 0.2s ease;
}

.user-team-row:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1) !important;
}

.user-team-info {
  min-width: 0;
  flex: 1;
}

.user-description {
  line-height: 1.4;
  word-wrap: break-word;
  word-break: break-word;
  hyphens: auto;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  line-clamp: 2;
  overflow: hidden;
}

.user-team-meta {
  opacity: 0.8;
}

.user-team-meta i {
  font-size: 0.9rem;
}

.user-team-meta .text-primary {
  font-weight: 600;
  opacity: 1;
}

.user-team-icons {
  flex-shrink: 0;
  align-items: center;
}

.user-mini-card {
  width: 48px;
  height: 48px;
  border-radius: 8px;
  overflow: hidden;
  flex: 0 0 auto;
}

.user-card-img {
  width: 48px;
  height: 48px;
  border-radius: 8px;
  border: 2px solid rgba(184, 155, 94, 0.65);
  box-shadow: 0 2px 6px rgba(15, 23, 42, 0.25);
}

.more-indicator {
  display: flex;
  align-items: center;
  margin-left: 0.5rem;
}

.user-team-actions {
  flex-shrink: 0;
  min-width: 80px;
}

/* Responsive */
@media (max-width: 991.98px) {
  .user-team-row .d-flex {
    flex-direction: column;
  }
  
  .user-team-icons {
    order: 2;
    margin-top: 1rem;
  }
  
  .user-team-actions {
    order: 3;
    flex-direction: row !important;
    margin-top: 1rem;
  }
}
</style>
