### 1. Application is prepared to work for 1000 users
```
wrk -t12 -c1000 -d30s https://tft-smartcomp-b3f1e37435eb.herokuapp.com/
```
Output:  
```
Running 30s test @ https://tft-smartcomp-b3f1e37435eb.herokuapp.com/
  12 threads and 1000 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency   424.63ms  163.62ms   2.00s    96.70%
    Req/Sec   205.94    138.77   797.00     72.05%
  72383 requests in 31.64s, 111.20MB read
  Socket errors: connect 0, read 0, write 0, timeout 576
Requests/sec:   2287.74
Transfer/sec:      3.51MB
```

```
wrk -t12 -c1000 -d30s https://tft-smartcomp-b3f1e37435eb.herokuapp.com/teams
```

Output:
```
t-smartcomp-b3f1e37435eb.herokuapp.com/teams
Running 30s test @ https://tft-smartcomp-b3f1e37435eb.herokuapp.com/teams
  12 threads and 1000 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     1.06s   136.80ms   1.46s    91.86%
    Req/Sec   106.50    118.71   580.00     82.37%
  26793 requests in 30.10s, 48.10MB read
Requests/sec:    890.25
Transfer/sec:      1.60MB
```

### 2. Pagination is implemented
Pagy 10 items each time on Team Library

### 3. Uses header/footer, custom error pages,  site icon, other images (https://www.rgbstock.com/images/Links to an external site., https://pixabay.com/Links to an external site., https://unsplash.com/Links to an external site. - share yours), and a catchy product name and logo (use AI if you're stuck).
- design a new logo
- -Add favicon
- Add custom error pages

# 404
curl https://tft-smartcomp-b3f1e37435eb.herokuapp.com/test-404

https://tft-smartcomp-b3f1e37435eb.herokuapp.com/asdfasdf

# 422
curl https://tft-smartcomp-b3f1e37435eb.herokuapp.com/422.html

https://tft-smartcomp-b3f1e37435eb.herokuapp.com/422.html

# 500
curl https://tft-smartcomp-b3f1e37435eb.herokuapp.com/500.html

https://tft-smartcomp-b3f1e37435eb.herokuapp.com/500.html


### PWA
done



### Accessibility
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


2. 