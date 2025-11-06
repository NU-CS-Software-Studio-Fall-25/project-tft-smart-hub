<template>
  <div
    v-if="useSprite"
    :class="wrapperClass"
    :style="wrapperStyle"
    role="img"
    :aria-label="alt || 'Champion portrait'"
  >
    <div class="sprite-inner" :style="spriteStyle" aria-hidden="true"></div>
  </div>
  <img
    v-else
    :src="imageUrl || fallback"
    :alt="alt || 'Champion portrait'"
    :class="imgClass"
    @error="onError"
  />
</template>

<script setup>
import { computed, ref, watch } from 'vue'

const props = defineProps({
  sprite: {
    type: Object,
    default: null,
  },
  imageUrl: {
    type: String,
    default: '',
  },
  size: {
    type: Number,
    default: 92,
  },
  alt: {
    type: String,
    default: '',
  },
  className: {
    type: String,
    default: '',
  },
  fallback: {
    type: String,
    default: '/tft-placeholder.svg',
  },
})

const broken = ref(false)
const isAbsoluteUrl = computed(() =>
  typeof props.imageUrl === 'string' && /^https?:\/\//i.test(props.imageUrl)
)

const hasExternalImage = computed(() => isAbsoluteUrl.value && !broken.value)
const useSprite = computed(() => !hasExternalImage.value && !!props.sprite?.sheet)

watch(
  () => props.imageUrl,
  () => {
    broken.value = false
  }
)

const sheetPath = computed(() => {
  if (!props.sprite?.sheet) return ''
  return `/sprites/${props.sprite.sheet}`
})

const scale = computed(() => {
  if (!props.sprite?.h) return 1
  return props.size / props.sprite.h
})

const wrapperClass = computed(() => ['sprite-wrapper', props.className].filter(Boolean))

const wrapperStyle = computed(() => ({
  width: `${props.size}px`,
  height: `${props.size}px`,
}))

const spriteStyle = computed(() => {
  if (!props.sprite) return {}
  const { x = 0, y = 0, w = props.size, h = props.size } = props.sprite
  return {
    width: `${w}px`,
    height: `${h}px`,
    backgroundImage: `url(${sheetPath.value})`,
    backgroundRepeat: 'no-repeat',
    backgroundPosition: `${-x}px ${-y}px`,
    transform: `scale(${scale.value})`,
    transformOrigin: 'top left',
    imageRendering: 'pixelated',
  }
})

const imgClass = computed(() => ['sprite-fallback', props.className].filter(Boolean))

const onError = () => {
  broken.value = true
}
</script>

<style scoped>
.sprite-wrapper {
  position: relative;
  border-radius: 12px;
  overflow: hidden;
}

.sprite-inner {
  border-radius: 12px;
}

.sprite-fallback {
  border-radius: 12px;
  object-fit: cover;
  width: 100%;
  height: 100%;
}
</style>

