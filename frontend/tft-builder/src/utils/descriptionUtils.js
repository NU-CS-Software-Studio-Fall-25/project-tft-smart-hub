export function extractDescriptionSegments(description = '') {
  if (!description) return []

  const segments = []
  const normalized = description.replace(/\s+/g, ' ').trim()

  const patterns = [
    { label: 'Lineup', regex: /Lineup:\s*([^.]*)/i },
    { label: 'Key traits', regex: /Key traits:\s*([^.]*)/i },
    { label: 'Avg placement', regex: /(Avg placement[^.]*)/i },
  ]

  patterns.forEach(({ label, regex }) => {
    const match = normalized.match(regex)
    if (match && match[1]) {
      segments.push({
        label,
        value: match[1].trim(),
      })
    }
  })

  if (!segments.length && normalized) {
    segments.push({
      label: '',
      value: normalized,
    })
  }

  return segments
}
