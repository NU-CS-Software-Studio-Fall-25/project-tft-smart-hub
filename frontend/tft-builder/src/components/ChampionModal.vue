<template>
  <transition name="modal-fade">
    <div
      v-if="champion"
      class="champion-modal-backdrop"
      role="dialog"
      aria-modal="true"
      :aria-labelledby="`champion-modal-title-${champion.id}`"
      @click.self="close"
      @keydown.esc="close"
    >
      <div class="champion-modal card shadow-lg">
        <div class="card-body p-4">
          <div class="d-flex justify-content-between align-items-start gap-3">
            <div class="d-flex align-items-center gap-3">
              <SpriteImage
                :sprite="champion.sprite"
                :image-url="champion.imageUrl"
                :alt="`${champion.name} champion portrait`"
                :size="120"
                class-name="modal-card-img"
              />
              <div>
                <h2 :id="`champion-modal-title-${champion.id}`" class="h4 fw-bold mb-1">{{ champion.name }}</h2>
                <div class="d-flex flex-wrap gap-2 align-items-center">
                  <span class="badge bg-warning text-dark fw-semibold">
                    Tier {{ champion.tier ?? '—' }}
                  </span>
                  <span
                    v-for="trait in champion.traits || []"
                    :key="trait"
                    class="badge bg-secondary-subtle text-secondary-emphasis"
                  >
                    {{ trait }}
                  </span>
                </div>
              </div>
            </div>
            <button 
              class="btn btn-link text-muted p-0" 
              @click="close"
              aria-label="Close champion details"
            >
              <i class="bi bi-x-lg fs-4" aria-hidden="true"></i>
            </button>
          </div>

          <div class="mt-4">
            <h3 class="h6 text-uppercase text-secondary fw-semibold mb-2">
              Appears in team comps
            </h3>
            <div v-if="teamsWithChampion.length === 0" class="text-body-secondary small">
              This champion is not part of any saved team compositions yet.
            </div>
            <ul v-else class="list-unstyled small mb-0">
              <li
                v-for="team in teamsWithChampion"
                :key="team.id"
                class="d-flex justify-content-between align-items-center border-bottom py-2"
              >
                <div>
                  <RouterLink
                    :to="{ name: 'team-detail', params: { id: team.id } }"
                    @click.prevent="viewTeam(team.id)"
                  >
                    {{ team.name }}
                  </RouterLink>
                  <div class="text-body-secondary">
                    Win {{ percentage(team.winRate) }} · Pick {{ percentage(team.playRate) }}
                  </div>
                </div>
                <button
                  class="btn btn-sm btn-outline-primary"
                  type="button"
                  @click="viewTeam(team.id)"
                >
                  View
                </button>
              </li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  </transition>
</template>

<script setup>
import { computed, onMounted, onBeforeUnmount } from 'vue'
import { RouterLink, useRouter } from 'vue-router'
import SpriteImage from './SpriteImage.vue'
import { store as selectionStore } from '../stores/selectionStore'
import { teamStore } from '../stores/teamStore'

const router = useRouter()
const champion = computed(() => selectionStore.focusedChampion)

const teamsWithChampion = computed(() => {
  if (!champion.value) return []
  return teamStore.list.filter((team) =>
    (team.championNames || []).includes(champion.value.name)
  )
})

const percentage = (value) => {
  if (value === null || value === undefined) return 'N/A'
  return `${(value * 100).toFixed(1)}%`
}

const close = () => {
  selectionStore.clearFocusedChampion()
}

const viewTeam = (id) => {
  if (!id) return
  close()
  router.push({ name: 'team-detail', params: { id } })
}

const onKeydown = (event) => {
  if (event.key === 'Escape') {
    close()
  }
}

onMounted(() => {
  window.addEventListener('keydown', onKeydown)
})

onBeforeUnmount(() => {
  window.removeEventListener('keydown', onKeydown)
})
</script>

<style scoped>
.champion-modal-backdrop {
  position: fixed;
  inset: 0;
  background: rgba(9, 12, 20, 0.6);
  display: grid;
  place-items: center;
  z-index: 1050;
  backdrop-filter: blur(6px);
  padding: 1.5rem;
}

.champion-modal {
  max-width: 560px;
  width: 100%;
  border: none;
}

.modal-card-img {
  border: 2px solid #b89b5e;
}

.modal-fade-enter-active,
.modal-fade-leave-active {
  transition: opacity 0.15s ease;
}

.modal-fade-enter-from,
.modal-fade-leave-to {
  opacity: 0;
}
</style>
