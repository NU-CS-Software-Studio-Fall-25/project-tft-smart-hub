import { reactive } from 'vue'

export const teamStore = reactive({
  list: [],
  byId: {},

  setTeams(teams = []) {
    this.list = Array.isArray(teams) ? teams : []
    this.byId = this.list.reduce((acc, team) => {
      acc[team.id] = team
      return acc
    }, {})
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
  },

  getById(id) {
    return this.byId[id]
  },
})
