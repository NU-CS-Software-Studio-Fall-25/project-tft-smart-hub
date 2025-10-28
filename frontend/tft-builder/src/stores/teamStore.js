import { reactive } from 'vue'

export const teamStore = reactive({
  list: [],
  byId: {},
  meta: {
    page: 1,
    per: 50,
    total: 0,
    totalPages: 1,
    hasMore: false,
  },

  setTeams(teams = [], meta = {}) {
    const normalized = Array.isArray(teams) ? teams : []
    this.list = normalized
    this.byId = normalized.reduce((acc, team) => {
      if (team?.id) acc[team.id] = team
      return acc
    }, {})
    this.meta = { ...this.meta, ...meta }
  },

  appendTeams(teams = [], meta = {}) {
    const additions = Array.isArray(teams) ? teams : []
    if (!additions.length) {
      this.meta = { ...this.meta, ...meta }
      return
    }

    const merged = new Map(this.list.map((team) => [team.id, team]))
    additions.forEach((team) => {
      if (team?.id) {
        merged.set(team.id, team)
      }
    })

    const entries = Array.from(merged.entries())
    this.list = entries.map(([, team]) => team)
    this.byId = entries.reduce((acc, [id, team]) => {
      acc[id] = team
      return acc
    }, {})

    this.meta = { ...this.meta, ...meta }
  },

  upsert(team) {
    if (!team || !team.id) return
    const index = this.list.findIndex((item) => item.id === team.id)
    if (index >= 0) {
      this.list.splice(index, 1, team)
    } else {
      this.list.unshift(team)
    }
    this.byId[team.id] = team
  },

  remove(id) {
    this.list = this.list.filter((team) => team.id !== id)
    delete this.byId[id]
    if (this.meta?.total) {
      this.meta.total = Math.max(0, this.meta.total - 1)
    }
  },

  getById(id) {
    return this.byId[id]
  },
})
