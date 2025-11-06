### Accessibility (RTZ)
1. Proper heading hierarchy has been implemented across all pages to help screen reader users navigate and understand page structure. 

**CardPickerPage.vue  Heading Structure:**
```
h1: Champion Synergy Search
├── h2: Selected champions
├── h2: Filter champions (in aside)
└── h2: Champion roster
```

**RecommendationsPage.vue Heading Structure:**
```
h1: Recommended team compositions
├── h2: Selected champions (sidebar)
└── For each team:
    ├── h2: [Team Name]
    └── h3: Champions in [Team Name] (visually hidden)
```


2. All champion images and portraits now have proper alternative text for screen readers.
**Before:**
```vue
<div class="sprite-wrapper">
  <div class="sprite-inner"></div>
</div>
```

**After:**
```vue
<div 
  role="img"
  aria-label="Ahri champion portrait"
  class="sprite-wrapper"
>
  <div class="sprite-inner" aria-hidden="true"></div>
</div>
```



### Colors
1. Home Page
- White heading text #ffffff on dark background #0b0f17 = 19.17：1
- Button text #1a1a2e on gold background #ffc107 = 10.46:1

2. Champion Selection Page (CardPickerPage)
- Card title #f9f7fb on dark background #0b0f17 = 18:1

3. Recommendations Page
- Team name #212529 on white background #ffffff = 15:1 
- Champion name on card #1f2638 on light-blue background = 12:1 


4. Team List Page
- Team title #212529 on white #ffffff = 15:1 
- Trait count #6c7385 on white = 5.1:1 

### Additional Accessibility Improvements (YRM)
1. Promoted the team library wrapper to a semantic `<main>` landmark so assistive tech can jump straight to the core content.  

**Before:**
```vue
<div class="page-white">
  ...
</div>
```
**After:**
```vue
<main class="page-white" aria-labelledby="team-library-heading">
  ...
</main>
```

2. Enabled keyboard access for champion thumbnails in the saved-team strip, ensuring the preview modal works without a mouse.  
**Before:**
```vue
<div
  v-for="card in team.cards"
  :key="`${team.id}-${card.id}`"
  class="mini-card"
  :title="card.name"
  @contextmenu.prevent="preview(card)"
>
```
**After:**
```vue
<div
  v-for="card in team.cards"
  :key="`${team.id}-${card.id}`"
  class="mini-card"
  :title="card.name"
  role="button"
  tabindex="0"
  :aria-label="`Preview ${card.name}`"
  @click="preview(card)"
  @keydown.enter.prevent="preview(card)"
  @keydown.space.prevent="preview(card)"
  @contextmenu.prevent="preview(card)"
>
```
