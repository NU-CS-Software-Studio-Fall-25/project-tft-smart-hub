<template>
  <div
    class="tft-card-tile position-relative"
    :class="{ selected }"
    @click="onToggle"
    @contextmenu.prevent="onPreview"
  >
    <div v-if="selected" class="selected-indicator">
      <i class="bi bi-check-circle-fill"></i>
    </div>
    <SpriteImage
      :sprite="card.sprite"
      :image-url="card.imageUrl"
      :alt="card.name"
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
