<template>
  <div class="page-white">
    <div class="container py-5">
      <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3 mb-4">
        <div>
          <h1 class="h3 fw-bold mb-1">Team composition library</h1>
          <p class="mb-0 text-body-secondary">
            Review curated comps, compare win rates, and jump straight into the details.
          </p>
        </div>
        <RouterLink class="btn btn-primary" :to="{ name: 'team-create' }">
          <i class="bi bi-plus-circle me-1"></i>
          Add a new team
        </RouterLink>
      </div>

      <div v-if="loading" class="py-5 text-center">
        <div class="spinner-border"></div>
        <div class="mt-3 text-body-secondary">Loading team compositions...</div>
      </div>

      <div v-else>
        <div v-if="teams.length === 0" class="alert alert-info">
          No team compositions saved yet. Create your first comp via the
          <RouterLink to="/teams/new">team builder</RouterLink>.
        </div>

        <div v-else class="row g-4 row-cols-1 row-cols-lg-2">
          <div v-for="team in teams" :key="team.id" class="col">
            <div class="team-card card h-100 shadow-sm border-0">
              <div class="card-body d-flex flex-column">
                <div class="d-flex justify-content-between align-items-start mb-3">
                  <div class="pe-3">
                    <h2 class="h4 fw-semibold mb-1">{{ team.name }}</h2>
                    <p class="text-body-secondary small mb-0">
                      {{ truncate(team.description, 150) }}
                    </p>
                  </div>
                  <span class="badge bg-success-subtle text-success-emphasis fs-6">
                    Win {{ percentage(team.winRate) }}
                  </span>
                </div>

                <div class="team-card-strip horizontal-scroll d-flex gap-3 pb-2">
                  <div
                    v-for="card in team.cards"
                    :key="`${team.id}-${card.id}`"
                    class="mini-card"
                    :title="card.name"
                    @contextmenu.prevent="preview(card)"
                  >
                    <SpriteImage
                      :sprite="card.sprite"
                      :image-url="card.imageUrl"
                      :alt="card.name"
                      :size="72"
                      class-name="mini-card-img"
                    />
                  </div>
                </div>

                <div class="d-flex justify-content-between align-items-center mt-4 small text-body-secondary">
                  <div>
                    <i class="bi bi-people me-1"></i>
                    Play {{ percentage(team.playRate) }}
                  </div>
                  <div v-if="team.source">Source: {{ team.source }}</div>
                </div>
              </div>
              <div class="card-footer bg-white d-flex justify-content-between gap-3">
                <RouterLink
                  class="btn btn-sm btn-outline-primary flex-grow-1"
                  :to="{ name: 'team-detail', params: { id: team.id } }"
                >
                  View details
                </RouterLink>
                <button class="btn btn-sm btn-outline-danger" @click="removeTeam(team.id)">
                  <i class="bi bi-trash"></i>
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'
import { RouterLink } from 'vue-router'
import SpriteImage from '../components/SpriteImage.vue'
import { store as selectionStore } from '../stores/selectionStore'
import { fetchTeamComps, deleteTeamComp } from '../services/api'
import { teamStore } from '../stores/teamStore'

const loading = ref(false)

const teams = computed(() => teamStore.list)

const percentage = (value) => {
  if (value === null || value === undefined) return 'N/A'
  return `${(value * 100).toFixed(1)}%`
}

const truncate = (text, limit) => {
  if (!text) return ''
  return text.length > limit ? `${text.slice(0, limit)}…` : text
}

const removeTeam = async (id) => {
  const confirmed = window.confirm('Remove this team from your library?')
  if (!confirmed) return
  await deleteTeamComp(id)
  teamStore.remove(id)
}

const preview = (card) => {
  selectionStore.focusChampion(card)
}

onMounted(async () => {
  if (teamStore.list.length) return
  loading.value = true
  try {
    const data = await fetchTeamComps()
    teamStore.setTeams(data)
  } finally {
    loading.value = false
  }
})
</script>

<style scoped>
.team-card {
  min-height: 360px;
  padding-bottom: 1.5rem;
}

.team-card-strip {
  min-height: 110px;
}

.mini-card {
  width: 72px;
  height: 72px;
  border-radius: 14px;
  overflow: hidden;
  flex: 0 0 auto;
}

.mini-card-img {
  width: 72px;
  height: 72px;
  border-radius: 14px;
  border: 3px solid rgba(184, 155, 94, 0.65);
  box-shadow: 0 4px 10px rgba(15, 23, 42, 0.35);
}
</style>
