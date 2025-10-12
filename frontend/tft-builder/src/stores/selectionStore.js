import { reactive } from 'vue'

export const store = reactive({
  allCards: [],
  selectedIds: new Set(),
  recommendations: null,
  focusedChampion: null,

  clearSelection() {
    this.selectedIds = new Set()
  },

  toggle(id) {
    if (this.selectedIds.has(id)) {
      this.selectedIds.delete(id)
    } else {
      this.selectedIds.add(id)
    }
  },

  remove(id) {
    this.selectedIds.delete(id)
  },

  setAllCards(cards) {
    this.allCards = cards || []
  },

  setRecommendations(payload) {
    this.recommendations = payload || null
  },

  focusChampion(champion) {
    this.focusedChampion = champion || null
  },

  clearFocusedChampion() {
    this.focusedChampion = null
  },
})
