<template>
  <div class="not-found-container">
    <div class="content">
      <svg class="gem-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
        <defs>
          <linearGradient id="gem404" x1="0%" y1="0%" x2="100%" y2="100%">
            <stop offset="0%" style="stop-color:#ffc107;stop-opacity:1" />
            <stop offset="100%" style="stop-color:#ffa000;stop-opacity:1" />
          </linearGradient>
        </defs>
        <path d="M 50 10 L 80 35 L 50 90 L 20 35 Z" fill="url(#gem404)" stroke="#ff6f00" stroke-width="2"/>
      </svg>
      
      <h1 class="error-code">404</h1>
      <h2>Team Composition Not Found</h2>
      <p class="description">
        Looks like this page didn't make it to the meta. The composition you're looking for might have been removed or never existed.
      </p>
      
      <div class="actions">
        <RouterLink to="/" class="btn btn-primary">
          <i class="bi bi-house-fill me-2"></i>
          Return to Home
        </RouterLink>
      </div>
      
      <div class="quick-links">
        <RouterLink to="/teams" class="link">Browse Teams</RouterLink>
        <RouterLink to="/builder" class="link">Team Builder</RouterLink>
      </div>
    </div>
  </div>
</template>

<style scoped>
.not-found-container {
  min-height: calc(100vh - 120px);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 40px 20px;
  background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
}

.content {
  text-align: center;
  max-width: 600px;
}

.gem-icon {
  width: 120px;
  height: 120px;
  margin: 0 auto 30px;
  opacity: 0.3;
  animation: float 3s ease-in-out infinite;
}

@keyframes float {
  0%, 100% { transform: translateY(0px); }
  50% { transform: translateY(-20px); }
}

.error-code {
  font-size: 96px;
  font-weight: 700;
  color: #ffc107;
  margin-bottom: 20px;
  text-shadow: 0 0 20px rgba(255, 193, 7, 0.3);
  line-height: 1;
}

h2 {
  font-size: 32px;
  margin-bottom: 20px;
  color: #fff;
}

.description {
  font-size: 18px;
  line-height: 1.6;
  margin-bottom: 40px;
  color: #b0b0b0;
}

.actions {
  margin-bottom: 30px;
}

.btn-primary {
  display: inline-flex;
  align-items: center;
  padding: 14px 32px;
  background: linear-gradient(135deg, #ffc107 0%, #ffa000 100%);
  color: #1a1a2e;
  text-decoration: none;
  border-radius: 8px;
  font-weight: 600;
  font-size: 16px;
  transition: transform 0.2s, box-shadow 0.2s;
  box-shadow: 0 4px 15px rgba(255, 193, 7, 0.3);
}

.btn-primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(255, 193, 7, 0.4);
  color: #1a1a2e;
}

.quick-links {
  padding-top: 30px;
  border-top: 1px solid rgba(255, 255, 255, 0.1);
  display: flex;
  gap: 20px;
  justify-content: center;
}

.link {
  color: #ffc107;
  text-decoration: none;
  font-size: 16px;
  transition: color 0.2s;
}

.link:hover {
  color: #ffeb3b;
  text-decoration: underline;
}

@media (max-width: 576px) {
  .error-code {
    font-size: 72px;
  }
  
  h2 {
    font-size: 24px;
  }
  
  .gem-icon {
    width: 80px;
    height: 80px;
  }
}
</style>
