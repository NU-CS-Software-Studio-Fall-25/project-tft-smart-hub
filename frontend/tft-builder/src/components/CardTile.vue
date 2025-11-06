<template>
  <div
    class="tft-card-tile position-relative"
    :class="{ selected }"
    @click="onToggle"
    @contextmenu.prevent="onPreview"
    role="button"
    tabindex="0"
    :aria-label="cardAriaLabel"
    :aria-pressed="selected"
    @keydown.enter="onToggle"
    @keydown.space.prevent="onToggle"
  >
    <div v-if="selected" class="selected-indicator" aria-hidden="true">
      <i class="bi bi-check-circle-fill"></i>
    </div>
    <SpriteImage
      :sprite="card.sprite"
      :image-url="card.imageUrl"
      :alt="`${card.name} champion portrait`"
      :size="size"
      class-name="tft-card-img"
    />
    <div v-if="showName" class="tft-card-name">{{ card.name }}</div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import SpriteImage from './SpriteImage.vue'
import { store as selectionStore } from '../stores/selectionStore'

const props = defineProps({
  card: {
    type: Object,
    required: true,
  },
  selected: {
    type: Boolean,
    default: false,
  },
  size: {
    type: Number,
    default: 92,
  },
  hideRemove: {
    type: Boolean,
    default: false,
  },
  showName: {
    type: Boolean,
    default: true,
  },
})

const emits = defineEmits(['toggle', 'remove'])

const cardAriaLabel = computed(() => {
  const tierInfo = props.card.tier ? `, Tier ${props.card.tier}` : ''
  const statusInfo = props.selected ? ', selected' : ', not selected'
  return `${props.card.name}${tierInfo}${statusInfo}. Press Enter or Space to toggle selection.`
})

const cardId = computed(() => props.card?.id)

const onToggle = () => {
  if (!cardId.value) return
  emits('toggle', cardId.value)
}

const onRemove = () => {
  if (!cardId.value) return
  emits('remove', cardId.value)
}

const onPreview = () => {
  if (!props.card) return
  selectionStore.focusChampion(props.card)
}
</script>
