<template>
  <canvas
    v-if="useSprite"
    ref="canvasRef"
    :width="size"
    :height="size"
    :class="wrapperClass"
    role="img"
    :aria-label="alt || 'Champion portrait'"
  />
  <img
    v-else
    :src="normalizedImageUrl || fallback"
    :alt="alt || 'Champion portrait'"
    :class="imgClass"
    @error="onError"
  />
</template>

<script setup>
import { computed, onMounted, ref, watch } from 'vue'

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
const canvasRef = ref(null)
const imageCache = new Map()

const normalizedImageUrl = computed(() => {
  if (!props.imageUrl) return ''
  if (/^https?:\/\//i.test(props.imageUrl)) return props.imageUrl
  const trimmed = props.imageUrl.replace(/^\/+/, '')
  return `/${trimmed}`
})

const hasImageAsset = computed(() => !!normalizedImageUrl.value && !broken.value)
const useSprite = computed(() => !hasImageAsset.value && !!props.sprite?.sheet)

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

const wrapperClass = computed(() => ['sprite-wrapper', 'sprite-canvas', props.className].filter(Boolean))
const imgClass = computed(() => ['sprite-fallback', props.className].filter(Boolean))

const onError = () => {
  broken.value = true
}

const loadImage = (path) => {
  if (!path) return Promise.reject(new Error('Missing sprite sheet path'))
  if (imageCache.has(path)) {
    const cached = imageCache.get(path)
    if (cached instanceof Promise) {
      return cached
    }
    return Promise.resolve(cached)
  }

  const promise = new Promise((resolve, reject) => {
    const img = new Image()
    img.onload = () => {
      imageCache.set(path, img)
      resolve(img)
    }
    img.onerror = reject
    img.src = path
  })

  imageCache.set(path, promise)
  return promise
}

const renderSprite = async () => {
  if (!useSprite.value || !props.sprite) return
  const canvas = canvasRef.value
  if (!canvas) return
  const ctx = canvas.getContext('2d')
  if (!ctx) return

  const path = sheetPath.value
  if (!path) return

  try {
    const image = await loadImage(path)
    const { x = 0, y = 0, w = props.sprite.w || props.size, h = props.sprite.h || props.size } = props.sprite
    ctx.clearRect(0, 0, canvas.width, canvas.height)
    ctx.imageSmoothingEnabled = false
    ctx.drawImage(image, x, y, w, h, 0, 0, props.size, props.size)
  } catch (error) {
    console.error('[sprite] failed to render sprite', error)
  }
}

watch([useSprite, () => props.sprite, () => props.size, sheetPath], () => {
  if (useSprite.value) {
    renderSprite()
  }
})

onMounted(() => {
  if (useSprite.value) {
    renderSprite()
  }
})
</script>

<style scoped>
.sprite-wrapper {
  width: 100%;
  height: 100%;
  border-radius: 12px;
  overflow: hidden;
  display: block;
}

.sprite-canvas {
  background: transparent;
}

.sprite-fallback {
  border-radius: 12px;
  object-fit: cover;
  width: 100%;
  height: 100%;
  display: block;
}
</style>
