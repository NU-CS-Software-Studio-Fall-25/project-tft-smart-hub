import rawCards from './cards.json'

// 小工具
const byId = Object.fromEntries(rawCards.map(c => [c.id, c]))
const pick = (arr, n) => arr.slice().sort(() => Math.random() - 0.5).slice(0, n)

// 导出：获取卡牌
export async function fetchCardsMock() {
  await delay(200) // 模拟网络
  return rawCards
}

// 导出：根据包含卡牌生成 N 个推荐卡组（默认 8 组）
export async function fetchRecommendationsMock(includeCards, { teamCount = 8 } = {}) {
  await delay(400)

  const cards = rawCards
  const teams = Array.from({ length: teamCount }, (_, i) => {
    // 随机补齐到 8 张（保持单行，前端会横向滚动）
    const extra = pick(cards.map(c => c.id).filter(id => !includeCards.includes(id)), 8)
    const ids = Array.from(new Set([...includeCards, ...extra])).slice(0, 8)

    return {
      id: `team-${i + 1}`,
      name: `卡组${i + 1}：示例阵容`,
      winRate: +(0.48 + Math.random() * 0.2).toFixed(3),
      playRate: +(0.10 + Math.random() * 0.3).toFixed(3),
      notes: '示例：前排控制 + 后排持续输出；真实字段可由后端调整。',
      cards: ids.map(id => byId[id]).filter(Boolean)
    }
  })

  return {
    selected: includeCards.map(id => byId[id]).filter(Boolean),
    teams
  }
}

function delay(ms) { return new Promise(r => setTimeout(r, ms)) }
