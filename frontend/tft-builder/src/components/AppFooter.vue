<template>
  <footer class="bg-dark border-top border-secondary mt-auto text-white-50">
    <div class="container py-4 d-flex flex-column flex-lg-row align-items-lg-center justify-content-between gap-3">
      <div>
        <strong class="text-light">TFT Team Lab</strong>
        <div class="small">
          Built with Vue 3 + Rails API. Data powered by the TFT community datasets.
        </div>
      </div>
      <div class="d-flex gap-3 small">
        <a href="https://www.communitydragon.org/" target="_blank" rel="noreferrer" class="link-light text-decoration-none">
          CommunityDragon
        </a>
        <RouterLink to="/builder" class="link-light text-decoration-none">
          Search Builder
        </RouterLink>
        <RouterLink to="/teams" class="link-light text-decoration-none">
          Team Library
        </RouterLink>
      </div>
    </div>
  </footer>
</template>
